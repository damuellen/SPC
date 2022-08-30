extension TunOl {
  func hour4(_ hour4: inout [Double], j: Int, d1 day11: [Double], hour0: [Double], hour1: [Double], hour2: [Double], hour3: [Double]) {
    let (J0, L0, M0, BK1, BM1, BP1, BQ1, CC2) = (26280, 43800, 52560, 131400, 148920, 175200, 183960, 70080)
    let BO1 = 166440
    let daysBO: [[Int]] = hour1[BO1 + 1..<(BO1 + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] }).map { $0.map { $0 - BO1 } }

    let AY1 = 26280
    let AYsum = hour1.sum(hours: daysBO, condition: AY1)
    /// Maximum night op perc considering tank sizes
    let DV = 0
    let day1R = 5475
    let BT2 = 175200
    let BX2 = 26280
    let hour = daysBO.indices.map { day -> [Double] in
      let value = day11[(day + day1R)]
      return [Double](repeating: value, count: daysBO[day].count)
    }.joined()
    // =IF(BT6=0,0,VLOOKUP($BO6,DailyCalc_1!$A$3:$R$367,COLUMN(DailyCalc_1!R$3)))
    hour4.replaceSubrange(1..<8760, with: hour)
    for i in 1..<8760 where hour2[BT2 + i].isZero { hour4[i] = .zero }

    /// Max net elec demand outside harm op period
    let DW = 8760
    // DW=IF(OR(BX6=0,DV6=0,$BM6>0,AND((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6)/El_boiler_eff)<$BP6-PB_stby_aux_cons,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)<El_boiler_cap_ud*El_boiler_eff+$BQ6)),0,((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF($BM7=0,0,A_overall_stup_cons))
    for i in 1..<8760 {
      hour4[DW + i] = iff(or(hour2[BX2 + i].isZero, hour4[DV + i].isZero, hour1[BM1 + i] > .zero, and((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_stup_cons[j]) + min(El_boiler_cap_ud, max(.zero, (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero,  .zero, overall_heat_stup_cons[j]) - hour1[BQ1 + i]) / El_boiler_eff) < hour1[BP1 + i] - PB_stby_aux_cons, (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_heat_stup_cons[j]) < El_boiler_cap_ud * El_boiler_eff + hour1[BQ1 + i])), .zero, ((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_stup_cons[j]))
    }

    /// Optimized max net elec demand outside harm op period
    let DX = 17520
    // =IF(OR(AND(DW6>0,DW5=0,DW7=0,DW4=0,DW8=0),AND(DW6=0,DW5>0,DW7>0),AND(DW6>0,OR(AND(DW4=0,DW5>0,DW7=0),AND(DW5=0,DW7>0,DW8=0)))),DW5,DW6)
    for i in 1..<8760 { 
      let a = hour4[max(DW + i - 2, DW)]
      let b = hour4[max(DW + i - 1, DW)]
      let c = hour4[min(DW + i + 1, DX - 1)]
      let d = hour4[min(DW + i + 2, DX - 1)]
      hour4[DX + i] = iff(
        or(
          and(hour4[DW + i] > 0, b.isZero, c.isZero, a.isZero, d.isZero), and(hour4[DW + i].isZero, b > 0, c > 0),
          and(hour4[DW + i] > 0, or(and(a.isZero, b > 0, c.isZero), and(b.isZero, c > 0, d.isZero)))), b, hour4[DW + i])
    }
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let DY = 26280
    // DY=ROUNDUP(IF(DV6=0,0,IF(OR($BM6>0,PB_nom_gross_cap_ud<=0),0,$BK6+MAX(0,(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,DX6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*MAX(0,DX6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,DX6-$BP6))-PB_net_min_cap))+((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*PB_Ratio_Heat_input_vs_output+IF(AND(DX6=0,DX8>0),IF(COUNTIF(DX2:DX6,"0")<PB_warm_start_duration,PB_hot_start_heat_req,PB_warm_start_heat_req),0)-$BQ6)*TES_aux_cons_perc)),1)
    for i in 1..<8760 {
      hour4[DY + i] = (iff(hour4[DV + i].isZero, .zero, iff(
        hour4[DV + i].isZero, .zero,
        iff(
          or(hour1[BM1 + i] > .zero, PB_nom_gross_cap_ud <= .zero), .zero,
          hour1[BK1 + i]
            + max(0, ((min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour4[DX + i] - hour1[BP1 + i]))) + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour4[DX + i] - hour1[BP1 + i]))) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff)
              + PB_fix_aux_el) / (PB_gross_min_eff + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap) * (min(PB_nom_net_cap, max(.zero, hour4[DX + i] - hour1[BP1 + i])) - PB_net_min_cap)) + (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * PB_Ratio_Heat_input_vs_output
            + iff(
              and(hour4[DX + i].isZero, hour4[DX + i + 1] > .zero),
                iff(
                  (hour4[max(DX + i - 5, DX)...(DX + i)]
                    .reduce(0) {
                      if $1.isZero { return $0 + 1 }
                      return $0
                    }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), 0) - hour1[BQ1 + i]) * TES_aux_cons_perc))) * 10).rounded(.up) / 10
    }

    /// Corresponding PB net elec output
    let DZ = 35040
    // =IF(AND(DX6=0,DX6+DY6-$BP6<=0),0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-$BP6)))
    for i in 1..<8760 { hour4[DZ + i] = iff(and(hour4[DX + i].isZero, (hour4[DX + i] + hour4[DY + i] - hour1[BP1 + i]) <= 0), .zero, max(PB_net_min_cap, min(PB_nom_net_cap, hour4[DX + i] + hour4[DY + i] - hour1[BP1 + i]))) 
    }

    /// Corresponding PB gross elec output
    let EA = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 { hour4[EA + i] = iff(hour4[DZ + i].isZero, .zero, hour4[DZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(hour4[DZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el) }

    /// ST startup heat cons
    let EB = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      hour4[EB + i] = iff(
        and(hour4[EA + i].isZero, hour4[EA + i + 1] > .zero),
        iff(
          (hour4[max(EA + i - 5, EA)...(EA + i)]
            .reduce(0) {
              if $1.isZero { return $0 + 1 }
              return $0
            }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req), .zero)
    }
    let EBsum = hour4.sum(hours: daysBO, condition: EB)
    /// Corresponding gross heat cons for ST
    let EC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { hour4[EC + i] = iff(hour4[EA + i].isZero, .zero, hour4[EA + i] / PB_nom_gross_eff / POLY(hour4[EA + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let ECsum = hour4.sum(hours: daysBO, condition: EC)
    /// Corresponding gross heat cons for extraction
    let ED = 70080
    // ED=IF(OR(DV6=0,$BM6>0,PB_nom_gross_cap_ud<=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN(IF(A_overall_var_max_cons=0,1,(MIN(DZ6-DY6+$BP6,DX6)-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons)*A_overall_var_heat_max_cons,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,DZ6+$BP6-DX6-DY6)*El_boiler_eff)))
    for i in 1..<8760 {
      hour4[ED + i] = iff(or(hour4[DV + i].isZero, hour1[BM1 + i] > .zero, PB_nom_gross_cap_ud < .zero), .zero, PB_Ratio_Heat_input_vs_output * max(.zero, min(iff(overall_var_max_cons[j].isZero, 1, (min(hour4[DZ + i] - hour4[DY + i] + hour1[BP1 + i], hour4[DX + i]) - overall_fix_stby_cons[j] - iff(hour1[BM1 + i + 1].isZero, .zero, overall_stup_cons[j])) / overall_var_max_cons[j]) * overall_var_heat_max_cons[j], (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j] + iff(hour1[BM1 + i + 1].isZero, .zero, overall_heat_stup_cons[j]) - hour1[BQ1 + i] - min(El_boiler_cap_ud, max(.zero, hour4[DZ + i] + hour1[BP1 + i] - hour4[DX + i] - hour4[DY + i]) * El_boiler_eff)))
    }

    let EDsum = hour4.sum(hours: daysBO, condition: ED)
    let ECEDsum = zip(ECsum, EDsum).map { $0 + $1 }
    /// TES energy available if above min op case
    let EE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 1..<8760 { hour4[EE + i] = iff(hour2[CC2 + i].isZero, .zero, min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i - 1] + ECEDsum[i - 1])) }
    let CA = 52560
    /// Effective gross heat cons for ST
    let EF = 87600
    // =IF(EE6=0,0,MIN(EC6,MAX(CA6,IFERROR((EE6-CC6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(EC6-CA6),0)+CA6)))
    for i in 1..<8760 {
      hour4[EF + i] = iff(hour4[EE + i].isZero, .zero, min(hour4[EC + i], max(hour2[CA + i], ifFinite((hour4[EE + i] - hour2[CC2 + i]) / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - hour2[CC2 + i]) * (hour4[EC + i] - hour2[CA + i]),0) + hour2[CA + i])))
    }

    let BY2 = 35040
    /// Effective PB gross elec output
    let EG = 96360
    // =IF(EF6=0,0,MIN(EA6,MAX(BY6,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))))
    for i in 1..<8760 {
      hour4[EG + i] = iff(hour4[EF + i].isZero, .zero, min(hour4[EA + i], max(hour2[BY2 + i], hour4[EF + i] * PB_nom_gross_eff * POLY(hour4[EF + i] / PB_nom_heat_cons, th_Coeff))))
    }

    /// Effective PB net elec output
    let EH = 105120
    // =IF(EG6=0,0,MIN(DZ6,MAX(BX6,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)))
    for i in 1..<8760 { 
      hour4[EH + i] = iff(hour4[EG + i].isZero, .zero, min(hour4[EG + i], max(hour2[BX2 + i], hour4[EG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(hour4[EG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el)))
    }
    let CB = 61320
    /// Effective gross heat cons for extraction
    let EI = 113880
    // =IF(EE6=0,0,MIN(ED6,MAX(CB6,IFERROR((EE6-CC6)/(SUMIF(BO5:BO8764,"="&BO6,EB5:EB8764)+SUMIF(BO5:BO8764,"="&BO6,EC5:EC8764)+SUMIF(BO5:BO8764,"="&BO6,ED5:ED8764)-CC6)*(ED6-CB6),0)+CB6)))
    for i in 1..<8760 { 
      hour4[EI + i] = iff(hour4[EE + i].isZero, .zero, min(hour4[ED + i], max(hour2[CB + i], ifFinite((hour4[EE + i] - hour2[CC2 + i]) / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - hour2[CC2 + i]) * (hour4[ED + i] - hour2[CB + i]), 0) + hour2[CB + i])))
    }
    let CT3 = 35040
    // let CTsum = hour3.sum(hours: daysBO, condition: CT)
    let DXsum = hour4.sum(hours: daysBO, condition: DX)

    /// Surplus TES energy due to op case
    let EK = 131400
    // =IF(EE6=0,0,MAX(0,SUMIF(BO5:BO8764,"="BO6,AY5:AY8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EE6))
    for i in 1..<8760 { hour4[EK + i] = iff(hour4[EE + i].isZero, .zero, max(.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hour4[EE + i])) }

    /// Peripherial PV hour PV to heater
    let EL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { hour4[EL + i] = iff(or(and(hour4[EK + i] > .zero, hour1[AY1 + i] > .zero, hour1[AY1 + i - 1].isZero), and(hour4[EK + i] > .zero, hour1[AY1 + i + 1].isZero, hour1[AY1 + i] > .zero)), hour1[AY1 + i], .zero) }
    let ELsum = hour4.sum(hours: daysBO, condition: EL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let EM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour4[EM + i] = max(.zero, hour4[EK + i] - ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let EN = 157680
    // IF(EK6=0;0;ROUND($AY6-(EK6-EM6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6;5))
    for i in 1..<8760 {
      hour4[EN + i] = iff(hour4[EK + i].isZero, .zero, round(hour1[AY1 + i] - (hour4[EK + i] - hour4[EM + i]) / (ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour4[EL + i], 5))
      if hour4[EN + i] < 1 { hour4[EN + i] = 0 }
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let EO = 166440
    let AW0 = 3509160
    let EN_BOcountNonZero = hour4.count(hours: daysBO, range: EN, predicate: { $0 > 0 })
    let ENsum = hour4.sum(hours: daysBO, condition: EN)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 1..<8760 {
      let a = (hour0[AW0 + i] - hour4[EN + i]) / (hour4[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i - 1])
      let b = (hour0[J0 + i] - hour4[EN + i] * Heater_eff / Ratio_CSP_vs_Heater) / (hour4[EM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i - 1])
      let s = ENsum[i - 1]
      hour4[EO + i] = iff(or(hour4[EN + i].isZero, hour4[EM + i].isZero), .zero, max(a, b) / s * hour4[EN + i])
    }
    let EOsum = hour4.sum(hours: daysBO, condition: EO)
    /// corrected max possible elec to TES
    let EP = 175200
    // EP=IF(EE6=0,0,IF(EK6>0,MAX(0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF($BO$5:$BO$8764,"="&$BO6,EO$5:EO$8764)*EO6)),$AY6))
    for i in 1..<8760 { hour4[EP + i] = iff(hour4[EE + i].isZero, .zero, iff(hour4[EK + i] > .zero, max(.zero, hour4[EN + i] - iff(hour4[EM + i].isZero, .zero, hour4[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i - 1] * hour4[EO + i])), hour1[AY1 + i])) }

    /// Max possible CSP heat to TES
    let EQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour4[EQ + i] = min(hour0[J0 + i], hour4[EP + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Available elec from PV after TES chrg
    let ER = 192720
    /// Available heat from CSP after TES
    let ES = 201480
    for i in 1..<8760 {
      // =MAX(0,ROUNDUP($L6-EP6,2))
      hour4[ER + i] = max(.zero, roundUp(hour0[L0 + i] - hour4[EP + i]))
      // =MAX(0,ROUNDUP($J6-EQ6,2))
      hour4[ES + i] = max(.zero, roundUp(hour0[J0 + i] - hour4[EQ + i]))
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let ET = 210240
    // =ROUNDDOWN(IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(OR(EE6=0,AND(EH6=0,EB6=0)),PB_stby_aux_cons,0)+IF(AND(EE6>0,EB6>0),PB_stup_aux_cons+EB6*TES_aux_cons_perc,0)+IF(EH6>0,(EB6+EF6+EI6)*TES_aux_cons_perc,0),2)
    for i in 1..<8760 {
      hour4[ET + i] =
        ((iff(hour0[J0 + i] > .zero, hour0[J0 + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[M0 + i] + (hour4[EP + i] * Heater_eff + hour4[EQ + i]) * TES_aux_cons_perc + iff(or(hour4[EE + i].isZero, and(hour4[EH + i].isZero, hour4[EB + i].isZero)), PB_stby_aux_cons, .zero)
        + iff(and(hour4[EE + i] > .zero, hour4[EB + i] > .zero), PB_stup_aux_cons + hour4[EB + i] * TES_aux_cons_perc, .zero) + iff(hour4[EH + i] > .zero, (hour4[EB + i] + hour4[EF + i] + hour4[EI + i]) * TES_aux_cons_perc, .zero)) * 100).rounded(.down) / 100
    }


    /// Min harmonious net elec cons not considering grid import
    let EW = 227760
    // =IF(OR(DX6>0,MIN(MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-MIN(El_boiler_cap_ud,MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)),MAX(0,ES6+MIN(El_boiler_cap_ud,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons),0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour4[EW + i] = iff(or(hour4[DX + i] > 0,
        min(
          max(.zero, hour4[ER + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour4[EP + i] - hour0[L0 + i])) - hour4[ET + i] - min(El_boiler_cap_ud, max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[ES + i]) / El_boiler_eff)),
          max(.zero, hour4[ES + i] + min(El_boiler_cap_ud, max(.zero, hour4[ER + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour4[EP + i] - hour0[L0 + i])) - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons
            + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons), .zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let EX = 236520
    // IF(OR(AND(EW6>0,EW5=0,EW7=0),AND(EW6>0,OR(AND(EW4=0,EW5>0,EW7=0),AND(EW5=0,EW7>0,EW8=0)))),0,EW6)
    for i in 1..<8760 {
      hour4[EX + i] = iff(or(and(hour4[EW + i] > .zero, hour4[EW + i - 1].isZero, hour4[EW + i + 1].isZero), and(hour4[EW + i] > .zero, or(and(hour4[EW + i - 2].isZero, hour4[EW + i - 1] > 0, hour4[EW + i + 1].isZero), and(hour4[EW + i - 1].isZero, hour4[EW + i + 1] > 0, hour4[EW + i + 2].isZero)))), 0, hour4[EW + i])
    }

    /// Min harmonious net heat cons
    let EY = 245280
    // MAX(0,(EX6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 { hour4[EY + i] = iff(hour4[EX + i].isZero, .zero, max(.zero, (hour4[EX + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Grid import for TES chrg and min harm and stby
    let EU = 219000
    // =IF(EP6=0,0,MAX(0,ROUND(EP6+ET6+EX6+MIN(El_boiler_cap_ud,MAX(0,EY6-ES6)/El_boiler_eff)-$L6,5)))
    for i in 1..<8760 { 
      hour4[EU + i] = iff(hour4[EP + i].isZero, .zero, max(.zero, round(hour4[EP + i] + hour4[ET + i] + hour4[EX + i] + min(El_boiler_cap_ud, max(.zero, hour4[EY + i] - hour4[ES + i]) / El_boiler_eff) - hour0[L0 + i], 5)))
    }
    /// Harmonious op day
    let EZ = 254040
    // =IF(OR(AND(EX19<=0,EX20>0,SUM(EX10:EX19)=0),AND($F19<=0,$F20>0,SUM(EX10:EX30)=0)),IF(EZ19<364,EZ19+1,0),EZ19)
    for i in 12..<8748 {
      hour4[EZ + i] = hour4[EZ + i - 1]
      if hour4[EX + i - 1].isZero, hour4[EX + i] > 0, hour4[EX + i + 1] > 0, hour4[(EZ + i - 12)..<(EZ + i)].allSatisfy( { $0 == hour4[EZ + i] }) {
        hour4[EZ + i] += 1
      } else if hour0[i - 1].isZero, hour0[i] > 0, hour4[EX + i..<EX + i + 12].allSatisfy(\.isZero), hour4[EZ + i - 12..<EZ + i].allSatisfy({ $0 == hour4[EZ + i] }) {
        hour4[EZ + i] += 1
      }
    }
    for i in 8748..<8760 { hour4[EZ + i] = hour4[EZ + i - 1] }
    /// El cons due to op outside of harm op period
    let FA = 262800
    // FA=IF(OR(EE6=0,EX6>0,CT6=0),0,MAX(CT6,A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+A_overall_var_max_cons*MIN(1,IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons)+(ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)/(A_overall_var_max_cons+A_overall_var_heat_max_cons/El_boiler_eff),1),IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons))/A_overall_var_max_cons,1),IFERROR((ES6+EI6/PB_Ratio_Heat_input_vs_output+El_boiler_cap_ud*El_boiler_eff-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/A_overall_var_heat_max_cons,1))))
    for i in 1..<8760 { 
    hour4[FA + i] = iff(
      or(hour4[EE + i].isZero, hour4[EX + i] > 0, hour3[CT3 + i].isZero), .zero,
      max(
        hour3[CT3 + i],
        overall_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j]) + overall_var_max_cons[j]
          * min(
            1, ifFinite(
            (hour4[EH + i] + hour4[ER + i] + max(.zero, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - hour4[EU + i]) - hour4[ET + i] - hour4[EX + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, 0, overall_stup_cons[j])
              + (hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[EY + i] - overall_heat_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])) / El_boiler_eff)
              / (overall_var_max_cons[j] + overall_var_heat_max_cons[j] / El_boiler_eff),1), ifFinite((
            hour4[EH + i] + hour4[ER + i] + max(.zero, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - hour4[EU + i]) - hour4[ET + i] - hour4[EX + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])) / overall_var_max_cons[j], 1), ifFinite(
            (hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output + El_boiler_cap_ud * El_boiler_eff - hour4[EY + i] - overall_heat_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])) / overall_var_heat_max_cons[j],1))))
    }

    // let FAsum = hour4.sum(hours: daysBO, condition: FA)
    let FA_DXnonZeroSum = hour4.sum(FA, hours: daysBO, condition: DX, predicate: {$0>0})
    let CT_DXnonZeroSum = hour3.sum(CT3, hours: daysBO, range2: hour4, condition: DX, predicate: {$0>0})
    /// TES energy to fulfil op case if above
    let EJ = 122640

    // EJ=IF(OR(EE6=0,DV6=0),0,MIN(DV6,MAX(A_equiv_harmonious_min_perc,IFERROR((SUMIFS(FA$5:FA$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0")-SUMIFS(CT$5:CT$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0"))/(SUMIF($BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764)-SUMIFS(CT$5:CT$8764,$BO$5:$BO$8764,"="&$BO6,DX$5:DX$8764,">0"))+A_equiv_harmonious_min_perc,DV6),IFERROR((EE6-CC6)/(SUMIF($BO$5:$BO$8764,"="&$BO6,EB$5:EB$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,EC$5:EC$8764)+SUMIF($BO$5:$BO$8764,"="&$BO6,ED$5:ED$8764)-CC6)*(DV6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc,A_equiv_harmonious_max_perc))))
    for i in 1..<8760 { 
      hour4[EJ + i] = iff(or(hour4[EE + i].isZero, hour4[i].isZero), .zero, min(hour4[i], max(equiv_harmonious_min_perc[j], ifFinite((FA_DXnonZeroSum[i - 1] - CT_DXnonZeroSum[i - 1]) / (DXsum[i - 1] - CT_DXnonZeroSum[i - 1]) + equiv_harmonious_min_perc[j], hour4[i]), ifFinite((hour4[EE + i] - hour2[CC2 + i]) / (EBsum[i - 1] + ECsum[i - 1] + EDsum[i - 1] - hour2[CC2 + i]) * (hour4[i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j], equiv_harmonious_max_perc[j]))))
    }
    let CU3 = 43800
    /// heat cons due to op outside of harm op period
    let FB = 271560
    // =IF(OR(EE6=0,EX6>0,CT6=0),0,MAX(CU6,A_overall_heat_fix_stby_cons+IF(EX7=0,0,A_overall_heat_stup_cons)+A_overall_var_heat_max_cons*MIN(1,IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons)+(ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)/(A_overall_var_max_cons+A_overall_var_heat_max_cons/El_boiler_eff),1),IFERROR((EH6+ER6+MAX(0,Grid_import_yes_no_PB_strategy_outsideharmop*Grid_import_max_ud-EU6)-ET6-EX6-A_overall_fix_stby_cons-IF(EX7=0,0,A_overall_stup_cons))/A_overall_var_max_cons,1),IFERROR((ES6+EI6/PB_Ratio_Heat_input_vs_output+El_boiler_cap_ud*El_boiler_eff-EY6-A_overall_heat_fix_stby_cons-IF(EX7=0,0,A_overall_heat_stup_cons))/A_overall_var_heat_max_cons,1))))
    for i in 1..<8760 {
      hour4[FB + i] = iff(
      or(hour4[EE + i].isZero, hour4[EX + i] > 0, hour3[CT3 + i].isZero), .zero,
      max(
        hour3[CU3 + i],
        overall_heat_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j]) + overall_var_heat_max_cons[j]
          * min(
            1, ifFinite(
            (hour4[EH + i] + hour4[ER + i] + max(.zero, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - hour4[EU + i]) - hour4[ET + i] - hour4[EX + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, 0, overall_stup_cons[j])
              + (hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[EY + i] - overall_heat_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])) / El_boiler_eff)
              / (overall_var_max_cons[j] + overall_var_heat_max_cons[j] / El_boiler_eff),1), ifFinite((
            hour4[EH + i] + hour4[ER + i] + max(.zero, Grid_import_yes_no_PB_strategy_outsideharmop * Grid_import_max_ud - hour4[EU + i]) - hour4[ET + i] - hour4[EX + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])) / overall_var_max_cons[j], 1), ifFinite(
            (hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output + El_boiler_cap_ud * El_boiler_eff - hour4[EY + i] - overall_heat_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])) / overall_var_heat_max_cons[j],1))))
    }

    /// Remaining el after min harmonious
    let FC = 280320
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+EY6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 { hour4[FC + i] = max(.zero, round(hour0[L0 + i] + hour4[EH + i] - hour4[EP + i] - hour4[ET + i] - hour4[EX + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, hour4[EQ + i] + hour4[EY + i] + hour4[FB + i] - hour0[J0 + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff), 5)) }

    /// Remaining heat after min harmonious
    let FD = 289080
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 1..<8760 { hour4[FD + i] = max(.zero, round(hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[EY + i] - hour4[FB + i], 5)) }

    /// Grid import necessary for min harm
    let FE = 297840
    // =MAX(0,-ROUND(EH6+ER6-ET6-EX6-FA6-MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 { hour4[FE + i] = max(.zero, round(-(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[EX + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[EY + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff))), 5)) }

    /// Grid import for min harm and stby
    let TB = 508080
    // =MIN(IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,FE6)
    for i in 1..<8760 { 
      hour4[TB + i] = min(iff(hour4[EX + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, hour4[FE + i]) 
    }

    /// Remaining grid import capacity after min harm
    let FF = 306600
    // =MAX(0,IF(EX6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-TB6)
    for i in 1..<8760 {
      hour4[FF + i] = max(.zero, iff(hour4[EX + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - hour4[TB + i])
    }

    /// El boiler op after min harmonious heat cons
    let FG = 315360
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 { hour4[FG + i] = min(El_boiler_cap_ud, max(.zero, round((hour4[EY + i] + hour4[FB + i] - hour4[ES + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output), 5) / El_boiler_eff)) }

    /// Remaining el boiler cap after min harmonious heat cons
    let FH = 324120
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 1..<8760 { hour4[FH + i] = max(.zero, round(El_boiler_cap_ud - hour4[FG + i], 5)) }

    /// Remaining MethSynt cap after min harmonious cons
    let FI = 332880
    /// Remaining CCU cap after min harmonious cons
    let FJ = 341640
    /// Remaining EY cap after min harmonious cons
    let FK = 350400

    for i in 1..<8760 {
      // FI=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FF6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FI + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i] + hour4[FD + i] / El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FF + i] + hour4[FH + i] * El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i]
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FI + i] = round(MethSynt_RawMeth_nom_prod_ud * iff(and(hour4[EX + i] == 0, hour4[FI + i] < MethSynt_cap_min_perc), 0, hour4[FI + i]), 5)

      // FJ=ROUND(CCU_CO2_nom_prod_ud*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FF6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FJ + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        CO2_max_cons[j] / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i] + hour4[FD + i] / El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FF + i] + hour4[FH + i] * El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i]
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FJ + i] = round(CCU_CO2_nom_prod_ud * iff(and(hour4[EX + i] == 0, hour4[FJ + i] < CCU_cap_min_perc), 0, hour4[FJ + i]), 5)
      // FK=ROUND(EY_Hydrogen_nom_prod*IF(AND(EX6=0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FF6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FC6+FF6+FD6/El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FD6+FH6*El_boiler_eff-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FC6+FF6-IF(EX6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FK + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc)
              + EY_harmonious_min_perc)),
        Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i] + hour4[FD + i] / El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FF + i] + hour4[FH + i] * El_boiler_eff
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FC + i] + hour4[FF + i]
                  - iff(
                    hour4[EX + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FK + i] = round(EY_Hydrogen_nom_prod * iff(and(hour4[EX + i] == 0, hour4[FK + i] < EY_cap_min_perc), 0, hour4[FK + i]), 5)
    }

    /// Max BESS charging after min harmonious cons
    let FL = 359160
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let FM = 367920
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FC6)
      hour4[FL + i] = min(BESS_chrg_max_cons, hour4[FC + i])
      // =MIN(IF(EX6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,FC6)
      hour4[FM + i] = min(iff(hour4[EX + i] > 0, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, hour4[FC + i])
    }

    /// Max harmonious net elec cons
    let FN = 376680
    for i in 1..<8760 {
    // =IF(EX6=0,0,Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1,MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0,Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),MAX(0,ES6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0,ER6+MAX(0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy-MAX(0,EP6-$L6))-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff),MAX(0,ES6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
      hour4[FN + i] = iff(
        hour4[EX + i].isZero, .zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            1,
            max(.zero, hour4[ER + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour4[EP + i] - hour0[L0 + i])) - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[ES + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(.zero, hour4[ES + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(.zero, hour4[ER + i] + max(.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy - max(.zero, hour4[EP + i] - hour0[L0 + i])) - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
              / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
            max(.zero, hour4[ES + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons) / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }

    /// Optimized max harmonious net elec cons
    let FO = 385440
    // IF(OR(AND(FN6>0;FN5=0;FN7=0);AND(FN6>0;OR(AND(FN4=0;FN5=0;FN8=0);AND(FN4=0;FN7=0;FN8=0))));0;FN6)
    for i in 1..<8760 {
      hour4[FO + i] = iff(or(and(hour4[FN + i] > .zero, hour4[FN + i - 1].isZero, hour4[FN + i + 1].isZero), and(hour4[FN + i] > .zero, or(and(hour4[FN + i - 2].isZero, hour4[FN + i - 1] > 0, hour4[FN + i + 1].isZero), and(hour4[FN + i - 1].isZero, hour4[FN + i + 1] > 0, hour4[FN + i + 2].isZero)))), 0, hour4[FN + i])
    }

    /// max harmonious net heat cons
    let FP = 394200
    // MAX(0;(FO6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)

    for i in 1..<8760 { hour4[FP + i] = iff(hour4[FO + i].isZero, .zero, max(.zero, (hour4[FO + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)) }

    /// Remaining el after max harmonious
    let FQ = 402960
    // =MAX(0,ROUND($L6+EH6-EP6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,EQ6+FP6+FB6-$J6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff),5))
    for i in 1..<8760 { hour4[FQ + i] = max(.zero, round(hour0[L0 + i] + hour4[EH + i] - hour4[EP + i] - hour4[ET + i] - hour4[FO + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, hour4[EQ + i] + hour4[FP + i] + hour4[FB + i] - hour0[J0 + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff), 5)) }

    /// Remaining heat after max harmonious
    let FR = 411720
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 1..<8760 { hour4[FR + i] = max(.zero, round(hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[FP + i] - hour4[FB + i], 5)) }

    /// Grid import necessary for max harm
    let FS = 420480
    // =MAX(0,-ROUND(EH6+ER6-ET6-FO6-FA6-MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)),5))
    for i in 1..<8760 { hour4[FS + i] = max(.zero, round(-(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[FO + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[FP + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff))), 5)) }

    /// Grid import for max harm and stby
    let TC = 499320
    // =MIN(IF(FO6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud,FS6)
    for i in 1..<8760 { 
      hour4[TC + i] = min(iff(hour4[FO + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud, hour4[FS + i]) 
    }
    /// Remaining grid import capacity after max harm
    let FT = 429240
    // =MAX(0,IF(FO6>0,Grid_import_yes_no_PB_strategy,Grid_import_yes_no_PB_strategy_outsideharmop)*Grid_import_max_ud-TC6)
    for i in 1..<8760 {
      hour4[FT + i] = max(.zero, iff(hour4[FO + i] > 0, Grid_import_yes_no_PB_strategy, Grid_import_yes_no_PB_strategy_outsideharmop) * Grid_import_max_ud - hour4[TC + i])
    }

    /// El boiler op after max harmonious heat cons
    let FU = 438000
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 { hour4[FU + i] = min(El_boiler_cap_ud, max(.zero, round((hour4[FP + i] + hour4[FB + i] - hour4[ES + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output), 5) / El_boiler_eff)) }

    /// Remaining el boiler cap after max harmonious heat cons
    let FV = 446760
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 1..<8760 { hour4[FV + i] = max(.zero, round(El_boiler_cap_ud - hour4[FU + i], 5)) }

    /// Remaining MethSynt cap after max harmonious cons
    let FW = 455520
    /// Remaining CCU cap after max harmonious cons
    let FX = 464280
    /// Remaining EY cap after max harmonious cons
    let FY = 473040
    for i in 1..<8760 {
      // FW=ROUND(MethSynt_RawMeth_nom_prod_ud*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FT6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<MethSynt_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc)),A_RawMeth_max_cons/MethSynt_RawMeth_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FW + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)),
        RawMeth_max_cons[j] / MethSynt_RawMeth_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i] + hour4[FR + i] / El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FT + i] + hour4[FV + i] * El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i]
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FW + i] = round(
        MethSynt_RawMeth_nom_prod_ud * iff(and(hour4[FO + i] == 0, hour4[FW + i] < MethSynt_cap_min_perc), 0, hour4[FW + i]), 5)
      // FX=ROUND(CCU_CO2_nom_prod_ud*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FT6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<CCU_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc)),A_CO2_max_cons/CCU_CO2_nom_prod_ud*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FX + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (CCU_harmonious_max_perc - CCU_harmonious_min_perc)
              + CCU_harmonious_min_perc)),
        CO2_max_cons[j] / CCU_CO2_nom_prod_ud
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i] + hour4[FR + i] / El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FT + i] + hour4[FV + i] * El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i]
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FX + i] = round(CCU_CO2_nom_prod_ud * iff(and(hour4[FO + i] == 0, hour4[FX + i] < CCU_cap_min_perc), 0, hour4[FX + i]), 5)
      // FY=ROUND(EY_Hydrogen_nom_prod*IF(AND(FO6=0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FT6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))<EY_cap_min_perc),0,MIN(1,MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc)),A_Hydrogen_max_cons/EY_Hydrogen_nom_prod*MIN(IF(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff<=0,9999,MAX(0,FQ6+FT6+FR6/El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons-MethSynt_heat_fix_prod/El_boiler_eff)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons+CCU_heat_fix_cons/El_boiler_eff)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons+EY_heat_fix_cons/El_boiler_eff)))/(A_daytime_cons_per_h_of_night_op+A_daytime_heat_cons_per_h_of_night_op/El_boiler_eff)),IF(A_daytime_heat_cons_per_h_of_night_op<=0,9999,MAX(0,FR6+FV6*El_boiler_eff-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,-MethSynt_heat_fix_prod)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_heat_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_heat_fix_cons)))/A_daytime_heat_cons_per_h_of_night_op),IF(A_daytime_cons_per_h_of_night_op<=0,9999,MAX(0,FQ6+FT6-IF(FO6=0,IF(A_RawMeth_max_cons=0,0,MethSynt_fix_cons)+IF(A_CO2_max_cons+A_RawMeth_max_cons=0,0,CCU_fix_cons)+IF(A_Hydrogen_max_cons+A_RawMeth_max_cons=0,0,EY_fix_cons)))/A_daytime_cons_per_h_of_night_op)))),5)
      hour4[FY + i] = min(
        1,
        max(
          0,
          1
            - ((max(0, hour4[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * (EY_harmonious_max_perc - EY_harmonious_min_perc)
              + EY_harmonious_min_perc)),
        Hydrogen_max_cons[j] / EY_Hydrogen_nom_prod
          * min(
            iff(
              daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i] + hour4[FR + i] / El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons - MethSynt_heat_fix_prod / El_boiler_eff)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons + CCU_heat_fix_cons / El_boiler_eff)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons + EY_heat_fix_cons / El_boiler_eff)))
                / (daytime_cons_per_h_of_night_op[j] + daytime_heat_cons_per_h_of_night_op[j] / El_boiler_eff)),
            iff(
              daytime_heat_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FT + i] + hour4[FV + i] * El_boiler_eff
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, -MethSynt_heat_fix_prod)
                      + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_heat_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_heat_fix_cons))) / daytime_heat_cons_per_h_of_night_op[j]),
            iff(
              daytime_cons_per_h_of_night_op[j] <= .zero, 9999,
              max(
                0,
                hour4[FQ + i] + hour4[FT + i]
                  - iff(
                    hour4[FO + i] > 0, 0,
                    iff(RawMeth_max_cons[j] == 0, 0, MethSynt_fix_cons) + iff(CO2_max_cons[j] + RawMeth_max_cons[j] == 0, 0, CCU_fix_cons)
                      + iff(Hydrogen_max_cons[j] + RawMeth_max_cons[j] == 0, 0, EY_fix_cons))) / daytime_cons_per_h_of_night_op[j])))
      hour4[FY + i] = round(EY_Hydrogen_nom_prod * iff(and(hour4[FO + i] == 0, hour4[FY + i] < EY_cap_min_perc), 0, hour4[FY + i]), 5)
    }

    /// Max BESS charging after max harmonious cons
    let FZ = 481800
    /// Max grid export after TES chrg, min harm, night and aux el cons
    let GA = 490560
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FQ6)
      hour4[FZ + i] = min(BESS_chrg_max_cons, hour4[FQ + i])
      // =MIN(IF(FO6>0,Grid_export_yes_no_PB_strategy,Grid_export_yes_no_PB_strategy_outsideharmop)*Grid_export_max_ud,FQ6)
      hour4[GA + i] = min(iff(hour4[FO + i] > 0, Grid_export_yes_no_PB_strategy, Grid_export_yes_no_PB_strategy_outsideharmop) * Grid_export_max_ud, hour4[FQ + i])      
    }
  }
}
