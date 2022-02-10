extension TunOl {
  func hourly() {
    let j = 0
    var hourly0 = [Double]()
    let daysD = [[Int]]()
    /// Day of year
    let hourlyD = 0
    // IF(C6=0,D5+1,D5)
    // for i in 0..<8760 {
    //   hourly0[hourlyD + i] = iff(
    //     hourly0[C + i].isZero, hourly0[hourlyD + i - 1] + 1, hourly0[hourlyD + i - 1])
    // }

    /// Inverter power fraction -
    let hourlyH = 8760
    // MAX(0,G6/MAX(G5:G8763))
    // for i in 0..<8760 {
      // hourly0[hourlyH + i] = max(0, hourly0[hourlyG + i] / max(hourly0[(hourlyG + i)...].prefix(8760)))
    // }

    /// Inverter efficiency -
    let hourlyI = 17520
    // IFERROR(IF(G6<MAX(G5:G8763),MAX(G6,0)/F6,0),0)
    // for i in 0..<8760 {
    //   hourly0[hourlyI + i] = ifFinite(
    //     iff(
    //       hourly_[G + i] < max(hourly0[(G + i)...].prefix()),
    //       max(hourly_[G + i], 0) / hourly0[F + i], 0), 0)
    // }

    /// Q_solar (before dumping) MWth
    let hourlyJ = 26280
    // E6*CSP_loop_nr_ud
    // for i in 0..<8760 { hourly0[hourlyJ + i] = hourly0[E + i] * CSP_loop_nr_ud }

    /// E_PV_Total _Scaled MWel_DC
    let hourlyK = 35040
    // F6*PV_DC_cap_ud/PV_Ref_DC_cap
    // for i in 0..<8760 { hourly0[hourlyK + i] = hourly0[F + i] * PV_DC_cap_ud / PV_Ref_DC_cap }

    /// PV MV net power at transformer outlet MWel
    let hourlyL = 43800
    // MIN(PV_AC_cap_ud,IF(K6/PV_DC_cap_ud>Inv_eff_Ref_approx_handover,K6*POLY(K6/PV_DC_cap_ud,HL_Coeff),IF(K6/PV_DC_cap_ud>0,K6*POLY(K6/PV_DC_cap_ud,LL_Coeff),0)))
    for i in 0..<8760 {
      hourly0[hourlyL + i] = min(
        PV_AC_cap_ud,
        iff(
          hourly0[hourlyK + i] / PV_DC_cap_ud > Inv_eff_Ref_approx_handover,
          hourly0[hourlyK + i] * POLY(hourly0[hourlyK + i] / PV_DC_cap_ud, HL_Coeff),
          iff(
            hourly0[hourlyK + i] / PV_DC_cap_ud > 0,
            hourly0[hourlyK + i] * POLY(hourly0[hourlyK + i] / PV_DC_cap_ud, LL_Coeff), 0)))
    }

    /// PV aux consumption at transformer level MWel
    let hourlyM = 52560
    // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
    // for i in 0..<8760 {
    //   hourly0[hourlyM + i] = max(0, -hourly0[G + i] / PV_Ref_AC_cap * PV_AC_cap_ud)
    // }

    /// Aux elec for PB stby, CSP SF and PV Plant MWel
    let hourlyO = 61320
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+PB_stby_aux_cons
    for i in 0..<8760 {
      hourly0[hourlyO + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i] + PB_stby_aux_cons
    }

    /// Available PV power MWel
    let hourlyP = 70080
    // MAX(0,L6-O6)
    for i in 0..<8760 {
      hourly0[hourlyP + i] = max(0, hourly0[hourlyL + i] - hourly0[hourlyO + i])
    }

    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let hourlyQ = 78840
    // MAX(0,O6-P6)
    for i in 0..<8760 {
      hourly0[hourlyQ + i] = max(0, hourly0[hourlyO + i] - hourly0[hourlyP + i])
    }

    /// Min harmonious net elec cons
    let hourlyR = 87600
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly0[hourlyR + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0,
                (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                  - hourly0[hourlyJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyS = 96360
    // IF(AND(R6>0,R5=0,OR(R6=0,R7=0)),0,R6)
    for i in 0..<8760 {
      hourly0[hourlyS + i] = iff(
        and(
          hourly0[hourlyR + i] > 0, hourly0[hourlyR + i - 1].isZero,
          or(hourly0[hourlyR + i].isZero, hourly0[hourlyR + i].isZero)), 0, hourly0[hourlyR + i])
    }

    /// Min harmonious net heat cons
    let hourlyT = 105120
    // S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly0[hourlyT + i] =
        hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyU = 113880
    // IF(AND(S5<=0,S6>0),U5+1,U5)
    for i in 0..<8760 {
      hourly0[hourlyU + i] = iff(
        and(hourly0[hourlyS + i - 1] <= 0, hourly0[hourlyS + i] > 0), hourly0[hourlyU + i - 1] + 1,
        hourly0[hourlyU + i - 1])
    }

    /// Remaining PV after min harmonious
    let hourlyV = 122640
    // MAX(0,P6-Q6-S6-MAX(0,(T6-J6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly0[hourlyV + i] = max(
        0,
        hourly0[hourlyP + i] - hourly0[hourlyQ + i] - hourly0[hourlyS + i]
          - max(0, (hourly0[hourlyT + i] - hourly0[hourlyJ + i]) / El_boiler_eff))
    }

    /// Remaining CSP heat after min harmonious
    let hourlyW = 131400
    // MAX(0,J6-T6)
    for i in 0..<8760 {
      hourly0[hourlyW + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyT + i])
    }

    /// Grid import necessary for min harmonious
    let hourlyX = 140160
    // MAX(0,-(P6-Q6-S6-MAX(0,(T6-J6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly0[hourlyX + i] = max(
        0,
        -(hourly0[hourlyP + i] - hourly0[hourlyQ + i] - hourly0[hourlyS + i]
          - max(0, (hourly0[hourlyT + i] - hourly0[hourlyJ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harmonious
    let hourlyY = 148920
    // Grid_import_max_ud-X6
    for i in 0..<8760 { hourly0[hourlyY + i] = Grid_import_max_ud - hourly0[hourlyX + i] }

    /// El to el boiler after min harm heat cons
    let hourlyZ = 157680
    // MAX(0,(T6-J6)/El_boiler_eff)
    for i in 0..<8760 {
      hourly0[hourlyZ + i] = max(0, (hourly0[hourlyT + i] - hourly0[hourlyJ + i]) / El_boiler_eff)
    }

    /// Remaining el boiler cap after min harm heat cons
    let hourlyAA = 166440
    // MAX(0,El_boiler_cap_ud-Z6)
    for i in 0..<8760 { hourly0[hourlyAA + i] = max(0, El_boiler_cap_ud - hourly0[hourlyZ + i]) }

    /// Remaining MethSynt cap after min harm cons
    let hourlyAB = 175200
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAB + i] =
        max(
          0,
          1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harm cons
    let hourlyAC = 183960
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAC + i] =
        max(
          0,
          1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harm cons
    let hourlyAD = 192720
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly0[hourlyAD + i] =
        max(
          0,
          1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harm cons
    let hourlyAE = 201480
    // MIN(BESS_chrg_max_cons,V6)
    for i in 0..<8760 { hourly0[hourlyAE + i] = min(BESS_chrg_max_cons, hourly0[hourlyV + i]) }

    /// Max grid export after min harm cons
    let hourlyAF = 210240
    // MIN(Grid_export_max_ud,V6)
    for i in 0..<8760 { hourly0[hourlyAF + i] = min(Grid_export_max_ud, hourly0[hourlyV + i]) }

    /// Max harm net elec cons
    let hourlyAG = 219000
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly0[hourlyAG + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0,
                (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                  - hourly0[hourlyJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0,
                (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                  - hourly0[hourlyJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harm net elec cons
    let hourlyAH = 227760
    // IF(AND(AG6>0,AG5=0,OR(AG6=0,AG7=0)),0,AG6)
    for i in 0..<8760 {
      hourly0[hourlyAH + i] = iff(
        and(
          hourly0[hourlyAG + i] > 0, hourly0[hourlyAG + i - 1].isZero,
          or(hourly0[hourlyAG + i].isZero, hourly0[hourlyAG + i].isZero)), 0, hourly0[hourlyAG + i])
    }

    /// max harm net heat cons
    let hourlyAI = 236520
    // AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly0[hourlyAI + i] =
        hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining PV after max harm
    let hourlyAJ = 245280
    // MAX(0,P6-Q6-AH6-MAX(0,(AI6-J6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly0[hourlyAJ + i] = max(
        0,
        hourly0[hourlyP + i] - hourly0[hourlyQ + i] - hourly0[hourlyAH + i]
          - max(0, (hourly0[hourlyAI + i] - hourly0[hourlyJ + i]) / El_boiler_eff))
    }

    /// Remaining CSP heat after max harm
    let hourlyAK = 254040
    // MAX(0,J6-AI6)
    for i in 0..<8760 {
      hourly0[hourlyAK + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyAI + i])
    }

    /// Grid import necessary for max harm
    let hourlyAL = 262800
    // MAX(0,-(P6-Q6-AH6-MAX(0,(AI6-J6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly0[hourlyAL + i] = max(
        0,
        -(hourly0[hourlyP + i] - hourly0[hourlyQ + i] - hourly0[hourlyAH + i]
          - max(0, (hourly0[hourlyAI + i] - hourly0[hourlyJ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyAM = 271560
    // Grid_import_max_ud-AL6
    for i in 0..<8760 { hourly0[hourlyAM + i] = Grid_import_max_ud - hourly0[hourlyAL + i] }

    /// El to el boiler after max harm heat cons
    let hourlyAN = 280320
    // MAX(0,(AI6-J6)/El_boiler_eff)
    for i in 0..<8760 {
      hourly0[hourlyAN + i] = max(
        0, (hourly0[hourlyAI + i] - hourly0[hourlyJ + i]) / El_boiler_eff)
    }

    /// Remaining el boiler cap after max harm heat cons
    let hourlyAO = 289080
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 0..<8760 { hourly0[hourlyAO + i] = max(0, El_boiler_cap_ud - hourly0[hourlyAN + i]) }

    /// Remaining MethSynt cap after max harm cons
    let hourlyAP = 297840
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAP + i] =
        max(
          0,
          1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harm cons
    let hourlyAQ = 306600
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAQ + i] =
        max(
          0,
          1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harm cons
    let hourlyAR = 315360
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly0[hourlyAR + i] =
        max(
          0,
          1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harm cons
    let hourlyAS = 324120
    // MIN(BESS_chrg_max_cons,AJ6)
    for i in 0..<8760 { hourly0[hourlyAS + i] = min(BESS_chrg_max_cons, hourly0[hourlyAJ + i]) }

    /// Max grid export after max harm cons
    let hourlyAT = 332880
    // MIN(Grid_export_max_ud,AJ6)
    for i in 0..<8760 { hourly0[hourlyAT + i] = min(Grid_export_max_ud, hourly0[hourlyAJ + i]) }

    var hourly1 = [Double]()

    /// Aux elec for CSP SF and PV Plant MWel
    let hourlyAV = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 0..<8760 {
      hourly1[hourlyAV + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
    }

    /// Available PV power MWel
    let hourlyAW = 8760
    // MAX(0,L6-AV6)
    for i in 0..<8760 {
      hourly1[hourlyAW + i] = max(0, hourly0[hourlyL + i] - hourly1[hourlyAV + i])
    }

    /// Not covered aux elec for CSP SF and PV Plant MWel
    let hourlyAX = 17520
    // MAX(0,AV6-AW6)
    for i in 0..<8760 {
      hourly1[hourlyAX + i] = max(0, hourly1[hourlyAV + i] - hourly1[hourlyAW + i])
    }

    /// Max possible PV elec to TES (considering TES chrg aux)
    let hourlyAY = 26280
    // MAX(0,MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc),Heater_cap_ud,J6*Ratio_CSP_vs_Heater/Heater_eff))
    for i in 0..<8760 {
      hourly1[hourlyAY + i] = max(
        0,
        min(
          hourly1[hourlyAW + i]
            * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc), Heater_cap_ud,
          hourly0[hourlyJ + i] * Ratio_CSP_vs_Heater / Heater_eff))
    }

    let AYsum = hourly1.sum(hours: daysD, condition: hourlyAY)

    /// Maximum TES energy per PV day
    let hourlyAZ = 35040
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly1[hourlyAZ + i] = min(
        TES_thermal_cap, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// Surplus energy due to TES size limit
    let hourlyBA = 43800
    // MAX(0,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap)
    for i in 0..<8760 {
      hourly1[hourlyBA + i] = max(
        0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap)
    }

    /// Peripherial PV hour PV to heater
    let hourlyBB = 52560
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly1[hourlyBB + i] = iff(
        or(
          and(hourly1[hourlyBA + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly1[hourlyBA + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    let BBsum = hourly1.sum(hours: daysD, condition: hourlyBB)

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyBC = 61320
    // MAX(0,BA6-SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly1[hourlyBC + i] = max(
        0, hourly1[hourlyBA + i] - BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyBD = 70080
    // IF(AZ6=0,0,AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6))
    for i in 0..<8760 {
      hourly1[hourlyBD + i] = iff(
        hourly1[hourlyAZ + i].isZero, 0,
        hourly1[hourlyAY + i]
          - iff(
            hourly1[hourlyBA + i].isZero, 0,
            (hourly1[hourlyBA + i] - hourly1[hourlyBC + i])
              / (BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly1[hourlyBB + i]))
    }
    let BDcountNonZero = hourly1.count(hours: daysD, range: hourlyBD, predicate: {$0>0})
    let BDsum = hourly1.sum(hours: daysD, condition: hourlyBD)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyBE = 78840
    // IF(OR(BD6=0,BC6=0),0,MAX((AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(D5:D8763,"="D6,BD4:BD8762,">0")),(J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(D5:D8763,"="D6,BD5:BD8763,">0")))/SUMIF(D5:D8763,"="D6,BD5:BD8763)*BD6)
    for i in 0..<8760 {
      hourly1[hourlyBE + i] = iff(
        or(hourly1[hourlyBD + i].isZero, hourly1[hourlyBC + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly1[hourlyBD + i])
            / (hourly1[hourlyBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / BDcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly1[hourlyBD + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly1[hourlyBC + i] / (1 + Ratio_CSP_vs_Heater) / BDcountNonZero[i])) / BDsum[i]
          * hourly1[hourlyBD + i])
    }
    let BEsum = hourly1.sum(hours: daysD, condition: hourlyBE)
    /// corrected max possible PV elec to TES
    let hourlyBF = 87600
    // IF(AZ6=0,0,BD6-IF(BC6=0,0,BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(D5:D8763,"="D6,BE5:BE8763)*BE6))
    for i in 0..<8760 {
      hourly1[hourlyBF + i] = iff(
        hourly1[hourlyAZ + i].isZero, 0,
        hourly1[hourlyBD + i]
          - iff(
            hourly1[hourlyBC + i].isZero, 0,
            hourly1[hourlyBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i]
              * hourly1[hourlyBE + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyBG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly1[hourlyBG + i] = min(
        hourly0[hourlyJ + i], hourly1[hourlyBF + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourlyBH = 105120
    // AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc
    for i in 0..<8760 {
      hourly1[hourlyBH + i] =
        hourly1[hourlyAX + i] + (hourly1[hourlyBF + i] * Heater_eff + hourly1[hourlyBG + i])
        * TES_aux_cons_perc
    }

    /// Remaining PV after TES chrg
    let hourlyBI = 113880
    // MAX(0,AW6-BF6-BH6)
    for i in 0..<8760 {
      hourly1[hourlyBI + i] = max(
        0, hourly1[hourlyAW + i] - hourly1[hourlyBF + i] - hourly1[hourlyBH + i])
    }

    /// Remaining CSP heat after TES
    let hourlyBJ = 122640
    // J6-BG6
    for i in 0..<8760 { hourly1[hourlyBJ + i] = hourly0[hourlyJ + i] - hourly1[hourlyBG + i] }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourlyBK = 131400
    // MAX(0,-(AW6-BF6-BH6))
    for i in 0..<8760 {
      hourly1[hourlyBK + i] = max(
        0, -(hourly1[hourlyAW + i] - hourly1[hourlyBF + i] - hourly1[hourlyBH + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyBL = 140160
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons,MIN(BJ6+El_boiler_cap_ud*El_boiler_eff,(BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons)/(Overall_harmonious_var_max_cons+Overall_fix_cons+PB_stby_aux_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-BJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly1[hourlyBL + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly1[hourlyBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - PB_stby_aux_cons,
          min(
            hourly1[hourlyBJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly1[hourlyBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - PB_stby_aux_cons)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + PB_stby_aux_cons + max(
                0,
                (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                  - hourly1[hourlyBJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyBM = 148920
    // IF(AND(BL6>0,BL5=0,OR(BL6=0,BL7=0)),0,BL6)
    for i in 0..<8760 {
      hourly1[hourlyBM + i] = iff(
        and(
          hourly1[hourlyBL + i] > 0, hourly1[hourlyBL + i - 1].isZero,
          or(hourly1[hourlyBL + i].isZero, hourly1[hourlyBL + i].isZero)), 0, hourly1[hourlyBL + i])
    }

    /// Min harmonious net heat cons
    let hourlyBN = 157680
    // BM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly1[hourlyBN + i] =
        hourly1[hourlyBM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyBO = 166440
    // IF(AND(BM5<=0,BM6>0),BO5+1,IF(AND(BI5<=0,BI6>0,COUNTIF(BM6:BM15,"=0")=10,COUNTIF(BI6:BI15,">0")>5),BO5+1,BO5))
    for i in 0..<8760 {
      hourly1[hourlyBO + i] = iff(
        and(hourly1[hourlyBM + i - 1] <= 0, hourly1[hourlyBM + i] > 0),
        hourly1[hourlyBO + i - 1] + 1,
        iff(
          and(
            hourly1[hourlyBI + i - 1] <= 0, hourly1[hourlyBI + i] > 0,
            countiff(hourly1[(hourlyBM + i)...].prefix(8760), { $0.isZero }) == 10,
            countiff(hourly1[(hourlyBI + i)...].prefix(8760), { !$0.isZero }) > 5),
          hourly1[hourlyBO + i - 1] + 1, hourly1[hourlyBO + i - 1]))
    }
    let daysBO: [[Int]] = hourly1[hourlyBO..<(hourlyBO + 8760)].indices.chunked(by: {hourly1[$0] == hourly1[$1]}).map { $0.map { $0 } }
    /// Remaining PV after min harmonious
    let hourlyBP = 175200
    // MAX(0,BI6-BK6-BM6-MAX(0,(BN6-BJ6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly1[hourlyBP + i] = max(
        0,
        hourly1[hourlyBI + i] - hourly1[hourlyBK + i] - hourly1[hourlyBM + i]
          - max(0, (hourly1[hourlyBN + i] - hourly1[hourlyBJ + i]) / El_boiler_eff))
    }

    /// Remaining CSP heat after min harmonious
    let hourlyBQ = 183960
    // MAX(0,BJ6-BN6)
    for i in 0..<8760 {
      hourly1[hourlyBQ + i] = max(0, hourly1[hourlyBJ + i] - hourly1[hourlyBN + i])
    }

    /// Grid import necessary for min harm
    let hourlyBR = 192720
    // MAX(0,-(BI6-BK6-BM6-MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly1[hourlyBR + i] = max(
        0,
        -(hourly1[hourlyBI + i] - hourly1[hourlyBK + i] - hourly1[hourlyBM + i]
          - max(0, (hourly1[hourlyBN + i] - hourly1[hourlyBJ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyBS = 201480
    // Grid_import_max_ud-BR6
    for i in 0..<8760 { hourly1[hourlyBS + i] = Grid_import_max_ud - hourly1[hourlyBR + i] }

    var hourly2 = [Double]()

    /// Min net elec demand to power block
    let hourlyBU = 0
    // IF(BM6>0,0,IF(A_overall_var_min_cons+A_overall_fix_stby_cons+BK6+IF(BM7=0,0,A_overall_stup_cons)+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly2[hourlyBU + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          overall_var_min_cons[j] + overall_fix_stby_cons[j] + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]) + max(
              0,
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          overall_var_min_cons[j] + overall_fix_stby_cons[j]
            + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j])))
    }

    /// Optimized min net elec demand to power block
    let hourlyBV = 8760
    // IF(AND(BU7>0,BU6=0,BU5>0),BU5,BU6)
    for i in 0..<8760 {
      hourly2[hourlyBV + i] = iff(
        and(hourly2[hourlyBU + i] > 0, hourly2[hourlyBU + i].isZero, hourly2[hourlyBU + i - 1] > 0),
        hourly2[hourlyBU + i - 1], hourly2[hourlyBU + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyBW = 17520
    // IF(BV6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV6+BK6-BP6))-PB_net_min_cap))+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(BV6=0,BV7>0),MAX(0,IF(COUNTIF(BV1:BV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly2[hourlyBW + i] = iff(
        hourly2[hourlyBV + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - hourly1[hourlyBQ + i])
            * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly2[hourlyBV + i].isZero, hourly2[hourlyBV + i] > 0),
            max(
              0,
              iff(
                countiff(hourly2[(hourlyBV + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourlyBX = 26280
    // IF(BV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-BP6)))
    for i in 0..<8760 {
      hourly2[hourlyBX + i] = iff(
        hourly2[hourlyBV + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly2[hourlyBV + i] + hourly2[hourlyBW + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding min PB gross elec output
    let hourlyBY = 35040
    // IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly2[hourlyBY + i] = iff(
        hourly2[hourlyBX + i].isZero, 0,
        hourly2[hourlyBX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly2[hourlyBX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyBZ = 43800
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly2[hourlyBZ + i] = iff(
        and(hourly2[hourlyBY + i].isZero, hourly2[hourlyBY + i] > 0),
        iff(
          countiff(hourly2[(hourlyBY + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }
    let BZsum = hourly2.sum(hours: daysBO, condition: hourlyBZ)
    /// Min gross heat cons for ST
    let hourlyCA = 52560
    // IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly2[hourlyCA + i] = iff(
        hourly2[hourlyBY + i].isZero, 0,
        hourly2[hourlyBY + i] / PB_nom_gross_eff
          / POLY(hourly2[hourlyBY + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let CAsum = hourly2.sum(hours: daysBO, condition: hourlyCA)
    /// Min gross heat cons for extraction
    let hourlyCB = 61320
    // IF(CA6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(BX6-BW6+BP6)/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,BX6-BV6-BW6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly2[hourlyCB + i] = iff(
        hourly2[hourlyCA + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j]),
              (hourly2[hourlyBX + i] - hourly2[hourlyBW + i] + hourly1[hourlyBP + i])
                / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]))
                * (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])))
              - hourly1[hourlyBQ + i] - max(
                0, hourly2[hourlyBX + i] - hourly2[hourlyBV + i] - hourly2[hourlyBW + i])
              * El_boiler_eff)))
    }
    let CBsum = hourly2.sum(hours: daysBO, condition: hourlyCB)
    /// TES energy needed to fulfil op case
    let hourlyCC = 70080
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763),0,
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763))
    for i in 0..<8760 {
      hourly2[hourlyCC + i] = iff(
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < BZsum[i] + CAsum[i]
          + CBsum[i], 0, BZsum[i] + CAsum[i] + CBsum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyCD = 78840
    // IF(CC6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6))
    for i in 0..<8760 {
      hourly2[hourlyCD + i] = iff(
        hourly2[hourlyCC + i].isZero, 0,
        max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly2[hourlyCC + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyCE = 87600
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly2[hourlyCE + i] = iff(
        or(
          and(hourly2[hourlyCD + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly2[hourlyCD + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }
    let CEsum = hourly2.sum(hours: daysBO, condition: hourlyCE)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyCF = 96360
    // MAX(0,CD6-SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly2[hourlyCF + i] = max(
        0, hourly2[hourlyCD + i] - CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyCG = 105120
    // IF(CD6=0,0,AY6-(CD6-CF6)/(SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6)
    for i in 0..<8760 {
      hourly2[hourlyCG + i] = iff(
        hourly2[hourlyCD + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly2[hourlyCD + i] - hourly2[hourlyCF + i])
          / (CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly2[hourlyCE + i])
    }
    let CGsum = hourly2.sum(hours: daysBO, condition: hourlyCG)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyCH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX((AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")),(J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")))/SUMIF(BO5:BO8763,"="BO6,CG5:CG8763)*CG6)
    // for i in 0..<8760 {
    //   hourly2[hourlyCH + i] = iff(
    //     or(hourly2[hourlyCG + i].isZero, hourly2[hourlyCF + i].isZero), 0,
    //     max(
    //       (hourly1[hourlyAW + i] - hourly2[hourlyCG + i])
    //         / (hourly2[hourlyCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
    //           / CG_BOcountNonZero[i]),
    //       (hourly0[hourlyJ + i] - hourly2[hourlyCG + i] * Heater_eff / Ratio_CSP_vs_Heater)
    //         / (hourly2[hourlyCF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i])) / CGsum[i]
    //       * hourly2[hourlyCG + i])
    // }
    let CHsum = hourly2.sum(hours: daysBO, condition: hourlyCH)
    /// corrected max possible PV elec to TES
    let hourlyCI = 122640
    // IF(CC6=0,0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,CH5:CH8763)*CH6))
    for i in 0..<8760 {
      hourly2[hourlyCI + i] = iff(
        hourly2[hourlyCC + i].isZero, 0,
        hourly2[hourlyCG + i]
          - iff(
            hourly2[hourlyCF + i].isZero, 0,
            hourly2[hourlyCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i]
              * hourly2[hourlyCH + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyCJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly2[hourlyCJ + i] = min(
        hourly0[hourlyJ + i], hourly2[hourlyCI + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyCK = 140160
    // MAX(0,L6-CI6)
    for i in 0..<8760 {
      hourly2[hourlyCK + i] = max(0, hourly0[hourlyL + i] - hourly2[hourlyCI + i])
    }

    /// Available heat from CSP after TES
    let hourlyCL = 148920
    // MAX(0,J6-CJ6)
    for i in 0..<8760 {
      hourly2[hourlyCL + i] = max(0, hourly0[hourlyJ + i] - hourly2[hourlyCJ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyCM = 157680
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(BY6=0,AND(BY6>0,CC6=0)),PB_stby_aux_cons+BZ6*TES_aux_cons_perc,(BZ6+CA6+CB6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly2[hourlyCM + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly2[hourlyCI + i] * Heater_eff + hourly2[hourlyCJ + i]) * TES_aux_cons_perc
        + iff(
          or(hourly2[hourlyBY + i].isZero, and(hourly2[hourlyBY + i] > 0, hourly2[hourlyCC + i].isZero)),
          PB_stby_aux_cons + hourly2[hourlyBZ + i] * TES_aux_cons_perc,
          (hourly2[hourlyBZ + i] + hourly2[hourlyCA + i] + hourly2[hourlyCB + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyCN = 166440
    // MAX(0,-(L6+IF(CC6>0,BX6,0)-CI6-CM6))
    for i in 0..<8760 {
      hourly2[hourlyCN + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0)
          - hourly2[hourlyCI + i] - hourly2[hourlyCM + i]))
    }

    var hourly3 = [Double]()

    /// Min harmonious net elec cons not considering grid import
    let hourlyCP = 0
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly3[hourlyCP + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]),
          min(
            hourly2[hourlyCL + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly2[hourlyCL + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyCQ = 8760
    // IF(AND(CP6>0,CP5=0,OR(CP6=0,CP7=0)),0,CP6)
    for i in 0..<8760 {
      hourly3[hourlyCQ + i] = iff(
        and(
          hourly3[hourlyCP + i] > 0, hourly3[hourlyCP + i - 1].isZero,
          or(hourly3[hourlyCP + i].isZero, hourly3[hourlyCP + i].isZero)), 0, hourly3[hourlyCP + i])
    }

    /// Min harmonious net heat cons
    let hourlyCR = 17520
    // CQ6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly3[hourlyCR + i] =
        hourly3[hourlyCQ + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyCS = 26280
    // IF(AND(CQ5<=0,CQ6>0),CS5+1,IF(AND(CK6>0,BO6<>BO5,SUM(CQ6:CQ8)=0),CS5+1,CS5))
    for i in 0..<8760 {
      hourly3[hourlyCS + i] = iff(
        and(hourly3[hourlyCQ + i - 1] <= 0, hourly3[hourlyCQ + i] > 0),
        hourly3[hourlyCS + i - 1] + 1,
        iff(
          and(
            hourly2[hourlyCK + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            sum(hourly2[(hourlyCQ + i)...].prefix(3)) == 0), hourly3[hourlyCS + i - 1] + 1,
          hourly3[hourlyCS + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyCT = 35040
    // IF(OR(CQ6>0,CC6=0),0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly3[hourlyCT + i] = iff(
        or(hourly3[hourlyCQ + i] > 0, hourly2[hourlyCC + i].isZero), 0,
        min(
          (hourly2[hourlyBX + i] + hourly2[hourlyCK + i]
            + (hourly2[hourlyCL + i] + hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hourly3[hourlyCR + i].isZero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])),
          overall_var_min_cons[j] + overall_fix_stby_cons[j]
            + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let hourlyCU = 43800
    // IF(CT6=0,0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)),A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly3[hourlyCU + i] = iff(
        hourly3[hourlyCT + i].isZero, 0,
        min(
          (hourly2[hourlyBX + i] + hourly2[hourlyCK + i]
            + (hourly2[hourlyCL + i] + hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hourly3[hourlyCR + i].isZero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
              + iff(hourly3[hourlyCR + i].isZero, 0, overall_heat_stup_cons[j])),
          overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(hourly3[hourlyCR + i].isZero, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourlyCV = 52560
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly3[hourlyCV + i] = max(
        0,
        iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly3[hourlyCQ + i]
          - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly3[hourlyCR + i] + hourly3[hourlyCU + i]
              - iff(
                hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly2[hourlyCL + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyCW = 61320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 0..<8760 {
      hourly3[hourlyCW + i] = max(
        0,
        hourly2[hourlyCL + i]
          + iff(
            hourly2[hourlyCC + i].isZero, 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
          - hourly3[hourlyCR + i] - hourly3[hourlyCU + i])
    }

    /// Grid import necessary for min harm
    let hourlyCX = 70080
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly3[hourlyCX + i] = max(
        0,
        -(iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly3[hourlyCQ + i]
          - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly3[hourlyCR + i] + hourly3[hourlyCU + i]
              - iff(
                hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly2[hourlyCL + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyCY = 78840
    // Grid_import_max_ud-CX6
    for i in 0..<8760 { hourly3[hourlyCY + i] = Grid_import_max_ud - hourly3[hourlyCX + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyCZ = 87600
    // MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly3[hourlyCZ + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly3[hourlyCR + i] + hourly3[hourlyCU + i] - hourly2[hourlyCL + i]
            - iff(
              hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyDA = 96360
    // MAX(0,El_boiler_cap_ud-CZ6)
    for i in 0..<8760 { hourly3[hourlyDA + i] = max(0, El_boiler_cap_ud - hourly3[hourlyCZ + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyDB = 105120
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly3[hourlyDB + i] =
        max(
          0,
          1
            - ((max(0, hourly3[hourlyCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyDC = 113880
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly3[hourlyDC + i] =
        max(
          0,
          1
            - ((max(0, hourly3[hourlyCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyDD = 122640
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly3[hourlyDD + i] =
        max(
          0,
          1
            - ((max(0, hourly3[hourlyCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyDE = 131400
    // MIN(BESS_chrg_max_cons,CV6)
    for i in 0..<8760 { hourly3[hourlyDE + i] = min(BESS_chrg_max_cons, hourly3[hourlyCV + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyDF = 140160
    // MIN(Grid_export_max_ud,CV6)
    for i in 0..<8760 { hourly3[hourlyDF + i] = min(Grid_export_max_ud, hourly3[hourlyCV + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyDG = 148920
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly3[hourlyDG + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]),
          min(
            hourly2[hourlyCL + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly2[hourlyCL + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]),
          min(
            hourly2[hourlyCL + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly2[hourlyCL + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyDH = 157680
    // IF(AND(DG6>0,DG5=0,OR(DG6=0,DG7=0)),0,DG6)
    for i in 0..<8760 {
      hourly3[hourlyDH + i] = iff(
        and(
          hourly3[hourlyDG + i] > 0, hourly3[hourlyDG + i - 1].isZero,
          or(hourly3[hourlyDG + i].isZero, hourly3[hourlyDG + i].isZero)), 0, hourly3[hourlyDG + i])
    }

    /// max harmonious net heat cons
    let hourlyDI = 166440
    // DH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly3[hourlyDI + i] =
        hourly0[hourlyDH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyDJ = 175200
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly3[hourlyDJ + i] = max(
        0,
        iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly0[hourlyDH + i]
          - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly0[hourlyDI + i] + hourly3[hourlyCU + i]
              - iff(
                hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly2[hourlyCL + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyDK = 183960
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 0..<8760 {
      hourly3[hourlyDK + i] = max(
        0,
        hourly2[hourlyCL + i]
          + iff(
            hourly2[hourlyCC + i].isZero, 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
          - hourly0[hourlyDI + i] - hourly3[hourlyCU + i])
    }

    /// Grid import necessary for max harm
    let hourlyDL = 192720
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly3[hourlyDL + i] = max(
        0,
        -(iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly0[hourlyDH + i]
          - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly0[hourlyDI + i] + hourly3[hourlyCU + i]
              - iff(
                hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly2[hourlyCL + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyDM = 201480
    // Grid_import_max_ud-DL6
    for i in 0..<8760 { hourly3[hourlyDM + i] = Grid_import_max_ud - hourly0[hourlyDL + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyDN = 210240
    // MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly3[hourlyDN + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyDI + i] + hourly3[hourlyCU + i] - hourly2[hourlyCL + i]
            - iff(
              hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyDO = 219000
    // MAX(0,El_boiler_cap_ud-DN6)
    for i in 0..<8760 { hourly3[hourlyDO + i] = max(0, El_boiler_cap_ud - hourly0[hourlyDN + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyDP = 227760
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly3[hourlyDP + i] =
        max(
          0,
          1
            - ((max(0, hourly0[hourlyDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyDQ = 236520
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly3[hourlyDQ + i] =
        max(
          0,
          1
            - ((max(0, hourly0[hourlyDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyDR = 245280
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly3[hourlyDR + i] =
        max(
          0,
          1
            - ((max(0, hourly0[hourlyDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyDS = 254040
    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 0..<8760 { hourly3[hourlyDS + i] = min(BESS_chrg_max_cons, hourly3[hourlyDJ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyDT = 262800
    // MIN(Grid_export_max_ud,DJ6)
    for i in 0..<8760 { hourly3[hourlyDT + i] = min(Grid_export_max_ud, hourly3[hourlyDJ + i]) }

    var hourly4 = [Double]()

    /// Maximum night op perc considering tank sizes
    let hourlyDV = 0
    // VLOOKUP(BO6,DailyCalc_1A3:R367,COLUMN(DailyCalc_1R3))
    // for i in 0..<8760 {
    //   hourly4[hourlyDV + i] = VLOOKUP(
    //     hourly1[hourlyBO + i], DailyCalc_1hourly_[(A + i)...].prefix(),
    //     COLUMN(DailyCalc_1hourly0[hourlyR + i]))
    // }

    /// Max net elec demand outside harm op period
    let hourlyDW = 8760
    // IF(BM6>0,0,IF(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+BK6+IF(BM7=0,0,A_overall_stup_cons)+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyDW + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]) + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j])))
    }

    /// Optimized max net elec demand outside harm op period
    let hourlyDX = 17520
    // IF(AND(DW7>0,DW6=0,DW5>0),DW5,DW6)
    for i in 0..<8760 {
      hourly4[hourlyDX + i] = iff(
        and(hourly4[hourlyDW + i] > 0, hourly4[hourlyDW + i].isZero, hourly4[hourlyDW + i - 1] > 0),
        hourly4[hourlyDW + i - 1], hourly4[hourlyDW + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyDY = 26280
    // IF(DX6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,DX6+BK6-BP6))-PB_net_min_cap))+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(DX6=0,DX7>0),MAX(0,IF(COUNTIF(DX1:DX6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyDY + i] = iff(
        hourly0[hourlyDX + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                - hourly1[hourlyBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly0[hourlyDX + i].isZero, hourly0[hourlyDX + i] > 0),
            max(
              0,
              iff(
                countiff(hourly0[(hourlyDX + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding max PB net elec output
    let hourlyDZ = 35040
    // IF(DX6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyDZ + i] = iff(
        hourly0[hourlyDX + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly0[hourlyDX + i] + hourly0[hourlyDY + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding max PB gross elec output
    let hourlyEA = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyEA + i] = iff(
        hourly0[hourlyDZ + i].isZero, 0,
        hourly0[hourlyDZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyDZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyEB = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyEB + i] = iff(
        and(hourly4[hourlyEA + i].isZero, hourly4[hourlyEA + i] > 0),
        iff(
          countiff(hourly4[(hourlyEA + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }
    let EBsum = hourly1.sum(hours: daysBO, condition: hourlyEB)
    /// Max gross heat cons for ST
    let hourlyEC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyEC + i] = iff(
        hourly4[hourlyEA + i].isZero, 0,
        hourly4[hourlyEA + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyEA + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let ECsum = hourly1.sum(hours: daysBO, condition: hourlyEC)
    /// Max gross heat cons for extraction
    let hourlyED = 70080
    // IF(EC6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(DZ6-DY6+BP6)/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,DZ6-DX6-DY6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyED + i] = iff(
        hourly4[hourlyEC + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j]),
              (hourly0[hourlyDZ + i] - hourly0[hourlyDY + i] + hourly1[hourlyBP + i])
                / (((overall_var_max_cons[j] - overall_var_min_cons[j])
                  * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                  + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]))
                * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                  * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                  + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])))
              - hourly1[hourlyBQ + i] - max(
                0, hourly0[hourlyDZ + i] - hourly0[hourlyDX + i] - hourly0[hourlyDY + i])
              * El_boiler_eff)))
    }
    let EDsum = hourly1.sum(hours: daysBO, condition: hourlyED)
    /// TES energy available if above min op case
    let hourlyEE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 0..<8760 {
      hourly4[hourlyEE + i] = iff(
        hourly2[hourlyCC + i].isZero, 0,
        min(
          AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap,
          EBsum[i] + ECsum[i] + EDsum[i]))
    }

    /// Effective gross heat cons for ST
    let hourlyEF = 87600
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*EC6)
    for i in 0..<8760 {
      hourly4[hourlyEF + i] = iff(
        hourly4[hourlyEE + i].isZero, 0,
        (hourly4[hourlyEE + i] - EBsum[i]) / (ECsum[i] + EDsum[i]) * hourly4[hourlyEC + i])
    }

    /// Effective PB gross elec output
    let hourlyEG = 96360
    // IF(EF6=0,0,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyEG + i] = iff(
        hourly4[hourlyEF + i].isZero, 0,
        hourly4[hourlyEF + i] * PB_nom_gross_eff
          * POLY(hourly4[hourlyEF + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourlyEH = 105120
    // IF(EG6=0,0,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyEH + i] = iff(
        hourly4[hourlyEG + i].isZero, 0,
        hourly4[hourlyEG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyEG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff)
          - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourlyEI = 113880
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*ED6)
    for i in 0..<8760 {
      hourly4[hourlyEI + i] = iff(
        hourly4[hourlyEE + i].isZero, 0,
        (hourly4[hourlyEE + i] - EBsum[i]) / (ECsum[i] + EDsum[i]) * hourly4[hourlyED + i])
    }

    /// TES energy to fulfil op case if above
    let hourlyEJ = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763),EE6,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))
    for i in 0..<8760 {
      hourly4[hourlyEJ + i] = iff(
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < EBsum[i] + ECsum[i]
          + EDsum[i], hourly4[hourlyEE + i], EBsum[i] + ECsum[i] + EDsum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyEK = 131400
    // IF(EJ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EJ6))
    for i in 0..<8760 {
      hourly4[hourlyEK + i] = iff(
        hourly4[hourlyEJ + i].isZero, 0,
        max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyEJ + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyEL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyEL + i] = iff(
        or(
          and(hourly4[hourlyEK + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyEK + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }
    let ELsum = hourly1.sum(hours: daysBO, condition: hourlyEL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyEM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyEM + i] = max(
        0, hourly4[hourlyEK + i] - ELsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyEN = 157680
    // IF(EK6=0,0,AY6-(EK6-EM6)/(SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6)
    for i in 0..<8760 {
      hourly4[hourlyEN + i] = iff(
        hourly4[hourlyEK + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyEK + i] - hourly4[hourlyEM + i])
          / (ELsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyEL + i])
    }
    let ENsum = hourly4.sum(hours: daysBO, condition: hourlyBZ)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyEO = 166440
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    // for i in 0..<8760 {
    //   hourly4[hourlyEO + i] = iff(
    //     or(hourly4[hourlyEN + i].isZero, hourly4[hourlyEM + i].isZero), 0,
    //     max(
    //       (hourly1[hourlyAW + i] - hourly4[hourlyEN + i])
    //         / (hourly4[hourlyEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
    //           / EN_BOcountNonZero[i]),
    //       (hourly0[hourlyJ + i] - hourly4[hourlyEN + i] * Heater_eff / Ratio_CSP_vs_Heater)
    //         / (hourly4[hourlyEM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i])) / ENsum[i]
    //       * hourly4[hourlyEN + i])
    // }
    let EOsum = hourly4.sum(days: daysBO, range: hourlyEO)
    /// corrected max possible PV elec to TES
    let hourlyEP = 175200
    // IF(EJ6=0,0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,EO5:EO8763)*EO6))
    for i in 0..<8760 {
      hourly4[hourlyEP + i] = iff(
        hourly4[hourlyEJ + i].isZero, 0,
        hourly4[hourlyEN + i]
          - iff(
            hourly4[hourlyEM + i].isZero, 0,
            hourly4[hourlyEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i]
              * hourly4[hourlyEO + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyEQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyEQ + i] = min(
        hourly0[hourlyJ + i], hourly4[hourlyEP + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyER = 192720
    // MAX(0,L6-EP6)
    for i in 0..<8760 {
      hourly4[hourlyER + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyEP + i])
    }

    /// Available heat from CSP after TES
    let hourlyES = 201480
    // MAX(0,J6-EQ6)
    for i in 0..<8760 {
      hourly4[hourlyES + i] = max(0, hourly0[hourlyJ + i] - hourly4[hourlyEQ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyET = 210240
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(EH6=0,PB_stby_aux_cons+EB6*TES_aux_cons_perc,(EB6+EF6+EI6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyET + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyEP + i] * Heater_eff + hourly4[hourlyEQ + i]) * TES_aux_cons_perc
        + iff(
          hourly4[hourlyEH + i].isZero, PB_stby_aux_cons + hourly4[hourlyEB + i] * TES_aux_cons_perc,
          (hourly4[hourlyEB + i] + hourly4[hourlyEF + i] + hourly4[hourlyEI + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyEU = 219000
    // MAX(0,-(L6+IF(EJ6>0,DZ6,0)-EP6-ET6))
    for i in 0..<8760 {
      hourly4[hourlyEU + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyEJ + i] > 0, hourly0[hourlyDZ + i], 0)
          - hourly4[hourlyEP + i] - hourly4[hourlyET + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyEW = 227760
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyEW + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyEX = 236520
    // IF(AND(EW6>0,EW5=0,OR(EW6=0,EW7=0)),0,EW6)
    for i in 0..<8760 {
      hourly4[hourlyEX + i] = iff(
        and(
          hourly4[hourlyEW + i] > 0, hourly4[hourlyEW + i - 1].isZero,
          or(hourly4[hourlyEW + i].isZero, hourly4[hourlyEW + i].isZero)), 0, hourly4[hourlyEW + i])
    }

    /// Min harmonious net heat cons
    let hourlyEY = 245280
    // EX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyEY + i] =
        hourly4[hourlyEX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyEZ = 254040
    // IF(AND(EX5<=0,EX6>0),EZ5+1,IF(AND(ER6>0,BO6<>BO5,SUM(EX6:EX8)=0),EZ5+1,EZ5))
    for i in 0..<8760 {
      hourly4[hourlyEZ + i] = iff(
        and(hourly4[hourlyEX + i - 1] <= 0, hourly4[hourlyEX + i] > 0),
        hourly4[hourlyEZ + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyER + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            sum(hourly4[(hourlyEX + i)...].prefix(3)) == 0), hourly4[hourlyEZ + i - 1] + 1,
          hourly4[hourlyEZ + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyFA = 262800
    // IF(OR(EX6>0,EJ6=0),0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)),((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFA + i] = iff(
        or(hourly4[hourlyEX + i] > 0, hourly4[hourlyEJ + i].isZero), 0,
        min(
          (hourly4[hourlyEH + i] + hourly4[hourlyER + i]
            + (hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])),
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let hourlyFB = 271560
    // IF(FA6=0,0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)),((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFB + i] = iff(
        hourly4[hourlyFA + i].isZero, 0,
        min(
          (hourly4[hourlyEH + i] + hourly4[hourlyER + i]
            + (hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
                + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
              * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
              + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
              + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])),
          ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
            * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
            + overall_heat_fix_stby_cons[j]
            + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourlyFC = 280320
    // MAX(0,EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFC + i] = max(
        0,
        hourly4[hourlyEH + i] + hourly4[hourlyER + i]
          - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyEX + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyES + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyFD = 289080
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 0..<8760 {
      hourly4[hourlyFD + i] = max(
        0,
        hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
          - hourly4[hourlyEY + i] - hourly4[hourlyFB + i])
    }

    /// Grid import necessary for min harm
    let hourlyFE = 297840
    // MAX(0,-(EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyFE + i] = max(
        0,
        -(hourly4[hourlyEH + i] + hourly4[hourlyER + i]
          - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyEX + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyES + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyFF = 306600
    // Grid_import_max_ud-FE6
    for i in 0..<8760 { hourly4[hourlyFF + i] = Grid_import_max_ud - hourly4[hourlyFE + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyFG = 315360
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFG + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyES + i]
            - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyFH = 324120
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 0..<8760 { hourly4[hourlyFH + i] = max(0, El_boiler_cap_ud - hourly4[hourlyFG + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyFI = 332880
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFI + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyFJ = 341640
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFJ + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyFK = 350400
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyFK + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyFL = 359160
    // MIN(BESS_chrg_max_cons,FC6)
    for i in 0..<8760 { hourly4[hourlyFL + i] = min(BESS_chrg_max_cons, hourly4[hourlyFC + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyFM = 367920
    // MIN(Grid_export_max_ud,FC6)
    for i in 0..<8760 { hourly4[hourlyFM + i] = min(Grid_export_max_ud, hourly4[hourlyFC + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyFN = 376680
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFN + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyFO = 385440
    // IF(AND(FN6>0,FN5=0,OR(FN6=0,FN7=0)),0,FN6)
    for i in 0..<8760 {
      hourly4[hourlyFO + i] = iff(
        and(
          hourly4[hourlyFN + i] > 0, hourly4[hourlyFN + i - 1].isZero,
          or(hourly4[hourlyFN + i].isZero, hourly4[hourlyFN + i].isZero)), 0, hourly4[hourlyFN + i])
    }

    /// max harmonious net heat cons
    let hourlyFP = 394200
    // FO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyFP + i] =
        hourly4[hourlyFO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyFQ = 402960
    // MAX(0,EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFQ + i] = max(
        0,
        hourly4[hourlyEH + i] + hourly4[hourlyER + i]
          - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyFO + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyES + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyFR = 411720
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 0..<8760 {
      hourly4[hourlyFR + i] = max(
        0,
        hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
          - hourly4[hourlyFP + i] - hourly4[hourlyFB + i])
    }

    /// Grid import necessary for max harm
    let hourlyFS = 420480
    // MAX(0,-(EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyFS + i] = max(
        0,
        -(hourly4[hourlyEH + i] + hourly4[hourlyER + i]
          - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyFO + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyES + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyFT = 429240
    // Grid_import_max_ud-FS6
    for i in 0..<8760 { hourly4[hourlyFT + i] = Grid_import_max_ud - hourly4[hourlyFS + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyFU = 438000
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFU + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyES + i]
            - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyFV = 446760
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 0..<8760 { hourly4[hourlyFV + i] = max(0, El_boiler_cap_ud - hourly4[hourlyFU + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyFW = 455520
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFW + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyFX = 464280
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFX + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyFY = 473040
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyFY + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyFZ = 481800
    // MIN(BESS_chrg_max_cons,FQ6)
    for i in 0..<8760 { hourly4[hourlyFZ + i] = min(BESS_chrg_max_cons, hourly4[hourlyFQ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyGA = 490560
    // MIN(Grid_export_max_ud,FQ6)
    for i in 0..<8760 { hourly4[hourlyGA + i] = min(Grid_export_max_ud, hourly4[hourlyFQ + i]) }
/*
    /// Min net elec demand to power block
    let hourlyGC = 499320
    // IF(BM6>0,0,IF(B_overall_var_min_cons+B_overall_fix_stby_cons+BK6+IF(BM7=0,0,B_overall_stup_cons)+MAX(0,B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,B_overall_var_min_cons+B_overall_fix_stby_cons+IF(BM7=0,0,B_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyGC + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          B_overall_var_min_cons + B_overall_fix_stby_cons + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons) + max(
              0,
              B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          B_overall_var_min_cons + B_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons)))
    }

    /// Optimized min net elec demand to power block
    let hourlyGD = 508080
    // IF(AND(GC7>0,GC6=0,GC5>0),GC5,GC6)
    for i in 0..<8760 {
      hourly4[hourlyGD + i] = iff(
        and(hourly4[hourlyGC + i] > 0, hourly4[hourlyGC + i].isZero, hourly4[hourlyGC + i - 1] > 0),
        hourly4[hourlyGC + i - 1], hourly4[hourlyGC + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyGE = 516840
    // IF(GD6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(GD6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(GD6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,GD6+BK6-BP6))-PB_net_min_cap))+MAX(0,B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(GD6=0,GD7>0),MAX(0,IF(COUNTIF(GD1:GD6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyGE + i] = iff(
        hourly4[hourlyGD + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly4[hourlyGD + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly4[hourlyGD + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly4[hourlyGD + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0, B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons - hourly1[hourlyBQ + i]
            ) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly4[hourlyGD + i].isZero, hourly4[hourlyGD + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(GD + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourlyGF = 525600
    // IF(GD6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,GD6+GE6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyGF + i] = iff(
        hourly4[hourlyGD + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly4[hourlyGD + i] + hourly4[hourlyGE + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding min PB gross elec output
    let hourlyGG = 534360
    // IF(GF6=0,0,GF6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(GF6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyGG + i] = iff(
        hourly4[hourlyGF + i].isZero, 0,
        hourly4[hourlyGF + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyGF + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyGH = 543120
    // IF(AND(GG6=0,GG7>0),IF(COUNTIF(GG1:GG6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyGH + i] = iff(
        and(hourly4[hourlyGG + i].isZero, hourly4[hourlyGG + i] > 0),
        iff(
          countiff(hourly_[(GG + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Min gross heat cons for ST
    let hourlyGI = 551880
    // IF(GG6=0,0,GG6/PB_nom_gross_eff/POLY(GG6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyGI + i] = iff(
        hourly4[hourlyGG + i].isZero, 0,
        hourly4[hourlyGG + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyGG + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Min gross heat cons for extraction
    let hourlyGJ = 560640
    // IF(GI6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons),(GF6-GE6+BP6)/(B_overall_var_min_cons+B_overall_fix_stby_cons+IF(BM7=0,0,B_overall_stup_cons))*(B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons)))-BQ6-MAX(0,GF6-GD6-GE6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyGJ + i] = iff(
        hourly4[hourlyGI + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons),
              (hourly4[hourlyGF + i] - hourly4[hourlyGE + i] + hourly1[hourlyBP + i])
                / (B_overall_var_min_cons + B_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons))
                * (B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly4[hourlyGF + i] - hourly4[hourlyGD + i] - hourly4[hourlyGE + i])
              * El_boiler_eff)))
    }

    /// TES energy needed to fulfil op case
    let hourlyGK = 569400
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,GH5:GH8763)+SUMIF(BO5:BO8763,"="BO6,GI5:GI8763)+SUMIF(BO5:BO8763,"="BO6,GJ5:GJ8763),0,SUMIF(BO5:BO8763,"="BO6,GH5:GH8763)+SUMIF(BO5:BO8763,"="BO6,GI5:GI8763)+SUMIF(BO5:BO8763,"="BO6,GJ5:GJ8763))
    for i in 0..<8760 {
      hourly4[hourlyGK + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], 0, sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyGL = 578160
    // IF(GK6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-GK6))
    for i in 0..<8760 {
      hourly4[hourlyGL + i] = iff(
        hourly4[hourlyGK + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyGK + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyGM = 586920
    // IF(OR(AND(GL6>0,AY6>0,AY5=0),AND(GL6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyGM + i] = iff(
        or(
          and(hourly4[hourlyGL + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyGL + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyGN = 595680
    // MAX(0,GL6-SUMIF(BO5:BO8763,"="BO6,GM5:GM8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyGN + i] = max(
        0, hourly4[hourlyGL + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyGO = 604440
    // IF(GL6=0,0,AY6-(GL6-GN6)/(SUMIF(BO5:BO8763,"="BO6,GM5:GM8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*GM6)
    for i in 0..<8760 {
      hourly4[hourlyGO + i] = iff(
        hourly4[hourlyGL + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyGL + i] - hourly4[hourlyGN + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyGM + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyGP = 613200
    // IF(OR(GO6=0,GN6=0),0,MAX((AW6-GO6)/(GN6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,GO5:GO8763,">0")),(J6-GO6*Heater_eff/Ratio_CSP_vs_Heater)/(GN6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,GO5:GO8763,">0")))/SUMIF(BO5:BO8763,"="BO6,GO5:GO8763)*GO6)
    for i in 0..<8760 {
      hourly4[hourlyGP + i] = iff(
        or(hourly4[hourlyGO + i].isZero, hourly4[hourlyGN + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly4[hourlyGO + i])
            / (hourly4[hourlyGN + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / GO_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly4[hourlyGO + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyGN + i] / (1 + Ratio_CSP_vs_Heater) / GO_BOcountNonZero[i])) / sum[i]
          * hourly4[hourlyGO + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyGQ = 621960
    // IF(GK6=0,0,GO6-IF(GN6=0,0,GN6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,GP5:GP8763)*GP6))
    for i in 0..<8760 {
      hourly4[hourlyGQ + i] = iff(
        hourly4[hourlyGK + i].isZero, 0,
        hourly4[hourlyGO + i]
          - iff(
            hourly4[hourlyGN + i].isZero, 0,
            hourly4[hourlyGN + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
              * hourly4[hourlyGP + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyGR = 630720
    // MIN(J6,GQ6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyGR + i] = min(
        hourly0[hourlyJ + i], hourly4[hourlyGQ + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyGS = 639480
    // MAX(0,L6-GQ6)
    for i in 0..<8760 {
      hourly4[hourlyGS + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyGQ + i])
    }

    /// Available heat from CSP after TES
    let hourlyGT = 648240
    // MAX(0,J6-GR6)
    for i in 0..<8760 {
      hourly4[hourlyGT + i] = max(0, hourly0[hourlyJ + i] - hourly4[hourlyGR + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyGU = 657000
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(GQ6*Heater_eff+GR6)*TES_aux_cons_perc+IF(OR(GG6=0,AND(GG6>0,GK6=0)),PB_stby_aux_cons+GH6*TES_aux_cons_perc,(GH6+GI6+GJ6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyGU + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyGQ + i] * Heater_eff + hourly4[hourlyGR + i]) * TES_aux_cons_perc
        + iff(
          or(hourly4[hourlyGG + i].isZero, and(hourly4[hourlyGG + i] > 0, hourly4[hourlyGK + i].isZero)),
          PB_stby_aux_cons + hourly4[hourlyGH + i] * TES_aux_cons_perc,
          (hourly4[hourlyGH + i] + hourly4[hourlyGI + i] + hourly4[hourlyGJ + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyGV = 665760
    // MAX(0,-(L6+IF(GK6>0,GF6,0)-GQ6-GU6))
    for i in 0..<8760 {
      hourly4[hourlyGV + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyGK + i] > 0, hourly4[hourlyGF + i], 0)
          - hourly4[hourlyGQ + i] - hourly4[hourlyGU + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyGX = 674520
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6),MIN(GT6+El_boiler_cap_ud*El_boiler_eff,(GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(GU6-GV6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-GT6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyGX + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]),
          min(
            hourly4[hourlyGT + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyGT + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyGY = 683280
    // IF(AND(GX6>0,GX5=0,OR(GX6=0,GX7=0)),0,GX6)
    for i in 0..<8760 {
      hourly4[hourlyGY + i] = iff(
        and(
          hourly4[hourlyGX + i] > 0, hourly4[hourlyGX + i - 1].isZero,
          or(hourly4[hourlyGX + i].isZero, hourly4[hourlyGX + i].isZero)), 0, hourly4[hourlyGX + i])
    }

    /// Min harmonious net heat cons
    let hourlyGZ = 692040
    // GY6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyGZ + i] =
        hourly4[hourlyGY + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyHA = 700800
    // IF(AND(GY5<=0,GY6>0),HA5+1,IF(AND(GS6>0,BO6<>BO5,SUM(GY6:GY8)=0),HA5+1,HA5))
    for i in 0..<8760 {
      hourly4[hourlyHA + i] = iff(
        and(hourly4[hourlyGY + i - 1] <= 0, hourly4[hourlyGY + i] > 0),
        hourly0[hourlyHA + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyGS + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(GY + i)...].prefix()) = 0), hourly0[hourlyHA + i - 1] + 1,
          hourly0[hourlyHA + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyHB = 709560
    // IF(OR(GY6>0,GK6=0),0,MIN((GF6+GS6+(GT6+GJ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(GU6-GV6))/(B_overall_var_min_cons+B_overall_fix_stby_cons+IF(GY7=0,0,B_overall_stup_cons)+(B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(GZ7=0,0,B_overall_heat_stup_cons))/El_boiler_eff)*(B_overall_var_min_cons+B_overall_fix_stby_cons+IF(GY7=0,0,B_overall_stup_cons)),B_overall_var_min_cons+B_overall_fix_stby_cons+IF(GY7=0,0,B_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyHB + i] = iff(
        or(hourly4[hourlyGY + i] > 0, hourly4[hourlyGK + i].isZero), 0,
        min(
          (hourly4[hourlyGF + i] + hourly4[hourlyGS + i]
            + (hourly4[hourlyGT + i] + hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]))
            / (B_overall_var_min_cons + B_overall_fix_stby_cons
              + iff(hourly4[hourlyGY + i].isZero, 0, B_overall_stup_cons)
              + (B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyGZ + i].isZero, 0, B_overall_heat_stup_cons)) / El_boiler_eff)
            * (B_overall_var_min_cons + B_overall_fix_stby_cons
              + iff(hourly4[hourlyGY + i].isZero, 0, B_overall_stup_cons)),
          B_overall_var_min_cons + B_overall_fix_stby_cons
            + iff(hourly4[hourlyGY + i].isZero, 0, B_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyHC = 718320
    // IF(HB6=0,0,MIN((GF6+GS6+(GT6+GJ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(GU6-GV6))/(B_overall_var_min_cons+B_overall_fix_stby_cons+IF(GY7=0,0,B_overall_stup_cons)+(B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(GZ7=0,0,B_overall_heat_stup_cons))/El_boiler_eff)*(B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(GZ7=0,0,B_overall_heat_stup_cons)),B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons+IF(GZ7=0,0,B_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyHC + i] = iff(
        hourly0[hourlyHB + i].isZero, 0,
        min(
          (hourly4[hourlyGF + i] + hourly4[hourlyGS + i]
            + (hourly4[hourlyGT + i] + hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]))
            / (B_overall_var_min_cons + B_overall_fix_stby_cons
              + iff(hourly4[hourlyGY + i].isZero, 0, B_overall_stup_cons)
              + (B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyGZ + i].isZero, 0, B_overall_heat_stup_cons)) / El_boiler_eff)
            * (B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
              + iff(hourly4[hourlyGZ + i].isZero, 0, B_overall_heat_stup_cons)),
          B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons
            + iff(hourly4[hourlyGZ + i].isZero, 0, B_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlyHD = 727080
    // MAX(0,IF(GK6>0,GF6,0)+GS6-(GU6-GV6)-GY6-HB6-MAX(0,(GZ6+HC6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0)-GT6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyHD + i] = max(
        0,
        iff(hourly4[hourlyGK + i] > 0, hourly4[hourlyGF + i], 0) + hourly4[hourlyGS + i]
          - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) - hourly4[hourlyGY + i]
          - hourly0[hourlyHB + i]
          - max(
            0,
            (hourly4[hourlyGZ + i] + hourly0[hourlyHC + i]
              - iff(
                hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyGT + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyHE = 735840
    // MAX(0,GT6+IF(GK6=0,0,GJ6/PB_Ratio_Heat_input_vs_output)-GZ6-HC6)
    for i in 0..<8760 {
      hourly4[hourlyHE + i] = max(
        0,
        hourly4[hourlyGT + i]
          + iff(
            hourly4[hourlyGK + i].isZero, 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output)
          - hourly4[hourlyGZ + i] - hourly0[hourlyHC + i])
    }

    /// Grid import necessary for min harm
    let hourlyHF = 744600
    // MAX(0,-(IF(GK6>0,GF6,0)+GS6-(GU6-GV6)-GY6-HB6-MAX(0,(GZ6+HC6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0)-GT6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyHF + i] = max(
        0,
        -(iff(hourly4[hourlyGK + i] > 0, hourly4[hourlyGF + i], 0) + hourly4[hourlyGS + i]
          - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) - hourly4[hourlyGY + i]
          - hourly0[hourlyHB + i]
          - max(
            0,
            (hourly4[hourlyGZ + i] + hourly0[hourlyHC + i]
              - iff(
                hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyGT + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyHG = 753360
    // Grid_import_max_ud-HF6
    for i in 0..<8760 { hourly4[hourlyHG + i] = Grid_import_max_ud - hourly0[hourlyHF + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyHH = 762120
    // MIN(El_boiler_cap_ud,MAX(0,(GZ6+HC6-GT6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyHH + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyGZ + i] + hourly0[hourlyHC + i] - hourly4[hourlyGT + i]
            - iff(
              hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyHI = 770880
    // MAX(0,El_boiler_cap_ud-HH6)
    for i in 0..<8760 { hourly4[hourlyHI + i] = max(0, El_boiler_cap_ud - hourly0[hourlyHH + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyHJ = 779640
    // MAX(0,1-GY6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyHJ + i] =
        max(
          0,
          1 - hourly4[hourlyGY + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyHK = 788400
    // MAX(0,1-GY6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyHK + i] =
        max(
          0,
          1 - hourly4[hourlyGY + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyHL = 797160
    // MAX(0,1-GY6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyHL + i] =
        max(
          0,
          1 - hourly4[hourlyGY + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyHM = 805920
    // MIN(BESS_chrg_max_cons,HD6)
    for i in 0..<8760 { hourly4[hourlyHM + i] = min(BESS_chrg_max_cons, hourly0[hourlyHD + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyHN = 814680
    // MIN(Grid_export_max_ud,HD6)
    for i in 0..<8760 { hourly4[hourlyHN + i] = min(Grid_export_max_ud, hourly0[hourlyHD + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyHO = 823440
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6),MIN(GT6+El_boiler_cap_ud*El_boiler_eff,(GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(GU6-GV6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-GT6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6),MIN(GT6+El_boiler_cap_ud*El_boiler_eff,(GS6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(GU6-GV6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(GU6-GV6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-GT6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyHO + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]),
          min(
            hourly4[hourlyGT + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyGT + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]),
          min(
            hourly4[hourlyGT + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyGS + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyGT + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyHP = 832200
    // IF(AND(HO6>0,HO5=0,OR(HO6=0,HO7=0)),0,HO6)
    for i in 0..<8760 {
      hourly4[hourlyHP + i] = iff(
        and(
          hourly0[hourlyHO + i] > 0, hourly0[hourlyHO + i - 1].isZero,
          or(hourly0[hourlyHO + i].isZero, hourly0[hourlyHO + i].isZero)), 0, hourly0[hourlyHO + i])
    }

    /// max harmonious net heat cons
    let hourlyHQ = 840960
    // HP6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyHQ + i] =
        hourly0[hourlyHP + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyHR = 849720
    // MAX(0,IF(GK6>0,GF6,0)+GS6-(GU6-GV6)-HP6-HB6-MAX(0,(HQ6+HC6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0)-GT6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyHR + i] = max(
        0,
        iff(hourly4[hourlyGK + i] > 0, hourly4[hourlyGF + i], 0) + hourly4[hourlyGS + i]
          - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) - hourly0[hourlyHP + i]
          - hourly0[hourlyHB + i]
          - max(
            0,
            (hourly4[hourlyHQ + i] + hourly0[hourlyHC + i]
              - iff(
                hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyGT + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyHS = 858480
    // MAX(0,GT6+IF(GK6=0,0,GJ6/PB_Ratio_Heat_input_vs_output)-HQ6-HC6)
    for i in 0..<8760 {
      hourly4[hourlyHS + i] = max(
        0,
        hourly4[hourlyGT + i]
          + iff(
            hourly4[hourlyGK + i].isZero, 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output)
          - hourly4[hourlyHQ + i] - hourly0[hourlyHC + i])
    }

    /// Grid import necessary for max harm
    let hourlyHT = 867240
    // MAX(0,-(IF(GK6>0,GF6,0)+GS6-(GU6-GV6)-HP6-HB6-MAX(0,(HQ6+HC6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0)-GT6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyHT + i] = max(
        0,
        -(iff(hourly4[hourlyGK + i] > 0, hourly4[hourlyGF + i], 0) + hourly4[hourlyGS + i]
          - (hourly4[hourlyGU + i] - hourly4[hourlyGV + i]) - hourly0[hourlyHP + i]
          - hourly0[hourlyHB + i]
          - max(
            0,
            (hourly4[hourlyHQ + i] + hourly0[hourlyHC + i]
              - iff(
                hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyGT + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyHU = 876000
    // Grid_import_max_ud-HT6
    for i in 0..<8760 { hourly4[hourlyHU + i] = Grid_import_max_ud - hourly4[hourlyHT + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyHV = 884760
    // MIN(El_boiler_cap_ud,MAX(0,(HQ6+HC6-GT6-IF(GK6>0,GJ6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyHV + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyHQ + i] + hourly0[hourlyHC + i] - hourly4[hourlyGT + i]
            - iff(
              hourly4[hourlyGK + i] > 0, hourly4[hourlyGJ + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyHW = 893520
    // MAX(0,El_boiler_cap_ud-HV6)
    for i in 0..<8760 { hourly4[hourlyHW + i] = max(0, El_boiler_cap_ud - hourly0[hourlyHV + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyHX = 902280
    // MAX(0,1-HP6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyHX + i] =
        max(
          0,
          1 - hourly0[hourlyHP + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyHY = 911040
    // MAX(0,1-HP6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyHY + i] =
        max(
          0,
          1 - hourly0[hourlyHP + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyHZ = 919800
    // MAX(0,1-HP6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyHZ + i] =
        max(
          0,
          1 - hourly0[hourlyHP + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyIA = 928560
    // MIN(BESS_chrg_max_cons,HR6)
    for i in 0..<8760 { hourly4[hourlyIA + i] = min(BESS_chrg_max_cons, hourly0[hourlyHR + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyIB = 937320
    // MIN(Grid_export_max_ud,HR6)
    for i in 0..<8760 { hourly4[hourlyIB + i] = min(Grid_export_max_ud, hourly0[hourlyHR + i]) }

    /// Maximum night op perc considering tank sizes
    let hourlyID = 946080
    // VLOOKUP(BO6,DailyCalc_1A3:BD367,COLUMN(DailyCalc_1BD3))
    for i in 0..<8760 {
      hourly4[hourlyID + i] = VLOOKUP(
        hourly1[hourlyBO + i], DailyCalc_1hourly_[(A + i)...].prefix(),
        COLUMN(DailyCalc_1hourly1[hourlyBD + i]))
    }

    /// Max net elec demand outside harm op period
    let hourlyIE = 954840
    // IF(BM6>0,0,IF(B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+BK6+IF(BM7=0,0,B_overall_stup_cons)+MAX(0,B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(BM7=0,0,B_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyIE + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
            + hourly1[hourlyBK + i] + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons) + max(
              0,
              B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons)))
    }

    /// Optimized max net elec demand outside harm op period
    let hourlyIF = 963600
    // IF(AND(IE7>0,IE6=0,IE5>0),IE5,IE6)
    for i in 0..<8760 {
      hourly4[hourlyIF + i] = iff(
        and(hourly4[hourlyIE + i] > 0, hourly4[hourlyIE + i].isZero, hourly4[hourlyIE + i - 1] > 0),
        hourly4[hourlyIE + i - 1], hourly4[hourlyIE + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyIG = 972360
    // IF(IF6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(IF6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(IF6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,IF6+BK6-BP6))-PB_net_min_cap))+MAX(0,B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(IF6=0,IF7>0),MAX(0,IF(COUNTIF(IF1:IF6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyIG + i] = iff(
        hourly4[hourlyIF + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly4[hourlyIF + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly4[hourlyIF + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly4[hourlyIF + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
                - hourly1[hourlyBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly4[hourlyIF + i].isZero, hourly4[hourlyIF + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(IF + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding max PB net elec output
    let hourlyIH = 981120
    // IF(IF6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,IF6+IG6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyIH + i] = iff(
        hourly4[hourlyIF + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly4[hourlyIF + i] + hourly4[hourlyIG + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding max PB gross elec output
    let hourlyII = 989880
    // IF(IH6=0,0,IH6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(IH6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyII + i] = iff(
        hourly4[hourlyIH + i].isZero, 0,
        hourly4[hourlyIH + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyIH + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyIJ = 998640
    // IF(AND(II6=0,II7>0),IF(COUNTIF(II1:II6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyIJ + i] = iff(
        and(hourly4[hourlyII + i].isZero, hourly4[hourlyII + i] > 0),
        iff(
          countiff(hourly_[(II + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Max gross heat cons for ST
    let hourlyIK = 1_007_400
    // IF(II6=0,0,II6/PB_nom_gross_eff/POLY(II6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyIK + i] = iff(
        hourly4[hourlyII + i].isZero, 0,
        hourly4[hourlyII + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyII + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Max gross heat cons for extraction
    let hourlyIL = 1_016_160
    // IF(IK6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons),(IH6-IG6+BP6)/(B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(BM7=0,0,B_overall_stup_cons))*(B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(BM7=0,0,B_overall_heat_stup_cons)))-BQ6-MAX(0,IH6-IF6-IG6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyIL + i] = iff(
        hourly4[hourlyIK + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons),
              (hourly4[hourlyIH + i] - hourly4[hourlyIG + i] + hourly1[hourlyBP + i])
                / (B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_stup_cons))
                * (B_overall_var_heat_max_cons * hourly4[hourlyID + i]
                  + B_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, B_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly4[hourlyIH + i] - hourly4[hourlyIF + i] - hourly4[hourlyIG + i])
              * El_boiler_eff)))
    }

    /// TES energy available if above min op case
    let hourlyIM = 1_024_920
    // IF(GK6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,IJ5:IJ8763)+SUMIF(BO5:BO8763,"="BO6,IK5:IK8763)+SUMIF(BO5:BO8763,"="BO6,IL5:IL8763)))
    for i in 0..<8760 {
      hourly4[hourlyIM + i] = iff(
        hourly4[hourlyGK + i].isZero, 0,
        min(
          sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap,
          sum[i] + sum[i] + sum[i]))
    }

    /// Effective gross heat cons for ST
    let hourlyIN = 1_033_680
    // IF(IM6=0,0,(IM6-SUMIF(BO5:BO8763,"="BO6,IJ5:IJ8763))/(SUMIF(BO5:BO8763,"="BO6,IK5:IK8763)+SUMIF(BO5:BO8763,"="BO6,IL5:IL8763))*IK6)
    for i in 0..<8760 {
      hourly4[hourlyIN + i] = iff(
        hourly4[hourlyIM + i].isZero, 0,
        (hourly4[hourlyIM + i] - sum[i]) / (sum[i] + sum[i]) * hourly4[hourlyIK + i])
    }

    /// Effective PB gross elec output
    let hourlyIO = 1_042_440
    // IF(IN6=0,0,IN6*PB_nom_gross_eff*POLY(IN6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyIO + i] = iff(
        hourly4[hourlyIN + i].isZero, 0,
        hourly4[hourlyIN + i] * PB_nom_gross_eff
          * POLY(hourly4[hourlyIN + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourlyIP = 1_051_200
    // IF(IO6=0,0,IO6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(IO6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyIP + i] = iff(
        hourly4[hourlyIO + i].isZero, 0,
        hourly4[hourlyIO + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyIO + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff)
          - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourlyIQ = 1_059_960
    // IF(IM6=0,0,(IM6-SUMIF(BO5:BO8763,"="BO6,IJ5:IJ8763))/(SUMIF(BO5:BO8763,"="BO6,IK5:IK8763)+SUMIF(BO5:BO8763,"="BO6,IL5:IL8763))*IL6)
    for i in 0..<8760 {
      hourly4[hourlyIQ + i] = iff(
        hourly4[hourlyIM + i].isZero, 0,
        (hourly4[hourlyIM + i] - sum[i]) / (sum[i] + sum[i]) * hourly4[hourlyIL + i])
    }

    /// TES energy to fulfil op case if above
    let hourlyIR = 1_068_720
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,IJ5:IJ8763)+SUMIF(BO5:BO8763,"="BO6,IK5:IK8763)+SUMIF(BO5:BO8763,"="BO6,IL5:IL8763),IM6,SUMIF(BO5:BO8763,"="BO6,IJ5:IJ8763)+SUMIF(BO5:BO8763,"="BO6,IK5:IK8763)+SUMIF(BO5:BO8763,"="BO6,IL5:IL8763))
    for i in 0..<8760 {
      hourly4[hourlyIR + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], hourly4[hourlyIM + i], sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyIS = 1_077_480
    // IF(IR6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-IR6))
    for i in 0..<8760 {
      hourly4[hourlyIS + i] = iff(
        hourly4[hourlyIR + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyIR + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyIT = 1_086_240
    // IF(OR(AND(IS6>0,AY6>0,AY5=0),AND(IS6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyIT + i] = iff(
        or(
          and(hourly4[hourlyIS + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyIS + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyIU = 1_095_000
    // MAX(0,IS6-SUMIF(BO5:BO8763,"="BO6,IT5:IT8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyIU + i] = max(
        0, hourly4[hourlyIS + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyIV = 1_103_760
    // IF(IS6=0,0,AY6-(IS6-IU6)/(SUMIF(BO5:BO8763,"="BO6,IT5:IT8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*IT6)
    for i in 0..<8760 {
      hourly4[hourlyIV + i] = iff(
        hourly4[hourlyIS + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyIS + i] - hourly4[hourlyIU + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyIT + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyIW = 1_112_520
    // IF(OR(IV6=0,IU6=0),0,MAX((AW6-IV6)/(IU6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,IV5:IV8763,">0")),(J6-IV6*Heater_eff/Ratio_CSP_vs_Heater)/(IU6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,IV5:IV8763,">0")))/SUMIF(BO5:BO8763,"="BO6,IV5:IV8763)*IV6)
    for i in 0..<8760 {
      hourly4[hourlyIW + i] = iff(
        or(hourly4[hourlyIV + i].isZero, hourly4[hourlyIU + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly4[hourlyIV + i])
            / (hourly4[hourlyIU + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / IV_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly4[hourlyIV + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyIU + i] / (1 + Ratio_CSP_vs_Heater) / IV_BOcountNonZero[i])) / sum[i]
          * hourly4[hourlyIV + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyIX = 1_121_280
    // IF(IR6=0,0,IV6-IF(IU6=0,0,IU6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,IW5:IW8763)*IW6))
    for i in 0..<8760 {
      hourly4[hourlyIX + i] = iff(
        hourly4[hourlyIR + i].isZero, 0,
        hourly4[hourlyIV + i]
          - iff(
            hourly4[hourlyIU + i].isZero, 0,
            hourly4[hourlyIU + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
              * hourly4[hourlyIW + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyIY = 1_130_040
    // MIN(J6,IX6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyIY + i] = min(
        hourly0[hourlyJ + i], hourly4[hourlyIX + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyIZ = 1_138_800
    // MAX(0,L6-IX6)
    for i in 0..<8760 {
      hourly4[hourlyIZ + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyIX + i])
    }

    /// Available heat from CSP after TES
    let hourlyJA = 1_147_560
    // MAX(0,J6-IY6)
    for i in 0..<8760 {
      hourly4[hourlyJA + i] = max(0, hourly0[hourlyJ + i] - hourly4[hourlyIY + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyJB = 1_156_320
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(IX6*Heater_eff+IY6)*TES_aux_cons_perc+IF(IP6=0,PB_stby_aux_cons+IJ6*TES_aux_cons_perc,(IJ6+IN6+IQ6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyJB + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyIX + i] * Heater_eff + hourly4[hourlyIY + i]) * TES_aux_cons_perc
        + iff(
          hourly4[hourlyIP + i].isZero, PB_stby_aux_cons + hourly4[hourlyIJ + i] * TES_aux_cons_perc,
          (hourly4[hourlyIJ + i] + hourly4[hourlyIN + i] + hourly4[hourlyIQ + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyJC = 1_165_080
    // MAX(0,-(L6+IF(IR6>0,IH6,0)-IX6-JB6))
    for i in 0..<8760 {
      hourly4[hourlyJC + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyIR + i] > 0, hourly4[hourlyIH + i], 0)
          - hourly4[hourlyIX + i] - hourly0[hourlyJB + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyJE = 1_173_840
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6),MIN(JA6+El_boiler_cap_ud*El_boiler_eff,(IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(JB6-JC6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-JA6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyJE + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]),
          min(
            hourly0[hourlyJA + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyJA + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyJF = 1_182_600
    // IF(AND(JE6>0,JE5=0,OR(JE6=0,JE7=0)),0,JE6)
    for i in 0..<8760 {
      hourly4[hourlyJF + i] = iff(
        and(
          hourly0[hourlyJE + i] > 0, hourly0[hourlyJE + i - 1].isZero,
          or(hourly0[hourlyJE + i].isZero, hourly0[hourlyJE + i].isZero)), 0, hourly0[hourlyJE + i])
    }

    /// Min harmonious net heat cons
    let hourlyJG = 1_191_360
    // JF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyJG + i] =
        hourly0[hourlyJF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyJH = 1_200_120
    // IF(AND(JF5<=0,JF6>0),JH5+1,IF(AND(IZ6>0,BO6<>BO5,SUM(JF6:JF8)=0),JH5+1,JH5))
    for i in 0..<8760 {
      hourly4[hourlyJH + i] = iff(
        and(hourly0[hourlyJF + i - 1] <= 0, hourly0[hourlyJF + i] > 0),
        hourly0[hourlyJH + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyIZ + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(JF + i)...].prefix()) = 0), hourly0[hourlyJH + i - 1] + 1,
          hourly0[hourlyJH + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyJI = 1_208_880
    // IF(OR(JF6>0,IR6=0),0,MIN((IP6+IZ6+(JA6+IQ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(JB6-JC6))/(B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(JF7=0,0,B_overall_stup_cons)+(B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(JG7=0,0,B_overall_heat_stup_cons))/El_boiler_eff)*(B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(JF7=0,0,B_overall_stup_cons)),B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(JF7=0,0,B_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyJI + i] = iff(
        or(hourly0[hourlyJF + i] > 0, hourly4[hourlyIR + i].isZero), 0,
        min(
          (hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
            + (hourly0[hourlyJA + i] + hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]))
            / (B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
              + iff(hourly0[hourlyJF + i].isZero, 0, B_overall_stup_cons)
              + (B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyJG + i].isZero, 0, B_overall_heat_stup_cons)) / El_boiler_eff)
            * (B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
              + iff(hourly0[hourlyJF + i].isZero, 0, B_overall_stup_cons)),
          B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
            + iff(hourly0[hourlyJF + i].isZero, 0, B_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyJJ = 1_217_640
    // IF(JI6=0,0,MIN((IP6+IZ6+(JA6+IQ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(JB6-JC6))/(B_overall_var_max_cons*ID6+B_overall_fix_stby_cons+IF(JF7=0,0,B_overall_stup_cons)+(B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(JG7=0,0,B_overall_heat_stup_cons))/El_boiler_eff)*(B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(JG7=0,0,B_overall_heat_stup_cons)),B_overall_var_heat_max_cons*ID6+B_overall_heat_fix_stby_cons+IF(JG7=0,0,B_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyJJ + i] = iff(
        hourly0[hourlyJI + i].isZero, 0,
        min(
          (hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
            + (hourly0[hourlyJA + i] + hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]))
            / (B_overall_var_max_cons * hourly4[hourlyID + i] + B_overall_fix_stby_cons
              + iff(hourly0[hourlyJF + i].isZero, 0, B_overall_stup_cons)
              + (B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyJG + i].isZero, 0, B_overall_heat_stup_cons)) / El_boiler_eff)
            * (B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
              + iff(hourly0[hourlyJG + i].isZero, 0, B_overall_heat_stup_cons)),
          B_overall_var_heat_max_cons * hourly4[hourlyID + i] + B_overall_heat_fix_stby_cons
            + iff(hourly0[hourlyJG + i].isZero, 0, B_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlyJK = 1_226_400
    // MAX(0,IP6+IZ6-(JB6-JC6)-JF6-JI6-MAX(0,(JG6+JJ6-IQ6/PB_Ratio_Heat_input_vs_output-JA6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyJK + i] = max(
        0,
        hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
          - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) - hourly0[hourlyJF + i]
          - hourly0[hourlyJI + i]
          - max(
            0,
            (hourly0[hourlyJG + i] + hourly0[hourlyJJ + i] - hourly4[hourlyIQ + i]
              / PB_Ratio_Heat_input_vs_output - hourly0[hourlyJA + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyJL = 1_235_160
    // MAX(0,JA6+IQ6/PB_Ratio_Heat_input_vs_output-JG6-JJ6)
    for i in 0..<8760 {
      hourly4[hourlyJL + i] = max(
        0,
        hourly0[hourlyJA + i] + hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output
          - hourly0[hourlyJG + i] - hourly0[hourlyJJ + i])
    }

    /// Grid import necessary for min harm
    let hourlyJM = 1_243_920
    // MAX(0,-(IP6+IZ6-(JB6-JC6)-JF6-JI6-MAX(0,(JG6+JJ6-IQ6/PB_Ratio_Heat_input_vs_output-JA6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyJM + i] = max(
        0,
        -(hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
          - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) - hourly0[hourlyJF + i]
          - hourly0[hourlyJI + i]
          - max(
            0,
            (hourly0[hourlyJG + i] + hourly0[hourlyJJ + i] - hourly4[hourlyIQ + i]
              / PB_Ratio_Heat_input_vs_output - hourly0[hourlyJA + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyJN = 1_252_680
    // Grid_import_max_ud-JM6
    for i in 0..<8760 { hourly4[hourlyJN + i] = Grid_import_max_ud - hourly0[hourlyJM + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyJO = 1_261_440
    // MIN(El_boiler_cap_ud,MAX(0,(JG6+JJ6-JA6-IQ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyJO + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyJG + i] + hourly0[hourlyJJ + i] - hourly0[hourlyJA + i]
            - hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyJP = 1_270_200
    // MAX(0,El_boiler_cap_ud-JO6)
    for i in 0..<8760 { hourly4[hourlyJP + i] = max(0, El_boiler_cap_ud - hourly0[hourlyJO + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyJQ = 1_278_960
    // MAX(0,1-JF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyJQ + i] =
        max(
          0,
          1 - hourly0[hourlyJF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyJR = 1_287_720
    // MAX(0,1-JF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyJR + i] =
        max(
          0,
          1 - hourly0[hourlyJF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyJS = 1_296_480
    // MAX(0,1-JF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyJS + i] =
        max(
          0,
          1 - hourly0[hourlyJF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyJT = 1_305_240
    // MIN(BESS_chrg_max_cons,JK6)
    for i in 0..<8760 { hourly4[hourlyJT + i] = min(BESS_chrg_max_cons, hourly0[hourlyJK + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyJU = 1_314_000
    // MIN(Grid_export_max_ud,JK6)
    for i in 0..<8760 { hourly4[hourlyJU + i] = min(Grid_export_max_ud, hourly0[hourlyJK + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyJV = 1_322_760
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6),MIN(JA6+El_boiler_cap_ud*El_boiler_eff,(IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(JB6-JC6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-JA6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6),MIN(JA6+El_boiler_cap_ud*El_boiler_eff,(IZ6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(JB6-JC6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(JB6-JC6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-JA6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyJV + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]),
          min(
            hourly0[hourlyJA + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyJA + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]),
          min(
            hourly0[hourlyJA + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyIZ + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyJA + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyJW = 1_331_520
    // IF(AND(JV6>0,JV5=0,OR(JV6=0,JV7=0)),0,JV6)
    for i in 0..<8760 {
      hourly4[hourlyJW + i] = iff(
        and(
          hourly0[hourlyJV + i] > 0, hourly0[hourlyJV + i - 1].isZero,
          or(hourly0[hourlyJV + i].isZero, hourly0[hourlyJV + i].isZero)), 0, hourly0[hourlyJV + i])
    }

    /// max harmonious net heat cons
    let hourlyJX = 1_340_280
    // JW6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyJX + i] =
        hourly0[hourlyJW + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyJY = 1_349_040
    // MAX(0,IP6+IZ6-(JB6-JC6)-JW6-JI6-MAX(0,(JX6+JJ6-IQ6/PB_Ratio_Heat_input_vs_output-JA6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyJY + i] = max(
        0,
        hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
          - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) - hourly0[hourlyJW + i]
          - hourly0[hourlyJI + i]
          - max(
            0,
            (hourly0[hourlyJX + i] + hourly0[hourlyJJ + i] - hourly4[hourlyIQ + i]
              / PB_Ratio_Heat_input_vs_output - hourly0[hourlyJA + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyJZ = 1_357_800
    // MAX(0,JA6+IQ6/PB_Ratio_Heat_input_vs_output-JX6-JJ6)
    for i in 0..<8760 {
      hourly4[hourlyJZ + i] = max(
        0,
        hourly0[hourlyJA + i] + hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output
          - hourly0[hourlyJX + i] - hourly0[hourlyJJ + i])
    }

    /// Grid import necessary for max harm
    let hourlyKA = 1_366_560
    // MAX(0,-(IP6+IZ6-(JB6-JC6)-JW6-JI6-MAX(0,(JX6+JJ6-IQ6/PB_Ratio_Heat_input_vs_output-JA6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyKA + i] = max(
        0,
        -(hourly4[hourlyIP + i] + hourly4[hourlyIZ + i]
          - (hourly0[hourlyJB + i] - hourly0[hourlyJC + i]) - hourly0[hourlyJW + i]
          - hourly0[hourlyJI + i]
          - max(
            0,
            (hourly0[hourlyJX + i] + hourly0[hourlyJJ + i] - hourly4[hourlyIQ + i]
              / PB_Ratio_Heat_input_vs_output - hourly0[hourlyJA + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyKB = 1_375_320
    // Grid_import_max_ud-KA6
    for i in 0..<8760 { hourly4[hourlyKB + i] = Grid_import_max_ud - hourly0[hourlyKA + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyKC = 1_384_080
    // MIN(El_boiler_cap_ud,MAX(0,(JX6+JJ6-JA6-IQ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyKC + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyJX + i] + hourly0[hourlyJJ + i] - hourly0[hourlyJA + i]
            - hourly4[hourlyIQ + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyKD = 1_392_840
    // MAX(0,El_boiler_cap_ud-KC6)
    for i in 0..<8760 { hourly4[hourlyKD + i] = max(0, El_boiler_cap_ud - hourly4[hourlyKC + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyKE = 1_401_600
    // MAX(0,1-JW6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyKE + i] =
        max(
          0,
          1 - hourly0[hourlyJW + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyKF = 1_410_360
    // MAX(0,1-JW6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyKF + i] =
        max(
          0,
          1 - hourly0[hourlyJW + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyKG = 1_419_120
    // MAX(0,1-JW6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyKG + i] =
        max(
          0,
          1 - hourly0[hourlyJW + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyKH = 1_427_880
    // MIN(BESS_chrg_max_cons,JY6)
    for i in 0..<8760 { hourly4[hourlyKH + i] = min(BESS_chrg_max_cons, hourly0[hourlyJY + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyKI = 1_436_640
    // MIN(Grid_export_max_ud,JY6)
    for i in 0..<8760 { hourly4[hourlyKI + i] = min(Grid_export_max_ud, hourly0[hourlyJY + i]) }

    /// Min net elec demand to power block
    let hourlyKK = 1_445_400
    // IF(BM6>0,0,IF(C_overall_var_min_cons+C_overall_fix_stby_cons+BK6+IF(BM7=0,0,C_overall_stup_cons)+MAX(0,C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,C_overall_var_min_cons+C_overall_fix_stby_cons+IF(BM7=0,0,C_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyKK + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          C_overall_var_min_cons + C_overall_fix_stby_cons + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons) + max(
              0,
              C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          C_overall_var_min_cons + C_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons)))
    }

    /// Optimized min net elec demand to power block
    let hourlyKL = 1_454_160
    // IF(AND(KK7>0,KK6=0,KK5>0),KK5,KK6)
    for i in 0..<8760 {
      hourly4[hourlyKL + i] = iff(
        and(hourly4[hourlyKK + i] > 0, hourly4[hourlyKK + i].isZero, hourly4[hourlyKK + i - 1] > 0),
        hourly4[hourlyKK + i - 1], hourly4[hourlyKK + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyKM = 1_462_920
    // IF(KL6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(KL6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(KL6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,KL6+BK6-BP6))-PB_net_min_cap))+MAX(0,C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(KL6=0,KL7>0),MAX(0,IF(COUNTIF(KL1:KL6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyKM + i] = iff(
        hourly4[hourlyKL + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly4[hourlyKL + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly4[hourlyKL + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly4[hourlyKL + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0, C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons - hourly1[hourlyBQ + i]
            ) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly4[hourlyKL + i].isZero, hourly4[hourlyKL + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(KL + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourlyKN = 1_471_680
    // IF(KL6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,KL6+KM6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyKN + i] = iff(
        hourly4[hourlyKL + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly4[hourlyKL + i] + hourly0[hourlyKM + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding min PB gross elec output
    let hourlyKO = 1_480_440
    // IF(KN6=0,0,KN6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(KN6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyKO + i] = iff(
        hourly4[hourlyKN + i].isZero, 0,
        hourly4[hourlyKN + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyKN + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyKP = 1_489_200
    // IF(AND(KO6=0,KO7>0),IF(COUNTIF(KO1:KO6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyKP + i] = iff(
        and(hourly4[hourlyKO + i].isZero, hourly4[hourlyKO + i] > 0),
        iff(
          countiff(hourly_[(KO + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Min gross heat cons for ST
    let hourlyKQ = 1_497_960
    // IF(KO6=0,0,KO6/PB_nom_gross_eff/POLY(KO6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyKQ + i] = iff(
        hourly4[hourlyKO + i].isZero, 0,
        hourly4[hourlyKO + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyKO + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Min gross heat cons for extraction
    let hourlyKR = 1_506_720
    // IF(KQ6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons),(KN6-KM6+BP6)/(C_overall_var_min_cons+C_overall_fix_stby_cons+IF(BM7=0,0,C_overall_stup_cons))*(C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons)))-BQ6-MAX(0,KN6-KL6-KM6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyKR + i] = iff(
        hourly4[hourlyKQ + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons),
              (hourly4[hourlyKN + i] - hourly0[hourlyKM + i] + hourly1[hourlyBP + i])
                / (C_overall_var_min_cons + C_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons))
                * (C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly4[hourlyKN + i] - hourly4[hourlyKL + i] - hourly0[hourlyKM + i])
              * El_boiler_eff)))
    }

    /// TES energy needed to fulfil op case
    let hourlyKS = 1_515_480
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,KP5:KP8763)+SUMIF(BO5:BO8763,"="BO6,KQ5:KQ8763)+SUMIF(BO5:BO8763,"="BO6,KR5:KR8763),0,SUMIF(BO5:BO8763,"="BO6,KP5:KP8763)+SUMIF(BO5:BO8763,"="BO6,KQ5:KQ8763)+SUMIF(BO5:BO8763,"="BO6,KR5:KR8763))
    for i in 0..<8760 {
      hourly4[hourlyKS + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], 0, sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyKT = 1_524_240
    // IF(KS6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-KS6))
    for i in 0..<8760 {
      hourly4[hourlyKT + i] = iff(
        hourly4[hourlyKS + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyKS + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyKU = 1_533_000
    // IF(OR(AND(KT6>0,AY6>0,AY5=0),AND(KT6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyKU + i] = iff(
        or(
          and(hourly4[hourlyKT + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyKT + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyKV = 1_541_760
    // MAX(0,KT6-SUMIF(BO5:BO8763,"="BO6,KU5:KU8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyKV + i] = max(
        0, hourly4[hourlyKT + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyKW = 1_550_520
    // IF(KT6=0,0,AY6-(KT6-KV6)/(SUMIF(BO5:BO8763,"="BO6,KU5:KU8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*KU6)
    for i in 0..<8760 {
      hourly4[hourlyKW + i] = iff(
        hourly4[hourlyKT + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyKT + i] - hourly4[hourlyKV + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyKU + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyKX = 1_559_280
    // IF(OR(KW6=0,KV6=0),0,MAX((AW6-KW6)/(KV6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,KW5:KW8763,">0")),(J6-KW6*Heater_eff/Ratio_CSP_vs_Heater)/(KV6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,KW5:KW8763,">0")))/SUMIF(BO5:BO8763,"="BO6,KW5:KW8763)*KW6)
    for i in 0..<8760 {
      hourly4[hourlyKX + i] = iff(
        or(hourly4[hourlyKW + i].isZero, hourly4[hourlyKV + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly4[hourlyKW + i])
            / (hourly4[hourlyKV + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / KW_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly4[hourlyKW + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyKV + i] / (1 + Ratio_CSP_vs_Heater) / KW_BOcountNonZero[i])) / sum[i]
          * hourly4[hourlyKW + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyKY = 1_568_040
    // IF(KS6=0,0,KW6-IF(KV6=0,0,KV6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,KX5:KX8763)*KX6))
    for i in 0..<8760 {
      hourly4[hourlyKY + i] = iff(
        hourly4[hourlyKS + i].isZero, 0,
        hourly4[hourlyKW + i]
          - iff(
            hourly4[hourlyKV + i].isZero, 0,
            hourly4[hourlyKV + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
              * hourly4[hourlyKX + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyKZ = 1_576_800
    // MIN(J6,KY6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyKZ + i] = min(
        hourly0[hourlyJ + i], hourly4[hourlyKY + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyLA = 1_585_560
    // MAX(0,L6-KY6)
    for i in 0..<8760 {
      hourly4[hourlyLA + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyKY + i])
    }

    /// Available heat from CSP after TES
    let hourlyLB = 1_594_320
    // MAX(0,J6-KZ6)
    for i in 0..<8760 {
      hourly4[hourlyLB + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyKZ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyLC = 1_603_080
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(KY6*Heater_eff+KZ6)*TES_aux_cons_perc+IF(OR(KO6=0,AND(KO6>0,KS6=0)),PB_stby_aux_cons+KP6*TES_aux_cons_perc,(KP6+KQ6+KR6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyLC + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyKY + i] * Heater_eff + hourly0[hourlyKZ + i]) * TES_aux_cons_perc
        + iff(
          or(hourly4[hourlyKO + i].isZero, and(hourly4[hourlyKO + i] > 0, hourly4[hourlyKS + i].isZero)),
          PB_stby_aux_cons + hourly4[hourlyKP + i] * TES_aux_cons_perc,
          (hourly4[hourlyKP + i] + hourly4[hourlyKQ + i] + hourly4[hourlyKR + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyLD = 1_611_840
    // MAX(0,-(L6+IF(KS6>0,KN6,0)-KY6-LC6))
    for i in 0..<8760 {
      hourly4[hourlyLD + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyKS + i] > 0, hourly4[hourlyKN + i], 0)
          - hourly4[hourlyKY + i] - hourly4[hourlyLC + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyLF = 1_620_600
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6),MIN(LB6+El_boiler_cap_ud*El_boiler_eff,(LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(LC6-LD6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-LB6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyLF + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]),
          min(
            hourly4[hourlyLB + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyLB + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyLG = 1_629_360
    // IF(AND(LF6>0,LF5=0,OR(LF6=0,LF7=0)),0,LF6)
    for i in 0..<8760 {
      hourly4[hourlyLG + i] = iff(
        and(
          hourly4[hourlyLF + i] > 0, hourly4[hourlyLF + i - 1].isZero,
          or(hourly4[hourlyLF + i].isZero, hourly4[hourlyLF + i].isZero)), 0, hourly4[hourlyLF + i])
    }

    /// Min harmonious net heat cons
    let hourlyLH = 1_638_120
    // LG6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyLH + i] =
        hourly4[hourlyLG + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyLI = 1_646_880
    // IF(AND(LG5<=0,LG6>0),LI5+1,IF(AND(LA6>0,BO6<>BO5,SUM(LG6:LG8)=0),LI5+1,LI5))
    for i in 0..<8760 {
      hourly4[hourlyLI + i] = iff(
        and(hourly4[hourlyLG + i - 1] <= 0, hourly4[hourlyLG + i] > 0),
        hourly4[hourlyLI + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyLA + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(LG + i)...].prefix()) = 0), hourly4[hourlyLI + i - 1] + 1,
          hourly4[hourlyLI + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyLJ = 1_655_640
    // IF(OR(LG6>0,KS6=0),0,MIN((KN6+LA6+(LB6+KR6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(LC6-LD6))/(C_overall_var_min_cons+C_overall_fix_stby_cons+IF(LG7=0,0,C_overall_stup_cons)+(C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(LH7=0,0,C_overall_heat_stup_cons))/El_boiler_eff)*(C_overall_var_min_cons+C_overall_fix_stby_cons+IF(LG7=0,0,C_overall_stup_cons)),C_overall_var_min_cons+C_overall_fix_stby_cons+IF(LG7=0,0,C_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyLJ + i] = iff(
        or(hourly4[hourlyLG + i] > 0, hourly4[hourlyKS + i].isZero), 0,
        min(
          (hourly4[hourlyKN + i] + hourly4[hourlyLA + i]
            + (hourly4[hourlyLB + i] + hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]))
            / (C_overall_var_min_cons + C_overall_fix_stby_cons
              + iff(hourly4[hourlyLG + i].isZero, 0, C_overall_stup_cons)
              + (C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyLH + i].isZero, 0, C_overall_heat_stup_cons)) / El_boiler_eff)
            * (C_overall_var_min_cons + C_overall_fix_stby_cons
              + iff(hourly4[hourlyLG + i].isZero, 0, C_overall_stup_cons)),
          C_overall_var_min_cons + C_overall_fix_stby_cons
            + iff(hourly4[hourlyLG + i].isZero, 0, C_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyLK = 1_664_400
    // IF(LJ6=0,0,MIN((KN6+LA6+(LB6+KR6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(LC6-LD6))/(C_overall_var_min_cons+C_overall_fix_stby_cons+IF(LG7=0,0,C_overall_stup_cons)+(C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(LH7=0,0,C_overall_heat_stup_cons))/El_boiler_eff)*(C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(LH7=0,0,C_overall_heat_stup_cons)),C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons+IF(LH7=0,0,C_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyLK + i] = iff(
        hourly4[hourlyLJ + i].isZero, 0,
        min(
          (hourly4[hourlyKN + i] + hourly4[hourlyLA + i]
            + (hourly4[hourlyLB + i] + hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]))
            / (C_overall_var_min_cons + C_overall_fix_stby_cons
              + iff(hourly4[hourlyLG + i].isZero, 0, C_overall_stup_cons)
              + (C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyLH + i].isZero, 0, C_overall_heat_stup_cons)) / El_boiler_eff)
            * (C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
              + iff(hourly4[hourlyLH + i].isZero, 0, C_overall_heat_stup_cons)),
          C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons
            + iff(hourly4[hourlyLH + i].isZero, 0, C_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlyLL = 1_673_160
    // MAX(0,IF(KS6>0,KN6,0)+LA6-(LC6-LD6)-LG6-LJ6-MAX(0,(LH6+LK6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0)-LB6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyLL + i] = max(
        0,
        iff(hourly4[hourlyKS + i] > 0, hourly4[hourlyKN + i], 0) + hourly4[hourlyLA + i]
          - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) - hourly4[hourlyLG + i]
          - hourly4[hourlyLJ + i]
          - max(
            0,
            (hourly4[hourlyLH + i] + hourly4[hourlyLK + i]
              - iff(
                hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyLB + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyLM = 1_681_920
    // MAX(0,LB6+IF(KS6=0,0,KR6/PB_Ratio_Heat_input_vs_output)-LH6-LK6)
    for i in 0..<8760 {
      hourly4[hourlyLM + i] = max(
        0,
        hourly4[hourlyLB + i]
          + iff(
            hourly4[hourlyKS + i].isZero, 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output)
          - hourly4[hourlyLH + i] - hourly4[hourlyLK + i])
    }

    /// Grid import necessary for min harm
    let hourlyLN = 1_690_680
    // MAX(0,-(IF(KS6>0,KN6,0)+LA6-(LC6-LD6)-LG6-LJ6-MAX(0,(LH6+LK6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0)-LB6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyLN + i] = max(
        0,
        -(iff(hourly4[hourlyKS + i] > 0, hourly4[hourlyKN + i], 0) + hourly4[hourlyLA + i]
          - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) - hourly4[hourlyLG + i]
          - hourly4[hourlyLJ + i]
          - max(
            0,
            (hourly4[hourlyLH + i] + hourly4[hourlyLK + i]
              - iff(
                hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyLB + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyLO = 1_699_440
    // Grid_import_max_ud-LN6
    for i in 0..<8760 { hourly4[hourlyLO + i] = Grid_import_max_ud - hourly4[hourlyLN + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyLP = 1_708_200
    // MIN(El_boiler_cap_ud,MAX(0,(LH6+LK6-LB6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyLP + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyLH + i] + hourly4[hourlyLK + i] - hourly4[hourlyLB + i]
            - iff(
              hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyLQ = 1_716_960
    // MAX(0,El_boiler_cap_ud-LP6)
    for i in 0..<8760 { hourly4[hourlyLQ + i] = max(0, El_boiler_cap_ud - hourly4[hourlyLP + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyLR = 1_725_720
    // MAX(0,1-LG6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyLR + i] =
        max(
          0,
          1 - hourly4[hourlyLG + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyLS = 1_734_480
    // MAX(0,1-LG6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyLS + i] =
        max(
          0,
          1 - hourly4[hourlyLG + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyLT = 1_743_240
    // MAX(0,1-LG6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyLT + i] =
        max(
          0,
          1 - hourly4[hourlyLG + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyLU = 1_752_000
    // MIN(BESS_chrg_max_cons,LL6)
    for i in 0..<8760 { hourly4[hourlyLU + i] = min(BESS_chrg_max_cons, hourly4[hourlyLL + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyLV = 1_760_760
    // MIN(Grid_export_max_ud,LL6)
    for i in 0..<8760 { hourly4[hourlyLV + i] = min(Grid_export_max_ud, hourly4[hourlyLL + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyLW = 1_769_520
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6),MIN(LB6+El_boiler_cap_ud*El_boiler_eff,(LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(LC6-LD6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-LB6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6),MIN(LB6+El_boiler_cap_ud*El_boiler_eff,(LA6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(LC6-LD6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(LC6-LD6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-LB6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyLW + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]),
          min(
            hourly4[hourlyLB + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyLB + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]),
          min(
            hourly4[hourlyLB + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyLA + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyLB + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyLX = 1_778_280
    // IF(AND(LW6>0,LW5=0,OR(LW6=0,LW7=0)),0,LW6)
    for i in 0..<8760 {
      hourly4[hourlyLX + i] = iff(
        and(
          hourly4[hourlyLW + i] > 0, hourly4[hourlyLW + i - 1].isZero,
          or(hourly4[hourlyLW + i].isZero, hourly4[hourlyLW + i].isZero)), 0, hourly4[hourlyLW + i])
    }

    /// max harmonious net heat cons
    let hourlyLY = 1_787_040
    // LX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyLY + i] =
        hourly4[hourlyLX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyLZ = 1_795_800
    // MAX(0,IF(KS6>0,KN6,0)+LA6-(LC6-LD6)-LX6-LJ6-MAX(0,(LY6+LK6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0)-LB6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyLZ + i] = max(
        0,
        iff(hourly4[hourlyKS + i] > 0, hourly4[hourlyKN + i], 0) + hourly4[hourlyLA + i]
          - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) - hourly4[hourlyLX + i]
          - hourly4[hourlyLJ + i]
          - max(
            0,
            (hourly4[hourlyLY + i] + hourly4[hourlyLK + i]
              - iff(
                hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyLB + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyMA = 1_804_560
    // MAX(0,LB6+IF(KS6=0,0,KR6/PB_Ratio_Heat_input_vs_output)-LY6-LK6)
    for i in 0..<8760 {
      hourly4[hourlyMA + i] = max(
        0,
        hourly4[hourlyLB + i]
          + iff(
            hourly4[hourlyKS + i].isZero, 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output)
          - hourly4[hourlyLY + i] - hourly4[hourlyLK + i])
    }

    /// Grid import necessary for max harm
    let hourlyMB = 1_813_320
    // MAX(0,-(IF(KS6>0,KN6,0)+LA6-(LC6-LD6)-LX6-LJ6-MAX(0,(LY6+LK6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0)-LB6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyMB + i] = max(
        0,
        -(iff(hourly4[hourlyKS + i] > 0, hourly4[hourlyKN + i], 0) + hourly4[hourlyLA + i]
          - (hourly4[hourlyLC + i] - hourly4[hourlyLD + i]) - hourly4[hourlyLX + i]
          - hourly4[hourlyLJ + i]
          - max(
            0,
            (hourly4[hourlyLY + i] + hourly4[hourlyLK + i]
              - iff(
                hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly4[hourlyLB + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyMC = 1_822_080
    // Grid_import_max_ud-MB6
    for i in 0..<8760 { hourly4[hourlyMC + i] = Grid_import_max_ud - hourly0[hourlyMB + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyMD = 1_830_840
    // MIN(El_boiler_cap_ud,MAX(0,(LY6+LK6-LB6-IF(KS6>0,KR6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyMD + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyLY + i] + hourly4[hourlyLK + i] - hourly4[hourlyLB + i]
            - iff(
              hourly4[hourlyKS + i] > 0, hourly4[hourlyKR + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyME = 1_839_600
    // MAX(0,El_boiler_cap_ud-MD6)
    for i in 0..<8760 { hourly4[hourlyME + i] = max(0, El_boiler_cap_ud - hourly0[hourlyMD + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyMF = 1_848_360
    // MAX(0,1-LX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyMF + i] =
        max(
          0,
          1 - hourly4[hourlyLX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyMG = 1_857_120
    // MAX(0,1-LX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyMG + i] =
        max(
          0,
          1 - hourly4[hourlyLX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyMH = 1_865_880
    // MAX(0,1-LX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyMH + i] =
        max(
          0,
          1 - hourly4[hourlyLX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyMI = 1_874_640
    // MIN(BESS_chrg_max_cons,LZ6)
    for i in 0..<8760 { hourly4[hourlyMI + i] = min(BESS_chrg_max_cons, hourly4[hourlyLZ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyMJ = 1_883_400
    // MIN(Grid_export_max_ud,LZ6)
    for i in 0..<8760 { hourly4[hourlyMJ + i] = min(Grid_export_max_ud, hourly4[hourlyLZ + i]) }

    /// Maximum night op perc considering tank sizes
    let hourlyML = 1_892_160
    // VLOOKUP(BO6,DailyCalc_1A3:CP367,COLUMN(DailyCalc_1CP3))
    for i in 0..<8760 {
      hourly4[hourlyML + i] = VLOOKUP(
        hourly1[hourlyBO + i], DailyCalc_1hourly_[(A + i)...].prefix(),
        COLUMN(DailyCalc_1hourly3[hourlyCP + i]))
    }

    /// Max net elec demand outside harm op period
    let hourlyMM = 1_900_920
    // IF(BM6>0,0,IF(C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+BK6+IF(BM7=0,0,C_overall_stup_cons)+MAX(0,C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(BM7=0,0,C_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyMM + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
            + hourly1[hourlyBK + i] + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons) + max(
              0,
              C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons)))
    }

    /// Optimized max net elec demand outside harm op period
    let hourlyMN = 1_909_680
    // IF(AND(MM7>0,MM6=0,MM5>0),MM5,MM6)
    for i in 0..<8760 {
      hourly4[hourlyMN + i] = iff(
        and(hourly4[hourlyMM + i] > 0, hourly4[hourlyMM + i].isZero, hourly4[hourlyMM + i - 1] > 0),
        hourly4[hourlyMM + i - 1], hourly4[hourlyMM + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyMO = 1_918_440
    // IF(MN6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(MN6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(MN6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,MN6+BK6-BP6))-PB_net_min_cap))+MAX(0,C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(MN6=0,MN7>0),MAX(0,IF(COUNTIF(MN1:MN6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyMO + i] = iff(
        hourly4[hourlyMN + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly4[hourlyMN + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly4[hourlyMN + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly4[hourlyMN + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
                - hourly1[hourlyBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly4[hourlyMN + i].isZero, hourly4[hourlyMN + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(MN + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding max PB net elec output
    let hourlyMP = 1_927_200
    // IF(MN6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,MN6+MO6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyMP + i] = iff(
        hourly4[hourlyMN + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly4[hourlyMN + i] + hourly4[hourlyMO + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding max PB gross elec output
    let hourlyMQ = 1_935_960
    // IF(MP6=0,0,MP6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MP6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyMQ + i] = iff(
        hourly4[hourlyMP + i].isZero, 0,
        hourly4[hourlyMP + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyMP + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyMR = 1_944_720
    // IF(AND(MQ6=0,MQ7>0),IF(COUNTIF(MQ1:MQ6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyMR + i] = iff(
        and(hourly4[hourlyMQ + i].isZero, hourly4[hourlyMQ + i] > 0),
        iff(
          countiff(hourly_[(MQ + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Max gross heat cons for ST
    let hourlyMS = 1_953_480
    // IF(MQ6=0,0,MQ6/PB_nom_gross_eff/POLY(MQ6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyMS + i] = iff(
        hourly4[hourlyMQ + i].isZero, 0,
        hourly4[hourlyMQ + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyMQ + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Max gross heat cons for extraction
    let hourlyMT = 1_962_240
    // IF(MS6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons),(MP6-MO6+BP6)/(C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(BM7=0,0,C_overall_stup_cons))*(C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(BM7=0,0,C_overall_heat_stup_cons)))-BQ6-MAX(0,MP6-MN6-MO6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyMT + i] = iff(
        hourly4[hourlyMS + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons),
              (hourly4[hourlyMP + i] - hourly4[hourlyMO + i] + hourly1[hourlyBP + i])
                / (C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_stup_cons))
                * (C_overall_var_heat_max_cons * hourly0[hourlyML + i]
                  + C_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, C_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly4[hourlyMP + i] - hourly4[hourlyMN + i] - hourly4[hourlyMO + i])
              * El_boiler_eff)))
    }

    /// TES energy available if above min op case
    let hourlyMU = 1_971_000
    // IF(KS6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,MR5:MR8763)+SUMIF(BO5:BO8763,"="BO6,MS5:MS8763)+SUMIF(BO5:BO8763,"="BO6,MT5:MT8763)))
    for i in 0..<8760 {
      hourly4[hourlyMU + i] = iff(
        hourly4[hourlyKS + i].isZero, 0,
        min(
          sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap,
          sum[i] + sum[i] + sum[i]))
    }

    /// Effective gross heat cons for ST
    let hourlyMV = 1_979_760
    // IF(MU6=0,0,(MU6-SUMIF(BO5:BO8763,"="BO6,MR5:MR8763))/(SUMIF(BO5:BO8763,"="BO6,MS5:MS8763)+SUMIF(BO5:BO8763,"="BO6,MT5:MT8763))*MS6)
    for i in 0..<8760 {
      hourly4[hourlyMV + i] = iff(
        hourly0[hourlyMU + i].isZero, 0,
        (hourly0[hourlyMU + i] - sum[i]) / (sum[i] + sum[i]) * hourly4[hourlyMS + i])
    }

    /// Effective PB gross elec output
    let hourlyMW = 1_988_520
    // IF(MV6=0,0,MV6*PB_nom_gross_eff*POLY(MV6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyMW + i] = iff(
        hourly4[hourlyMV + i].isZero, 0,
        hourly4[hourlyMV + i] * PB_nom_gross_eff
          * POLY(hourly4[hourlyMV + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourlyMX = 1_997_280
    // IF(MW6=0,0,MW6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MW6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyMX + i] = iff(
        hourly0[hourlyMW + i].isZero, 0,
        hourly0[hourlyMW + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyMW + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff)
          - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourlyMY = 2_006_040
    // IF(MU6=0,0,(MU6-SUMIF(BO5:BO8763,"="BO6,MR5:MR8763))/(SUMIF(BO5:BO8763,"="BO6,MS5:MS8763)+SUMIF(BO5:BO8763,"="BO6,MT5:MT8763))*MT6)
    for i in 0..<8760 {
      hourly4[hourlyMY + i] = iff(
        hourly0[hourlyMU + i].isZero, 0,
        (hourly0[hourlyMU + i] - sum[i]) / (sum[i] + sum[i]) * hourly0[hourlyMT + i])
    }

    /// TES energy to fulfil op case if above
    let hourlyMZ = 2_014_800
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,MR5:MR8763)+SUMIF(BO5:BO8763,"="BO6,MS5:MS8763)+SUMIF(BO5:BO8763,"="BO6,MT5:MT8763),MU6,SUMIF(BO5:BO8763,"="BO6,MR5:MR8763)+SUMIF(BO5:BO8763,"="BO6,MS5:MS8763)+SUMIF(BO5:BO8763,"="BO6,MT5:MT8763))
    for i in 0..<8760 {
      hourly4[hourlyMZ + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], hourly0[hourlyMU + i], sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyNA = 2_023_560
    // IF(MZ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-MZ6))
    for i in 0..<8760 {
      hourly4[hourlyNA + i] = iff(
        hourly0[hourlyMZ + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly0[hourlyMZ + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyNB = 2_032_320
    // IF(OR(AND(NA6>0,AY6>0,AY5=0),AND(NA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyNB + i] = iff(
        or(
          and(hourly4[hourlyNA + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyNA + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyNC = 2_041_080
    // MAX(0,NA6-SUMIF(BO5:BO8763,"="BO6,NB5:NB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyNC + i] = max(
        0, hourly4[hourlyNA + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyND = 2_049_840
    // IF(NA6=0,0,AY6-(NA6-NC6)/(SUMIF(BO5:BO8763,"="BO6,NB5:NB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*NB6)
    for i in 0..<8760 {
      hourly4[hourlyND + i] = iff(
        hourly4[hourlyNA + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyNA + i] - hourly4[hourlyNC + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyNB + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyNE = 2_058_600
    // IF(OR(ND6=0,NC6=0),0,MAX((AW6-ND6)/(NC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,ND5:ND8763,">0")),(J6-ND6*Heater_eff/Ratio_CSP_vs_Heater)/(NC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,ND5:ND8763,">0")))/SUMIF(BO5:BO8763,"="BO6,ND5:ND8763)*ND6)
    for i in 0..<8760 {
      hourly4[hourlyNE + i] = iff(
        or(hourly4[hourlyND + i].isZero, hourly4[hourlyNC + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly4[hourlyND + i])
            / (hourly4[hourlyNC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / ND_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly4[hourlyND + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyNC + i] / (1 + Ratio_CSP_vs_Heater) / ND_BOcountNonZero[i])) / sum[i]
          * hourly4[hourlyND + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyNF = 2_067_360
    // IF(MZ6=0,0,ND6-IF(NC6=0,0,NC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,NE5:NE8763)*NE6))
    for i in 0..<8760 {
      hourly4[hourlyNF + i] = iff(
        hourly0[hourlyMZ + i].isZero, 0,
        hourly4[hourlyND + i]
          - iff(
            hourly4[hourlyNC + i].isZero, 0,
            hourly4[hourlyNC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
              * hourly4[hourlyNE + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyNG = 2_076_120
    // MIN(J6,NF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyNG + i] = min(
        hourly0[hourlyJ + i], hourly4[hourlyNF + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyNH = 2_084_880
    // MAX(0,L6-NF6)
    for i in 0..<8760 {
      hourly4[hourlyNH + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyNF + i])
    }

    /// Available heat from CSP after TES
    let hourlyNI = 2_093_640
    // MAX(0,J6-NG6)
    for i in 0..<8760 {
      hourly4[hourlyNI + i] = max(0, hourly0[hourlyJ + i] - hourly4[hourlyNG + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyNJ = 2_102_400
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(NF6*Heater_eff+NG6)*TES_aux_cons_perc+IF(MX6=0,PB_stby_aux_cons+MR6*TES_aux_cons_perc,(MR6+MV6+MY6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyNJ + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyNF + i] * Heater_eff + hourly4[hourlyNG + i]) * TES_aux_cons_perc
        + iff(
          hourly4[hourlyMX + i].isZero, PB_stby_aux_cons + hourly4[hourlyMR + i] * TES_aux_cons_perc,
          (hourly4[hourlyMR + i] + hourly4[hourlyMV + i] + hourly0[hourlyMY + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyNK = 2_111_160
    // MAX(0,-(L6+IF(MZ6>0,MP6,0)-NF6-NJ6))
    for i in 0..<8760 {
      hourly4[hourlyNK + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly0[hourlyMZ + i] > 0, hourly4[hourlyMP + i], 0)
          - hourly4[hourlyNF + i] - hourly4[hourlyNJ + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyNM = 2_119_920
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6),MIN(NI6+El_boiler_cap_ud*El_boiler_eff,(NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(NJ6-NK6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-NI6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyNM + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]),
          min(
            hourly4[hourlyNI + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyNI + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyNN = 2_128_680
    // IF(AND(NM6>0,NM5=0,OR(NM6=0,NM7=0)),0,NM6)
    for i in 0..<8760 {
      hourly4[hourlyNN + i] = iff(
        and(
          hourly4[hourlyNM + i] > 0, hourly4[hourlyNM + i - 1].isZero,
          or(hourly4[hourlyNM + i].isZero, hourly4[hourlyNM + i].isZero)), 0, hourly4[hourlyNM + i])
    }

    /// Min harmonious net heat cons
    let hourlyNO = 2_137_440
    // NN6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyNO + i] =
        hourly4[hourlyNN + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyNP = 2_146_200
    // IF(AND(NN5<=0,NN6>0),NP5+1,IF(AND(NH6>0,BO6<>BO5,SUM(NN6:NN8)=0),NP5+1,NP5))
    for i in 0..<8760 {
      hourly4[hourlyNP + i] = iff(
        and(hourly4[hourlyNN + i - 1] <= 0, hourly4[hourlyNN + i] > 0),
        hourly4[hourlyNP + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyNH + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(NN + i)...].prefix()) = 0), hourly4[hourlyNP + i - 1] + 1,
          hourly4[hourlyNP + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyNQ = 2_154_960
    // IF(OR(NN6>0,MZ6=0),0,MIN((MX6+NH6+(NI6+MY6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(NJ6-NK6))/(C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(NN7=0,0,C_overall_stup_cons)+(C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(NO7=0,0,C_overall_heat_stup_cons))/El_boiler_eff)*(C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(NN7=0,0,C_overall_stup_cons)),C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(NN7=0,0,C_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyNQ + i] = iff(
        or(hourly4[hourlyNN + i] > 0, hourly0[hourlyMZ + i].isZero), 0,
        min(
          (hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
            + (hourly4[hourlyNI + i] + hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]))
            / (C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
              + iff(hourly4[hourlyNN + i].isZero, 0, C_overall_stup_cons)
              + (C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyNO + i].isZero, 0, C_overall_heat_stup_cons)) / El_boiler_eff)
            * (C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
              + iff(hourly4[hourlyNN + i].isZero, 0, C_overall_stup_cons)),
          C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
            + iff(hourly4[hourlyNN + i].isZero, 0, C_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyNR = 2_163_720
    // IF(NQ6=0,0,MIN((MX6+NH6+(NI6+MY6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(NJ6-NK6))/(C_overall_var_max_cons*ML6+C_overall_fix_stby_cons+IF(NN7=0,0,C_overall_stup_cons)+(C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(NO7=0,0,C_overall_heat_stup_cons))/El_boiler_eff)*(C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(NO7=0,0,C_overall_heat_stup_cons)),C_overall_var_heat_max_cons*ML6+C_overall_heat_fix_stby_cons+IF(NO7=0,0,C_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyNR + i] = iff(
        hourly4[hourlyNQ + i].isZero, 0,
        min(
          (hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
            + (hourly4[hourlyNI + i] + hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]))
            / (C_overall_var_max_cons * hourly0[hourlyML + i] + C_overall_fix_stby_cons
              + iff(hourly4[hourlyNN + i].isZero, 0, C_overall_stup_cons)
              + (C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
                + iff(hourly4[hourlyNO + i].isZero, 0, C_overall_heat_stup_cons)) / El_boiler_eff)
            * (C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
              + iff(hourly4[hourlyNO + i].isZero, 0, C_overall_heat_stup_cons)),
          C_overall_var_heat_max_cons * hourly0[hourlyML + i] + C_overall_heat_fix_stby_cons
            + iff(hourly4[hourlyNO + i].isZero, 0, C_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlyNS = 2_172_480
    // MAX(0,MX6+NH6-(NJ6-NK6)-NN6-NQ6-MAX(0,(NO6+NR6-MY6/PB_Ratio_Heat_input_vs_output-NI6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyNS + i] = max(
        0,
        hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
          - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) - hourly4[hourlyNN + i]
          - hourly4[hourlyNQ + i]
          - max(
            0,
            (hourly4[hourlyNO + i] + hourly4[hourlyNR + i] - hourly0[hourlyMY + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyNI + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyNT = 2_181_240
    // MAX(0,NI6+MY6/PB_Ratio_Heat_input_vs_output-NO6-NR6)
    for i in 0..<8760 {
      hourly4[hourlyNT + i] = max(
        0,
        hourly4[hourlyNI + i] + hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output
          - hourly4[hourlyNO + i] - hourly4[hourlyNR + i])
    }

    /// Grid import necessary for min harm
    let hourlyNU = 2_190_000
    // MAX(0,-(MX6+NH6-(NJ6-NK6)-NN6-NQ6-MAX(0,(NO6+NR6-MY6/PB_Ratio_Heat_input_vs_output-NI6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyNU + i] = max(
        0,
        -(hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
          - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) - hourly4[hourlyNN + i]
          - hourly4[hourlyNQ + i]
          - max(
            0,
            (hourly4[hourlyNO + i] + hourly4[hourlyNR + i] - hourly0[hourlyMY + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyNI + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyNV = 2_198_760
    // Grid_import_max_ud-NU6
    for i in 0..<8760 { hourly4[hourlyNV + i] = Grid_import_max_ud - hourly4[hourlyNU + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyNW = 2_207_520
    // MIN(El_boiler_cap_ud,MAX(0,(NO6+NR6-NI6-MY6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyNW + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyNO + i] + hourly4[hourlyNR + i] - hourly4[hourlyNI + i]
            - hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyNX = 2_216_280
    // MAX(0,El_boiler_cap_ud-NW6)
    for i in 0..<8760 { hourly4[hourlyNX + i] = max(0, El_boiler_cap_ud - hourly4[hourlyNW + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyNY = 2_225_040
    // MAX(0,1-NN6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyNY + i] =
        max(
          0,
          1 - hourly4[hourlyNN + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyNZ = 2_233_800
    // MAX(0,1-NN6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyNZ + i] =
        max(
          0,
          1 - hourly4[hourlyNN + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyOA = 2_242_560
    // MAX(0,1-NN6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyOA + i] =
        max(
          0,
          1 - hourly4[hourlyNN + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyOB = 2_251_320
    // MIN(BESS_chrg_max_cons,NS6)
    for i in 0..<8760 { hourly4[hourlyOB + i] = min(BESS_chrg_max_cons, hourly4[hourlyNS + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyOC = 2_260_080
    // MIN(Grid_export_max_ud,NS6)
    for i in 0..<8760 { hourly4[hourlyOC + i] = min(Grid_export_max_ud, hourly4[hourlyNS + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyOD = 2_268_840
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6),MIN(NI6+El_boiler_cap_ud*El_boiler_eff,(NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(NJ6-NK6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-NI6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6),MIN(NI6+El_boiler_cap_ud*El_boiler_eff,(NH6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(NJ6-NK6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(NJ6-NK6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-NI6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyOD + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]),
          min(
            hourly4[hourlyNI + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyNI + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]),
          min(
            hourly4[hourlyNI + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyNH + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly4[hourlyNI + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyOE = 2_277_600
    // IF(AND(OD6>0,OD5=0,OR(OD6=0,OD7=0)),0,OD6)
    for i in 0..<8760 {
      hourly4[hourlyOE + i] = iff(
        and(
          hourly0[hourlyOD + i] > 0, hourly0[hourlyOD + i - 1].isZero,
          or(hourly0[hourlyOD + i].isZero, hourly0[hourlyOD + i].isZero)), 0, hourly0[hourlyOD + i])
    }

    /// max harmonious net heat cons
    let hourlyOF = 2_286_360
    // OE6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyOF + i] =
        hourly0[hourlyOE + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyOG = 2_295_120
    // MAX(0,MX6+NH6-(NJ6-NK6)-OE6-NQ6-MAX(0,(OF6+NR6-MY6/PB_Ratio_Heat_input_vs_output-NI6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyOG + i] = max(
        0,
        hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
          - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) - hourly0[hourlyOE + i]
          - hourly4[hourlyNQ + i]
          - max(
            0,
            (hourly0[hourlyOF + i] + hourly4[hourlyNR + i] - hourly0[hourlyMY + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyNI + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyOH = 2_303_880
    // MAX(0,NI6+MY6/PB_Ratio_Heat_input_vs_output-OF6-NR6)
    for i in 0..<8760 {
      hourly4[hourlyOH + i] = max(
        0,
        hourly4[hourlyNI + i] + hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output
          - hourly0[hourlyOF + i] - hourly4[hourlyNR + i])
    }

    /// Grid import necessary for max harm
    let hourlyOI = 2_312_640
    // MAX(0,-(MX6+NH6-(NJ6-NK6)-OE6-NQ6-MAX(0,(OF6+NR6-MY6/PB_Ratio_Heat_input_vs_output-NI6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyOI + i] = max(
        0,
        -(hourly4[hourlyMX + i] + hourly4[hourlyNH + i]
          - (hourly4[hourlyNJ + i] - hourly4[hourlyNK + i]) - hourly0[hourlyOE + i]
          - hourly4[hourlyNQ + i]
          - max(
            0,
            (hourly0[hourlyOF + i] + hourly4[hourlyNR + i] - hourly0[hourlyMY + i]
              / PB_Ratio_Heat_input_vs_output - hourly4[hourlyNI + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyOJ = 2_321_400
    // Grid_import_max_ud-OI6
    for i in 0..<8760 { hourly4[hourlyOJ + i] = Grid_import_max_ud - hourly0[hourlyOI + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyOK = 2_330_160
    // MIN(El_boiler_cap_ud,MAX(0,(OF6+NR6-NI6-MY6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyOK + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyOF + i] + hourly4[hourlyNR + i] - hourly4[hourlyNI + i]
            - hourly0[hourlyMY + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyOL = 2_338_920
    // MAX(0,El_boiler_cap_ud-OK6)
    for i in 0..<8760 { hourly4[hourlyOL + i] = max(0, El_boiler_cap_ud - hourly4[hourlyOK + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyOM = 2_347_680
    // MAX(0,1-OE6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyOM + i] =
        max(
          0,
          1 - hourly0[hourlyOE + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyON = 2_356_440
    // MAX(0,1-OE6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyON + i] =
        max(
          0,
          1 - hourly0[hourlyOE + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyOO = 2_365_200
    // MAX(0,1-OE6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyOO + i] =
        max(
          0,
          1 - hourly4[hourlyOE + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyOP = 2_373_960
    // MIN(BESS_chrg_max_cons,OG6)
    for i in 0..<8760 { hourly4[hourlyOP + i] = min(BESS_chrg_max_cons, hourly0[hourlyOG + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyOQ = 2_382_720
    // MIN(Grid_export_max_ud,OG6)
    for i in 0..<8760 { hourly4[hourlyOQ + i] = min(Grid_export_max_ud, hourly0[hourlyOG + i]) }

    /// Min net elec demand to power block
    let hourlyOS = 2_391_480
    // IF(BM6>0,0,IF(D_overall_var_min_cons+D_overall_fix_stby_cons+BK6+IF(BM7=0,0,D_overall_stup_cons)+MAX(0,D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,D_overall_var_min_cons+D_overall_fix_stby_cons+IF(BM7=0,0,D_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyOS + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          D_overall_var_min_cons + D_overall_fix_stby_cons + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons) + max(
              0,
              D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          D_overall_var_min_cons + D_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons)))
    }

    /// Optimized min net elec demand to power block
    let hourlyOT = 2_400_240
    // IF(AND(OS7>0,OS6=0,OS5>0),OS5,OS6)
    for i in 0..<8760 {
      hourly4[hourlyOT + i] = iff(
        and(hourly0[hourlyOS + i] > 0, hourly0[hourlyOS + i].isZero, hourly0[hourlyOS + i - 1] > 0),
        hourly0[hourlyOS + i - 1], hourly0[hourlyOS + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyOU = 2_409_000
    // IF(OT6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(OT6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(OT6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,OT6+BK6-BP6))-PB_net_min_cap))+MAX(0,D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(OT6=0,OT7>0),MAX(0,IF(COUNTIF(OT1:OT6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyOU + i] = iff(
        hourly4[hourlyOT + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly4[hourlyOT + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly4[hourlyOT + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly4[hourlyOT + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0, D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons - hourly1[hourlyBQ + i]
            ) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly4[hourlyOT + i].isZero, hourly4[hourlyOT + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(OT + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourlyOV = 2_417_760
    // IF(OT6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,OT6+OU6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyOV + i] = iff(
        hourly4[hourlyOT + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly4[hourlyOT + i] + hourly4[hourlyOU + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding min PB gross elec output
    let hourlyOW = 2_426_520
    // IF(OV6=0,0,OV6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(OV6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyOW + i] = iff(
        hourly0[hourlyOV + i].isZero, 0,
        hourly0[hourlyOV + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyOV + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyOX = 2_435_280
    // IF(AND(OW6=0,OW7>0),IF(COUNTIF(OW1:OW6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyOX + i] = iff(
        and(hourly4[hourlyOW + i].isZero, hourly4[hourlyOW + i] > 0),
        iff(
          countiff(hourly_[(OW + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Min gross heat cons for ST
    let hourlyOY = 2_444_040
    // IF(OW6=0,0,OW6/PB_nom_gross_eff/POLY(OW6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyOY + i] = iff(
        hourly4[hourlyOW + i].isZero, 0,
        hourly4[hourlyOW + i] / PB_nom_gross_eff
          / POLY(hourly4[hourlyOW + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Min gross heat cons for extraction
    let hourlyOZ = 2_452_800
    // IF(OY6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons),(OV6-OU6+BP6)/(D_overall_var_min_cons+D_overall_fix_stby_cons+IF(BM7=0,0,D_overall_stup_cons))*(D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons)))-BQ6-MAX(0,OV6-OT6-OU6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyOZ + i] = iff(
        hourly0[hourlyOY + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons),
              (hourly0[hourlyOV + i] - hourly4[hourlyOU + i] + hourly1[hourlyBP + i])
                / (D_overall_var_min_cons + D_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons))
                * (D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly0[hourlyOV + i] - hourly4[hourlyOT + i] - hourly4[hourlyOU + i])
              * El_boiler_eff)))
    }

    /// TES energy needed to fulfil op case
    let hourlyPA = 2_461_560
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,OX5:OX8763)+SUMIF(BO5:BO8763,"="BO6,OY5:OY8763)+SUMIF(BO5:BO8763,"="BO6,OZ5:OZ8763),0,SUMIF(BO5:BO8763,"="BO6,OX5:OX8763)+SUMIF(BO5:BO8763,"="BO6,OY5:OY8763)+SUMIF(BO5:BO8763,"="BO6,OZ5:OZ8763))
    for i in 0..<8760 {
      hourly4[hourlyPA + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], 0, sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyPB = 2_470_320
    // IF(PA6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-PA6))
    for i in 0..<8760 {
      hourly4[hourlyPB + i] = iff(
        hourly4[hourlyPA + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyPA + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyPC = 2_479_080
    // IF(OR(AND(PB6>0,AY6>0,AY5=0),AND(PB6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyPC + i] = iff(
        or(
          and(hourly4[hourlyPB + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyPB + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyPD = 2_487_840
    // MAX(0,PB6-SUMIF(BO5:BO8763,"="BO6,PC5:PC8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyPD + i] = max(
        0, hourly4[hourlyPB + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyPE = 2_496_600
    // IF(PB6=0,0,AY6-(PB6-PD6)/(SUMIF(BO5:BO8763,"="BO6,PC5:PC8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*PC6)
    for i in 0..<8760 {
      hourly4[hourlyPE + i] = iff(
        hourly4[hourlyPB + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyPB + i] - hourly4[hourlyPD + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly0[hourlyPC + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyPF = 2_505_360
    // IF(OR(PE6=0,PD6=0),0,MAX((AW6-PE6)/(PD6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,PE5:PE8763,">0")),(J6-PE6*Heater_eff/Ratio_CSP_vs_Heater)/(PD6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,PE5:PE8763,">0")))/SUMIF(BO5:BO8763,"="BO6,PE5:PE8763)*PE6)
    for i in 0..<8760 {
      hourly4[hourlyPF + i] = iff(
        or(hourly0[hourlyPE + i].isZero, hourly4[hourlyPD + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly0[hourlyPE + i])
            / (hourly4[hourlyPD + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / PE_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly0[hourlyPE + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyPD + i] / (1 + Ratio_CSP_vs_Heater) / PE_BOcountNonZero[i])) / sum[i]
          * hourly0[hourlyPE + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyPG = 2_514_120
    // IF(PA6=0,0,PE6-IF(PD6=0,0,PD6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,PF5:PF8763)*PF6))
    for i in 0..<8760 {
      hourly4[hourlyPG + i] = iff(
        hourly4[hourlyPA + i].isZero, 0,
        hourly0[hourlyPE + i]
          - iff(
            hourly4[hourlyPD + i].isZero, 0,
            hourly4[hourlyPD + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
              * hourly4[hourlyPF + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyPH = 2_522_880
    // MIN(J6,PG6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyPH + i] = min(
        hourly0[hourlyJ + i], hourly0[hourlyPG + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyPI = 2_531_640
    // MAX(0,L6-PG6)
    for i in 0..<8760 {
      hourly4[hourlyPI + i] = max(0, hourly0[hourlyL + i] - hourly0[hourlyPG + i])
    }

    /// Available heat from CSP after TES
    let hourlyPJ = 2_540_400
    // MAX(0,J6-PH6)
    for i in 0..<8760 {
      hourly4[hourlyPJ + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyPH + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyPK = 2_549_160
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(PG6*Heater_eff+PH6)*TES_aux_cons_perc+IF(OR(OW6=0,AND(OW6>0,PA6=0)),PB_stby_aux_cons+OX6*TES_aux_cons_perc,(OX6+OY6+OZ6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyPK + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly0[hourlyPG + i] * Heater_eff + hourly0[hourlyPH + i]) * TES_aux_cons_perc
        + iff(
          or(hourly4[hourlyOW + i].isZero, and(hourly4[hourlyOW + i] > 0, hourly4[hourlyPA + i].isZero)),
          PB_stby_aux_cons + hourly0[hourlyOX + i] * TES_aux_cons_perc,
          (hourly0[hourlyOX + i] + hourly0[hourlyOY + i] + hourly0[hourlyOZ + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyPL = 2_557_920
    // MAX(0,-(L6+IF(PA6>0,OV6,0)-PG6-PK6))
    for i in 0..<8760 {
      hourly4[hourlyPL + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyPA + i] > 0, hourly0[hourlyOV + i], 0)
          - hourly0[hourlyPG + i] - hourly0[hourlyPK + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyPN = 2_566_680
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6),MIN(PJ6+El_boiler_cap_ud*El_boiler_eff,(PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(PK6-PL6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-PJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyPN + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]),
          min(
            hourly0[hourlyPJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyPJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyPO = 2_575_440
    // IF(AND(PN6>0,PN5=0,OR(PN6=0,PN7=0)),0,PN6)
    for i in 0..<8760 {
      hourly4[hourlyPO + i] = iff(
        and(
          hourly0[hourlyPN + i] > 0, hourly0[hourlyPN + i - 1].isZero,
          or(hourly0[hourlyPN + i].isZero, hourly0[hourlyPN + i].isZero)), 0, hourly0[hourlyPN + i])
    }

    /// Min harmonious net heat cons
    let hourlyPP = 2_584_200
    // PO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyPP + i] =
        hourly4[hourlyPO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyPQ = 2_592_960
    // IF(AND(PO5<=0,PO6>0),PQ5+1,IF(AND(PI6>0,BO6<>BO5,SUM(PO6:PO8)=0),PQ5+1,PQ5))
    for i in 0..<8760 {
      hourly4[hourlyPQ + i] = iff(
        and(hourly4[hourlyPO + i - 1] <= 0, hourly4[hourlyPO + i] > 0),
        hourly4[hourlyPQ + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyPI + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(PO + i)...].prefix()) = 0), hourly4[hourlyPQ + i - 1] + 1,
          hourly4[hourlyPQ + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyPR = 2_601_720
    // IF(OR(PO6>0,PA6=0),0,MIN((OV6+PI6+(PJ6+OZ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(PK6-PL6))/(D_overall_var_min_cons+D_overall_fix_stby_cons+IF(PO7=0,0,D_overall_stup_cons)+(D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(PP7=0,0,D_overall_heat_stup_cons))/El_boiler_eff)*(D_overall_var_min_cons+D_overall_fix_stby_cons+IF(PO7=0,0,D_overall_stup_cons)),D_overall_var_min_cons+D_overall_fix_stby_cons+IF(PO7=0,0,D_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyPR + i] = iff(
        or(hourly4[hourlyPO + i] > 0, hourly4[hourlyPA + i].isZero), 0,
        min(
          (hourly0[hourlyOV + i] + hourly4[hourlyPI + i]
            + (hourly0[hourlyPJ + i] + hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]))
            / (D_overall_var_min_cons + D_overall_fix_stby_cons
              + iff(hourly4[hourlyPO + i].isZero, 0, D_overall_stup_cons)
              + (D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyPP + i].isZero, 0, D_overall_heat_stup_cons)) / El_boiler_eff)
            * (D_overall_var_min_cons + D_overall_fix_stby_cons
              + iff(hourly4[hourlyPO + i].isZero, 0, D_overall_stup_cons)),
          D_overall_var_min_cons + D_overall_fix_stby_cons
            + iff(hourly4[hourlyPO + i].isZero, 0, D_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyPS = 2_610_480
    // IF(PR6=0,0,MIN((OV6+PI6+(PJ6+OZ6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(PK6-PL6))/(D_overall_var_min_cons+D_overall_fix_stby_cons+IF(PO7=0,0,D_overall_stup_cons)+(D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(PP7=0,0,D_overall_heat_stup_cons))/El_boiler_eff)*(D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(PP7=0,0,D_overall_heat_stup_cons)),D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons+IF(PP7=0,0,D_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyPS + i] = iff(
        hourly4[hourlyPR + i].isZero, 0,
        min(
          (hourly0[hourlyOV + i] + hourly4[hourlyPI + i]
            + (hourly0[hourlyPJ + i] + hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]))
            / (D_overall_var_min_cons + D_overall_fix_stby_cons
              + iff(hourly4[hourlyPO + i].isZero, 0, D_overall_stup_cons)
              + (D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyPP + i].isZero, 0, D_overall_heat_stup_cons)) / El_boiler_eff)
            * (D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
              + iff(hourly0[hourlyPP + i].isZero, 0, D_overall_heat_stup_cons)),
          D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons
            + iff(hourly0[hourlyPP + i].isZero, 0, D_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlyPT = 2_619_240
    // MAX(0,IF(PA6>0,OV6,0)+PI6-(PK6-PL6)-PO6-PR6-MAX(0,(PP6+PS6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0)-PJ6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyPT + i] = max(
        0,
        iff(hourly4[hourlyPA + i] > 0, hourly0[hourlyOV + i], 0) + hourly4[hourlyPI + i]
          - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) - hourly4[hourlyPO + i]
          - hourly4[hourlyPR + i]
          - max(
            0,
            (hourly0[hourlyPP + i] + hourly0[hourlyPS + i]
              - iff(
                hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly0[hourlyPJ + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyPU = 2_628_000
    // MAX(0,PJ6+IF(PA6=0,0,OZ6/PB_Ratio_Heat_input_vs_output)-PP6-PS6)
    for i in 0..<8760 {
      hourly4[hourlyPU + i] = max(
        0,
        hourly0[hourlyPJ + i]
          + iff(
            hourly4[hourlyPA + i].isZero, 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output)
          - hourly0[hourlyPP + i] - hourly0[hourlyPS + i])
    }

    /// Grid import necessary for min harm
    let hourlyPV = 2_636_760
    // MAX(0,-(IF(PA6>0,OV6,0)+PI6-(PK6-PL6)-PO6-PR6-MAX(0,(PP6+PS6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0)-PJ6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyPV + i] = max(
        0,
        -(iff(hourly4[hourlyPA + i] > 0, hourly0[hourlyOV + i], 0) + hourly4[hourlyPI + i]
          - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) - hourly4[hourlyPO + i]
          - hourly4[hourlyPR + i]
          - max(
            0,
            (hourly0[hourlyPP + i] + hourly0[hourlyPS + i]
              - iff(
                hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly0[hourlyPJ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyPW = 2_645_520
    // Grid_import_max_ud-PV6
    for i in 0..<8760 { hourly4[hourlyPW + i] = Grid_import_max_ud - hourly4[hourlyPV + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyPX = 2_654_280
    // MIN(El_boiler_cap_ud,MAX(0,(PP6+PS6-PJ6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyPX + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyPP + i] + hourly0[hourlyPS + i] - hourly0[hourlyPJ + i]
            - iff(
              hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyPY = 2_663_040
    // MAX(0,El_boiler_cap_ud-PX6)
    for i in 0..<8760 { hourly4[hourlyPY + i] = max(0, El_boiler_cap_ud - hourly0[hourlyPX + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyPZ = 2_671_800
    // MAX(0,1-PO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyPZ + i] =
        max(
          0,
          1 - hourly4[hourlyPO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyQA = 2_680_560
    // MAX(0,1-PO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyQA + i] =
        max(
          0,
          1 - hourly4[hourlyPO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyQB = 2_689_320
    // MAX(0,1-PO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyQB + i] =
        max(
          0,
          1 - hourly4[hourlyPO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyQC = 2_698_080
    // MIN(BESS_chrg_max_cons,PT6)
    for i in 0..<8760 { hourly4[hourlyQC + i] = min(BESS_chrg_max_cons, hourly0[hourlyPT + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyQD = 2_706_840
    // MIN(Grid_export_max_ud,PT6)
    for i in 0..<8760 { hourly4[hourlyQD + i] = min(Grid_export_max_ud, hourly0[hourlyPT + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyQE = 2_715_600
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6),MIN(PJ6+El_boiler_cap_ud*El_boiler_eff,(PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(PK6-PL6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-PJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6),MIN(PJ6+El_boiler_cap_ud*El_boiler_eff,(PI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(PK6-PL6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(PK6-PL6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-PJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyQE + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]),
          min(
            hourly0[hourlyPJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyPJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]),
          min(
            hourly0[hourlyPJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyPI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly0[hourlyPJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyQF = 2_724_360
    // IF(AND(QE6>0,QE5=0,OR(QE6=0,QE7=0)),0,QE6)
    for i in 0..<8760 {
      hourly4[hourlyQF + i] = iff(
        and(
          hourly4[hourlyQE + i] > 0, hourly4[hourlyQE + i - 1].isZero,
          or(hourly4[hourlyQE + i].isZero, hourly4[hourlyQE + i].isZero)), 0, hourly4[hourlyQE + i])
    }

    /// max harmonious net heat cons
    let hourlyQG = 2_733_120
    // QF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyQG + i] =
        hourly4[hourlyQF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyQH = 2_741_880
    // MAX(0,IF(PA6>0,OV6,0)+PI6-(PK6-PL6)-QF6-PR6-MAX(0,(QG6+PS6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0)-PJ6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyQH + i] = max(
        0,
        iff(hourly4[hourlyPA + i] > 0, hourly0[hourlyOV + i], 0) + hourly4[hourlyPI + i]
          - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) - hourly4[hourlyQF + i]
          - hourly4[hourlyPR + i]
          - max(
            0,
            (hourly0[hourlyQG + i] + hourly0[hourlyPS + i]
              - iff(
                hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly0[hourlyPJ + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyQI = 2_750_640
    // MAX(0,PJ6+IF(PA6=0,0,OZ6/PB_Ratio_Heat_input_vs_output)-QG6-PS6)
    for i in 0..<8760 {
      hourly4[hourlyQI + i] = max(
        0,
        hourly0[hourlyPJ + i]
          + iff(
            hourly4[hourlyPA + i].isZero, 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output)
          - hourly0[hourlyQG + i] - hourly0[hourlyPS + i])
    }

    /// Grid import necessary for max harm
    let hourlyQJ = 2_759_400
    // MAX(0,-(IF(PA6>0,OV6,0)+PI6-(PK6-PL6)-QF6-PR6-MAX(0,(QG6+PS6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0)-PJ6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyQJ + i] = max(
        0,
        -(iff(hourly4[hourlyPA + i] > 0, hourly0[hourlyOV + i], 0) + hourly4[hourlyPI + i]
          - (hourly0[hourlyPK + i] - hourly4[hourlyPL + i]) - hourly4[hourlyQF + i]
          - hourly4[hourlyPR + i]
          - max(
            0,
            (hourly0[hourlyQG + i] + hourly0[hourlyPS + i]
              - iff(
                hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0
              ) - hourly0[hourlyPJ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyQK = 2_768_160
    // Grid_import_max_ud-QJ6
    for i in 0..<8760 { hourly4[hourlyQK + i] = Grid_import_max_ud - hourly4[hourlyQJ + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyQL = 2_776_920
    // MIN(El_boiler_cap_ud,MAX(0,(QG6+PS6-PJ6-IF(PA6>0,OZ6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyQL + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyQG + i] + hourly0[hourlyPS + i] - hourly0[hourlyPJ + i]
            - iff(
              hourly4[hourlyPA + i] > 0, hourly0[hourlyOZ + i] / PB_Ratio_Heat_input_vs_output, 0))
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyQM = 2_785_680
    // MAX(0,El_boiler_cap_ud-QL6)
    for i in 0..<8760 { hourly4[hourlyQM + i] = max(0, El_boiler_cap_ud - hourly4[hourlyQL + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyQN = 2_794_440
    // MAX(0,1-QF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyQN + i] =
        max(
          0,
          1 - hourly4[hourlyQF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyQO = 2_803_200
    // MAX(0,1-QF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyQO + i] =
        max(
          0,
          1 - hourly4[hourlyQF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyQP = 2_811_960
    // MAX(0,1-QF6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyQP + i] =
        max(
          0,
          1 - hourly4[hourlyQF + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyQQ = 2_820_720
    // MIN(BESS_chrg_max_cons,QH6)
    for i in 0..<8760 { hourly4[hourlyQQ + i] = min(BESS_chrg_max_cons, hourly4[hourlyQH + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyQR = 2_829_480
    // MIN(Grid_export_max_ud,QH6)
    for i in 0..<8760 { hourly4[hourlyQR + i] = min(Grid_export_max_ud, hourly4[hourlyQH + i]) }

    var hourly5 = [Double]()

    /// Maximum night op perc considering tank sizes
    let hourlyQT = 0
    // VLOOKUP(BO6,DailyCalc_1A3:EB367,COLUMN(DailyCalc_1EB3))
    for i in 0..<8760 {
      hourly5[hourlyQT + i] = VLOOKUP(
        hourly1[hourlyBO + i], DailyCalc_1hourly_[(A + i)...].prefix(),
        COLUMN(DailyCalc_1hourly4[hourlyEB + i]))
    }

    /// Max net elec demand outside harm op period
    let hourlyQU = 8760
    // IF(BM6>0,0,IF(D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+BK6+IF(BM7=0,0,D_overall_stup_cons)+MAX(0,D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(BM7=0,0,D_overall_stup_cons)))
    for i in 0..<8760 {
      hourly5[hourlyQU + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
            + hourly1[hourlyBK + i] + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons) + max(
              0,
              D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons)
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i]
            - PB_stby_aux_cons, 0,
          D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
            + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons)))
    }

    /// Optimized max net elec demand outside harm op period
    let hourlyQV = 17520
    // IF(AND(QU7>0,QU6=0,QU5>0),QU5,QU6)
    for i in 0..<8760 {
      hourly5[hourlyQV + i] = iff(
        and(hourly5[hourlyQU + i] > 0, hourly5[hourlyQU + i].isZero, hourly5[hourlyQU + i - 1] > 0),
        hourly5[hourlyQU + i - 1], hourly5[hourlyQU + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyQW = 26280
    // IF(QV6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(QV6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(QV6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,QV6+BK6-BP6))-PB_net_min_cap))+MAX(0,D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(QV6=0,QV7>0),MAX(0,IF(COUNTIF(QV1:QV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly5[hourlyQW + i] = iff(
        hourly5[hourlyQV + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap,
              (1 + TES_aux_cons_perc)
                * (hourly5[hourlyQV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc)
                    * (hourly5[hourlyQV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(
                  PB_nom_net_cap,
                  max(0, hourly5[hourlyQV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
                - hourly1[hourlyBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly5[hourlyQV + i].isZero, hourly5[hourlyQV + i] > 0),
            max(
              0,
              iff(
                countiff(hourly_[(QV + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hourly1[hourlyBQ + i])
              * TES_aux_cons_perc, 0))
    }

    /// Corresponding max PB net elec output
    let hourlyQX = 35040
    // IF(QV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,QV6+QW6-BP6)))
    for i in 0..<8760 {
      hourly5[hourlyQX + i] = iff(
        hourly5[hourlyQV + i].isZero, 0,
        max(
          PB_net_min_cap,
          min(
            PB_nom_net_cap, hourly5[hourlyQV + i] + hourly5[hourlyQW + i] - hourly1[hourlyBP + i]))
      )
    }

    /// Corresponding max PB gross elec output
    let hourlyQY = 43800
    // IF(QX6=0,0,QX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(QX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly5[hourlyQY + i] = iff(
        hourly0[hourlyQX + i].isZero, 0,
        hourly0[hourlyQX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyQX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyQZ = 52560
    // IF(AND(QY6=0,QY7>0),IF(COUNTIF(QY1:QY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly5[hourlyQZ + i] = iff(
        and(hourly5[hourlyQY + i].isZero, hourly5[hourlyQY + i] > 0),
        iff(
          countiff(hourly_[(QY + i)...].prefix(), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Max gross heat cons for ST
    let hourlyRA = 61320
    // IF(QY6=0,0,QY6/PB_nom_gross_eff/POLY(QY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly5[hourlyRA + i] = iff(
        hourly5[hourlyQY + i].isZero, 0,
        hourly5[hourlyQY + i] / PB_nom_gross_eff
          / POLY(hourly5[hourlyQY + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Max gross heat cons for extraction
    let hourlyRB = 70080
    // IF(RA6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons),(QX6-QW6+BP6)/(D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(BM7=0,0,D_overall_stup_cons))*(D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(BM7=0,0,D_overall_heat_stup_cons)))-BQ6-MAX(0,QX6-QV6-QW6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly5[hourlyRB + i] = iff(
        hourly0[hourlyRA + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
                + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons),
              (hourly0[hourlyQX + i] - hourly5[hourlyQW + i] + hourly1[hourlyBP + i])
                / (D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_stup_cons))
                * (D_overall_var_heat_max_cons * hourly0[hourlyQT + i]
                  + D_overall_heat_fix_stby_cons
                  + iff(hourly1[hourlyBM + i].isZero, 0, D_overall_heat_stup_cons)))
              - hourly1[hourlyBQ + i] - max(
                0, hourly0[hourlyQX + i] - hourly5[hourlyQV + i] - hourly5[hourlyQW + i])
              * El_boiler_eff)))
    }

    /// TES energy available if above min op case
    let hourlyRC = 78840
    // IF(PA6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,QZ5:QZ8763)+SUMIF(BO5:BO8763,"="BO6,RA5:RA8763)+SUMIF(BO5:BO8763,"="BO6,RB5:RB8763)))
    for i in 0..<8760 {
      hourly5[hourlyRC + i] = iff(
        hourly4[hourlyPA + i].isZero, 0,
        min(
          sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap,
          sum[i] + sum[i] + sum[i]))
    }

    /// Effective gross heat cons for ST
    let hourlyRD = 87600
    // IF(RC6=0,0,(RC6-SUMIF(BO5:BO8763,"="BO6,QZ5:QZ8763))/(SUMIF(BO5:BO8763,"="BO6,RA5:RA8763)+SUMIF(BO5:BO8763,"="BO6,RB5:RB8763))*RA6)
    for i in 0..<8760 {
      hourly5[hourlyRD + i] = iff(
        hourly0[hourlyRC + i].isZero, 0,
        (hourly0[hourlyRC + i] - sum[i]) / (sum[i] + sum[i]) * hourly0[hourlyRA + i])
    }

    /// Effective PB gross elec output
    let hourlyRE = 96360
    // IF(RD6=0,0,RD6*PB_nom_gross_eff*POLY(RD6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      hourly5[hourlyRE + i] = iff(
        hourly0[hourlyRD + i].isZero, 0,
        hourly0[hourlyRD + i] * PB_nom_gross_eff
          * POLY(hourly0[hourlyRD + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourlyRF = 105120
    // IF(RE6=0,0,RE6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(RE6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      hourly5[hourlyRF + i] = iff(
        hourly0[hourlyRE + i].isZero, 0,
        hourly0[hourlyRE + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyRE + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff)
          - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourlyRG = 113880
    // IF(RC6=0,0,(RC6-SUMIF(BO5:BO8763,"="BO6,QZ5:QZ8763))/(SUMIF(BO5:BO8763,"="BO6,RA5:RA8763)+SUMIF(BO5:BO8763,"="BO6,RB5:RB8763))*RB6)
    for i in 0..<8760 {
      hourly5[hourlyRG + i] = iff(
        hourly0[hourlyRC + i].isZero, 0,
        (hourly0[hourlyRC + i] - sum[i]) / (sum[i] + sum[i]) * hourly0[hourlyRB + i])
    }

    /// TES energy to fulfil op case if above
    let hourlyRH = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,QZ5:QZ8763)+SUMIF(BO5:BO8763,"="BO6,RA5:RA8763)+SUMIF(BO5:BO8763,"="BO6,RB5:RB8763),RC6,SUMIF(BO5:BO8763,"="BO6,QZ5:QZ8763)+SUMIF(BO5:BO8763,"="BO6,RA5:RA8763)+SUMIF(BO5:BO8763,"="BO6,RB5:RB8763))
    for i in 0..<8760 {
      hourly5[hourlyRH + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
          + sum[i], hourly0[hourlyRC + i], sum[i] + sum[i] + sum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyRI = 131400
    // IF(RH6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-RH6))
    for i in 0..<8760 {
      hourly5[hourlyRI + i] = iff(
        hourly0[hourlyRH + i].isZero, 0,
        max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly0[hourlyRH + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyRJ = 140160
    // IF(OR(AND(RI6>0,AY6>0,AY5=0),AND(RI6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly5[hourlyRJ + i] = iff(
        or(
          and(hourly0[hourlyRI + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly0[hourlyRI + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)),
        hourly1[hourlyAY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyRK = 148920
    // MAX(0,RI6-SUMIF(BO5:BO8763,"="BO6,RJ5:RJ8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly5[hourlyRK + i] = max(
        0, hourly0[hourlyRI + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyRL = 157680
    // IF(RI6=0,0,AY6-(RI6-RK6)/(SUMIF(BO5:BO8763,"="BO6,RJ5:RJ8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*RJ6)
    for i in 0..<8760 {
      hourly5[hourlyRL + i] = iff(
        hourly0[hourlyRI + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly0[hourlyRI + i] - hourly0[hourlyRK + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly0[hourlyRJ + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyRM = 166440
    // IF(OR(RL6=0,RK6=0),0,MAX((AW6-RL6)/(RK6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,RL5:RL8763,">0")),(J6-RL6*Heater_eff/Ratio_CSP_vs_Heater)/(RK6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,RL5:RL8763,">0")))/SUMIF(BO5:BO8763,"="BO6,RL5:RL8763)*RL6)
    for i in 0..<8760 {
      hourly5[hourlyRM + i] = iff(
        or(hourly5[hourlyRL + i].isZero, hourly0[hourlyRK + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly5[hourlyRL + i])
            / (hourly0[hourlyRK + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / RL_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly5[hourlyRL + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly0[hourlyRK + i] / (1 + Ratio_CSP_vs_Heater) / RL_BOcountNonZero[i])) / sum[i]
          * hourly5[hourlyRL + i])
    }

    /// corrected max possible PV elec to TES
    let hourlyRN = 175200
    // IF(RH6=0,0,IF(RI6>0,RL6-IF(RK6=0,0,RK6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,RM5:RM8763)*RM6),AY6))
    for i in 0..<8760 {
      hourly5[hourlyRN + i] = iff(
        hourly0[hourlyRH + i].isZero, 0,
        iff(
          hourly0[hourlyRI + i] > 0,
          hourly5[hourlyRL + i]
            - iff(
              hourly0[hourlyRK + i].isZero, 0,
              hourly0[hourlyRK + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i]
                * hourly0[hourlyRM + i]), hourly1[hourlyAY + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyRO = 183960
    // MIN(J6,RN6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly5[hourlyRO + i] = min(
        hourly0[hourlyJ + i], hourly0[hourlyRN + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyRP = 192720
    // MAX(0,L6-RN6)
    for i in 0..<8760 {
      hourly5[hourlyRP + i] = max(0, hourly0[hourlyL + i] - hourly0[hourlyRN + i])
    }

    /// Available heat from CSP after TES
    let hourlyRQ = 201480
    // MAX(0,J6-RO6)
    for i in 0..<8760 {
      hourly5[hourlyRQ + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyRO + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyRR = 210240
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(RN6*Heater_eff+RO6)*TES_aux_cons_perc+IF(RF6=0,PB_stby_aux_cons+QZ6*TES_aux_cons_perc,(QZ6+RD6+RG6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly5[hourlyRR + i] =
        iff(
          hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc,
          CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly0[hourlyRN + i] * Heater_eff + hourly0[hourlyRO + i]) * TES_aux_cons_perc
        + iff(
          hourly0[hourlyRF + i].isZero, PB_stby_aux_cons + hourly5[hourlyQZ + i] * TES_aux_cons_perc,
          (hourly5[hourlyQZ + i] + hourly0[hourlyRD + i] + hourly0[hourlyRG + i])
            * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyRS = 219000
    // MAX(0,-(L6+RF6-RN6-RR6))
    for i in 0..<8760 {
      hourly5[hourlyRS + i] = max(
        0,
        -(hourly0[hourlyL + i] + hourly0[hourlyRF + i] - hourly0[hourlyRN + i]
          - hourly5[hourlyRR + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyRU = 227760
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6),MIN(RQ6+El_boiler_cap_ud*El_boiler_eff,(RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(RR6-RS6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-RQ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly5[hourlyRU + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]),
          min(
            hourly5[hourlyRQ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly5[hourlyRQ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyRV = 236520
    // IF(AND(RU6>0,RU5=0,OR(RU6=0,RU7=0)),0,RU6)
    for i in 0..<8760 {
      hourly5[hourlyRV + i] = iff(
        and(
          hourly0[hourlyRU + i] > 0, hourly0[hourlyRU + i - 1].isZero,
          or(hourly0[hourlyRU + i].isZero, hourly0[hourlyRU + i].isZero)), 0, hourly0[hourlyRU + i])
    }

    /// Min harmonious net heat cons
    let hourlyRW = 245280
    // RV6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly5[hourlyRW + i] =
        hourly0[hourlyRV + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyRX = 254040
    // IF(AND(RV5<=0,RV6>0),RX5+1,IF(AND(RP6>0,BO6<>BO5,SUM(RV6:RV8)=0),RX5+1,RX5))
    for i in 0..<8760 {
      hourly5[hourlyRX + i] = iff(
        and(hourly0[hourlyRV + i - 1] <= 0, hourly0[hourlyRV + i] > 0),
        hourly0[hourlyRX + i - 1] + 1,
        iff(
          and(
            hourly0[hourlyRP + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            SUM(hourly_[(RV + i)...].prefix()) = 0), hourly0[hourlyRX + i - 1] + 1,
          hourly0[hourlyRX + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyRY = 262800
    // IF(OR(RV6>0,RH6=0),0,MIN((RF6+RP6+(RQ6+RG6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(RR6-RS6))/(D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(RV7=0,0,D_overall_stup_cons)+(D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(RW7=0,0,D_overall_heat_stup_cons))/El_boiler_eff)*(D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(RV7=0,0,D_overall_stup_cons)),D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(RV7=0,0,D_overall_stup_cons)))
    for i in 0..<8760 {
      hourly5[hourlyRY + i] = iff(
        or(hourly0[hourlyRV + i] > 0, hourly0[hourlyRH + i].isZero), 0,
        min(
          (hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
            + (hourly5[hourlyRQ + i] + hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]))
            / (D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
              + iff(hourly0[hourlyRV + i].isZero, 0, D_overall_stup_cons)
              + (D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyRW + i].isZero, 0, D_overall_heat_stup_cons)) / El_boiler_eff)
            * (D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
              + iff(hourly0[hourlyRV + i].isZero, 0, D_overall_stup_cons)),
          D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
            + iff(hourly0[hourlyRV + i].isZero, 0, D_overall_stup_cons)))
    }

    /// heat cons due to op outside of harm op period
    let hourlyRZ = 271560
    // IF(RY6=0,0,MIN((RF6+RP6+(RQ6+RG6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(RR6-RS6))/(D_overall_var_max_cons*QT6+D_overall_fix_stby_cons+IF(RV7=0,0,D_overall_stup_cons)+(D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(RW7=0,0,D_overall_heat_stup_cons))/El_boiler_eff)*(D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(RW7=0,0,D_overall_heat_stup_cons)),D_overall_var_heat_max_cons*QT6+D_overall_heat_fix_stby_cons+IF(RW7=0,0,D_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly5[hourlyRZ + i] = iff(
        hourly0[hourlyRY + i].isZero, 0,
        min(
          (hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
            + (hourly5[hourlyRQ + i] + hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]))
            / (D_overall_var_max_cons * hourly0[hourlyQT + i] + D_overall_fix_stby_cons
              + iff(hourly0[hourlyRV + i].isZero, 0, D_overall_stup_cons)
              + (D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
                + iff(hourly0[hourlyRW + i].isZero, 0, D_overall_heat_stup_cons)) / El_boiler_eff)
            * (D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
              + iff(hourly0[hourlyRW + i].isZero, 0, D_overall_heat_stup_cons)),
          D_overall_var_heat_max_cons * hourly0[hourlyQT + i] + D_overall_heat_fix_stby_cons
            + iff(hourly0[hourlyRW + i].isZero, 0, D_overall_heat_stup_cons)))
    }

    /// Remaining el after min harmonious
    let hourlySA = 280320
    // MAX(0,RF6+RP6-(RR6-RS6)-RV6-RY6-MAX(0,(RW6+RZ6-RG6/PB_Ratio_Heat_input_vs_output-RQ6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly5[hourlySA + i] = max(
        0,
        hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
          - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) - hourly0[hourlyRV + i]
          - hourly0[hourlyRY + i]
          - max(
            0,
            (hourly0[hourlyRW + i] + hourly0[hourlyRZ + i] - hourly0[hourlyRG + i]
              / PB_Ratio_Heat_input_vs_output - hourly5[hourlyRQ + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlySB = 289080
    // MAX(0,RQ6+RG6/PB_Ratio_Heat_input_vs_output-RW6-RZ6)
    for i in 0..<8760 {
      hourly5[hourlySB + i] = max(
        0,
        hourly5[hourlyRQ + i] + hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output
          - hourly0[hourlyRW + i] - hourly0[hourlyRZ + i])
    }

    /// Grid import necessary for min harm
    let hourlySC = 297840
    // MAX(0,-(RF6+RP6-(RR6-RS6)-RV6-RY6-MAX(0,(RW6+RZ6-RG6/PB_Ratio_Heat_input_vs_output-RQ6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly5[hourlySC + i] = max(
        0,
        -(hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
          - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) - hourly0[hourlyRV + i]
          - hourly0[hourlyRY + i]
          - max(
            0,
            (hourly0[hourlyRW + i] + hourly0[hourlyRZ + i] - hourly0[hourlyRG + i]
              / PB_Ratio_Heat_input_vs_output - hourly5[hourlyRQ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlySD = 306600
    // Grid_import_max_ud-SC6
    for i in 0..<8760 { hourly5[hourlySD + i] = Grid_import_max_ud - hourly0[hourlySC + i] }

    /// El boiler op after min harmonious heat cons
    let hourlySE = 315360
    // MIN(El_boiler_cap_ud,MAX(0,(RW6+RZ6-RQ6-RG6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly5[hourlySE + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlyRW + i] + hourly0[hourlyRZ + i] - hourly5[hourlyRQ + i]
            - hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlySF = 324120
    // MAX(0,El_boiler_cap_ud-SE6)
    for i in 0..<8760 { hourly5[hourlySF + i] = max(0, El_boiler_cap_ud - hourly5[hourlySE + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlySG = 332880
    // MAX(0,1-RV6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly5[hourlySG + i] =
        max(
          0,
          1 - hourly0[hourlyRV + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlySH = 341640
    // MAX(0,1-RV6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly5[hourlySH + i] =
        max(
          0,
          1 - hourly0[hourlyRV + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlySI = 350400
    // MAX(0,1-RV6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly5[hourlySI + i] =
        max(
          0,
          1 - hourly0[hourlyRV + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlySJ = 359160
    // MIN(BESS_chrg_max_cons,SA6)
    for i in 0..<8760 { hourly5[hourlySJ + i] = min(BESS_chrg_max_cons, hourly5[hourlySA + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlySK = 367920
    // MIN(Grid_export_max_ud,SA6)
    for i in 0..<8760 { hourly5[hourlySK + i] = min(Grid_export_max_ud, hourly5[hourlySA + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlySL = 376680
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6),MIN(RQ6+El_boiler_cap_ud*El_boiler_eff,(RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(RR6-RS6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-RQ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6),MIN(RQ6+El_boiler_cap_ud*El_boiler_eff,(RP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(RR6-RS6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(RR6-RS6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-RQ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly5[hourlySL + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]),
          min(
            hourly5[hourlyRQ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly5[hourlyRQ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]),
          min(
            hourly5[hourlyRQ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly0[hourlyRP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons
                + (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) + max(
                  0,
                  (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons
                    - hourly5[hourlyRQ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlySM = 385440
    // IF(AND(SL6>0,SL5=0,OR(SL6=0,SL7=0)),0,SL6)
    for i in 0..<8760 {
      hourly5[hourlySM + i] = iff(
        and(
          hourly0[hourlySL + i] > 0, hourly0[hourlySL + i - 1].isZero,
          or(hourly0[hourlySL + i].isZero, hourly0[hourlySL + i].isZero)), 0, hourly0[hourlySL + i])
    }

    /// max harmonious net heat cons
    let hourlySN = 394200
    // SM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly5[hourlySN + i] =
        hourly5[hourlySM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlySO = 402960
    // MAX(0,RF6+RP6-(RR6-RS6)-SM6-RY6-MAX(0,(SN6+RZ6-RG6/PB_Ratio_Heat_input_vs_output-RQ6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly5[hourlySO + i] = max(
        0,
        hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
          - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) - hourly5[hourlySM + i]
          - hourly0[hourlyRY + i]
          - max(
            0,
            (hourly0[hourlySN + i] + hourly0[hourlyRZ + i] - hourly0[hourlyRG + i]
              / PB_Ratio_Heat_input_vs_output - hourly5[hourlyRQ + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlySP = 411720
    // MAX(0,RQ6+RG6/PB_Ratio_Heat_input_vs_output-SN6-RZ6)
    for i in 0..<8760 {
      hourly5[hourlySP + i] = max(
        0,
        hourly5[hourlyRQ + i] + hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output
          - hourly0[hourlySN + i] - hourly0[hourlyRZ + i])
    }

    /// Grid import necessary for max harm
    let hourlySQ = 420480
    // MAX(0,-(RF6+RP6-(RR6-RS6)-SM6-RY6-MAX(0,(SN6+RZ6-RG6/PB_Ratio_Heat_input_vs_output-RQ6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly5[hourlySQ + i] = max(
        0,
        -(hourly0[hourlyRF + i] + hourly0[hourlyRP + i]
          - (hourly5[hourlyRR + i] - hourly5[hourlyRS + i]) - hourly5[hourlySM + i]
          - hourly0[hourlyRY + i]
          - max(
            0,
            (hourly0[hourlySN + i] + hourly0[hourlyRZ + i] - hourly0[hourlyRG + i]
              / PB_Ratio_Heat_input_vs_output - hourly5[hourlyRQ + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlySR = 429240
    // Grid_import_max_ud-SQ6
    for i in 0..<8760 { hourly5[hourlySR + i] = Grid_import_max_ud - hourly0[hourlySQ + i] }

    /// El boiler op after max harmonious heat cons
    let hourlySS = 438000
    // MIN(El_boiler_cap_ud,MAX(0,(SN6+RZ6-RQ6-RG6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly5[hourlySS + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly0[hourlySN + i] + hourly0[hourlyRZ + i] - hourly5[hourlyRQ + i]
            - hourly0[hourlyRG + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyST = 446760
    // MAX(0,El_boiler_cap_ud-SS6)
    for i in 0..<8760 { hourly5[hourlyST + i] = max(0, El_boiler_cap_ud - hourly5[hourlySS + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlySU = 455520
    // MAX(0,1-SM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly5[hourlySU + i] =
        max(
          0,
          1 - hourly5[hourlySM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlySV = 464280
    // MAX(0,1-SM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly5[hourlySV + i] =
        max(
          0,
          1 - hourly5[hourlySM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlySW = 473040
    // MAX(0,1-SM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly5[hourlySW + i] =
        max(
          0,
          1 - hourly5[hourlySM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlySX = 481800
    // MIN(BESS_chrg_max_cons,SO6)
    for i in 0..<8760 { hourly5[hourlySX + i] = min(BESS_chrg_max_cons, hourly0[hourlySO + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlySY = 490560
    // MIN(Grid_export_max_ud,SO6)
    for i in 0..<8760 { hourly5[hourlySY + i] = min(Grid_export_max_ud, hourly0[hourlySO + i]) }
    */
  }  
}
