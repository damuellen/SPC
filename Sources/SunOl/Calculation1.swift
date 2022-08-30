extension TunOl {
  func hour2(_ hour2: inout [Double], j: Int, hour0: [Double], hour1: [Double]) {
    let (J0, L0, M0, BK1, BM1, BO1, BP1, BQ1) = (26280, 43800, 52560, 131400, 148920, 166440, 175200, 183960)
    let daysBO: [[Int]] = hour1[BO1 + 1..<(BO1 + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] }).map { $0.map { $0 - BO1 } }

    let BMcountZero = hour1.count(hours: daysBO, range: BM1, predicate: { $0 <= 0 })
    /// Number of outside harm op period hours
    let BR = 0
    // =COUNTIFS($BO$5:$BO$8764,"="&$BO6,$BM$5:$BM$8764,"<=0")
    for i in 1..<8760 { hour2[BR + i] = BMcountZero[i - 1] }
    let AY1 = 26280
    let BF1 = 87600
    let AYsum = hour1.sum(hours: daysBO, condition: AY1)
    let BFcount = hour1.count(hours: daysBO, range: BF1, predicate: { $0 > 0 })
    /// Number of night hours
    // let BLcount = hour1.count(hours: daysBO, range: BL, predicate: { $0 <= 0 })  // BR=COUNTIFS($BO$5:$BO$8764,"="&$BO5,$BL$5:$BL$8764,"<=0")

    /// Minimum night op possible considering tank sizes
    let BT2 = 175200
    // BT=IF(OR($BR6*A_RawMeth_min_cons>RawMeth_storage_cap_ud,$BR6*A_CO2_min_cons>CO2_storage_cap_ud,$BR6*A_Hydrogen_min_cons>Hydrogen_storage_cap_ud,COUNTIFS($BO$5:$BO$8764,"="&$BO6,$BF$5:$BF$8764,">0")=0),0,1)
    for i in 1..<8760 { hour2[BT2 + i] = iff(or(BMcountZero[i - 1] * RawMeth_min_cons[j] > RawMeth_storage_cap_ud, BMcountZero[i - 1] * CO2_min_cons[j] > CO2_storage_cap_ud, BMcountZero[i - 1] * Hydrogen_min_cons[j] > Hydrogen_storage_cap_ud, BFcount[i - 1].isZero), 0, 1) }

    /// Min net elec demand outside harm op period
    let BU = 0
    // BU=IF(OR(BT6=0,$BM6>0,AND(A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6)/El_boiler_eff)<$BP6-PB_stby_aux_cons,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)<El_boiler_cap_ud*El_boiler_eff+$BQ6)),0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons)))
    for i in 1..<8760 {
      hour2[BU + i] = iff(or(hour2[BT2 + i].isZero, hour1[BM1 + i] > .zero, and(overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_stup_cons[j]) + min(El_boiler_cap_ud, max(.zero, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_heat_stup_cons[j]) - hour1[BQ1 + i]) / El_boiler_eff)<hour1[BP1 + i] - PB_stby_aux_cons, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_heat_stup_cons[j])<El_boiler_cap_ud * El_boiler_eff + hour1[BQ1 + i])), .zero, overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_stup_cons[j]))
    }

    /// Optimized min net elec demand outside harm op period
    let BV = 8760
    // =IF(OR(AND(BU6>0,BU5=0,BU7=0,BU4=0,BU8=0),AND(BU6=0,BU5>0,BU7>0),AND(BU6>0,OR(AND(BU4=0,BU5>0,BU7=0),AND(BU5=0,BU7>0,BU8=0)))),BU5,BU6)
    for i in 1..<8760 {
      let a = hour2[max(BU + i - 2, BU)]
      let b = hour2[max(BU + i - 1, BU)]
      let c = hour2[min(BU + i + 1, BV - 1)]
      let d = hour2[min(BU + i + 2, BV - 1)]
      hour2[BV + i] = iff(
        or(
          and(hour2[BU + i] > 0, b.isZero, c.isZero, a.isZero, d.isZero), and(hour2[BU + i].isZero, b > 0, c > 0),
          and(hour2[BU + i] > 0, or(and(a.isZero, b > 0, c.isZero), and(b.isZero, c > 0, d.isZero)))), b, hour2[BU + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let BW = 17520
    // =ROUNDUP(IF(OR(BT7=0,$BM7>0,PB_nom_gross_cap_ud<=0),0,$BK7+MAX(0,(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,BV7-$BP7)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,BV7-$BP7)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV7-$BP7))-PB_net_min_cap))+(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*PB_Ratio_Heat_input_vs_output+IF(AND(BV7=0,BV8>0),IF(COUNTIF(BV2:BV7,"0")<PB_warm_start_duration,PB_hot_start_heat_req,PB_warm_start_heat_req),0)-$BQ7)*TES_aux_cons_perc),1)
    for i in 1..<8760 {
      hour2[BW + i] = (iff(
        or(hour2[BT2 + i].isZero, hour1[BM1 + i] > .zero, PB_nom_gross_cap_ud <= .zero), .zero,
        hour1[BK1 + i]
          + max(.zero, (min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour2[BV + i] - hour1[BP1 + i]))) + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour2[BV + i] - hour1[BP1 + i]))) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff)
            + PB_fix_aux_el) / (PB_gross_min_eff + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap) * (min(PB_nom_net_cap, max(0, hour2[BV + i] - hour1[BP1 + i])) - PB_net_min_cap)) + (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * PB_Ratio_Heat_input_vs_output
          + iff(
            and(hour2[BV + i].isZero, hour2[BV + i + 1] > .zero),
              iff(
                (hour2[max(BV + i - 5, BV)...(BV + i)]
                  .reduce(0) {
                    if $1.isZero { return $0 + 1 }
                    return $0
                  }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), 0) - hour1[BQ1 + i]) * TES_aux_cons_perc) * 10).rounded(.up) / 10
    }

    /// Corresponding PB net elec output
    let BX = 26280
    // BX=IF(AND(BV6=0,BV6+BW6-$BP6<=0),0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-$BP6)))
    for i in 1..<8760 {
      hour2[BX + i] = iff(and(hour2[BV + i] .isZero, (hour2[BV + i] + hour2[BW + i] - hour1[BP1 + i]) <= 0), .zero, max(PB_net_min_cap, min(PB_nom_net_cap, hour2[BV + i] + hour2[BW + i] - hour1[BP1 + i]))) 
    }

    /// Corresponding PB gross elec output
    let BY = 35040
    // =IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 { hour2[BY + i] = iff(hour2[BX + i].isZero, .zero, hour2[BX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(hour2[BX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) }

    /// ST startup heat cons
    let BZ = 43800
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      let count =
        (hour2[max(BY + i - 5, BY)...(BY + i)]
          .reduce(0) {
            if $1.isZero { return $0 + 1 }
            return $0
          })
      hour2[BZ + i] = iff(and(hour2[BY + i].isZero, hour2[BY + i + 1] > .zero), iff(count < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), .zero)
    }

    let BZsum = hour2.sum(hours: daysBO, condition: BZ)
    /// Corresponding gross heat cons for ST
    let CA = 52560
    // =IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { hour2[CA + i] = iff(hour2[BY + i].isZero, .zero, hour2[BY + i] / PB_nom_gross_eff / POLY(hour2[BY + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let CAsum = hour2.sum(hours: daysBO, condition: CA)
    /// Gross heat cons for extraction
    let CB = 61320
    // =IF(OR(BT6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,BX6+$BP6-BW6-BV6)*El_boiler_eff)))
    for i in 1..<8760 {
      hour2[CB + i] = iff(
        or(hour2[BT2 + i].isZero, hour1[BM1 + i] > .zero, PB_nom_gross_cap_ud <= .zero), .zero,
        PB_Ratio_Heat_input_vs_output * max(.zero, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_heat_stup_cons[j]) - hour1[BQ1 + i] - min(El_boiler_cap_ud, max(.zero, hour2[BX + i] + hour1[BP1 + i] - hour2[BW + i] - hour2[BV + i]) * El_boiler_eff)))
    }
    let CBsum = hour2.sum(hours: daysBO, condition: CB)
    /// TES energy needed to fulfil op case
    let CC = 70080
    // IF(MIN(SUMIF(BO5:BO8764,"="BO6,AY5:AY8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap_ud)<SUMIF(BO5:BO8764,"="BO6,BZ5:BZ8764)+SUMIF(BO5:BO8764,"="BO6,CA5:CA8764)+SUMIF(BO5:BO8764,"="BO6,CB5:CB8764),0,SUMIF(BO5:BO8764,"="&BO6,BZ5:BZ8764)+SUMIF(BO5:BO8764,"="BO6,CA5:CA8764)+SUMIF(BO5:BO8764,"="BO6,CB5:CB8764))
    for i in 1..<8760 { hour2[CC + i] = iff(min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < BZsum[i - 1] + CAsum[i - 1] + CBsum[i - 1], .zero, BZsum[i - 1] + CAsum[i - 1] + CBsum[i - 1]) }

    /// Surplus TES energy due to op case
    let CD = 78840
    // IF(CC6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-CC6))
    for i in 1..<8760 { hour2[CD + i] = iff(hour2[CC + i].isZero, .zero, max(.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hour2[CC + i])) }

    /// Peripherial PV hour PV to heater
    let CE = 87600
    // IF(OR(AND(CD6>0,AY6>0,AY5=0),AND(CD6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { hour2[CE + i] = iff(or(and(hour2[CD + i] > .zero, hour1[AY1 + i] > .zero, hour1[AY1 + i - 1].isZero), and(hour2[CD + i] > .zero, hour1[AY1 + i + 1].isZero, hour1[AY1 + i] > .zero)), hour1[AY1 + i], .zero) }
    let CEsum = hour2.sum(hours: daysBO, condition: CE)
    /// Surplus energy due to op limit after removal of peripherial hours
    let CF = 96360
    // MAX(0,CD6-SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour2[CF + i] = max(.zero, hour2[CD + i] - CEsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let CG = 105120
    // IF(CD6=0;0;ROUND($AY6-(CD6-CF6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;CE$5:CE$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6;5))
    for i in 1..<8760 { hour2[CG + i] = iff(hour2[CD + i].isZero, .zero, round(hour1[AY1 + i] - (hour2[CD + i] - hour2[CF + i]) / (CEsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour2[CE + i], 5)) }

    let CG_BOcountNonZero = hour2.count(hours: daysBO, range: CG, predicate: { $0 > 0 })
    let CGsum = hour2.sum(hours: daysBO, condition: CG)
    let AW0 = 3509160
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let CH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX(($AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764,">0")),($J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764,">0")))/SUMIF($BO$5:$BO$8764,"="&$BO6,CG$5:CG$8764)*CG6)
    for i in 1..<8760 {
      hour2[CH + i] = iff(
        or(hour2[CG + i].isZero, hour2[CF + i].isZero), .zero,
        max((hour0[AW0 + i] - hour2[CG + i]) / (hour2[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CG_BOcountNonZero[i - 1]), (hour0[J0 + i] - hour2[CG + i] * Heater_eff / Ratio_CSP_vs_Heater) / (hour2[CF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i - 1])) / CGsum[i - 1] * hour2[CG + i])
    }
    let CHsum = hour2.sum(hours: daysBO, condition: CH)
    /// corrected max possible PV elec to TES
    let CI = 122640
    // =IF(CC6=0,0,MAX(0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($BO$5:$BO$8764,"="&$BO6,CH$5:CH$8764)*CH6)))
    for i in 1..<8760 {
      hour2[CI + i] = iff(hour2[CC + i].isZero, .zero, max(.zero, hour2[CG + i] - iff(hour2[CF + i].isZero, .zero, hour2[CF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i - 1] * hour2[CH + i])))
    }

    /// Max possible CSP heat to TES
    let CJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour2[CJ + i] = min(hour0[J0 + i], hour2[CI + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Available elec from PV after TES chrg
    let CK = 140160
    /// Available heat from CSP after TES
    let CL = 148920
    for i in 1..<8760 {
      // MAX(0,L6-CI6)
      hour2[CK + i] = max(.zero, roundUp(hour0[L0 + i] - hour2[CI + i]))
      // MAX(0,J6-CJ6)
      hour2[CL + i] = max(.zero, roundUp(hour0[J0 + i] - hour2[CJ + i]))
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let CM = 157680
    // =ROUNDDOWN(IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(CI6*Heater_eff+CJ6)*TES_aux_cons_perc+IF(OR(CC6=0,AND(BY6=0,BZ6=0)),PB_stby_aux_cons,0)+IF(AND(CC6>0,BZ6>0),PB_stup_aux_cons+BZ6*TES_aux_cons_perc,0)+IF(AND(CC6>0,BY6>0),(BZ6+CA6+CB6)*TES_aux_cons_perc,0),2)
    for i in 1..<8760 {
      hour2[CM + i] = ((
        iff(hour0[J0 + i] > .zero, hour0[J0 + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[M0 + i] + (hour2[CI + i] * Heater_eff + hour2[CJ + i]) * TES_aux_cons_perc + iff(or(hour2[CC + i].isZero, and(hour2[BY + i].isZero, hour2[BZ + i].isZero)), PB_stby_aux_cons, .zero)
        + iff(and(hour2[CC + i] > .zero, hour2[BZ + i] > .zero), PB_stup_aux_cons + hour2[BZ + i] * TES_aux_cons_perc, .zero) + iff(and(hour2[CC + i] > .zero, hour2[BY + i] > .zero), (hour2[BZ + i] + hour2[CA + i] + hour2[CB + i]) * TES_aux_cons_perc, .zero)) * 100.0).rounded(.down) / 100
    }
  }

  func hour3(_ hour3: inout [Double], j: Int, hour0: [Double], hour1: [Double], hour2: [Double]) {
    let (BX2, CB2, CC2, CK2, CL2, CM2) = (26280, 61320, 70080, 140160, 148920, 157680)
    let CI2 = 122640
    let L0 = 43800
    let BV2 = 8760

    /// Min harmonious net elec cons not considering grid import
    let CP = 0
    // =IF(OR(BV6>0,MIN(CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff),MAX(0,CL6+MIN(El_boiler_cap_ud,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour3[CP + i] = iff(
        or(
          hour2[BV2 + i] > 0,
          min(
            hour2[CK2 + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, hour2[CI2 + i] - hour0[L0 + i])) - hour2[CM2 + i]
              - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour2[CL2 + i]) / El_boiler_eff),
            max(
              0,
              hour2[CL2 + i] + min(
                El_boiler_cap_ud,
                max(
                  0,
                  hour2[CK2 + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, hour2[CI2 + i] - hour0[L0 + i])) - hour2[CM2 + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)
              ) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons),
        0, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let CQ = 8760
    // IF(OR(AND(CP6>0,CP5=0,CP7=0),AND(CP6>0,OR(AND(CP4=0,CP5>0,CP7=0),AND(CP5=0,CP7>0,CP8=0)))),0,CP6)
    for i in 1..<8760 {
      hour3[CQ + i] = iff(or(and(hour3[CP + i] > .zero, hour3[CP + i - 1].isZero, hour3[CP + i + 1].isZero), and(hour3[CP + i] > .zero, or(and(hour3[max(i - 2, 0)].isZero, hour3[max(i - 1, 0)] > 0, hour3[CP + i + 1].isZero), and(hour3[max(i - 1, 0)].isZero, hour3[CP + i + 1] > 0, hour3[CP + i + 2].isZero)))), 0, hour3[CP + i])
    }

    /// Min harmonious net heat cons
    let CR = 17520
    // MAX(0,(CQ6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 { hour3[CR + i] = iff(hour3[CQ + i].isZero, .zero, max(.zero, (hour3[CQ + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Not covered aux elec MWel
    let CN = 289080
    // =IF(CI6=0,0,MAX(0,ROUND(CI6+CM6+CQ6+MIN(El_boiler_cap_ud,MAX(0,CR6-CL6)/El_boiler_eff)-$L6,5)))
    for i in 1..<8760 { 
      hour3[CN + i] = iff(hour2[CI2 + i].isZero, .zero, max(.zero, round(hour2[CI2 + i] + hour2[CM2 + i] + hour2[CQ + i] + min(El_boiler_cap_ud, max(.zero, hour3[CR + i] - hour2[CL2 + i]) / El_boiler_eff) - hour0[L0 + i], 5)))
    }

    /// Harmonious op day
    let CS = 26280
    // IF(OR(AND(CQ5<=0,CQ6>0,SUM(CQ$1:CQ5)=0),AND($F5<=0,$F6>0,SUM(CQ$1:CQ16)=0)),IF(CS5<364,CS5+1,0),CS5)
    // IF(AND(CQ17=0,CQ18>0,COUNTIF(CS6:CS17,CS17)=12),CS17+1,IF(AND($F17=0,$F18>0,COUNTIF(CQ19:CQ30,0)=12),CS17+1,CS17))
    for i in 12..<8748 {
      hour3[CS + i] = hour3[CS + i - 1]
      if hour3[CQ + i - 1].isZero, hour3[CQ + i] > 0, hour3[CQ + i + 1] > 0, hour3[(CS + i - 12)..<(CS + i)].allSatisfy( { $0 == hour3[CS + i] }) {
        hour3[CS + i] += 1
      } else if hour0[i - 1].isZero, hour0[i] > 0, hour3[CQ + i..<CQ + i + 12].allSatisfy(\.isZero), hour3[CS + i - 12..<CS + i].allSatisfy({ $0 == hour3[CS + i] }) {
        hour3[CS + i] += 1
      }
    }
    for i in 8748..<8760 { hour3[CS + i] = hour3[CS + i - 1] }
    /// El cons due to op outside of harm op period
    let CT = 35040
    // =IF(OR(CQ6>0,CC6=0,BX6+CK6-CM6<A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)),0,A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons))
    for i in 1..<8760 { 
      hour3[CT + i] = iff(
        or(hour3[CQ + i] > 0, hour2[CC2 + i].isZero, hour2[BX2 + i] + hour2[CK2 + i] - hour2[CM2 + i] < overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour3[CQ + i + 1].isZero, 0, overall_stup_cons[j])), 0,
        overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour3[CQ + i + 1].isZero, 0, overall_stup_cons[j]))
    }
    
    /// heat cons due to op outside of harm op period
    let CU = 43800
    // =IF(CT6=0,0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons))
    for i in 1..<8760 {
      hour3[CU + i] = iff(hour3[CT + i].isZero, 0, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour3[CQ + i + 1].isZero, 0, overall_heat_stup_cons[j]))
    }

    let J0 = 26280
    let CJ2 = 131400
    /// Remaining el after min harmonious
    let CV = 52560
    // =MAX(0,ROUND($L6+IF(CC6>0,BX6,0)-CI6-CM6-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,CR6+CU6+CJ6-$J6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff),5))
    for i in 1..<8760 {
      hour3[CV + i] = max(
        .zero, round(hour0[L0 + i] + iff(hour2[CC2 + i] > .zero, hour2[BX2 + i], .zero) - hour2[CI2 + i] - hour2[CM2 + i] - hour3[CQ + i] - hour3[CT + i] - min(El_boiler_cap_ud, max(.zero, hour3[CR + i] + hour3[CU + i] + hour2[CJ2 + i] - hour0[J0 + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero)) / El_boiler_eff), 5))
    }

    /// Remaining heat after min harmonious
    let CW = 61320
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-CR6-CU6)
    for i in 1..<8760 { hour3[CW + i] = max(.zero, round(hour2[CL2 + i] + iff(hour2[CC2 + i].isZero, .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output) - hour3[CR + i] - hour3[CU + i], 5)) }

    /// Electr demand not covered after min harm and stby
    let CX = 70080
    // =MAX(0,-ROUND(IF(CC6>0,BX6,0)+CK6-CM6-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      hour3[CX + i] = max(
        .zero, round(-(iff(hour2[CC2 + i] > .zero, hour2[BX2 + i], .zero) + hour2[CK2 + i] - hour2[CM2 + i] - hour3[CQ + i] - hour3[CT + i] - min(El_boiler_cap_ud, max(.zero, (hour3[CR + i] + hour3[CU + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero) - hour2[CL2 + i]) / El_boiler_eff))), 5))
    }

    /// Grid import for TES chrg, min harm, stby and outside harm op prod
    let CO = 271560
    // =MIN(IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,CX6)
    for i in 1..<8760 { 
      hour3[CO + i] = min(iff(hour3[CQ + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, hour3[CX + i]) 
    }

    /// Remaining grid import capacity after min harm
    let CY = 78840
    // =MAX(0,IF(CQ6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-CO6)
    for i in 1..<8760 { 
      hour3[CY + i] = max(0, iff(hour3[CQ + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - hour3[CO + i])
    }

    /// El boiler op after min harmonious heat cons
    let CZ = 87600
    // MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 1..<8760 { hour3[CZ + i] = min(El_boiler_cap_ud, max(.zero, round((hour3[CR + i] + hour3[CU + i] - hour2[CL2 + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero)), 5) / El_boiler_eff)) }

    /// Remaining el boiler cap after min harmonious heat cons
    let DA = 96360
    // MAX(0,El_boiler_cap_ud-CZ6)
    for i in 1..<8760 { hour3[DA + i] = max(.zero, round(El_boiler_cap_ud - hour3[CZ + i], 5)) }

    /// Remaining MethSynt cap after min harmonious cons
    let DB = 105120
    /// Remaining CCU cap after min harmonious cons
    let DC = 113880
    /// Remaining EY cap after min harmonious cons
    let DD = 122640

    for i in 1..<8760 {
      // DB=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CY6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DB + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= 0, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i] + hour3[CW + i] / El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= 0, 9999,
              max(
                0,
                hour3[CW + i] + hour3[DA + i] * El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= 0, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i]
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) 
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DB + i] = round(
        MethSynt_RawMeth_nom_prod_ud * iff(and(hour3[CQ + i] == 0, hour3[DB + i] < MethSynt_cap_min_perc), 0, hour3[DB + i]), 5)
      // DC=ROUND(CCU_CO2_nom_prod_ud*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CY6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DC + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        CO2_max_cons[j] / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i] + hour3[CW + i] / El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[CY + i] + hour3[DA + i] * El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i]
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DC + i] = round(CCU_CO2_nom_prod_ud * iff(and(hour3[CQ + i] == 0, hour3[DC + i] < CCU_cap_min_perc), 0, hour3[DC + i]), 5)
      // DD=ROUND(EY_Hydrogen_nom_prod*IF(AND(CQ6=0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CY6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,CV6+CY6+CW6/El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,CW6+DA6*El_boiler_eff-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,CV6+CY6-IF(CQ6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DD + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[CQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc)
              + EY_harmonious_min_perc)),
        Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i] + hour3[CW + i] / El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[CY + i] + hour3[DA + i] * El_boiler_eff
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[CV + i] + hour3[CY + i]
                  - iff(
                    hour3[CQ + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DD + i] = round(EY_Hydrogen_nom_prod * iff(and(hour3[CQ + i] == 0, hour3[DD + i] < EY_cap_min_perc), 0, hour3[DD + i]), 5)
    }

    /// Max BESS charging after min harmonious cons
    let DE = 131400
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DF = 140160
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,CV6)
      hour3[DE + i] = min(BESS_chrg_max_cons, hour3[CV + i])
      // =MIN(IF(CQ6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,CV6)
      hour3[DF + i] = min(iff(hour3[CQ + i] > 0, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, hour3[CV + i])

    }

    /// Max harmonious net elec cons without considering grid
    let DG = 148920
    // =IF(CQ6=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-CL6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,CL6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,CK6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,CI6-$L6))-CM6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,CL6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      hour3[DG + i] = iff(
        hour3[CQ + i].isZero, .zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            1,
            max(.zero, hour2[CK2 + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour2[CI2 + i] - hour0[L0 + i])) - hour2[CM2 + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour2[CL2 + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(.zero, hour2[CL2 + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(.zero, hour2[CK2 + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour2[CI2 + i] - hour0[L0 + i])) - hour2[CM2 + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(.zero, hour2[CL2 + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }

    /// Optimized max harmonious net elec cons
    let DH = 157680
    // IF(OR(AND(DG6>0,DG5=0,DG7=0),AND(DG6>0,OR(AND(DG4=0,DG5=0,DG8=0),AND(DG4=0,DG7=0,DG8=0)))),0,DG6)
    for i in 1..<8760 {
      hour3[DH + i] = iff(or(and(hour3[DG + i] > .zero, hour3[DG + i - 1].isZero, hour3[DG + i + 1].isZero), and(hour3[DG + i] > .zero, or(and(hour3[DG + i - 2].isZero, hour3[DG + i - 1] > 0, hour3[DG + i + 1].isZero), and(hour3[DG + i - 1].isZero, hour3[DG + i + 1] > 0, hour3[DG + i + 2].isZero)))), 0, hour3[DG + i])
    }

    /// max harmonious net heat cons
    let DI = 166440
    // MAX(0,(DH6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 { hour3[DI + i] = iff(hour3[DH + i].isZero, .zero, max(.zero, (hour3[DH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Remaining el after max harmonious
    let DJ = 175200
    // =MAX(0,ROUND(L6+IF(CC6>0,BX6,0)-CI6-CM6-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6+CJ6-J6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff)),5))
    for i in 1..<8760 {
      hour3[DJ + i] = max(
        .zero, round(hour0[L0 + i] + iff(hour2[CC2 + i] > .zero, hour2[BX2 + i], .zero) - hour2[CI2 + i] - hour2[CM2 + i] - hour3[DH + i] - hour3[CT + i] - min(El_boiler_cap_ud, max(.zero, (hour3[DI + i] + hour3[CU + i]  + hour2[CJ2 + i] - hour0[J0 + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero)) / El_boiler_eff)), 5))
    }

    /// Remaining heat after max harmonious
    let DK = 183960
    // MAX(0,CL6+IF(CC6=0,0,CB6/PB_Ratio_Heat_input_vs_output)-DI6-CU6)
    for i in 1..<8760 { hour3[DK + i] = max(.zero, round(hour2[CL2 + i] + iff(hour2[CC2 + i].isZero, .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output) - hour3[DI + i] - hour3[CU + i], 5)) }

    /// Electr demand not covered after max harm and stby
    let DL = 192720
    // =MAX(0,-ROUND(IF(CC6>0,BX6,0)+CK6-CM6-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      hour3[DL + i] = max(
        .zero, round(-(iff(hour2[CC2 + i] > .zero, hour2[BX2 + i], .zero) + hour2[CK2 + i] - hour2[CM2 + i] - hour3[DH + i] - hour3[CT + i] - min(El_boiler_cap_ud, max(.zero, (hour3[DI + i] + hour3[CU + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero) - hour2[CL2 + i]) / El_boiler_eff))), 5))
    }
    /// Grid import for max harm and stby
    let DU = 280320
    // =MIN(IF(DH6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,DL6)
    for i in 1..<8760 { 
      hour3[DU + i] = min(iff(hour3[DH + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, hour3[DL + i])
    }
    /// Remaining grid import capacity after max harm
    let DM = 201480
    // =MAX(0,IF(DH6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-DU6)
    for i in 1..<8760 { hour3[DM + i] = max(.zero, iff(hour3[DH + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - hour3[DU + i])
    }

    /// El boiler op after max harmonious heat cons
    let DN = 210240
    // MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-CL6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0))/El_boiler_eff))
    for i in 1..<8760 { hour3[DN + i] = min(El_boiler_cap_ud, max(.zero, round((hour3[DI + i] + hour3[CU + i] - hour2[CL2 + i] - iff(hour2[CC2 + i] > .zero, hour2[CB2 + i] / PB_Ratio_Heat_input_vs_output, .zero)), 5) / El_boiler_eff)) }

    /// Remaining el boiler cap after max harmonious heat cons
    let DO = 219000
    // MAX(0,El_boiler_cap_ud-DN6)
    for i in 1..<8760 { hour3[DO + i] = max(.zero, round(El_boiler_cap_ud - hour3[DN + i], 5)) }

    for i in 1..<8760 {
      /// Remaining MethSynt cap after max harmonious cons
      let DP = 227760
      /// Remaining CCU cap after max harmonious cons
      let DQ = 236520
      /// Remaining EY cap after max harmonious cons
      let DR = 245280
      // DP=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DM6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DP + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour3[DJ + i] + hour3[DM + i] + hour3[DK + i] / El_boiler_eff
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[DM + i] + hour3[DO + i] * El_boiler_eff
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[DJ + i] + hour3[DM + i]
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DP + i] = round(
        MethSynt_RawMeth_nom_prod_ud * iff(and(hour3[DH + i] == 0, hour3[DP + i] < MethSynt_cap_min_perc), 0, hour3[DP + i]), 5)
      // DQ=ROUND(CCU_CO2_nom_prod_ud*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DM6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DQ + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        CO2_max_cons[j] / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour3[DJ + i] + hour3[DM + i] + hour3[DK + i] / El_boiler_eff
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[DM + i] + hour3[DO + i] * El_boiler_eff
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour3[DJ + i] + hour3[DM + i]
                  - iff(
                    hour3[DH + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DQ + i] = round(CCU_CO2_nom_prod_ud * iff(and(hour3[DH + i] == 0, hour3[DQ + i] < CCU_cap_min_perc), 0, hour3[DQ + i]), 5)

      // DR=ROUND(EY_Hydrogen_nom_prod*IF(AND(DH6=0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DM6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,DJ6+DM6+DK6/El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,DK6+DO6*El_boiler_eff-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,DJ6+DM6-IF(DH6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour3[DR + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour3[DH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc)
              + EY_harmonious_min_perc)), Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod * min(iff(
        daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
        max(
          0,
          hour3[DJ + i] + hour3[DM + i] + hour3[DK + i] / El_boiler_eff
            - iff(
              hour3[DH + i] > 0, 0,
              iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                + iff((Hydrogen_max_cons[j] + RawMeth_max_cons[j]) == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
          / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)), iff(
        daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
        max(
          0,
          hour3[DM + i] + hour3[DO + i] * El_boiler_eff
            - iff(
              hour3[DH + i] > 0, 0,
              iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod) 
                + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                + iff((Hydrogen_max_cons[j] + RawMeth_max_cons[j]) == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]), iff(
        daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
        max(
          0,
          hour3[DJ + i] + hour3[DM + i]
            - iff(
              hour3[DH + i] > 0, 0,
              iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) 
                + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                + iff((Hydrogen_max_cons[j] + RawMeth_max_cons[j]) == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour3[DR + i] = round(EY_Hydrogen_nom_prod * iff(and(hour3[DH + i] == 0, hour3[DR + i] < EY_cap_min_perc), 0, hour3[DR + i]), 5)
    }

    /// Max BESS charging after max harmonious cons
    let DS = 254040
    // MIN(BESS_chrg_max_cons,DJ6)
    for i in 1..<8760 { hour3[DS + i] = min(BESS_chrg_max_cons, hour3[DJ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let DT = 262800
    // =MIN(IF(DH6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,DJ6)
    for i in 1..<8760 { hour3[DT + i] = min(iff(hour3[DH + i] > 0, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, hour3[DJ + i]) }
  }
}
