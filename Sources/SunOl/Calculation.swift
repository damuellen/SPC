extension TunOl {
  mutating func hour0(
    _ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double], _ Reference_PV_MV_power_at_transformer_outlet: [Double]
  ) -> [Double] {
    var hour0 = [Double](repeating: Double.zero, count: 341_640)

    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    /// Inverter power fraction -
    let hourH = 8760
    /// Inverter efficiency -
    let hourI = 17520
    /// Q_solar (before dumping) MWth
    let hourJ = 26280
    /// E_PV_Total _Scaled MWel_DC
    let hourK = 35040
    /// PV MV net power at transformer outlet MWel
    let hourL = 43800
    /// PV aux consumption at transformer level MWel
    let hourM = 52560
    /// Aux elec for PB stby, CSP SF and PV Plant MWel
    let hourO = 61320
    /// Available PV power MWel
    let hourP = 70080
    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let hourQ = 78840
    for i in 1..<8760 {
      // MAX(0,G6/MAX(G5:G8763))
      hour0[hourH + i] = max(Double.zero, Reference_PV_plant_power_at_inverter_inlet_DC[i] / maximum)
      // IFERROR(IF(G6<MAX(G5:G8763),MAX(G6,0)/F6,0),0)
      hour0[hourI + i] = ifFinite(
        iff(
          Reference_PV_MV_power_at_transformer_outlet[i] < maximum,
          max(Reference_PV_MV_power_at_transformer_outlet[i], Double.zero) / Reference_PV_plant_power_at_inverter_inlet_DC[i], Double.zero),
        Double.zero)
      // E6*CSP_loop_nr_ud
      hour0[hourJ + i] = Q_Sol_MW_thLoop[i] * CSP_loop_nr_ud
      // F6*PV_DC_cap_ud/PV_Ref_DC_cap
      hour0[hourK + i] = Reference_PV_plant_power_at_inverter_inlet_DC[i] * PV_DC_cap_ud / PV_Ref_DC_cap
      // MIN(PV_AC_cap_ud,IF(K6/PV_DC_cap_ud>Inv_eff_Ref_approx_handover,K6*POLY(K6/PV_DC_cap_ud,HL_Coeff),IF(K6/PV_DC_cap_ud>0,K6*POLY(K6/PV_DC_cap_ud,LL_Coeff),0)))
      hour0[hourL + i] = min(
        PV_AC_cap_ud,
        iff(
          hour0[hourK + i] / PV_DC_cap_ud > Inv_eff_Ref_approx_handover, hour0[hourK + i] * POLY(hour0[hourK + i] / PV_DC_cap_ud, HL_Coeff),
          iff(hour0[hourK + i] / PV_DC_cap_ud > Double.zero, hour0[hourK + i] * POLY(hour0[hourK + i] / PV_DC_cap_ud, LL_Coeff), Double.zero)))
      // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
      let M = max(Double.zero, -Reference_PV_MV_power_at_transformer_outlet[i] / PV_Ref_AC_cap * PV_AC_cap_ud)
      hour0[hourM + i] = M
      // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+PB_stby_aux_cons
      hour0[hourO + i] =
        iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i] + PB_stby_aux_cons
      // MAX(0,L6-O6)
      hour0[hourP + i] = max(Double.zero, hour0[hourL + i] - hour0[hourO + i])
      // MAX(0,O6-P6)
      hour0[hourQ + i] = max(Double.zero, hour0[hourO + i] - hour0[hourP + i])
    }

    /// Min harmonious net elec cons
    let hourR = 87600
    // IF(MIN(MAX(0;P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-MIN(El_boiler_cap_ud;MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-J6)/El_boiler_eff));MAX(0;J6+MIN(El_boiler_cap_ud;MAX(0;P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons;0;Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour0[hourR + i] = iff(
        min(
          max(
            Double.zero,
            hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy
              - min(
                El_boiler_cap_ud, max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour0[hourJ + i]) / El_boiler_eff)),
          max(
            Double.zero,
            hour0[hourJ + i] + min(
              El_boiler_cap_ud,
              max(
                Double.zero,
                hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - Overall_harmonious_var_min_cons - Overall_fix_cons))
              * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons)
          < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourS = 96360
    // IF(OR(AND(R6>0,R5=0,R7=0),AND(R6>0,OR(AND(R4=0,R5=0,R8=0),AND(R4=0,R7=0,R8=0)))),0,R6)
    for i in 1..<8760 {
      hour0[hourS + i] = iff(
        or(
          and(hour0[hourR + i] > Double.zero, hour0[hourR + i - 1].isZero, hour0[hourR + i + 1].isZero),
          and(
            hour0[hourR + i] > Double.zero,
            or(
              and(hour0[hourR + i - 2].isZero, hour0[hourR + i - 1].isZero, hour0[hourR + i + 2].isZero),
              and(hour0[hourR + i - 2].isZero, hour0[hourR + i + 1].isZero, hour0[hourR + i + 2].isZero)))), 0, hour0[hourR + i])
    }

    /// Min harmonious net heat cons
    let hourT = 105120
    // =MAX(0,(S6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour0[hourT + i] = max(
        Double.zero,
        (hour0[hourS + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourU = 113880
    // =IF(OR(AND(S5<=0,S6>0,SUM(S1:S5)=0),AND($F5<=0,$F6>0,SUM(S4:S18)=0)),IF(U5<364,U5+1,0),U5)
    // IF(AND(S5<=0,S6>0),U5+1,U5)
    for i in 1..<8760 {
      let U = iff(and(hour0[hourS + i - 1] <= Double.zero, hour0[hourS + i] > Double.zero), hour0[hourU + i - 1] + 1, hour0[hourU + i - 1])
      hour0[hourU + i] = U
    }

    /// Remaining PV after min harmonious
    let hourV = 122640
    // MAX(0,$P6-$Q6-S6-MIN(El_boiler_cap_ud,MAX(0,(T6-$J6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour0[hourV + i] = max(
        Double.zero,
        hour0[hourP + i] - hour0[hourQ + i] - hour0[hourS + i]
          - min(El_boiler_cap_ud, max(Double.zero, (hour0[hourT + i] - hour0[hourJ + i]) / El_boiler_eff)))
    }

    /// Remaining CSP heat after min harmonious
    let hourW = 131400
    // MAX(0,J6-T6)
    for i in 1..<8760 { hour0[hourW + i] = max(Double.zero, hour0[hourJ + i] - hour0[hourT + i]) }

    /// Grid import necessary for min harmonious
    let hourX = 140160
    // MAX(0,-($P6-$Q6-$S6-MIN(El_boiler_cap_ud,MAX(0,(T6-$J6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour0[hourX + i] = max(
        Double.zero,
        -(hour0[hourP + i] - hour0[hourQ + i] - hour0[hourS + i]
          - min(El_boiler_cap_ud, max(Double.zero, (hour0[hourT + i] - hour0[hourJ + i]) / El_boiler_eff))))
    }

    /// Remaining grid import capacity after min harmonious
    let hourY = 148920
    // =MAX(0,Grid_import_max_ud-X6)
    for i in 1..<8760 { hour0[hourY + i] = max(Double.zero, Grid_import_max_ud - hour0[hourX + i]) }

    /// El to el boiler after min harm heat cons
    let hourZ = 157680
    // MAX(0,MIN(El_boiler_cap_ud,(T6-$J6)/El_boiler_eff))
    for i in 1..<8760 { hour0[hourZ + i] = max(Double.zero, min(El_boiler_cap_ud, (hour0[hourT + i] - hour0[hourJ + i]) / El_boiler_eff)) }

    /// Remaining el boiler cap after min harm heat cons
    let hourAA = 166440
    // MAX(0,El_boiler_cap_ud-Z6)
    for i in 1..<8760 { hour0[hourAA + i] = max(Double.zero, El_boiler_cap_ud - hour0[hourZ + i]) }

    /// Remaining MethSynt cap after min harm cons
    let hourAB = 175200
    /// Remaining CCU cap after min harm cons
    let hourAC = 183960
    /// Remaining EY cap after min harm cons
    let hourAD = 192720
    for i in 1..<8760 {
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction =
        (max(Double.zero, hour0[hourS + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour0[hourAB + i] =
        max(Double.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      hour0[hourAC + i] =
        max(Double.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour0[hourAD + i] =
        max(Double.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harm cons
    let hourAE = 201480
    /// Max grid export after min harm cons
    let hourAF = 210240
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,V6)
      hour0[hourAE + i] = min(BESS_chrg_max_cons, hour0[hourV + i])
      // MIN(Grid_export_max_ud,V6)
      hour0[hourAF + i] = min(Grid_export_max_ud, hour0[hourV + i])
    }

    /// Max harm net elec cons
    let hourAG = 219000
    // IF(R6=0,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,(MIN($J6+El_boiler_cap_ud*El_boiler_eff,MAX(0,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_fix_cons)/(Overall_harmonious_var_max_cons+MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-$J6)/El_boiler_eff))*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons))
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 1..<8760 {
      let grid: Double =
        (hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
        / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
          Double.zero, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hour0[hourJ + i])) / El_boiler_eff)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
      let a: Double = min(
        Overall_harmonious_var_max_cons + Overall_fix_cons, hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
        min(hour0[hourJ + i] + El_boiler_cap_ud * El_boiler_eff, grid) / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
          * (Overall_harmonious_var_max_cons + Overall_fix_cons))
      let b = min(
        Overall_harmonious_var_max_cons + Overall_fix_cons, hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
        min(hour0[hourJ + i] + El_boiler_cap_ud * El_boiler_eff, grid) / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
          * (Overall_harmonious_var_max_cons + Overall_fix_cons))
      hour0[hourAG + i] = iff(a < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, b)
    }

    /// Optimized max harm net elec cons
    let hourAH = 227760
    // IF(OR(AND(AG6>0,AG5=0,AG7=0),AND(AG6>0,OR(AND(AG4=0,AG5=0,AG8=0),AND(AG4=0,AG7=0,AG8=0)))),0,AG6)
    for i in 1..<8760 {
      hour0[hourAH + i] = iff(
        or(
          and(hour0[hourAG + i] > Double.zero, hour0[hourAG + i - 1].isZero, hour0[hourAG + i + 1].isZero),
          and(
            hour0[hourAG + i] > Double.zero,
            or(
              and(hour0[hourAG + i - 2].isZero, hour0[hourAG + i - 1].isZero, hour0[hourAG + i + 2].isZero),
              and(hour0[hourAG + i - 2].isZero, hour0[hourAG + i + 1].isZero, hour0[hourAG + i + 2].isZero)))), 0, hour0[hourAG + i])
    }

    /// max harm net heat cons
    let hourAI = 236520
    // MAX(0,(AH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour0[hourAI + i] = max(
        Double.zero,
        (hour0[hourAH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining PV after max harm
    let hourAJ = 245280
    // MAX(0,$P6-$Q6-AH6-MIN(El_boiler_cap_ud,MAX(0,(AI6-$J6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour0[hourAJ + i] = max(
        Double.zero,
        hour0[hourP + i] - hour0[hourQ + i] - hour0[hourAH + i]
          - min(El_boiler_cap_ud, max(Double.zero, (hour0[hourAI + i] - hour0[hourJ + i]) / El_boiler_eff)))
    }

    /// Remaining CSP heat after max harm
    let hourAK = 254040
    // MAX(0,J6-AI6)
    for i in 1..<8760 { hour0[hourAK + i] = max(Double.zero, hour0[hourJ + i] - hour0[hourAI + i]) }

    /// Grid import necessary for max harm
    let hourAL = 262800
    // MAX(0,-($P6-$Q6-AH6-MIN(El_boiler_cap_ud,MAX(0,(AI6-$J6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour0[hourAL + i] = max(
        Double.zero,
        -(hour0[hourP + i] - hour0[hourQ + i] - hour0[hourAH + i]
          - min(El_boiler_cap_ud, max(Double.zero, (hour0[hourAI + i] - hour0[hourJ + i]) / El_boiler_eff))))
    }

    /// Remaining grid import capacity after max harm
    let hourAM = 271560
    // MAX(0,Grid_import_max_ud-AL6)
    for i in 1..<8760 { hour0[hourAM + i] = max(Double.zero, Grid_import_max_ud - hour0[hourAL + i]) }

    /// El to el boiler after max harm heat cons
    let hourAN = 280320
    // MAX(0,MIN(El_boiler_cap_ud,(AI6-$J6)/El_boiler_eff))
    for i in 1..<8760 { hour0[hourAN + i] = max(Double.zero, min(El_boiler_cap_ud, (hour0[hourAI + i] - hour0[hourJ + i]) / El_boiler_eff)) }

    /// Remaining el boiler cap after max harm heat cons
    let hourAO = 289080
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 1..<8760 { hour0[hourAO + i] = max(Double.zero, El_boiler_cap_ud - hour0[hourAN + i]) }

    for i in 1..<8760 {
      /// Remaining MethSynt cap after max harm cons
      let hourAP = 297840
      /// Remaining CCU cap after max harm cons
      let hourAQ = 306600
      /// Remaining EY cap after max harm cons
      let hourAR = 315360
      // =MAX(0,1-((MAX(0,AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction =
        (max(Double.zero, hour0[hourAH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour0[hourAP + i] =
        max(Double.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour0[hourAQ + i] =
        max(Double.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour0[hourAR + i] =
        max(Double.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harm cons
    let hourAS = 324120
    /// Max grid export after max harm cons
    let hourAT = 332880
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,AJ6)
      hour0[hourAS + i] = min(BESS_chrg_max_cons, hour0[hourAJ + i])
      // MIN(Grid_export_max_ud,AJ6)
      hour0[hourAT + i] = min(Grid_export_max_ud, hour0[hourAJ + i])
    }
    return hour0
  }

  mutating func hour1(hour0: [Double]) -> [Double] {
    let (hourJ, hourL, hourM) = (26280, 43800, 52560)
    var hour1 = [Double](repeating: Double.zero, count: 192_720)
    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }

    /// Aux elec for CSP SF and PV Plant MWel
    let hourAV = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 1..<8760 {
      hour1[hourAV + i] = iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i]
    }
    /// Available PV power MWel
    let hourAW = 8760
    // MAX(0,L6-AV6)
    for i in 1..<8760 { hour1[hourAW + i] = max(Double.zero, hour0[hourL + i] - hour1[hourAV + i]) }

    /// Not covered aux elec for CSP SF and PV Plant MWel
    let hourAX = 17520
    // MAX(0,AV6-AW6)
    for i in 1..<8760 { hour1[hourAX + i] = max(Double.zero, hour1[hourAV + i] - hour1[hourAW + i]) }

    /// Max possible PV elec to TES (considering TES chrg aux)
    let hourAY = 26280
    // MAX(0,MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc),Heater_cap_ud,($J6-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-MIN(El_boiler_cap_ud*El_boiler_eff,(AW6-Heater_cap_ud)*Heater_eff)))*Ratio_CSP_vs_Heater/Heater_eff))
    for i in 1..<8760 {
      hour1[hourAY + i] = max(
        Double.zero,
        min(
          hour1[hourAW + i] * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc), Heater_cap_ud,
          (hour0[hourJ + i]
            - max(
              Double.zero,
              Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons
                - min(El_boiler_cap_ud * El_boiler_eff, (hour1[hourAW + i] - Heater_cap_ud) * Heater_eff))) * Ratio_CSP_vs_Heater / Heater_eff))
    }

    let AYsum = hour1.sum(hours: daysD, condition: hourAY)

    /// Maximum TES energy per PV day
    let hourAZ = 35040
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour1[hourAZ + i] = min(TES_thermal_cap, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// Surplus energy due to TES size limit
    let hourBA = 43800
    // MAX(0,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap)
    for i in 1..<8760 { hour1[hourBA + i] = max(Double.zero, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap) }

    /// Peripherial PV hour PV to heater
    let hourBB = 52560
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 {
      hour1[hourBB + i] = iff(
        or(
          and(hour1[hourBA + i] > Double.zero, hour1[hourAY + i] > Double.zero, hour1[hourAY + i - 1].isZero),
          and(hour1[hourBA + i] > Double.zero, hour1[hourAY + i + 1].isZero, hour1[hourAY + i] > Double.zero)), hour1[hourAY + i], Double.zero)
    }

    let BBsum = hour1.sum(hours: daysD, condition: hourBB)

    /// Surplus energy due to op limit after removal of peripherial hours
    let hourBC = 61320
    // MAX(0,BA6-SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour1[hourBC + i] = max(Double.zero, hour1[hourBA + i] - BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let hourBD = 70080
    // IF(AZ6=0,0,AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6))
    for i in 1..<8760 {
      hour1[hourBD + i] = iff(
        hour1[hourAZ + i].isZero, Double.zero,
        hour1[hourAY + i]
          - iff(
            hour1[hourBA + i].isZero, Double.zero,
            (hour1[hourBA + i] - hour1[hourBC + i]) / (BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour1[hourBB + i]))
    }
    let BDcountNonZero = hour1.count(hours: daysD, range: hourBD, predicate: { $0 > 0 })
    let BDsum = hour1.sum(hours: daysD, condition: hourBD)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourBE = 78840
    // IF(OR(BD6=0,BC6=0),0,MAX((AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(D5:D8763,"="D6,BD4:BD8762,">0")),(J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(D5:D8763,"="D6,BD5:BD8763,">0")))/SUMIF(D5:D8763,"="D6,BD5:BD8763)*BD6)
    for i in 1..<8760 {
      hour1[hourBE + i] = iff(
        or(hour1[hourBD + i].isZero, hour1[hourBC + i].isZero), Double.zero,
        max(
          (hour1[hourAW + i] - hour1[hourBD + i]) / (hour1[hourBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BDcountNonZero[i]),
          (hour0[hourJ + i] - hour1[hourBD + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hour1[hourBC + i] / (1 + Ratio_CSP_vs_Heater) / BDcountNonZero[i])) / BDsum[i] * hour1[hourBD + i])
    }
    let BEsum = hour1.sum(hours: daysD, condition: hourBE)
    /// corrected max possible PV elec to TES
    let hourBF = 87600
    // IF(AZ6=0,0,BD6-IF(BC6=0,0,BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(D5:D8763,"="D6,BE5:BE8763)*BE6))
    for i in 1..<8760 {
      hour1[hourBF + i] = iff(
        hour1[hourAZ + i].isZero, Double.zero,
        hour1[hourBD + i]
          - iff(hour1[hourBC + i].isZero, Double.zero, hour1[hourBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i] * hour1[hourBE + i])
      )
    }

    /// Max possible CSP heat to TES
    let hourBG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour1[hourBG + i] = min(hour0[hourJ + i], hour1[hourBF + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourBH = 105120
    // AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc
    for i in 1..<8760 { hour1[hourBH + i] = hour1[hourAX + i] + (hour1[hourBF + i] * Heater_eff + hour1[hourBG + i]) * TES_aux_cons_perc }

    /// Remaining PV after TES chrg
    let hourBI = 113880
    // MAX(0,AW6-BF6-BH6)
    for i in 1..<8760 { hour1[hourBI + i] = max(Double.zero, hour1[hourAW + i] - hour1[hourBF + i] - hour1[hourBH + i]) }

    /// Remaining CSP heat after TES
    let hourBJ = 122640
    // J6-BG6
    for i in 1..<8760 { hour1[hourBJ + i] = hour0[hourJ + i] - hour1[hourBG + i] }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourBK = 131400
    // MAX(0,-(AW6-BF6-BH6))
    for i in 1..<8760 { hour1[hourBK + i] = max(Double.zero, -(hour1[hourAW + i] - hour1[hourBF + i] - hour1[hourBH + i])) }

    /// Min harmonious net elec cons not considering grid import
    let hourBL = 140160
    // =IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons,(MIN(BJ6+El_boiler_cap_ud*El_boiler_eff,MAX(0,BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons-Overall_fix_cons)/(Overall_harmonious_var_max_cons+MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-BJ6)/El_boiler_eff))*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour1[hourBL + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hour1[hourBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons,
          (min(
            hour1[hourBJ + i] + El_boiler_cap_ud * El_boiler_eff,
            max(Double.zero, hour1[hourBI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons - Overall_fix_cons)
              / (Overall_harmonious_var_max_cons
                + min(
                  El_boiler_cap_ud,
                  max(Double.zero, Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hour1[hourBJ + i]) / El_boiler_eff))
              * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons) - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons
            * Overall_harmonious_var_max_cons + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourBM = 148920
    // IF(OR(AND(BL6>0,BL5=0,BL7=0),AND(BL6>0,OR(AND(BL4=0,BL5=0,BL8=0),AND(BL4=0,BL7=0,BL8=0)))),0,BL6)
    for i in 1..<8760 {
      hour1[hourBM + i] = iff(
        or(
          and(hour1[hourBL + i] > Double.zero, hour1[hourBL + i - 1].isZero, hour1[hourBL + i + 1].isZero),
          and(
            hour1[hourBL + i] > Double.zero,
            or(
              and(hour1[hourBL + i - 2].isZero, hour1[hourBL + i - 1].isZero, hour1[hourBL + i + 2].isZero),
              and(hour1[hourBL + i - 2].isZero, hour1[hourBL + i + 1].isZero, hour1[hourBL + i + 2].isZero)))), 0, hour1[hourBL + i])
    }

    /// Min harmonious net heat cons
    let hourBN = 157680
    // MAX(0,(BM6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour1[hourBN + i] = max(
        Double.zero,
        (hour1[hourBM + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourBO = 166440  // FIXME
    // =IF(OR(AND(BM5<=0,BM6>0,SUM(BM$1:BM5)=0),AND($F5<=0,$F6>0,SUM(BM$1:BM16)=0)),IF(BO5<364,BO5+1,0),BO5)
    // IF(AND(BM5<=0,BM6>0),BO5+1,IF(AND(BI5<=0,BI6>0,COUNTIF(BM6:BM15,"=0")=10,COUNTIF(BI6:BI15,">0")>5),BO5+1,BO5))
    for i in 1..<8760 {
      hour1[hourBO + i] = iff(
        and(hour1[hourBM + i - 1] <= Double.zero, hour1[hourBM + i] > Double.zero), hour1[hourBO + i - 1] + 1,
        iff(
          and(
            hour1[hourBI + i - 1] <= Double.zero, hour1[hourBI + i] > Double.zero,
            countiff(hour1[(hourBM + i)...].prefix(8760), { $0.isZero }) == 10, countiff(hour1[(hourBI + i)...].prefix(8760), { !$0.isZero }) > 5),
          hour1[hourBO + i - 1] + 1, hour1[hourBO + i - 1]))
    }

    /// Remaining PV after min harmonious
    let hourBP = 175200
    // MAX(0,BI6-BK6-BM6-MIN(El_boiler_cap_ud,MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour1[hourBP + i] = max(
        Double.zero,
        hour1[hourBI + i] - hour1[hourBK + i] - hour1[hourBM + i]
          - min(El_boiler_cap_ud, max(Double.zero, (hour1[hourBN + i] - hour1[hourBJ + i]) / El_boiler_eff)))
    }

    /// Remaining CSP heat after min harmonious
    let hourBQ = 183960
    // MAX(0,BJ6-BN6)
    for i in 1..<8760 { hour1[hourBQ + i] = max(Double.zero, hour1[hourBJ + i] - hour1[hourBN + i]) }

    return hour1
  }
}
