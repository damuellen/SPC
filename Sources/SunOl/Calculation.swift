extension TunOl {
  func hourly(r0: inout [Double]) {
    /// Day of year
    let D = 0
    let E = 0
    let F = 0
    // IF(C6=0,D5+1,D5)
    let G = 0
    /// Inverter power fraction -
    let H = 0
    // MAX(0,G6/MAX(G5:G8763))
    

    /// Inverter efficiency -
    let I = 8760
    // IFERROR(IF(G6<MAX(G5:G8763),MAX(G6,0)/F6,0),0)
    for i in 0..<8760 {
      r0[I + i] = ifFinite(
        iff(r0[G + i] < max([(G + i)...].prefix(8760)), max(r0[G + i], 0) / r0[F + i], 0), 0)
    }

    /// Q_solar (before dumping) MWth
    let J = 17520
    // E6*CSP_loop_nr_ud
    for i in 0..<8760 { r0[J + i] = r0[E + i] * CSP_loop_nr_ud }

    /// E_PV_Total _Scaled MWel_DC
    let K = 26280
    // F6*PV_DC_cap_ud/PV_Ref_DC_cap
    for i in 0..<8760 { r0[K + i] = r0[F + i] * PV_DC_cap_ud / PV_Ref_DC_cap }

    /// PV MV net power at transformer outlet MWel
    let L = 35040
    // MIN(PV_AC_cap_ud,IF(K6/PV_DC_cap_ud>Inv_eff_Ref_approx_handover,K6*POLY(K6/PV_DC_cap_ud,HL_Coeff),IF(K6/PV_DC_cap_ud>0,K6*POLY(K6/PV_DC_cap_ud,LL_Coeff),0)))
    for i in 0..<8760 {
      r0[L + i] = min(
        PV_AC_cap_ud,
        iff(
          r0[K + i] / PV_DC_cap_ud > Inv_eff_Ref_approx_handover,
          r0[K + i] * POLY(r0[K + i] / PV_DC_cap_ud, HL_Coeff),
          iff(
            r0[K + i] / PV_DC_cap_ud > 0, r0[K + i] * POLY(r0[K + i] / PV_DC_cap_ud, LL_Coeff), 0))
      )
    }

    /// PV aux consumption at transformer level MWel
    let M = 43800
    // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
    for i in 0..<8760 { r0[M + i] = max(0, -r0[G + i] / PV_Ref_AC_cap * PV_AC_cap_ud) }

  }
}

extension TunOl {
  func opStrategy2(r1: inout [Double]) {

    /// Aux elec for PB stby, CSP SF and PV Plant MWel
    let O = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+PB_stby_aux_cons
    for i in 0..<8760 {
      r1[O + i] =
        iff(r1[J + i] > 0, r1[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + r1[M + i]
        + PB_stby_aux_cons
    }

    /// Available PV power MWel
    let P = 8760
    // MAX(0,L6-O6)
    for i in 0..<8760 { r1[P + i] = max(0, r1[L + i] - r1[O + i]) }

    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let Q = 17520
    // MAX(0,O6-P6)
    for i in 0..<8760 { r1[Q + i] = max(0, r1[O + i] - r1[P + i]) }

    /// Min harmonious net elec cons
    let R = 26280
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      r1[R + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            r1[J + i] + El_boiler_cap_ud * El_boiler_eff,
            (r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r1[J + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let S = 35040
    // IF(AND(R6>0,R5=0,OR(R6=0,R7=0)),0,R6)
    for i in 0..<8760 {
      r1[S + i] = iff(
        and(r1[R + i] > 0, r1[R + i - 1].isZero, or(r1[R + i].isZero, r1[R + i + 1].isZero)), 0, r1[R + i])
    }

    /// Min harmonious net heat cons
    let T = 43800
    // S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r1[T + i] =
        r1[S + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let U = 52560
    // IF(AND(S5<=0,S6>0),U5+1,U5)
    for i in 0..<8760 {
      r1[U + i] = iff(and(r1[S + i - 1] <= 0, r1[S + i] > 0), r1[U + i - 1] + 1, r1[U + i - 1])
    }

    /// Remaining PV after min harmonious
    let V = 61320
    // MAX(0,P6-Q6-S6-MAX(0,(T6-J6)/El_boiler_eff))
    for i in 0..<8760 {
      r1[V + i] = max(
        0, r1[P + i] - r1[Q + i] - r1[S + i] - max(0, (r1[T + i] - r1[J + i]) / El_boiler_eff))
    }

    /// Remaining CSP heat after min harmonious
    let W = 70080
    // MAX(0,J6-T6)
    for i in 0..<8760 { r1[W + i] = max(0, r1[J + i] - r1[T + i]) }

    /// Grid import necessary for min harmonious
    let X = 78840
    // MAX(0,-(P6-Q6-S6-MAX(0,(T6-J6)/El_boiler_eff)))
    for i in 0..<8760 {
      r1[X + i] = max(
        0, -(r1[P + i] - r1[Q + i] - r1[S + i] - max(0, (r1[T + i] - r1[J + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harmonious
    let Y = 87600
    // Grid_import_max_ud-X6
    for i in 0..<8760 { r1[Y + i] = Grid_import_max_ud - r1[X + i] }

    /// El to el boiler after min harm heat cons
    let Z = 96360
    // MAX(0,(T6-J6)/El_boiler_eff)
    for i in 0..<8760 { r1[Z + i] = max(0, (r1[T + i] - r1[J + i]) / El_boiler_eff) }

    /// Remaining el boiler cap after min harm heat cons
    let AA = 105120
    // MAX(0,El_boiler_cap_ud-Z6)
    for i in 0..<8760 { r1[AA + i] = max(0, El_boiler_cap_ud - r1[Z + i]) }

    /// Remaining MethSynt cap after min harm cons
    let AB = 113880
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r1[AB + i] =
        max(
          0,
          1 - r1[S + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harm cons
    let AC = 122640
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r1[AC + i] =
        max(
          0,
          1 - r1[S + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harm cons
    let AD = 131400
    // MAX(0,1-S6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r1[AD + i] =
        max(
          0,
          1 - r1[S + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harm cons
    let AE = 140160
    // MIN(BESS_chrg_max_cons,V6)
    for i in 0..<8760 { r1[AE + i] = min(BESS_chrg_max_cons, r1[V + i]) }

    /// Max grid export after min harm cons
    let AF = 148920
    // MIN(Grid_export_max_ud,V6)
    for i in 0..<8760 { r1[AF + i] = min(Grid_export_max_ud, r1[V + i]) }

    /// Max harm net elec cons
    let AG = 157680
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy,MIN(J6+El_boiler_cap_ud*El_boiler_eff,(P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy)/(Overall_harmonious_var_max_cons+Overall_fix_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-J6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      r1[AG + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            r1[J + i] + El_boiler_cap_ud * El_boiler_eff,
            (r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r1[J + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy,
          min(
            r1[J + i] + El_boiler_cap_ud * El_boiler_eff,
            (r1[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r1[J + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harm net elec cons
    let AH = 166440
    // IF(AND(AG6>0,AG5=0,OR(AG6=0,AG7=0)),0,AG6)
    for i in 0..<8760 {
      r1[AH + i] = iff(
        and(r1[AG + i] > 0, r1[AG + i - 1].isZero, or(r1[AG + i].isZero, r1[AG + i + 1].isZero)), 0, r1[AG + i])
    }

    /// max harm net heat cons
    let AI = 175200
    // AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r1[AI + i] =
        r1[AH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining PV after max harm
    let AJ = 183960
    // MAX(0,P6-Q6-AH6-MAX(0,(AI6-J6)/El_boiler_eff))
    for i in 0..<8760 {
      r1[AJ + i] = max(
        0, r1[P + i] - r1[Q + i] - r1[AH + i] - max(0, (r1[AI + i] - r1[J + i]) / El_boiler_eff))
    }

    /// Remaining CSP heat after max harm
    let AK = 192720
    // MAX(0,J6-AI6)
    for i in 0..<8760 { r1[AK + i] = max(0, r1[J + i] - r1[AI + i]) }

    /// Grid import necessary for max harm
    let AL = 201480
    // MAX(0,-(P6-Q6-AH6-MAX(0,(AI6-J6)/El_boiler_eff)))
    for i in 0..<8760 {
      r1[AL + i] = max(
        0, -(r1[P + i] - r1[Q + i] - r1[AH + i] - max(0, (r1[AI + i] - r1[J + i]) / El_boiler_eff))
      )
    }

    /// Remaining grid import capacity after max harm
    let AM = 210240
    // Grid_import_max_ud-AL6
    for i in 0..<8760 { r1[AM + i] = Grid_import_max_ud - r1[AL + i] }

    /// El to el boiler after max harm heat cons
    let AN = 219000
    // MAX(0,(AI6-J6)/El_boiler_eff)
    for i in 0..<8760 { r1[AN + i] = max(0, (r1[AI + i] - r1[J + i]) / El_boiler_eff) }

    /// Remaining el boiler cap after max harm heat cons
    let AO = 227760
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 0..<8760 { r1[AO + i] = max(0, El_boiler_cap_ud - r1[AN + i]) }

    /// Remaining MethSynt cap after max harm cons
    let AP = 236520
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethSynt_harmonious_max_perc)*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r1[AP + i] =
        max(
          0,
          1 - r1[AH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethSynt_harmonious_max_perc) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harm cons
    let AQ = 245280
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*CCU_harmonious_max_perc)*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r1[AQ + i] =
        max(
          0,
          1 - r1[AH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * CCU_harmonious_max_perc) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harm cons
    let AR = 254040
    // MAX(0,1-AH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*EY_harmonious_max_perc)*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r1[AR + i] =
        max(
          0,
          1 - r1[AH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * EY_harmonious_max_perc) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harm cons
    let AS = 262800
    // MIN(BESS_chrg_max_cons,AJ6)
    for i in 0..<8760 { r1[AS + i] = min(BESS_chrg_max_cons, r1[AJ + i]) }

    /// Max grid export after max harm cons
    let AT = 271560
    // MIN(Grid_export_max_ud,AJ6)
    for i in 0..<8760 { r1[AT + i] = min(Grid_export_max_ud, r1[AJ + i]) }

  }
}

extension TunOl {
  func opStrategy1(r2: inout [Double]) {

    /// Aux elec for CSP SF and PV Plant MWel
    let AV = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 0..<8760 {
      r2[AV + i] =
        iff(r2[J + i] > 0, r2[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + r2[M + i]
    }

    /// Available PV power MWel
    let AW = 8760
    // MAX(0,L6-AV6)
    for i in 0..<8760 { r2[AW + i] = max(0, r2[L + i] - r2[AV + i]) }

    /// Not covered aux elec for CSP SF and PV Plant MWel
    let AX = 17520
    // MAX(0,AV6-AW6)
    for i in 0..<8760 { r2[AX + i] = max(0, r2[AV + i] - r2[AW + i]) }

    /// Max possible PV elec to TES (considering TES chrg aux)
    let AY = 26280
    // MAX(0,MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc),Heater_cap_ud,J6*Ratio_CSP_vs_Heater/Heater_eff))
    for i in 0..<8760 {
      r2[AY + i] = max(
        0,
        min(
          r2[AW + i] * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc),
          Heater_cap_ud, r2[J + i] * Ratio_CSP_vs_Heater / Heater_eff))
    }

    /// Maximum TES energy per PV day
    let AZ = 35040
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      r2[AZ + i] = min(TES_thermal_cap, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// Surplus energy due to TES size limit
    let BA = 43800
    // MAX(0,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap)
    for i in 0..<8760 {
      r2[BA + i] = max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap)
    }

    /// Peripherial PV hour PV to heater
    let BB = 52560
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      r2[BB + i] = iff(
        or(
          and(r2[BA + i] > 0, r2[AY + i] > 0, r2[AY + i - 1].isZero),
          and(r2[BA + i] > 0, r2[AY + i + 1].isZero, r2[AY + i] > 0)), r2[AY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let BC = 61320
    // MAX(0,BA6-SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      r2[BC + i] = max(0, r2[BA + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let BD = 70080
    // IF(AZ6=0,0,AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6))
    for i in 0..<8760 {
      r2[BD + i] = iff(
        r2[AZ + i].isZero, 0,
        r2[AY + i]
          - iff(
            r2[BA + i].isZero, 0,
            (r2[BA + i] - r2[BC + i]) / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
              * r2[BB + i]))
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let BE = 78840
    // IF(OR(BD6=0,BC6=0),0,MAX((AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(D5:D8763,"="D6,BD4:BD8762,">0")),(J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(D5:D8763,"="D6,BD5:BD8763,">0")))/SUMIF(D5:D8763,"="D6,BD5:BD8763)*BD6)
    for i in 0..<8760 {
      r2[BE + i] = iff(
        or(r2[BD + i].isZero, r2[BC + i].isZero), 0,
        max(
          (r2[AW + i] - r2[BD + i])
            / (r2[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / _DcountNonZero[i]),
          (r2[J + i] - r2[BD + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (r2[BC + i] / (1 + Ratio_CSP_vs_Heater) / _DcountNonZero[i])) / sum[i] * r2[BD + i])
    }

    /// corrected max possible PV elec to TES
    let BF = 87600
    // IF(AZ6=0,0,BD6-IF(BC6=0,0,BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(D5:D8763,"="D6,BE5:BE8763)*BE6))
    for i in 0..<8760 {
      r2[BF + i] = iff(
        r2[AZ + i].isZero, 0,
        r2[BD + i]
          - iff(
            r2[BC + i].isZero, 0,
            r2[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i] * r2[BE + i]))
    }

    /// Max possible CSP heat to TES
    let BG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      r2[BG + i] = min(r2[J + i], r2[BF + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BH = 105120
    // AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc
    for i in 0..<8760 {
      r2[BH + i] = r2[AX + i] + (r2[BF + i] * Heater_eff + r2[BG + i]) * TES_aux_cons_perc
    }

    /// Remaining PV after TES chrg
    let BI = 113880
    // MAX(0,AW6-BF6-BH6)
    for i in 0..<8760 { r2[BI + i] = max(0, r2[AW + i] - r2[BF + i] - r2[BH + i]) }

    /// Remaining CSP heat after TES
    let BJ = 122640
    // J6-BG6
    for i in 0..<8760 { r2[BJ + i] = r2[J + i] - r2[BG + i] }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BK = 131400
    // MAX(0,-(AW6-BF6-BH6))
    for i in 0..<8760 { r2[BK + i] = max(0, -(r2[AW + i] - r2[BF + i] - r2[BH + i])) }

    /// Min harmonious net elec cons not considering grid import
    let BL = 140160
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons,MIN(BJ6+El_boiler_cap_ud*El_boiler_eff,(BI6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_stby_aux_cons)/(Overall_harmonious_var_max_cons+Overall_fix_cons+PB_stby_aux_cons+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-BJ6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      r2[BL + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r2[BI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons,
          min(
            r2[BJ + i] + El_boiler_cap_ud * El_boiler_eff,
            (r2[BI + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_stby_aux_cons)
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + PB_stby_aux_cons + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r2[BJ + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let BM = 148920
    // IF(AND(BL6>0,BL5=0,OR(BL6=0,BL7=0)),0,BL6)
    for i in 0..<8760 {
      r2[BM + i] = iff(
        and(r2[BL + i] > 0, r2[BL + i - 1].isZero, or(r2[BL + i] = 0, r2[BL + i + 1].isZero)), 0, r2[BL + i])
    }

    /// Min harmonious net heat cons
    let BN = 157680
    // BM6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r2[BN + i] =
        r2[BM + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let BO = 166440
    // IF(AND(BM5<=0,BM6>0),BO5+1,IF(AND(BI5<=0,BI6>0,COUNTIF(BM6:BM15,"=0")=10,COUNTIF(BI6:BI15,">0")>5),BO5+1,BO5))
    for i in 0..<8760 {
      r2[BO + i] = iff(
        and(r2[BM + i - 1] <= 0, r2[BM + i] > 0), r2[BO + i - 1] + 1,
        iff(
          and(
            r2[BI + i - 1] <= 0, r2[BI + i] > 0,
            countiff([(BM + i)...].prefix(9), { $0.isZero }) = 10,
            countiff([(BI + i)...].prefix(9), { !$0.isZero }) > 5), r2[BO + i - 1] + 1,
          r2[BO + i - 1]))
    }



    /// Remaining PV after min harmonious
    let BP = 175200
    // MAX(0,BI6-BK6-BM6-MAX(0,(BN6-BJ6)/El_boiler_eff))
    for i in 0..<8760 {
      r2[BP + i] = max(
        0, r2[BI + i] - r2[BK + i] - r2[BM + i] - max(0, (r2[BN + i] - r2[BJ + i]) / El_boiler_eff)
      )
    }

    /// Remaining CSP heat after min harmonious
    let BQ = 183960
    // MAX(0,BJ6-BN6)
    for i in 0..<8760 { r2[BQ + i] = max(0, r2[BJ + i] - r2[BN + i]) }

    /// Grid import necessary for min harm
    let BR = 192720
    // MAX(0,-(BI6-BK6-BM6-MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 0..<8760 {
      r2[BR + i] = max(
        0,
        -(r2[BI + i] - r2[BK + i] - r2[BM + i] - max(0, (r2[BN + i] - r2[BJ + i]) / El_boiler_eff))
      )
    }

    /// Remaining grid import capacity after min harm
    let BS = 201480
    // Grid_import_max_ud-BR6
    for i in 0..<8760 { r2[BS + i] = Grid_import_max_ud - r2[BR + i] }
  }
}

extension TunOl {
  func operationCase(r2: [Double], r3: inout [Double]) {
    let rangeBO: [[Int]] = r2[BO...<(BO+8760)].indices.chunked(by: {r2[$0] == r2[$1]}).map { $0.map { $0 - BO } }
    /// Min net elec demand to power block
    let BU = 0
    // IF(BM6>0,0,IF(A_overall_var_min_cons+A_overall_fix_stby_cons+BK6+IF(BM7=0,0,A_overall_stup_cons)+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      r3[BU + i] = iff(
        r3[BM + i] > 0, 0,
        iff(
          overall_var_min_cons[j] + overall_fix_stby_cons[j] + r3[BK + i]
            + iff(r3[BM + i + 1].isZero, 0, overall_stup_cons[j]) + max(
              0,
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(r3[BM + i + 1].isZero, 0, overall_heat_stup_cons[j]) - r3[BQ + i]) / El_boiler_eff
            < r3[BP + i] - PB_stby_aux_cons, 0,
          overall_var_min_cons[j] + overall_fix_stby_cons[j]
            + iff(r3[BM + i + 1].isZero, 0, overall_stup_cons[j])))
    }

    /// Optimized min net elec demand to power block
    let BV = 8760
    // IF(AND(BU7>0,BU6=0,BU5>0),BU5,BU6)
    for i in 0..<8760 {
      r3[BV + i] = iff(
        and(r3[BU + i + 1] > 0, r3[BU + i].isZero, r3[BU + i - 1] > 0), r3[BU + i - 1], r3[BU + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let BW = 17520
    // IF(BV6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV6+BK6-BP6))-PB_net_min_cap))+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(BV6=0,BV7>0),MAX(0,IF(COUNTIF(BV1:BV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      r3[BW + i] = iff(
        r3[BV + i].isZero, 0,
        r3[BK + i]
          + ((min(
            PB_nom_net_cap,
            max(PB_net_min_cap, (1 + TES_aux_cons_perc) * (r3[BV + i] + r3[BK + i] - r3[BP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap, (1 + TES_aux_cons_perc) * (r3[BV + i] + r3[BK + i] - r3[BP + i]))
              ) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(0, r3[BV + i] + r3[BK + i] - r3[BP + i]))
                  - PB_net_min_cap))
            + max(0, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - r3[BQ + i])
            * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(r3[BV + i] = 0, r3[BV + i] > 0),
            max(
              0,
              iff(
                countiff([(BV + i)...].prefix(6), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - r3[BQ + i]) * TES_aux_cons_perc, 0
          ))
    }

    /// Corresponding min PB net elec output
    let BX = 26280
    // IF(BV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-BP6)))
    for i in 0..<8760 {
      r3[BX + i] = iff(
        r3[BV + i] = 0, 0,
        max(PB_net_min_cap, min(PB_nom_net_cap, r3[BV + i] + r3[BW + i] - r3[BP + i])))
    }

    /// Corresponding min PB gross elec output
    let BY = 35040
    // IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      r3[BY + i] = iff(
        r3[BX + i] = 0, 0,
        r3[BX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(r3[BX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let BZ = 43800
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      r3[BZ + i] = iff(
        and(r3[BY + i] = 0, r3[BY + i] > 0),
        iff(
          countiff([(BY + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Min gross heat cons for ST
    let CA = 52560
    // IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      r3[CA + i] = iff(
        r3[BY + i] = 0, 0,
        r3[BY + i] / PB_nom_gross_eff / POLY(r3[BY + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Min gross heat cons for extraction
    let CB = 61320
    // IF(CA6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(BX6-BW6+BP6)/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,BX6-BV6-BW6)*El_boiler_eff)))
    for i in 0..<8760 {
      r3[CB + i] = iff(
        r3[CA + i] = 0, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(r3[BM + i] = 0, 0, overall_heat_stup_cons[j]),
              (r3[BX + i] - r3[BW + i] + r3[BP + i])
                / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
                  + iff(r3[BM + i] = 0, 0, overall_stup_cons[j]))
                * (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                  + iff(r3[BM + i] = 0, 0, overall_heat_stup_cons[j]))) - r3[BQ + i] - max(
                0, r3[BX + i] - r3[BV + i] - r3[BW + i]) * El_boiler_eff)))
    }

    /// TES energy needed to fulfil op case
    let CC = 70080
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763),0,SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763))
    let AYsum = r2.sum(hours: rangeBO, condition: AY, predicate: {_ in true})
    let BZsum = r3.sum(hours: rangeBO, condition: BZ, predicate: {_ in true})
    let CAsum = r3.sum(hours: rangeBO, condition: CA, predicate: {_ in true})
    let CBsum = r3.sum(hours: rangeBO, condition: CB, predicate: {_ in true})
    for i in 0..<8760 {
      r3[CC + i] = iff(
        min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < AYsum[i] + BZsum[i]
          + CAsum[i] + CBsum[i], 0, BZsum[i] + CAsum[i] + CBsum[i])
    }

    /// Surplus TES energy due to op case
    let CD = 78840
    // IF(CC6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6))
    for i in 0..<8760 {
      r3[CD + i] = iff(
        r3[CC + i] = 0, 0, max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - r3[CC + i])
      )
    }

    /// Peripherial PV hour PV to heater
    let CE = 87600
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      r3[CE + i] = iff(
        or(
          and(r3[CD + i] > 0, r3[AY + i] > 0, r3[AY + i - 1] = 0),
          and(r3[CD + i] > 0, r3[AY + i] = 0, r3[AY + i] > 0)), r3[AY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let CF = 96360
    // MAX(0,CD6-SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      r3[CF + i] = max(0, r3[CD + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let CG = 105120
    // IF(CD6=0,0,AY6-(CD6-CF6)/(SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6)
    for i in 0..<8760 {
      r3[CG + i] = iff(
        r3[CD + i] = 0, 0,
        r3[AY + i] - (r3[CD + i] - r3[CF + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * r3[CE + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let CH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX((AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")),(J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")))/SUMIF(BO5:BO8763,"="BO6,CG5:CG8763)*CG6)
    for i in 0..<8760 {
      r3[CH + i] = iff(
        or(r3[CG + i] = 0, r3[CF + i] = 0), 0,
        max(
          (r3[AW + i] - r3[CG + i])
            / (r3[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CG_BOcountNonZero[i]),
          (r3[J + i] - r3[CG + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (r3[CF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i])) / sum[i]
          * r3[CG + i])
    }
    let CHsum = r3.sum(hours: rangeBO, condition: CB, predicate: {_ in true})
    /// corrected max possible PV elec to TES
    let CI = 122640
    // IF(CC6=0,0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,CH5:CH8763)*CH6))
    for i in 0..<8760 {
      r3[CI + i] = iff(
        r3[CC + i] = 0, 0,
        r3[CG + i]
          - iff(
            r3[CF + i] = 0, 0,
            r3[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i] * r3[CH + i]))
    }

    /// Max possible CSP heat to TES
    let CJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      r3[CJ + i] = min(r3[J + i], r3[CI + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let CK = 140160
    // MAX(0,L6-CI6)
    for i in 0..<8760 { r3[CK + i] = max(0, r3[L + i] - r3[CI + i]) }

    /// Available heat from CSP after TES
    let CL = 148920
    // MAX(0,J6-CJ6)
    for i in 0..<8760 { r3[CL + i] = max(0, r3[J + i] - r3[CJ + i]) }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let CM = 157680
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(BY6=0,AND(BY6>0,CC6=0)),PB_stby_aux_cons+BZ6*TES_aux_cons_perc,(BZ6+CA6+CB6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      r3[CM + i] =
        iff(r3[J + i] > 0, r3[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + r3[M + i]
        + (r3[CI + i] * Heater_eff + r3[CJ + i]) * TES_aux_cons_perc
        + iff(
          or(r3[BY + i] = 0, and(r3[BY + i] > 0, r3[CC + i] = 0)),
          PB_stby_aux_cons + r3[BZ + i] * TES_aux_cons_perc,
          (r3[BZ + i] + r3[CA + i] + r3[CB + i]) * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let CN = 166440
    // MAX(0,-(L6+IF(CC6>0,BX6,0)-CI6-CM6))
    for i in 0..<8760 {
      r3[CN + i] = max(
        0, -(r3[L + i] + iff(r3[CC + i] > 0, r3[BX + i], 0) - r3[CI + i] - r3[CM + i]))
    }

  }
}
extension TunOl {
  func hourly(r3: [Double], r4: inout [Double]) {
    let BX = 26280
    let CB = 61320
    let CC = 70080
    let CK = 140160
    let CL = 148920
    let CM = 157680
    let CN = 166440
    /// Min harmonious net elec cons not considering grid import
    let CP = 0
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      r4[CP + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r3[CM + i] - r3[CN + i]),
          min(
            r3[CL + i] + El_boiler_cap_ud * El_boiler_eff,
            (r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r3[CM + i] - r3[CN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r3[CM + i] - r3[CN + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r3[CL + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let CQ = 8760
    // IF(AND(CP6>0,CP5=0,OR(CP6=0,CP7=0)),0,CP6)
    for i in 0..<8760 {
      r4[CQ + i] = iff(
        and(r4[CP + i] > 0, r4[CP + i - 1] == 0, or(r4[CP + i] == 0, r4[CP + i] = 0)), 0, r4[CP + i])
    }

    /// Min harmonious net heat cons
    let CR = 17520
    // CQ6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r4[CR + i] =
        r4[CQ + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let CS = 26280
    // IF(AND(CQ5<=0,CQ6>0),CS5+1,IF(AND(CK6>0,BO6<>BO5,SUM(CQ6:CQ8)=0),CS5+1,CS5))
    for i in 0..<8760 {
      r4[CS + i] = iff(
        and(r4[CQ + i - 1] <= 0, r4[CQ + i] > 0), r4[CS + i - 1] + 1,
        iff(
          and(r3[CK + i] > 0, r4[BO + i]  == r4[BO + i - 1], SUM(r4[(CQ + i)...].prefix(3)) = 0),
          r4[CS + i - 1] + 1, r4[CS + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let CT = 35040
    // IF(OR(CQ6>0,CC6=0),0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      r4[CT + i] = iff(
        or(r4[CQ + i] > 0, r3[CC + i] = 0), 0,
        min(
          (r3[BX + i] + r3[CK + i] + (r3[CL + i] + r3[CB + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (r3[CM + i] - r3[CN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(r4[CQ + i] == 0, 0, overall_stup_cons[j])
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(r4[CR + i] == 0, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(r4[CQ + i] == 0, 0, overall_stup_cons[j])),
          overall_var_min_cons[j] + overall_fix_stby_cons[j]
            + iff(r4[CQ + i] == 0, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let CU = 43800
    // IF(CT6=0,0,MIN((BX6+CK6+(CL6+CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(CM6-CN6))/(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)),A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      r4[CU + i] = iff(
        r4[CT + i] == 0, 0,
        min(
          (r3[BX + i] + r3[CK + i] + (r3[CL + i] + r3[CB + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (r3[CM + i] - r3[CN + i]))
            / (overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(r4[CQ + i + 1] = 0, 0, overall_stup_cons[j])
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
                + iff(r4[CR + i] == 0, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
            * (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
              + iff(r4[CR + i] == 0, 0, overall_heat_stup_cons[j])),
          overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(r4[CR + i] == 0, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let CV = 52560
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))
    for i in 0..<8760 {
      r4[CV + i] = max(
        0,
        iff(r3[CC + i] > 0, r3[BX + i], 0) + r3[CK + i] - (r3[CM + i] - r3[CN + i]) - r4[CQ + i]
          - r4[CT + i]
          - max(
            0,
            (r4[CR + i] + r4[CU + i]
              - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0) - r3[CL + i])
              / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let CW = 61320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 0..<8760 {
      r4[CW + i] = max(
        0,
        r3[CL + i] + iff(r3[CC + i] == 0, 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output)
          - r4[CR + i] - r4[CU + i])
    }

    /// Grid import necessary for min harm
    let CX = 70080
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      r4[CX + i] = max(
        0,
        -(iff(r3[CC + i] > 0, r3[BX + i], 0) + r3[CK + i] - (r3[CM + i] - r3[CN + i]) - r4[CQ + i]
          - r4[CT + i]
          - max(
            0,
            (r4[CR + i] + r4[CU + i]
              - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0) - r3[CL + i])
              / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let CY = 78840
    // Grid_import_max_ud-CX6
    for i in 0..<8760 { r4[CY + i] = Grid_import_max_ud - r4[CX + i] }

    /// El boiler op after min harmonious heat cons
    let CZ = 87600
    // MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      r4[CZ + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (r4[CR + i] + r4[CU + i] - r3[CL + i]
            - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0)) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let DA = 96360
    // MAX(0,El_boiler_cap_ud-CZ6)
    for i in 0..<8760 { r4[DA + i] = max(0, El_boiler_cap_ud - r4[CZ + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let DB = 105120
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r4[DB + i] =
        max(
          0,
          1
            - ((max(0, r4[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let DC = 113880
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r4[DC + i] =
        max(
          0,
          1
            - ((max(0, r4[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let DD = 122640
    // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r4[DD + i] =
        max(
          0,
          1
            - ((max(0, r4[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let DE = 131400
    // MIN(BESS_chrg_max_cons,CV6)
    for i in 0..<8760 { r4[DE + i] = min(BESS_chrg_max_cons, r4[CV + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DF = 140160
    // MIN(Grid_export_max_ud,CV6)
    for i in 0..<8760 { r4[DF + i] = min(Grid_export_max_ud, r4[CV + i]) }

    /// Max harmonious net elec cons without considering grid
    let DG = 148920
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6),MIN(CL6+El_boiler_cap_ud*El_boiler_eff,(CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(CM6-CN6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-CL6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      r4[DG + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r3[CM + i] - r3[CN + i]),
          min(
            r3[CL + i] + El_boiler_cap_ud * El_boiler_eff,
            (r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r3[CM + i] - r3[CN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r3[CM + i] - r3[CN + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r3[CL + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r3[CM + i] - r3[CN + i]),
          min(
            r3[CL + i] + El_boiler_cap_ud * El_boiler_eff,
            (r3[CK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r3[CM + i] - r3[CN + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r3[CM + i] - r3[CN + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r3[CL + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let DH = 157680
    // IF(AND(DG6>0,DG5=0,OR(DG6=0,DG7=0)),0,DG6)
    for i in 0..<8760 {
      r4[DH + i] = iff(
        and(r4[DG + i] > 0, r4[DG + i - 1] == 0, or(r4[DG + i].isZero, r4[DG + i + 4].isZero)), 0, r4[DG + i])
    }

    /// max harmonious net heat cons
    let DI = 166440
    // DH6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r4[DI + i] =
        r4[DH + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let DJ = 175200
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))
    for i in 0..<8760 {
      r4[DJ + i] = max(
        0,
        iff(r3[CC + i] > 0, r3[BX + i], 0) + r3[CK + i] - (r3[CM + i] - r3[CN + i]) - r4[DH + i]
          - r4[CT + i]
          - max(
            0,
            (r4[DI + i] + r4[CU + i]
              - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0) - r3[CL + i])
              / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let DK = 183960
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 0..<8760 {
      r4[DK + i] = max(
        0,
        r3[CL + i] + iff(r3[CC + i].isZero, 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output)
          - r4[DI + i] - r4[CU + i])
    }

    /// Grid import necessary for max harm
    let DL = 192720
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 0..<8760 {
      r4[DL + i] = max(
        0,
        -(iff(r3[CC + i] > 0, r3[BX + i], 0) + r3[CK + i] - (r3[CM + i] - r3[CN + i]) - r4[DH + i]
          - r4[CT + i]
          - max(
            0,
            (r4[DI + i] + r4[CU + i]
              - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0) - r3[CL + i])
              / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let DM = 201480
    // Grid_import_max_ud-DL6
    for i in 0..<8760 { r4[DM + i] = Grid_import_max_ud - r4[DL + i] }

    /// El boiler op after max harmonious heat cons
    let DN = 210240
    // MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 0..<8760 {
      r4[DN + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (r4[DI + i] + r4[CU + i] - r3[CL + i]
            - iff(r3[CC + i] > 0, r3[CB + i] / PB_Ratio_Heat_input_vs_output, 0)) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let DO = 219000
    // MAX(0,El_boiler_cap_ud-DN6)
    for i in 0..<8760 { r4[DO + i] = max(0, El_boiler_cap_ud - r4[DN + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let DP = 227760
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r4[DP + i] =
        max(
          0,
          1
            - ((max(0, r4[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let DQ = 236520
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r4[DQ + i] =
        max(
          0,
          1
            - ((max(0, r4[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let DR = 245280
    // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r4[DR + i] =
        max(
          0,
          1
            - ((max(0, r4[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let DS = 254040
    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 0..<8760 { r4[DS + i] = min(BESS_chrg_max_cons, r4[DJ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DT = 262800
    // MIN(Grid_export_max_ud,DJ6)
    for i in 0..<8760 { r4[DT + i] = min(Grid_export_max_ud, r4[DJ + i]) }

  }
}
extension TunOl {
  func hourly(r5: inout [Double]) {

    /// Maximum night op perc considering tank sizes
    let DV = 0
    // VLOOKUP(BO6,DailyCalc_1A3:R367,COLUMN(DailyCalc_1R3))
    // for i in 0..<8760 {
    //   r5[DV + i] = VLOOKUP(
    //     r5[BO + i], DailyCalc_1[(A + i)...].prefix(), COLUMN(DailyCalc_1r5[R + i]))
    // }

    /// Max net elec demand outside harm op period
    let DW = 8760
    // IF(BM6>0,0,IF(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+BK6+IF(BM7=0,0,A_overall_stup_cons)+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      r5[DW + i] = iff(
        r5[BM + i] > 0, 0,
        iff(
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + r5[BK + i] + iff(r5[BM + i] = 0, 0, overall_stup_cons[j])
            + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(r5[BM + i] = 0, 0, overall_heat_stup_cons[j])
                - r5[BQ + i]) / El_boiler_eff < r5[BP + i] - PB_stby_aux_cons, 0,
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + iff(r5[BM + i] = 0, 0, overall_stup_cons[j])))
    }

    /// Optimized max net elec demand outside harm op period
    let DX = 17520
    // IF(AND(DW7>0,DW6=0,DW5>0),DW5,DW6)
    for i in 0..<8760 {
      r5[DX + i] = iff(
        and(r5[DW + i] > 0, r5[DW + i] = 0, r5[DW + i - 1] > 0), r5[DW + i - 1], r5[DW + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let DY = 26280
    // IF(DX6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,DX6+BK6-BP6))-PB_net_min_cap))+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(DX6=0,DX7>0),MAX(0,IF(COUNTIF(DX1:DX6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      r5[DY + i] = iff(
        r5[DX + i] = 0, 0,
        r5[BK + i]
          + ((min(
            PB_nom_net_cap,
            max(PB_net_min_cap, (1 + TES_aux_cons_perc) * (r5[DX + i] + r5[BK + i] - r5[BP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap, (1 + TES_aux_cons_perc) * (r5[DX + i] + r5[BK + i] - r5[BP + i]))
              ) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(0, r5[DX + i] + r5[BK + i] - r5[BP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] - r5[BQ + i]) * PB_Ratio_Heat_input_vs_output)
          * TES_aux_cons_perc
          + iff(
            and(r5[DX + i] = 0, r5[DX + i] > 0),
            max(
              0,
              iff(
                countiff([(DX + i)...].prefix(6), { $0.isZero }) = PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - r5[BQ + i]) * TES_aux_cons_perc, 0
          ))
    }

    /// Corresponding max PB net elec output
    let DZ = 35040
    // IF(DX6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-BP6)))
    for i in 0..<8760 {
      r5[DZ + i] = iff(
        r5[DX + i] = 0, 0,
        max(PB_net_min_cap, min(PB_nom_net_cap, r5[DX + i] + r5[DY + i] - r5[BP + i])))
    }

    /// Corresponding max PB gross elec output
    let EA = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      r5[EA + i] = iff(
        r5[DZ + i] == 0, 0,
        r5[DZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(r5[DZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let EB = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      r5[EB + i] = iff(
        and(r5[EA + i] = 0, r5[EA + i] > 0),
        iff(
          countiff([(EA + i)...].prefix(6), { $0.isZero }) = PB_warm_start_duration,
          PB_warm_start_heat_req, PB_hot_start_heat_req), 0)
    }

    /// Max gross heat cons for ST
    let EC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      r5[EC + i] = iff(
        r5[EA + i] = 0, 0,
        r5[EA + i] / PB_nom_gross_eff / POLY(r5[EA + i] / PB_nom_gross_cap_ud, el_Coeff))
    }

    /// Max gross heat cons for extraction
    let ED = 70080
    // IF(EC6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(DZ6-DY6+BP6)/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,DZ6-DX6-DY6)*El_boiler_eff)))
    for i in 0..<8760 {
      r5[ED + i] = iff(
        r5[EC + i] = 0, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j]
                + iff(r5[BM + i] = 0, 0, overall_heat_stup_cons[j]),
              (r5[DZ + i] - r5[DY + i] + r5[BP + i])
                / (((overall_var_max_cons[j] - overall_var_min_cons[j])
                  * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
                  + overall_fix_stby_cons[j] + iff(r5[BM + i] = 0, 0, overall_stup_cons[j]))
                * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                  * (r5[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                  + overall_heat_fix_stby_cons[j]
                  + iff(r5[BM + i] = 0, 0, overall_heat_stup_cons[j]))) - r5[BQ + i] - max(
                0, r5[DZ + i] - r5[DX + i] - r5[DY + i]) * El_boiler_eff)))
    }

    /// TES energy available if above min op case
    let EE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 0..<8760 {
      r5[EE + i] = iff(
        r5[CC + i] = 0, 0,
        min(
          sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap,
          sum[i] + sum[i] + sum[i]))
    }

    /// Effective gross heat cons for ST
    let EF = 87600
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*EC6)
    for i in 0..<8760 {
      r5[EF + i] = iff(r5[EE + i] == 0, 0, (r5[EE + i] - sum[i]) / (sum[i] + sum[i]) * r5[EC + i])
    }

    /// Effective PB gross elec output
    let EG = 96360
    // IF(EF6=0,0,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      r5[EG + i] = iff(
        r5[EF + i] = 0, 0,
        r5[EF + i] * PB_nom_gross_eff * POLY(r5[EF + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let EH = 105120
    // IF(EG6=0,0,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      r5[EH + i] = iff(
        r5[EG + i] = 0, 0,
        r5[EG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(r5[EG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let EI = 113880
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*ED6)
    for i in 0..<8760 {
      r5[EI + i] = iff(r5[EE + i] == 0, 0, (r5[EE + i] - sum[i]) / (sum[i] + sum[i]) * r5[ED + i])
    }

    /// TES energy to fulfil op case if above
    let EJ = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763),EE6,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))
    // for i in 0..<8760 {
    //   r5[EJ + i] = iff(
    //     min(sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < sum[i] + sum[i]
    //       + sum[i], r5[EE + i], sum[i] + sum[i] + sum[i])
    // }

    /// Surplus TES energy due to op case
    let EK = 131400
    // IF(EJ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EJ6))
    for i in 0..<8760 {
      r5[EK + i] = iff(
        r5[EJ + i] == 0, 0, max(0, sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - r5[EJ + i])
      )
    }

    /// Peripherial PV hour PV to heater
    let EL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      r5[EL + i] = iff(
        or(
          and(r5[EK + i] > 0, r5[AY + i] > 0, r5[AY + i - 1] = 0),
          and(r5[EK + i] > 0, r5[AY + i] = 0, r5[AY + i] > 0)), r5[AY + i], 0)
    }

    /// Surplus energy due to op limit after removal of peripherial hours
    let EM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    let sumEL = r5.sum(hours: [[Int]], condition: Int, predicate: (Double) -> Bool)
    for i in 0..<8760 {
      r5[EM + i] = max(0, r5[EK + i] - sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let EN = 157680
    // IF(EK6=0,0,AY6-(EK6-EM6)/(SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6)
    for i in 0..<8760 {
      r5[EN + i] = iff(
        r5[EK + i] = 0, 0,
        r5[AY + i] - (r5[EK + i] - r5[EM + i])
          / (sum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * r5[EL + i])
    }

    /// Partitions of PV hour PV to be dedicated to TES chrg
    let EO = 166440
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 0..<8760 {
      r5[EO + i] = iff(
        or(r5[EN + i] = 0, r5[EM + i] = 0), 0,
        max(
          (r5[AW + i] - r5[EN + i])
            / (r5[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i]),
          (r5[J + i] - r5[EN + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (r5[EM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i])) / sum[i]
          * r5[EN + i])
    }

    /// corrected max possible PV elec to TES
    let EP = 175200
    // IF(EJ6=0,0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,EO5:EO8763)*EO6))
    for i in 0..<8760 {
      r5[EP + i] = iff(
        r5[EJ + i] == 0, 0,
        r5[EN + i]
          - iff(
            r5[EM + i] == 0, 0,
            r5[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / sum[i] * r5[EO + i]))
    }

    /// Max possible CSP heat to TES
    let EQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      r5[EQ + i] = min(r5[J + i], r5[EP + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let ER = 192720
    // MAX(0,L6-EP6)
    for i in 0..<8760 { r5[ER + i] = max(0, r5[L + i] - r5[EP + i]) }

    /// Available heat from CSP after TES
    let ES = 201480
    // MAX(0,J6-EQ6)
    for i in 0..<8760 { r5[ES + i] = max(0, r5[J + i] - r5[EQ + i]) }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let ET = 210240
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(EH6=0,PB_stby_aux_cons+EB6*TES_aux_cons_perc,(EB6+EF6+EI6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      r5[ET + i] =
        iff(r5[J + i] > 0, r5[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + r5[M + i]
        + (r5[EP + i] * Heater_eff + r5[EQ + i]) * TES_aux_cons_perc
        + iff(
          r5[EH + i] = 0, PB_stby_aux_cons + r5[EB + i] * TES_aux_cons_perc,
          (r5[EB + i] + r5[EF + i] + r5[EI + i]) * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let EU = 219000
    // MAX(0,-(L6+IF(EJ6>0,DZ6,0)-EP6-ET6))
    for i in 0..<8760 {
      r5[EU + i] = max(
        0, -(r5[L + i] + iff(r5[EJ + i] > 0, r5[DZ + i], 0) - r5[EP + i] - r5[ET + i]))
    }

  }
}
extension TunOl {
  func hourly(r5: [Double], r6: inout [Double]) {
    let ET = 210240
    let EU = 219000
    /// Min harmonious net elec cons not considering grid import
    let EW = 0
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      r6[EW + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r5[ET + i] - r5[EU + i]),
          min(
            r6[ES + i] + El_boiler_cap_ud * El_boiler_eff,
            (r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r5[ET + i] - r5[EU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r5[ET + i] - r5[EU + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r6[ES + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let EX = 8760
    // IF(AND(EW6>0,EW5=0,OR(EW6=0,EW7=0)),0,EW6)
    for i in 0..<8760 {
      r6[EX + i] = iff(
        and(r6[EW + i] > 0, r6[EW + i - 1] == 0, or(r6[EW + i] = 0, r6[EW + i] = 0)), 0, r6[EW + i])
    }

    /// Min harmonious net heat cons
    let EY = 17520
    // EX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r6[EY + i] =
        r6[EX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let EZ = 26280
    // IF(AND(EX5<=0,EX6>0),EZ5+1,IF(AND(ER6>0,BO6<>BO5,SUM(EX6:EX8)=0),EZ5+1,EZ5))
    for i in 0..<8760 {
      r6[EZ + i] = iff(
        and(r6[EX + i - 1] <= 0, r6[EX + i] > 0), r6[EZ + i - 1] + 1,
        iff(
          and(r6[ER + i] > 0, r6[BO + i] == r6[BO + i - 1], SUM(r6[(EX + i)...].prefix(3)) = 0),
          r6[EZ + i - 1] + 1, r6[EZ + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let FA = 35040
    // IF(OR(EX6>0,EJ6=0),0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)),((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      r6[FA + i] = iff(
        or(r6[EX + i] > 0, r6[EJ + i] = 0), 0,
        min(
          (r6[EH + i] + r6[ER + i] + (r6[ES + i] + r6[EI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (r5[ET + i] - r5[EU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(r6[EX + i] = 0, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(r6[EY + i] = 0, 0, overall_heat_stup_cons[j]))
                / El_boiler_eff)
            * (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(r6[EX + i] = 0, 0, overall_stup_cons[j])),
          ((overall_var_max_cons[j] - overall_var_min_cons[j])
            * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
            + overall_fix_stby_cons[j] + iff(r6[EX + i] = 0, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let FB = 43800
    // IF(FA6=0,0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)),((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      r6[FB + i] = iff(
        r6[FA + i] = 0, 0,
        min(
          (r6[EH + i] + r6[ER + i] + (r6[ES + i] + r6[EI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff - (r5[ET + i] - r5[EU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j])
              * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j])
              + overall_fix_stby_cons[j] + iff(r6[EX + i] = 0, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(r6[EY + i] = 0, 0, overall_heat_stup_cons[j]))
                / El_boiler_eff)
            * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
              * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
              + overall_heat_fix_stby_cons[j] + iff(r6[EY + i] = 0, 0, overall_heat_stup_cons[j])),
          ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
            * (r6[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
            + overall_heat_fix_stby_cons[j] + iff(r6[EY + i] = 0, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let FC = 52560
    // MAX(0,EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      r6[FC + i] = max(
        0,
        r6[EH + i] + r6[ER + i] - (r5[ET + i] - r5[EU + i]) - r6[EX + i] - r6[FA + i]
          - max(
            0,
            (r6[EY + i] + r6[FB + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[ES + i])
              / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let FD = 61320
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 0..<8760 {
      r6[FD + i] = max(
        0, r6[ES + i] + r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[EY + i] - r6[FB + i])
    }

    /// Grid import necessary for min harm
    let FE = 70080
    // MAX(0,-(EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      r6[FE + i] = max(
        0,
        -(r6[EH + i] + r6[ER + i] - (r5[ET + i] - r5[EU + i]) - r6[EX + i] - r6[FA + i]
          - max(
            0,
            (r6[EY + i] + r6[FB + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[ES + i])
              / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let FF = 78840
    // Grid_import_max_ud-FE6
    for i in 0..<8760 { r6[FF + i] = Grid_import_max_ud - r6[FE + i] }

    /// El boiler op after min harmonious heat cons
    let FG = 87600
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      r6[FG + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (r6[EY + i] + r6[FB + i] - r6[ES + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let FH = 96360
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 0..<8760 { r6[FH + i] = max(0, El_boiler_cap_ud - r6[FG + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let FI = 105120
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r6[FI + i] =
        max(
          0,
          1
            - ((max(0, r6[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let FJ = 113880
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r6[FJ + i] =
        max(
          0,
          1
            - ((max(0, r6[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let FK = 122640
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r6[FK + i] =
        max(
          0,
          1
            - ((max(0, r6[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let FL = 131400
    // MIN(BESS_chrg_max_cons,FC6)
    for i in 0..<8760 { r6[FL + i] = min(BESS_chrg_max_cons, r6[FC + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let FM = 140160
    // MIN(Grid_export_max_ud,FC6)
    for i in 0..<8760 { r6[FM + i] = min(Grid_export_max_ud, r6[FC + i]) }

    /// Max harmonious net elec cons without considering grid
    let FN = 148920
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      r6[FN + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r5[ET + i] - r5[EU + i]),
          min(
            r6[ES + i] + El_boiler_cap_ud * El_boiler_eff,
            (r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r5[ET + i] - r5[EU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r5[ET + i] - r5[EU + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r6[ES + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons))
          < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (r5[ET + i] - r5[EU + i]),
          min(
            r6[ES + i] + El_boiler_cap_ud * El_boiler_eff,
            (r6[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (r5[ET + i] - r5[EU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (r5[ET + i] - r5[EU + i])
                + max(
                  0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - r6[ES + i]))
                / El_boiler_eff) * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let FO = 157680
    // IF(AND(FN6>0,FN5=0,OR(FN6=0,FN7=0)),0,FN6)
    for i in 0..<8760 {
      r6[FO + i] = iff(
        and(r6[FN + i] > 0, r6[FN + i - 1] = 0, or(r6[FN + i] = 0, r6[FN + i] = 0)), 0, r6[FN + i])
    }

    /// max harmonious net heat cons
    let FP = 166440
    // FO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      r6[FP + i] =
        r6[FO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let FQ = 175200
    // MAX(0,EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      r6[FQ + i] = max(
        0,
        r6[EH + i] + r6[ER + i] - (r5[ET + i] - r5[EU + i]) - r6[FO + i] - r6[FA + i]
          - max(
            0,
            (r6[FP + i] + r6[FB + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[ES + i])
              / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let FR = 183960
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 0..<8760 {
      r6[FR + i] = max(
        0, r6[ES + i] + r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[FP + i] - r6[FB + i])
    }

    /// Grid import necessary for max harm
    let FS = 192720
    // MAX(0,-(EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      r6[FS + i] = max(
        0,
        -(r6[EH + i] + r6[ER + i] - (r5[ET + i] - r5[EU + i]) - r6[FO + i] - r6[FA + i]
          - max(
            0,
            (r6[FP + i] + r6[FB + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output - r6[ES + i])
              / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let FT = 201480
    // Grid_import_max_ud-FS6
    for i in 0..<8760 { r6[FT + i] = Grid_import_max_ud - r6[FS + i] }

    /// El boiler op after max harmonious heat cons
    let FU = 210240
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      r6[FU + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (r6[FP + i] + r6[FB + i] - r6[ES + i] - r6[EI + i] / PB_Ratio_Heat_input_vs_output)
            / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let FV = 219000
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 0..<8760 { r6[FV + i] = max(0, El_boiler_cap_ud - r6[FU + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let FW = 227760
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      r6[FW + i] =
        max(
          0,
          1
            - ((max(0, r6[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let FX = 236520
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      r6[FX + i] =
        max(
          0,
          1
            - ((max(0, r6[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let FY = 245280
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      r6[FY + i] =
        max(
          0,
          1
            - ((max(0, r6[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let FZ = 254040
    // MIN(BESS_chrg_max_cons,FQ6)
    for i in 0..<8760 { r6[FZ + i] = min(BESS_chrg_max_cons, r6[FQ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let GA = 262800
    // MIN(Grid_export_max_ud,FQ6)
    for i in 0..<8760 { r6[GA + i] = min(Grid_export_max_ud, r6[FQ + i]) }

  }
}
