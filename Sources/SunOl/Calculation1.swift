extension TunOl {
  mutating func hour2(j: Int, hour0: [Double], hour1: [Double]) -> [Double] {
    let (hourJ, hourL, hourM, hourAW, hourBK, hourBM, hourBO, hourBP, hourBQ) = (26280, 43800, 52560, 8760, 131400, 148920, 166440, 175200, 183960)
    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }
    let daysBO: [[Int]] = hour1[hourBO..<(hourBO + 8760)].indices.chunked(by: { hour1[$0] == hour1[$1] }).map { $0.map { $0 - hourBO } }
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
    let hourBF = 87600
    let BO_BFcount = hour1.count(hours: daysBO, range: hourBF, predicate: {$0>0})
    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourBW = 17520
    // IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,$BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+$BK6-$BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(BV6+$BK6-$BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,BV6+$BK6-$BP6))-PB_net_min_cap))+MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons-$BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(BV6=0,BV7>0),MAX(0,IF(COUNTIF(BV$1:BV6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-$BQ6)*TES_aux_cons_perc,0))
    for i in 1..<8760 {
      hour2[hourBW + i] = iff(
        or(hour1[hourBM + i] > 0, PB_nom_gross_cap_ud <= 0, BO_BFcount[i].isZero), 0,
        hour1[hourBK + i]
          + ((min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * (hour2[hourBQ + i] + hour1[hourBK + i] - hour1[hourBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(PB_nom_net_cap, max(PB_net_min_cap, (1 + TES_aux_cons_perc) * (hour2[hourBQ + i] + hour1[hourBK + i] - hour1[hourBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(0, hour2[hourBQ + i] + hour1[hourBK + i] - hour1[hourBP + i])) - PB_net_min_cap))
            + max(0, overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] - hour1[hourBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hour2[hourBQ + i].isZero, hour2[hourBV + i + 1] > 0),
            max(
              0,
              iff(
                (hour2[min(hourBV + i - 6, hourBV + i)...(hourBV + i)].reduce(0.0) { if $1.isZero { return $0+1 }; return $0 }) == PB_warm_start_duration,
                PB_warm_start_heat_req, PB_hot_start_heat_req) - hour1[hourBQ + i]) * TES_aux_cons_perc, 0))
    }

    /// Corresponding min PB net elec output
    let hourBX = 26280
    // IF(BV6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,BV6+BW6-BP6)))
    for i in 1..<8760 {
      hour2[hourBX + i] = iff(
        hour2[hourBV + i].isZero, Double.zero, max(PB_net_min_cap, min(PB_nom_net_cap, hour2[hourBV + i] + hour2[hourBW + i] - hour1[hourBP + i])))
    }

    /// Corresponding min PB gross elec output
    let hourBY = 35040
    // IF(BX6=0,0,BX6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(BX6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 1..<8760 {
      hour2[hourBY + i] = iff(
        hour2[hourBX + i].isZero, Double.zero,
        hour2[hourBX + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net * POLY(hour2[hourBX + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff)
          + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourBZ = 43800
    // IF(AND(BY6=0,BY7>0),IF(COUNTIF(BY1:BY6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 1..<8760 {
      hour2[hourBZ + i] = iff(
        and(hour2[hourBY + i].isZero, hour2[hourBY + i + 1] > Double.zero),
        iff((hour2[min(hourBY + i - 6, hourBY + i)...(hourBY + i)].reduce(0.0) { if $1.isZero { return $0+1 }; return $0 }) == PB_warm_start_duration, PB_warm_start_heat_req, PB_hot_start_heat_req),
        Double.zero)
    }

    let BZsum = hour2.sum(hours: daysBO, condition: hourBZ)
    /// Min gross heat cons for ST
    let hourCA = 52560
    // IF(BY6=0,0,BY6/PB_nom_gross_eff/POLY(BY6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 1..<8760 {
      hour2[hourCA + i] = iff(
        hour2[hourBY + i].isZero, Double.zero, hour2[hourBY + i] / PB_nom_gross_eff / POLY(hour2[hourBY + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let CAsum = hour2.sum(hours: daysBO, condition: hourCA)
    /// Min gross heat cons for extraction
    let hourCB = 61320
    // =IF(OR($BM6>0,PB_nom_gross_cap_ud<=0,COUNTIFS($BO$5:$BO$8763,"="&$BO6,$BF$5:$BF$8763,">0")=0),0,PB_Ratio_Heat_input_vs_output*MAX(0,MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons),(BX6-BW6+$BP6-A_overall_fix_stby_cons-IF($BM7=0,0,A_overall_stup_cons))/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF($BM7=0,0,A_overall_heat_stup_cons))-$BQ6-MIN(El_boiler_cap_ud,MAX(0,BX6-BV6-BW6)*El_boiler_eff)))
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
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763),0,SUMIF(BO5:BO8763,"="BO6,BZ5:BZ8763)+SUMIF(BO5:BO8763,"="BO6,CA5:CA8763)+SUMIF(BO5:BO8763,"="BO6,CB5:CB8763))
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
    for i in 1..<8760 { hour2[hourCF + i] = max(Double.zero, hour2[hourCD + i] - CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) }

    /// intermediate resulting PV elec to TES
    let hourCG = 105120
    // IF(CD6=0,0,AY6-(CD6-CF6)/(SUMIF(BO5:BO8763,"="BO6,CE5:CE8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*CE6)
    for i in 1..<8760 {
      hour2[hourCG + i] = iff(
        hour2[hourCD + i].isZero, Double.zero,
        hour1[hourAY + i] - (hour2[hourCD + i] - hour2[hourCF + i]) / (CEsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hour2[hourCE + i])
    }

    let CG_BOcountNonZero = hour2.count(hours: daysBO, range: hourCG, predicate: { $0 > 0 })
    let CGsum = hour2.sum(days: daysBO, range: hourCG)
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourCH = 113880
    // IF(OR(CG6=0,CF6=0),0,MAX((AW6-CG6)/(CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")),(J6-CG6*Heater_eff/Ratio_CSP_vs_Heater)/(CF6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,CG5:CG8763,">0")))/SUMIF(BO5:BO8763,"="BO6,CG5:CG8763)*CG6)
    for i in 1..<8760 {
      hour2[hourCH + i] = iff(
        or(hour2[hourCG + i].isZero, hour2[hourCF + i].isZero), Double.zero,
        max(
          (hour1[hourAW + i] - hour2[hourCG + i]) / (hour2[hourCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CG_BOcountNonZero[i]),
          (hour0[hourJ + i] - hour2[hourCG + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hour2[hourCF + i] / (1 + Ratio_CSP_vs_Heater) / CG_BOcountNonZero[i])) / CGsum[i] * hour2[hourCG + i])
    }
    let CHsum = hour2.sum(hours: daysBO, condition: hourCH)
    /// corrected max possible PV elec to TES
    let hourCI = 122640
    // IF(CC6=0,0,CG6-IF(CF6=0,0,CF6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,CH5:CH8763)*CH6))
    for i in 1..<8760 {
      hour2[hourCI + i] = iff(
        hour2[hourCC + i].isZero, Double.zero,
        hour2[hourCG + i]
          - iff(hour2[hourCF + i].isZero, Double.zero, hour2[hourCF + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / CHsum[i] * hour2[hourCH + i])
      )
    }

    /// Max possible CSP heat to TES
    let hourCJ = 131400
    // MIN(J6,CI6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 1..<8760 { hour2[hourCJ + i] = min(hour0[hourJ + i], hour2[hourCI + i] * Heater_eff / Ratio_CSP_vs_Heater) }

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
        + iff(
          and(hour2[hourCC + i] > Double.zero, hour2[hourBZ + i] > Double.zero), PB_stup_aux_cons + hour2[hourBZ + i] * TES_aux_cons_perc,
          Double.zero)
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
        -(hour0[hourL + i] + iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) - hour2[hourCI + i] - hour2[hourCM + i]))
    }
    return hour2
  }

  mutating func hour3(j: Int, hour0: [Double], hour1: [Double], hour2: [Double]) -> [Double] {
    let (hourBX, hourCB, hourCC, hourCK, hourCL, hourCM, hourCN) = (26280, 61320, 70080, 140160, 148920, 157680, 166440)
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
              - min(
                El_boiler_cap_ud, max(Double.zero, Overall_harmonious_var_heat_min_cons + Overall_heat_fix_cons - hour2[hourCL + i]) / El_boiler_eff)
          ),
          max(
            Double.zero,
            hour2[hourCL + i] + min(
              El_boiler_cap_ud,
              max(
                Double.zero,
                hour2[hourCK + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy - (hour2[hourCM + i] - hour2[hourCN + i])
                  - Overall_harmonious_var_min_cons - Overall_fix_cons)) * El_boiler_eff - Overall_heat_fix_cons)
            / Overall_harmonious_var_heat_max_cons * Overall_harmonious_var_max_cons + Overall_fix_cons) < Overall_harmonious_var_min_cons
          + Overall_fix_cons, Double.zero, Overall_harmonious_var_min_cons + Overall_fix_cons)
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
      hour3[hourCR + i] = max(
        Double.zero,
        (hour3[hourCQ + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }
    let hourF = 0
    /// Harmonious op day
    let hourCS = 26280
    // IF(OR(AND(CQ5<=0,CQ6>0,SUM(CQ$1:CQ5)=0),AND($F5<=0,$F6>0,SUM(CQ$1:CQ16)=0)),IF(CS5<364,CS5+1,0),CS5)
    for i in 2..<8760 {
      hour3[hourCS + i] = iff(
        or(
          and(hour3[hourCQ + i - 1] <= 0, hour3[hourCQ + i] > 0, hour3[max(hourCQ + i - 10, hourCQ)..<min(hourCQ + i - 1, hourCR)].reduce(0, +).isZero),
          and(hour0[hourF + i - 1] <= 0, hour0[hourF + i] > 0, hour3[max(hourCQ + i - 10, hourCQ)..<min(hourCQ + i + 10, hourCR)].reduce(0, +).isZero)),
        iff(hour3[hourCS + i - 1] < 364, hour3[hourCS + i - 1] + 1, 0), hour3[hourCS + i - 1])
    }

    /// El cons due to op outside of harm op period
    let hourCT = 35040
    // =IF(OR(CQ6>0,CC6=0),0,MIN(A_overall_var_min_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons),MAX(0,BX6+CK6-(CM6-CN6)-CQ6-MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)+CR6-CL6-CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff)),MAX(0,MIN(El_boiler_cap_ud,BX6+CK6-(CM6-CN6)-CQ6)*El_boiler_eff+CL6+CB6/PB_Ratio_Heat_input_vs_output-CR6-IF(CQ7=0,0,A_overall_heat_stup_cons)-A_overall_heat_fix_stby_cons)/A_overall_var_heat_max_cons*A_overall_var_max_cons+A_overall_fix_stby_cons+IF(CQ7=0,0,A_overall_stup_cons)))
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
          min(El_boiler_cap_ud, hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i]) * El_boiler_eff
            + hour2[hourCL + i] + hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output - hour3[hourCR + i]
            - iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_heat_stup_cons[j]) - overall_heat_fix_stby_cons[j])
        / overall_var_heat_max_cons[j] * overall_var_max_cons[j] + overall_fix_stby_cons[j]
        + iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_stup_cons[j])
      hour3[hourCT + i] = iff(
        or(hour3[hourCQ + i] > Double.zero, hour2[hourCC + i].isZero), Double.zero,
        min(overall_var_min_cons[j] + overall_fix_stby_cons[j] + iff(hour3[hourCQ + i + 1].isZero, Double.zero, overall_stup_cons[j]), a, b))
    }

    /// heat cons due to op outside of harm op period
    let hourCU = 43800
    // IF(CT6=0,0,MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CR7=0,0,A_overall_heat_stup_cons),MAX(0,MIN(El_boiler_cap_ud,BX6+CK6-(CM6-CN6)-CQ6)*El_boiler_eff+CL6+CB6/PB_Ratio_Heat_input_vs_output-CR6),MAX(0,BX6+CK6-(CM6-CN6)-CQ6-MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)+CR6-CL6-CB6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff)-IF(CQ7=0,0,A_overall_stup_cons)-A_overall_fix_stby_cons)/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF(CQ7=0,0,A_overall_heat_stup_cons)))
    for i in 1..<8760 {
      hour3[hourCU + i] = iff(
        hour3[hourCT + i].isZero, Double.zero,
        min(
          overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour3[hourCR + i + 1].isZero, 0, overall_heat_stup_cons[j]),
          max(
            Double.zero,
            min(El_boiler_cap_ud, hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i])
              * El_boiler_eff + hour2[hourCL + i] + hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output - hour3[hourCR + i]),
          max(
            Double.zero,
            hour2[hourBX + i] + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i]) - hour3[hourCQ + i]
              - min(
                El_boiler_cap_ud,
                max(
                  Double.zero,
                  overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour3[hourCQ + i + 1].isZero, 0, overall_heat_stup_cons[j])
                    + hour3[hourCR + i] - hour2[hourCL + i] - hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff)
              - iff(hour3[hourCQ + i + 1].isZero, 0, overall_stup_cons[j]) - overall_fix_stby_cons[j]) / overall_var_max_cons[j]
            * overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j] + iff(hour3[hourCQ + i + 1].isZero, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourCV = 52560
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourCV + i] = max(
        Double.zero,
        iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i])
          - hour3[hourCQ + i] - hour3[hourCT + i]
          - min(
            El_boiler_cap_ud,
            max(
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
        hour2[hourCL + i] + iff(hour2[hourCC + i].isZero, Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output) - hour3[hourCR + i]
          - hour3[hourCU + i])
    }

    /// Grid import necessary for min harm
    let hourCX = 70080
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-CQ6-CT6-MIN(El_boiler_cap_ud,MAX(0,(CR6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff))))
    for i in 1..<8760 {
      hour3[hourCX + i] = max(
        Double.zero,
        -(iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i])
          - hour3[hourCQ + i] - hour3[hourCT + i]
          - min(
            El_boiler_cap_ud,
            max(
              Double.zero,
              (hour3[hourCR + i] + hour3[hourCU + i]
                - iff(hour2[hourCC + i] > Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output, Double.zero) - hour2[hourCL + i])
                / El_boiler_eff))))
    }

    /// Remaining grid import capacity after min harm
    let hourCY = 78840
    // MAX(0;Grid_import_max_ud-CX6)
    for i in 1..<8760 { hour3[hourCY + i] = max(Double.zero, Grid_import_max_ud - hour3[hourCX + i]) }

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
    /// Remaining CCU cap after min harmonious cons
    let hourDC = 113880
    /// Remaining EY cap after min harmonious cons
    let hourDD = 122640

    for i in 1..<8760 {
      // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction =
        (max(Double.zero, hour3[hourCQ + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour3[hourDB + i] =
        max(Double.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
      // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour3[hourDC + i] =
        max(Double.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
      // MAX(0,1-((MAX(0,CQ6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour3[hourDD + i] =
        max(Double.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
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
    //  IF(CP6=0,0,Overall_fix_cons+MIN(Overall_harmonious_var_max_cons,Overall_harmonious_var_min_cons+(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*MIN((CK6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(CM6-CN6)-Overall_harmonious_var_min_cons-Overall_fix_cons+MAX(0,CL6-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/El_boiler_eff)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons+(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons)/El_boiler_eff),(CL6+El_boiler_cap_ud*El_boiler_eff-Overall_harmonious_var_heat_min_cons-Overall_heat_fix_cons)/(Overall_harmonious_var_heat_max_cons-Overall_harmonious_var_heat_min_cons))))
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
                (hour2[hourCL + i] + El_boiler_cap_ud * El_boiler_eff - Overall_harmonious_var_heat_min_cons - Overall_heat_fix_cons)
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
      hour3[hourDI + i] = max(
        Double.zero,
        (hour3[hourDH + i] - Overall_fix_cons) / Overall_harmonious_var_max_cons * Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourDJ = 175200
    // MAX(0,IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MIN(El_boiler_cap_ud,MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourDJ + i] = max(
        Double.zero,
        iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i])
          - hour3[hourDH + i] - hour3[hourCT + i]
          - min(
            El_boiler_cap_ud,
            max(
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
        hour2[hourCL + i] + iff(hour2[hourCC + i].isZero, Double.zero, hour2[hourCB + i] / PB_Ratio_Heat_input_vs_output) - hour0[hourDI + i]
          - hour3[hourCU + i])
    }

    /// Grid import necessary for max harm
    let hourDL = 192720
    // MAX(0,-(IF(CC6>0,BX6,0)+CK6-(CM6-CN6)-DH6-CT6-MAX(0,(DI6+CU6-IF(CC6>0,CB6/PB_Ratio_Heat_input_vs_output,0)-CL6)/El_boiler_eff)))
    for i in 1..<8760 {
      hour3[hourDL + i] = max(
        Double.zero,
        -(iff(hour2[hourCC + i] > Double.zero, hour2[hourBX + i], Double.zero) + hour2[hourCK + i] - (hour2[hourCM + i] - hour2[hourCN + i])
          - hour3[hourDH + i] - hour3[hourCT + i]
          - min(
            El_boiler_cap_ud,
            max(
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

    for i in 1..<8760 {
      /// Remaining MethSynt cap after max harmonious cons
      let hourDP = 227760
      /// Remaining CCU cap after max harmonious cons
      let hourDQ = 236520
      /// Remaining EY cap after max harmonious cons
      let hourDR = 245280

      // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
      let fraction =
        (max(Double.zero, hour3[hourDH + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
        / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
      hour3[hourDP + i] =
        max(Double.zero, 1 - (fraction * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud

      // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
      hour3[hourDQ + i] =
        max(Double.zero, 1 - (fraction * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud

      // MAX(0,1-((MAX(0,DH6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
      hour3[hourDR + i] =
        max(Double.zero, 1 - (fraction * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
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