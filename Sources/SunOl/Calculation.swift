extension TunOl {
  mutating func hourly0() -> [Double] {
    var hourly0 = [Double](repeating: 0, count: 341_640)

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
            hourly0[hourlyK + i] / PV_DC_cap_ud > 0, hourly0[hourlyK + i] * POLY(hourly0[hourlyK + i] / PV_DC_cap_ud, LL_Coeff),
            0)))
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
        iff(hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + PB_stby_aux_cons
    }

    /// Available PV power MWel
    let hourlyP = 70080
    // MAX(0,L6-O6)
    for i in 0..<8760 { hourly0[hourlyP + i] = max(0, hourly0[hourlyL + i] - hourly0[hourlyO + i]) }

    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let hourlyQ = 78840
    // MAX(0,O6-P6)
    for i in 0..<8760 { hourly0[hourlyQ + i] = max(0, hourly0[hourlyO + i] - hourly0[hourlyP + i]) }

    /// Min harmonious net elec cons
    let hourlyR = 87600
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      let grid: Double = (hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
        / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
          0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly0[hourlyJ + i])) / El_boiler_eff)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
      hourly0[hourlyR + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff,
           grid)
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons
            , 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyS = 96360
    // IF(AND(R6>0,R5=0,OR(R6=0,R7=0)),0,R6)
    for i in 0..<8760 {
      hourly0[hourlyS + i] = iff(
        and(
          hourly0[hourlyR + i] > 0, hourly0[hourlyR + i - 1].isZero, or(hourly0[hourlyR + i].isZero, hourly0[hourlyR + i].isZero)
        ), 0, hourly0[hourlyR + i])
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
        and(hourly0[hourlyS + i - 1] <= 0, hourly0[hourlyS + i] > 0), hourly0[hourlyU + i - 1] + 1, hourly0[hourlyU + i - 1])
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
    for i in 0..<8760 { hourly0[hourlyW + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyT + i]) }

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
    for i in 0..<8760 { hourly0[hourlyZ + i] = max(0, (hourly0[hourlyT + i] - hourly0[hourlyJ + i]) / El_boiler_eff) }

    /// Remaining el boiler cap after min harm heat cons
    let hourlyAA = 166440
    // MAX(0,El_boiler_cap_ud-Z6)
    for i in 0..<8760 { hourly0[hourlyAA + i] = max(0, El_boiler_cap_ud - hourly0[hourlyZ + i]) }

    /// Remaining MethSynt cap after min harm cons
    let hourlyAB = 175200
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAB + i] =
        max(0, 1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethSynt_harmonious_max_perc)
        * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harm cons
    let hourlyAC = 183960
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAC + i] =
        max(0, 1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * CCU_harmonious_max_perc)
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harm cons
    let hourlyAD = 192720
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly0[hourlyAD + i] =
        max(0, 1 - hourly0[hourlyS + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * EY_harmonious_max_perc)
        * EY_Hydrogen_nom_prod
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
      let grid: Double = (hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
        / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
          0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly0[hourlyJ + i])) / El_boiler_eff)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
      hourly0[hourlyAG + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff, grid)
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly0[hourlyP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hourly0[hourlyJ + i] + El_boiler_cap_ud * El_boiler_eff, grid)
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
    for i in 0..<8760 { hourly0[hourlyAK + i] = max(0, hourly0[hourlyJ + i] - hourly0[hourlyAI + i]) }

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
    for i in 0..<8760 { hourly0[hourlyAN + i] = max(0, (hourly0[hourlyAI + i] - hourly0[hourlyJ + i]) / El_boiler_eff) }

    /// Remaining el boiler cap after max harm heat cons
    let hourlyAO = 289080
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 0..<8760 { hourly0[hourlyAO + i] = max(0, El_boiler_cap_ud - hourly0[hourlyAN + i]) }

    /// Remaining MethSynt cap after max harm cons
    let hourlyAP = 297840
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAP + i] =
        max(0, 1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethSynt_harmonious_max_perc)
        * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harm cons
    let hourlyAQ = 306600
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly0[hourlyAQ + i] =
        max(0, 1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * CCU_harmonious_max_perc)
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harm cons
    let hourlyAR = 315360
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly0[hourlyAR + i] =
        max(0, 1 - hourly0[hourlyAH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * EY_harmonious_max_perc)
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harm cons
    let hourlyAS = 324120
    // MIN(BESS_chrg_max_cons,AJ6)
    for i in 0..<8760 { hourly0[hourlyAS + i] = min(BESS_chrg_max_cons, hourly0[hourlyAJ + i]) }

    /// Max grid export after max harm cons
    let hourlyAT = 332880
    // MIN(Grid_export_max_ud,AJ6)
    for i in 0..<8760 { hourly0[hourlyAT + i] = min(Grid_export_max_ud, hourly0[hourlyAJ + i]) }
    return hourly0
  }

  mutating func hourly1(hourly0: [Double]) -> [Double] {
    let hourlyJ = 26280
    let hourlyL = 43800
    let hourlyM = 52560
    var hourly1 = [Double](repeating: 0, count: 210_240)

    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }

    /// Aux elec for CSP SF and PV Plant MWel
    let hourlyAV = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 0..<8760 {
      hourly1[hourlyAV + i] =
        iff(hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
    }

    /// Available PV power MWel
    let hourlyAW = 8760
    // MAX(0,L6-AV6)
    for i in 0..<8760 { hourly1[hourlyAW + i] = max(0, hourly0[hourlyL + i] - hourly1[hourlyAV + i]) }

    /// Not covered aux elec for CSP SF and PV Plant MWel
    let hourlyAX = 17520
    // MAX(0,AV6-AW6)
    for i in 0..<8760 { hourly1[hourlyAX + i] = max(0, hourly1[hourlyAV + i] - hourly1[hourlyAW + i]) }

    /// Max possible PV elec to TES (considering TES chrg aux)
    let hourlyAY = 26280
    // MAX(0,MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc),Heater_cap_ud,J6*Ratio_CSP_vs_Heater/Heater_eff))
    for i in 0..<8760 {
      hourly1[hourlyAY + i] = max(
        0,
        min(
          hourly1[hourlyAW + i] * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc), Heater_cap_ud,
          hourly0[hourlyJ + i] * Ratio_CSP_vs_Heater / Heater_eff))
    }

    let AYsum = hourly1.sum(hours: daysD, condition: hourlyAY)

    /// Maximum TES energy per PV day
    let hourlyAZ = 35040
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 { hourly1[hourlyAZ + i] = min(TES_thermal_cap, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// Surplus energy due to TES size limit
    let hourlyBA = 43800
    // MAX(0,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap)
    for i in 0..<8760 { hourly1[hourlyBA + i] = max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap) }

    /// Peripherial PV hour PV to heater
    let hourlyBB = 52560
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly1[hourlyBB + i] = iff(
        or(
          and(hourly1[hourlyBA + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly1[hourlyBA + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)), hourly1[hourlyAY + i], 0)
    }

    let BBsum = hourly1.sum(hours: daysD, condition: hourlyBB)

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyBC = 61320
    // MAX(0,BA6-SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly1[hourlyBC + i] = max(0, hourly1[hourlyBA + i] - BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
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
            (hourly1[hourlyBA + i] - hourly1[hourlyBC + i]) / (BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
              * hourly1[hourlyBB + i]))
    }
    let BDcountNonZero = hourly1.count(hours: daysD, range: hourlyBD, predicate: { $0 > 0 })
    let BDsum = hourly1.sum(hours: daysD, condition: hourlyBD)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyBE = 78840
    // IF(OR(BD6=0,BC6=0),0,MAX((AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(D5:D8763,"="D6,BD4:BD8762,">0")),(J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(D5:D8763,"="D6,BD5:BD8763,">0")))/SUMIF(D5:D8763,"="D6,BD5:BD8763)*BD6)
    for i in 0..<8760 {
      hourly1[hourlyBE + i] = iff(
        or(hourly1[hourlyBD + i].isZero, hourly1[hourlyBC + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly1[hourlyBD + i])
            / (hourly1[hourlyBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BDcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly1[hourlyBD + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly1[hourlyBC + i] / (1 + Ratio_CSP_vs_Heater) / BDcountNonZero[i])) / BDsum[i] * hourly1[hourlyBD + i])
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
            hourly1[hourlyBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i] * hourly1[hourlyBE + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyBG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly1[hourlyBG + i] = min(hourly0[hourlyJ + i], hourly1[hourlyBF + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourlyBH = 105120
    // AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc
    for i in 0..<8760 {
      hourly1[hourlyBH + i] =
        hourly1[hourlyAX + i] + (hourly1[hourlyBF + i] * Heater_eff + hourly1[hourlyBG + i]) * TES_aux_cons_perc
    }

    /// Remaining PV after TES chrg
    let hourlyBI = 113880
    // MAX(0,AW6-BF6-BH6)
    for i in 0..<8760 { hourly1[hourlyBI + i] = max(0, hourly1[hourlyAW + i] - hourly1[hourlyBF + i] - hourly1[hourlyBH + i]) }

    /// Remaining CSP heat after TES
    let hourlyBJ = 122640
    // J6-BG6
    for i in 0..<8760 { hourly1[hourlyBJ + i] = hourly0[hourlyJ + i] - hourly1[hourlyBG + i] }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourlyBK = 131400
    // MAX(0,-(AW6-BF6-BH6))
    for i in 0..<8760 {
      hourly1[hourlyBK + i] = max(0, -(hourly1[hourlyAW + i] - hourly1[hourlyBF + i] - hourly1[hourlyBH + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyBL = 140160
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons,MIN(BJ6+El_boiler_cap_ud*El_boiler_eff,(BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons)/(Overall_harmonious_var_max_cons+Overall_fix_cons+PB_stby_aux_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-BJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly1[hourlyBL + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly1[hourlyBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons,
          min(
            hourly1[hourlyBJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly1[hourlyBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + PB_stby_aux_cons + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly1[hourlyBJ + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
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
        and(hourly1[hourlyBM + i - 1] <= 0, hourly1[hourlyBM + i] > 0), hourly1[hourlyBO + i - 1] + 1,
        iff(
          and(
            hourly1[hourlyBI + i - 1] <= 0, hourly1[hourlyBI + i] > 0,
            countiff(hourly1[(hourlyBM + i)...].prefix(8760), { $0.isZero }) == 10,
            countiff(hourly1[(hourlyBI + i)...].prefix(8760), { !$0.isZero }) > 5), hourly1[hourlyBO + i - 1] + 1,
          hourly1[hourlyBO + i - 1]))
    }
    // let daysBO: [[Int]] = hourly1[hourlyBO..<(hourlyBO + 8760)].indices.chunked(by: {hourly1[$0] == hourly1[$1]}).map { $0.map { $0 } }
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
    for i in 0..<8760 { hourly1[hourlyBQ + i] = max(0, hourly1[hourlyBJ + i] - hourly1[hourlyBN + i]) }

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
    return hourly1
  }

  mutating func hourly2(hourly0: [Double], hourly1: [Double]) -> [Double] {
    let hourlyJ = 26280
    let hourlyL = 43800
    let hourlyM = 52560
    let hourlyAW = 8760
    let hourlyBK = 131400
    let hourlyBM = 148920
    let hourlyBO = 166440
    let hourlyBP = 175200
    let hourlyBQ = 183960

    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }
    let daysBO: [[Int]] = hourly1[hourlyBO..<(hourlyBO + 8760)].indices.chunked(by: { hourly1[$0] == hourly1[$1] })
      .map { $0.map { $0 - hourlyBO } }
    
    let hourlyAY = 26280
    let AYsum = hourly1.sum(hours: daysD, condition: hourlyAY)
    var hourly2 = [Double]()
    let j = 0
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
                + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j]) - hourly1[hourlyBQ + i]) / El_boiler_eff
            < hourly1[hourlyBP + i] - PB_stby_aux_cons, 0,
          overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j])))
    }

    /// Optimized min net elec demand to power block
    let hourlyBV = 8760
    // IF(AND(BU7>0,BU6=0,BU5>0),BU5,BU6)
    for i in 0..<8760 {
      hourly2[hourlyBV + i] = iff(
        and(hourly2[hourlyBU + i] > 0, hourly2[hourlyBU + i].isZero, hourly2[hourlyBU + i - 1] > 0), hourly2[hourlyBU + i - 1],
        hourly2[hourlyBU + i])
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
              PB_net_min_cap, (1 + TES_aux_cons_perc) * (hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc) * (hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(0, hourly2[hourlyBV + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(0, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - hourly1[hourlyBQ + i])
            * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly2[hourlyBV + i].isZero, hourly2[hourlyBV + i] > 0),
            max(
              0,
              iff(
                countiff(hourly2[(hourlyBV + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
                PB_hot_start_heat_req) - hourly1[hourlyBQ + i]) * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourlyBX = 26280
    // IF(BV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-BP6)))
    for i in 0..<8760 {
      hourly2[hourlyBX + i] = iff(
        hourly2[hourlyBV + i].isZero, 0,
        max(PB_net_min_cap, min(PB_nom_net_cap, hourly2[hourlyBV + i] + hourly2[hourlyBW + i] - hourly1[hourlyBP + i])))
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
          countiff(hourly2[(hourlyBY + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
          PB_hot_start_heat_req), 0)
    }
    let BZsum = hourly2.sum(hours: daysBO, condition: hourlyBZ)
    /// Min gross heat cons for ST
    let hourlyCA = 52560
    // IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly2[hourlyCA + i] = iff(
        hourly2[hourlyBY + i].isZero, 0,
        hourly2[hourlyBY + i] / PB_nom_gross_eff / POLY(hourly2[hourlyBY + i] / PB_nom_gross_cap_ud, el_Coeff))
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
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j]))) - hourly1[hourlyBQ + i] - max(
                0, hourly2[hourlyBX + i] - hourly2[hourlyBV + i] - hourly2[hourlyBW + i]) * El_boiler_eff)))
    }
    let CBsum = hourly2.sum(hours: daysBO, condition: hourlyCB)
    /// TES energy needed to fulfil op case
    let hourlyCC = 70080
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763),0,
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763))
    for i in 0..<8760 {
      hourly2[hourlyCC + i] = iff(
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < BZsum[i] + CAsum[i] + CBsum[i], 0,
        BZsum[i] + CAsum[i] + CBsum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyCD = 78840
    // IF(CC6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6))
    for i in 0..<8760 {
      hourly2[hourlyCD + i] = iff(
        hourly2[hourlyCC + i].isZero, 0, max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly2[hourlyCC + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyCE = 87600
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly2[hourlyCE + i] = iff(
        or(
          and(hourly2[hourlyCD + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly2[hourlyCD + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)), hourly1[hourlyAY + i], 0)
    }
    let CEsum = hourly2.sum(hours: daysBO, condition: hourlyCE)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyCF = 96360
    // MAX(0,CD6-SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly2[hourlyCF + i] = max(0, hourly2[hourlyCD + i] - CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
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

    let CG_BOcountNonZero = hourly2.count(hours: daysBO, range: hourlyCG, predicate: {$0>0})
    let CGsum = hourly2.sum(days: daysBO, range: hourlyCG)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyCH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX((AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")),(J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")))/SUMIF(BO5:BO8763,"="BO6,CG5:CG8763)*CG6)
    for i in 0..<8760 {
      hourly2[hourlyCH + i] = iff(
        or(hourly2[hourlyCG + i].isZero, hourly2[hourlyCF + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly2[hourlyCG + i])
            / (hourly2[hourlyCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / CG_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly2[hourlyCG + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly2[hourlyCF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i])) / CGsum[i]
          * hourly2[hourlyCG + i])
    }
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
            hourly2[hourlyCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i] * hourly2[hourlyCH + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyCJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly2[hourlyCJ + i] = min(hourly0[hourlyJ + i], hourly2[hourlyCI + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyCK = 140160
    // MAX(0,L6-CI6)
    for i in 0..<8760 { hourly2[hourlyCK + i] = max(0, hourly0[hourlyL + i] - hourly2[hourlyCI + i]) }

    /// Available heat from CSP after TES
    let hourlyCL = 148920
    // MAX(0,J6-CJ6)
    for i in 0..<8760 { hourly2[hourlyCL + i] = max(0, hourly0[hourlyJ + i] - hourly2[hourlyCJ + i]) }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyCM = 157680
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(BY6=0,AND(BY6>0,CC6=0)),PB_stby_aux_cons+BZ6*TES_aux_cons_perc,(BZ6+CA6+CB6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly2[hourlyCM + i] =
        iff(hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly2[hourlyCI + i] * Heater_eff + hourly2[hourlyCJ + i]) * TES_aux_cons_perc
        + iff(
          or(hourly2[hourlyBY + i].isZero, and(hourly2[hourlyBY + i] > 0, hourly2[hourlyCC + i].isZero)),
          PB_stby_aux_cons + hourly2[hourlyBZ + i] * TES_aux_cons_perc,
          (hourly2[hourlyBZ + i] + hourly2[hourlyCA + i] + hourly2[hourlyCB + i]) * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyCN = 166440
    // MAX(0,-(L6+IF(CC6>0,BX6,0)-CI6-CM6))
    for i in 0..<8760 {
      hourly2[hourlyCN + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) - hourly2[hourlyCI + i]
          - hourly2[hourlyCM + i]))
    }
    return hourly2
  }
  mutating func hourly3(hourly0: [Double], hourly1: [Double], hourly2: [Double]) -> [Double] {
    let j = 0
    let hourlyBO = 166440
    let hourlyBX = 26280
    let hourlyCB = 61320
    let hourlyCC = 70080
    let hourlyCK = 140160
    let hourlyCL = 148920
    let hourlyCM = 157680
    let hourlyCN = 166440
    var hourly3 = [Double](repeating: 0, count: 271_560)

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
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly2[hourlyCL + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
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
        and(hourly3[hourlyCQ + i - 1] <= 0, hourly3[hourlyCQ + i] > 0), hourly3[hourlyCS + i - 1] + 1,
        iff(
          and(
            hourly2[hourlyCK + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            sum(hourly2[(hourlyCQ + i)...].prefix(3)) == 0), hourly3[hourlyCS + i - 1] + 1, hourly3[hourlyCS + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyCT = 35040
    // IF(OR(CQ6>0,CC6=0),0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly3[hourlyCT + i] = iff(
        or(hourly3[hourlyCQ + i] > 0, hourly2[hourlyCC + i].isZero), 0,
        min(
          (hourly2[hourlyBX + i] + hourly2[hourlyCK + i]
            + (hourly2[hourlyCL + i] + hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hourly3[hourlyCR + i].isZero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])),
          overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let hourlyCU = 43800
    // IF(CT6=0,0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)),A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly3[hourlyCU + i] = iff(
        hourly3[hourlyCT + i].isZero, 0,
        min(
          (hourly2[hourlyBX + i] + hourly2[hourlyCK + i]
            + (hourly2[hourlyCL + i] + hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hourly3[hourlyCQ + i].isZero, 0, overall_stup_cons[j])
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
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly3[hourlyCQ + i] - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly3[hourlyCR + i] + hourly3[hourlyCU + i]
              - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0) - hourly2[hourlyCL + i])
              / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyCW = 61320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 0..<8760 {
      hourly3[hourlyCW + i] = max(
        0,
        hourly2[hourlyCL + i] + iff(hourly2[hourlyCC + i].isZero, 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
          - hourly3[hourlyCR + i] - hourly3[hourlyCU + i])
    }

    /// Grid import necessary for min harm
    let hourlyCX = 70080
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly3[hourlyCX + i] = max(
        0,
        -(iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly3[hourlyCQ + i] - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly3[hourlyCR + i] + hourly3[hourlyCU + i]
              - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0) - hourly2[hourlyCL + i])
              / El_boiler_eff)))
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
            - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0)) / El_boiler_eff))
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
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
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
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
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
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
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
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly2[hourlyCL + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]),
          min(
            hourly2[hourlyCL + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly2[hourlyCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly2[hourlyCL + i])) / El_boiler_eff)
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
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly0[hourlyDH + i] - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly0[hourlyDI + i] + hourly3[hourlyCU + i]
              - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0) - hourly2[hourlyCL + i])
              / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyDK = 183960
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 0..<8760 {
      hourly3[hourlyDK + i] = max(
        0,
        hourly2[hourlyCL + i] + iff(hourly2[hourlyCC + i].isZero, 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output)
          - hourly0[hourlyDI + i] - hourly3[hourlyCU + i])
    }

    /// Grid import necessary for max harm
    let hourlyDL = 192720
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly3[hourlyDL + i] = max(
        0,
        -(iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyBX + i], 0) + hourly2[hourlyCK + i]
          - (hourly2[hourlyCM + i] - hourly2[hourlyCN + i]) - hourly0[hourlyDH + i] - hourly3[hourlyCT + i]
          - max(
            0,
            (hourly0[hourlyDI + i] + hourly3[hourlyCU + i]
              - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0) - hourly2[hourlyCL + i])
              / El_boiler_eff)))
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
            - iff(hourly2[hourlyCC + i] > 0, hourly2[hourlyCB + i] / PB_Ratio_Heat_input_vs_output, 0)) / El_boiler_eff))
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
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
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
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
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
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyDS = 254040
    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 0..<8760 { hourly3[hourlyDS + i] = min(BESS_chrg_max_cons, hourly3[hourlyDJ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyDT = 262800
    // MIN(Grid_export_max_ud,DJ6)
    for i in 0..<8760 { hourly3[hourlyDT + i] = min(Grid_export_max_ud, hourly3[hourlyDJ + i]) }
    return hourly3
  }
}
