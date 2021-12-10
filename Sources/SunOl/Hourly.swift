import Utilities

func foo2(
  _ Q_Sol_MW_thLoop: [Double],
  _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double],
  _ Reference_PV_MV_power_at_transformer_outlet: [Double]
) {
  var PV = SunOl.PV()
  let PVMVPowerAtTransformerOutletMWel = [Double]()

  let BESS_charging_max_cons: Double = 0.0  // B$86
  let CCU_CO2_nom_prod: Double = 0.0  // B$147
  let CCU_fix_aux_cons: Double = 0.0  // B$149
  let CCU_harmonious_min_perc: Double = 0.0  // L$8
  let CCU_var_aux_nom_cons: Double = 0.0  // B$150
  let CCU_var_heat_nom_cons: Double = 0.0  // B$151
  let CSP_Loop_Nr: Double = 0.0  // B$70
  let CSP_nonsolar_aux_cons: Double = 0.0  // B$73
  let CSP_var_aux_nom_perc: Double = 0.0  // G$75
  let EY_H2_nom_prod: Double = 0.0  // B$99
  let EY_fix_aux_elec: Double = 0.0  // B$95
  let EY_harmonious_min_perc: Double = 0.0  // L$9
  let EY_var_gross_nom_cons: Double = 0.0  // B$93
  let EY_var_heat_nom_cons: Double = 0.0  // B$97
  let El_boiler_cap: Double = 0.0  // B$134
  let grid_max_import: Double = 0.0  // B$138
  let Heater_cap: Double = 0.0  // B$81
  let MethDist_harmonious_min_perc: Double = 0.0  // L$6
  let MethSynt_RawMeth_nom_prod: Double = 0.0  // B$108
  let MethSynt_fix_aux_cons: Double = 0.0  // B$114
  let MethSynt_harmonious_min_perc: Double = 0.0  // L$7
  let MethSynt_var_aux_nom_cons: Double = 0.0  // B$115
  let Overall_fix_aux_cons: Double = 0.0  // L$3
  let Overall_harmonious_max_var_cons: Double = 0.0  // L$20
  let Overall_harmonious_max_var_heat_cons: Double = 0.0  // L$21
  let Overall_harmonious_min_var_cons: Double = 0.0  // L$11

  let PB_stby_aux_cons: Double = 0.0  // B$32

  let PV_AC_Cap: Double = 0.0  // B$53

  let TES_Aux_elec_percentage: Double = 0.0  // G$81

  let TES_Thermal_capacity: Double = 0.0  // B$77

  let Heater_eff = 0.99
  let El_boiler_eff = 0.99
  let Ratio_CSP_vs_Heater = 1.315007

  let range = 0..<8760
  let zeroes = Array(repeating: 0.0, count: range.count)

  let indices = Reference_PV_MV_power_at_transformer_outlet.indices
  let Q_solar_before_dumping = Q_Sol_MW_thLoop.map { $0 * CSP_Loop_Nr }
  let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
  let Inverter_power_fraction = Reference_PV_MV_power_at_transformer_outlet.map {
    max(0, $0 / maximum)
  }
  let Inverter_eff = indices.map {
    return iff(
      Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
      max(Reference_PV_MV_power_at_transformer_outlet[$0], 0)
        / Reference_PV_plant_power_at_inverter_inlet_DC[$0],
      0
    )
  }
  let inverter = zip(Inverter_power_fraction, Inverter_eff).filter { $0.0 > 0 && $0.0 < 1 }
    .sorted(by: { $0.0 < $1.0 })
  let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
  let eff1 = chunks.map { bin in bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count) }
  let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1)
    .map { PV.AC_Cap * $0.0 / $0.1 / PV.DC_Cap }
  let LL = Polynomial.fit(x: Array(eff2[...20]), y: Array(eff1[...20]), degree: 6)
  let ML = Polynomial.fit(x: Array(eff2[8...22]), y: Array(eff1[8...22]), degree: 3)
  let HL = Polynomial.fit(x: Array(eff2[20...]), y: Array(eff1[20...]), degree: 4)

  let E_PV_total_Scaled_DC = Reference_PV_plant_power_at_inverter_inlet_DC.map {
    $0 * PV.DC_Cap / PV.Ref_DC_cap
  }

  let PV_MV_power_at_transformer_outlet: [Double] = indices.map {
    let load = E_PV_total_Scaled_DC[$0] / PV.DC_Cap
    let value: Double
    if load > 0.2 {
      value = E_PV_total_Scaled_DC[$0] * HL(load)
    } else if load > 0.1 {
      value = E_PV_total_Scaled_DC[$0] * ML(load)
    } else if load > 0 {
      value = E_PV_total_Scaled_DC[$0] * LL(load)
    } else {
      value = Reference_PV_MV_power_at_transformer_outlet[$0] / PV.Ref_AC_cap * PV.AC_Cap
    }
    return min(PV_AC_Cap, value)
  }

  let auxElecForPBStby_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    iff(
      Q_solar_before_dumping[i] > 0,
      Q_solar_before_dumping[i] * CSP_var_aux_nom_perc,
      CSP_nonsolar_aux_cons
    ) + max(0, -PV_MV_power_at_transformer_outlet[i]) + PB_stby_aux_cons
  }

  let availablePVPowerMWel: [Double] = range.map { i -> Double in
    max(0, PV_MV_power_at_transformer_outlet[i] - auxElecForPBStby_CSPSFAndPVPlantMWel[i])
  }

  let pvDayRanges = Array(
    availablePVPowerMWel.indices.chunked(by:) {
      !(availablePVPowerMWel[$0] == 0.0 && availablePVPowerMWel[$1] > 0.0)
    }
  )

  let dayIndex = pvDayRanges.indices.flatMap { i in Array(repeating: i, count: pvDayRanges[i].count)
  }

  let pvDays = pvDayRanges.map { r in Array(availablePVPowerMWel[r]) }
  let pvDayStats: [(Double, Double, Double)] = pvDays.map { day in
    let n = day.reduce(into: 0) { counter, value in if value > 0 { counter += 1 } }
    return (sum(day[0...]), Double(n), Double(day.count) - Double(n))
  }

  let notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    max(0, auxElecForPBStby_CSPSFAndPVPlantMWel[i] - availablePVPowerMWel[i])
  }

  let minHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        availablePVPowerMWel[i] + grid_max_import,
        min(
          Q_solar_before_dumping[i] + El_boiler_cap * El_boiler_eff,
          (availablePVPowerMWel[i] + grid_max_import)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
              0,
              (Overall_harmonious_max_var_heat_cons - Q_solar_before_dumping[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
      0,
      Overall_harmonious_min_var_cons + Overall_fix_aux_cons
    )
  }

  let optimizedMinHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      and(
        minHarmoniousNetElecCons[i] > 0,
        minHarmoniousNetElecCons[i - 1] == 0// countiff(minHarmoniousNetElecCons[i], minHarmoniousNetElecCons[i + 1], "0") > 0
      ),
      0,
      minHarmoniousNetElecCons[i]
    )
  }

  let minHarmoniousNetHeatCons: [Double] = range.map { i -> Double in
    optimizedMinHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  let remainingPVAfterMinHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      availablePVPowerMWel[i] - notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
        - optimizedMinHarmoniousNetElecCons[i]
        - max(0.0, (minHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff)
    )
  }

  let remainingCSPHeatAfterMinHarmonious: [Double] = range.map { i -> Double in
    max(0.0, Q_solar_before_dumping[i] - minHarmoniousNetHeatCons[i])
  }

  let gridImportNecessaryForMinHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      -(availablePVPowerMWel[i] - optimizedMinHarmoniousNetElecCons[i]
        - max(0.0, (minHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff))
        + notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
    )
  }

  let remaininggridImportCapacityAfterMinHarmonious: [Double] = range.map { i -> Double in
    grid_max_import - gridImportNecessaryForMinHarmonious[i]
  }

  let remainingElBoilerCapAfterMinHarmoniousHeatCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        El_boiler_cap
          - max(0.0, (minHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff),
        remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i]
      )
    )
  }

  let remainingMethSyntCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
        (111 + remaininggridImportCapacityAfterMinHarmonious[i])
          / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
      )
    )
  }

  let remainingCCUCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * CCU_harmonious_min_perc),
        (remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
            0.0,
            CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
            / (max(0.0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * CCU_CO2_nom_prod
    )
  }

  let remainingEYCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * EY_harmonious_min_perc),
        (remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
            0.0,
            EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
            / (max(0.0, EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * EY_H2_nom_prod
    )
  }

  let maxBESSChargingAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    min(BESS_charging_max_cons, remainingPVAfterMinHarmonious[i])
  }

  let maxHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        availablePVPowerMWel[i] + grid_max_import,
        min(
          Q_solar_before_dumping[i] + El_boiler_cap * El_boiler_eff,
          (availablePVPowerMWel[i] + grid_max_import)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
              0.0,
              (Overall_harmonious_max_var_heat_cons - Q_solar_before_dumping[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
      0.0,
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        availablePVPowerMWel[i] + grid_max_import,
        min(
          Q_solar_before_dumping[i] + El_boiler_cap * El_boiler_eff,
          (availablePVPowerMWel[i] + grid_max_import)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
              0.0,
              (Overall_harmonious_max_var_heat_cons - Q_solar_before_dumping[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      )
    )
  }

  let optimizedMaxHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      and(
        maxHarmoniousNetElecCons[i] > 0.0,
        maxHarmoniousNetElecCons[i - 1] == 0.0// countiff(maxHarmoniousNetElecCons[i], maxHarmoniousNetElecCons[i + 1], "0") > 0
      ),
      0.0,
      maxHarmoniousNetElecCons[i]
    )
  }

  let maxHarmoniousNetHeatCons: [Double] = range.map { i -> Double in
    optimizedMaxHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  let remainingPVAfterMaxHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      availablePVPowerMWel[i] - notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
        - optimizedMaxHarmoniousNetElecCons[i]
        - max(0.0, (maxHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff)
    )
  }

  let remainingCSPHeatAfterMaxHarmonious: [Double] = range.map { i -> Double in
    max(0.0, Q_solar_before_dumping[i] - maxHarmoniousNetHeatCons[i])
  }

  let gridImportNecessaryForMaxHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      -(availablePVPowerMWel[i] - optimizedMaxHarmoniousNetElecCons[i]
        - max(0.0, (maxHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff))
        + notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
    )
  }

  let remaininggridImportCapacityAfterMaxHarmonious: [Double] = range.map { i -> Double in
    grid_max_import - gridImportNecessaryForMaxHarmonious[i]
  }

  let remainingElBoilerCapAfterMaxHarmoniousHeatCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        El_boiler_cap
          - max(0.0, (maxHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff),
        remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i]
      )
    )
  }

  let remainingMethSyntCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
        (Reference_PV_plant_power_at_inverter_inlet_DC[i]
          + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
      )
    )
  }

  let remainingCCUCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * CCU_harmonious_min_perc) * CCU_CO2_nom_prod,
        (remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons
            + max(0.0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])),
        ifFinite(
          remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
            / (max(0.0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * CCU_CO2_nom_prod
    )
  }

  let remainingEYCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * EY_harmonious_min_perc) * EY_H2_nom_prod,
        (remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec
            + max(0.0, EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])),
        ifFinite(
          remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
            / (max(0.0, EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * EY_H2_nom_prod
    )
  }

  let maxBESSChargingAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    min(BESS_charging_max_cons, remainingPVAfterMaxHarmonious[i])
  }

  let auxElecForCSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    iff(
      Q_solar_before_dumping[i] > 0.0,
      Q_solar_before_dumping[i] * CSP_var_aux_nom_perc,
      CSP_nonsolar_aux_cons
    ) + max(0.0, -PVMVPowerAtTransformerOutletMWel[i])
  }

  let _availablePVPowerMWel: [Double] = range.map { i -> Double in
    max(0.0, PVMVPowerAtTransformerOutletMWel[i] - auxElecForCSPSFAndPVPlantMWel[i])
  }

  let _notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    max(0.0, auxElecForCSPSFAndPVPlantMWel[i] - availablePVPowerMWel[i])
  }

  let maxPossiblePVElecToTES: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        availablePVPowerMWel[i]
          * (1.0 - (1.0 + 1.0 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage),
        Heater_cap,
        Q_solar_before_dumping[i] * Ratio_CSP_vs_Heater / Heater_eff
      )
    )
  }

  let daysMaxPossiblePVElecToTES = pvDayRanges.map { r in Array(maxPossiblePVElecToTES[r]) }

  let remainingPVAfterTES: [Double] = range.map { i -> Double in
    max(
      0.0,
      availablePVPowerMWel[i] - maxPossiblePVElecToTES[i]
        * (1.0 + (1.0 + 1.0 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage)
    )
  }

  let maximumTESEnergyPerPVDay: [Double] = range.map { i -> Double in
    min(
      TES_Thermal_capacity,
      sum(daysMaxPossiblePVElecToTES[dayIndex[i]]) * Heater_eff * (1.0 + 1.0 / Ratio_CSP_vs_Heater)
    )
  }

  let surplusEnergyDueToTESSizeLimit: [Double] = range.map { i -> Double in
    max(
      0.0,
      sum(daysMaxPossiblePVElecToTES[dayIndex[i]]) * Heater_eff * (1.0 + 1.0 / Ratio_CSP_vs_Heater)
        - TES_Thermal_capacity
    )
  }

  let peripherialHourHeaterOp: [Double] = range.map { i -> Double in
    iff(
      or(
        and(
          surplusEnergyDueToTESSizeLimit[i] > 0.0,
          maxPossiblePVElecToTES[i] < Heater_cap,
          maxPossiblePVElecToTES[i] > 0.0,
          maxPossiblePVElecToTES[i - 1] == 0
        ),
        and(
          surplusEnergyDueToTESSizeLimit[i] > 0.0,
          maxPossiblePVElecToTES[i] < Heater_cap,
          maxPossiblePVElecToTES[i + 1] == 0.0,
          maxPossiblePVElecToTES[i] > 0.0
        )
      ),
      maxPossiblePVElecToTES[i],
      0
    )
  }

  let surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours: [Double] = range.map {
    i -> Double in
    max(
      0.0,
      surplusEnergyDueToTESSizeLimit[i] - sum(daysMaxPossiblePVElecToTES[dayIndex[i]]) * Heater_eff
        * (1.0 + 1.0 / Ratio_CSP_vs_Heater)
    )
  }

  let daysPeripherialHourHeaterOp = pvDayRanges.map { r in Array(peripherialHourHeaterOp[r]) }

  let correctedMaxPossiblePVElecToTES: [Double] = range.map { i -> Double in
    iff(
      surplusEnergyDueToTESSizeLimit[i]
        > surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i],
      iff(
        surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i] > 0.0,
        maxPossiblePVElecToTES[i] - peripherialHourHeaterOp[i],
        maxPossiblePVElecToTES[i]
          - iff(
            peripherialHourHeaterOp[i] == 0.0,
            0.0,
            surplusEnergyDueToTESSizeLimit[i] / Heater_eff / (1.0 + 1.0 / Ratio_CSP_vs_Heater)
              / sum(daysPeripherialHourHeaterOp[dayIndex[i]]) * peripherialHourHeaterOp[i]
          )
      ),
      maxPossiblePVElecToTES[i]
    )
  }

  let hoursOfAboveAverageHeaterOp: [Double] = range.map { i -> Double in 0.0// COUNTIFS(
    //   AX5: AX8763,
    //   ">=" & average(correctedMaxPossiblePVElecToTES[dayIndex[i]]),
    //   D5: D8763,
    //   "=" & dayOfYear[i]
    // )
  }

  let _correctedMaxPossiblePVElecToTES: [Double] = range.map { i -> Double in
    iff(
      hoursOfAboveAverageHeaterOp[i] > 0.0,
      iff(
        and(
          // correctedMaxPossiblePVElecToTES[i]
          // >= AVERAGEIFS(AX5: AX8763, AX5: AX8763, ">0", D5: D8763, "=" & dayOfYear[i]),
          surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i] > 0
        ),
        correctedMaxPossiblePVElecToTES[i]
          - surplusEnergyDueToTESSizeLimitAfterRemovalOfPeripherialHours[i]
          / (1.0 + 1.0 / Ratio_CSP_vs_Heater) / Heater_eff / hoursOfAboveAverageHeaterOp[i],
        correctedMaxPossiblePVElecToTES[i]
      ),
      0
    )
  }

  let maxPossibleCSPHeatToTES: [Double] = range.map { i -> Double in
    min(
      Q_solar_before_dumping[i],
      correctedMaxPossiblePVElecToTES[i] * Heater_eff / Ratio_CSP_vs_Heater
    )
  }

  let notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    notCoveredAuxElecForPBStby_CSPSFAndPVPlantMWel[i]
      + (correctedMaxPossiblePVElecToTES[i] * Heater_eff + maxPossibleCSPHeatToTES[i])
      * TES_Aux_elec_percentage
  }

  let remainingPVAfterTESChrg: [Double] = range.map { i -> Double in
    max(
      0.0,
      availablePVPowerMWel[i] - correctedMaxPossiblePVElecToTES[i]
        - notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
    )
  }

  let remainingCSPHeatAfterTES: [Double] = range.map { i -> Double in
    Q_solar_before_dumping[i] - maxPossibleCSPHeatToTES[i]
  }

  let _minHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
        remainingPVAfterTESChrg[i] + grid_max_import - PB_stby_aux_cons,
        min(
          remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_eff,
          (Double(i.remainderReportingOverflow(dividingBy: 24).partialValue) + grid_max_import
            - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
              0.0,
              (Overall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      0.0,
      Overall_harmonious_min_var_cons + Overall_fix_aux_cons
    )
  }

  let _optimizedMinHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      and(
        minHarmoniousNetElecCons[i] > 0.0,
        minHarmoniousNetElecCons[i - 1] == 0.0// countiff(minHarmoniousNetElecCons[i], minHarmoniousNetElecCons[i + 1], "0") > 0.0
      ),
      0.0,
      minHarmoniousNetElecCons[i]
    )
  }

  let _minHarmoniousNetHeatCons: [Double] = range.map { i -> Double in
    optimizedMinHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  let notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
      + iff(optimizedMinHarmoniousNetElecCons[i] > 0.0, PB_stby_aux_cons, 0)
  }

  let _remainingPVAfterMinHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
        - max(0.0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff)
        - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
    )
  }

  let _remainingCSPHeatAfterMinHarmonious: [Double] = range.map { i -> Double in
    max(0.0, remainingCSPHeatAfterTES[i] - minHarmoniousNetHeatCons[i])
  }

  let notCoveredAuxElecMWel: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i],
        -(remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
          - max(0.0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff)
          - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i])
      )
    )
  }

  let _gridImportNecessaryForMinHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      -(remainingPVAfterTESChrg[i] - optimizedMinHarmoniousNetElecCons[i]
        - max(0.0, (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff))
        + notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
    )
  }

  let _remaininggridImportCapacityAfterMinHarmonious: [Double] = range.map { i -> Double in
    grid_max_import - gridImportNecessaryForMinHarmonious[i]
  }

  let _remainingElBoilerCapAfterMinHarmoniousHeatCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        El_boiler_cap
          - max(
            0.0,
            (minHarmoniousNetHeatCons[i] - remainingCSPHeatAfterMinHarmonious[i]) / El_boiler_eff
          ),
        remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i]
      )
    )
  }

  let _remainingMethSyntCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
        (Q_solar_before_dumping[i] + remaininggridImportCapacityAfterMinHarmonious[i])
          / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
      )
    )
  }

  let _remainingCCUCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * CCU_harmonious_min_perc),
        (remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
            0.0,
            CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
            / (max(0.0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * CCU_CO2_nom_prod
    )
  }

  let _remainingEYCapAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMinHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * EY_harmonious_min_perc),
        (remainingPVAfterMinHarmonious[i] + remaininggridImportCapacityAfterMinHarmonious[i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
            0.0,
            EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
            / (max(0.0, EY_var_heat_nom_cons - remainingCSPHeatAfterMinHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * EY_H2_nom_prod
    )
  }

  let _maxBESSChargingAfterMinHarmoniousCons: [Double] = range.map { i -> Double in
    min(BESS_charging_max_cons, remainingPVAfterMinHarmonious[i])
  }

  let _maxHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
        remainingPVAfterTESChrg[i] + grid_max_import - PB_stby_aux_cons,
        min(
          remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_eff,
          (Double(i.remainderReportingOverflow(dividingBy: 24).partialValue) + grid_max_import
            - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
              0,
              (Overall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      0,
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        remainingPVAfterTESChrg[i] + grid_max_import - PB_stby_aux_cons,
        min(
          remainingCSPHeatAfterTES[i] + El_boiler_cap * El_boiler_eff,
          (Double(i.remainderReportingOverflow(dividingBy: 24).partialValue) + grid_max_import
            - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
              0.0,
              (Overall_harmonious_max_var_heat_cons - remainingCSPHeatAfterTES[i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      )
    )
  }

  let _optimizedMaxHarmoniousNetElecCons: [Double] = range.map { i -> Double in
    iff(
      and(
        maxHarmoniousNetElecCons[i] > 0.0,
        maxHarmoniousNetElecCons[i - 1] == 0.0// countiff(maxHarmoniousNetElecCons[i], maxHarmoniousNetElecCons[i + 1], "0") > 0.0
      ),
      0,
      maxHarmoniousNetElecCons[i]
    )
  }

  let _maxHarmoniousNetHeatCons: [Double] = range.map { i -> Double in
    optimizedMaxHarmoniousNetElecCons[i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  let _notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel: [Double] = range.map { i -> Double in
    notCoveredAuxElecForPBStby_TESChrg_CSPSFAndPVPlantMWel[i]
      + iff(optimizedMaxHarmoniousNetElecCons[i] > 0, PB_stby_aux_cons, 0.0)
  }

  let _remainingPVAfterMaxHarmonious: [Double] = range.map { i -> Double in
    max(
      0,
      remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
        - max(0.0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff)
        - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
    )
  }

  let _remainingCSPHeatAfterMaxHarmonious: [Double] = range.map { i -> Double in
    max(0.0, remainingCSPHeatAfterTES[i] - maxHarmoniousNetHeatCons[i])
  }

  let _notCoveredAuxElecMWel: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i],
        -(remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
          - max(0.0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff)
          - notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i])
      )
    )
  }

  let _gridImportNecessaryForMaxHarmonious: [Double] = range.map { i -> Double in
    max(
      0.0,
      -(remainingPVAfterTESChrg[i] - optimizedMaxHarmoniousNetElecCons[i]
        - max(0.0, (maxHarmoniousNetHeatCons[i] - remainingCSPHeatAfterTES[i]) / El_boiler_eff))
        + notCoveredAuxElecPBStby_ForTESChrg_CSPSFAndPVPlantMWel[i]
    )
  }

  let _remaininggridImportCapacityAfterMaxHarmonious: [Double] = range.map { i -> Double in
    grid_max_import - gridImportNecessaryForMaxHarmonious[i]
  }

  let _remainingElBoilerCapAfterMaxHarmoniousHeatCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        El_boiler_cap
          - max(0.0, (maxHarmoniousNetHeatCons[i] - Q_solar_before_dumping[i]) / El_boiler_eff),
        remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i]
      )
    )
  }

  let _remainingMethSyntCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
        (remainingElBoilerCapAfterMinHarmoniousHeatCons[i]
          + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
      )
    )
  }

  let _remainingCCUCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * CCU_harmonious_min_perc),
        (remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(
            0.0,
            CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
            / (max(0.0, CCU_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
              / El_boiler_eff),
          1.0
        )
      ) * CCU_CO2_nom_prod
    )
  }

  let _remainingEYCapAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    max(
      0.0,
      min(
        (1.0 - optimizedMaxHarmoniousNetElecCons[i]
          / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc
          * EY_harmonious_min_perc),
        (remainingPVAfterMaxHarmonious[i] + remaininggridImportCapacityAfterMaxHarmonious[i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(
            0.0,
            EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i]
          ) / El_boiler_eff),
        ifFinite(
          remainingElBoilerCapAfterMaxHarmoniousHeatCons[i]
            / (max(0.0, EY_var_heat_nom_cons - remainingCSPHeatAfterMaxHarmonious[i])
              / El_boiler_eff),
          1
        )
      ) * EY_H2_nom_prod
    )
  }

  let _maxBESSChargingAfterMaxHarmoniousCons: [Double] = range.map { i -> Double in
    min(BESS_charging_max_cons, remainingPVAfterMaxHarmonious[i])
  }
}
