extension TunOl {
  mutating func hourly4(j: Int, daily11: [Double], hourly0: [Double], hourly1: [Double], hourly2: [Double]) -> [Double] {

    let hourlyJ = 26280
    let hourlyL = 43800
    let hourlyM = 52560
    let hourlyAW = 8760
    let hourlyBK = 131400
    let hourlyBM = 148920
    let hourlyBP = 175200
    let hourlyBQ = 183960
    let hourlyCC = 70080
    var hourly4 = [Double]()
    let hourlyBO = 166440
    let daysBO: [[Int]] = hourly1[hourlyBO..<(hourlyBO + 8760)].indices.chunked(by: { hourly1[$0] == hourly1[$1] })
      .map { $0.map { $0 - hourlyBO } }
    let daysD: [[Int]] = (0..<365).map { Array(repeating: $0, count: 24) }
    let hourlyAY = 26280
    let AYsum = hourly1.sum(hours: daysD, condition: hourlyAY)
    /// Maximum night op perc considering tank sizes
    let hourlyDV = 0
    let daily1R = 5475
    let hourly = daysBO.indices.map { day -> [Double] in        
      let value = daily11[(day + daily1R)]
      return [Double](repeating: value, count: daysBO[day].count)
    }.joined()
    // VLOOKUP(BO6,DailyCalc_1A3:R367,COLUMN(DailyCalc_1R3))
    hourly4.replaceSubrange(0..<8760, with: hourly)

    /// Max net elec demand outside harm op period
    let hourlyDW = 8760
    // IF(BM6>0,0,IF(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+BK6+IF(BM7=0,0,A_overall_stup_cons)+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)-BQ6)/El_boiler_eff<BP6-PB_stby_aux_cons,0,((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyDW + i] = iff(
        hourly1[hourlyBM + i] > 0, 0,
        iff(
          ((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + hourly1[hourlyBK + i]
            + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]) + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])
                - hourly1[hourlyBQ + i]) / El_boiler_eff < hourly1[hourlyBP + i] - PB_stby_aux_cons, 0,
          ((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j])))
    }

    /// Optimized max net elec demand outside harm op period
    let hourlyDX = 17520
    // IF(AND(DW7>0,DW6=0,DW5>0),DW5,DW6)
    for i in 0..<8760 {
      hourly4[hourlyDX + i] = iff(
        and(hourly4[hourlyDW + i] > 0, hourly4[hourlyDW + i].isZero, hourly4[hourlyDW + i - 1] > 0), hourly4[hourlyDW + i - 1],
        hourly4[hourlyDW + i])
    }

    /// Outside harm op aux elec for TES dischrg, CSP SF and PV Plant MWel
    let hourlyDY = 26280
    // IF(DX6=0,0,BK6+((MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(MIN(PB_nom_net_cap,MAX(PB_net_min_cap,(1+TES_aux_cons_perc)*(DX6+BK6-BP6)))/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)/(PB_gross_min_eff+(PB_nom_gross_eff-PB_gross_min_eff)/(PB_nom_net_cap-PB_net_min_cap)*(MIN(PB_nom_net_cap,MAX(0,DX6+BK6-BP6))-PB_net_min_cap))+MAX(0,((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons-BQ6)*PB_Ratio_Heat_input_vs_output)*TES_aux_cons_perc+IF(AND(DX6=0,DX7>0),MAX(0,IF(COUNTIF(DX1:DX6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req)-BQ6)*TES_aux_cons_perc,0))
    for i in 0..<8760 {
      hourly4[hourlyDY + i] = iff(
        hourly0[hourlyDX + i].isZero, 0,
        hourly1[hourlyBK + i]
          + ((min(
            PB_nom_net_cap,
            max(
              PB_net_min_cap, (1 + TES_aux_cons_perc) * (hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
            + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
            * POLY(
              min(
                PB_nom_net_cap,
                max(
                  PB_net_min_cap,
                  (1 + TES_aux_cons_perc) * (hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i])))
                / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
            / (PB_gross_min_eff
              + (PB_nom_gross_eff - PB_gross_min_eff) / (PB_nom_net_cap - PB_net_min_cap)
                * (min(PB_nom_net_cap, max(0, hourly0[hourlyDX + i] + hourly1[hourlyBK + i] - hourly1[hourlyBP + i]))
                  - PB_net_min_cap))
            + max(
              0,
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] - hourly1[hourlyBQ + i]) * PB_Ratio_Heat_input_vs_output) * TES_aux_cons_perc
          + iff(
            and(hourly0[hourlyDX + i].isZero, hourly0[hourlyDX + i] > 0),
            max(
              0,
              iff(
                countiff(hourly0[(hourlyDX + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
                PB_hot_start_heat_req) - hourly1[hourlyBQ + i]) * TES_aux_cons_perc, 0))
    }

    /// Corresponding max PB net elec output
    let hourlyDZ = 35040
    // IF(DX6=0,0,MAX(PB_net_min_cap,MIN(PB_nom_net_cap,DX6+DY6-BP6)))
    for i in 0..<8760 {
      hourly4[hourlyDZ + i] = iff(
        hourly0[hourlyDX + i].isZero, 0,
        max(PB_net_min_cap, min(PB_nom_net_cap, hourly0[hourlyDX + i] + hourly0[hourlyDY + i] - hourly1[hourlyBP + i])))
    }

    /// Corresponding max PB gross elec output
    let hourlyEA = 43800
    // IF(DZ6=0,0,DZ6+PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(DZ6/PB_nom_net_cap,PB_n2g_var_aux_el_Coeff)+PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyEA + i] = iff(
        hourly0[hourlyDZ + i].isZero, 0,
        hourly0[hourlyDZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly0[hourlyDZ + i] / PB_nom_net_cap, PB_n_g_var_aux_el_Coeff) + PB_fix_aux_el)
    }

    /// ST startup heat cons
    let hourlyEB = 52560
    // IF(AND(EA6=0,EA7>0),IF(COUNTIF(EA1:EA6,"0")=PB_warm_start_duration,PB_warm_start_heat_req,PB_hot_start_heat_req),0)
    for i in 0..<8760 {
      hourly4[hourlyEB + i] = iff(
        and(hourly4[hourlyEA + i].isZero, hourly4[hourlyEA + i] > 0),
        iff(
          countiff(hourly4[(hourlyEA + i)...].prefix(6), { $0.isZero }) == PB_warm_start_duration, PB_warm_start_heat_req,
          PB_hot_start_heat_req), 0)
    }
    let EBsum = hourly1.sum(hours: daysBO, condition: hourlyEB)
    /// Max gross heat cons for ST
    let hourlyEC = 61320
    // IF(EA6=0,0,EA6/PB_nom_gross_eff/POLY(EA6/PB_nom_gross_cap_ud,el_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyEC + i] = iff(
        hourly4[hourlyEA + i].isZero, 0,
        hourly4[hourlyEA + i] / PB_nom_gross_eff / POLY(hourly4[hourlyEA + i] / PB_nom_gross_cap_ud, el_Coeff))
    }
    let ECsum = hourly1.sum(hours: daysBO, condition: hourlyEC)
    /// Max gross heat cons for extraction
    let hourlyED = 70080
    // IF(EC6=0,0,MAX(0,PB_Ratio_Heat_input_vs_output*(MIN(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons),(DZ6-DY6+BP6)/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(BM7=0,0,A_overall_stup_cons))*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(BM7=0,0,A_overall_heat_stup_cons)))-BQ6-MAX(0,DZ6-DX6-DY6)*El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyED + i] = iff(
        hourly4[hourlyEC + i].isZero, 0,
        max(
          0,
          PB_Ratio_Heat_input_vs_output
            * (min(
              ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j]),
              (hourly0[hourlyDZ + i] - hourly0[hourlyDY + i] + hourly1[hourlyBP + i])
                / (((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
                  + overall_var_min_cons[j]) + overall_fix_stby_cons[j]
                  + iff(hourly1[hourlyBM + i].isZero, 0, overall_stup_cons[j]))
                * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                  * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                  + overall_heat_fix_stby_cons[j] + iff(hourly1[hourlyBM + i].isZero, 0, overall_heat_stup_cons[j])))
              - hourly1[hourlyBQ + i] - max(0, hourly0[hourlyDZ + i] - hourly0[hourlyDX + i] - hourly0[hourlyDY + i])
              * El_boiler_eff)))
    }
    let EDsum = hourly1.sum(hours: daysBO, condition: hourlyED)
    /// TES energy available if above min op case
    let hourlyEE = 78840
    // IF(CC6=0,0,MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763)))
    for i in 0..<8760 {
      hourly4[hourlyEE + i] = iff(
        hourly2[hourlyCC + i].isZero, 0,
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap, EBsum[i] + ECsum[i] + EDsum[i]))
    }

    /// Effective gross heat cons for ST
    let hourlyEF = 87600
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*EC6)
    for i in 0..<8760 {
      hourly4[hourlyEF + i] = iff(
        hourly4[hourlyEE + i].isZero, 0, (hourly4[hourlyEE + i] - EBsum[i]) / (ECsum[i] + EDsum[i]) * hourly4[hourlyEC + i])
    }

    /// Effective PB gross elec output
    let hourlyEG = 96360
    // IF(EF6=0,0,EF6*PB_nom_gross_eff*POLY(EF6/PB_nom_heat_cons,th_Coeff))
    for i in 0..<8760 {
      hourly4[hourlyEG + i] = iff(
        hourly4[hourlyEF + i].isZero, 0,
        hourly4[hourlyEF + i] * PB_nom_gross_eff * POLY(hourly4[hourlyEF + i] / PB_nom_heat_cons, th_Coeff))
    }

    /// Effective PB net elec output
    let hourlyEH = 105120
    // IF(EG6=0,0,EG6-PB_nom_net_cap*PB_nom_var_aux_cons_perc_net*POLY(EG6/PB_nom_gross_cap_ud,PB_g2n_var_aux_el_Coeff)-PB_fix_aux_el)
    for i in 0..<8760 {
      hourly4[hourlyEH + i] = iff(
        hourly4[hourlyEG + i].isZero, 0,
        hourly4[hourlyEG + i] - PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
          * POLY(hourly4[hourlyEG + i] / PB_nom_gross_cap_ud, PB_g2n_var_aux_el_Coeff) - PB_fix_aux_el)
    }

    /// Effective gross heat cons for extraction
    let hourlyEI = 113880
    // IF(EE6=0,0,(EE6-SUMIF(BO5:BO8763,"="BO6,EB5:EB8763))/(SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))*ED6)
    for i in 0..<8760 {
      hourly4[hourlyEI + i] = iff(
        hourly4[hourlyEE + i].isZero, 0, (hourly4[hourlyEE + i] - EBsum[i]) / (ECsum[i] + EDsum[i]) * hourly4[hourlyED + i])
    }

    /// TES energy to fulfil op case if above
    let hourlyEJ = 122640
    // IF(MIN(SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater),TES_thermal_cap)<SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763),EE6,SUMIF(BO5:BO8763,"="BO6,EB5:EB8763)+SUMIF(BO5:BO8763,"="BO6,EC5:EC8763)+SUMIF(BO5:BO8763,"="BO6,ED5:ED8763))
    for i in 0..<8760 {
      hourly4[hourlyEJ + i] = iff(
        min(AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater), TES_thermal_cap) < EBsum[i] + ECsum[i] + EDsum[i],
        hourly4[hourlyEE + i], EBsum[i] + ECsum[i] + EDsum[i])
    }

    /// Surplus TES energy due to op case
    let hourlyEK = 131400
    // IF(EJ6=0,0,MAX(0,SUMIF(BO5:BO8763,"="BO6,AY5:AY8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater)-EJ6))
    for i in 0..<8760 {
      hourly4[hourlyEK + i] = iff(
        hourly4[hourlyEJ + i].isZero, 0, max(0, AYsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - hourly4[hourlyEJ + i]))
    }

    /// Peripherial PV hour PV to heater
    let hourlyEL = 140160
    // IF(OR(AND(EK6>0,AY6>0,AY5=0),AND(EK6>0,AY7=0,AY6>0)),AY6,0)
    for i in 0..<8760 {
      hourly4[hourlyEL + i] = iff(
        or(
          and(hourly4[hourlyEK + i] > 0, hourly1[hourlyAY + i] > 0, hourly1[hourlyAY + i - 1].isZero),
          and(hourly4[hourlyEK + i] > 0, hourly1[hourlyAY + i].isZero, hourly1[hourlyAY + i] > 0)), hourly1[hourlyAY + i], 0)
    }
    let ELsum = hourly1.sum(hours: daysBO, condition: hourlyEL)
    /// Surplus energy due to op limit after removal of peripherial hours
    let hourlyEM = 148920
    // MAX(0,EK6-SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))
    for i in 0..<8760 {
      hourly4[hourlyEM + i] = max(0, hourly4[hourlyEK + i] - ELsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater))
    }

    /// intermediate resulting PV elec to TES
    let hourlyEN = 157680
    // IF(EK6=0,0,AY6-(EK6-EM6)/(SUMIF(BO5:BO8763,"="BO6,EL5:EL8763)*Heater_eff*(1+1/Ratio_CSP_vs_Heater))*EL6)
    for i in 0..<8760 {
      hourly4[hourlyEN + i] = iff(
        hourly4[hourlyEK + i].isZero, 0,
        hourly1[hourlyAY + i] - (hourly4[hourlyEK + i] - hourly4[hourlyEM + i])
          / (ELsum[i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)) * hourly4[hourlyEL + i])
    }
    /// Partitions of PV hour PV to be dedicated to TES chrg
    let hourlyEO = 166440
    let EN_BOcountNonZero = hourly4.count(hours: daysBO, range: hourlyEN, predicate: {$0>0})
    let ENsum = hourly4.sum(hours: daysBO, condition: hourlyEN)
    // IF(OR(EN6=0,EM6=0),0,MAX((AW6-EN6)/(EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")),(J6-EN6*Heater_eff/Ratio_CSP_vs_Heater)/(EM6/(1+Ratio_CSP_vs_Heater)/COUNTIFS(BO5:BO8763,"="BO6,EN5:EN8763,">0")))/SUMIF(BO5:BO8763,"="BO6,EN5:EN8763)*EN6)
    for i in 0..<8760 {
      hourly4[hourlyEO + i] = iff(
        or(hourly4[hourlyEN + i].isZero, hourly4[hourlyEM + i].isZero), 0,
        max(
          (hourly1[hourlyAW + i] - hourly4[hourlyEN + i])
            / (hourly4[hourlyEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / EN_BOcountNonZero[i]),
          (hourly0[hourlyJ + i] - hourly4[hourlyEN + i] * Heater_eff / Ratio_CSP_vs_Heater)
            / (hourly4[hourlyEM + i] / (1 + Ratio_CSP_vs_Heater) / EN_BOcountNonZero[i])) / ENsum[i]
          * hourly4[hourlyEN + i])
    }
    let EOsum = hourly4.sum(days: daysBO, range: hourlyEO)
    /// corrected max possible PV elec to TES
    let hourlyEP = 175200
    // IF(EJ6=0,0,EN6-IF(EM6=0,0,EM6/(1+1/Ratio_CSP_vs_Heater)/Heater_eff/SUMIF(BO5:BO8763,"="BO6,EO5:EO8763)*EO6))
    for i in 0..<8760 {
      hourly4[hourlyEP + i] = iff(
        hourly4[hourlyEJ + i].isZero, 0,
        hourly4[hourlyEN + i]
          - iff(
            hourly4[hourlyEM + i].isZero, 0,
            hourly4[hourlyEM + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / EOsum[i] * hourly4[hourlyEO + i]))
    }

    /// Max possible CSP heat to TES
    let hourlyEQ = 183960
    // MIN(J6,EP6*Heater_eff/Ratio_CSP_vs_Heater)
    for i in 0..<8760 {
      hourly4[hourlyEQ + i] = min(hourly0[hourlyJ + i], hourly4[hourlyEP + i] * Heater_eff / Ratio_CSP_vs_Heater)
    }

    /// Available elec from PV after TES chrg
    let hourlyER = 192720
    // MAX(0,L6-EP6)
    for i in 0..<8760 { hourly4[hourlyER + i] = max(0, hourly0[hourlyL + i] - hourly4[hourlyEP + i]) }

    /// Available heat from CSP after TES
    let hourlyES = 201480
    // MAX(0,J6-EQ6)
    for i in 0..<8760 { hourly4[hourlyES + i] = max(0, hourly0[hourlyJ + i] - hourly4[hourlyEQ + i]) }

    /// Total aux el TES chrg&disch CSP SF, PV, PB stby  MWel
    let hourlyET = 210240
    // IF(J6>0,J6*CSP_var_aux_nom_perc,CSP_nonsolar_aux_cons)+M6+(EP6*Heater_eff+EQ6)*TES_aux_cons_perc+IF(EH6=0,PB_stby_aux_cons+EB6*TES_aux_cons_perc,(EB6+EF6+EI6)*TES_aux_cons_perc)
    for i in 0..<8760 {
      hourly4[hourlyET + i] =
        iff(hourly0[hourlyJ + i] > 0, hourly0[hourlyJ + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + hourly0[hourlyM + i]
        + (hourly4[hourlyEP + i] * Heater_eff + hourly4[hourlyEQ + i]) * TES_aux_cons_perc
        + iff(
          hourly4[hourlyEH + i].isZero, PB_stby_aux_cons + hourly4[hourlyEB + i] * TES_aux_cons_perc,
          (hourly4[hourlyEB + i] + hourly4[hourlyEF + i] + hourly4[hourlyEI + i]) * TES_aux_cons_perc)
    }

    /// Not covered aux elec MWel
    let hourlyEU = 219000
    // MAX(0,-(L6+IF(EJ6>0,DZ6,0)-EP6-ET6))
    for i in 0..<8760 {
      hourly4[hourlyEU + i] = max(
        0,
        -(hourly0[hourlyL + i] + iff(hourly4[hourlyEJ + i] > 0, hourly0[hourlyDZ + i], 0) - hourly4[hourlyEP + i]
          - hourly4[hourlyET + i]))
    }

    /// Min harmonious net elec cons not considering grid import
    let hourlyEW = 227760
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,Overall_harmonious_var_min_cons+Overall_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyEW + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        Overall_harmonious_var_min_cons + Overall_fix_cons)
    }

    /// Optimized min harmonious net elec cons
    let hourlyEX = 236520
    // IF(AND(EW6>0,EW5=0,OR(EW6=0,EW7=0)),0,EW6)
    for i in 0..<8760 {
      hourly4[hourlyEX + i] = iff(
        and(
          hourly4[hourlyEW + i] > 0, hourly4[hourlyEW + i - 1].isZero,
          or(hourly4[hourlyEW + i].isZero, hourly4[hourlyEW + i].isZero)), 0, hourly4[hourlyEW + i])
    }

    /// Min harmonious net heat cons
    let hourlyEY = 245280
    // EX6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyEY + i] =
        hourly4[hourlyEX + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Harmonious op day
    let hourlyEZ = 254040
    // IF(AND(EX5<=0,EX6>0),EZ5+1,IF(AND(ER6>0,BO6<>BO5,SUM(EX6:EX8)=0),EZ5+1,EZ5))
    for i in 0..<8760 {
      hourly4[hourlyEZ + i] = iff(
        and(hourly4[hourlyEX + i - 1] <= 0, hourly4[hourlyEX + i] > 0), hourly4[hourlyEZ + i - 1] + 1,
        iff(
          and(
            hourly4[hourlyER + i] > 0, hourly1[hourlyBO + i] == hourly1[hourlyBO + i - 1],
            sum(hourly4[(hourlyEX + i)...].prefix(3)).isZero), hourly4[hourlyEZ + i - 1] + 1, hourly4[hourlyEZ + i - 1]))
    }

    /// El cons due to op outside of harm op period
    let hourlyFA = 262800
    // IF(OR(EX6>0,EJ6=0),0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)),((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFA + i] = iff(
        or(hourly4[hourlyEX + i] > 0, hourly4[hourlyEJ + i].isZero), 0,
        min(
          (hourly4[hourlyEH + i] + hourly4[hourlyER + i]
            + (hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
              + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j]))
                / El_boiler_eff)
            * (((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
              + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])),
          ((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])))
    }

    /// heat cons due to op outside of harm op period
    let hourlyFB = 271560
    // IF(FA6=0,0,MIN((EH6+ER6+(ES6+EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff-(ET6-EU6))/(((A_overall_var_max_cons-A_overall_var_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_min_cons)+A_overall_fix_stby_cons+IF(EX7=0,0,A_overall_stup_cons)+(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons))/El_boiler_eff)*(((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)),((A_overall_var_heat_max_cons-A_overall_var_heat_min_cons)*(DV6-A_equiv_harmonious_min_perc)+A_overall_var_heat_min_cons)+A_overall_heat_fix_stby_cons+IF(EY7=0,0,A_overall_heat_stup_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFB + i] = iff(
        hourly4[hourlyFA + i].isZero, 0,
        min(
          (hourly4[hourlyEH + i] + hourly4[hourlyER + i]
            + (hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output) / El_boiler_eff
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
            / (((overall_var_max_cons[j] - overall_var_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
              + overall_var_min_cons[j]) + overall_fix_stby_cons[j] + iff(hourly4[hourlyEX + i].isZero, 0, overall_stup_cons[j])
              + (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
                * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
                + overall_heat_fix_stby_cons[j] + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j]))
                / El_boiler_eff)
            * (((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j])
              * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j]) + overall_var_heat_min_cons[j])
              + overall_heat_fix_stby_cons[j] + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])),
          ((overall_var_heat_max_cons[j] - overall_var_heat_min_cons[j]) * (hourly4[hourlyDV + i] - equiv_harmonious_min_perc[j])
            + overall_var_heat_min_cons[j]) + overall_heat_fix_stby_cons[j]
            + iff(hourly4[hourlyEY + i].isZero, 0, overall_heat_stup_cons[j])))
    }

    /// Remaining el after min harmonious
    let hourlyFC = 280320
    // MAX(0,EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFC + i] = max(
        0,
        hourly4[hourlyEH + i] + hourly4[hourlyER + i] - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyEX + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
              - hourly4[hourlyES + i]) / El_boiler_eff))
    }

    /// Remaining heat after min harmonious
    let hourlyFD = 289080
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-EY6-FB6)
    for i in 0..<8760 {
      hourly4[hourlyFD + i] = max(
        0,
        hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output - hourly4[hourlyEY + i]
          - hourly4[hourlyFB + i])
    }

    /// Grid import necessary for min harm
    let hourlyFE = 297840
    // MAX(0,-(EH6+ER6-(ET6-EU6)-EX6-FA6-MAX(0,(EY6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyFE + i] = max(
        0,
        -(hourly4[hourlyEH + i] + hourly4[hourlyER + i] - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyEX + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
              - hourly4[hourlyES + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after min harm
    let hourlyFF = 306600
    // Grid_import_max_ud-FE6
    for i in 0..<8760 { hourly4[hourlyFF + i] = Grid_import_max_ud - hourly4[hourlyFE + i] }

    /// El boiler op after min harmonious heat cons
    let hourlyFG = 315360
    // MIN(El_boiler_cap_ud,MAX(0,(EY6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFG + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyEY + i] + hourly4[hourlyFB + i] - hourly4[hourlyES + i] - hourly4[hourlyEI + i]
            / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after min harmonious heat cons
    let hourlyFH = 324120
    // MAX(0,El_boiler_cap_ud-FG6)
    for i in 0..<8760 { hourly4[hourlyFH + i] = max(0, El_boiler_cap_ud - hourly4[hourlyFG + i]) }

    /// Remaining MethSynt cap after min harmonious cons
    let hourlyFI = 332880
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFI + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after min harmonious cons
    let hourlyFJ = 341640
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFJ + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after min harmonious cons
    let hourlyFK = 350400
    // MAX(0,1-((MAX(0,EX6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyFK + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyEX + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after min harmonious cons
    let hourlyFL = 359160
    // MIN(BESS_chrg_max_cons,FC6)
    for i in 0..<8760 { hourly4[hourlyFL + i] = min(BESS_chrg_max_cons, hourly4[hourlyFC + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyFM = 367920
    // MIN(Grid_export_max_ud,FC6)
    for i in 0..<8760 { hourly4[hourlyFM + i] = min(Grid_export_max_ud, hourly4[hourlyFC + i]) }

    /// Max harmonious net elec cons without considering grid
    let hourlyFN = 376680
    // IF(MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons))<Overall_harmonious_var_min_cons+Overall_fix_cons,0,MIN(Overall_harmonious_var_max_cons+Overall_fix_cons,ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6),MIN(ES6+El_boiler_cap_ud*El_boiler_eff,(ER6+Grid_import_max_ud*Grid_import_yes_no_PB_strategy-(ET6-EU6))/(Overall_harmonious_var_max_cons+Overall_fix_cons+(ET6-EU6)+MAX(0,(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons-ES6))/El_boiler_eff)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons))/(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)*(Overall_harmonious_var_max_cons+Overall_fix_cons)))
    for i in 0..<8760 {
      hourly4[hourlyFN + i] = iff(
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)) < Overall_harmonious_var_min_cons + Overall_fix_cons, 0,
        min(
          Overall_harmonious_var_max_cons + Overall_fix_cons,
          hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
            - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]),
          min(
            hourly4[hourlyES + i] + El_boiler_cap_ud * El_boiler_eff,
            (hourly4[hourlyER + i] + Grid_import_max_ud * Grid_import_yes_no_PB_strategy
              - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]))
              / (Overall_harmonious_var_max_cons + Overall_fix_cons + (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) + max(
                0, (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons - hourly4[hourlyES + i])) / El_boiler_eff)
              * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons))
            / (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
            * (Overall_harmonious_var_max_cons + Overall_fix_cons)))
    }

    /// Optimized max harmonious net elec cons
    let hourlyFO = 385440
    // IF(AND(FN6>0,FN5=0,OR(FN6=0,FN7=0)),0,FN6)
    for i in 0..<8760 {
      hourly4[hourlyFO + i] = iff(
        and(
          hourly4[hourlyFN + i] > 0, hourly4[hourlyFN + i - 1].isZero,
          or(hourly4[hourlyFN + i].isZero, hourly4[hourlyFN + i].isZero)), 0, hourly4[hourlyFN + i])
    }

    /// max harmonious net heat cons
    let hourlyFP = 394200
    // FO6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*(Overall_harmonious_var_heat_max_cons+Overall_heat_fix_cons)
    for i in 0..<8760 {
      hourly4[hourlyFP + i] =
        hourly4[hourlyFO + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
        * (Overall_harmonious_var_heat_max_cons + Overall_heat_fix_cons)
    }

    /// Remaining el after max harmonious
    let hourlyFQ = 402960
    // MAX(0,EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFQ + i] = max(
        0,
        hourly4[hourlyEH + i] + hourly4[hourlyER + i] - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyFO + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
              - hourly4[hourlyES + i]) / El_boiler_eff))
    }

    /// Remaining heat after max harmonious
    let hourlyFR = 411720
    // MAX(0,ES6+EI6/PB_Ratio_Heat_input_vs_output-FP6-FB6)
    for i in 0..<8760 {
      hourly4[hourlyFR + i] = max(
        0,
        hourly4[hourlyES + i] + hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output - hourly4[hourlyFP + i]
          - hourly4[hourlyFB + i])
    }

    /// Grid import necessary for max harm
    let hourlyFS = 420480
    // MAX(0,-(EH6+ER6-(ET6-EU6)-FO6-FA6-MAX(0,(FP6+FB6-EI6/PB_Ratio_Heat_input_vs_output-ES6)/El_boiler_eff)))
    for i in 0..<8760 {
      hourly4[hourlyFS + i] = max(
        0,
        -(hourly4[hourlyEH + i] + hourly4[hourlyER + i] - (hourly4[hourlyET + i] - hourly4[hourlyEU + i]) - hourly4[hourlyFO + i]
          - hourly4[hourlyFA + i]
          - max(
            0,
            (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyEI + i] / PB_Ratio_Heat_input_vs_output
              - hourly4[hourlyES + i]) / El_boiler_eff)))
    }

    /// Remaining grid import capacity after max harm
    let hourlyFT = 429240
    // Grid_import_max_ud-FS6
    for i in 0..<8760 { hourly4[hourlyFT + i] = Grid_import_max_ud - hourly4[hourlyFS + i] }

    /// El boiler op after max harmonious heat cons
    let hourlyFU = 438000
    // MIN(El_boiler_cap_ud,MAX(0,(FP6+FB6-ES6-EI6/PB_Ratio_Heat_input_vs_output)/El_boiler_eff))
    for i in 0..<8760 {
      hourly4[hourlyFU + i] = min(
        El_boiler_cap_ud,
        max(
          0,
          (hourly4[hourlyFP + i] + hourly4[hourlyFB + i] - hourly4[hourlyES + i] - hourly4[hourlyEI + i]
            / PB_Ratio_Heat_input_vs_output) / El_boiler_eff))
    }

    /// Remaining el boiler cap after max harmonious heat cons
    let hourlyFV = 446760
    // MAX(0,El_boiler_cap_ud-FU6)
    for i in 0..<8760 { hourly4[hourlyFV + i] = max(0, El_boiler_cap_ud - hourly4[hourlyFU + i]) }

    /// Remaining MethSynt cap after max harmonious cons
    let hourlyFW = 455520
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethSynt_harmonious_max_perc-MethSynt_harmonious_min_perc)+MethSynt_harmonious_min_perc))*MethSynt_RawMeth_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFW + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) + MethSynt_harmonious_min_perc))
        * MethSynt_RawMeth_nom_prod_ud
    }

    /// Remaining CCU cap after max harmonious cons
    let hourlyFX = 464280
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(CCU_harmonious_max_perc-CCU_harmonious_min_perc)+CCU_harmonious_min_perc))*CCU_CO2_nom_prod_ud
    for i in 0..<8760 {
      hourly4[hourlyFX + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (CCU_harmonious_max_perc - CCU_harmonious_min_perc) + CCU_harmonious_min_perc)) * CCU_C_O_2_nom_prod_ud
    }

    /// Remaining EY cap after max harmonious cons
    let hourlyFY = 473040
    // MAX(0,1-((MAX(0,FO6-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(EY_harmonious_max_perc-EY_harmonious_min_perc)+EY_harmonious_min_perc))*EY_Hydrogen_nom_prod
    for i in 0..<8760 {
      hourly4[hourlyFY + i] =
        max(
          0,
          1
            - ((max(0, hourly4[hourlyFO + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons)
              / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
              * (EY_harmonious_max_perc - EY_harmonious_min_perc) + EY_harmonious_min_perc)) * EY_Hydrogen_nom_prod
    }

    /// Max BESS charging after max harmonious cons
    let hourlyFZ = 481800
    // MIN(BESS_chrg_max_cons,FQ6)
    for i in 0..<8760 { hourly4[hourlyFZ + i] = min(BESS_chrg_max_cons, hourly4[hourlyFQ + i]) }

    /// Max grid export after TES chrg, min harm, night and aux el  cons
    let hourlyGA = 490560
    // MIN(Grid_export_max_ud,FQ6)
    for i in 0..<8760 { hourly4[hourlyGA + i] = min(Grid_export_max_ud, hourly4[hourlyFQ + i]) }
    return hourly4
  }
}
