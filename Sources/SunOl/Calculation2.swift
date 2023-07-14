extension TunOl {
  func hourFinal(_ h: inout [Double], d1: [Double], hour h0: [Double], case j: Int) {
    let (J0, L0, M0, BK0, BM0, BP0, BQ0, BT0, BX0, CC0) = (17520, 35040, 43800, 481800, 499320, 525600, 534360, 560640, 595680, 639480)
    let BO: Int = 516840
    let BOday: [[Int]] = h0[BO + 1..<(BO + 8760)].indices.chunked(by: { h0[$0] == h0[$1] }).map { $0.map { $0 - BO } }
    let AY: Int = 376680
    let AYsum: [Double] = h0.sumif(AY, hours: BOday)
    /// Maximum night op perc considering tank sizes
    let DV: Int = 0
    let day1R = 5475
    let day = BOday.indices
      .map { day -> [Double] in let value = d1[(day + day1R)]
        return [Double](repeating: value, count: BOday[day].count)
      }
      .joined()
    // =IF(BT6=0,0,VLOOKUP($BO6,DailyCalc_1!$A$3:$R$367,COLUMN(DailyCalc_1!R$3)))
    h.replaceSubrange(1..<8760, with: day)
    for i in 1..<8760 where h0[BT0 + i].isZero { h[i] = Double.zero }

    /// Max net elec demand outside harm op period
    let DW: Int = 8760
    // DW=IF(OR(BX6=0,DV6=0,AND($BM6>0,$BM7>0),AND((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6)/El_boiler_eff)<$BP6-IF(AND(BM6>0,BM7=0,DW5=0),PB_stby_aux_cons,PB_stup_aux_cons+PB_warm_start_heat_req*TES_aux_cons_perc)-IF($BM7=0,0,PB_warm_start_heat_req*TES_aux_cons_perc),(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)<El_boiler_cap_ud*El_boiler_eff+$BQ6)),0,((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons))
    for i in 1..<8760 {
      h[DW + i] = iff(
        or(
          h0[BX0 + i].isZero, h[DV + i].isZero, and(h0[BM0 + i] > Double.zero, h0[BM0 + i + 1] > Double.zero),
          and(
            (overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j] + overall_fix_stby_cons[j]
              + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_stup_cons[j])
              + min(
                El_boiler_cap_ud,
                max(
                  Double.zero,
                  (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]
                    + overall_heat_fix_stby_cons[j] + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - h0[BQ0 + i]) / El_boiler_eff) < h0[BP0 + i]
              - iff(and(h0[BM0 + i] > 0, h0[BM0 + i + 1].isZero, h[DW + i - 1].isZero), PB_stby_aux_cons, PB_stup_aux_cons + PB_warm_start_heat_req * TES_aux_cons_perc)
              - iff(h0[BM0 + i + 1].isZero, Double.zero, PB_warm_start_heat_req * TES_aux_cons_perc),
            (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
              + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) < El_boiler_cap_ud * El_boiler_eff + h0[BQ0 + i])), Double.zero,
        ((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
          + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_stup_cons[j]))
    }
    let DY: Int = 26280
    /// Optimized max net elec demand outside harm op period
    let DX: Int = 17520
    // DX=IF(DW6>0,IF(SUM(DX3:DX5,DW7:DW9)=0,0,DW6),IF(OR(SUM(DX4:DX5)=0,SUM(DW7:DW8)=0),0,MAX(DW4:DW8)))
    for i in 1..<8760 {
      let sum = (h[max(DW + i - 3, DW)..<(DW + i)].reduce(0, +) + h[(DW + i + 1)..<min(DW + i + 4, DX)].reduce(0, +)).isZero
      let dx = h[max(DX + i - 2, DX)..<(DX + i)].reduce(0, +).isZero
      let dw = h[max(DW + i + 1, DW)..<min(DW + i + 3, DY)].reduce(0, +).isZero
      let max = h[max(DW + i - 3, DW)..<min(DW + i + 3, DY)].max()!
      h[DX + i] = iff(h[DW + i] > Double.zero, iff(sum, 0, h[DW + i]), iff(or(dx, dw), 0, max))
    }
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel

    // DY=IF(DV6=0,0,IF(OR($BM6>0,PB_nom_gross_cap_ud<=0),0,$BK6+MAX(0,(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+DX6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+DX6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/PB_gross_min_eff+((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*PB_Ratio_Heat_input_vs_output+IF(AND(DX6=0,DX7>0),IF(COUNTIF(DX$1:DX6,"0")<PB_warm_start_duration,PB_hot_start_heat_req,PB_warm_start_heat_req),0)-$BQ6)*TES_aux_cons_perc))
    for i in 1..<8760 {
      h[DY + i] = iff(
        h[DV + i].isZero, 0,
        iff(
          or(h0[BM0 + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero), 0,
          roundUp(h0[BK0 + i] + max(
            0,
            (min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(Double.zero, h0[BK0 + i] + h[DX + i] - h0[BP0 + i]))) + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
              * POLY(min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(Double.zero, h0[BK0 + i] + h[DX + i] - h0[BP0 + i]))) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) / PB_gross_min_eff
              + ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]
                + overall_heat_fix_stby_cons[j]) * PB_Ratio_Heat_input_vs_output
              + iff(
                and(h[DX + i].isZero, h[DX + i + 1] > Double.zero),
                iff(
                  (h[max(DX + i - 5, DX)...(DX + i)]
                    .reduce(0) {
                      if  $1 < 0.000001 { return $0 + 1 }
                      return $0
                    }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), Double.zero) - h0[BQ0 + i]) * TES_aux_cons_perc,1)))
    }

    /// Corresponding PB net elec output
    let DZ: Int = 35040
    // =IF(AND(DX6=0,DX6+DY6-$BP6<=0),0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-$BP6)))
    for i in 1..<8760 { h[DZ + i] = iff(and(h[DX + i].isZero, (h[DX + i] + h[DY + i] - h0[BP0 + i]) <= Double.zero), Double.zero, max(PB_net_min_cap, min(PB_nom_net_cap, h[DX + i] + h[DY + i] - h0[BP0 + i]))) }

    /// Corresponding PB gross elec output
    let EA: Int = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 { h[EA + i] = iff(h[DZ + i].isZero, Double.zero, h[DZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(h[DZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) }

    /// ST startup heat cons
    let EB: Int = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      h[EB + i] = iff(
        and(h[EA + i].isZero, h[EA + i + 1] > Double.zero),
        iff(
          (h[max(EA + i - 5, EA)...(EA + i)]
            .reduce(0) {
              if  $1 < 0.000001 { return $0 + 1 }
              return $0
            }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), Double.zero)
    }
    let EBsum: [Double] = h.sumif(EB, hours: BOday)
    /// Corresponding gross heat cons for ST
    let EC: Int = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { h[EC + i] = iff(h[EA + i].isZero, Double.zero, h[EA + i] / PB_nom_gross_eff / POLY(h[EA + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let ECsum: [Double] = h.sumif(EC, hours: BOday)
    /// Corresponding gross heat cons for extraction
    let ED: Int = 70080
    // ED=IF(OR(DV6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN(IF(A_overall_var_max_cons=0,1,(MIN(DZ6-DY6+$BP6,DX6)-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons)-A_overall_var_min_cons)/(A_overall_var_max_cons-A_overall_var_min_cons)*(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)),(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc))+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,DZ6+$BP6-DX6-DY6)*El_boiler_eff)))
    for i in 1..<8760 {
      h[ED + i] = iff(
        or(h[DV + i] == Double.zero, h0[BM0 + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero), 0,
        PB_Ratio_Heat_input_vs_output
          * max(
            0,
            min(
              iff(
                overall_var_max_cons[j] == Double.zero, 1,
                (min(h[DZ + i] - h[DY + i] + h0[BP0 + i], h[DX + i]) - overall_fix_stby_cons[j] - iff(h0[BM0 + i + 1] == Double.zero, 0, overall_stup_cons[j]) - overall_var_min_cons[j]) / (overall_var_max_cons[j] - overall_var_min_cons[j])
                  * (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])),
              (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j])) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
              + iff(h0[BM0 + i + 1] == Double.zero, 0, overall_heat_stup_cons[j]) - h0[BQ0 + i] - min(El_boiler_cap_ud, max(0, h[DZ + i] + h0[BP0 + i] - h[DX + i] - h[DY + i]) * El_boiler_eff)))
    }

    let EDsum: [Double] = h.sumif(ED, hours: BOday)
    let ECEDsum: [Double] = zip(ECsum, EDsum).map { $0 + $1 }
    /// TES energy available if above min op case
    let EE: Int = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 1..<8760 { if h0[CC0 + i].isZero { h[EE + i] = Double.zero } else { h[EE + i] = min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i - 1] + ECEDsum[i - 1]) } }


    let EF: Int = 87600
    let EG: Int = 96360
    let EH: Int = 105120
    // Effective PB net elec output
    // EH=IF(EE6=0,0,BX6+(DZ6-BX6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(EE6-CC6))
    for i in 1..<8760 {
      h[EH + i] = iff(
        h[EE + i] == Double.zero, 0,
        h0[BX0 + i] + (h[DZ + i] - h0[BX0 + i])
          / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - h0[CC0 + i]) * (h[EE + i] - h0[CC0 + i]))
    }

    // Effective PB gross elec output
    // EG=IF(EH6=0,0,EH6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EH6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 { h[EG + i] = iff(h[EH + i] == Double.zero, 0, h[EH + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(h[EH + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) }
    // Effective gross heat cons for ST
    // EF=IF(EG6=0,0,EG6/PB_nom_gross_eff/POLY(EG6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { h[EF + i] = iff(h[EG + i].isZero, 0, h[EG + i] / PB_nom_gross_eff / POLY(h[EG + i] / PB_nom_gross_cap_ud, el_Coeff)) }

    let CB0: Int = 630720
    /// Effective gross heat cons for extraction
    let EI: Int = 113880

    // Effective gross heat cons for extraction
    // EI=IF(EE6=0,0,CB6+(ED6-CB6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(EE6-CC6))
    for i in 1..<8760 {
      h[EI + i] = iff(
        h[EE + i] == Double.zero, 0,
        h0[CB0 + i] + (h[ED + i] - h0[CB0 + i])
          / (EBsum[i - 1] + ECsum[i - 1]
            + EDsum[i - 1] - h0[CC0 + i]) * (h[EE + i] - h0[CC0 + i]))
    }

    // let CTsum: [Double] = hour.sumif(CT, hours: BOday)
    let DXsum: [Double] = h.sumif(DX, hours: BOday)

    /// Surplus TES energy due to op case
    let EK: Int = 131400
    // =IF(EE6=0,0,ROUND(MAX(0,SUMIF($BO$5:$BO$8764,"="&$BO6,$AY$5:$AY$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EE6),5))
    for i in 1..<8760 { if h[EE + i].isZero { h[EK + i] = Double.zero } else { h[EK + i] = max(Double.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - h[EE + i]) } }

    /// Peripherial PV hour PV to heater
    let EL: Int = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { h[EL + i] = iff(or(and(h[EK + i] > Double.zero, h0[AY + i] > Double.zero, h0[AY + i - 1].isZero), and(h[EK + i] > Double.zero, h0[AY + i + 1].isZero, h0[AY + i] > Double.zero)), h0[AY + i], Double.zero) }
    let ELsum: [Double] = h.sumif(EL, hours: BOday)
    /// Surplus energy due to op limit after removal of peripherial hours
    let EM: Int = 148920
    // =ROUND(MAX(0,EK6-SUMIF($BO$5:$BO$8764,"="&$BO6,EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)),5)
    for i in 1..<8760 { h[EM + i] = max(Double.zero, h[EK + i] - ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let EN: Int = 157680
    // IF(EK6=0;0;ROUND($AY6-(EK6-EM6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6;5))
    for i in 1..<8760 {
      h[EN + i] = iff(h[EK + i].isZero, Double.zero, h0[AY + i] - (h[EK + i] - h[EM + i]) / (ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * h[EL + i])
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let EO: Int = 166440
    let AW0: Int = 359160
    let EN_BOcountNonZero = h.countif(EN, criteria: { $0 > 0.000001 }, hours: BOday)
    let ENsum: [Double] = h.sumif(EN, hours: BOday)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 1..<8760 {
      let a = (h0[AW0 + i] - h[EN + i]) / (h[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i - 1])
      let b = (h0[J0 + i] - h[EN + i] * Heater_eff / Ratio_CSP_vs_Heater) / (h[EM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i - 1])
      let s = ENsum[i - 1]
      h[EO + i] = iff(or(h[EN + i].isZero, h[EM + i].isZero), Double.zero, max(a, b) / s * h[EN + i])
    }
    let EOsum: [Double] = h.sumif(EO, hours: BOday)
    /// corrected max possible elec to TES
    let EP: Int = 175200
    // EP=IF(EE6=0,0,IF(EK6>0,ROUND(MAX(0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($BO$5:$BO$8764,"="&$BO6,EO$5:EO$8764)*EO6)),5),$AY6))
    for i in 1..<8760 {
      if h[EE + i].isZero {
        h[EP + i] = Double.zero
      } else {
        h[EP + i] = iff(h[EK + i] > Double.zero, max(Double.zero, h[EN + i] - iff(h[EM + i].isZero, Double.zero, h[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i - 1] * h[EO + i])), h0[AY + i])
      }
    }

    /// Max possible CSP heat to TES
    let EQ: Int = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { h[EQ + i] = min(h0[J0 + i], h[EP + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Available elec from PV after TES chrg
    let ER: Int = 192720
    /// Available heat from CSP after TES
    let ES: Int = 201480
    for i in 1..<8760 {
      // =MAX(0,$L6-EP6)
      h[ER + i] = max(Double.zero, h0[L0 + i] - h[EP + i])
      // =MAX(0,$J6-EQ6)
      h[ES + i] = max(Double.zero, h0[J0 + i] - h[EQ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let ET: Int = 210240
    // =IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(OR(EE6=0,AND(EH6=0,EB6=0)),PB_stby_aux_cons,0)+IF(AND(EE6>0,EB6>0),PB_stup_aux_cons+EB6*TES_aux_cons_perc,0)+IF(EH6>0,(EB6+EF6+EI6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      h[ET + i] =
        iff(h0[J0 + i] > Double.zero, h0[J0 + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + h0[M0 + i] + (h[EP + i] * Heater_eff + h[EQ + i]) * TES_aux_cons_perc
        + iff(or(h[EE + i].isZero, and(h[EH + i].isZero, h[EB + i].isZero)), PB_stby_aux_cons, Double.zero) + iff(and(h[EE + i] > Double.zero, h[EB + i] > Double.zero), PB_stup_aux_cons + h[EB + i] * TES_aux_cons_perc, Double.zero)
        + iff(h[EH + i] > Double.zero, (h[EB + i] + h[EF + i] + h[EI + i]) * TES_aux_cons_perc, Double.zero)
    }

    /// Min harmonious net elec cons not considering grid import
    let EW: Int = 236520
    // Min harm net elec cons
    // EW=IF(OR(EH6>0,ROUNDUP(MIN(MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)),MAX(0,ES6+MIN(El_boiler_cap_ud,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5)),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      h[EW + i] = iff(
        or(
          h[EH + i] > Double.zero,
          roundUp(
            min(
              max(
                0,
                h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i]
                  - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[ES + i]) / El_boiler_eff)),
              max(
                0,
                h[ES + i] + min(El_boiler_cap_ud, max(0, h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                  - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5)), 0, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }
    /// Optimized min harmonious net elec cons
    let EX: Int = 245280
    // IF(OR(AND(EW6>0,EW5=0,EW7=0),AND(EW6>0,OR(AND(EW4=0,EW5>0,EW7=0),AND(EW5=0,EW7>0,EW8=0)))),0,EW6)
    for i in 1..<8760 {
      h[EX + i] = iff(
        or(
          and(h[EW + i] > Double.zero, h[EW + i - 1].isZero, h[EW + i + 1].isZero),
          and(h[EW + i] > Double.zero, or(and(h[EW + i - 2].isZero, h[EW + i - 1] > Double.zero, h[EW + i + 1].isZero), and(h[EW + i - 1].isZero, h[EW + i + 1] > Double.zero, h[EW + i + 2].isZero)))), Double.zero, h[EW + i])
    }

    /// Min harmonious net heat cons
    let EY: Int = 254040
    // Min harm net heat cons
    // EY=IF(OR(EX6=0,EH6>0,ROUNDUP(MIN(MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)),MAX(0,ES6+MIN(El_boiler_cap_ud,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)+Overall_harmonious_var_min_cons+Overall_fix_cons),5)<ROUNDDOWN(Overall_harmonious_var_min_cons+Overall_fix_cons,5)),0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      h[EY + i] = iff(
        or(
          h[EX + i] == Double.zero, h[EH + i] > Double.zero,
          roundUp(
            min(
              max(
                0,
                h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i]
                  - min(El_boiler_cap_ud, max(0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[ES + i]) / El_boiler_eff)),
              max(
                0,
                h[ES + i] + min(El_boiler_cap_ud, max(0, h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
                  - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                + Overall_harmonious_var_min_cons + Overall_fix_cons), 5) < roundDown(Overall_harmonious_var_min_cons + Overall_fix_cons, 5)), 0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons)
    }

    /// Grid import for TES chrg and min harm and stby
    let EU: Int = 219000
    // =IF(EP6=0,0,MAX(0,ROUND(EP6+ET6+EX6+MIN(El_boiler_cap_ud,MAX(0,EY6-ES6)/El_boiler_eff)-$L6,5)))
    for i in 1..<8760 {
      if h[EP + i].isZero { h[EU + i] = Double.zero } else { h[EU + i] = max(Double.zero, h[EP + i] + h[ET + i] + h[EX + i] + min(El_boiler_cap_ud, max(Double.zero, h[EY + i] - h[ES + i]) / El_boiler_eff) - h0[L0 + i]) }
    }
    /// Harmonious op day
    let EZ: Int = 262800
    // =IF(OR(AND(EX19<=0,EX20>0,SUM(EX10:EX19)=0),AND($F19<=0,$F20>0,SUM(EX10:EX30)=0)),IF(EZ19<364,EZ19+1,0),EZ19)
    for i in 12..<8748 {
      h[EZ + i] = h[EZ + i - 1]
      if h[EX + i - 1].isZero, h[EX + i] > Double.zero, h[EX + i + 1] > Double.zero, h[(EZ + i - 12)..<(EZ + i)].allSatisfy({ $0 == h[EZ + i] }) {
        h[EZ + i] += 1
      } else if h0[i - 1].isZero, h0[i] > Double.zero, h[EX + i..<EX + i + 12].allSatisfy(\.isZero), h[EZ + i - 12..<EZ + i].allSatisfy({ $0 == h[EZ + i] }) {
        h[EZ + i] += 1
      }
    }
    for i in 8748..<8760 { h[EZ + i] = h[EZ + i - 1] }
    /// El cons due to op outside of harm op period

    let CK0: Int = 709560
    let CL0: Int = 718320
    let CM0: Int = 727080
    let CN0: Int = 735840
    let CQ0: Int = 762120
    let CR0: Int = 770880
    let CT0: Int = 788400
    let FA: Int = 271560
    let BV0: Int = 578160
    // El cons due to stby & net op outside of harm op period
    // FA=IF(OR(EX6>0,EE6=0,ROUNDUP(MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-EU6)+EH6+ER6-ET6,5)<ROUNDDOWN(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons),5)),IF(EX6>0,0,IF(EX7=0,Overall_stby_cons,Overall_stup_cons)),MAX(CT6,A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+A_overall_var_min_cons+(A_overall_var_max_cons-A_overall_var_min_cons)*MIN(1,IFERROR((EH6-BX6+ER6-CK6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-CN6)-ET6+CM6-EX6+CQ6+(ES6-CL6+(EI6-CB6)/PB_Ratio_Heat_input_vs_output-(EY6-CR6))/El_boiler_eff)/(A_overall_var_max_cons-A_overall_var_min_cons+(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/El_boiler_eff),1),IFERROR((EH6-BX6+ER6-CK6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-CN6)-ET6+CM6-EX6+CQ6)/(A_overall_var_max_cons-A_overall_var_min_cons),1),IFERROR((ES6-CL6+(EI6-CB6)/PB_Ratio_Heat_input_vs_output-EY6+CR6)/(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons),1))))
    for i in 1..<8760 {
      h[FA + i] = iff(
        or(
          h[EX + i] > Double.zero, h[EE + i] == Double.zero,
          roundUp(
            max(0, iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[EU + i]) + h[EH + i] + h[ER + i]
              - h[ET + i], 5) < roundDown(overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j]), 5)),
        iff(h[EX + i] > Double.zero, 0, iff(h[EX + i + 1] == Double.zero, Overall_stby_cons, Overall_stup_cons)),
        max(
          h0[CT0 + i],
          overall_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j]) + overall_var_min_cons[j] + (overall_var_max_cons[j] - overall_var_min_cons[j])
            * min(
              1,
              ifFinite(
                (h[EH + i] - h0[BX0 + i] + h[ER + i] - h0[CK0 + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i])
                  - max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h0[CN0 + i]) - h[ET + i] + h0[CM0 + i] - h[EX + i] + h0[CQ0 + i]
                  + (h[ES + i] - h0[CL0 + i] + (h[EI + i] - h0[CB0 + i]) / PB_Ratio_Heat_input_vs_output - (h[EY + i] - h0[CR0 + i])) / El_boiler_eff)
                  / (overall_var_max_cons[j] - overall_var_min_cons[j] + (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / El_boiler_eff), 1),
              ifFinite(
                (h[EH + i] - h0[BX0 + i] + h[ER + i] - h0[CK0 + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i])
                  - max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h0[CN0 + i]) - h[ET + i] + h0[CM0 + i] - h[EX + i] + h0[CQ0 + i])
                  / (overall_var_max_cons[j] - overall_var_min_cons[j]), 1),
              ifFinite(
                (h[ES + i] - h0[CL0 + i] + (h[EI + i] - h0[CB0 + i]) / PB_Ratio_Heat_input_vs_output - h[EY + i] + h0[CR0 + i])
                  / (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]), 1))))
    }

    /// TES energy to fulfil op case if above
    let EJ: Int = 122640
    let BVsum = h0.sumif(BV0, hours: BOday)
    let CTsum = h0.sumif(CT0, hours: BOday)
    let FAsum = h.sumif(FA, hours: BOday)
    // Updated maximum outside harm op period operation %
    // EJ=IF(OR(EE6=0,DV6=0),0,MIN(DV6,MAX(A_equiv_harmonious_min_perc,IFERROR((SUMIF($BO$5:$BO$8764,"="&$BO6,FA$5:FA$8764)-SUMIF($BO$5:$BO$8764,"="&$BO6,CT$5:CT$8764))/((SUMIF($BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764)-SUMIF($BO$5:$BO$8764,"="&$BO6,BV$5:BV$8764))/(DV6-A_equiv_harmonious_min_perc)*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc))+A_equiv_harmonious_min_perc,DV6))))
    for i in 1..<8760 {
      h[EJ + i] = iff(
        or(h[EE + i] == Double.zero, h[DV + i] == Double.zero), 0,
        min(
          h[DV + i],
          max(
            equiv_harmonious_min_perc[j],
            ifFinite(
              (FAsum[i - 1] - CTsum[i - 1])
                / ((DXsum[i - 1] - BVsum[i - 1]) / (h[DV + i] - equiv_harmonious_min_perc[j])
                  * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]))
                + equiv_harmonious_min_perc[j], h[DV + i]))))
    }


    let CU0 = 797160
    /// heat cons due to op outside of harm op period
    let FB: Int = 280320
    // heat cons due to stby & net op outside of harm op period
    // FB=IF(OR(EX6>0,EE6=0,ROUNDUP(EI6/PB_Ratio_Heat_input_vs_output+ES6+MIN(El_boiler_cap_ud,MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-EU6)+EH6+ER6-ET6-FA6)*El_boiler_eff,5)<ROUNDDOWN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(EX7=0,0,A_overall_heat_stup_cons),5)),IF(EX6>0,0,IF(EX7=0,Overall_heat_stby_cons,Overall_heat_stup_cons)),MAX(CU6,A_overall_heat_fix_stby_cons+IF(EX7=0,0,A_overall_heat_stup_cons)+A_overall_var_heat_min_cons+(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*MIN(1,IFERROR((EH6-BX6+ER6-CK6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-CN6)-ET6+CM6-EX6+CQ6+(ES6-CL6+(EI6-CB6)/PB_Ratio_Heat_input_vs_output-(EY6-CR6))/El_boiler_eff)/(A_overall_var_max_cons-A_overall_var_min_cons+(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/El_boiler_eff),1),IFERROR((EH6-BX6+ER6-CK6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-CN6)-ET6+CM6-EX6+CQ6)/(A_overall_var_max_cons-A_overall_var_min_cons),1),IFERROR((ES6-CL6+(EI6-CB6)/PB_Ratio_Heat_input_vs_output-EY6+CR6)/(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons),1))))
    for i in 1..<8760 {
      h[FB + i] = iff(
        or(
          h[EX + i] > Double.zero, h[EE + i] == Double.zero,
          roundUp(
            h[EI + i] / PB_Ratio_Heat_input_vs_output + h[ES + i] + min(
              El_boiler_cap_ud,
              max(0, iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[EU + i]) + h[EH + i]
                + h[ER + i] - h[ET + i] - h[FA + i]) * El_boiler_eff, 5)
            < roundDown(overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j]), 5)),
        iff(h[EX + i] > Double.zero, 0, iff(h[EX + i + 1] == Double.zero, Overall_heat_stby_cons, Overall_heat_stup_cons)),
        max(
          h0[CU0 + i],
          overall_heat_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j]) + overall_var_heat_min_cons[j]
            + (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
            * min(
              1,
              ifFinite(
                (h[EH + i] - h0[BX0 + i] + h[ER + i] - h0[CK0 + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i])
                  - max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h0[CN0 + i]) - h[ET + i] + h0[CM0 + i] - h[EX + i] + h0[CQ0 + i]
                  + (h[ES + i] - h0[CL0 + i] + (h[EI + i] - h0[CB0 + i]) / PB_Ratio_Heat_input_vs_output - (h[EY + i] - h0[CR0 + i])) / El_boiler_eff)
                  / (overall_var_max_cons[j] - overall_var_min_cons[j] + (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / El_boiler_eff), 1),
              ifFinite(
                (h[EH + i] - h0[BX0 + i] + h[ER + i] - h0[CK0 + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i])
                  - max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h0[CN0 + i]) - h[ET + i] + h0[CM0 + i] - h[EX + i] + h0[CQ0 + i])
                  / (overall_var_max_cons[j] - overall_var_min_cons[j]), 1),
              ifFinite(
                (h[ES + i] - h0[CL0 + i] + (h[EI + i] - h0[CB0 + i]) / PB_Ratio_Heat_input_vs_output - h[EY + i] + h0[CR0 + i])
                  / (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]), 1))))
    }

    /// Remaining el after min harmonious
    let FC: Int = 289080
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+EY6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 {
      h[FC + i] = max(
        Double.zero,
        h0[L0 + i] + h[EH + i] - h[EP + i] - h[ET + i] - h[EX + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, h[EQ + i] + h[EY + i] + h[FB + i] - h0[J0 + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let FD: Int = 297840
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 1..<8760 { h[FD + i] = max(Double.zero, h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[EY + i] - h[FB + i]) }

    /// Grid import necessary for min harm
    let FE: Int = 306600
    // =MAX(0,-ROUND(EH6+ER6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[FE + i] = max(Double.zero, -(h[EH + i] + h[ER + i] - h[ET + i] - h[EX + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, (h[EY + i] + h[FB + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output - h[ES + i]) / El_boiler_eff))))
    }

    /// Grid import for min harm and stby
    let TB: Int = 508080
    // =MIN(IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,FE6)
    for i in 1..<8760 { h[TB + i] = min(iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, h[FE + i]) }

    /// Remaining grid import capacity after min harm
    let FF: Int = 315360
    // =MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-TB6)
    for i in 1..<8760 { h[FF + i] = max(Double.zero, iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[TB + i]) }

    /// El boiler op after min harmonious heat cons
    let FG: Int = 324120
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 { 
      h[FG + i] = min(El_boiler_cap_ud, max(Double.zero, (h[EY + i] + h[FB + i] - h[ES + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)) 
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let FH: Int = 332880
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 1..<8760 { h[FH + i] = max(Double.zero, El_boiler_cap_ud - h[FG + i]) }

    let UH: Int = 516_840
    // UH=IF(EJ6=0,0,MIN(IF((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,A_overall_fix_stby_cons+A_overall_heat_fix_stby_cons/El_boiler_eff))/((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff)),IF((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,A_overall_heat_fix_stby_cons))/((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)),IF((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,A_overall_fix_stby_cons))/((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op))))
    for i in 1..<8760 {
      h[UH + i] = iff(
        h[EJ + i] == Double.zero, 0,
        min(
          iff(
            (h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff
              <= Double.zero, 9999,
            max(0, h[FC + i] + h[FF + i] + h[FD + i] / El_boiler_eff - iff(h[EX + i] == Double.zero, overall_fix_stby_cons[j] + overall_heat_fix_stby_cons[j] / El_boiler_eff))
              / ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff)
          ),
          iff(
            (h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j] <= Double.zero, 9999,
            max(0, h[FD + i] + h[FH + i] * El_boiler_eff - iff(h[EX + i] == Double.zero, overall_heat_fix_stby_cons[j]))
              / ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j])),
          iff(
            (h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j] <= Double.zero, 9999,
            max(0, h[FC + i] + h[FF + i] - iff(h[EX + i] == Double.zero, overall_fix_stby_cons[j]))
              / ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]))))
    }
    
    /// Remaining MethSynt cap after min harmonious cons
    let FI: Int = 341640
    /// Remaining CCU cap after min harmonious cons
    let FJ: Int = 350400
    /// Remaining EY cap after min harmonious cons
    let FK: Int = 359160
    // Remaining MethSynt cap after meth prod & stby
    // FI=MethSynt_RawMeth_nom_prod_ud*IF(OR(UH6 == 9999,AND(EX6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)*UH6/MethSynt_RawMeth_nom_prod_ud<MethSynt_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)*UH6/MethSynt_RawMeth_nom_prod_ud))
    for i in 1..<8760 {
      h[FI + i] =
        MethSynt_RawMeth_nom_prod_ud
        * iff(
          or(
            h[UH + i] == 9999,
            and(
              h[EX + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) * h[UH + i] / MethSynt_RawMeth_nom_prod_ud < MethSynt_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
              + RawMeth_min_cons[j]) * h[UH + i] / MethSynt_RawMeth_nom_prod_ud))
    }

    // Remaining CCU cap after meth prod & stby
    // FJ=CCU_CO2_nom_prod_ud*IF(OR(UH6 == 9999,AND(EX6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_CO2_max_cons-A_CO2_min_cons)+A_CO2_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)*UH6/CCU_CO2_nom_prod_ud<CCU_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_CO2_max_cons-A_CO2_min_cons)+A_CO2_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)*UH6/CCU_CO2_nom_prod_ud))
    for i in 1..<8760 {
      h[FJ + i] =
        CCU_CO2_nom_prod_ud
        * iff(
          or(
            h[UH + i] == 9999,
            and(
              h[EX + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (CO2_max_cons[j] - CO2_min_cons[j]) + CO2_min_cons[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                  + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons)
                * h[UH + i] / CCU_CO2_nom_prod_ud < CCU_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (CO2_max_cons[j] - CO2_min_cons[j]) + CO2_min_cons[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons)
              * h[UH + i] / CCU_CO2_nom_prod_ud))
    }

    // Remaining EY cap after meth prod & stby
    // FK=EY_Hydrogen_nom_prod*IF(OR(UH6 == 9999,AND(EX6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_Hydrogen_max_cons-A_Hydrogen_min_cons)+A_Hydrogen_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)*UH6/EY_Hydrogen_nom_prod<EY_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_Hydrogen_max_cons-A_Hydrogen_min_cons)+A_Hydrogen_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)*UH6/EY_Hydrogen_nom_prod))
    for i in 1..<8760 {
      h[FK + i] =
        EY_Hydrogen_nom_prod
        * iff(
          or(
            h[UH + i] == 9999,
            and(
              h[EX + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (Hydrogen_max_cons[j] - Hydrogen_min_cons[j])
                + Hydrogen_min_cons[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                  + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
                * h[UH + i] / EY_Hydrogen_nom_prod < EY_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (Hydrogen_max_cons[j] - Hydrogen_min_cons[j])
              + Hydrogen_min_cons[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
              * h[UH + i] / EY_Hydrogen_nom_prod))
    }

    /// Max BESS charging after min harmonious cons
    let FL: Int = 367920
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let FM: Int = 376680
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FC6)
      h[FL + i] = min(BESS_chrg_max_cons, h[FC + i])
      // =MIN(IF(EX6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,FC6)
      h[FM + i] = min(iff(h[EX + i] > Double.zero, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, h[FC + i])
    }

    /// Max harmonious net elec cons
    let FN: Int = 385440
    for i in 1..<8760 {
      // =IF(EX6=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,ES6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,ES6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
      h[FN + i] = iff(
        h[EX + i].isZero, Double.zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            Double.one,
            max(
              Double.zero,
              h[ER + i] + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(
                Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[ES + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              Double.zero,
              h[ES + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(
                Double.zero, h[ER + i] + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(Double.zero, h[ES + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }

    /// Optimized max harmonious net elec cons
    let FO: Int = 394200
    // IF(OR(AND(FN6>0;FN5=0;FN7=0);AND(FN6>0;OR(AND(FN4=0;FN5=0;FN8=0);AND(FN4=0;FN7=0;FN8=0))));0;FN6)
    for i in 1..<8760 {
      h[FO + i] = iff(
        or(
          and(h[FN + i] > Double.zero, h[FN + i - 1].isZero, h[FN + i + 1].isZero),
          and(h[FN + i] > Double.zero, or(and(h[FN + i - 2].isZero, h[FN + i - 1] > Double.zero, h[FN + i + 1].isZero), and(h[FN + i - 1].isZero, h[FN + i + 1] > Double.zero, h[FN + i + 2].isZero)))), Double.zero, h[FN + i])
    }

    /// max harmonious net heat cons
    let FP: Int = 402960
    // FP=IF(FO6=0,0,Overall_heat_fix_cons+Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)*MIN(1,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,ES6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,ES6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      h[FP + i] = iff(
        h[FO + i] == Double.zero, 0,
        Overall_heat_fix_cons + Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)
          * min(
            1,
            max(
              0,
              h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(
                0, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[ES + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(
              0,
              h[ES + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(
                0, h[ER + i] + max(0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(0, h[EP + i] - h0[L0 + i])) - h[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(0, h[ES + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }

    /// Remaining el after max harmonious
    let FQ: Int = 411720
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+FP6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 {
      h[FQ + i] = max(
        Double.zero,
        h0[L0 + i] + h[EH + i] - h[EP + i] - h[ET + i] - h[FO + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, h[EQ + i] + h[FP + i] + h[FB + i] - h0[J0 + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let FR: Int = 420480
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 1..<8760 { h[FR + i] = max(Double.zero, h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[FP + i] - h[FB + i]) }

    /// Grid import necessary for max harm
    let FS: Int = 429240
    // =MAX(0,-ROUND(EH6+ER6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[FS + i] = max(Double.zero, -(h[EH + i] + h[ER + i] - h[ET + i] - h[FO + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, (h[FP + i] + h[FB + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output - h[ES + i]) / El_boiler_eff))))
    }

    /// Grid import for max harm and stby
    let TC: Int = 499320
    // =MIN(IF(FO6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,FS6)
    for i in 1..<8760 { h[TC + i] = min(iff(h[FO + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, h[FS + i]) }
    /// Remaining grid import capacity after max harm
    let FT: Int = 438000
    // =MAX(0,IF(FO6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-TC6)
    for i in 1..<8760 { h[FT + i] = max(Double.zero, iff(h[FO + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[TC + i]) }

    /// El boiler op after max harmonious heat cons
    let FU: Int = 446760
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 { h[FU + i] = min(El_boiler_cap_ud, max(Double.zero, (h[FP + i] + h[FB + i] - h[ES + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)) }

    let TJ: Int = FG
    // TJ=MAX(0,-ROUND(ES5+EI5/PB_Ratio_Heat_input_vs_output+FG5*El_boiler_eff-EY5-FB5,5))
    for i in 1..<8760 { h[TJ + i] = max(Double.zero, -(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + h[FG + i] * El_boiler_eff - h[EY + i] - h[FB + i])) }

    /// Remaining el boiler cap after max harmonious heat cons
    let FV: Int = 455520
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 1..<8760 { h[FV + i] = max(Double.zero, El_boiler_cap_ud - h[FU + i]) }

    let UI: Int = 525_600
    // UI=IF(EJ6=0,0,MIN(IF((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,A_overall_fix_stby_cons+A_overall_heat_fix_stby_cons/El_boiler_eff))/((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff)),IF(((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,A_overall_heat_fix_stby_cons))/(((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_heat_cons_per_h_of_max_night_op-A_daytime_heat_cons_per_h_of_min_night_op)+A_daytime_heat_cons_per_h_of_min_night_op)/El_boiler_eff)),IF((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,A_overall_fix_stby_cons))/((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_daytime_cons_per_h_of_max_night_op-A_daytime_cons_per_h_of_min_night_op)+A_daytime_cons_per_h_of_min_night_op))))
    for i in 1..<8760 {
      h[UI + i] = iff(
        h[EJ + i] == Double.zero, 0,
        min(
          iff(
            (h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff
              <= Double.zero, 9999,
            max(0, h[FQ + i] + h[FT + i] + h[FR + i] / El_boiler_eff - iff(h[FO + i] == Double.zero, overall_fix_stby_cons[j] + overall_heat_fix_stby_cons[j] / El_boiler_eff))
              / ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff)
          ),
          iff(
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff <= Double.zero,
            9999,
            max(0, h[FR + i] + h[FV + i] * El_boiler_eff - iff(h[FO + i] == Double.zero, overall_heat_fix_stby_cons[j]))
              / (((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_heat_cons_per_h_of_max_night_op[j] - daytime_heat_cons_per_h_of_min_night_op[j]) + daytime_heat_cons_per_h_of_min_night_op[j]) / El_boiler_eff)),
          iff(
            (h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j] <= Double.zero, 9999,
            max(0, h[FQ + i] + h[FT + i] - iff(h[FO + i] == Double.zero, overall_fix_stby_cons[j]))
              / ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daytime_cons_per_h_of_max_night_op[j] - daytime_cons_per_h_of_min_night_op[j]) + daytime_cons_per_h_of_min_night_op[j]))))
    }

    let TK: Int = FU
    // TK=MAX(0,-ROUND(ES5+EI5/PB_Ratio_Heat_input_vs_output+FU5*El_boiler_eff-FP5-FB5,5))
    for i in 1..<8760 { h[TK + i] = max(Double.zero, -(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + h[FU + i] * El_boiler_eff - h[FP + i] - h[FB + i])) }

    let FW: Int = 464280
    let FX: Int = 473040
    let FY: Int = 481800
    // Remaining MethSynt cap after meth prod & stby
    // FW=MethSynt_RawMeth_nom_prod_ud*IF(OR(UI6 == 9999,AND(FO6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)*UI6/MethSynt_RawMeth_nom_prod_ud<MethSynt_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)*UI6/MethSynt_RawMeth_nom_prod_ud))
    for i in 1..<8760 {
      h[FW + i] =
        MethSynt_RawMeth_nom_prod_ud
        * iff(
          or(
            h[UI + i] == 9999,
            and(
              h[FO + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) * h[UI + i] / MethSynt_RawMeth_nom_prod_ud < MethSynt_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
              + RawMeth_min_cons[j]) * h[UI + i] / MethSynt_RawMeth_nom_prod_ud))
    }

    // Remaining CCU cap after meth prod & stby
    // FX=CCU_CO2_nom_prod_ud*IF(OR(UI6 == 9999,AND(FO6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_CO2_max_cons-A_CO2_min_cons)+A_CO2_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)*UI6/CCU_CO2_nom_prod_ud<CCU_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_CO2_max_cons-A_CO2_min_cons)+A_CO2_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)*UI6/CCU_CO2_nom_prod_ud))
    for i in 1..<8760 {
      h[FX + i] =
        CCU_CO2_nom_prod_ud
        * iff(
          or(
            h[UI + i] == 9999,
            and(
              h[FO + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (CO2_max_cons[j] - CO2_min_cons[j]) + CO2_min_cons[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                  + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons)
                * h[UI + i] / CCU_CO2_nom_prod_ud < CCU_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (CO2_max_cons[j] - CO2_min_cons[j]) + CO2_min_cons[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons)
              * h[UI + i] / CCU_CO2_nom_prod_ud))
    }

    // Remaining EY cap after meth prod & stby
    // FY=EY_Hydrogen_nom_prod*IF(OR(UI6 == 9999,AND(FO6=0,((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_Hydrogen_max_cons-A_Hydrogen_min_cons)+A_Hydrogen_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)*UI6/EY_Hydrogen_nom_prod<EY_cap_min_perc)),0,MIN(1,MAX(0,1-(MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc),((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_Hydrogen_max_cons-A_Hydrogen_min_cons)+A_Hydrogen_min_cons+((EJ6-A_equiv_harmonious_min_perc)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)*UI6/EY_Hydrogen_nom_prod))
    for i in 1..<8760 {
      h[FY + i] =
        EY_Hydrogen_nom_prod
        * iff(
          or(
            h[UI + i] == 9999,
            and(
              h[FO + i] == Double.zero,
              ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (Hydrogen_max_cons[j] - Hydrogen_min_cons[j])
                + Hydrogen_min_cons[j]
                + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                  + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
                * h[UI + i] / EY_Hydrogen_nom_prod < EY_cap_min_perc)), 0,
          min(
            1,
            max(
              0,
              1 - (max(0, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
                * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc),
            ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (Hydrogen_max_cons[j] - Hydrogen_min_cons[j])
              + Hydrogen_min_cons[j]
              + ((h[EJ + i] - equiv_harmonious_min_perc[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j])
                + RawMeth_min_cons[j]) / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
              * h[UI + i] / EY_Hydrogen_nom_prod))
    }

    /// Max BESS charging after max harmonious cons
    let FZ: Int = 490560
    /// Max grid export after TES chrg, min harm, night and aux el cons
    let GA: Int = 499320
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FQ6)
      h[FZ + i] = min(BESS_chrg_max_cons, h[FQ + i])
      // =MIN(IF(FO6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,FQ6)
      h[GA + i] = min(iff(h[FO + i] > Double.zero, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, h[FQ + i])
    }
  }
}
