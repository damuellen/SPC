extension TunOl {
  func hour4(_ hour4: inout [Double], j: Int, day1 day11: [Double], hour0: [Double], hour1: [Double], hour2: [Double]) {
    let (hourJ, hourL, hourM, hourAW, hourBK, hourBM, hourBP, hourBQ, hourCC) = (
      26280, 43800, 52560, 8760, 131400, 148920, 175200, 183960, 70080
    )
    
    let hourBO = 166440
    let daysBO: [[Int]] = hour1[hourBO+1..<(hourBO + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] }).map { $0.map { $0 - hourBO } }

    let hourAY = 26280
    let AYsum = hour1.sum(hours: daysBO, condition: hourAY)
    
    /// Maximum night op perc considering tank sizes
    let hourDV = 0
    let day1R = 5475
    let hour = daysBO.indices.map { day -> [Double] in        
      let value = day11[(day + day1R)]
      return [Double](repeating: value, count: daysBO[day].count)
    }.joined()
    // VLOOKUP(BO6,DailyCalc_1A3:R367,COLUMN(DailyCalc_1R3))
    hour4.replaceSubrange(1..<8760, with: hour)

    /// Max net elec demand outside harm op period
    let hourDW = 8760
    // =IF(OR($BM6>0;(A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+$BK6+IF($BM7=0;0;A_overall_stup_cons)+MIN(El_boiler_cap_ud;MAX(0;(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0;0;A_overall_heat_stup_cons)-$BQ6)/El_boiler_eff)<$BP6-PB_stby_aux_cons);0;MIN(((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF($BM7=0;0;A_overall_stup_cons);PB_nom_net_cap+$BP6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-PB_var_heat_max_cons*TES_aux_cons_perc-$BK6))
    for i in 1..<8760 {
      hour4[hourDW + i] = iff(hour4[hourDV + i].isZero, Double.zero, iff(
        or(hour1[hourBM + i] > Double.zero,
          (overall_var_max_cons[j] - overall_var_min_cons[j])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (hour4[hourDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_min_cons[j] + overall_fix_stby_cons[j] + hour1[hourBK + i]
            + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_stup_cons[j]) + min(
              El_boiler_cap_ud, max(Double.zero,
              (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]
                + overall_heat_fix_stby_cons[j] + iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])
                - hour1[hourBQ + i]) / El_boiler_eff) < hour1[hourBP + i] - PB_stby_aux_cons), Double.zero,
          min(((overall_var_max_cons[j] - overall_var_min_cons[j])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (hour4[hourDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
            + iff(hour1[hourBM + i + 1].isZero, Double.zero,  overall_stup_cons[j]),
            PB_nom_net_cap + hour1[hourBP + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - PB_var_heat_max_cons * TES_aux_cons_perc - hour1[hourBK + i])))
    }

    /// Optimized max net elec demand outside harm op period
    let hourDX = 17520
    // IF(AND(DW7>0,DW6=0,DW5>0),DW5,DW6)
    for i in 1..<8760 {
      hour4[hourDX + i] = iff(
        and(hour4[hourDW + i + 1] > Double.zero, hour4[hourDW + i].isZero, hour4[hourDW + i - 1] > Double.zero), hour4[hourDW + i - 1],
        hour4[hourDW + i])
    }

    let hourBF = 87600
    let BO_BFcount = hour1.count(hours: daysBO, range: hourBF, predicate: {$0>0})
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourDY = 26280
    // IF(OR($BM6>0;PB_nom_gross_cap_ud<=0;COUNTIFS($BO$5:$BO$8764;"="&$BO6;$BF$5:$BF$8764;">0")=0);0;$BK6+((MIN(PB_nom_net_cap;MAX(PB_net_min_cap;(1+TES_aux_cons_perc)*MAX(0;DX6+$BK6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap;MAX(PB_net_min_cap;(1+TES_aux_cons_perc)*MAX(0;DX6+$BK6-$BP6)))/PB_nom_net_cap;PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap;MAX(0;DX6+$BK6-$BP6))-PB_net_min_cap))+MAX(0;(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-$BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(DX6=0;DX7>0);MAX(0;IF(COUNTIF(DX$1:DX6;"0")<PB_warm_start_duration;PB_hot_start_heat_req;PB_warm_start_heat_req)-$BQ6)*TES_aux_cons_perc;0))
    for i in 1..<8760 {
      hour4[hourDY + i] = iff(hour4[hourDV + i].isZero, Double.zero, iff(
        or(hour1[hourBM + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero, BO_BFcount[i-1].isZero), Double.zero,
        hour1[hourBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap, (1 + TES_aux_cons_perc) * max(Double.zero,
              hour4[hourDX + i] + hour1[hourBK + i] - hour1[hourBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc) * max(Double.zero, hour4[hourDX + i] + hour1[hourBK + i] - hour1[hourBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(Double.zero, hour4[hourDX + i] + hour1[hourBK + i] - hour1[hourBP + i]))
                  - PB_net_min_cap))
            + max(
              Double.zero,
              (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j]
                + overall_heat_fix_stby_cons[j] - hour1[hourBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hour4[hourDX + i].isZero, hour4[hourDX + i + 1] > Double.zero),
            max(
              Double.zero,
              iff(
                (hour4[max(hourDX + i - 5, hourDX)...(hourDX + i)].reduce(0) { if $1.isZero { return $0+1 }; return $0 }) < PB_warm_start_duration, PB_hot_start_heat_req, PB_warm_start_heat_req) - hour1[hourBQ + i]) * TES_aux_cons_perc, Double.zero)))
    }

    /// Corresponding max PB net elec output
    let hourDZ = 35040
    // IF(DX6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-BP6)))
    for i in 1..<8760 {
      hour4[hourDZ + i] = iff(
        hour4[hourDX + i].isZero, Double.zero,
        max(PB_net_min_cap, min(PB_nom_net_cap, hour4[hourDX + i] + hour4[hourDY + i] - hour1[hourBP + i])))
    }

    /// Corresponding max PB gross elec output
    let hourEA = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 {
      hour4[hourEA + i] = iff(
        hour4[hourDZ + i].isZero, Double.zero,
        hour4[hourDZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hour4[hourDZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourEB = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      hour4[hourEB + i] = iff(
        and(hour4[hourEA + i].isZero, hour4[hourEA + i + 1] > Double.zero),
        iff(
          (hour4[max(hourEA + i - 5, hourEA)...(hourEA + i)].reduce(0) { if $1.isZero { return $0+1 }; return $0 }) < PB_warm_start_duration, PB_hot_start_heat_req,PB_warm_start_heat_req), Double.zero)
    }
    let EBsum = hour4.sum(hours: daysBO, condition: hourEB)
    /// Max gross heat cons for ST
    let hourEC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 {
      hour4[hourEC + i] = iff(
        hour4[hourEA + i].isZero, Double.zero,
        hour4[hourEA + i] / PB_nom_gross_eff / POLY(hour4[hourEA + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let ECsum = hour4.sum(hours: daysBO, condition: hourEC)
    /// Max gross heat cons for extraction
    let hourED = 70080
    // IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN((DX6-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons,(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons)-$BQ6-MIN(El_boiler_cap_ud,MAX(0,DZ6+$BP6-DX6-DY6)*El_boiler_eff)))
    for i in 1..<8760 {
      if or(hour4[hourDV + i].isZero, hour1[hourBM + i] > Double.zero, PB_nom_gross_cap_ud <= Double.zero, BO_BFcount[i - 1].isZero) {
        hour4[hourED + i] = Double.zero
      } else {
        let stup_cons = iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_stup_cons[j])
        let heat_stup_cons = iff(hour1[hourBM + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])
        let minimum = min(
         (hour4[hourDX + i] - overall_fix_stby_cons[j] - stup_cons) / overall_var_max_cons[j] * overall_var_heat_max_cons[j],
          (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
        let ED = PB_Ratio_Heat_input_vs_output * max(Double.zero,
            minimum + overall_heat_fix_stby_cons[j] + heat_stup_cons - hour1[hourBQ + i]
              - min(El_boiler_cap_ud, max(Double.zero, hour4[hourDZ + i] + hour1[hourBP + i] - hour4[hourDX + i] - hour4[hourDY + i]) * El_boiler_eff))
        hour4[hourED + i] = ED
      } 
    }

    let EDsum = hour4.sum(hours: daysBO, condition: hourED)
    let ECEDsum = zip(ECsum, EDsum).map { $0 + $1 }
    /// TES energy available if above min op case
    let hourEE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 1..<8760 {
      hour4[hourEE + i] = iff(
        hour2[hourCC + i].isZero, Double.zero,
        min(AYsum[i-1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i-1] + ECEDsum[i-1]))
    }

    /// Effective gross heat cons for ST
    let hourEF = 87600
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*EC6)
    for i in 1..<8760 {
      hour4[hourEF + i] = iff(
        hour4[hourEE + i].isZero, Double.zero, (hour4[hourEE + i] - EBsum[i-1]) / (ECEDsum[i-1]) * hour4[hourEC + i])
    }

    /// Effective PB gross elec output
    let hourEG = 96360
    // IF(EF6=0,0,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))
    for i in 1..<8760 {
      hour4[hourEG + i] = iff(
        hour4[hourEF + i].isZero, Double.zero,
        hour4[hourEF + i] * PB_nom_gross_eff * POLY(hour4[hourEF + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourEH = 105120
    // IF(EG6=0,0,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 1..<8760 {
      hour4[hourEH + i] = iff(
        hour4[hourEG + i].isZero, Double.zero,
        hour4[hourEG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hour4[hourEG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourEI = 113880
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*ED6)
    for i in 1..<8760 {
      hour4[hourEI + i] = iff(
        hour4[hourEE + i].isZero, Double.zero, (hour4[hourEE + i] - EBsum[i-1]) / (ECEDsum[i-1]) * hour4[hourED + i])
    }

    /// TES energy to fulfil op case if above
    let hourEJ = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763),EE6,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))
    for i in 1..<8760 {
      hour4[hourEJ + i] = iff(
        min(AYsum[i-1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < EBsum[i-1] + ECEDsum[i-1],
        hour4[hourEE + i], EBsum[i-1] + ECEDsum[i-1])
    }

    /// Surplus TES energy due to op case
    let hourEK = 131400
    // IF(EJ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EJ6))
    for i in 1..<8760 {
      hour4[hourEK + i] = iff(
        hour4[hourEJ + i].isZero, Double.zero, max(Double.zero, AYsum[i-1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hour4[hourEJ + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourEL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 1..<8760 {
      hour4[hourEL + i] = iff(
        or(
          and(hour4[hourEK + i] > Double.zero, hour1[hourAY + i] > Double.zero, hour1[hourAY + i - 1].isZero),
          and(hour4[hourEK + i] > Double.zero, hour1[hourAY + i + 1].isZero, hour1[hourAY + i] > Double.zero)), hour1[hourAY + i], Double.zero)
    }
    let ELsum = hour4.sum(hours: daysBO, condition: hourEL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourEM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 1..<8760 {
      hour4[hourEM + i] = max(Double.zero, hour4[hourEK + i] - ELsum[i-1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourEN = 157680
    // IF(EK6=0;0;ROUND($AY6-(EK6-EM6)/(SUMIF($BO$5:$BO$8764;"="&$BO6;EL$5:EL$8764)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6;5))
    for i in 1..<8760 {
      hour4[hourEN + i] = iff(
        hour4[hourEK + i].isZero, Double.zero,
        round(hour1[hourAY + i] - (hour4[hourEK + i] - hour4[hourEM + i])
          / (ELsum[i-1] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour4[hourEL + i], 5))
      if hour4[hourEN + i] < 1 {
        hour4[hourEN + i] = 0
      }
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourEO = 166440
    let EN_BOcountNonZero = hour4.count(hours: daysBO, range: hourEN, predicate: {$0>0})
    let ENsum = hour4.sum(hours: daysBO, condition: hourEN)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 1..<8760 {
      let a = (hour1[hourAW + i] - hour4[hourEN + i])
            / (hour4[hourEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EN_BOcountNonZero[i-1])
      let b = (hour0[hourJ + i] - hour4[hourEN + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hour4[hourEM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i-1])
      let s = ENsum[i-1]
      hour4[hourEO + i] = iff(
        or(hour4[hourEN + i].isZero, hour4[hourEM + i].isZero), Double.zero,
        max(a ,b) / s * hour4[hourEN + i])
    }
    let EOsum = hour4.sum(hours: daysBO, condition: hourEO)
    /// corrected max possible PV elec to TES
    let hourEP = 175200
    // IF(EJ6=0,0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,EO5:EO8763)*EO6))
    for i in 1..<8760 {
      hour4[hourEP + i] = iff(
        hour4[hourEJ + i].isZero, Double.zero,
        hour4[hourEN + i]
          - iff(
            hour4[hourEM + i].isZero, Double.zero,
            hour4[hourEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i-1] * hour4[hourEO + i]))
    }

    /// Max possible CSP heat to TES
    let hourEQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 {
      hour4[hourEQ + i] = min(hour0[hourJ + i], hour4[hourEP + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourER = 192720
    /// Available heat from CSP after TES
    let hourES = 201480
    
    for i in 1..<8760 { 
      // MAX(0,L6-EP6)
      hour4[hourER + i] = max(Double.zero, hour0[hourL + i] - hour4[hourEP + i])
      // MAX(0,J6-EQ6)
      hour4[hourES + i] = max(Double.zero, hour0[hourJ + i] - hour4[hourEQ + i])
    }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourET = 210240
    // IF($J6>0,$J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+$M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(OR(EE6=0,AND(EH6=0,EB6=0)),PB_stby_aux_cons,0)+IF(AND(EE6>0,EB6>0),PB_stup_aux_cons+EB6*TES_aux_cons_perc,0)+IF(EH6>0,(EB6+EF6+EI6)*TES_aux_cons_perc,0)
    for i in 1..<8760 {
      hour4[hourET + i] =
        iff(hour0[hourJ + i] > Double.zero, hour0[hourJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hour0[hourM + i]
        + (hour4[hourEP + i] * Heater_eff + hour4[hourEQ + i]) * TES_aux_cons_perc
        + iff(or(hour4[hourEE + i].isZero, and(hour4[hourEH + i].isZero, hour4[hourEB + i].isZero)), PB_stby_aux_cons, Double.zero)
        + iff(and(hour4[hourEE + i] > Double.zero, hour4[hourEB + i] > Double.zero), PB_stup_aux_cons + hour4[hourEB + i] * TES_aux_cons_perc, Double.zero)
        + iff(hour4[hourEH + i] > Double.zero, (hour4[hourEB + i] + hour4[hourEF + i] + hour4[hourEI + i]) * TES_aux_cons_perc, Double.zero)
    }

    /// Not covered aux elec MWel
    let hourEU = 219000
    // =MAX(0,-(L6+EH6-EP6-ET6))
    for i in 1..<8760 {
      hour4[hourEU + i] = max(
        Double.zero,
        -(hour0[hourL + i] + hour4[hourEH + i] - hour4[hourEP + i] - hour4[hourET + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourEW = 227760
    // IF(MIN(MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-MIN(El_boiler_cap_ud;MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff));MAX(0;ES6+MIN(El_boiler_cap_ud;MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons))*El_boiler_eff-Overall_heat_fix_cons)/Overall_harmonious_var_heat_max_cons*Overall_harmonious_var_max_cons+Overall_fix_cons)<Overall_harmonious_var_min_cons+Overall_fix_cons;0;Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 1..<8760 {
      hour4[hourEW + i] = iff(
        min(
          max(Double.zero,
            hour4[hourER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[hourET + i]
            - min(El_boiler_cap_ud, max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[hourES + i])/El_boiler_eff)),
          max(Double.zero,
            hour4[hourES + i] + min(El_boiler_cap_ud, max(Double.zero, hour4[hourER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - hour4[hourET + i] - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff
              - Overall_heat_fix_cons) / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons)
        < Overall_harmonious_var_min_cons + Overall_fix_cons, Double.zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourEX = 236520
    // IF(OR(AND(EW6>0,EW5=0,EW7=0),AND(EW6>0,OR(AND(EW4=0,EW5=0,EW8=0),AND(EW4=0,EW7=0,EW8=0)))),0,EW6)
    for i in 1..<8760 {
      hour4[hourEX + i] = iff(
        or(
          and(hour4[hourEW + i] > Double.zero, hour4[hourEW + i - 1].isZero, hour4[hourEW + i + 1].isZero),
          and(
            hour4[hourEW + i] > Double.zero,
            or(
              and(hour4[hourEW + i - 2].isZero, hour4[hourEW + i - 1].isZero, hour4[hourEW + i + 2].isZero),
              and(hour4[hourEW + i - 2].isZero, hour4[hourEW + i + 1].isZero, hour4[hourEW + i + 2].isZero)))), 0, hour4[hourEW + i])
    }

    /// Min harmonious net heat cons
    let hourEY = 245280
    // MAX(0,(EX6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 1..<8760 {
      hour4[hourEY + i] = iff(hour4[hourEX + i].isZero, Double.zero,
        max(Double.zero, (hour4[hourEX + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons 
        * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
    }

    /// Harmonious op day
    let hourEZ = 254040
    // =IF(OR(AND(EX5<=0,EX6>0,SUM(EX$1:EX5)=0),AND($F5<=0,$F6>0,SUM(EX$1:EX16)=0)),IF(EZ5<364,EZ5+1,0),EZ5)
    let hourF = 0
    for i in 2..<8760 {
      let start = max(hourEX + i - 10, hourEX)
      let end = max(min(hourEX + i - 1, hourEX+1), start+1)
      hour4[hourEZ + i] = iff(
        or(
          and(hour4[hourEX + i - 1] <= 0, hour4[hourEX + i] > 0,
              hour4[start..<end].reduce(0, +).isZero),
          and(hour0[hourF + i - 1] <= 0, hour0[hourF + i] > 0,
              hour4[start..<min(hourEX + i + 10, hourEY)].reduce(0, +).isZero)),
        iff(hour4[hourEZ + i - 1] < 364, hour4[hourEZ + i - 1] + 1, 0), hour4[hourEZ + i - 1])
    }

    /// El cons due to op outside of harm op period
    let hourFA = 262800
    // IF(OR(EX6>0;EJ6=0;MIN(MAX(0;Grid_import_max_ud*Grid_import_yes_no_PB_strategy+EH6+ER6-ET6-EX6-MIN(El_boiler_cap_ud;MAX(0;MIN((DX6-A_overall_fix_stby_cons-IF(EX7=0;0;A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons;(A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EX7=0;0;A_overall_heat_stup_cons)+EY6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff));MAX(0;MIN(El_boiler_cap_ud;Grid_import_max_ud*Grid_import_yes_no_PB_strategy+EH6+ER6-ET6-EX6)*El_boiler_eff+ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-IF(EX7=0;0;A_overall_heat_stup_cons)-A_overall_heat_fix_stby_cons)/((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)*((A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons))<A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons));0;MIN(DX6;(A_overall_var_max_cons-A_overall_var_min_cons)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons+A_overall_fix_stby_cons+IF(EX7=0;0;A_overall_stup_cons)))
    for i in 1..<8760 {
      hour4[hourFA + i] = iff(hour4[hourDV + i].isZero, Double.zero, iff(
        or(hour4[hourEX + i] > Double.zero, hour4[hourEJ + i].isZero, min(
          max(Double.zero, Grid_import_max_ud * Grid_import_yes_no_PB_strategy
          + hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourEX + i]
          - min(El_boiler_cap_ud, max(Double.zero, min((hour4[hourDX + i] - overall_fix_stby_cons[j]
            - iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_stup_cons[j]))
            / overall_var_max_cons[j] * overall_var_heat_max_cons[j],          
          (overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])
                + hour4[hourEY + i] - hour4[hourES + i] - hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)),
          max(Double.zero, min(El_boiler_cap_ud, Grid_import_max_ud * Grid_import_yes_no_PB_strategy
          + hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourEX + i]) * El_boiler_eff
          + hour4[hourES + i] + hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output - hour4[hourEY + i]
          - iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - overall_heat_fix_stby_cons[j])
          / ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
          * ((overall_var_max_cons[j] - overall_var_min_cons[j])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
            + iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_stup_cons[j])) < overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_stup_cons[j])),
          Double.zero, min(hour4[hourDX + i], (overall_var_max_cons[j] - overall_var_min_cons[j])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (hour4[hourDV + i] - equiv_harmonious_min_perc[j]) + overall_var_min_cons[j] + overall_fix_stby_cons[j]
          + iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_stup_cons[j]))))
    }

    /// heat cons due to op outside of harm op period
    let hourFB = 271560
    // IF(FA5=0;0;MAX(0;(FA5-A_overall_fix_stby_cons-IF(EX6=0;0;A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF(EX6=0;0;A_overall_heat_stup_cons)))
    for i in 1..<8760 {
      hour4[hourFB + i] = iff(
        hour4[hourFA + i].isZero, Double.zero,
          max(Double.zero, (hour4[hourFA + i] - overall_fix_stby_cons[j]
            - iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_stup_cons[j]))
            / overall_var_max_cons[j] * overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]
            + iff(hour4[hourEX + i + 1].isZero, Double.zero, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourFC = 280320
    // MAX(0,EH6+ER6-ET6-EX6-FA6-min(El_boiler_cap_ud;MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour4[hourFC + i] = max(
        Double.zero,
        round(hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourEX + i]
          - hour4[hourFA + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour4[hourEY + i] + hour4[hourFB + i] - hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output
              - hour4[hourES + i]) / El_boiler_eff)),5))
    }

    /// Remaining heat after min harmonious
    let hourFD = 289080
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 1..<8760 {
      hour4[hourFD + i] = max(
        Double.zero,
        round(hour4[hourES + i] + hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output - hour4[hourEY + i]
          - hour4[hourFB + i],5))
    }

    /// Grid import necessary for min harm
    let hourFE = 297840
    // MAX(0;-(EH6+ER6-ET6-EX6-FA6-MIN(El_boiler_cap_ud;MAX(0;(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour4[hourFE + i] = max(
        Double.zero,
        round(-(hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourEX + i] - hour4[hourFA + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour4[hourEY + i] + hour4[hourFB + i] - hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output
              - hour4[hourES + i]) / El_boiler_eff))),5))
    }

    /// Remaining grid import capacity after min harm
    let hourFF = 306600
    // Grid_import_max_ud-FE6
    for i in 1..<8760 { hour4[hourFF + i] = max(Double.zero, round(Grid_import_max_ud - hour4[hourFE + i],5)) }

    /// El boiler op after min harmonious heat cons
    let hourFG = 315360
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 {
      hour4[hourFG + i] = min(
        El_boiler_cap_ud,
        max(
          Double.zero,
          round((hour4[hourEY + i] + hour4[hourFB + i] - hour4[hourES + i] - hour4[hourEI + i]
            / PB_Ratio_Heat_input_vs_output),5) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourFH = 324120
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 1..<8760 { hour4[hourFH + i] = max(Double.zero, round(El_boiler_cap_ud - hour4[hourFG + i],5)) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourFI = 332880
    /// Remaining CCU cap after min harmonious cons
    let hourFJ = 341640
    /// Remaining EY cap after min harmonious cons
    let hourFK = 350400

    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      let fraction =
        (max(Double.zero, hour4[hourEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      
      hour4[hourFI + i] =
        max(Double.zero,1
          - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud

    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    
      hour4[hourFJ + i] =
        max(Double.zero,1
          - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    
      hour4[hourFK + i] =
        max(Double.zero,1
          - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourFL = 359160
    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourFM = 367920
    
    for i in 1..<8760 { 
      // MIN(BESS_chrg_max_cons,FC6)
      hour4[hourFL + i] = min(BESS_chrg_max_cons, hour4[hourFC + i])
      // MIN(Grid_export_max_ud,FC6)
      hour4[hourFM + i] = min(Grid_export_max_ud, hour4[hourFC + i])
    }

    /// Max harmonious net elec cons
    let hourFN = 376680
    // IF(EW6=0;0;Overall_fix_cons+Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN(1;MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons-MAX(0;Overall_harmonious_var_heat_min_cons+Overall_heat_fix_cons-ES6)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff);MAX(0;ES6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons+MAX(0;ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-ET6-Overall_harmonious_var_min_cons-Overall_fix_cons)*El_boiler_eff)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*El_boiler_eff);MAX(0;ES6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)))
    for i in 1..<8760 {
      hour4[hourFN + i] = iff(
        hour4[hourEW + i].isZero, Double.zero,
        Overall_fix_cons + Overall_harmonious_var_min_cons + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
          * min(1,
              max(Double.zero,
                hour4[hourER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[hourET + i]
                  - Overall_harmonious_var_min_cons - Overall_fix_cons - max(
                    Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour4[hourES + i]) / El_boiler_eff)
                  / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons
                    + (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons) / El_boiler_eff),
                max(Double.zero,
                hour4[hourES + i] - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons
                + max(Double.zero, hour4[hourER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - hour4[hourET + i]
                  - Overall_harmonious_var_min_cons - Overall_fix_cons) * El_boiler_eff)
                  / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons
                  + (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons) * El_boiler_eff),
                max(Double.zero, hour4[hourES + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
                  / (Overall_harmonious_var_heat_max_cons - Overall_harmonious_var_heat_min_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourFO = 385440
    // IF(OR(AND(FN6>0;FN5=0;FN7=0);AND(FN6>0;OR(AND(FN4=0;FN5=0;FN8=0);AND(FN4=0;FN7=0;FN8=0))));0;FN6)
    for i in 1..<8760 {
      hour4[hourFO + i] = iff(
        or(
          and(hour4[hourFN + i] > Double.zero, hour4[hourFN + i - 1].isZero, hour4[hourFN + i + 1].isZero),
          and(
            hour4[hourFN + i] > Double.zero,
            or(
              and(hour4[hourFN + i - 2].isZero, hour4[hourFN + i - 1].isZero, hour4[hourFN + i + 2].isZero),
              and(hour4[hourFN + i - 2].isZero, hour4[hourFN + i + 1].isZero, hour4[hourFN + i + 2].isZero)))), 0, hour4[hourFN + i])
    }

    /// max harmonious net heat cons
    let hourFP = 394200
    // MAX(0;(FO6-Overall_fix_cons)/Overall_harmonious_var_max_cons*Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)

    for i in 1..<8760 {
      hour4[hourFP + i] = iff(hour4[hourFO + i].isZero, Double.zero,
        max(Double.zero, (hour4[hourFO + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons 
        * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
    }

    /// Remaining el after max harmonious
    let hourFQ = 402960
    // MAX(0,EH6+ER6-ET6-FO6-FA6-MIN(El_boiler_cap_ud;MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour4[hourFQ + i] = max(
        Double.zero,
        round(hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourFO + i]
          - hour4[hourFA + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour4[hourFP + i] + hour4[hourFB + i] - hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output
              - hour4[hourES + i]) / El_boiler_eff)),5))
    }

    /// Remaining heat after max harmonious
    let hourFR = 411720
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 1..<8760 {
      hour4[hourFR + i] = max(
        Double.zero,
        round(hour4[hourES + i] + hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output - hour4[hourFP + i]
          - hour4[hourFB + i],5))
    }

    /// Grid import necessary for max harm
    let hourFS = 420480
    // MAX(0,-(EH6+ER6-ET6-FO6-FA6-min(El_boiler_cap_ud;MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour4[hourFS + i] = max(
        Double.zero,
        round(-(hour4[hourEH + i] + hour4[hourER + i] - hour4[hourET + i] - hour4[hourFO + i]
          - hour4[hourFA + i]
          - min(El_boiler_cap_ud, max(
            Double.zero,
            (hour4[hourFP + i] + hour4[hourFB + i] - hour4[hourEI + i] / PB_Ratio_Heat_input_vs_output
              - hour4[hourES + i]) / El_boiler_eff))),5))
    }

    /// Remaining grid import capacity after max harm
    let hourFT = 429240
    // MAX(0;Grid_import_max_ud-FS6)
    for i in 1..<8760 { hour4[hourFT + i] = max(Double.zero, round(Grid_import_max_ud - hour4[hourFS + i],5)) }

    /// El boiler op after max harmonious heat cons
    let hourFU = 438000
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 1..<8760 {
      hour4[hourFU + i] = min(
        El_boiler_cap_ud,
        max(
          Double.zero,
          round((hour4[hourFP + i] + hour4[hourFB + i] - hour4[hourES + i] - hour4[hourEI + i]
            / PB_Ratio_Heat_input_vs_output),5) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourFV = 446760
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 1..<8760 { hour4[hourFV + i] = max(Double.zero, round(El_boiler_cap_ud - hour4[hourFU + i],5)) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourFW = 455520
    /// Remaining CCU cap after max harmonious cons
    let hourFX = 464280
    /// Remaining EY cap after max harmonious cons
    let hourFY = 473040
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 1..<8760 {
      let fraction =
        (max(Double.zero, hour4[hourFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour4[hourFW + i] =
        max(Double.zero,1
          - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
    
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour4[hourFX + i] =
        max(Double.zero,1
          - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc))
        * CCU_C_O_2_nom_prod_ud
    
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour4[hourFY + i] =
        max(Double.zero,1
          - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc))
        * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourFZ = 481800
    /// Max grid export after TES chrg, min harm, night and aux el cons
    let hourGA = 490560
    
    for i in 1..<8760 { 
      // MIN(BESS_chrg_max_cons,FQ6)
      hour4[hourFZ + i] = min(BESS_chrg_max_cons, hour4[hourFQ + i])
      // MIN(Grid_export_max_ud,FQ6)
      hour4[hourGA + i] = min(Grid_export_max_ud, hour4[hourFQ + i])
    }
  }
}
