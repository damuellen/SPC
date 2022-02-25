extension TunOl {
  mutating func hour0(_ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double],
    _ Reference_PV_MV_power_at_transformer_outlet: [Double]) -> [Double] {
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
          max(Reference_PV_MV_power_at_transformer_outlet[i], Double.zero) / Reference_PV_plant_power_at_inverter_inlet_DC[i], Double.zero), Double.zero)
      // E6*CSP_loop_nr_ud
      hour0[hourJ + i] = Q_Sol_MW_thLoop[i] * CSP_loop_nr_ud
      // F6*PV_DC_cap_ud/PV_Ref_DC_cap
      hour0[hourK + i] = Reference_PV_plant_power_at_inverter_inlet_DC[i] * PV_DC_cap_ud / PV_Ref_DC_cap
      // MIN(PV_AC_cap_ud,IF(K6/PV_DC_cap_ud>Inv_eff_Ref_approx_handover,K6*POLY(K6/PV_DC_cap_ud,HL_Coeff),IF(K6/PV_DC_cap_ud>0,K6*POLY(K6/PV_DC_cap_ud,LL_Coeff),0)))
      hour0[hourL + i] = min(
        PV_AC_cap_ud,
        iff(
          hour0[hourK + i] / PV_DC_cap_ud > Inv_eff_Ref_approx_handover,
          hour0[hourK + i] * POLY(hour0[hourK + i] / PV_DC_cap_ud, HL_Coeff),
          iff(hour0[hourK + i] / PV_DC_cap_ud > Double.zero, hour0[hourK + i] * POLY(hour0[hourK + i] / PV_DC_cap_ud, LL_Coeff), Double.zero)))
      // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
      let M = max(Double.zero, -Reference_PV_MV_power_at_transformer_outlet[i] / PV_Ref_AC_cap * PV_AC_cap_ud)
      hour0[hourM + i] = M
      // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+PB_stby_aux_cons
      hour0[hourO + i] =
        iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i]
        + PB_stby_aux_cons
      // MAX(0,L6-O6)
      hour0[hourP + i] = max(Double.zero, hour0[hourL + i] - hour0[hourO + i])

      // MAX(0,O6-P6)
      hour0[hourQ + i] = max(Double.zero, hour0[hourO + i] - hour0[hourP + i])
    }

    /// Min harmonious net elec cons
    let hourR = 87600
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,
    //(MIN(J6+El_boiler_cap_ud*El_boiler_eff,MAX(0,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_fix_cons)/(Overall_harmonious_var_max_cons+MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-$J6)/El_boiler_eff))*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,
    //MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      let grid: Double = (hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
        / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
          Double.zero, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hour0[hourJ + i])) / El_boiler_eff)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
      hour0[hourR + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hour0[hourJ + i] + El_boiler_cap_ud * El_boiler_eff,
           grid)
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons
            , Double.zero,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
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
      hour0[hourT + i] =
        max(Double.zero, (hour0[hourS + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons
        * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourU = 113880
    // =IF(OR(AND(S5<=0,S6>0,SUM(S1:S5)=0),AND($F5<=0,$F6>0,SUM(S4:S18)=0)),IF(U5<364,U5+1,0),U5)
    // IF(AND(S5<=0,S6>0),U5+1,U5)
    for i in 1..<8760 {
      let U = iff(
        and(hour0[hourS + i - 1] <= Double.zero, hour0[hourS + i] > Double.zero), hour0[hourU + i - 1] + 1, hour0[hourU + i - 1])
      hour0[hourU + i] = U
    }

    /// Remaining PV after min harmonious
    let hourV = 122640
    // =MAX(0,$P6-$Q6-S6-MIN(El_boiler_cap_ud,MAX(0,(T6-$J6)/El_boiler_eff)))
    // MAX(0,P6-Q6-S6-MAX(0,(T6-J6)/El_boiler_eff))
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
      // MAX(0,1-(S6-Overall_fix_cons)/Overall_harmonious_var_max_cons*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
      hour0[hourAB + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourS + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
      // MAX(0,1-(S6-Overall_fix_cons)/Overall_harmonious_var_max_cons*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
      hour0[hourAC + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourS + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
      // MAX(0,1-(S6-Overall_fix_cons)/Overall_harmonious_var_max_cons*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
      hour0[hourAD + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourS + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
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
    for i in 1..<8760 {
      let grid: Double = (hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
        / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
          Double.zero, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hour0[hourJ + i])) / El_boiler_eff)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
      let a: Double = min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hour0[hourJ + i] + El_boiler_cap_ud * El_boiler_eff, grid)
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
      let b = min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hour0[hourP + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            hour0[hourJ + i] + El_boiler_cap_ud * El_boiler_eff, grid)
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
      hour0[hourAG + i] = iff(
        a < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, b)
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
      hour0[hourAI + i] =
        max(Double.zero, (hour0[hourAH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons
        * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
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

    /// Remaining MethSynt cap after max harm cons
    let hourAP = 297840
    // =MAX(0,Overall_harmonious_max_perc-((MAX(0,AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    // =MAX(0,1-(AH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      hour0[hourAP + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourAH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harm cons
    let hourAQ = 306600
    // =MAX(0,1-(AH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 1..<8760 {
      hour0[hourAQ + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourAH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harm cons
    let hourAR = 315360
    // =MAX(0,1-(AH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 1..<8760 {
      hour0[hourAR + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourAH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
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
      hour1[hourAV + i] =
        iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i]
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
          (hour0[hourJ + i] - max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - min(El_boiler_cap_ud * El_boiler_eff, (hour1[hourAW + i]-Heater_cap_ud)*Heater_eff))) * Ratio_CSP_vs_Heater / Heater_eff))
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
    for i in 1..<8760 {
      hour1[hourBC + i] = max(Double.zero, hour1[hourBA + i] - BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourBD = 70080
    // IF(AZ6=0,0,AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6))
    for i in 1..<8760 {
      hour1[hourBD + i] = iff(
        hour1[hourAZ + i].isZero, Double.zero,
        hour1[hourAY + i]
          - iff(
            hour1[hourBA + i].isZero, Double.zero,
            (hour1[hourBA + i] - hour1[hourBC + i]) / (BBsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
              * hour1[hourBB + i]))
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
          (hour1[hourAW + i] - hour1[hourBD + i])
            / (hour1[hourBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BDcountNonZero[i]),
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
          - iff(
            hour1[hourBC + i].isZero, Double.zero,
            hour1[hourBC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i] * hour1[hourBE + i]))
    }

    /// Max possible CSP heat to TES
    let hourBG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 {
      hour1[hourBG + i] = min(hour0[hourJ + i], hour1[hourBF + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let hourBH = 105120
    // AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc
    for i in 1..<8760 {
      hour1[hourBH + i] =
        hour1[hourAX + i] + (hour1[hourBF + i] * Heater_eff + hour1[hourBG + i]) * TES_aux_cons_perc
    }

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
    for i in 1..<8760 {
      hour1[hourBK + i] = max(Double.zero, -(hour1[hourAW + i] - hour1[hourBF + i] - hour1[hourBH + i]))
    }

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
              * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons) - Overall_heat_fix_cons)
            / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons)
          < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
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
      hour1[hourBN + i] = max(Double.zero, 
        (hour1[hourBM + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons
        * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourBO = 166440 // FIXME
    // =IF(OR(AND(BM5<=0,BM6>0,SUM(BM$1:BM5)=0),AND($F5<=0,$F6>0,SUM(BM$1:BM16)=0)),IF(BO5<364,BO5+1,0),BO5)
    // IF(AND(BM5<=0,BM6>0),BO5+1,IF(AND(BI5<=0,BI6>0,COUNTIF(BM6:BM15,"=0")=10,COUNTIF(BI6:BI15,">0")>5),BO5+1,BO5))
    for i in 1..<8760 {
      hour1[hourBO + i] = iff(
        and(hour1[hourBM + i - 1] <= Double.zero, hour1[hourBM + i] > Double.zero), hour1[hourBO + i - 1] + 1,
        iff(
          and(
            hour1[hourBI + i - 1] <= Double.zero, hour1[hourBI + i] > Double.zero,
            countiff(hour1[(hourBM + i)...].prefix(8760), { $0.isZero }) == 10,
            countiff(hour1[(hourBI + i)...].prefix(8760), { !$0.isZero }) > 5), hour1[hourBO + i - 1] + 1,
          hour1[hourBO + i - 1]))
    }

    /// Remaining PV after min harmonious
    let hourBP = 175200
    // MAX(0,BI6-BK6-BM6-MIN(El_boiler_cap_ud,MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour1[hourBP + i] = max(
        Double.zero,
        hour1[hourBI + i] - hour1[hourBK + i] - hour1[hourBM + i] - min(El_boiler_cap_ud,
          max(Double.zero, (hour1[hourBN + i] - hour1[hourBJ + i]) / El_boiler_eff)))
    }

    /// Remaining CSP heat after min harmonious
    let hourBQ = 183960
    // MAX(0,BJ6-BN6)
    for i in 1..<8760 { hour1[hourBQ + i] = max(Double.zero, hour1[hourBJ + i] - hour1[hourBN + i]) }

    return hour1
  }

  mutating func hour2(j: Int, hour0: [Double], hour1: [Double]) -> [Double] {
    let (hourJ, hourL, hourM, hourAW, hourBK, hourBM, hourBO, hourBP, hourBQ) = (
      26280, 43800, 52560, 8760, 131400, 148920, 166440, 175200, 183960
    )
    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }
    let daysBO: [[Int]] = hour1[hourBO..<(hourBO + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] })
      .map { $0.map { $0 - hourBO } }
    
    let hourAY = 26280
    let AYsum = hour1.sum(hours: daysD, condition: hourAY)
    var hour2 = [Double]()

    /// Min net elec demand to power block
    let hourBU = 0
    // IF($BM6>0,0,IF(A_overall_var_min_cons+A_overall_fix_stby_cons+$BK6+IF($BM7=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6)/El_boiler_eff)<$BP6-PB_stby_aux_cons,0,MAX(0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons)-BP6)))
    for i in 1..<8760 {
      hour2[hourBU + i] = iff(
        hour1[hourBM + i] > Double.zero, Double.zero,
        iff(
          overall_var_min_cons[j] + overall_fix_stby_cons[j] + hour1[hourBK + i]
            + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_stup_cons[j])
            + min(
              El_boiler_cap_ud,
              max(
                Double.zero,
                overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                  + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - hour1[hourBQ + i]) / El_boiler_eff)
            < hour1[hourBP + i] - PB_stby_aux_cons[j], Double.zero,
          max(
            Double.zero,
            overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_stup_cons[j])
              - hour1[hourBP + i])))
    }


    /// Optimized min net elec demand to power block
    let hourBV = 8760
    // IF(AND(BU7>0,BU6=0,BU5>0),BU5,BU6)
    for i in 1..<8760 {
      hour2[hourBV + i] = iff(
        and(hour2[hourBU + i + 1] > Double.zero, hour2[hourBU + i].isZero, hour2[hourBU + i - 1] > Double.zero), hour2[hourBU + i - 1],
        hour2[hourBU + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourBW = 17520
    // COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0) FIXME
    // =IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,$BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+$BK6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+$BK6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV6+$BK6-$BP6))-PB_net_min_cap))+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-$BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(BV6=0,BV7>0),MAX(0,IF(COUNTIF(BV$1:BV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-$BQ6)*TES_aux_cons_perc,0))
    // IF(OR(BV6=0;PB_nom_gross_cap_ud<=0),0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV6+BK6-BP6))-PB_net_min_cap))+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(BV6=0,BV7>0),MAX(0,IF(COUNTIF(BV1:BV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 1..<8760 {
      hour2[hourBW + i] = iff(
        or(hour2[hourBV + i].isZero, PB_nom_gross_cap_ud <= Double.zero), Double.zero,
        hour1[hourBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap, (1 + TES_aux_cons_perc) * (hour2[hourBV + i] + hour1[hourBK + i] - hour1[hourBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc) * (hour2[hourBV + i] + hour1[hourBK + i] - hour1[hourBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(Double.zero, hour2[hourBV + i] + hour1[hourBK + i] - hour1[hourBP + i]))
                  - PB_net_min_cap))
            + max(Double.zero, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - hour1[hourBQ + i])
            * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hour2[hourBV + i].isZero, hour2[hourBV + i] > Double.zero),
            max(
              Double.zero,
              iff(
                countiff(hour2[(hourBV + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
                PB_hot_start_heat_req) - hour1[hourBQ + i]) * TES_aux_cons_perc, Double.zero))
    }

    /// Corresponding min PB net elec output
    let hourBX = 26280
    // IF(BV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-BP6)))
    for i in 1..<8760 {
      hour2[hourBX + i] = iff(
        hour2[hourBV + i].isZero, Double.zero,
        max(PB_net_min_cap, min(PB_nom_net_cap, hour2[hourBV + i] + hour2[hourBW + i] - hour1[hourBP + i])))
    }

    /// Corresponding min PB gross elec output
    let hourBY = 35040
    // IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 {
      hour2[hourBY + i] = iff(
        hour2[hourBX + i].isZero, Double.zero,
        hour2[hourBX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hour2[hourBX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourBZ = 43800
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      hour2[hourBZ + i] = iff(
        and(hour2[hourBY + i].isZero, hour2[hourBY + i + 1] > Double.zero),
        iff(
          countiff(hour2[(hourBY + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
          PB_hot_start_heat_req), Double.zero)
    }
    let BZsum = hour2.sum(hours: daysBO, condition: hourBZ)
    /// Min gross heat cons for ST
    let hourCA = 52560
    // IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 {
      hour2[hourCA + i] = iff(
        hour2[hourBY + i].isZero, Double.zero,
        hour2[hourBY + i] / PB_nom_gross_eff / POLY(hour2[hourBY + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let CAsum = hour2.sum(hours: daysBO, condition: hourCA)
    /// Min gross heat cons for extraction
    let hourCB = 61320
    // COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0) FIXME BM7
    // =IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons),(BX6-BW6+$BP6-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons))-$BQ6-MIN(El_boiler_cap_ud,MAX(0,BX6-BV6-BW6)*El_boiler_eff)))
    // IF(CA6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(BX6-BW6+BP6)/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,BX6-BV6-BW6)*El_boiler_eff)))
    let BO_BFcount = [Double]()
    for i in 1..<8760 {
      hour2[hourCB + i] = iff(
        or(hour1[hourBM + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero, BO_BFcount[i].isZero), Double.zero,
        PB_Ratio_Heat_input_vs_output
          * max(
            Double.zero,
            min(
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]),
              (hour1[hourBX + i] - hour1[hourBW + i] + hour1[hourBP + i] - overall_fix_stby_cons[j]
                - iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_stup_cons[j])) / overall_var_max_cons[j] * overall_var_heat_max_cons[j]
                + overall_heat_fix_stby_cons[j] + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])) - hour1[hourBQ + i]
              - min(El_boiler_cap_ud, max(Double.zero, hour1[hourBX + i] - hour1[hourBV + i] - hour1[hourBW + i]) * El_boiler_eff)))
              
    }
    let CBsum = hour2.sum(hours: daysBO, condition: hourCB)
    /// TES energy needed to fulfil op case
    let hourCC = 70080
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763),0,
    // SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763))
    for i in 1..<8760 {
      hour2[hourCC + i] = iff(
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < BZsum[i] + CAsum[i] + CBsum[i], Double.zero,
        BZsum[i] + CAsum[i] + CBsum[i])
    }

    /// Surplus TES energy due to op case
    let hourCD = 78840
    // IF(CC6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6))
    for i in 1..<8760 {
      hour2[hourCD + i] = iff(
        hour2[hourCC + i].isZero, Double.zero, max(Double.zero, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hour2[hourCC + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourCE = 87600
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 {
      hour2[hourCE + i] = iff(
        or(
          and(hour2[hourCD + i] > Double.zero, hour1[hourAY + i] > Double.zero, hour1[hourAY + i - 1].isZero),
          and(hour2[hourCD + i] > Double.zero, hour1[hourAY + i + 1].isZero, hour1[hourAY + i] > Double.zero)), hour1[hourAY + i], Double.zero)
    }
    let CEsum = hour2.sum(hours: daysBO, condition: hourCE)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourCF = 96360
    // MAX(0,CD6-SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 {
      hour2[hourCF + i] = max(Double.zero, hour2[hourCD + i] - CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourCG = 105120
    // IF(CD6=0,0,AY6-(CD6-CF6)/(SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6)
    for i in 1..<8760 {
      hour2[hourCG + i] = iff(
        hour2[hourCD + i].isZero, Double.zero,
        hour1[hourAY + i] - (hour2[hourCD + i] - hour2[hourCF + i])
          / (CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour2[hourCE + i])
    }

    let CG_BOcountNonZero = hour2.count(hours: daysBO, range: hourCG, predicate: {$0>0})
    let CGsum = hour2.sum(days: daysBO, range: hourCG)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourCH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX((AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")),(J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")))/SUMIF(BO5:BO8763,"="BO6,CG5:CG8763)*CG6)
    for i in 1..<8760 {
      hour2[hourCH + i] = iff(
        or(hour2[hourCG + i].isZero, hour2[hourCF + i].isZero), Double.zero,
        max(
          (hour1[hourAW + i] - hour2[hourCG + i])
            / (hour2[hourCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / CG_BOcountNonZero[i]),
          (hour0[hourJ + i] - hour2[hourCG + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hour2[hourCF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i])) / CGsum[i]
          * hour2[hourCG + i])
    }
    let CHsum = hour2.sum(hours: daysBO, condition: hourCH)
    /// corrected max possible PV elec to TES
    let hourCI = 122640
    // IF(CC6=0,0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,CH5:CH8763)*CH6))
    for i in 1..<8760 {
      hour2[hourCI + i] = iff(
        hour2[hourCC + i].isZero, Double.zero,
        hour2[hourCG + i]
          - iff(
            hour2[hourCF + i].isZero, Double.zero,
            hour2[hourCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i] * hour2[hourCH + i]))
    }

    /// Max possible CSP heat to TES
    let hourCJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 {
      hour2[hourCJ + i] = min(hour0[hourJ + i], hour2[hourCI + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourCK = 140160
    /// Available heat from CSP after TES
    let hourCL = 148920
    
    for i in 1..<8760 { 
      // MAX(0,L6-CI6)
      hour2[hourCK + i] = max(Double.zero, hour0[hourL + i] - hour2[hourCI + i])
      // MAX(0,J6-CJ6)
      hour2[hourCL + i] = max(Double.zero, hour0[hourJ + i] - hour2[hourCJ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourCM = 157680
    //  IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(CC6=0,AND(BY6=0,BZ6=0)),PB_stby_aux_cons,0)+IF(AND(CC6>0,BZ6>0),PB_stup_aux_cons+BZ6*TES_aux_cons_perc,0)+IF(AND(CC6>0,BY6>0),(BZ6+CA6+CB6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      hour2[hourCM + i] =
        iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i]
        + (hour2[hourCI + i] * Heater_eff + hour2[hourCJ + i]) * TES_aux_cons_perc
        + iff(or(hour2[hourCC + i].isZero, and(hour2[hourBY + i].isZero, hour2[hourBZ + i].isZero)), PB_stby_aux_cons, Double.zero)
        + iff(and(hour2[hourCC + i] > Double.zero, hour2[hourBZ + i] > Double.zero), PB_stup_aux_cons + hour2[hourBZ + i] * TES_aux_cons_perc, Double.zero)
        + iff(
          and(hour2[hourCC + i] > Double.zero, hour2[hourBY + i] > Double.zero),
          (hour2[hourBZ + i] + hour2[hourCA + i] + hour2[hourCB + i]) * TES_aux_cons_perc, Double.zero)
    }

    /// Not covered aux elec MWel
    let hourCN = 166440
    // MAX(0,-(L6+IF(CC6>0,BX6,0)-CI6-CM6))
    for i in 1..<8760 {
      hour2[hourCN + i] = max(
        Double.zero,
        -(hour0[hourL + i] + iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) - hour2[hourCI + i]
          - hour2[hourCM + i]))
    }
    return hour2
  }
  
  mutating func hour3(j: Int, hour0: [Double], hour1: [Double], hour2: [Double]) -> [Double] {
    let (hourBO, hourBX, hourCB, hourCC, hourCK, hourCL, hourCM, hourCN) = (
      166440, 26280, 61320, 70080, 140160, 148920, 157680, 166440
    )
    var hour3 = [Double](repeating: Double.zero, count: 271_560)

    /// Min harmonious net elec cons not considering grid import
    let hourCP = 0
    // IF(MIN(MAX(0,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6)-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff)),MAX(0,CL6+MIN(El_boiler_cap_ud,MAX(0,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6)-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour3[hourCP + i] = iff(
        min(
          max(
            Double.zero,
            hour2[hourCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - (hour2[hourCM + i] - hour2[hourCN + i])
              - min(El_boiler_cap_ud, max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour2[hourCL + i]) / El_boiler_eff)),
          max(
            Double.zero,
            hour2[hourCL + i] + min(
              El_boiler_cap_ud,
              max(
                Double.zero,
                hour2[hourCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - (hour2[hourCM + i] - hour2[hourCN + i])
                  - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons)
            / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons)
          < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    
    /// Optimized min harmonious net elec cons
    let hourCQ = 8760
    // IF(OR(AND(CP6>0,CP5=0,CP7=0),AND(CP6>0,OR(AND(CP4=0,CP5=0,CP8=0),AND(CP4=0,CP7=0,CP8=0)))),0,CP6)
    for i in 1..<8760 {
      hour3[hourCQ + i] = iff(
        or(
          and(hour3[hourCP + i] > Double.zero, hour3[hourCP + i - 1].isZero, hour3[hourCP + i + 1].isZero),
          and(
            hour3[hourCP + i] > Double.zero,
            or(
              and(hour3[hourCP + i - 2].isZero, hour3[hourCP + i - 1].isZero, hour3[hourCP + i + 2].isZero),
              and(hour3[hourCP + i - 2].isZero, hour3[hourCP + i + 1].isZero, hour3[hourCP + i + 2].isZero)))), 0, hour3[hourCP + i])
    }

    /// Min harmonious net heat cons
    let hourCR = 17520
    // MAX(0,(CQ6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour3[hourCR + i] = max(Double.zero, (hour3[hourCQ + i] - Overall_fix_cons) /
        Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourCS = 26280 // FIXME
    // =IF(OR(AND(CQ5<=0,CQ6>0,SUM(CQ$1:CQ5)=0),AND($F5<=0,$F6>0,SUM(CQ$1:CQ16)=0)),IF(CS5<364,CS5+1,0),CS5)
    // IF(AND(CQ5<=0,CQ6>0),CS5+1,IF(AND(CK6>0,BO6<>BO5,SUM(CQ6:CQ8)=0),CS5+1,CS5))
    for i in 1..<8760 {
      hour3[hourCS + i] = iff(
        and(hour3[hourCQ + i - 1] <= Double.zero, hour3[hourCQ + i] > Double.zero), hour3[hourCS + i - 1] + 1,
        iff(
          and(
            hour2[hourCK + i] > Double.zero, hour1[hourBO + i] == hour1[hourBO + i - 1],
            sum(hour2[(hourCQ + i)...].prefix(3)) == Double.zero), hour3[hourCS + i - 1] + 1, hour3[hourCS + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourCT = 35040
    // =IF(OR(CQ6>0,CC6=0),0,MIN(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons),MAX(0,BX6+CK6-(CM6-CN6)-CQ6-MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)+CR6-CL6-CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff)),MAX(0,MIN(El_boiler_cap_ud,BX6+CK6-(CM6-CN6)-CQ6)*El_boiler_eff+CL6+CB6/PB_Ratio_Heat_input_vs_output-CR6-IF(CQ7=0,0,A_overall_heat_stup_cons)-A_overall_heat_fix_stby_cons)/A_overall_var_heat_min_cons*A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
    // IF(OR(CQ6>0,CC6=0),0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
    for i in 1..<8760 {
      let a: Double = max(
        Double.zero,
        hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i]
          - min(
            El_boiler_cap_ud,
            max(
              Double.zero,
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) + hour3[hourCR + i] - hour2[hourCL + i]
                - hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
      let b: Double =
        max(
          Double.zero,
          min(El_boiler_cap_ud, hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i])
            * El_boiler_eff + hour2[hourCL + i] + hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output - hour3[hourCR + i]
            - iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - overall_heat_fix_stby_cons[j])
        / overall_var_heat_min_cons[j] * overall_var_min_cons[j] + overall_fix_stby_cons[j]
        + iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_stup_cons[j])
      hour3[hourCT + i] = iff(
        or(hour3[hourCQ + i] > Double.zero, hour2[hourCC + i].isZero), Double.zero,
        min(overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_stup_cons[j]), a, b)
      )
    }

    /// heat cons due to op outside of harm op period
    let hourCU = 43800
    // IF(CT6=0,0,MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons),MAX(0,MIN(El_boiler_cap_ud,BX6+CK6-(CM6-CN6)-CQ6)*El_boiler_eff+CL6+CB6/PB_Ratio_Heat_input_vs_output-CR6),MAX(0,BX6+CK6-(CM6-CN6)-CQ6-MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)+CR6-CL6-CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff)-IF(CQ7=0,0,A_overall_stup_cons)-A_overall_fix_stby_cons)/A_overall_var_min_cons*A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)))
    for i in 1..<8760 {
      hour3[hourCU + i] = iff(
        hour3[hourCT + i].isZero, Double.zero,
        min(
          overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(hour3[hourCR + i + 1].isZero, 0, overall_heat_stup_cons[j]),
          max(
            Double.zero,
            min(
              El_boiler_cap_ud, hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i])
              * El_boiler_eff + hour2[hourCL + i] + hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output - hour3[hourCR + i]),
          max(
            Double.zero,
            hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i]
              - min(
                El_boiler_cap_ud,
                max(
                  Double.zero,
                  overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                    + iff(hour3[hourCQ + i + 1].isZero, 0, overall_heat_stup_cons[j]) + hour3[hourCR + i] - hour2[hourCL + i]
                    - hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)
              - iff(hour3[hourCQ + i + 1].isZero, 0, overall_stup_cons[j]) - overall_fix_stby_cons[j]) / overall_var_min_cons[j]
            * overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(hour3[hourCQ + i + 1].isZero, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourCV = 52560
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourCV + i] = max(
        Double.zero,
        iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i]
          - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i] - hour3[hourCT + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour3[hourCR + i] + hour3[hourCU + i]
              - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - hour2[hourCL + i])
              / El_boiler_eff)))
    }

    /// Remaining heat after min harmonious
    let hourCW = 61320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 1..<8760 {
      hour3[hourCW + i] = max(
        Double.zero,
        hour2[hourCL + i] + iff(hour2[hourCC + i].isZero, Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output)
          - hour3[hourCR + i] - hour3[hourCU + i])
    }

    /// Grid import necessary for min harm
    let hourCX = 70080
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour3[hourCX + i] = max(
        Double.zero,
        -(iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i]
          - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i] - hour3[hourCT + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour3[hourCR + i] + hour3[hourCU + i]
              - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - hour2[hourCL + i])
              / El_boiler_eff))))
    }

    /// Remaining grid import capacity after min harm
    let hourCY = 78840
    // Grid_import_max_ud-CX6
    for i in 1..<8760 { hour3[hourCY + i] = Grid_import_max_ud - hour3[hourCX + i] }

    /// El boiler op after min harmonious heat cons
    let hourCZ = 87600
    // MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 1..<8760 {
      hour3[hourCZ + i] = min(
        El_boiler_cap_ud,
        max(
          Double.zero,
          (hour3[hourCR + i] + hour3[hourCU + i] - hour2[hourCL + i]
            - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero)) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourDA = 96360
    // MAX(0,El_boiler_cap_ud-CZ6)
    for i in 1..<8760 { hour3[hourDA + i] = max(Double.zero, El_boiler_cap_ud - hour3[hourCZ + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourDB = 105120
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      hour3[hourDB + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour3[hourCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourDC = 113880
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 1..<8760 {
      hour3[hourDC + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour3[hourCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourDD = 122640
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 1..<8760 {
      hour3[hourDD + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour3[hourCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourDE = 131400
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourDF = 140160
    
    for i in 1..<8760 { 
      // MIN(BESS_chrg_max_cons,CV6)
      hour3[hourDE + i] = min(BESS_chrg_max_cons, hour3[hourCV + i])
      // MIN(Grid_export_max_ud,CV6)
      hour3[hourDF + i] = min(Grid_export_max_ud, hour3[hourCV + i])
    }

    /// Max harmonious net elec cons without considering grid
    let hourDG = 148920
    //  IF(CP6=0,0,Overall_fix_cons+MIN(Overall_harmonious_var_max_cons,Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN((CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6)-Overall_harmonious_var_min_cons-Overall_fix_cons+MAX(0,CL6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),(CL6+El_boiler_cap_ud-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons))))
    for i in 1..<8760 {
      hour3[hourDG + i] = iff(
        hour3[hourCP + i].isZero, Double.zero,
        Overall_fix_cons
          + min(
            Overall_harmonious_var_max_cons,
            Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * min(
                (hour2[hourCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - (hour2[hourCM + i] - hour2[hourCN + i])
                  - Overall_harmonious_var_min_cons - Overall_fix_cons + max(
                    0, hour2[hourCL + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / El_boiler_eff)
                  / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons
                    + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
                (hour2[hourCL + i] + El_boiler_cap_ud - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
                  / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons))))
    }


    /// Optimized max harmonious net elec cons
    let hourDH = 157680
    // IF(OR(AND(DG6>0,DG5=0,DG7=0),AND(DG6>0,OR(AND(DG4=0,DG5=0,DG8=0),AND(DG4=0,DG7=0,DG8=0)))),0,DG6)
    for i in 1..<8760 {
      hour3[hourDH + i] = iff(
        or(
          and(hour3[hourDG + i] > Double.zero, hour3[hourDG + i - 1].isZero, hour3[hourDG + i + 1].isZero),
          and(
            hour3[hourDG + i] > Double.zero,
            or(
              and(hour3[hourDG + i - 2].isZero, hour3[hourDG + i - 1].isZero, hour3[hourDG + i + 2].isZero),
              and(hour3[hourDG + i - 2].isZero, hour3[hourDG + i + 1].isZero, hour3[hourDG + i + 2].isZero)))), 0, hour3[hourDG + i])
    }

    /// max harmonious net heat cons
    let hourDI = 166440
    // MAX(0,(DH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour3[hourDI + i] =
        max(Double.zero, (hour0[hourDH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourDJ = 175200
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourDJ + i] = max(
        Double.zero,
        iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i]
          - (hour2[hourCM + i] - hour2[hourCN + i]) - hour0[hourDH + i] - hour3[hourCT + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour0[hourDI + i] + hour3[hourCU + i]
              - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - hour2[hourCL + i])
              / El_boiler_eff)))
    }

    /// Remaining heat after max harmonious
    let hourDK = 183960
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 1..<8760 {
      hour3[hourDK + i] = max(
        Double.zero,
        hour2[hourCL + i] + iff(hour2[hourCC + i].isZero, Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output)
          - hour0[hourDI + i] - hour3[hourCU + i])
    }

    /// Grid import necessary for max harm
    let hourDL = 192720
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourDL + i] = max(
        Double.zero,
        -(iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i]
          - (hour2[hourCM + i] - hour2[hourCN + i]) - hour0[hourDH + i] - hour3[hourCT + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour0[hourDI + i] + hour3[hourCU + i]
              - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - hour2[hourCL + i])
              / El_boiler_eff))))
    }

    /// Remaining grid import capacity after max harm
    let hourDM = 201480
    // MAX(0,Grid_import_max_ud-DL6)
    for i in 1..<8760 { hour3[hourDM + i] = max(Double.zero, Grid_import_max_ud - hour0[hourDL + i]) }

    /// El boiler op after max harmonious heat cons
    let hourDN = 210240
    // MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 1..<8760 {
      hour3[hourDN + i] = min(
        El_boiler_cap_ud,
        max(
          Double.zero,
          (hour0[hourDI + i] + hour3[hourCU + i] - hour2[hourCL + i]
            - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero)) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourDO = 219000
    // MAX(0,El_boiler_cap_ud-DN6)
    for i in 1..<8760 { hour3[hourDO + i] = max(Double.zero, El_boiler_cap_ud - hour0[hourDN + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourDP = 227760
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      hour3[hourDP + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourDQ = 236520
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 1..<8760 {
      hour3[hourDQ + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourDR = 245280
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 1..<8760 {
      hour3[hourDR + i] =
        max(
          Double.zero,
          Overall_harmonious_max_perc
            - ((max(Double.zero, hour0[hourDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourDS = 254040
    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 1..<8760 { hour3[hourDS + i] = min(BESS_chrg_max_cons, hour3[hourDJ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourDT = 262800
    // MIN(Grid_export_max_ud,DJ6)
    for i in 1..<8760 { hour3[hourDT + i] = min(Grid_export_max_ud, hour3[hourDJ + i]) }
    return hour3
  }
}
