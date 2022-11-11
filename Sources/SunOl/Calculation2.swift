extension TunOl {
  func hourFinal(_ h: inout [Double], d1: [Double], hour h0: [Double], case j: Int) {
    let (J0, L0, M0, BK0, BM0, BP0, BQ0, BT0, BX0, CC0) = (17520, 35040, 43800, 481800, 499320, 525600, 534360, 560640, 595680, 639480)
    let BO: Int = 516840
    let BOday: [[Int]] = h0[BO + 1..<(BO + 8760)].indices.chunked(by: { h0[$0] == h0[$1] }).map { $0.map { $0 - BO } }
    let AY: Int = 376680
    let AYsum: [Double] = h0.sum(hours: BOday, condition: AY)
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
                    + overall_heat_fix_stby_cons[j] + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - h0[BQ0 + i]) / El_boiler_eff) < h0[BP0 + i] - iff(and(h0[BM0 + i] > 0 , h0[BM0 + i + 1].isZero, h[DW + i - 1].isZero), PB_stby_aux_cons, PB_stup_aux_cons + PB_warm_start_heat_req * TES_aux_cons_perc)
              - iff(h0[BM0 + i + 1].isZero, Double.zero, PB_warm_start_heat_req * TES_aux_cons_perc),
            (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
              + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) < El_boiler_cap_ud * El_boiler_eff + h0[BQ0 + i])), Double.zero,
        ((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
          + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_stup_cons[j]))
    }

    /// Optimized max net elec demand outside harm op period
    let DX: Int = 17520
    // =IF(OR(AND(DW6>0,DW5=0,DW7=0,DW4=0,DW8=0),AND(DW6=0,DW5>0,DW7>0),AND(DW6>0,OR(AND(DW4=0,DW5>0,DW7=0),AND(DW5=0,DW7>0,DW8=0)))),DW5,DW6)
    for i in 1..<8760 {
      let a = h[max(DW + i - 2, DW)]
      let b = h[max(DW + i - 1, DW)]
      let c = h[min(DW + i + 1, DX - 1)]
      let d = h[min(DW + i + 2, DX - 1)]
      h[DX + i] = iff(or(and(h[DW + i] > Double.zero, b.isZero, c.isZero, a.isZero, d.isZero), and(h[DW + i].isZero, b > 0, c > 0), and(h[DW + i] > Double.zero, or(and(a.isZero, b > 0, c.isZero), and(b.isZero, c > 0, d.isZero)))), b, h[DW + i])
    }
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let DY: Int = 26280
    // DY=IF(DV6=0,0,IF(OR($BM6>0,PB_nom_gross_cap_ud<=0),0,$BK6+MAX(0,(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+DX6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,$BK6+DX6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/PB_gross_min_eff+((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*PB_Ratio_Heat_input_vs_output+IF(AND(DX6=0,DX7>0),IF(COUNTIF(DX$1:DX6,"0")<PB_warm_start_duration,PB_hot_start_heat_req,PB_warm_start_heat_req),0)-$BQ6)*TES_aux_cons_perc))
    for i in 1..<8760 {
      h[DY + i] = iff(
        h[DV + i] == Double.zero, 0,
        iff(
          or(h0[BM0 + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero), 0,
          h0[BK0 + i] + max(
            0,
            (min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(0, h0[BK0 + i] + h[DX + i] - h0[BP0 + i]))) + PB_nom_net_cap
              * PB_nom_var_aux_cons_perc_net
              * POLY(
                min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(0, h0[BK0 + i] + h[DX + i] - h0[BP0 + i]))) / PB_nom_net_cap,
                PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) / PB_gross_min_eff
              + ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * PB_Ratio_Heat_input_vs_output
              + iff(
                and(h[DX + i] == Double.zero, h[DX + i + 1] > Double.zero),
                iff((h[max(DX + i - 5, DX)...(DX + i)]
                    .reduce(0) {
                      if $1.isZero { return $0 + 1 }
                      return $0
                    }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), 0) - h0[BQ0 + i]) * TES_aux_cons_perc))
    }

    /// Corresponding PB net elec output
    let DZ: Int = 35040
    // =IF(AND(DX6=0,DX6+DY6-$BP6<=0),0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-$BP6)))
    for i in 1..<8760 { h[DZ + i] = iff(and(h[DX + i].isZero, (h[DX + i] + h[DY + i] - h0[BP0 + i]) <= 0), Double.zero, max(PB_net_min_cap, min(PB_nom_net_cap, h[DX + i] + h[DY + i] - h0[BP0 + i]))) }

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
              if $1.isZero { return $0 + 1 }
              return $0
            }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), Double.zero)
    }
    let EBsum: [Double] = h.sum(hours: BOday, condition: EB)
    /// Corresponding gross heat cons for ST
    let EC: Int = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { h[EC + i] = iff(h[EA + i].isZero, Double.zero, h[EA + i] / PB_nom_gross_eff / POLY(h[EA + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let ECsum: [Double] = h.sum(hours: BOday, condition: EC)
    /// Corresponding gross heat cons for extraction
    let ED: Int = 70080
    // ED=IF(OR(DV6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN(IF(A_overall_var_max_cons=0,1,(MIN(DZ6-DY6+$BP6,DX6)-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons)*A_overall_var_heat_max_cons,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,DZ6+$BP6-DX6-DY6)*El_boiler_eff)))
    for i in 1..<8760 {
      if or(h[DV + i].isZero, h0[BM0 + i] > Double.zero, PB_nom_gross_cap_ud < Double.zero) {
        h[ED + i] = Double.zero
      } else {
        h[ED + i] =
          PB_Ratio_Heat_input_vs_output
          * max(
            Double.zero,
            min(
              iff(overall_var_max_cons[j].isZero, Double.one, (min(h[DZ + i] - h[DY + i] + h0[BP0 + i], h[DX + i]) - overall_fix_stby_cons[j] - iff(h0[BM0 + i + 1].isZero, Double.zero, overall_stup_cons[j])) / overall_var_max_cons[j])
                * overall_var_heat_max_cons[j],
              (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (h[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
              + overall_heat_fix_stby_cons[j] + iff(h0[BM0 + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - h0[BQ0 + i] - min(El_boiler_cap_ud, max(Double.zero, h[DZ + i] + h0[BP0 + i] - h[DX + i] - h[DY + i]) * El_boiler_eff))
      }
    }

    let EDsum: [Double] = h.sum(hours: BOday, condition: ED)
    let ECEDsum: [Double] = zip(ECsum, EDsum).map { $0 + $1 }
    /// TES energy available if above min op case
    let EE: Int = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 1..<8760 {
      if h0[CC0 + i].isZero {
        h[EE + i] = Double.zero
      } else {
        h[EE + i] = min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i - 1] + ECEDsum[i - 1])
      }
    }

    let CA: Int = 621960
    /// Effective gross heat cons for ST
    let EF: Int = 87600
    // EF=IF(EE6=0,0,MAX(CA6,IFERROR((EE6-CC6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(EC6-CA6),0)+CA6))
    for i in 1..<8760 {
      h[EF + i] = iff(
        h[EE + i] == Double.zero, 0,
        max(
          h0[CA + i],
          ifFinite(
            (h[EE + i] - h0[CC0 + i])
              / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - h0[CC0 + i])
              * (h[EC + i] - h0[CA + i]), 0) + h0[CA + i]))
    }

    let BY0 = 604440
    /// Effective PB gross elec output
    let EG: Int = 96360
    // EG=IF(EF6=0,0,MAX(BY6,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff)))
    for i in 1..<8760 { h[EG + i] = iff(h[EF + i] == Double.zero, 0, max(h0[BY0 + i], h[EF + i] * PB_nom_gross_eff * POLY(h[EF + i] / PB_nom_heat_cons, th_Coeff))) }
    /// Effective PB net elec output
    let EH: Int = 105120
    // EH=IF(EG6=0,0,MAX(BX6,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el))
    for i in 1..<8760 {
      h[EH + i] = iff(
        h[EG + i] == Double.zero, 0,
        max(h0[BX0 + i], h[EG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(h[EG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el))
    }

    let CB0: Int = 630720
    /// Effective gross heat cons for extraction
    let EI: Int = 113880
    // =IF(EE6=0,0,MIN(ED6,MAX(CB6,IFERROR((EE6-CC6)/(SUMIF(BO5:BO8764,"="&BO6,EB5:EB8764)+SUMIF(BO5:BO8764,"="&BO6,EC5:EC8764)+SUMIF(BO5:BO8764,"="&BO6,ED5:ED8764)-CC6)*(ED6-CB6),0)+CB6)))
    for i in 1..<8760 {
      if h[EE + i].isZero {
        h[EI + i] = Double.zero
      } else {
        h[EI + i] = min(
          h[ED + i],
          max(
            h0[CB0 + i], ifFinite((h[EE + i] - h0[CC0 + i]) / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - h0[CC0 + i]) * (h[ED + i] - h0[CB0 + i]), 0) + h0[CB0 + i]))
      }
    }

    // let CTsum: [Double] = hour.sum(hours: BOday, condition: CT)
    let DXsum: [Double] = h.sum(hours: BOday, condition: DX)

    /// Surplus TES energy due to op case
    let EK: Int = 131400
    // =IF(EE6=0,0,ROUND(MAX(0,SUMIF($BO$5:$BO$8764,"="&$BO6,$AY$5:$AY$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EE6),5))
    for i in 1..<8760 { if h[EE + i].isZero { h[EK + i] = Double.zero } else { h[EK + i] = round(max(Double.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - h[EE + i]),5) } }

    /// Peripherial PV hour PV to heater
    let EL: Int = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { h[EL + i] = iff(or(and(h[EK + i] > Double.zero, h0[AY + i] > Double.zero, h0[AY + i - 1].isZero), and(h[EK + i] > Double.zero, h0[AY + i + 1].isZero, h0[AY + i] > Double.zero)), h0[AY + i], Double.zero) }
    let ELsum: [Double] = h.sum(hours: BOday, condition: EL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let EM: Int = 148920
    // =ROUND(MAX(0,EK6-SUMIF($BO$5:$BO$8764,"="&$BO6,EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)),5)
    for i in 1..<8760 { h[EM + i] = round(max(Double.zero, h[EK + i] - ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)),5) }

    /// intermediate resulting PV elec to TES
    let EN: Int = 157680
    // IF(EK6=0;0;ROUND($AY6-(EK6-EM6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6;5))
    for i in 1..<8760 {
      h[EN + i] = iff(h[EK + i].isZero, Double.zero, round(h0[AY + i] - (h[EK + i] - h[EM + i]) / (ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * h[EL + i], 5))
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let EO: Int = 166440
    let AW0: Int = 359160
    let EN_BOcountNonZero = h.count(hours: BOday, range: EN, predicate: { $0 > Double.zero })
    let ENsum: [Double] = h.sum(hours: BOday, condition: EN)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 1..<8760 {
      let a = (h0[AW0 + i] - h[EN + i]) / (h[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i - 1])
      let b = (h0[J0 + i] - h[EN + i] * Heater_eff / Ratio_CSP_vs_Heater) / (h[EM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i - 1])
      let s = ENsum[i - 1]
      h[EO + i] = iff(or(h[EN + i].isZero, h[EM + i].isZero), Double.zero, max(a, b) / s * h[EN + i])
    }
    let EOsum: [Double] = h.sum(hours: BOday, condition: EO)
    /// corrected max possible elec to TES
    let EP: Int = 175200
    // EP=IF(EE6=0,0,IF(EK6>0,ROUND(MAX(0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($BO$5:$BO$8764,"="&$BO6,EO$5:EO$8764)*EO6)),5),$AY6))
    for i in 1..<8760 {
      if h[EE + i].isZero {
        h[EP + i] = Double.zero
      } else {
        h[EP + i] = iff(h[EK + i] > Double.zero, round(max(Double.zero, h[EN + i] - iff(h[EM + i].isZero, Double.zero, h[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i - 1] * h[EO + i])), 5), h0[AY + i])
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
      h[ER + i] = max(0, h0[L0 + i] - h[EP + i])
      // =MAX(0,$J6-EQ6)
      h[ES + i] = max(0, h0[J0 + i] - h[EQ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let ET: Int = 210240
    // =IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(OR(EE6=0,AND(EH6=0,EB6=0)),PB_stby_aux_cons,0)+IF(AND(EE6>0,EB6>0),PB_stup_aux_cons+EB6*TES_aux_cons_perc,0)+IF(EH6>0,(EB6+EF6+EI6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      h[ET + i] =
        iff(h0[J0 + i] > Double.zero, h0[J0 + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + h0[M0 + i] + (h[EP + i] * Heater_eff + h[EQ + i]) * TES_aux_cons_perc
        + iff(or(h[EE + i] == Double.zero, and(h[EH + i] == Double.zero, h[EB + i] == Double.zero)), PB_stby_aux_cons, 0)
        + iff(and(h[EE + i] > Double.zero, h[EB + i] > Double.zero), PB_stup_aux_cons + h[EB + i] * TES_aux_cons_perc, 0)
        + iff(h[EH + i] > Double.zero, (h[EB + i] + h[EF + i] + h[EI + i]) * TES_aux_cons_perc, 0)
    }

    /// Min harmonious net elec cons not considering grid import
    let EW: Int = 236520
    // =IF(OR(DX6>0,MIN(MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)),MAX(0,ES6+MIN(El_boiler_cap_ud,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      h[EW + i] = iff(
        or(
          h[DX + i] > Double.zero,
          min(
            max(
              Double.zero,
              h[ER + i] + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[EP + i] - h0[L0 + i])) - h[ET + i]
                - min(El_boiler_cap_ud, max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - h[ES + i]) / El_boiler_eff)),
            max(
              Double.zero,
              h[ES + i] + min(
                El_boiler_cap_ud,
                max(
                  Double.zero,
                  h[ER + i] + max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(Double.zero, h[EP + i] - h0[L0 + i])) - h[ET + i]
                    - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons
              * Overall_harmonious_var_max_cons + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons), Double.zero,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
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
    // MAX(0,(EX6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 { if h[EX + i].isZero { h[EY + i] = Double.zero } else { h[EY + i] = max(Double.zero, (h[EX + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons) } }

    /// Grid import for TES chrg and min harm and stby
    let EU: Int = 219000
    // =IF(EP6=0,0,MAX(0,ROUND(EP6+ET6+EX6+MIN(El_boiler_cap_ud,MAX(0,EY6-ES6)/El_boiler_eff)-$L6,5)))
    for i in 1..<8760 {
      if h[EP + i].isZero { h[EU + i] = Double.zero } else { h[EU + i] = max(Double.zero, round(h[EP + i] + h[ET + i] + h[EX + i] + min(El_boiler_cap_ud, max(Double.zero, h[EY + i] - h[ES + i]) / El_boiler_eff) - h0[L0 + i], 5)) }
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
    let CT0: Int = 788400
    let FA: Int = 271560
    // FA=IF(OR(EX6>0,EE6=0,MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-EU6)+EH6+ER6-ET6<A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)),IF(EX6>0,0,IF(EX7=0,Overall_stby_cons,Overall_stup_cons)),MAX(CT6,A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+A_overall_var_max_cons*MIN(1,IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons)+(ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)/(A_overall_var_max_cons+A_overall_var_heat_max_cons/El_boiler_eff),1),IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons))/A_overall_var_max_cons,1),IFERROR((ES6+EI6/PB_Ratio_Heat_input_vs_output+El_boiler_cap_ud*El_boiler_eff-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/A_overall_var_heat_max_cons,1))))
    for i in 1..<8760 {
    h[FA + i] = iff(
      or(
        h[EX + i] > Double.zero, h[EE + i] == Double.zero,
        max(0, iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[EU + i])
          + h[EH + i] + h[ER + i] - h[ET + i] < overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j])),
      iff(h[EX + i] > Double.zero, 0, iff(h[EX + i + 1] == Double.zero, Overall_stby_cons, Overall_stup_cons)),
      max(
        h0[CT0 + i],
        overall_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j]) + overall_var_max_cons[j]
          * min(
            1,
            ifFinite(
              (h[EH + i] + h[ER + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i]) - h[ET + i] - h[EX + i]
                - overall_fix_stby_cons[j] - iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j])
                + (h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[EY + i] - overall_heat_fix_stby_cons[j]
                  - iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
                / (overall_var_max_cons[j] + overall_var_heat_max_cons[j] / El_boiler_eff), 1),
            ifFinite(
              (h[EH + i] + h[ER + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i]) - h[ET + i] - h[EX + i]
                - overall_fix_stby_cons[j] - iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j])) / overall_var_max_cons[j], 1),
            ifFinite(
              (h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + El_boiler_cap_ud * El_boiler_eff - h[EY + i] - overall_heat_fix_stby_cons[j]
                - iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])) / overall_var_heat_max_cons[j], 1))))
    }

    // let FAsum: [Double] = h.sum(hours: BOday, condition: FA)
    let FA_DXnonZeroSum = h.sum(FA, hours: BOday, condition: DX, predicate: { $0 > Double.zero })
    let CT_DXnonZeroSum = h0.sum(CT0, hours: BOday, range2: h, condition: DX, predicate: { $0 > Double.zero })
    /// TES energy to fulfil op case if above
    let EJ: Int = 122640

    // EJ=IF(OR(EE6=0,DV6=0),0,MIN(DV6,MAX(A_equiv_harmonious_min_perc,IFERROR((SUMIFS(FA$5:FA$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0")-SUMIFS(CT$5:CT$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0"))/(SUMIF($BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764)-SUMIFS(CT$5:CT$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0"))+A_equiv_harmonious_min_perc,DV6),IFERROR((EE6-CC6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(DV6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc,A_equiv_harmonious_max_perc))))
    for i in 1..<8760 {
      if or(h[EE + i].isZero, h[i].isZero) {
        h[EJ + i] = Double.zero
      } else {
        h[EJ + i] = min(
          h[i],
          max(
            equiv_harmonious_min_perc[j], ifFinite((FA_DXnonZeroSum[i - 1] - CT_DXnonZeroSum[i - 1]) / (DXsum[i - 1] - CT_DXnonZeroSum[i - 1]) + equiv_harmonious_min_perc[j], h[i]),
            ifFinite((h[EE + i] - h0[CC0 + i]) / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - h0[CC0 + i]) * (h[i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j], equiv_harmonious_max_perc[j])))
      }
    }

    let CU0 = 797160
    /// heat cons due to op outside of harm op period
    let FB: Int = 280320
    // FB=IF(OR(EX6>0,EE6=0,EI6/PB_Ratio_Heat_input_vs_output+ES6+MIN(El_boiler_cap_ud,MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-EU6)+EH6+ER6-ET6-FA6)*El_boiler_eff<A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(EX7=0,0,A_overall_heat_stup_cons)),IF(EX6>0,0,IF(EX7=0,Overall_heat_stby_cons,Overall_heat_stup_cons)),MAX(CU6,A_overall_heat_fix_stby_cons+IF(EX7=0,0,A_overall_heat_stup_cons)+A_overall_var_heat_max_cons*MIN(1,IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons)+(ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)/(A_overall_var_max_cons+A_overall_var_heat_max_cons/El_boiler_eff),1),IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons))/A_overall_var_max_cons,1),IFERROR((ES6+EI6/PB_Ratio_Heat_input_vs_output+El_boiler_cap_ud*El_boiler_eff-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/A_overall_var_heat_max_cons,1))))
    for i in 1..<8760 {
      h[FB + i] = iff(
        or(
          h[EX + i] > Double.zero, h[EE + i] == Double.zero,
          h[EI + i] / PB_Ratio_Heat_input_vs_output + h[ES + i] + min(
            El_boiler_cap_ud,
            max(0, iff(h[EX + i] > Double.zero, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - h[EU + i])
              + h[EH + i] + h[ER + i] - h[ET + i] - h[FA + i]) * El_boiler_eff < overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])),
        iff(h[EX + i] > Double.zero, 0, iff(h[EX + i + 1] == Double.zero, Overall_heat_stby_cons, Overall_heat_stup_cons)),
        max(
          h0[CU0 + i],
          overall_heat_fix_stby_cons[j] + iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j]) + overall_var_heat_max_cons[j]
            * min(
              Double.one,
              ifFinite(
                (h[EH + i] + h[ER + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i]) - h[ET + i] - h[EX + i]
                  - overall_fix_stby_cons[j] - iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j])
                  + (h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[EY + i] - overall_heat_fix_stby_cons[j]
                    - iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])) / El_boiler_eff)
                  / (overall_var_max_cons[j] + overall_var_heat_max_cons[j] / El_boiler_eff), 1),
              ifFinite(
                (h[EH + i] + h[ER + i] + max(0, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - h[EU + i]) - h[ET + i] - h[EX + i]
                  - overall_fix_stby_cons[j] - iff(h[EX + i + 1] == Double.zero, 0, overall_stup_cons[j])) / overall_var_max_cons[j], 1),
              ifFinite(
                (h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + El_boiler_cap_ud * El_boiler_eff - h[EY + i] - overall_heat_fix_stby_cons[j]
                  - iff(h[EX + i + 1] == Double.zero, 0, overall_heat_stup_cons[j])) / overall_var_heat_max_cons[j], 1))))
    }

    /// Remaining el after min harmonious
    let FC: Int = 289080
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+EY6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 {
      h[FC + i] = max(
        Double.zero,
        round(h0[L0 + i] + h[EH + i] - h[EP + i] - h[ET + i] - h[EX + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, h[EQ + i] + h[EY + i] + h[FB + i] - h0[J0 + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff), 5))
    }

    /// Remaining heat after min harmonious
    let FD: Int = 297840
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 1..<8760 { h[FD + i] = max(Double.zero, round(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[EY + i] - h[FB + i], 5)) }

    /// Grid import necessary for min harm
    let FE: Int = 306600
    // =MAX(0,-ROUND(EH6+ER6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[FE + i] = max(Double.zero, round(-(h[EH + i] + h[ER + i] - h[ET + i] - h[EX + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, (h[EY + i] + h[FB + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output - h[ES + i]) / El_boiler_eff))), 5))
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
      h[FG + i] = min(El_boiler_cap_ud, max(Double.zero, round((h[EY + i] + h[FB + i] - h[ES + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output), 5) / El_boiler_eff)) 
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let FH: Int = 332880
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 1..<8760 { h[FH + i] = max(Double.zero, round(El_boiler_cap_ud - h[FG + i], 5)) }

    /// Remaining MethSynt cap after min harmonious cons
    let FI: Int = 341640
    /// Remaining CCU cap after min harmonious cons
    let FJ: Int = 350400
    /// Remaining EY cap after min harmonious cons
    let FK: Int = 359160
    let noCons = Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0
    let noCO2 = CO2_max_cons[j] + RawMeth_max_cons[j] == 0
    for i in 1..<8760 {
      // FI=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FI + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FC + i] + h[FF + i] + h[FD + i] / El_boiler_eff
                  - iff(
                    h[EX + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FD + i] + h[FH + i] * El_boiler_eff
                  - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FC + i] + h[FF + i] - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FI + i] = round(MethSynt_RawMeth_nom_prod_ud * iff(and(h[EX + i].isZero, h[FI + i] < MethSynt_cap_min_perc), Double.zero, h[FI + i]), 5)

      // FJ=ROUND(CCU_CO2_nom_prod_ud*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),(A_CO2_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),(A_CO2_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FJ + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        (CO2_max_cons[j] + RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FC + i] + h[FF + i] + h[FD + i] / El_boiler_eff
                  - iff(
                    h[EX + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FD + i] + h[FH + i] * El_boiler_eff
                  - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FC + i] + h[FF + i] - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FJ + i] = round(CCU_CO2_nom_prod_ud * iff(and(h[EX + i].isZero, h[FJ + i] < CCU_cap_min_perc), Double.zero, h[FJ + i]), 5)
      // FK=ROUND(EY_Hydrogen_nom_prod*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),(A_Hydrogen_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),(A_Hydrogen_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FK + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)
        ),
        (Hydrogen_max_cons[j] + RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FC + i] + h[FF + i] + h[FD + i] / El_boiler_eff
                  - iff(
                    h[EX + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FD + i] + h[FH + i] * El_boiler_eff
                  - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FC + i] + h[FF + i] - iff(h[EX + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FK + i] = round(EY_Hydrogen_nom_prod * iff(and(h[EX + i].isZero, h[FK + i] < EY_cap_min_perc), Double.zero, h[FK + i]), 5)
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
    // MAX(0;(FO6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)

    for i in 1..<8760 { h[FP + i] = iff(h[FO + i].isZero, Double.zero, max(Double.zero, (h[FO + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Remaining el after max harmonious
    let FQ: Int = 411720
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+FP6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 {
      h[FQ + i] = max(
        Double.zero,
        round(h0[L0 + i] + h[EH + i] - h[EP + i] - h[ET + i] - h[FO + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, h[EQ + i] + h[FP + i] + h[FB + i] - h0[J0 + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff), 5))
    }

    /// Remaining heat after max harmonious
    let FR: Int = 420480
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 1..<8760 { h[FR + i] = max(Double.zero, round(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output - h[FP + i] - h[FB + i], 5)) }

    /// Grid import necessary for max harm
    let FS: Int = 429240
    // =MAX(0,-ROUND(EH6+ER6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 {
      h[FS + i] = max(Double.zero, round(-(h[EH + i] + h[ER + i] - h[ET + i] - h[FO + i] - h[FA + i] - min(El_boiler_cap_ud, max(Double.zero, (h[FP + i] + h[FB + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output - h[ES + i]) / El_boiler_eff))), 5))
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
    for i in 1..<8760 { h[FU + i] = min(El_boiler_cap_ud, max(Double.zero, round((h[FP + i] + h[FB + i] - h[ES + i] - h[EI + i] / PB_Ratio_Heat_input_vs_output), 5) / El_boiler_eff)) }

    let TJ: Int = FG
    // TJ=MAX(0,-ROUND(ES5+EI5/PB_Ratio_Heat_input_vs_output+FG5*El_boiler_eff-EY5-FB5,5))
    for i in 1..<8760 { h[TJ + i] = max(0, -round(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + h[FG + i] * El_boiler_eff - h[EY + i] - h[FB + i], 5)) }

    /// Remaining el boiler cap after max harmonious heat cons
    let FV: Int = 455520
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 1..<8760 { h[FV + i] = max(Double.zero, round(El_boiler_cap_ud - h[FU + i], 5)) }

    let TK: Int = FU
    // TK=MAX(0,-ROUND(ES5+EI5/PB_Ratio_Heat_input_vs_output+FU5*El_boiler_eff-FP5-FB5,5))
    for i in 1..<8760 { h[TK + i] = max(0, -round(h[ES + i] + h[EI + i] / PB_Ratio_Heat_input_vs_output + h[FU + i] * El_boiler_eff - h[FP + i] - h[FB + i], 5)) }

    /// Remaining MethSynt cap after max harmonious cons
    let FW: Int = 464280
    /// Remaining CCU cap after max harmonious cons
    let FX: Int = 473040
    /// Remaining EY cap after max harmonious cons
    let FY: Int = 481800
    for i in 1..<8760 {
      // FW=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FW + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc)
              + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FQ + i] + h[FT + i] + h[FR + i] / El_boiler_eff
                  - iff(
                    h[FO + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FR + i] + h[FV + i] * El_boiler_eff
                  - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FQ + i] + h[FT + i] - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FW + i] = round(MethSynt_RawMeth_nom_prod_ud * iff(and(h[FO + i].isZero, h[FW + i] < MethSynt_cap_min_perc), Double.zero, h[FW + i]), 5)
      // FX=ROUND(CCU_CO2_nom_prod_ud*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),(A_CO2_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),(A_CO2_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FX + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        (CO2_max_cons[j] + RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FQ + i] + h[FT + i] + h[FR + i] / El_boiler_eff
                  - iff(
                    h[FO + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FR + i] + h[FV + i] * El_boiler_eff
                  - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FQ + i] + h[FT + i] - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FX + i] = round(CCU_CO2_nom_prod_ud * iff(and(h[FO + i].isZero, h[FX + i] < CCU_cap_min_perc), Double.zero, h[FX + i]), 5)
      // FY=ROUND(EY_Hydrogen_nom_prod*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),(A_Hydrogen_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),(A_Hydrogen_max_cons+A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      h[FY + i] = min(
        Double.one,
        max(
          Double.zero,
          Double.one
            - ((max(Double.zero, h[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)
        ),
        (Hydrogen_max_cons[j] + RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= Double.zero, 9999,
              max(
                Double.zero,
                h[FQ + i] + h[FT + i] + h[FR + i] / El_boiler_eff
                  - iff(
                    h[FO + i] > Double.zero, Double.zero,
                    iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff) + iff(noCO2, Double.zero, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(noCons, Double.zero, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff))) / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(
                Double.zero,
                h[FR + i] + h[FV + i] * El_boiler_eff
                  - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, -MethSynt_heat_fix_prod) + iff(noCO2, Double.zero, CCU_heat_fix_cons) + iff(noCons, Double.zero, EY_heat_fix_cons)))
                / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= Double.zero, 9999,
              max(Double.zero, h[FQ + i] + h[FT + i] - iff(h[FO + i] > Double.zero, Double.zero, iff(RawMeth_max_cons[j].isZero, Double.zero, MethSynt_fix_cons) + iff(noCO2, Double.zero, CCU_fix_cons) + iff(noCons, Double.zero, EY_fix_cons)))
                / daytime_cons_per_h_of_night_op[j])))
      h[FY + i] = round(EY_Hydrogen_nom_prod * iff(and(h[FO + i].isZero, h[FY + i] < EY_cap_min_perc), Double.zero, h[FY + i]), 5)
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
