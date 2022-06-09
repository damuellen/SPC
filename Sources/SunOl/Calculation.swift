extension TunOl {
  func hour0(_ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double], _ Reference_PV_MV_power_at_transformer_outlet: [Double]) -> [Double] {
    var hour0 = [Double](repeating: .zero, count: 350_400)

    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    /// Inverter power fraction -
    let H = 8760
    /// Inverter efficiency -
    let I = 17520
    /// Q_solar (before dumping) MWth
    let J = 26280
    /// E_PV_Total _Scaled MWel_DC
    let K = 35040
    /// PV MV net power at transformer outlet MWel
    let L = 43800
    /// PV aux consumption at transformer level MWel
    let M = 52560
    /// Aux elec for PB stby, CSP SF and PV Plant MWel
    let O = 61320
    /// Available PV power MWel
    let P = 70080
    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let Q = 78840
    for i in 1..<8760 {
      hour0[i] = Reference_PV_plant_power_at_inverter_inlet_DC[i]
      // MAX(0,G6/MAX(G5:G8763))
      hour0[H + i] = max(.zero, Reference_PV_MV_power_at_transformer_outlet[i] / maximum)
      // IFERROR(IF(G6<MAX(G5:G8763),MAX(G6,0)/F6,0),0)
      hour0[I + i] = ifFinite(iff(Reference_PV_MV_power_at_transformer_outlet[i] < maximum, max(Reference_PV_MV_power_at_transformer_outlet[i], .zero) / Reference_PV_plant_power_at_inverter_inlet_DC[i], .zero), .zero)
      // E6*CSP_loop_nr_ud
      hour0[J + i] = Q_Sol_MW_thLoop[i] * CSP_loop_nr_ud
      // F6*PV_DC_cap_ud/PV_Ref_DC_cap
      hour0[K + i] = Reference_PV_plant_power_at_inverter_inlet_DC[i] * PV_DC_cap_ud / PV_Ref_DC_cap
      // MIN(PV_AC_cap_ud,IF(K6/PV_DC_cap_ud>Inv_eff_Ref_approx_handover,K6*POLY(K6/PV_DC_cap_ud,HL_Coeff),IF(K6/PV_DC_cap_ud>0,K6*POLY(K6/PV_DC_cap_ud,LL_Coeff),0)))
      hour0[L + i] = min(PV_AC_cap_ud, iff(hour0[K + i] / PV_DC_cap_ud > Inv_eff_Ref_approx_handover, hour0[K + i] * POLY(hour0[K + i] / PV_DC_cap_ud, HL_Coeff), iff(hour0[K + i] / PV_DC_cap_ud > .zero, hour0[K + i] * POLY(hour0[K + i] / PV_DC_cap_ud, LL_Coeff), .zero)))
      // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
      let m = max(.zero, -Reference_PV_MV_power_at_transformer_outlet[i] / PV_Ref_AC_cap * PV_AC_cap_ud)
      hour0[M + i] = m
      // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+PB_stby_aux_cons
      hour0[O + i] = iff(hour0[J + i] > .zero, hour0[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[M + i] + PB_stby_aux_cons
      // MAX(0,L6-O6)
      hour0[P + i] = max(.zero, hour0[L + i] - hour0[O + i])
      // MAX(0,O6-P6)
      hour0[Q + i] = max(.zero, hour0[O + i] - hour0[P + i])
    }

    /// Min harmonious net elec cons
    let R = 87600
    // IF(MIN(MAX(0;P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-MIN(El_boiler_cap_ud;MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-J6)/El_boiler_eff));MAX(0;J6+MIN(El_boiler_cap_ud;MAX(0;P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons;0;Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour0[R + i] = iff(
        min(
          max(.zero, hour0[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - min(El_boiler_cap_ud, max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour0[J + i]) / El_boiler_eff)),
          max(.zero, hour0[J + i] + min(El_boiler_cap_ud, max(.zero, hour0[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons)
          < Overall_harmonious_var_min_cons + Overall_fix_cons, .zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let S = 96360
    // IF(OR(AND(R6>0,R5=0,R7=0),AND(R6>0,OR(AND(R4=0,R5=0,R8=0),AND(R4=0,R7=0,R8=0)))),0,R6)
    for i in 1..<8760 { hour0[S + i] = iff(or(and(hour0[R + i] > .zero, hour0[R + i - 1].isZero, hour0[R + i + 1].isZero), and(hour0[R + i] > .zero, or(and(hour0[R + i - 2].isZero, hour0[R + i - 1] > 0, hour0[R + i + 1].isZero), and(hour0[R + i - 1].isZero, hour0[R + i + 1] > 0, hour0[R + i + 2].isZero)))), 0, hour0[R + i]) }

    /// Min harmonious net heat cons
    let T = 105120
    // =IF(S6=0,0,MAX(0,(S6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))
    for i in 1..<8760 { hour0[T + i] = iff(hour0[S + i].isZero, .zero, max(.zero, (hour0[S + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Harmonious op day
    let U = 113880
    // IF(OR(AND(S5<=0,S6>0,SUM(S1:S5)=0),AND($F5<=0,$F6>0,SUM(S4:S18)=0)),IF(U5<364,U5+1,0),U5)
    for i in 12..<8748 {
      hour0[U + i] = hour0[U + i - 1]
      if hour0[S + i - 1].isZero, hour0[S + i] > 0, hour0[S + i + 1] > 0, hour0[(U + i - 12)..<(U + i)].allSatisfy( { $0 == hour0[U + i] }) {
        hour0[U + i] += 1
      } else if hour0[i - 1].isZero, hour0[i] > 0, hour0[S + i..<S + i + 12].allSatisfy(\.isZero), hour0[U + i - 12..<U + i].allSatisfy({ $0 == hour0[U + i] }) {
        hour0[U + i] += 1
      }
    }
    for i in 8748..<8760 { hour0[U + i] = hour0[U + i - 1] }
    /// Remaining PV after min harmonious
    let V = 122640
    // MAX(0,$P6-$Q6-S6-MIN(El_boiler_cap_ud,MAX(0,(T6-$J6)/El_boiler_eff)))
    for i in 1..<8760 { hour0[V + i] = max(.zero, hour0[P + i] - hour0[Q + i] - hour0[S + i] - min(El_boiler_cap_ud, max(.zero, (hour0[T + i] - hour0[J + i]) / El_boiler_eff))) }

    /// Remaining CSP heat after min harmonious
    let W = 131400
    // MAX(0,J6-T6)
    for i in 1..<8760 { hour0[W + i] = max(.zero, hour0[J + i] - hour0[T + i]) }

    /// Grid import necessary for min harmonious
    let X = 140160
    // =ROUND(MAX(0,-($P5-$Q5-S5-MIN(El_boiler_cap_ud,MAX(0,(T5-$J5)/El_boiler_eff)))),5)
    for i in 1..<8760 { hour0[X + i] = round(max(.zero, -(hour0[P + i] - hour0[Q + i] - hour0[S + i] - min(El_boiler_cap_ud, max(.zero, (hour0[T + i] - hour0[J + i]) / El_boiler_eff)))),5) }

    let N = 341640
    // MIN(IF(S5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud,X5)
    for i in 1..<8760 { hour0[N + i] = min(iff(hour0[S + i] > 0, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud, hour0[X + i]) }

    /// Remaining grid import capacity after min harmonious
    let Y = 148920
    // =MAX(0,IF(S5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud-N5)
    for i in 1..<8760 { hour0[Y + i] = max(.zero, iff(hour0[S + i] > 0,Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud - hour0[N + i]) }

    /// El to el boiler after min harm heat cons
    let Z = 157680
    // MAX(0,MIN(El_boiler_cap_ud,(T6-$J6)/El_boiler_eff))
    for i in 1..<8760 { hour0[Z + i] = max(.zero, min(El_boiler_cap_ud, (hour0[T + i] - hour0[J + i]) / El_boiler_eff)) }

    /// Remaining el boiler cap after min harm heat cons
    let AA = 166440
    // MAX(0,El_boiler_cap_ud-Z6)
    for i in 1..<8760 { hour0[AA + i] = max(.zero, El_boiler_cap_ud - hour0[Z + i]) }

    /// Remaining MethSynt cap after min harm cons
    let AB = 175200
    /// Remaining CCU cap after min harm cons
    let AC = 183960
    /// Remaining EY cap after min harm cons
    let AD = 192720
    for i in 1..<8760 {
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction = (max(.zero, hour0[S + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour0[AB + i] = max(.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      hour0[AC + i] = max(.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // MAX(0;1-((MAX(0;S6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour0[AD + i] = max(.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harm cons
    let AE = 201480
    /// Max grid export after min harm cons
    let AF = 210240
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,V6)
      hour0[AE + i] = min(BESS_chrg_max_cons, hour0[V + i])
      // =MIN(IF(S5>0,Grid_export_yes_no_BESS_strategy,Grid_export_yes_no_BESS_strategy_outsideharmop)*Grid_export_max_ud,V5)
      hour0[AF + i] = min(
        iff(hour0[S + i] > 0, Grid_export_yes_no_BESS_strategy, Grid_export_yes_no_BESS_strategy_outsideharmop) * Grid_export_max_ud, hour0[V + i])
    }

    /// Max harm net elec cons
    let AG = 219000
    // =IF(S5=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,P5+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-Q5-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-J5)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,J5-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,P5+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-Q5-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,J5+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      hour0[AG + i] = iff(
        hour0[S + i].isZero, .zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons
          + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            1,
            max(
              .zero,
              hour0[P + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
                - hour0[Q + i] - Overall_harmonious_var_min_cons - Overall_fix_cons
                - max(
                  .zero,
                  Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons
                    - hour0[J + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons
                + (Overall_harmonious_var_heat_max_cons
                  - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              .zero,
              hour0[J + i] - Overall_harmonious_var_heat_min_cons
                - Overall_heat_fix_cons + max(
                  .zero,
                  hour0[P + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
                    - hour0[Q + i] - Overall_harmonious_var_min_cons
                    - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons
                - Overall_harmonious_var_heat_min_cons
                + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * El_boiler_eff),
            max(
              .zero,
              hour0[J + i] + El_boiler_cap_ud * El_boiler_eff
                - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
              / (Overall_harmonious_var_heat_max_cons
                - Overall_harmonious_var_heat_min_cons)))
    }

    /// Optimized max harm net elec cons
    let AH = 227760
    // IF(OR(AND(AG6>0,AG5=0,AG7=0),AND(AG6>0,OR(AND(AG4=0,AG5>0,AG7=0),AND(AG5=0,AG7>0,AG8=0)))),0,AG6)
    for i in 1..<8760 {
      hour0[AH + i] = iff(or(and(hour0[AG + i] > .zero, hour0[AG + i - 1].isZero, hour0[AG + i + 1].isZero), and(hour0[AG + i] > .zero, or(and(hour0[AG + i - 2].isZero, hour0[AG + i - 1] > 0, hour0[AG + i + 1].isZero), and(hour0[AG + i - 1].isZero, hour0[AG + i + 1] > 0, hour0[AG + i + 2].isZero)))), 0, hour0[AG + i])
    }

    /// max harm net heat cons
    let AI = 236520
    // IF(AH6=0,0,MAX(0,(AH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))
    for i in 1..<8760 { hour0[AI + i] = iff(hour0[AH + i].isZero, .zero, max(.zero, (hour0[AH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Remaining PV after max harm
    let AJ = 245280
    // MAX(0,$P6-$Q6-AH6-MIN(El_boiler_cap_ud,MAX(0,(AI6-$J6)/El_boiler_eff)))
    for i in 1..<8760 { hour0[AJ + i] = max(.zero, hour0[P + i] - hour0[Q + i] - hour0[AH + i] - min(El_boiler_cap_ud, max(.zero, (hour0[AI + i] - hour0[J + i]) / El_boiler_eff))) }

    /// Remaining CSP heat after max harm
    let AK = 254040
    // MAX(0,J6-AI6)
    for i in 1..<8760 { hour0[AK + i] = max(.zero, hour0[J + i] - hour0[AI + i]) }

    /// Grid import necessary for max harm
    let AL = 262800
    // =ROUND(MAX(0,-($P6-$Q6-AH6-MIN(El_boiler_cap_ud,MAX(0,(AI6-$J6)/El_boiler_eff)))),5)
    for i in 1..<8760 { hour0[AL + i] = round(max(.zero, -(hour0[P + i] - hour0[Q + i] - hour0[AH + i] - min(El_boiler_cap_ud, max(.zero, (hour0[AI + i] - hour0[J + i]) / El_boiler_eff)))),5) }

    let AU = 271560
    // =MIN(IF(AH5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud,AL5)
    for i in 1..<8760 { hour0[AU + i] = min(iff(hour0[AH + i] > 0, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud, hour0[AL + i]) }
    /// Remaining grid import capacity after max harm
    let AM = 271560
    // =MAX(0,IF(AH5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud-AU6)
    for i in 1..<8760 { hour0[AM + i] = max(.zero, iff(hour0[AH + i] > 0, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud - hour0[AU + i]) }

    /// El to el boiler after max harm heat cons
    let AN = 280320
    // MAX(0,MIN(El_boiler_cap_ud,(AI6-$J6)/El_boiler_eff))
    for i in 1..<8760 { hour0[AN + i] = max(.zero, min(El_boiler_cap_ud, (hour0[AI + i] - hour0[J + i]) / El_boiler_eff)) }

    /// Remaining el boiler cap after max harm heat cons
    let AO = 289080
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 1..<8760 { hour0[AO + i] = max(.zero, El_boiler_cap_ud - hour0[AN + i]) }

    for i in 1..<8760 {
      /// Remaining MethSynt cap after max harm cons
      let AP = 297840
      /// Remaining CCU cap after max harm cons
      let AQ = 306600
      /// Remaining EY cap after max harm cons
      let AR = 315360
      // =MAX(0,1-((MAX(0,AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction = (max(.zero, hour0[AH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour0[AP + i] = max(.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour0[AQ + i] = max(.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour0[AR + i] = max(.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harm cons
    let AS = 324120
    /// Max grid export after max harm cons
    let AT = 332880
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,AJ6)
      hour0[AS + i] = min(BESS_chrg_max_cons, hour0[AJ + i])
      // =MIN(IF(AH5>0,Grid_export_yes_no_BESS_strategy,Grid_export_yes_no_BESS_strategy_outsideharmop)*Grid_export_max_ud,AJ5)
      hour0[AT + i] = min(iff(hour0[AH + i] > 0, Grid_export_yes_no_BESS_strategy,Grid_export_yes_no_BESS_strategy_outsideharmop) * Grid_export_max_ud, hour0[AJ + i])
    }
    return hour0
  }

  func hour1(hour0: [Double]) -> [Double] {
    let (J, L, M) = (26280, 43800, 52560)
    var hour1 = [Double](repeating: .zero, count: 192_720)
    let daysD: [[Int]] = (0..<365).map { Array(stride(from: 1 + $0 * 24, to: 1 + ($0 + 1) * 24, by: 1)) }

    /// Aux elec for CSP SF and PV Plant MWel
    let AV = 0
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 1..<8760 { hour1[AV + i] = iff(hour0[J + i] > .zero, hour0[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[M + i] }
    /// Available PV power MWel
    let AW = 8760
    // MAX(0,L6-AV6)
    for i in 1..<8760 { hour1[AW + i] = max(.zero, hour0[L + i] - hour1[AV + i]) }

    /// Not covered aux elec for CSP SF and PV Plant MWel
    let AX = 17520
    // MAX(0,AV6-AW6)
    for i in 1..<8760 { hour1[AX + i] = max(.zero, hour1[AV + i] - hour1[AW + i]) }

    /// Max possible PV elec to TES (considering TES chrg aux)
    let AY = 26280
    // =MAX(0,MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc)-PB_stby_aux_cons-Overall_harmonious_var_min_cons-Overall_fix_cons+Grid_import_max_ud*Grid_import_yes_no_PB_strategy,Heater_cap_ud,($J6-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-MIN(El_boiler_cap_ud,MAX(0,AW6-MIN(AW6*(1-Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc)-PB_stby_aux_cons-Overall_harmonious_var_min_cons-Overall_fix_cons+Grid_import_max_ud*Grid_import_yes_no_PB_strategy,Heater_cap_ud)))*El_boiler_eff))*Ratio_CSP_vs_Heater/Heater_eff))
    for i in 1..<8760 { 
      hour1[AY + i] = max(.zero, min(hour1[AW + i] * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc) - PB_stby_aux_cons - Overall_harmonious_var_min_cons - Overall_fix_cons + Grid_import_max_ud * Grid_import_yes_no_PB_strategy, Heater_cap_ud, (hour0[J + i] - max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - min(El_boiler_cap_ud, max(.zero, hour1[AW + i] - min(hour1[AW + i] * (1 - Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc) - PB_stby_aux_cons - Overall_harmonious_var_min_cons - Overall_fix_cons + Grid_import_max_ud * Grid_import_yes_no_PB_strategy, Heater_cap_ud))) * El_boiler_eff)) * Ratio_CSP_vs_Heater / Heater_eff))
    }

    let AYsum = hour1.sum(hours: daysD, condition: AY)

    /// Maximum TES energy per PV day
    let AZ = 35040
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour1[AZ + i] = min(TES_thermal_cap, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// Surplus energy due to TES size limit
    let BA = 43800
    // MAX(0,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap)
    for i in 1..<8760 { hour1[BA + i] = max(.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap) }

    /// Peripherial PV hour PV to heater
    let BB = 52560
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { hour1[BB + i] = iff(or(and(hour1[BA + i] > .zero, hour1[AY + i] > .zero, hour1[AY + i - 1].isZero), and(hour1[BA + i] > .zero, hour1[AY + i + 1].isZero, hour1[AY + i] > .zero)), hour1[AY + i], .zero) }

    let BBsum = hour1.sum(hours: daysD, condition: BB)

    /// Surplus energy due to op limit after removal of peripherial hours
    let BC = 61320
    // MAX(0,BA6-SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour1[BC + i] = max(.zero, hour1[BA + i] - BBsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let BD = 70080
    // IF(AZ6=0,0,AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF(D5:D8763,"="D6,BB5:BB8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6))
    for i in 1..<8760 { hour1[BD + i] = iff(hour1[AZ + i].isZero, .zero, hour1[AY + i] - iff(hour1[BA + i].isZero, .zero, (hour1[BA + i] - hour1[BC + i]) / (BBsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour1[BB + i])) }
    let BDcountNonZero = hour1.count(hours: daysD, range: BD, predicate: { $0 > 0 })
    let BDsum = hour1.sum(hours: daysD, condition: BD)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let BE = 78840
    // IF(OR(BD6=0,BC6=0),0,MAX((AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(D5:D8763,"="D6,BD4:BD8762,">0")),(J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(D5:D8763,"="D6,BD5:BD8763,">0")))/SUMIF(D5:D8763,"="D6,BD5:BD8763)*BD6)
    for i in 1..<8760 {
      hour1[BE + i] = iff(
        or(hour1[BD + i].isZero, hour1[BC + i].isZero), .zero,
        max((hour1[AW + i] - hour1[BD + i]) / (hour1[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BDcountNonZero[i - 1]), (hour0[J + i] - hour1[BD + i] * Heater_eff / Ratio_CSP_vs_Heater) / (hour1[BC + i] / (1 + Ratio_CSP_vs_Heater) / BDcountNonZero[i - 1])) / BDsum[i - 1] * hour1[BD + i])
    }
    let BEsum = hour1.sum(hours: daysD, condition: BE)
    /// corrected max possible PV elec to TES
    let BF = 87600
    // IF(AZ6=0,0,BD6-IF(BC6=0,0,BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(D5:D8763,"="D6,BE5:BE8763)*BE6))
    for i in 1..<8760 { hour1[BF + i] = iff(hour1[AZ + i].isZero, .zero, hour1[BD + i] - iff(hour1[BC + i].isZero, .zero, hour1[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i - 1] * hour1[BE + i])) }

    /// Max possible CSP heat to TES
    let BG = 96360
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour1[BG + i] = min(hour0[J + i], hour1[BF + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BH = 105120
    // =MAX(0,ROUND(BF6-AW6,5))
    for i in 1..<8760 { hour1[BH + i] = max(.zero,round(hour1[BF + i]-hour1[AW + i],5)) }

    /// Remaining PV after TES chrg
    let BI = 113880
    // =MAX(0,AW6-BF6-(AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc))
    for i in 1..<8760 { hour1[BI + i] = max(.zero,hour1[AW + i]-hour1[BF + i]-(hour1[AX + i]+(hour1[BF + i]*Heater_eff+hour1[BG + i])*TES_aux_cons_perc)) }

    /// Remaining CSP heat after TES
    let BJ = 122640
    // J6-BG6
    for i in 1..<8760 { hour1[BJ + i] = hour0[J + i] - hour1[BG + i] }

    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BK = 131400
    // =MAX(0,-(AW6-BF6-(AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc)))
    for i in 1..<8760 { hour1[BK + i] = max(.zero, -(hour1[AW + i] - hour1[BF + i] - (hour1[AX + i] + (hour1[BF + i] * Heater_eff + hour1[BG + i]) * TES_aux_cons_perc))) }

    /// Min harmonious net elec cons not considering grid import
    let BL = 140160
    // =IF(MIN(MAX(0,BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-BJ6)/El_boiler_eff)),MAX(0,BJ6+MIN(El_boiler_cap_ud,MAX(0,BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      let min_net_elec = min(
        max(.zero, hour1[BI + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour1[BH + i]) - PB_stby_aux_cons - min(El_boiler_cap_ud, max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour1[BJ + i]) / El_boiler_eff)),
        max(.zero, hour1[BJ + i] + min(El_boiler_cap_ud, max(.zero, hour1[BI + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour1[BH + i]) - PB_stby_aux_cons - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons
          + Overall_fix_cons)
      hour1[BL + i] = iff((min_net_elec * 10000).rounded() < ((Overall_harmonious_var_min_cons + Overall_fix_cons) * 10000).rounded(), .zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let BM = 148920
    // IF(OR(AND(BL6>0,BL5=0,BL7=0),AND(BL6>0,OR(AND(BL4=0,BL5=0,BL8=0),AND(BL4=0,BL7=0,BL8=0)))),0,BL6)
    for i in 1..<8760 {
      hour1[BM + i] = iff(or(and(hour1[BL + i] > .zero, hour1[BL + i - 1].isZero, hour1[BL + i + 1].isZero), and(hour1[BL + i] > .zero, or(and(hour1[BL + i - 2].isZero, hour1[BL + i - 1] > 0, hour1[BL + i + 1].isZero), and(hour1[BL + i - 1].isZero, hour1[BL + i + 1] > 0, hour1[BL + i + 2].isZero)))), 0, hour1[BL + i])
    }

    /// Min harmonious net heat cons
    let BN = 157680
    // MAX(0,(BM6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 { hour1[BN + i] = iff(hour1[BM + i].isZero, .zero, max(.zero, (hour1[BM + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Harmonious op day
    let BO = 166440
    // IF(OR(AND(BM5<=0,BM6>0,SUM(BM$1:BM5)=0),AND($F5<=0,$F6>0,SUM(BM$1:BM16)=0)),IF(BO5<364,BO5+1,0),BO5)
    for i in 12..<8748 {
      hour1[BO + i] = hour1[BO + i - 1]
      if hour1[BM + i - 1].isZero, hour1[BM + i] > 0, hour1[BM + i + 1] > 0, hour1[(BO + i - 12)..<(BO + i)].allSatisfy( { $0 == hour1[BO + i] }) {
        hour1[BO + i] += 1
      } else if hour0[i - 1].isZero, hour0[i] > 0, hour1[BM + i..<BM + i + 12].allSatisfy(\.isZero), hour1[BO + i - 12..<BO + i].allSatisfy({ $0 == hour1[BO + i] }) {
        hour1[BO + i] += 1
      }
    }
    for i in 8748..<8760 { hour1[BO + i] = hour1[BO + i - 1] }

    /// Remaining PV after min harmonious
    let BP = 175200
    // MAX(0,BI6-BK6-BM6-MIN(El_boiler_cap_ud,MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 1..<8760 { hour1[BP + i] = max(.zero, hour1[BI + i] - hour1[BK + i] - hour1[BM + i] - min(El_boiler_cap_ud, max(.zero, (hour1[BN + i] - hour1[BJ + i]) / El_boiler_eff))) }

    /// Remaining CSP heat after min harmonious
    let BQ = 183960
    // MAX(0,BJ6-BN6)
    for i in 1..<8760 { hour1[BQ + i] = max(.zero, hour1[BJ + i] - hour1[BN + i]) }

    return hour1
  }
}
