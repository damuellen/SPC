let month = range.map { i in 1 }

let day = range.map { i in 5 }

let hour = range.map { i in 10 }

let dayOfYear = range.map { i in iff(hour[i] = 0, dayOfYear[i - 1] + 1, dayOfYear[i - 1]) }

let q_Sol_Loop = range.map { i in 0 }

let referencePVPlantPowerAtInverterInletMWel_DC = range.map { i in 264.04096096919 }

let referencePVMVPowerAtTransformerOutletMWel = range.map { i in 253.063793528884 }

let inverterPowerFraction = range.map { i in
  max(0, referencePVMVPowerAtTransformerOutletMWel[i] / max(G5: G8763))
}

let inverterEfficiency = range.map { i in
  IFERROR(
    iff(
      referencePVMVPowerAtTransformerOutletMWel[i] < max(G5: G8764),
      max(referencePVMVPowerAtTransformerOutletMWel[i], 0)
        / referencePVPlantPowerAtInverterInletMWel_DC[i],
      0
    ),
    0
  )
}

let q_solar_beforeDumping_MWth = range.map { i in q_Sol_Loop[i] * CSP_Loop_Nr }

let e_PV_Total_ScaledMWel_DC = range.map { i in
  referencePVPlantPowerAtInverterInletMWel_DC[i] * PV_DC_Cap / Ref_PV_DC_capacity
}

let pVMVPowerAtTransformerOutletMWel = range.map { i in
  min(
    PV_AC_Cap,
    iff(
      e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap > Ref_Inv_eff_approx_handover,
      e_PV_Total_ScaledMWel_DC[i]
        * ((e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 3 * HL_C3
          + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 2 * HL_C2
          + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 1 * HL_C1 + HL_C0),
      iff(
        e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap > 0,
        e_PV_Total_ScaledMWel_DC[i]
          * ((e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 7 * LL_C7 + (
            e_PV_Total_ScaledMWel_DC[i] / V_DC_Cap
          ) ^ 6 * LL_C6 + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 5 * LL_C5
            + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 4 * LL_C4
            + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 3 * LL_C3
            + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 2 * LL_C2
            + (e_PV_Total_ScaledMWel_DC[i] / PV_DC_Cap) ^ 1 * LL_C1 + LL_C0),
        referencePVMVPowerAtTransformerOutletMWel[i] / Ref_PV_AC_capacity * PV_AC_Cap
      )
    )
  )
}

let auxElecForPBStby_CSPSFAndPVPlantMWel = range.map { i in
  iff(
    q_solar_beforeDumping_MWth[i] > 0,
    q_solar_beforeDumping_MWth[i] * CSP_var_aux_nom_perc,
    CSP_nonsolar_aux_cons
  ) + max(0, -pVMVPowerAtTransformerOutletMWel[i]) + PB_stby_aux_cons
}

let availablePVPowerMWel = range.map { i in
  max(0, pVMVPowerAtTransformerOutletMWel[i] - auxElecForPBStby_CSPSFAndPVPlantMWel[i])
}

let notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel = range.map { i in
  max(0, auxElecForPBStby_CSPSFAndPVPlantMWel[i] - availablePVPowerMWel[i])
}

let minHarmoniousNetElecCons = range.map { i in
  iff(
    min(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
      availablePVPowerMWel[i] + Grid_max_import,
      min(
        q_solar_beforeDumping_MWth[i] + El_boiler_cap * El_boiler_efficiency,
        (availablePVPowerMWel[i] + Grid_max_import)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
            0,
            (Overall_harmonious_max_var_heat_cons - q_solar_beforeDumping_MWth[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Overall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    ) < Overall_harmonious_min_var_cons + Overallfix_aux_cons,
    0,
    Overall_harmonious_min_var_cons + Overall_fix_aux_cons
  )
}

let optimizedMinHarmoniousNetElecCons = range.map { i in
  iff(
    AND(
      minHarmoniousNetElecCons[i] > 0,
      minHarmoniousNetElecCons[i - 1] = 0,
      COUNTiff(minHarmoniousNetElecCons[i], minHarmoniousNetElecCons[i + 1], "0") > 0
    ),
    0,
    minHarmoniousNetElecCons[i]
  )
}

let minHarmoniousNetHeatCons = range.map { i in
  optimizedMinHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    * Overall_harmonious_max_var_heat_cons
}

let photovoltaicDay = range.map { i in
  iff(
    AND(optimizedMinHarmoniousNetElecCons[i - 1] <= 0, optimizedMinHarmoniousNetElecCons[i] > 0),
    photovoltaicDay[i - 1] + 1,
    photovoltaicDay[i - 1]
  )
}

let remainingPVAfterMinHarmonious = range.map { i in
  max(
    0,
    availablePVPowerMWel[i] - notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
      - optimizedMinHarmoniousNetElecCons[i]
      - max(0, (minHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency)
  )
}

let remainingCSPHeatAfterMinHarmonious = range.map { i in
  max(0, q_solar_beforeDumping_MWth[i] - minHarmoniousNetHeatCons[i])
}

let gridImportNecessaryForMinHarmonious = range.map { i in
  max(
    0,
    -(availablePVPowerMWel[i] - optimizedMinHarmoniousNetElecCons[i]
      - max(0, (minHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency))
      + notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
  )
}

let remainingGridImportCapacityAfterMinHarmonious = range.map { i in
  Grid_max_import - gridImportNecessaryForMinHarmonious[i]
}

let remainingElBoilerCapAfterMinHarmoniousHeatCons = range.map { i in
  max(
    0,
    min(
      El_boiler_cap
        - max(
          0,
          (minHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency
        ),
      remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i]
    )
  )
}

let remainingMethSyntCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
      (111 + remainingGridImportCapacityAfterMinHarmonious[i])
        / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
    )
  )
}

let remainingCCUCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * CCU_harmonious_min_perc),
      (remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i])
        / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
          0,
          CU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
          / (max(0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * CCU_CO2_nom_prod
  )
}

let remainingEYCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * EY_harmonious_min_perc),
      (remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i])
        / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
          0,
          Y_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
          / (max(0, EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * EY_H2_nom_prod
  )
}

let maxBESSChargingAfterMinHarmoniousCons = range.map { i in
  min(BESS_charging_max_cons, remainingPVAfterMinHarmonious[i])
}

let maxHarmoniousNetElecCons = range.map { i in
  iff(
    min(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
      availablePVPowerMWel[i] + Grid_max_import,
      min(
        q_solar_beforeDumping_MWth[i] + El_boiler_cap * El_boiler_efficiency,
        (availablePVPowerMWel[i] + Grid_max_import)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
            0,
            (Overall_harmonious_max_var_heat_cons - q_solar_beforeDumping_MWth[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Overall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    ) < Overall_harmonious_min_var_cons + Overallfix_aux_cons,
    0,
    min(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
      availablePVPowerMWel[i] + Grid_max_import,
      min(
        q_solar_beforeDumping_MWth[i] + El_boiler_cap * El_boiler_efficiency,
        (availablePVPowerMWel[i] + Grid_max_import)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
            (Overall_harmonious_max_var_heat_cons - q_solar_beforeDumping_MWth[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Overall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    )
  )
}

let optimizedMaxHarmoniousNetElecCons = range.map { i in
  iff(
    AND(
      maxHarmoniousNetElecCons[i] > 0,
      maxHarmoniousNetElecCons[i - 1] = 0,
      COUNTiff(maxHarmoniousNetElecCons[i], maxHarmoniousNetElecCons[i + 1], "0") > 0
    ),
    0,
    maxHarmoniousNetElecCons[i]
  )
}

let maxHarmoniousNetHeatCons = range.map { i in
  optimizedMaxHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    * Overall_harmonious_max_var_heat_cons
}

let remainingPVAfterMaxHarmonious = range.map { i in
  max(
    0,
    availablePVPowerMWel[i] - notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
      - optimizedMaxHarmoniousNetElecCons[i]
      - max(0, (maxHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency)
  )
}

let remainingCSPHeatAfterMaxHarmonious = range.map { i in
  max(0, q_solar_beforeDumping_MWth[i] - maxHarmoniousNetHeatCons[i])
}

let gridImportNecessaryForMaxHarmonious = range.map { i in
  max(
    0,
    -(availablePVPowerMWel[i] - optimizedMaxHarmoniousNetElecCons[i]
      - max(0, (maxHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency))
      + notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
  )
}

let remainingGridImportCapacityAfterMaxHarmonious = range.map { i in
  Grid_max_import - gridImportNecessaryForMaxHarmonious[i]
}

let remainingElBoilerCapAfterMaxHarmoniousHeatCons = range.map { i in
  max(
    0,
    min(
      El_boiler_cap
        - max(
          0,
          (maxHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency
        ),
      remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i]
    )
  )
}

let remainingMethSyntCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
      (referencePVPlantPowerAtInverterInletMWel_DC[i]
        + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
    )
  )
}

let remainingCCUCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * CCU_harmonious_min_perc) * CCU_CO2_nom_prod,
      (remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (CCU_var_aux_nom_cons + CCU_fix_aux_cons
          + max(0, CU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])),
      IFERROR(
        remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
          / (max(0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * CCU_CO2_nom_prod
  )
}

let remainingEYCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * EY_harmonious_min_perc) * EY_H2_nom_prod,
      (remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (EY_var_gross_nom_cons + EY_fix_aux_elec
          + max(0, Y_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])),
      IFERROR(
        remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
          / (max(0, EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * EY_H2_nom_prod
  )
}

let maxBESSChargingAfterMaxHarmoniousCons = range.map { i in
  min(BESS_charging_max_cons, remainingPVAfterMaxHarmonious[i])
}

let auxElecForCSPSFAndPVPlantMWel = range.map { i in
  iff(
    q_solar_beforeDumping_MWth[i] > 0,
    q_solar_beforeDumping_MWth[i] * CSP_var_aux_nom_perc,
    CSP_nonsolar_aux_cons
  ) + max(0, -pVMVPowerAtTransformerOutletMWel[i])
}

let availablePVPowerMWel = range.map { i in
  max(0, pVMVPowerAtTransformerOutletMWel[i] - auxElecForCSPSFAndPVPlantMWel[i])
}

let notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel = range.map { i in
  max(0, auxElecForCSPSFAndPVPlantMWel[i] - availablePVPowerMWel[i])
}

let maxPossiblePVElecToTES = range.map { i in
  max(
    0,
    min(
      availablePVPowerMWel[i] * (1 - (1 + 1 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage),
      Heater_cap,
      q_solar_beforeDumping_MWth[i] * Ratio_CSP_vs_Heater / Heater_efficiency
    )
  )
}

let remainingPVAfterTES = range.map { i in
  max(
    0,
    availablePVPowerMWel[i] - maxPossiblePVElecToTES[i]
      * (1 + (1 + 1 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage)
  )
}

let maximumTESEnergyPerPVDay = range.map { i in
  min(
    TES_Thermal_capacity,
    SUMiff(D5: D8763, "=" & dayOfYear[i], AR5: AR8763) * Heater_efficiency
      * (1 + 1 / Ratio_CSP_vs_Heater)
  )
}

let surplusEnergyDueToTESSizeLimit = range.map { i in
  max(
    0,
    SUMiff(D5: D8763, "=" & dayOfYear[i], AR5: AR8763) * Heater_efficiency
      * (1 + 1 / Ratio_CSP_vs_Heater) - TES_Thermal_capacity
  )
}

let peripherialHourHeaterOp = range.map { i in
  iff(
    OR(
      AND(
        surplusEnergyDueToTESSizeLimit[i] > 0,
        maxPossiblePVElecToTES[i] < Heater_cap,
        maxPossiblePVElecToTES[i] > 0,
        maxPossiblePVElecToTES[i - 1] = 0
      ),
      AND(
        surplusEnergyDueToTESSizeLimit[i] > 0,
        maxPossiblePVElecToTES[i] < Heater_cap,
        maxPossiblePVElecToTES[i + 1] = 0,
        maxPossiblePVElecToTES[i] > 0
      )
    ),
    maxPossiblePVElecToTES[i],
    0
  )
}

let surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours = range.map { i in
  max(
    0,
    surplusEnergyDueToTESSizeLimit[i] - SUMiff(D5: D8763, "=" & dayOfYear[i], AV5: AV8763)
      * Heater_efficiency * (1 + 1 / Ratio_CSP_vs_Heater)
  )
}

let correctedMaxPossiblePVElecToTES = range.map { i in
  iff(
    surplusEnergyDueToTESSizeLimit[i]
      > surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i],
    iff(
      surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i] > 0,
      maxPossiblePVElecToTES[i] - peripherialHourHeaterOp[i],
      maxPossiblePVElecToTES[i]
        - iff(
          peripherialHourHeaterOp[i] = 0,
          0,
          surplusEnergyDueToTESSizeLimit[i] / Heater_efficiency / (1 + 1 / Ratio_CSP_vs_Heater)
            / SUMIFS(AV5: AV8763, AV5: AV8763, ">0", D5: D8763, "=" & dayOfYear[i])
            * peripherialHourHeaterOp[i]
        )
    ),
    maxPossiblePVElecToTES[i]
  )
}

let hoursOfAboveAverageHeaterOp = range.map { i in
  COUNTIFS(
    AX5: AX8763,
    ">=" & AVERAGEIFS(AX5: AX8763, AX5: AX8763, ">0", D5: D8763, "=" & dayOfYear[i]),
    D5: D8763,
    "=" & dayOfYear[i]
  )
}

let correctedMaxPossiblePVElecToTES = range.map { i in
  iff(
    hoursOfAboveAverageHeaterOp[i] > 0,
    iff(
      AND(
        correctedMaxPossiblePVElecToTES[i]
          >= AVERAGEIFS(AX5: AX8763, AX5: AX8763, ">0", D5: D8763, "=" & dayOfYear[i]),
        surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i] > 0
      ),
      correctedMaxPossiblePVElecToTES[i]
        - surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i]
        / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_efficiency / hoursOfAboveAverageHeaterOp[i],
      correctedMaxPossiblePVElecToTES[i]
    ),
    0
  )
}

let maxPossibleCSPHeatToTES = range.map { i in
  min(
    q_solar_beforeDumping_MWth[i],
    correctedMaxPossiblePVElecToTES[i] * Heater_efficiency / Ratio_CSP_vs_Heater
  )
}

let notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel = range.map { i in
  notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
    + (correctedMaxPossiblePVElecToTES[i] * Heater_efficiency + maxPossibleCSPHeatToTES[i])
    * TES_Aux_elec_percentage
}

let remainingPVAfterTESChrg = range.map { i in
  max(
    0,
    availablePVPowerMWel[i] - correctedMaxPossiblePVElecToTES[i]
      - notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
  )
}

let remainingCSPHeatAfterTES = range.map { i in
  q_solar_beforeDumping_MWth[i] - maxPossibleCSPHeatToTES[i]
}

let minHarmoniousNetElecCons = range.map { i in
  iff(
    min(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      remainingPVAfterTESChrg[i] + Grid_max_import - PB_stby_aux_cons,
      min(
        remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_efficiency,
        (hour[i] + Grid_max_import - PB_stby_aux_cons)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
            0,
            (Overall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Oerall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
    ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
    0,
    verall_harmonious_min_var_cons + Overall_fix_aux_cons
  )
}

let optimizedMinHarmoniousNetElecCons = range.map { i in
  iff(
    AND(
      minHarmoniousNetElecCons[i] > 0,
      minHarmoniousNetElecCons[i - 1] = 0,
      COUNTiff(minHarmoniousNetElecCons[i], minHarmoniousNetElecCons[i + 1], "0") > 0
    ),
    0,
    minHarmoniousNetElecCons[i]
  )
}

let minHarmoniousNetHeatCons = range.map { i in
  optimizedMinHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    * Overall_harmonious_max_var_heat_cons
}

let photovoltaicDay = range.map { i in
  iff(
    AND(optimizedMinHarmoniousNetElecCons[i - 1] <= 0, optimizedMinHarmoniousNetElecCons[i] > 0),
    photovoltaicDay[i - 1] + 1,
    photovoltaicDay[i - 1]
  )
}

let notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel = range.map { i in
  notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
    + iff(optimizedMinHarmoniousNetElecCons[i] > 0, PB_stby_aux_cons, 0)
}

let remainingPVAfterMinHarmonious = range.map { i in
  max(
    0,
    remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
      - max(0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency)
      - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
  )
}

let remainingCSPHeatAfterMinHarmonious = range.map { i in
  max(0, remainingCSPHeatAfterTES[i] - minHarmoniousNetHeatCons[i])
}

let notCoveredAuxElecMWel = range.map { i in
  max(
    0,
    min(
      notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i],
      -(remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
        - max(0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency)
        - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i])
    )
  )
}

let gridImportNecessaryForMinHarmonious = range.map { i in
  max(
    0,
    -(remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
      - max(0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency))
      + notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
  )
}

let remainingGridImportCapacityAfterMinHarmonious = range.map { i in
  Grid_max_import - gridImportNecessaryForMinHarmonious[i]
}

let remainingElBoilerCapAfterMinHarmoniousHeatCons = range.map { i in
  max(
    0,
    min(
      El_boiler_cap
        - max(
          0,
          (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterMinHarmonious[i])
            / El_boiler_efficiency
        ),
      remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i]
    )
  )
}

let remainingMethSyntCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
      (q_solar_beforeDumping_MWth[i] + remainingGridImportCapacityAfterMinHarmonious[i])
        / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
    )
  )
}

let remainingCCUCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * CCU_harmonious_min_perc),
      (remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i])
        / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
          0,
          CU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
          / (max(0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * CCU_CO2_nom_prod
  )
}

let remainingEYCapAfterMinHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMinHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * EY_harmonious_min_perc),
      (remainingPVAfterMinHarmonious[i] + remainingGridImportCapacityAfterMinHarmonious[i])
        / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
          0,
          Y_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
          / (max(0, EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * EY_H2_nom_prod
  )
}

let maxBESSChargingAfterMinHarmoniousCons = range.map { i in
  min(BESS_charging_max_cons, remainingPVAfterMinHarmonious[i])
}

let maxHarmoniousNetElecCons = range.map { i in
  iff(
    min(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      remainingPVAfterTESChrg[i] + Grid_max_import - PB_stby_aux_cons,
      min(
        remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_efficiency,
        (hour[i] + Grid_max_import - PB_stby_aux_cons)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
            0,
            (Overall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Oerall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
    ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
    0,
    min(
      verall_harmonious_max_var_cons + Overall_fix_aux_cons,
      remainingPVAfterTESChrg[i] + Grid_max_import - PB_stby_aux_cons,
      min(
        remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_efficiency,
        (hour[i] + Grid_max_import - PB_stby_aux_cons)
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
            0,
            (verall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
          ) / El_boiler_efficiency) * Overall_harmonious_max_var_heat_cons
      ) / Overall_harmonious_max_var_heat_cons
        * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    )
  )
}

let optimizedMaxHarmoniousNetElecCons = range.map { i in
  iff(
    AND(
      maxHarmoniousNetElecCons[i] > 0,
      maxHarmoniousNetElecCons[i - 1] = 0,
      COUNTiff(maxHarmoniousNetElecCons[i], maxHarmoniousNetElecCons[i + 1], "0") > 0
    ),
    0,
    maxHarmoniousNetElecCons[i]
  )
}

let maxHarmoniousNetHeatCons = range.map { i in
  optimizedMaxHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
    * Overall_harmonious_max_var_heat_cons
}

let notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel = range.map { i in
  notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
    + iff(optimizedMaxHarmoniousNetElecCons[i] > 0, PB_stby_aux_cons, 0)
}

let remainingPVAfterMaxHarmonious = range.map { i in
  max(
    0,
    remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
      - max(0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency)
      - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
  )
}

let remainingCSPHeatAfterMaxHarmonious = range.map { i in
  max(0, remainingCSPHeatAfterTES[i] - maxHarmoniousNetHeatCons[i])
}

let notCoveredAuxElecMWel = range.map { i in
  max(
    0,
    min(
      notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i],
      -(remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
        - max(0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency)
        - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i])
    )
  )
}

let gridImportNecessaryForMaxHarmonious = range.map { i in
  max(
    0,
    -(remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
      - max(0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_efficiency))
      + notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
  )
}

let remainingGridImportCapacityAfterMaxHarmonious = range.map { i in
  Grid_max_import - gridImportNecessaryForMaxHarmonious[i]
}

let remainingElBoilerCapAfterMaxHarmoniousHeatCons = range.map { i in
  max(
    0,
    min(
      El_boiler_cap
        - max(
          0,
          (maxHarmoniousNetHeatCons[i] - q_solar_beforeDumping_MWth[i]) / El_boiler_efficiency
        ),
      remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i]
    )
  )
}

let remainingMethSyntCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
      (remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
        + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
    )
  )
}

let remainingCCUCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * CCU_harmonious_min_perc),
      (remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
          0,
          CU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
          / (max(0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * CCU_CO2_nom_prod
  )
}

let remainingEYCapAfterMaxHarmoniousCons = range.map { i in
  max(
    0,
    min(
      (1 - optimizedMaxHarmoniousNetElecCons[i]
        / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
        * EY_harmonious_min_perc),
      (remainingPVAfterMaxHarmonious[i] + remainingGridImportCapacityAfterMaxHarmonious[i])
        / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
          0,
          Y_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i]
        ) / El_boiler_efficiency),
      IFERROR(
        remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
          / (max(0, EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
            / El_boiler_efficiency),
        1
      )
    ) * EY_H2_nom_prod
  )
}

let maxBESSChargingAfterMaxHarmoniousCons = range.map { i in
  min(BESS_charging_max_cons, remainingPVAfterMaxHarmonious[i])
}
