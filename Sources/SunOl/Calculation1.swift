extension TunOl {
  func hour(_ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double], _ Reference_PV_MV_power_at_transformer_outlet: [Double], hour h: inout [Double]) {
    /// Q_solar (before dumping) MWth
    let J: Int = 17520
    /// E_PV_Total _Scaled MWel_DC
    let K: Int = 26280
    /// PV MV net power at transformer outlet MWel
    let L: Int = 35040
    /// PV aux consumption at transformer level MWel
    let M: Int = 43800
    /// Aux elec for PB stby, CSP SF and PV Plant MWel
    let O: Int = 61320
    /// Available PV power MWel
    let P: Int = 70080
    /// Not covered aux elec for PB stby, CSP SF and PV Plant MWel
    let Q: Int = 78840
    for i in 1..<8760 {
      h[i] = Reference_PV_plant_power_at_inverter_inlet_DC[i]
      // E6*CSP_loop_nr_ud
      h[J + i] = Q_Sol_MW_thLoop[i] * CSP_loop_nr_ud
      // F6*PV_DC_cap_ud/PV_Ref_DC_cap
      h[K + i] = Reference_PV_plant_power_at_inverter_inlet_DC[i] * PV_DC_cap_ud / PV_Ref_DC_cap
      // L=IF(MIN(Inverter_max_DC_input,K5)/PV_DC_cap_ud>Inv_eff_approx_handover,MIN(Inverter_max_DC_input,K5)*POLY(MIN(Inverter_max_DC_input,K5)/PV_DC_cap_ud,HL_Coeff),IF(MIN(Inverter_max_DC_input,K5)/PV_DC_cap_ud>0,MIN(Inverter_max_DC_input,K5)*POLY(MIN(Inverter_max_DC_input,K5)/PV_DC_cap_ud,LL_Coeff),0))
      if min(Inverter_max_DC_input, h[K + i]) / PV_DC_cap_ud > Inv_eff_approx_handover {
        h[L + i] = min(Inverter_max_DC_input, h[K + i]) * POLY(min(Inverter_max_DC_input, h[K + i]) / PV_DC_cap_ud, HL_Coeff)
      } else if min(Inverter_max_DC_input, h[K + i]) / PV_DC_cap_ud > Double.zero {
        h[L + i] = min(Inverter_max_DC_input, h[K + i]) * POLY(min(Inverter_max_DC_input, h[K + i]) / PV_DC_cap_ud, LL_Coeff)
      } else {
        h[L + i] = Double.zero
      }
      // MAX(0,-G6/PV_Ref_AC_cap*PV_AC_cap_ud)
      let m = max(Double.zero, -Reference_PV_MV_power_at_transformer_outlet[i] / 600.5 * PV_AC_cap_ud)
      h[M + i] = m
      // =IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+IF(PB_nom_gross_cap_ud=0,0,PB_stby_aux_cons)
      h[O + i] = iff(h[J + i] > Double.zero, h[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + h[M + i] + iff(PB_nom_gross_cap_ud.isZero, Double.zero, PB_stby_aux_cons)
      // MAX(0,L6-O6)
      h[P + i] = max(Double.zero, h[L + i] - h[O + i])
      // MAX(0,O6-P6)
      h[Q + i] = max(Double.zero, h[O + i] - h[L + i])
    }
    /// Min harmonious net elec cons
    let R: Int = 87600
    // R=IF(MIN(MAX(0,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-$J6)/El_boiler_eff)),MAX(0,$J6+MIN(El_boiler_cap_ud,MAX(0,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      h[R + i] = iff(
        min(
          max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[J + i]) / El_boiler_eff)),
          max(
            0,
            h[J + i] + min(El_boiler_cap_ud, max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons
              - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) + Overall_harmonious_var_min_cons
            + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }
    /// Optimized min harmonious net elec cons
    let S: Int = 96360
    // IF(OR(AND(R6>0,R5=0,R7=0),AND(R6>0,OR(AND(R4=0,R5=0,R8=0),AND(R4=0,R7=0,R8=0)))),0,R6)
    for i in 1..<8760 {
      h[S + i] = iff(
        or(
          and(h[R + i] > Double.zero, h[R + i - 1].isZero, h[R + i + 1].isZero),
          and(h[R + i] > Double.zero, or(and(h[R + i - 2].isZero, h[R + i - 1] > Double.zero, h[R + i + 1].isZero), and(h[R + i - 1].isZero, h[R + i + 1] > Double.zero, h[R + i + 2].isZero)))), Double.zero, h[R + i])
    }
    /// Min harmonious net heat cons
    let T: Int = 105120
    // T=IF(OR(S6=0,MIN(MAX(0,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-$J6)/El_boiler_eff)),MAX(0,$J6+MIN(El_boiler_cap_ud,MAX(0,$P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons),0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      h[T + i] = iff(
        or(
          h[S + i] == Double.zero,
          min(
            max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[J + i]) / El_boiler_eff)),
            max(
              0,
              h[J + i] + min(El_boiler_cap_ud, max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons
                - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) + Overall_harmonious_var_min_cons
              + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons), 0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons)
    }
    /// Harmonious op day
    let U: Int = 113880
    // IF(OR(AND(S5<=0,S6>0,SUM(S1:S5)=0),AND($F5<=0,$F6>0,SUM(S4:S18)=0)),IF(U5<364,U5+1,0),U5)
    for i in 12..<8748 {
      h[U + i] = h[U + i - 1]
      if h[S + i - 1].isZero, h[S + i] > Double.zero, h[S + i + 1] > Double.zero, h[(U + i - 12)..<(U + i)].allSatisfy({ $0 == h[U + i] }) {
        h[U + i] += 1
      } else if h[i - 1].isZero, h[i] > Double.zero, h[S + i..<S + i + 12].allSatisfy(\.isZero), h[U + i - 12..<U + i].allSatisfy({ $0 == h[U + i] }) {
        h[U + i] += 1
      }
    }
    for i in 8748..<8760 { h[U + i] = h[U + i - 1] }
    /// Remaining PV after min harmonious
    let V: Int = 122640
    // V=ROUNDUP(MAX(0,$P5-$Q5-S5-MIN(El_boiler_cap_ud,MAX(0,(T5-$J5)/El_boiler_eff))),5)
    for i in 1..<8760 { 
      h[V + i] = max(Double.zero, h[P + i] - h[Q + i] - h[S + i] - min(El_boiler_cap_ud, max(Double.zero, (h[T + i] - h[J + i]) / El_boiler_eff))) 
    }
    /// Remaining CSP heat after min harmonious
    let W: Int = 131400
    // W=ROUNDUP(MAX(0,$J5-T5),5)
    for i in 1..<8760 { h[W + i] = max(Double.zero, h[J + i] - h[T + i]) }

    let (TX, TY, TZ) = (1_033_680, 1_042_440, 1_051_200)
    // TX=MAX(0,IF(S6>0,0,Overall_stby_cons+IF(S7=0,0,Overall_stup_cons)-V6))=MAX(0,IF(S6>0,0,Overall_stby_cons+IF(S7=0,0,Overall_stup_cons)-V6))
    // TY=MAX(0,IF(S6>0,0,Overall_heat_stby_cons+IF(S7=0,0,Overall_heat_stup_cons)-W6))
    // TZ=MAX(0,IF(S6>0,0,-Overall_stby_cons-IF(S7=0,0,Overall_stup_cons))+V6)
    for i in 1..<8760 {
      h[TX + i] = max(Double.zero, iff(h[S + i] > Double.zero, Double.zero, iff(h[S + i + 1].isZero, Overall_stby_cons, Overall_stup_cons) - h[V + i]))
      h[TY + i] = max(Double.zero, iff(h[S + i] > Double.zero, Double.zero, iff(h[S + i + 1].isZero, Overall_heat_stby_cons, Overall_heat_stup_cons) - h[W + i]))
      h[TZ + i] = max(Double.zero, iff(h[S + i] > Double.zero, Double.zero, iff(h[S + i + 1].isZero, -Overall_stby_cons, -Overall_stup_cons)) + h[V + i])
    }

    /// Grid import necessary for min harmonious
    let X: Int = 140160
    // X=ROUNDDOWN(MAX(0,-($P5-$Q5-S5-MIN(El_boiler_cap_ud,MAX(0,(T5-$J5)/El_boiler_eff)))),5)
    for i in 1..<8760 { h[X + i] = max(Double.zero, -(h[P + i] - h[Q + i] - h[S + i] - min(El_boiler_cap_ud, max(Double.zero, (h[T + i] - h[J + i]) / El_boiler_eff)))) }
    let N: Int = 52560
    // =MIN(IF(S5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud,X5)
    for i in 1..<8760 { h[N + i] = min(iff(h[S + i] > Double.zero, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud, h[X + i]) }
    /// Remaining grid import capacity after min harmonious
    let Y: Int = 148920
    // Y=ROUND(MAX(0,IF(S5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud-N5),5)
    for i in 1..<8760 { h[Y + i] = max(Double.zero, iff(h[S + i] > Double.zero, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud - h[N + i]) }
    /// El to el boiler after min harm heat cons
    let Z: Int = 157680
    // Z=ROUND(MAX(0,MIN(El_boiler_cap_ud,(T5-$J5)/El_boiler_eff)),5)
    for i in 1..<8760 { h[Z + i] = max(Double.zero, min(El_boiler_cap_ud, (h[T + i] - h[J + i]) / El_boiler_eff)) }
    /// Remaining el boiler cap after min harm heat cons
    let AA: Int = 166440
    // AA=ROUND(MAX(0,El_boiler_cap_ud-Z5),5)
    for i in 1..<8760 { h[AA + i] = max(Double.zero, El_boiler_cap_ud - h[Z + i]) }
    /// Remaining MethSynt cap after min harm cons
    let AB: Int = 175200
    /// Remaining CCU cap after min harm cons
    let AC: Int = 183960
    /// Remaining EY cap after min harm cons
    let AD: Int = 192720
    for i in 1..<8760 {
      // AB=ROUND(MAX(0,1-((MAX(0,S5-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud,5)
      h[AB + i] =
        max(
          Double.zero,
          1
            - ((max(Double.zero, h[S + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
      // AC=ROUND(MAX(0,1-((MAX(0,S5-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud,5)
      h[AC + i] = 
        max(
          Double.zero,
          1
            - ((max(Double.zero, h[S + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // AD=ROUND(MAX(0,1-((MAX(0,S5-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod,5)
      h[AD + i] = 
        max(
          Double.zero,
          1
            - ((max(Double.zero, h[S + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harm cons
    let AE: Int = 201480
    /// Max grid export after min harm cons
    let AF: Int = 210240
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,V6)
      h[AE + i] = min(BESS_chrg_max_cons, h[V + i])
      // =MIN(IF(S6>0,Grid_export_yes_no_BESS_strategy,Grid_export_yes_no_BESS_strategy_outsideharmop)*Grid_export_max_ud,V6)
      h[AF + i] = min(iff(h[S + i] > Double.zero, Grid_export_yes_no_BESS_strategy, Grid_export_yes_no_BESS_strategy_outsideharmop) * Grid_export_max_ud, h[V + i])
    }
    /// Max harm net elec cons
    let AG: Int = 219000
    // =IF(S5=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,P5+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Q5-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-J5)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,J5-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,P5+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Q5-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,J5+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      h[AG + i] = iff(
        h[S + i].isZero, Double.zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            Double.one,
            max(
              Double.zero,
              h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - h[Q + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[J + i])
                / El_boiler_eff) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              Double.zero,
              h[J + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(Double.zero, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - h[Q + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)
                * El_boiler_eff) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(Double.zero, h[J + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }
    /// Optimized max harm net elec cons
    let AH: Int = 227760
    // IF(OR(AND(AG6>0,AG5=0,AG7=0),AND(AG6>0,OR(AND(AG4=0,AG5>0,AG7=0),AND(AG5=0,AG7>0,AG8=0)))),0,AG6)
    for i in 1..<8760 {
      h[AH + i] = iff(
        or(
          and(h[AG + i] > Double.zero, h[AG + i - 1].isZero, h[AG + i + 1].isZero),
          and(h[AG + i] > Double.zero, or(and(h[AG + i - 2].isZero, h[AG + i - 1] > Double.zero, h[AG + i + 1].isZero), and(h[AG + i - 1].isZero, h[AG + i + 1] > Double.zero, h[AG + i + 2].isZero)))), Double.zero, h[AG + i])
    }
    /// max harm net heat cons
    let AI: Int = 236520
    // AI=IF(AH6=0,0,Overall_heat_fix_cons+Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*MIN(1,MAX(0,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Q6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-J6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,J6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,P6+Grid_import_max_ud*Grid_import_yes_no_BESS_strategy-Q6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,J6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      h[AI + i] = iff(
        h[AH + i] == Double.zero, 0,
        Overall_heat_fix_cons + Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)
          * min(
            1,
            max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - h[Q + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[J + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(0, h[J + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(0, h[P + i] + Grid_import_max_ud * Grid_import_yes_no_BESS_strategy - h[Q + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(0, h[J + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }
    /// Remaining PV after max harm
    let AJ: Int = 245280
    // AJ=ROUNDUP(MAX(0,$P5-$Q5-AH5-MIN(El_boiler_cap_ud,MAX(0,(AI5-$J5)/El_boiler_eff))),5)
    for i in 1..<8760 { h[AJ + i] = max(Double.zero, h[P + i] - h[Q + i] - h[AH + i] - min(El_boiler_cap_ud, max(Double.zero, (h[AI + i] - h[J + i]) / El_boiler_eff))) }
    /// Remaining CSP heat after max harm
    let AK: Int = 254040
    // AK=ROUNDUP(MAX(0,$J5-AI5),5)
    for i in 1..<8760 { h[AK + i] = max(Double.zero, h[J + i] - h[AI + i]) }

    let (UB, UC, UD) = (1_059_960, 1_068_720, 1_077_480)
    // UB=MAX(0,IF(AH6>0,0,Overall_stby_cons+IF(AH7=0,0,Overall_stup_cons)-AJ6))
    // UC=MAX(0,IF(AH6>0,0,Overall_heat_stby_cons+IF(AH7=0,0,Overall_heat_stup_cons)-AK6))
    // UD=MAX(0,IF(AH6>0,0,-Overall_stby_cons-IF(AH7=0,0,Overall_stup_cons))+AJ6)
    for i in 1..<8760 {
      h[UB + i] = max(Double.zero, iff(h[AH + i] > Double.zero, Double.zero, iff(h[AH + i + 1].isZero, Overall_stby_cons, Overall_stup_cons) - h[AJ + i]))
      h[UC + i] = max(Double.zero, iff(h[AH + i] > Double.zero, Double.zero, iff(h[AH + i + 1].isZero, Overall_heat_stby_cons, Overall_heat_stup_cons) - h[AK + i]))
      h[UD + i] = max(Double.zero, iff(h[AH + i] > Double.zero, Double.zero, iff(h[AH + i + 1].isZero, -Overall_stby_cons, -Overall_stup_cons)) + h[AJ + i])
    }

    /// Grid import necessary for max harm
    let AL: Int = 262800
    // AL=ROUNDDOWN(MAX(0,-($P5-$Q5-AH5-MIN(El_boiler_cap_ud,MAX(0,(AI5-$J5)/El_boiler_eff)))),5)
    for i in 1..<8760 { h[AL + i] = max(Double.zero, -(h[P + i] - h[Q + i] - h[AH + i] - min(El_boiler_cap_ud, max(Double.zero, (h[AI + i] - h[J + i]) / El_boiler_eff)))) }
    let AU: Int = 341640
    // =MIN(IF(AH6>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud,AL6)
    for i in 1..<8760 { h[AU + i] = min(iff(h[AH + i] > Double.zero, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud, h[AL + i]) }
    /// Remaining grid import capacity after max harm
    let AM: Int = 271560
    // =ROUND(MAX(0,IF(AH5>0,Grid_import_yes_no_BESS_strategy,Grid_import_yes_no_BESS_strategy_outsideharmop)*Grid_import_max_ud-AU5),5)
    for i in 1..<8760 { h[AM + i] = max(Double.zero, iff(h[AH + i] > Double.zero, Grid_import_yes_no_BESS_strategy, Grid_import_yes_no_BESS_strategy_outsideharmop) * Grid_import_max_ud - h[AU + i]) }
    /// El to el boiler after max harm heat cons
    let AN: Int = 280320
    // MAX(0,MIN(El_boiler_cap_ud,(AI6-$J6)/El_boiler_eff))
    for i in 1..<8760 { h[AN + i] = max(Double.zero, min(El_boiler_cap_ud, (h[AI + i] - h[J + i]) / El_boiler_eff)) }
    /// Remaining el boiler cap after max harm heat cons
    let AO: Int = 289080
    // MAX(0,El_boiler_cap_ud-AN6)
    for i in 1..<8760 { h[AO + i] = max(Double.zero, El_boiler_cap_ud - h[AN + i]) }

    for i in 1..<8760 {
      /// Remaining MethSynt cap after max harm cons
      let AP: Int = 297840
      /// Remaining CCU cap after max harm cons
      let AQ: Int = 306600
      /// Remaining EY cap after max harm cons
      let AR: Int = 315360
      // =MAX(0,1-((MAX(0,AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction = (max(Double.zero, h[AH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      h[AP + i] = max(Double.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      h[AQ + i] = max(Double.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // MAX(0;1-((MAX(0;AH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      h[AR + i] = max(Double.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }
    /// Max BESS charging after max harm cons
    let AS: Int = 324120
    /// Max grid export after max harm cons
    let AT: Int = 332880
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,AJ6)
      h[AS + i] = min(BESS_chrg_max_cons, h[AJ + i])
      // =MIN(IF(AH5>0,Grid_export_yes_no_BESS_strategy,Grid_export_yes_no_BESS_strategy_outsideharmop)*Grid_export_max_ud,AJ5)
      h[AT + i] = min(iff(h[AH + i] > Double.zero, Grid_export_yes_no_BESS_strategy, Grid_export_yes_no_BESS_strategy_outsideharmop) * Grid_export_max_ud, h[AJ + i])
    }
    /// Aux elec for CSP SF and PV Plant MWel
    let AV: Int = 350400
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6
    for i in 1..<8760 { h[AV + i] = iff(h[J + i] > Double.zero, h[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + h[M + i] }
    /// Available PV power MWel
    let AW: Int = 359160
    // MAX(0,L6-AV6)
    for i in 1..<8760 { h[AW + i] = max(Double.zero, h[L + i] - h[AV + i]) }
    /// Not covered aux elec for CSP SF and PV Plant MWel
    let AX: Int = 367920
    // MAX(0,AV6-AW6)
    for i in 1..<8760 { h[AX + i] = max(Double.zero, h[AV + i] - h[AW + i]) }
  }

  func hour1(_ h: inout [Double], reserved: Double) {
    var daysD: [[Int]] = [Array(stride(from: 1, to: 18, by: 1))]
    daysD.append(contentsOf: (0..<364).map { Array(stride(from: 18 + $0 * 24, to: 18 + ($0 + 1) * 24, by: 1)) })
    daysD[364].append(contentsOf: stride(from: 8754, to: 8760, by: 1))
    /// Max possible PV elec to TES (considering TES chrg aux)
    let (J, AW, AX, AY) = (17520, 359160, 367920, 376680)
    let BS: Int = 551880
    for i in 1..<8760 { h[BS + i] = reserved }

    // AY=ROUND(MAX(0,MIN((Grid_import_max_ud*Grid_import_yes_no_PB_strategy+AW6+IF(BS6<Overall_harmonious_min_perc,$J6,MAX(0,$J6-((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)+Overall_harmonious_var_heat_min_cons)-Overall_heat_fix_cons))/Heater_eff-IF(BS6<Overall_harmonious_min_perc,0,((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons)+Overall_fix_cons+MAX(0,((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)+Overall_harmonious_var_heat_min_cons)+Overall_heat_fix_cons-$J6)/El_boiler_eff)-IF(AND(AW6>0,AW7=0),PB_stup_aux_cons+PB_warm_start_heat_req*TES_aux_cons_perc,0)-PB_stby_aux_cons)/(1+1/Ratio_CSP_vs_Heater+Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc),Heater_cap_ud,$J6*Ratio_CSP_vs_Heater/Heater_eff,(MIN(El_boiler_cap_ud,Grid_import_max_ud*Grid_import_yes_no_PB_strategy+AW6)*El_boiler_eff-IF(BS6<Overall_harmonious_min_perc,0,((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)+Overall_harmonious_var_heat_min_cons)+Overall_heat_fix_cons)+$J6)*Ratio_CSP_vs_Heater/Heater_eff,(Grid_import_max_ud*Grid_import_yes_no_PB_strategy+AW6-IF(BS6<Overall_harmonious_min_perc,0,((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons)+Overall_fix_cons+MAX(0,((BS6-Overall_harmonious_min_perc)*(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)+Overall_harmonious_var_heat_min_cons)+Overall_heat_fix_cons-$J6)/El_boiler_eff)-IF(AND(AW6>0,AW7=0),PB_stup_aux_cons+PB_warm_start_heat_req*TES_aux_cons_perc,0)-PB_stby_aux_cons)/(1+Heater_eff*(1+1/Ratio_CSP_vs_Heater)*TES_aux_cons_perc))),5)
    for i in 1..<8760 {
      h[AY + i] =
        max(
          0,
          min(
            (Grid_import_max_ud * Grid_import_yes_no_PB_strategy + h[AW + i] + iff(
              h[BS + i] < Overall_harmonious_min_perc, h[J + i],
              max(0, h[J + i] - ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) + Overall_harmonious_var_heat_min_cons) - Overall_heat_fix_cons)) / Heater_eff
              - iff(
                h[BS + i] < Overall_harmonious_min_perc, 0,
                ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) + Overall_harmonious_var_min_cons) + Overall_fix_cons + max(
                  0, ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) + Overall_harmonious_var_heat_min_cons) + Overall_heat_fix_cons - h[J + i]) / El_boiler_eff)
              - iff(and(h[AW + i] > Double.zero, h[AW + i + 1] == Double.zero), PB_stup_aux_cons + PB_warm_start_heat_req * TES_aux_cons_perc, 0) - PB_stby_aux_cons)
              / (1 + 1 / Ratio_CSP_vs_Heater + Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc), Heater_cap_ud, h[J + i] * Ratio_CSP_vs_Heater / Heater_eff,
            (min(El_boiler_cap_ud, Grid_import_max_ud * Grid_import_yes_no_PB_strategy + h[AW + i]) * El_boiler_eff
              - iff(
                h[BS + i] < Overall_harmonious_min_perc, 0, ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) + Overall_harmonious_var_heat_min_cons) + Overall_heat_fix_cons)
              + h[J + i]) * Ratio_CSP_vs_Heater / Heater_eff,
            (Grid_import_max_ud * Grid_import_yes_no_PB_strategy + h[AW + i]
              - iff(
                h[BS + i] < Overall_harmonious_min_perc, 0,
                ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) + Overall_harmonious_var_min_cons) + Overall_fix_cons + max(
                  0, ((h[BS + i] - Overall_harmonious_min_perc) * (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) + Overall_harmonious_var_heat_min_cons) + Overall_heat_fix_cons - h[J + i]) / El_boiler_eff)
              - iff(and(h[AW + i] > Double.zero, h[AW + i + 1].isZero), PB_stup_aux_cons + PB_warm_start_heat_req * TES_aux_cons_perc, 0) - PB_stby_aux_cons) / (1 + Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) * TES_aux_cons_perc)))
    }
    let AYsum: [Double] = h.sum(hours: daysD, condition: AY)
    /// Maximum TES energy per PV day
    let AZ: Int = 385440
    // MIN(TES_thermal_cap,SUMIF(D5:D8763,"="D6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { h[AZ + i] = min(TES_thermal_cap, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }
    /// Surplus energy due to TES size limit
    let BA: Int = 394200
    // =MAX(0,ROUND(SUMIF($D$5:$D$8764,"="&$D6,AY$5:AY$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-TES_thermal_cap_ud,5))
    for i in 1..<8760 { h[BA + i] = max(Double.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_thermal_cap) }
    /// Peripherial PV hour PV to heater
    let BB: Int = 402960
    // IF(OR(AND(BA6>0,AY6>0,AY5=0),AND(BA6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { h[BB + i] = iff(or(and(h[BA + i] > Double.zero, h[AY + i] > Double.zero, h[AY + i - 1].isZero), and(h[BA + i] > Double.zero, h[AY + i + 1].isZero, h[AY + i] > Double.zero)), h[AY + i], Double.zero) }
    let BBsum: [Double] = h.sum(hours: daysD, condition: BB)
    /// Surplus energy due to op limit after removal of peripherial hours
    let BC: Int = 411720
    // =MAX(0,ROUND(BA6-SUMIF($D$5:$D$8764,"="&$D6,BB$5:BB$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),5))
    for i in 1..<8760 { h[BC + i] = max(Double.zero, h[BA + i] - BBsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }
    /// intermediate resulting PV elec to TES
    let BD: Int = 420480
    // =IF(AZ6=0,0,ROUND(AY6-IF(BA6=0,0,(BA6-BC6)/(SUMIF($D$5:$D$8764,"="&$D6,BB$5:BB$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*BB6),5))
    for i in 1..<8760 { 
      if 422592 == BD + i {

      }
      h[BD + i] = iff(h[AZ + i].isZero, Double.zero, h[AY + i] - iff(h[BA + i].isZero, Double.zero, (h[BA + i] - h[BC + i]) / (BBsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * h[BB + i]))
    }
    let BDcountNonZero = h.count(hours: daysD, range: BD, predicate: { $0 > 0.000001 })
    let BDsum: [Double] = h.sum(hours: daysD, condition: BD)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let BE: Int = 429240
    // IF(OR(BD6=0,BC6=0),0,MAX(($AW6-BD6)/(BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS($D$5:$D$8764,"="&$D6,BD$5:BD$8764,">0")),($J6-BD6*Heater_eff/Ratio_CSP_vs_Heater)/(BC6/(1+Ratio_CSP_vs_Heater)/COUNTIFS($D$5:$D$8764,"="&$D6,BD$5:BD$8764,">0")))/SUMIF($D$5:$D$8764,"="&$D6,BD$5:BD$8764)*BD6)
    for i in 1..<8760 {
      h[BE + i] = iff(
        or(h[BD + i].isZero, h[BC + i].isZero), Double.zero,
        max((h[AW + i] - h[BD + i]) / (h[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BDcountNonZero[i - 1]), (h[J + i] - h[BD + i] * Heater_eff / Ratio_CSP_vs_Heater) / (h[BC + i] / (1 + Ratio_CSP_vs_Heater) / BDcountNonZero[i - 1]))
          / BDsum[i - 1] * h[BD + i])
    }
    let BEsum: [Double] = h.sum(hours: daysD, condition: BE)
    /// corrected max possible PV elec to TES
    let BF: Int = 438000
    // =IF(AZ6=0,0,ROUND(MAX(0,BD6-IF(BC6=0,0,BC6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($D$5:$D$8764,"="&$D6,BE$5:BE$8764)*BE6)),5))
    for i in 1..<8760 { h[BF + i] = iff(h[AZ + i].isZero, Double.zero, max(Double.zero, h[BD + i] - iff(h[BC + i].isZero, Double.zero, h[BC + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / BEsum[i - 1] * h[BE + i]))) }
    /// Max possible CSP heat to TES
    let BG: Int = 446760
    // MIN(J6,BF6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { h[BG + i] = min(h[J + i], h[BF + i] * Heater_eff / Ratio_CSP_vs_Heater) }
    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BH: Int = 455520
    // =MAX(0,ROUND(BF6-AW6,5))
    for i in 1..<8760 { h[BH + i] = max(Double.zero, h[BF + i] - h[AW + i]) }
    /// Remaining PV after TES chrg
    let BI: Int = 464280
    // =MAX(0,AW6-BF6-(AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc))
    for i in 1..<8760 { h[BI + i] = max(Double.zero, h[AW + i] - h[BF + i] - (h[AX + i] + (h[BF + i] * Heater_eff + h[BG + i]) * TES_aux_cons_perc)) }
    /// Remaining CSP heat after TES
    let BJ: Int = 473040
    // J6-BG6
    for i in 1..<8760 { h[BJ + i] = round(h[J + i] - h[BG + i], 5) }
    /// Not covered aux elec for TES chrg, CSP SF and PV Plant MWel
    let BK: Int = 481800
    // =MAX(0,-(AW6-BF6-(AX6+(BF6*Heater_eff+BG6)*TES_aux_cons_perc)))
    for i in 1..<8760 { h[BK + i] = max(Double.zero, -(h[AW + i] - h[BF + i] - (h[AX + i] + (h[BF + i] * Heater_eff + h[BG + i]) * TES_aux_cons_perc))) }
    /// Min harmonious net elec cons
    let BL: Int = 490560
    // BL=IF(ROUNDUP(MIN(BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-BJ6)/El_boiler_eff),MAX(0,BJ6+MIN(El_boiler_cap_ud,MAX(0,BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      h[BL + i] = iff(
        roundUp(
          min(
            h[BI + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - h[BH + i]) - PB_stby_aux_cons - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[BJ + i]) / El_boiler_eff),
            max(
              0,
              h[BJ + i] + min(El_boiler_cap_ud, max(0, h[BI + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - h[BH + i]) - PB_stby_aux_cons - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                - Overall_heat_fix_cons - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5), 0, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let BM: Int = 499320
    // IF(OR(AND(BL6>0,BL5=0,BL7=0),AND(BL6>0,OR(AND(BL4=0,BL5=0,BL8=0),AND(BL4=0,BL7=0,BL8=0)))),0,BL6)
    for i in 1..<8760 {
      h[BM + i] = iff(
        or(
          and(h[BL + i] > Double.zero, h[BL + i - 1].isZero, h[BL + i + 1].isZero),
          and(h[BL + i] > Double.zero, or(and(h[BL + i - 2].isZero, h[BL + i - 1] > Double.zero, h[BL + i + 1].isZero), and(h[BL + i - 1].isZero, h[BL + i + 1] > Double.zero, h[BL + i + 2].isZero)))), Double.zero, h[BL + i])
    }
    /// Min harmonious net heat cons
    let BN: Int = 508080
    // BN=IF(OR(BM6=0,ROUNDUP(MIN(BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-BJ6)/El_boiler_eff),MAX(0,BJ6+MIN(El_boiler_cap_ud,MAX(0,BI6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-BH6)-PB_stby_aux_cons-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5)),0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      h[BN + i] = iff(
        or(
          h[BM + i] == Double.zero,
          roundUp(
            min(
              h[BI + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - h[BH + i]) - PB_stby_aux_cons - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[BJ + i]) / El_boiler_eff),
              max(
                0,
                h[BJ + i] + min(El_boiler_cap_ud, max(0, h[BI + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - h[BH + i]) - PB_stby_aux_cons - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                  - Overall_heat_fix_cons - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5)), 0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons)
    }
    /// Harmonious op day
    let BO: Int = 516840
    // IF(OR(AND(BM5<=0,BM6>0,SUM(BM$1:BM5)=0),AND($F5<=0,$F6>0,SUM(BM$1:BM16)=0)),IF(BO5<364,BO5+1,0),BO5)
    for i in 12..<8748 {
      h[BO + i] = h[BO + i - 1]
      if h[BM + i - 1].isZero, h[BM + i] > Double.zero, h[BM + i + 1] > Double.zero, h[(BO + i - 12)..<(BO + i)].allSatisfy({ $0 == h[BO + i] }) {
        h[BO + i] += 1
      } else if h[i - 1].isZero, h[i] > Double.zero, h[BM + i..<BM + i + 12].allSatisfy(\.isZero), h[BO + i - 12..<BO + i].allSatisfy({ $0 == h[BO + i] }) {
        h[BO + i] += 1
      }
    }
    for i in 8748..<8760 { h[BO + i] = h[BO + i - 1] }
    /// Remaining PV after min harmonious
    let BP: Int = 525600
    // MAX(0,BI6-BK6-BM6-MIN(El_boiler_cap_ud,MAX(0,(BN6-BJ6)/El_boiler_eff)))
    for i in 1..<8760 { h[BP + i] = max(Double.zero, h[BI + i] - h[BK + i] - h[BM + i] - min(El_boiler_cap_ud, max(Double.zero, (h[BN + i] - h[BJ + i]) / El_boiler_eff))) }
    /// Remaining CSP heat after min harmonious
    let BQ: Int = 534360
    // MAX(0,BJ6-BN6)
    for i in 1..<8760 { h[BQ + i] = max(Double.zero, h[BJ + i] - h[BN + i]) }
  }

  func hour2(_ h: inout [Double], case j: Int) {

    let BO: Int = 516840
    let BOday: [[Int]] = h[BO + 1..<(BO + 8760)].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - BO } }
    let BM: Int = 499320
    let BMcountZero = h.count(hours: BOday, range: BM, predicate: { $0 <= 0.000001 })
    /// Number of outside harm op period hours
    let BR: Int = 543120
    // =COUNTIFS($BO$5:$BO$8764,"="&$BO6,$BM$5:$BM$8764,"<=0")
    for i in 1..<8760 { h[BR + i] = BMcountZero[i - 1] }
    let AY: Int = 376680
    let BF: Int = 438000
    let BK: Int = 481800
    let BP: Int = 525600
    let BQ: Int = 534360
    let AYsum: [Double] = h.sum(hours: BOday, condition: AY)
    let BFcount = h.count(hours: BOday, range: BF, predicate: { $0 > 0.000001 })
    /// Number of night hours
    // let BLcount = h.count(hours: BOday, range: BL, predicate: { $0 <= 0 })  // BR=COUNTIFS($BO$5:$BO$8764,"="&$BO5,$BL$5:$BL$8764,"<=0")
    /// Minimum night op possible considering tank sizes
    let BT: Int = 560640
    // BT=IF(OR($BR6*A_RawMeth_min_cons>RawMeth_storage_cap_ud,$BR6*A_CO2_min_cons>CO2_storage_cap_ud,$BR6*A_Hydrogen_min_cons>Hydrogen_storage_cap_ud,COUNTIFS($BO$5:$BO$8764,"="&$BO6,$BF$5:$BF$8764,">1E-10")=0),0,1)
    for i in 1..<8760 {
      h[BT + i] = iff(
        or(BMcountZero[i - 1] * RawMeth_min_cons[j] > RawMeth_storage_cap_ud,
         BMcountZero[i - 1] * CO2_min_cons[j] > CO2_storage_cap_ud,
         BMcountZero[i - 1] * Hydrogen_min_cons[j] > Hydrogen_storage_cap_ud,
         BFcount[i - 1].isZero), Double.zero, 1.0)
    }
    /// Min net elec demand outside harm op period
    let BU: Int = 569400
    // BU=IF(OR(BT6=0,AND(BM6>0,BM7>0),AND(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff)<BP6-IF(AND(BM6>0,BM7=0,BU5=0),PB_stby_aux_cons,PB_stup_aux_cons+PB_warm_start_heat_req*TES_aux_cons_perc),A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)<El_boiler_cap_ud*El_boiler_eff+BQ6)),0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))
    for i in 1..<8760 {
      h[BU + i] = iff(
        or(
          h[BT + i].isZero, and(h[BM + i] > Double.zero, h[BM + i + 1] > Double.zero),
          and(
            overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[BM + i + 1].isZero, Double.zero, overall_stup_cons[j])
              + min(El_boiler_cap_ud, max(Double.zero, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[BM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - h[BQ + i]) / El_boiler_eff) < h[BP + i]
              - iff(and(h[BM + i] > Double.zero, h[BM + i + 1].isZero, h[BU + i - 1].isZero), PB_stby_aux_cons, PB_stup_aux_cons + PB_warm_start_heat_req * TES_aux_cons_perc),
            overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[BM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) < El_boiler_cap_ud * El_boiler_eff + h[BQ + i])), Double.zero,
        overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[BM + i + 1].isZero, Double.zero, overall_stup_cons[j]))
    }
    /// Optimized min net elec demand outside harm op period
    let BV: Int = 578160
    let BW: Int = 586920
    // BV=IF(BU6>0,IF(SUM(BV3:BV5,BU7:BU9)=0,0,BU6),IF(OR(SUM(BV4:BV5)=0,SUM(BU7:BU8)=0),0,MAX(BU4:BU8)))
    for i in 1..<8760 {
      let sum = (h[max(BU + i - 3, BU)..<(BU + i)].reduce(0, +) + h[(BU + i + 1)..<min(BU + i + 4, BW)].reduce(0, +)).isZero
      let bv = h[max(BV + i - 2, BV)..<(BV + i)].reduce(0, +).isZero
      let bu = h[max(BU + i + 1, BU)..<min(BU + i + 3, BV)].reduce(0, +).isZero
      let max = h[max(BU + i - 3, BU)..<min(BU + i + 3, BV)].max()!
      h[BV + i] = iff(h[BU + i] > Double.zero, iff(sum, 0, h[BU + i]), iff(or(bv, bu), 0, max))
    }
    
    // Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    // BW=IF(OR(BT6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,ROUNDUP($BK6+MAX(0,(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+BV6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+BV6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/PB_gross_min_eff+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons))*PB_Ratio_Heat_input_vs_output+IF(AND(BV6=0,BV7>0),IF(COUNTIF(BV1:BV6,"0")<PB_warm_start_duration,PB_hot_start_heat_req,PB_warm_start_heat_req),0)-$BQ6)*TES_aux_cons_perc,1))
    for i in 1..<8760 {
      h[BW + i] = iff(
        or(h[BT + i] == Double.zero, h[BM + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero), 0,
        roundUp(
          h[BK + i] + max(
            0,
            (min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(0, h[BK + i] + h[BV + i] - h[BP + i]))) + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
              * POLY(min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(0, h[BK + i] + h[BV + i] - h[BP + i]))) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) / PB_gross_min_eff
              + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[BM + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])) * PB_Ratio_Heat_input_vs_output
              + iff(and(h[BV + i] == Double.zero, h[BV + i + 1] > Double.zero), iff((h[max(BV + i - 5, BV)...(BV + i)]
                    .reduce(0) {
                      if $1 < 0.000001 { return $0 + 1 }
                      return $0
                    }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), 0) - h[BQ + i]) * TES_aux_cons_perc, 1))
    }

    /// Corresponding PB net elec output
    let BX: Int = 595680
    // BX=IF(AND(BV6=0,BV6+BW6-$BP6<=0),0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-$BP6)))
    for i in 1..<8760 { h[BX + i] = iff(and(h[BV + i].isZero, (h[BV + i] + h[BW + i] - h[BP + i]) <= Double.zero), Double.zero, max(PB_net_min_cap, min(PB_nom_net_cap, h[BV + i] + h[BW + i] - h[BP + i]))) }
    /// Corresponding PB gross elec output
    let BY: Int = 604440
    // =IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 { h[BY + i] = iff(h[BX + i].isZero, Double.zero, h[BX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(h[BX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) }
    /// ST startup heat cons
    let BZ: Int = 613200
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      let count: Int =
        (h[max(BY + i - 5, BY)...(BY + i)]
          .reduce(0) {
            if $1 < 0.000001 { return $0 + 1 }
            return $0
          })
      h[BZ + i] = iff(and(h[BY + i].isZero, h[BY + i + 1] > Double.zero), iff(count < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), Double.zero)
    }
    let BZsum: [Double] = h.sum(hours: BOday, condition: BZ)
    /// Corresponding gross heat cons for ST
    let CA: Int = 621960
    // =IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { h[CA + i] = iff(h[BY + i].isZero, Double.zero, h[BY + i] / PB_nom_gross_eff / POLY(h[BY + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let CAsum: [Double] = h.sum(hours: BOday, condition: CA)
    /// Gross heat cons for extraction
    let CB: Int = 630720
    // =IF(OR(BT6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,BX6+$BP6-BW6-BV6)*El_boiler_eff)))
    for i in 1..<8760 {
      h[CB + i] = iff(
        or(h[BT + i].isZero, h[BM + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero), Double.zero,
        PB_Ratio_Heat_input_vs_output
          * max(
            Double.zero,
            overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[BM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - h[BQ + i]
              - min(El_boiler_cap_ud, max(Double.zero, h[BX + i] + h[BP + i] - h[BW + i] - h[BV + i]) * El_boiler_eff)))
    }
    let CBsum: [Double] = h.sum(hours: BOday, condition: CB)
    /// TES energy needed to fulfil op case
    let CC: Int = 639480
    // IF(MIN(SUMIF(BO5:BO8764,"="BO6,AY5:AY8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap_ud)<SUMIF(BO5:BO8764,"="BO6,BZ5:BZ8764)+SUMIF(BO5:BO8764,"="BO6,CA5:CA8764)+SUMIF(BO5:BO8764,"="BO6,CB5:CB8764),0,SUMIF(BO5:BO8764,"="&BO6,BZ5:BZ8764)+SUMIF(BO5:BO8764,"="BO6,CA5:CA8764)+SUMIF(BO5:BO8764,"="BO6,CB5:CB8764))
    for i in 1..<8760 { h[CC + i] = iff(min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < BZsum[i - 1] + CAsum[i - 1] + CBsum[i - 1], Double.zero, BZsum[i - 1] + CAsum[i - 1] + CBsum[i - 1]) }
    /// Surplus TES energy due to op case
    let CD: Int = 648240
    // =IF(CC6=0,0,ROUND(MAX(0,SUMIF($BO$5:$BO$8764,"="&$BO6,$AY$5:$AY$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6),5))
    for i in 1..<8760 { h[CD + i] = iff(h[CC + i].isZero, Double.zero, max(Double.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - h[CC + i])) }
    /// Peripherial PV hour PV to heater
    let CE: Int = 657000
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { h[CE + i] = iff(or(and(h[CD + i] > Double.zero, h[AY + i] > Double.zero, h[AY + i - 1].isZero), and(h[CD + i] > Double.zero, h[AY + i + 1].isZero, h[AY + i] > Double.zero)), h[AY + i], Double.zero) }
    let CEsum: [Double] = h.sum(hours: BOday, condition: CE)
    /// Surplus energy due to op limit after removal of peripherial hours
    let CF: Int = 665760
    // =ROUND(MAX(0,CD6-SUMIF($BO$5:$BO$8764,"="&$BO6,CE$5:CE$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)),5)
    for i in 1..<8760 { h[CF + i] = max(Double.zero, h[CD + i] - CEsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }
    /// intermediate resulting PV elec to TES
    let CG: Int = 674520
    // IF(CD6=0;0;ROUND($AY6-(CD6-CF6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;CE$5:CE$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6;5))
    for i in 1..<8760 { h[CG + i] = iff(h[CD + i].isZero, Double.zero, round(h[AY + i] - (h[CD + i] - h[CF + i]) / (CEsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * h[CE + i], 5)) }
    let CG_BOcountNonZero = h.count(hours: BOday, range: CG, predicate: { $0 > 0.000001 })
    let CGsum: [Double] = h.sum(hours: BOday, condition: CG)
    let J: Int = 17520
    let AW: Int = 359160
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let CH: Int = 683280
    // IF(OR(CG6=0,CF6=0),0,MAX(($AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764,">0")),($J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764,">0")))/SUMIF($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764)*CG6)
    for i in 1..<8760 {
      h[CH + i] = iff(
        or(h[CG + i].isZero, h[CF + i].isZero), Double.zero,
        max(
          (h[AW + i] - h[CG + i]) / (h[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CG_BOcountNonZero[i - 1]),
          (h[J + i] - h[CG + i] * Heater_eff / Ratio_CSP_vs_Heater) / (h[CF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i - 1])) / CGsum[i - 1] * h[CG + i])
    }
    let CHsum: [Double] = h.sum(hours: BOday, condition: CH)
    /// corrected max possible PV elec to TES
    let CI: Int = 692040
    // =IF(CC6=0,0,ROUND(MAX(0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($BO$5:$BO$8764,"="&$BO6,CH$5:CH$8764)*CH6)),5))
    for i in 1..<8760 { h[CI + i] = iff(h[CC + i].isZero, Double.zero, round(max(Double.zero, h[CG + i] - iff(h[CF + i].isZero, Double.zero, h[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i - 1] * h[CH + i])),5)) }
    /// Max possible CSP heat to TES
    let CJ: Int = 700800
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { h[CJ + i] = min(h[J + i], h[CI + i] * Heater_eff / Ratio_CSP_vs_Heater) }
    /// Available elec from PV after TES chrg
    let CK: Int = 709560
    /// Available heat from CSP after TES
    let CL: Int = 718320
    let L: Int = 35040
    for i in 1..<8760 {
      // =MAX(0,$L6-CI6)
      h[CK + i] = max(Double.zero, h[L + i] - h[CI + i])
      // =MAX(0,$J6-CJ6)
      h[CL + i] = max(Double.zero, h[J + i] - h[CJ + i])
    }
    let M: Int = 43800
    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let CM: Int = 727080
    // =IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(CC6=0,AND(BY6=0,BZ6=0)),PB_stby_aux_cons,0)+IF(AND(CC6>0,BZ6>0),PB_stup_aux_cons+BZ6*TES_aux_cons_perc,0)+IF(AND(CC6>0,BY6>0),(BZ6+CA6+CB6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      h[CM + i] =
        iff(h[J + i] > Double.zero, h[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + h[M + i] + (h[CI + i] * Heater_eff + h[CJ + i]) * TES_aux_cons_perc
        + iff(or(h[CC + i].isZero, and(h[BY + i].isZero, h[BZ + i].isZero)), PB_stby_aux_cons, Double.zero)
        + iff(and(h[CC + i] > Double.zero, h[BZ + i] > Double.zero), PB_stup_aux_cons + h[BZ + i] * TES_aux_cons_perc, Double.zero)
        + iff(and(h[CC + i] > Double.zero, h[BY + i] > Double.zero), (h[BZ + i] + h[CA + i] + h[CB + i]) * TES_aux_cons_perc, Double.zero)
    }
  }
  func hour3(_ h: inout [Double], case j: Int) {
    let (L, BV, BX, CB, CC, CI, CK, CL, CM) = (35040, 578160, 595680, 630720, 639480, 692040, 709560, 718320, 727080)

    /// Min harm net elec cons
    let CP: Int = 753360
    // CP=IF(OR(AND(BV6>0,CC6>0),ROUNDUP(MIN(CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff),MAX(0,CL6+MIN(El_boiler_cap_ud,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5)),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      h[CP + i] = iff(
        or(
          and(h[BV + i] > Double.zero, h[CC + i] > Double.zero),
          roundUp(
            min(
              h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i]
                - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[CL + i]) / El_boiler_eff),
              max(
                0,
                h[CL + i] + min(El_boiler_cap_ud, max(0, h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                  - Overall_heat_fix_cons - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5)), 0, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let CQ: Int = 762120
    // IF(OR(AND(CP6>0,CP5=0,CP7=0),AND(CP6>0,OR(AND(CP4=0,CP5>0,CP7=0),AND(CP5=0,CP7>0,CP8=0)))),0,CP6)
    for i in 1..<8760 {
      h[CQ + i] = iff(
        or(
          and(h[CP + i] > Double.zero, h[CP + i - 1].isZero, h[min(CP + i + 1, 770880)].isZero),
          and(h[CP + i] > Double.zero, or(and(h[max(CP + i - 2, CP)].isZero, h[CP + i - 1] > Double.zero, h[min(CP + i + 1, CQ)].isZero), and(h[CP + i - 1].isZero, h[min(CP + i + 1, CQ)] > Double.zero, h[min(CP + i + 2, CQ)].isZero)))),
        Double.zero, h[CP + i])
    }
    /// Min harmonious net heat cons
    let CR: Int = 770880
    // CR=IF(OR(CQ6=0,AND(BV6>0,CC6>0),ROUNDUP(MIN(CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff),MAX(0,CL6+MIN(El_boiler_cap_ud,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons-Overall_harmonious_var_heat_min_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5)),0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      h[CR + i] = iff(
        or(
          h[CQ + i] == Double.zero, and(h[BV + i] > Double.zero, h[CC + i] > Double.zero),
          roundUp(
            min(
              h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i]
                - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[CL + i]) / El_boiler_eff),
              max(
                0,
                h[CL + i] + min(El_boiler_cap_ud, max(0, h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                  - Overall_heat_fix_cons - Overall_harmonious_var_heat_min_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5)), 0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons)
    }
    /// Not covered aux elec MWel
    let CN: Int = 735840
    // =IF(CI6=0,0,MAX(0,ROUND(CI6+CM6+CQ6+MIN(El_boiler_cap_ud,MAX(0,CR6-CL6)/El_boiler_eff)-$L6,5)))
    for i in 1..<8760 { h[CN + i] = iff(h[CI + i].isZero, Double.zero, max(Double.zero, round(h[CI + i] + h[CM + i] + h[CQ + i] + min(El_boiler_cap_ud, max(Double.zero, h[CR + i] - h[CL + i]) / El_boiler_eff) - h[L + i], 5))) }
    /// Harmonious op day
    let CS: Int = 779640
    // IF(OR(AND(CQ5<=0,CQ6>0,SUM(CQ$1:CQ5)=0),AND($F5<=0,$F6>0,SUM(CQ$1:CQ16)=0)),IF(CS5<364,CS5+1,0),CS5)
    // IF(AND(CQ17=0,CQ18>0,COUNTIF(CS6:CS17,CS17)=12),CS17+1,IF(AND($F17=0,$F18>0,COUNTIF(CQ19:CQ30,0)=12),CS17+1,CS17))
    for i in 12..<8748 {
      h[CS + i] = h[CS + i - 1]
      if h[CQ + i - 1].isZero, h[CQ + i] > Double.zero, h[CQ + i + 1] > Double.zero, h[(CS + i - 12)..<(CS + i)].allSatisfy({ $0 == h[CS + i] }) {
        h[CS + i] += 1
      } else if h[i - 1].isZero, h[i] > Double.zero, h[CQ + i..<CQ + i + 12].allSatisfy(\.isZero), h[CS + i - 12..<CS + i].allSatisfy({ $0 == h[CS + i] }) {
        h[CS + i] += 1
      }
    }
    for i in 8748..<8760 { h[CS + i] = h[CS + i - 1] }
    /// El cons due to op outside of harm op period
    let CT: Int = 788400
    // =IF(OR(CQ6>0,CC6=0,MAX(0,IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-CN6)+BX6+CK6-CM6<A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),IF(CQ6>0,0,IF(CQ7=0,Overall_stby_cons,Overall_stup_cons)),A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons))
    for i in 1..<8760 {
      h[CT + i] = iff(
        or(
          h[CQ + i] > Double.zero, h[CC + i].isZero,
          max(Double.zero, iff(h[CQ + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[CN + i])
            + h[BX + i] + h[CK + i] - h[CM + i] < overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[CQ + i + 1].isZero, Double.zero, overall_stup_cons[j])),
        iff(h[CQ + i] > Double.zero, Double.zero, iff(h[CQ + i + 1].isZero, Overall_stby_cons, Overall_stup_cons)),
        overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[CQ + i + 1].isZero, Double.zero, overall_stup_cons[j]))
    }

    /// heat cons due to op outside of harm op period
    let CU: Int = 797160
    // =IF(OR(CR6>0,CC6=0,CB6/PB_Ratio_Heat_input_vs_output+CL6+MIN(El_boiler_cap_ud,MAX(0,IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-CN6)+BX6+CK6-CM6-CT6)*El_boiler_eff<A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons)),IF(CQ6>0,0,IF(CQ7=0,Overall_heat_stby_cons,Overall_heat_stup_cons)),A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons))
    for i in 1..<8760 {
      h[CU + i] = iff(
        or(
          h[CR + i] > Double.zero, h[CC + i].isZero,
          h[CB + i] / PB_Ratio_Heat_input_vs_output + h[CL + i] + min(
            El_boiler_cap_ud,
            max(Double.zero, iff(h[CQ + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[CN + i])
              + h[BX + i] + h[CK + i] - h[CM + i] - h[CT + i]) * El_boiler_eff < overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(h[CR + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])),
        iff(h[CQ + i] > Double.zero, Double.zero, iff(h[CQ + i + 1].isZero, Overall_heat_stby_cons, Overall_heat_stup_cons)),
        overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[CR + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]))
    }

    let J: Int = 17520
    let CJ: Int = 700800
    /// Remaining el after min harmonious
    let CV: Int = 805920
    // =MAX(0,ROUND($L6+IF(CC6>0,BX6,0)-CI6-CM6-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,CR6+CU6+CJ6-$J6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff),5))
    for i in 1..<8760 {
      h[CV + i] = max(
        Double.zero,        
          h[L + i] + iff(h[CC + i] > Double.zero, h[BX + i], Double.zero) - h[CI + i] - h[CM + i] - h[CQ + i] - h[CT + i]
            - min(El_boiler_cap_ud, max(Double.zero, h[CR + i] + h[CU + i] + h[CJ + i] - h[J + i] - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero)) / El_boiler_eff))
    }
    /// Remaining heat after min harmonious
    let CW: Int = 814680
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 1..<8760 { h[CW + i] = max(Double.zero, round(h[CL + i] + iff(h[CC + i].isZero, Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output) - h[CR + i] - h[CU + i], 5)) }
    /// Electr demand not covered after min harm and stby
    let CX: Int = 823440
    // =MAX(0,-ROUND(IF(CC6>0,BX6,0)+CK6-CM6-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[CX + i] = max(
        Double.zero,
          -(iff(h[CC + i] > Double.zero, h[BX + i], Double.zero) + h[CK + i] - h[CM + i] - h[CQ + i] - h[CT + i]
            - min(El_boiler_cap_ud, max(Double.zero, (h[CR + i] + h[CU + i] - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - h[CL + i]) / El_boiler_eff))))
    }
    /// Grid import for TES chrg, min harm, stby and outside harm op prod
    let CO: Int = 744600
    // =MIN(IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,CX6)
    for i in 1..<8760 { h[CO + i] = min(iff(h[CQ + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, h[CX + i]) }
    /// Remaining grid import capacity after min harm
    let CY: Int = 832200
    // =MAX(0,IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-CO6)
    for i in 1..<8760 { h[CY + i] = max(Double.zero, iff(h[CQ + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[CO + i]) }
    /// El boiler op after min harmonious heat cons
    let CZ: Int = 840960
    // =MIN(El_boiler_cap_ud,MAX(0,ROUND(CR6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0),5)/El_boiler_eff))
    for i in 1..<8760 { 
      h[CZ + i] = min(El_boiler_cap_ud, 
      max(Double.zero, (h[CR + i] + h[CU + i] - h[CL + i]
       - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero))
        / El_boiler_eff))
     }
    /// Remaining el boiler cap after min harmonious heat cons
    let DA: Int = 849720
    // MAX(0,El_boiler_cap_ud-CZ6)
    for i in 1..<8760 { 
      h[DA + i] = max(Double.zero, El_boiler_cap_ud - h[CZ + i]) 
    }
    /// Remaining MethSynt cap after min harmonious cons
    let DB: Int = 858480
    /// Remaining CCU cap after min harmonious cons
    let DC: Int = 867240
    /// Remaining EY cap after min harmonious cons
    let DD: Int = 876000
    // Remaining MethSynt cap after min harm & min outside harm meth prod & stby
// DB=MethSynt_RawMeth_nom_prod_ud*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),MAX(0,A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),MAX(0,A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DB + i] =
        MethSynt_RawMeth_nom_prod_ud
        * iff(
          and(
            h[CQ + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
              max(
                0,
                RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CW + i] + h[DA + i] * El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i]
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < MethSynt_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
            max(
              0,
              RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CW + i] + h[DA + i] * El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i]
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    // Remaining CCU cap after min harm & min outside harm meth prod & stby
    // DC=CCU_CO2_nom_prod_ud*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),MAX(0,A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),MAX(0,A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DC + i] =
        CCU_CO2_nom_prod_ud
        * iff(
          and(
            h[CQ + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)),
              max(
                0,
                CO2_max_cons[j] / CCU_CO2_nom_prod_ud
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CW + i] + h[DA + i] * El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i]
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < CCU_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)),
            max(
              0,
              CO2_max_cons[j] / CCU_CO2_nom_prod_ud
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CW + i] + h[DA + i] * El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i]
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    // Remaining EY cap after min harm & min outside harm meth prod & stby
    // DD=EY_Hydrogen_nom_prod*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),MAX(0,A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),MAX(0,A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DD + i] =
        EY_Hydrogen_nom_prod
        * iff(
          and(
            h[CQ + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)),
              max(
                0,
                Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CW + i] + h[DA + i] * El_boiler_eff
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[CV + i] + h[CY + i]
                          - iff(
                            h[CQ + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < EY_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)),
            max(
              0,
              Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i] + h[CW + i] / El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CW + i] + h[DA + i] * El_boiler_eff
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[CV + i] + h[CY + i]
                        - iff(
                          h[CQ + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    /// Max BESS charging after min harmonious cons
    let DE: Int = 884760
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DF: Int = 893520
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,CV6)
      h[DE + i] = min(BESS_chrg_max_cons, h[CV + i])
      // =MIN(IF(CQ6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,CV6)
      h[DF + i] = min(
        iff(h[CQ + i] > Double.zero, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop)
          * Grid_export_max_ud, h[CV + i])
    }
    /// Max harmonious net elec cons without considering grid
    let DG: Int = 902280
    // =IF(CQ6=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,CL6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,CL6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      h[DG + i] = iff(
        h[CQ + i].isZero, Double.zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            Double.one,
            max(
              Double.zero,
              h[CK + i]
                + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[CI + i] - h[L + i]))
                - h[CM + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(
                  Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[CL + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons
                + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              Double.zero,
              h[CL + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(
                Double.zero,
                h[CK + i]
                  + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[CI + i] - h[L + i]))
                  - h[CM + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons
                + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(
              Double.zero,
              h[CL + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }
    /// Optimized max harmonious net elec cons
    let DH: Int = 911040
    // IF(OR(AND(DG6>0,DG5=0,DG7=0),AND(DG6>0,OR(AND(DG4=0,DG5=0,DG8=0),AND(DG4=0,DG7=0,DG8=0)))),0,DG6)
    for i in 1..<8760 {
      h[DH + i] = iff(
        or(
          and(h[DG + i] > Double.zero, h[DG + i - 1].isZero, h[DG + i + 1].isZero),
          and(
            h[DG + i] > Double.zero,
            or(
              and(h[DG + i - 2].isZero, h[DG + i - 1] > Double.zero, h[DG + i + 1].isZero),
              and(h[DG + i - 1].isZero, h[DG + i + 1] > Double.zero, h[DG + i + 2].isZero)))), Double.zero, h[DG + i])
    }
    /// max harmonious net heat cons
    let DI: Int = 919800
    // DI=IF(OR(CQ6=0,DH6=0),0,Overall_heat_fix_cons+Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*MIN(1,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,CL6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,CL6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      h[DI + i] = iff(
        or(h[CQ + i] == Double.zero, h[DH + i] == Double.zero), 0,
        Overall_heat_fix_cons + Overall_harmonious_var_heat_min_cons
          + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)
          * min(
            1,
            max(
              0,
              h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i]
                - Overall_harmonious_var_min_cons - Overall_fix_cons - max(
                  0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[CL + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons
                + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              0,
              h[CL + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(
                0,
                h[CK + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[CI + i] - h[L + i])) - h[CM + i]
                  - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons
                + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(0, h[CL + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }
    /// Remaining el after max harmonious
    let DJ: Int = 928560
    // =MAX(0,ROUND(L6+IF(CC6>0,BX6,0)-CI6-CM6-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6+CJ6-J6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[DJ + i] = max(
        0,
        h[L + i] + iff(h[CC + i] > Double.zero, h[BX + i], Double.zero) - h[CI + i] - h[CM + i] - h[DH + i] - h[CT + i]
          - min(
            El_boiler_cap_ud,
            max(
              Double.zero,
              (h[DI + i] + h[CU + i] + h[CJ + i] - h[J + i]
                - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero)) / El_boiler_eff)))
    }
    /// Remaining heat after max harmonious
    let DK: Int = 937320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 1..<8760 {
      h[DK + i] = max(
        Double.zero,
        h[CL + i] + iff(h[CC + i].isZero, Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output) - h[DI + i] - h[CU + i])
    }

    /// Electr demand not covered after max harm and stby
    let DL: Int = 946080
    // =MAX(0,-ROUND(IF(CC6>0,BX6,0)+CK6-CM6-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[DL + i] = max(
        Double.zero,
        -(iff(h[CC + i] > Double.zero, h[BX + i], Double.zero) + h[CK + i] - h[CM + i] - h[DH + i] - h[CT + i]
          - min(
            El_boiler_cap_ud,
            max(
              Double.zero,
              (h[DI + i] + h[CU + i] - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero)
                - h[CL + i]) / El_boiler_eff))))
    }
    /// Grid import for max harm and stby
    let DU: Int = 1_024_920
    // =MIN(IF(DH6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,DL6)
    for i in 1..<8760 {
      h[DU + i] = min(
        iff(h[DH + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop)
          * Grid_import_max_ud, h[DL + i])
    }

    /// Remaining grid import capacity after max harm
    let DM: Int = 954840
    // =MAX(0,IF(DH6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-DU6)
    for i in 1..<8760 {
      h[DM + i] = max(
        Double.zero,
        iff(h[DH + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop)
          * Grid_import_max_ud - h[DU + i])
    }

    /// El boiler op after max harmonious heat cons
    let DN: Int = 963600
    // MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 1..<8760 {
      h[DN + i] = min(
        El_boiler_cap_ud,
        max(
          Double.zero,
          (h[DI + i] + h[CU + i] - h[CL + i] - iff(h[CC + i] > Double.zero, h[CB + i] / PB_Ratio_Heat_input_vs_output, Double.zero))
            / El_boiler_eff))
    }
    let TH: Int = CZ
    // TH=MAX(0,-ROUND(CL5+CB5/PB_Ratio_Heat_input_vs_output+CZ5*El_boiler_eff-CR5-CU5,5))
    for i in 1..<8760 {
      h[TH + i] = max(
        Double.zero, -(h[CL + i] + h[CB + i] / PB_Ratio_Heat_input_vs_output + h[CZ + i] * El_boiler_eff - h[CR + i] - h[CU + i]))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let DO: Int = 972360
    // MAX(0,El_boiler_cap_ud-DN6)
    for i in 1..<8760 { h[DO + i] = max(Double.zero, El_boiler_cap_ud - h[DN + i]) }

    let TI: Int = DN
    // TI=MAX(0,-ROUND(CL5+CB5/PB_Ratio_Heat_input_vs_output+DN5*El_boiler_eff-DI5-CU5,5))
    for i in 1..<8760 {
      h[TI + i] = max(
        Double.zero, -(h[CL + i] + h[CB + i] / PB_Ratio_Heat_input_vs_output + h[DN + i] * El_boiler_eff - h[DI + i] - h[CU + i]))
    }

    let DP: Int = 981120
    let DQ: Int = 989880
    let DR: Int = 998640
    // Remaining MethSynt cap after max harm & min outside harm meth prod & stby
    // DP=MethSynt_RawMeth_nom_prod_ud*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),MAX(0,A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),MAX(0,A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DP + i] =
        MethSynt_RawMeth_nom_prod_ud
        * iff(
          and(
            h[DH + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
              max(
                0,
                RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DK + i] + h[DO + i] * El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i]
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < MethSynt_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
            max(
              0,
              RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DK + i] + h[DO + i] * El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i]
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    // Remaining CCU cap after max harm & min outside harm meth prod & stby
    // DQ=CCU_CO2_nom_prod_ud*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),MAX(0,A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),MAX(0,A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DQ + i] =
        CCU_CO2_nom_prod_ud
        * iff(
          and(
            h[DH + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)),
              max(
                0,
                CO2_max_cons[j] / CCU_CO2_nom_prod_ud
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DK + i] + h[DO + i] * El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i]
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < CCU_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)),
            max(
              0,
              CO2_max_cons[j] / CCU_CO2_nom_prod_ud
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DK + i] + h[DO + i] * El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i]
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    // Remaining EY cap after max harm & min outside harm meth prod & stby
    // DR=EY_Hydrogen_nom_prod*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),MAX(0,A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op))))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),MAX(0,A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))))
    for i in 1..<8760 {
      h[DR + i] =
        EY_Hydrogen_nom_prod
        * iff(
          and(
            h[DH + i] == Double.zero,
            min(
              1,
              max(
                0,
                1
                  - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                    * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)),
              max(
                0,
                Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
                  * min(
                    iff(
                      daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                        / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                    iff(
                      daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DK + i] + h[DO + i] * El_boiler_eff
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                    iff(
                      daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                      max(
                        0,
                        h[DJ + i] + h[DM + i]
                          - iff(
                            h[DH + i] == Double.zero,
                            iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                              + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                              + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j]))))
              < EY_cap_min_perc), 0,
          min(
            1,
            max(
              0,
              1
                - ((max(0, h[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                  * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)),
            max(
              0,
              Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
                * min(
                  iff(
                    daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i] + h[DK + i] / El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                      / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
                  iff(
                    daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DK + i] + h[DO + i] * El_boiler_eff
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, -MethSynt_heat_fix_prod)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_heat_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
                  iff(
                    daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
                    max(
                      0,
                      h[DJ + i] + h[DM + i]
                        - iff(
                          h[DH + i] == Double.zero,
                          iff(RawMeth_max_cons[j] == Double.zero, 0, MethSynt_fix_cons)
                            + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, CCU_fix_cons)
                            + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == Double.zero, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))))
    }

    /// Max BESS charging after max harmonious cons
    let DS: Int = 1_007_400

    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 1..<8760 { h[DS + i] = min(BESS_chrg_max_cons, h[DJ + i]) }
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DT: Int = 1_016_160
    // =MIN(IF(DH6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,DJ6)
    for i in 1..<8760 { h[DT + i] = min(iff(h[DH + i] > Double.zero, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, h[DJ + i]) }
  }
}
