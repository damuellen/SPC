extension TunOl {
  func hour4(_ hour4: inout [Double], j: Int, d1 day11: [Double], hour0: [Double], hour1: [Double], hour2: [Double]) {
    let (J, L, M, AW, BK, BM, BP, BQ, CC) = (26280, 43800, 52560, 8760, 131400, 148920, 175200, 183960, 70080)
    let BO = 166440
    let daysBO: [[Int]] = hour1[BO + 1..<(BO + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] }).map { $0.map { $0 - BO } }

    let AY = 26280
    let AYsum = hour1.sum(hours: daysBO, condition: AY)
    /// Maximum night op perc considering tank sizes
    let DV = 0
    let day1R = 5475
    let hour = daysBO.indices
      .map { day -> [Double] in let value = day11[(day + day1R)]
        return [Double](repeating: value, count: daysBO[day].count)
      }
      .joined()
    // VLOOKUP(BO6,DailyCalc_1A3:R367,COLUMN(DailyCalc_1R3))
    hour4.replaceSubrange(1..<8760, with: hour)

    /// Max net elec demand outside harm op period
    let DW = 8760
    // =IF(OR(BU5=0,DV5=0),0,IF(OR($BM5>0,(A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV5-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+IF($BM6=0,0,A_overall_stup_cons)+MIN(El_boiler_cap_ud,MAX(0,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV5-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM6=0,0,A_overall_heat_stup_cons)-$BQ5)/El_boiler_eff)<$BP5-PB_stby_aux_cons),0,MIN(((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV5-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF($BM6=0,0,A_overall_stup_cons),PB_nom_net_cap+$BP5+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_var_heat_max_cons*TES_aux_cons_perc-$BK5)))
    for i in 1..<8760 {
      hour4[DW + i] = iff(
        or(hour2[i].isZero, hour4[DV + i].isZero), .zero,
        iff(
          or(
            hour1[BM + i] > .zero,
            (overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour1[BM + i + 1].isZero, .zero, overall_stup_cons[j])
              + min(
                El_boiler_cap_ud,
                max(
                  .zero,
                  (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour1[BM + i + 1].isZero, .zero, overall_heat_stup_cons[j])
                    - hour1[BQ + i]) / El_boiler_eff) < hour1[BP + i] - PB_stby_aux_cons), .zero,
          min(
            ((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hour1[BM + i + 1].isZero, .zero, overall_stup_cons[j]),
            PB_nom_net_cap + hour1[BP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - PB_var_heat_max_cons * TES_aux_cons_perc - hour1[BK + i])))
    }

    /// Optimized max net elec demand outside harm op period
    let DX = 17520
    // IF(AND(DW7>0,DW6=0,DW5>0),DW5,DW6)
    for i in 1..<8760 { hour4[DX + i] = iff(and(hour4[DW + i + 1] > .zero, hour4[DW + i].isZero, hour4[DW + i - 1] > .zero), hour4[DW + i - 1], hour4[DW + i]) }

    let BF = 87600
    let BO_BFcount = hour1.count(hours: daysBO, range: BF, predicate: { $0 > 0 })
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let DY = 26280
    // IF(OR($BM6>0;PB_nom_gross_cap_ud<=0;COUNTIFS($BO$5:$BO$8764;"="&$BO6;$BF$5:$BF$8764;">0")=0);0;$BK6+((MIN(PB_nom_net_cap;MAX(PB_net_min_cap;(1+TES_aux_cons_perc)*MAX(0;DX6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap;MAX(PB_net_min_cap;(1+TES_aux_cons_perc)*MAX(0;DX6-$BP6)))/PB_nom_net_cap;PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap;MAX(0;DX6-$BP6))-PB_net_min_cap))+MAX(0;(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-$BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(DX6=0;DX7>0);MAX(0;IF(COUNTIF(DX$1:DX6;"0")<PB_warm_start_duration;PB_hot_start_heat_req;PB_warm_start_heat_req)-$BQ6)*TES_aux_cons_perc;0))
    for i in 1..<8760 {
      hour4[DY + i] = iff(
        hour4[DV + i].isZero, .zero,
        iff(
          or(hour1[BM + i] > .zero, PB_nom_gross_cap_ud <= .zero, BO_BFcount[i - 1].isZero), .zero,
          hour1[BK + i]
            + ((min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour4[DX + i] - hour1[BP + i]))) + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * max(.zero, hour4[DX + i] - hour1[BP + i]))) / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff)
              + PB_fix_aux_el) / (PB_gross_min_eff + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap) * (min(PB_nom_net_cap, max(.zero, hour4[DX + i] - hour1[BP + i])) - PB_net_min_cap)) + max(
                .zero, (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - hour1[BQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
            + iff(
              and(hour4[DX + i].isZero, hour4[DX + i + 1] > .zero),
              max(
                .zero,
                iff(
                  (hour4[max(DX + i - 5, DX)...(DX + i)]
                    .reduce(0) {
                      if $1.isZero { return $0 + 1 }
                      return $0
                    }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req) - hour1[BQ + i]) * TES_aux_cons_perc, .zero)))
    }

    /// Corresponding max PB net elec output
    let DZ = 35040
    // IF(DX6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-BP6-BK6)))
    for i in 1..<8760 { hour4[DZ + i] = iff(hour4[DX + i].isZero, .zero, max(PB_net_min_cap, min(PB_nom_net_cap, hour4[DX + i] + hour4[DY + i] - hour1[BP + i] - hour1[BK + i]))) }

    /// Corresponding max PB gross elec output
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
    /// Max gross heat cons for ST
    let EC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 { hour4[EC + i] = iff(hour4[EA + i].isZero, .zero, hour4[EA + i] / PB_nom_gross_eff / POLY(hour4[EA + i] / PB_nom_gross_cap_ud, el_Coeff)) }
    let ECsum = hour4.sum(hours: daysBO, condition: EC)
    /// Max gross heat cons for extraction
    let ED = 70080
    // IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN((DX6-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,DZ6+$BP6+BK6-DX6-DY6)*El_boiler_eff)))
    for i in 1..<8760 {
      if or(hour4[DV + i].isZero, hour1[BM + i] > .zero, PB_nom_gross_cap_ud <= .zero, BO_BFcount[i - 1].isZero) {
        hour4[ED + i] = .zero
      } else {
        let stup_cons = iff(hour1[BM + i + 1].isZero, .zero, overall_stup_cons[j])
        let heat_stup_cons = iff(hour1[BM + i + 1].isZero, .zero, overall_heat_stup_cons[j])
        let minimum = min(
          (hour4[DX + i] - overall_fix_stby_cons[j] - stup_cons) / overall_var_max_cons[j] * overall_var_heat_max_cons[j], (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
        let ed = PB_Ratio_Heat_input_vs_output * max(.zero, minimum + overall_heat_fix_stby_cons[j] + heat_stup_cons - hour1[BQ + i] - min(El_boiler_cap_ud, max(.zero, hour4[DZ + i] + hour1[BP + i] + hour1[BK + i] - hour4[DX + i] - hour4[DY + i]) * El_boiler_eff))
        hour4[ED + i] = ed
      }
    }

    let EDsum = hour4.sum(hours: daysBO, condition: ED)
    let ECEDsum = zip(ECsum, EDsum).map { $0 + $1 }
    /// TES energy available if above min op case
    let EE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 1..<8760 { hour4[EE + i] = iff(hour2[CC + i].isZero, .zero, min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i - 1] + ECEDsum[i - 1])) }

    /// Effective gross heat cons for ST
    let EF = 87600
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*EC6)
    for i in 1..<8760 { hour4[EF + i] = iff(hour4[EE + i].isZero, .zero, (hour4[EE + i] - EBsum[i - 1]) / (ECEDsum[i - 1]) * hour4[EC + i]) }

    /// Effective PB gross elec output
    let EG = 96360
    // IF(EF6=0,0,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))
    for i in 1..<8760 { hour4[EG + i] = iff(hour4[EF + i].isZero, .zero, hour4[EF + i] * PB_nom_gross_eff * POLY(hour4[EF + i] / PB_nom_heat_cons, th_Coeff)) }

    /// Effective PB net elec output
    let EH = 105120
    // IF(EG6=0,0,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 1..<8760 { hour4[EH + i] = iff(hour4[EG + i].isZero, .zero, hour4[EG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(hour4[EG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el) }

    /// Effective gross heat cons for extraction
    let EI = 113880
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*ED6)
    for i in 1..<8760 { hour4[EI + i] = iff(hour4[EE + i].isZero, .zero, (hour4[EE + i] - EBsum[i - 1]) / (ECEDsum[i - 1]) * hour4[ED + i]) }

    /// TES energy to fulfil op case if above
    let EJ = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763),EE6,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))
    for i in 1..<8760 { hour4[EJ + i] = iff(min(AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < EBsum[i - 1] + ECEDsum[i - 1], hour4[EE + i], EBsum[i - 1] + ECEDsum[i - 1]) }

    /// Surplus TES energy due to op case
    let EK = 131400
    // IF(EJ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EJ6))
    for i in 1..<8760 { hour4[EK + i] = iff(hour4[EJ + i].isZero, .zero, max(.zero, AYsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hour4[EJ + i])) }

    /// Peripherial PV hour PV to heater
    let EL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 { hour4[EL + i] = iff(or(and(hour4[EK + i] > .zero, hour1[AY + i] > .zero, hour1[AY + i - 1].isZero), and(hour4[EK + i] > .zero, hour1[AY + i + 1].isZero, hour1[AY + i] > .zero)), hour1[AY + i], .zero) }
    let ELsum = hour4.sum(hours: daysBO, condition: EL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let EM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 { hour4[EM + i] = max(.zero, hour4[EK + i] - ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let EN = 157680
    // IF(EK6=0;0;ROUND($AY6-(EK6-EM6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6;5))
    for i in 1..<8760 {
      hour4[EN + i] = iff(hour4[EK + i].isZero, .zero, round(hour1[AY + i] - (hour4[EK + i] - hour4[EM + i]) / (ELsum[i - 1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour4[EL + i], 5))
      if hour4[EN + i] < 1 { hour4[EN + i] = 0 }
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let EO = 166440
    let EN_BOcountNonZero = hour4.count(hours: daysBO, range: EN, predicate: { $0 > 0 })
    let ENsum = hour4.sum(hours: daysBO, condition: EN)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 1..<8760 {
      let a = (hour1[AW + i] - hour4[EN + i]) / (hour4[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i - 1])
      let b = (hour0[J + i] - hour4[EN + i] * Heater_eff / Ratio_CSP_vs_Heater) / (hour4[EM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i - 1])
      let s = ENsum[i - 1]
      hour4[EO + i] = iff(or(hour4[EN + i].isZero, hour4[EM + i].isZero), .zero, max(a, b) / s * hour4[EN + i])
    }
    let EOsum = hour4.sum(hours: daysBO, condition: EO)
    /// corrected max possible PV elec to TES
    let EP = 175200
    // IF(EJ6=0,0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,EO5:EO8763)*EO6))
    for i in 1..<8760 { hour4[EP + i] = iff(hour4[EJ + i].isZero, .zero, hour4[EN + i] - iff(hour4[EM + i].isZero, .zero, hour4[EM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i - 1] * hour4[EO + i])) }

    /// Max possible CSP heat to TES
    let EQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour4[EQ + i] = min(hour0[J + i], hour4[EP + i] * Heater_eff / Ratio_CSP_vs_Heater) }

    /// Available elec from PV after TES chrg
    let ER = 192720
    /// Available heat from CSP after TES
    let ES = 201480
    for i in 1..<8760 {
      // MAX(0,L6-EP6)
      hour4[ER + i] = max(.zero, hour0[L + i] - hour4[EP + i])
      // MAX(0,J6-EQ6)
      hour4[ES + i] = max(.zero, hour0[J + i] - hour4[EQ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let ET = 210240
    // IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(OR(EE6=0,AND(EH6=0,EB6=0)),PB_stby_aux_cons,0)+IF(AND(EE6>0,EB6>0),PB_stup_aux_cons+EB6*TES_aux_cons_perc,0)+IF(EH6>0,(EB6+EF6+EI6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      hour4[ET + i] =
        iff(hour0[J + i] > .zero, hour0[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[M + i] + (hour4[EP + i] * Heater_eff + hour4[EQ + i]) * TES_aux_cons_perc + iff(or(hour4[EE + i].isZero, and(hour4[EH + i].isZero, hour4[EB + i].isZero)), PB_stby_aux_cons, .zero)
        + iff(and(hour4[EE + i] > .zero, hour4[EB + i] > .zero), PB_stup_aux_cons + hour4[EB + i] * TES_aux_cons_perc, .zero) + iff(hour4[EH + i] > .zero, (hour4[EB + i] + hour4[EF + i] + hour4[EI + i]) * TES_aux_cons_perc, .zero)
    }

    /// Not covered aux elec MWel
    let EU = 219000
    // =MAX(0,-(L6+EH6-EP6-ET6))
    for i in 1..<8760 { hour4[EU + i] = max(.zero, -(hour0[L + i] + hour4[EH + i] - hour4[EP + i] - hour4[ET + i])) }

    /// Min harmonious net elec cons not considering grid import
    let EW = 227760
    // IF(MIN(MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-MIN(El_boiler_cap_ud;MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff));MAX(0;ES6+MIN(El_boiler_cap_ud;MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons;0;Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour4[EW + i] = iff(
        min(
          max(.zero, hour4[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[ET + i] - min(El_boiler_cap_ud, max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[ES + i]) / El_boiler_eff)),
          max(.zero, hour4[ES + i] + min(El_boiler_cap_ud, max(.zero, hour4[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons
            + Overall_fix_cons) < Overall_harmonious_var_min_cons + Overall_fix_cons, .zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
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

    /// El cons due to op outside of harm op period
    let FA = 262800
    // IF(OR(EX6>0;EJ6=0;MIN(MAX(0;Grid_import_max_ud*Grid_import_yes_no_PB_strategy+EH6+ER6-ET6-EX6-MIN(El_boiler_cap_ud;MAX(0;MIN((DX6-A_overall_fix_stby_cons-IF(EX7=0;0;A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons;(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EX7=0;0;A_overall_heat_stup_cons)+EY6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff));MAX(0;MIN(El_boiler_cap_ud;Grid_import_max_ud*Grid_import_yes_no_PB_strategy+EH6+ER6-ET6-EX6)*El_boiler_eff+ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-IF(EX7=0;0;A_overall_heat_stup_cons)-A_overall_heat_fix_stby_cons)/((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)*((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons))<A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons));0;MIN(DX6;(A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons)))
    for i in 1..<8760 {
      hour4[FA + i] = iff(
        hour4[DV + i].isZero, .zero,
        iff(
          or(
            hour4[EX + i] > .zero, hour4[EJ + i].isZero,
            min(
              max(
                .zero,
                Grid_import_max_ud * Grid_import_yes_no_PB_strategy + hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[EX + i]
                  - min(
                    El_boiler_cap_ud,
                    max(
                      .zero,
                      min(
                        (hour4[DX + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])) / overall_var_max_cons[j] * overall_var_heat_max_cons[j],
                        (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])
                        + hour4[EY + i] - hour4[ES + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)),
              max(
                .zero,
                min(El_boiler_cap_ud, Grid_import_max_ud * Grid_import_yes_no_PB_strategy + hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[EX + i]) * El_boiler_eff + hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[EY + i] - iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])
                  - overall_heat_fix_stby_cons[j]) / ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                * ((overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])) < overall_var_min_cons[j]
              + overall_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])), .zero,
          min(hour4[DX + i], (overall_var_max_cons[j] - overall_var_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (hour4[DV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j]))))
    }

    /// heat cons due to op outside of harm op period
    let FB = 271560
    // IF(FA5=0;0;MAX(0;(FA5-A_overall_fix_stby_cons-IF(EX6=0;0;A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF(EX6=0;0;A_overall_heat_stup_cons)))
    for i in 1..<8760 {
      hour4[FB + i] = iff(hour4[FA + i].isZero, .zero, max(.zero, (hour4[FA + i] - overall_fix_stby_cons[j] - iff(hour4[EX + i + 1].isZero, .zero, overall_stup_cons[j])) / overall_var_max_cons[j] * overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour4[EX + i + 1].isZero, .zero, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let FC = 280320
    // MAX(0,EH6+ER6-ET6-EX6-FA6-min(El_boiler_cap_ud;MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 1..<8760 { hour4[FC + i] = max(.zero, round(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[EX + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[EY + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff)), 5)) }

    /// Remaining heat after min harmonious
    let FD = 289080
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 1..<8760 { hour4[FD + i] = max(.zero, round(hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[EY + i] - hour4[FB + i], 5)) }

    /// Grid import necessary for min harm
    let FE = 297840
    // MAX(0;-(EH6+ER6-ET6-EX6-FA6-MIN(El_boiler_cap_ud;MAX(0;(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))))
    for i in 1..<8760 { hour4[FE + i] = max(.zero, round(-(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[EX + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[EY + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff))), 5)) }

    /// Remaining grid import capacity after min harm
    let FF = 306600
    // Grid_import_max_ud-FE6
    for i in 1..<8760 { hour4[FF + i] = max(.zero, round(Grid_import_max_ud - hour4[FE + i], 5)) }

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

    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      let fraction = (max(.zero, hour4[EX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour4[FI + i] = max(.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud

      // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud

      hour4[FJ + i] = max(.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod

      hour4[FK + i] = max(.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let FL = 359160
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let FM = 367920
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FC6)
      hour4[FL + i] = min(BESS_chrg_max_cons, hour4[FC + i])
      // MIN(Grid_export_max_ud,FC6)
      hour4[FM + i] = min(Grid_export_max_ud, hour4[FC + i])
    }

    /// Max harmonious net elec cons
    let FN = 376680
    // IF(EW6=0;0;Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1;MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff);MAX(0;ES6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff);MAX(0;ES6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      hour4[FN + i] = iff(
        hour4[EW + i].isZero, .zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(
            1,
            max(.zero, hour4[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons - max(.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[ES + i]) / El_boiler_eff)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
            max(.zero, hour4[ES + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons + max(.zero, hour4[ER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[ET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
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
    // MAX(0,EH6+ER6-ET6-FO6-FA6-MIN(El_boiler_cap_ud;MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 1..<8760 { hour4[FQ + i] = max(.zero, round(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[FO + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[FP + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff)), 5)) }

    /// Remaining heat after max harmonious
    let FR = 411720
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 1..<8760 { hour4[FR + i] = max(.zero, round(hour4[ES + i] + hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[FP + i] - hour4[FB + i], 5)) }

    /// Grid import necessary for max harm
    let FS = 420480
    // MAX(0,-(EH6+ER6-ET6-FO6-FA6-min(El_boiler_cap_ud;MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))))
    for i in 1..<8760 { hour4[FS + i] = max(.zero, round(-(hour4[EH + i] + hour4[ER + i] - hour4[ET + i] - hour4[FO + i] - hour4[FA + i] - min(El_boiler_cap_ud, max(.zero, (hour4[FP + i] + hour4[FB + i] - hour4[EI + i] / PB_Ratio_Heat_input_vs_output - hour4[ES + i]) / El_boiler_eff))), 5)) }

    /// Remaining grid import capacity after max harm
    let FT = 429240
    // MAX(0;Grid_import_max_ud-FS6)
    for i in 1..<8760 { hour4[FT + i] = max(.zero, round(Grid_import_max_ud - hour4[FS + i], 5)) }

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
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      let fraction = (max(.zero, hour4[FO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour4[FW + i] = max(.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc)) * MethSynt_RawMeth_nom_prod_ud
      // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour4[FX + i] = max(.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_CO2_nom_prod_ud
      // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour4[FY + i] = max(.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let FZ = 481800
    /// Max grid export after TES chrg, min harm, night and aux el cons
    let GA = 490560
    for i in 1..<8760 {
      // MIN(BESS_chrg_max_cons,FQ6)
      hour4[FZ + i] = min(BESS_chrg_max_cons, hour4[FQ + i])
      // MIN(Grid_export_max_ud,FQ6)
      hour4[GA + i] = min(Grid_export_max_ud, hour4[FQ + i])
    }
  }
}
