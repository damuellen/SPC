
extension TunOl {
  mutating func day(hour0: [Double]) -> [Double] {
    print(hour0[113880..<(113880 + 100)])
    let daysU: [[Int]] = hour0[113880..<(113880 + 8760)].indices.chunked(by: { hour0[$0] == hour0[$1] })
      .map { $0.map { $0 - 113880 } } // FIXME
    // let hourD = 0
    // let hourH = 8760
    // let hourI = 17520
    let hourJ = 26280
    // let hourK = 35040
    // let hourL = 43800
    // let hourM = 52560
    // let hourO = 61320
    let hourP = 70080
    // let hourQ = 78840
    // let hourR = 87600
    let hourS = 96360
    let hourT = 105120
    // let hourU = 113880
    let hourV = 122640
    let hourW = 131400
    let hourX = 140160
    let hourY = 148920
    let hourZ = 157680
    let hourAA = 166440
    let hourAB = 175200
    let hourAC = 183960
    let hourAD = 192720
    let hourAE = 201480
    let hourAF = 210240
    // let hourAG = 219000
    let hourAH = 227760
    let hourAI = 236520
    let hourAJ = 245280
    let hourAK = 254040
    let hourAL = 262800
    let hourAM = 271560
    let hourAN = 280320
    let hourAO = 289080
    let hourAP = 297840
    let hourAQ = 306600
    let hourAR = 315360
    let hourAS = 324120
    let hourAT = 332880
    // let S_UcountZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 <= 0 })
    // let S_UcountNonZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 > 0 })
    let U_S_Psum = hour0.sumOf(hourP, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_T_Jsum = hour0.sumOf(hourJ, days: daysU, condition: hourT, predicate: { $0 > 0 })
    let U_S_AFsum = hour0.sumOf(hourAF, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_S_ATsum = hour0.sumOf(hourAT, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_S_Xsum = hour0.sumOf(hourX, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_ALsum = hour0.sumOf(hourAL, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_Vsum = hour0.sumOf(hourV, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_AJsum = hour0.sumOf(hourAJ, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_Wsum = hour0.sumOf(hourW, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_AKsum = hour0.sumOf(hourAK, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_Ysum = hour0.sumOf(hourY, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_AMsum = hour0.sumOf(hourAM, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_AEsum = hour0.sumOf(hourAE, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_ASsum = hour0.sumOf(hourAS, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    // let U_S_AEsumZero = hour0.sumOf(hourAE, days: daysU, condition: hourS, predicate: { $0.isZero })
    let U_S_Zsum = hour0.sumOf(hourZ, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_S_ANsum = hour0.sumOf(hourAN, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_S_AAsum = hour0.sumOf(hourAA, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_AOsum = hour0.sumOf(hourAO, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_ABsum = hour0.sumOf(hourAB, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_APsum = hour0.sumOf(hourAP, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_ACsum = hour0.sumOf(hourAC, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_AQsum = hour0.sumOf(hourAQ, days: daysU, condition: hourAH, predicate: { $0 > 0 })
    let U_S_ADsum = hour0.sumOf(hourAD, days: daysU, condition: hourS, predicate: { $0 > 0 })
    let U_AH_ARsum = hour0.sumOf(hourAR, days: daysU, condition: hourAH, predicate: { $0 > 0 })

    let Psum = hour0.sum(days: daysU, range: hourP)
    let Jsum = hour0.sum(days: daysU, range: hourJ)
    let Ssum = hour0.sum(days: daysU, range: hourS)
    let Tsum = hour0.sum(days: daysU, range: hourT)
    let AIsum = hour0.sum(days: daysU, range: hourAI)
    let AFsum = hour0.sum(days: daysU, range: hourAF)
    let Xsum = hour0.sum(days: daysU, range: hourX)
    let Ysum = hour0.sum(days: daysU, range: hourY)
    let Vsum = hour0.sum(days: daysU, range: hourV)
    let Wsum = hour0.sum(days: daysU, range: hourW)

    let AAsum = hour0.sum(days: daysU, range: hourAA)
    let ABsum = hour0.sum(days: daysU, range: hourAB)
    let ACsum = hour0.sum(days: daysU, range: hourAC)
    let ADsum = hour0.sum(days: daysU, range: hourAD)
    let AHsum = hour0.sum(days: daysU, range: hourAH)

    var day5 = [Double]()

    /// Available day op PV elec after CSP, PB stby aux
    let dayDM = 0
    // SUMIFS(CalculationP5:P8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day5[dayDM + i] = U_S_Psum[i] }

    /// Available night op PV elec after CSP, PB stby aux
    let dayDN = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationP5:P8763)-DM6
    for i in 0..<365 { day5[dayDN + i] = Psum[i] - day5[dayDM + i] }

    /// Available day op  CSP heat
    let dayDO = 730
    // SUMIFS(CalculationJ5:J8763,CalculationU5:U8763,"="A6,CalculationT5:T8763,">0")
    for i in 0..<365 { day5[dayDO + i] = U_T_Jsum[i] }

    /// Available night op  CSP heat
    let dayDP = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationJ5:J8763)-DO6
    for i in 0..<365 { day5[dayDP + i] = Jsum[i] - day5[dayDO + i] }

    var day6 = [Double]()

    /// El cons considering min harm op during harm op period
    let dayDR = 0
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    for i in 0..<365 { day6[dayDR + i] = Ssum[i] }

    /// El cons considering max harm op during harm op period
    let dayDS = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    for i in 0..<365 { day6[dayDS + i] = AHsum[i] }

    /// Heat cons considering min harm op during harm op period
    let dayDT = 730
    // SUMIF(CalculationU5:U8763,"="A6,CalculationT5:T8763)
    for i in 0..<365 { day6[dayDT + i] = Tsum[i] }

    /// Heat cons considering max harm op during harm op period
    let dayDU = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAI5:AI8763)
    for i in 0..<365 { day6[dayDU + i] = AIsum[i] }

    /// Max grid export after min harm op during harm op period
    let dayDV = 1460
    // SUMIFS(CalculationAF5:AF8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayDV + i] = U_S_AFsum[i] }

    /// Max grid export after max harm op during harm op period
    let dayDW = 1825
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayDW + i] = U_S_ATsum[i] }

    /// Max grid export after min/max harm op outside of harm op period
    let dayDX = 2190
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    for i in 0..<365 { day6[dayDX + i] = AFsum[i] - day6[dayDV + i] }

    /// Grid cons considering min harm op during harm op period
    let dayDY = 2555
    // SUMIFS(CalculationX5:X8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayDY + i] = U_S_Xsum[i] }

    /// Grid cons considering max harm op during harm op period
    let dayDZ = 2920
    // SUMIFS(CalculationAL5:AL8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayDZ + i] = U_AH_ALsum[i] }

    /// Grid cons considering min/max harm op outside harm op period
    let dayEA = 3285
    // SUMIF(CalculationU5:U8763,"="A6,CalculationX5:X8763)-DY6
    for i in 0..<365 { day6[dayEA + i] = Xsum[i] - day6[dayDY + i] }

    /// Remaining PV el after min harm during harm op period
    let dayEB = 3650
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEB + i] = U_S_Vsum[i] }

    /// Remaining PV el after max harm during harm op period
    let dayEC = 4015
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEC + i] = U_AH_AJsum[i] }

    /// Remaining PV el after min harm outside harm op period
    let dayED = 4380
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    for i in 0..<365 { day6[dayED + i] = Vsum[i] - day6[dayEB + i] }

    /// Remaining CSP heat after min harm during harm op period
    let dayEE = 4745
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEE + i] = U_S_Wsum[i] }

    /// Remaining CSP heat after max harm during harm op period
    let dayEF = 5110
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEF + i] = U_AH_AKsum[i] }

    /// Remaining CSP heat after min harm outside harm op period
    let dayEG = 5475
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    for i in 0..<365 { day6[dayEG + i] = Wsum[i] - day6[dayEE + i] }

    /// Remaining grid import cap after min harm during harm op period
    let dayEH = 5840
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEH + i] = U_S_Ysum[i] }

    /// Remaining grid import cap after max harm during harm op period
    let dayEI = 6205
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEI + i] = U_AH_AMsum[i] }

    /// Remaining grid import cap after min harm outside harm op period
    let dayEJ = 6570
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    for i in 0..<365 { day6[dayEJ + i] = Ysum[i] - day6[dayEH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let dayEK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day6[dayEK + i] = min(U_S_AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let dayEL = 7300
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day6[dayEL + i] = min(U_AH_ASsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
    let dayEM = 7665
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day6[dayEM + i] = min(U_S_AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// El boiler op for min harm during harm op period
    let dayEN = 8030
    // SUMIFS(CalculationZ5:Z8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEN + i] = U_S_Zsum[i] }

    /// El boiler op for max harm during harm op period
    let dayEO = 8395
    // SUMIFS(CalculationAN5:AN8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEO + i] = U_S_ANsum[i] }

    /// Remaining El boiler cap after min harm during harm op period
    let dayEP = 8760
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEP + i] = U_S_AAsum[i] }

    /// Remaining El boiler cap after max harm during harm op period
    let dayEQ = 9125
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEQ + i] = U_AH_AOsum[i] }

    /// Remaining El boiler cap after min harm outside harm op period
    let dayER = 9490
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    for i in 0..<365 { day6[dayER + i] = AAsum[i] - day6[dayEP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    let dayES = 9855
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayES + i] = U_S_ABsum[i] }

    /// Remaining MethSynt cap after max harm during harm op period
    let dayET = 10220
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayET + i] = U_AH_APsum[i] }

    /// Remaining MethSynt cap after min harm outside of harm op period
    let dayEU = 10585
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    for i in 0..<365 { day6[dayEU + i] = ABsum[i] - day6[dayES + i] }

    /// Remaining CCU cap after min harm during harm op period
    let dayEV = 10950
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEV + i] = U_S_ACsum[i] }

    /// Remaining CCU cap after max harm during harm op period
    let dayEW = 11315
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEW + i] = U_AH_AQsum[i] }

    /// Remaining CCU cap after min harm outside of harm op period
    let dayEX = 11680
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    for i in 0..<365 { day6[dayEX + i] = ACsum[i] - day6[dayEV + i] }

    /// Remaining EY cap after min harm during harm op period
    let dayEY = 12045
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day6[dayEY + i] = U_S_ADsum[i] }

    /// Remaining EY cap after max harm during harm op period
    let dayEZ = 12410
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { day6[dayEZ + i] = U_AH_ARsum[i] }

    /// Remaining EY cap after min harm outside of harm op period
    let dayFA = 12775
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    for i in 0..<365 { day6[dayFA + i] = ADsum[i] - day6[dayEY + i] }
    return day6
  }

  mutating func day(case j: Int, day1: [Double], day6: [Double]) -> [Double] {
    let dayE = 0
    let dayF = 365
    let dayG = 730
    let dayH = 1095
    let dayI = 1460
    let dayJ = 1825
    // let dayK = 2190
    // let dayL = 2555
    // let dayM = 2920
    // let dayN = 3285
    let dayO = 3650
    let dayP = 4015
    let dayQ = 4380
    let dayR = 4745
    let dayS = 5110
    let dayT = 5475
    let dayU = 5840
    let dayV = 6205
    let dayW = 6570
    let dayX = 6935
    // let dayY = 7300
    // let dayZ = 7665
    // let dayAA = 8030
    // let dayAB = 8395
    // let dayAC = 8760
    // let dayAD = 9125
    let dayAE = 9490
    
    let dayEA = 3285
    let dayEB = 3650
    let dayEC = 4015
    let dayED = 4380
    let dayEE = 4745
    let dayEF = 5110
    let dayEG = 5475
    let dayEH = 5840
    let dayEI = 6205
    let dayEJ = 6570
    let dayEK = 6935
    let dayEL = 7300
    let dayEM = 7665
    let dayEN = 8030
    let dayEO = 8395
    let dayEP = 8760
    let dayEQ = 9125
    let dayER = 9490
    let dayES = 9855
    let dayET = 10220    
    let dayEV = 10950
    let dayEW = 11315
    let dayEY = 12045
    let dayEZ = 12410

    let dayDR = 0
    let dayDS = 365
    let dayDT = 730
    let dayDU = 1095
    let dayDV = 1460
    let dayDW = 1825
    let dayDX = 2190
    let dayDY = 2555
    let dayDZ = 2920
    var day7 = [Double]()

    let equiv_harmonious_range = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]

    /// Surplus harm op period el after min day harm op and min night op prep
    let dayFC = 0
    // EB6+EH6-O6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFC + i] =
        day6[dayEB + i] + day1[dayEH + i] - day1[dayO + i]
        - min(
          day6[dayEK + i],
          (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff) / BESS_chrg_eff) - max(
          Double.zero, day1[dayQ + i] - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let dayFD = 365
    // EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFD + i] =
        day6[dayEB + i] + day1[dayEH + i]
        - (day1[dayO + i]
          + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
        - min(
          day6[dayEK + i],
          (day6[dayEA + i]
            + (day1[dayE + i]
              + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            + (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff)
            / BESS_chrg_eff) - max(
          Double.zero,
          (day1[dayQ + i]
            + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let dayFE = 730
    // EC6+EI6-O6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFE + i] =
        day6[dayEC + i] + day6[dayEI + i] - day1[dayO + i]
        - min(
          day6[dayEL + i],
          (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff) / BESS_chrg_eff) - max(
          Double.zero, day1[dayQ + i] - day6[dayEF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFF = 1095
    // (EK6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      day7[dayFF + i] =
        (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - day1[dayE + i]
        - day1[dayG + i] / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFG = 1460
    // (EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff
    for i in 0..<365 {
      day7[dayFG + i] =
        (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
        - (day1[dayE + i]
          + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
        - (day1[dayG + i]
          + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
        / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFH = 1825
    // (EL6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      day7[dayFH + i] =
        (day6[dayEL + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - day1[dayE + i]
        - day1[dayG + i] / El_boiler_eff
    }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFI = 2190
    // EE6+(EB6+EH6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      day7[dayFI + i] =
        day6[dayEE + i]
        + (day6[dayEB + i] + day1[dayEH + i]
          - min(
            day6[dayEK + i],
            (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff) / BESS_chrg_eff)
          - day1[dayO + i]) * El_boiler_eff - day1[dayQ + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFJ = 2555
    // EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayFJ + i] =
        day6[dayEE + i]
        + (day6[dayEB + i] + day1[dayEH + i]
          - min(
            day6[dayEK + i],
            (day6[dayEA + i]
              + (day1[dayE + i]
                + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
              + (day1[dayG + i]
                + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                / El_boiler_eff)
              / BESS_chrg_eff)
          - (day1[dayO + i]
            + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j])))
        * El_boiler_eff
        - (day1[dayQ + i]
          + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFK = 2920
    // EF6+(EC6+EI6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      day7[dayFK + i] =
        day6[dayEF + i]
        + (day6[dayEC + i] + day6[dayEI + i]
          - min(
            day6[dayEL + i],
            (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff) / BESS_chrg_eff)
          - day1[dayO + i]) * El_boiler_eff - day1[dayQ + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let dayFL = 3285
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 {
      day7[dayFL + i] = day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i]
    }

    /// Surplus outside harm op heat after min day harm and max night op prep
    let dayFM = 3650
    // EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayFM + i] =
        day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
        - (day1[dayG + i]
          + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus outside harm op heat after max day harm and min night op prep
    let dayFN = 4015
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 {
      day7[dayFN + i] = day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let dayFO = 4380
    // EP6-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFO + i] = day6[dayEP + i] - max(Double.zero, day1[dayQ + i] - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let dayFP = 4745
    // EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFP + i] =
        day6[dayEP + i] - max(
          Double.zero,
          (day1[dayQ + i]
            + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
              * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let dayFQ = 5110
    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let dayFR = 5475
    
    for i in 0..<365 {
      // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
      day7[dayFQ + i] = day6[dayEQ + i] - max(Double.zero, day1[dayQ + i] - day6[dayEF + i]) / El_boiler_eff
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      day7[dayFR + i] = day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let dayFS = 5840
    // ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFS + i] =
        day6[dayER + i] - max(
          Double.zero,
          (day1[dayG + i]
            + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
              * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            - day6[dayEG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let dayFT = 6205
    // ER6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFT + i] = day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff
    }

    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let dayFU = 6570
    // ES6-S6
    for i in 0..<365 { day7[dayFU + i] = day6[dayES + i] - day1[dayS + i] }

    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let dayFV = 6935
    // ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayFV + i] =
        day6[dayES + i]
        - (day1[dayS + i]
          + (day1[dayT + i] - day1[dayS + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let dayFW = 7300
    // ET6-S6
    for i in 0..<365 { day7[dayFW + i] = day6[dayET + i] - day1[dayS + i] }

    /// Surplus CO2 prod cap after min day harm and min night op prep
    let dayFX = 7665
    // EV6-U6
    for i in 0..<365 { day7[dayFX + i] = day6[dayEV + i] - day1[dayU + i] }

    /// Surplus CO2 prod cap after min day harm and max night op prep
    let dayFY = 8030
    // EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayFY + i] =
        day6[dayEV + i]
        - (day1[dayU + i]
          + (day1[dayV + i] - day1[dayU + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max day harm and min night op prep
    let dayFZ = 8395
    // EW6-U6
    for i in 0..<365 { day7[dayFZ + i] = day6[dayEW + i] - day1[dayU + i] }

    /// Surplus H2 prod cap after min day harm and min night op prep
    let dayGA = 8760
    // EY6-W6
    for i in 0..<365 { day7[dayGA + i] = day6[dayEY + i] - day1[dayW + i] }

    /// Surplus H2 prod cap after min day harm and max night op prep
    let dayGB = 9125
    // EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayGB + i] =
        day6[dayEY + i]
        - (day1[dayW + i]
          + (day1[dayX + i] - day1[dayW + i]) / equiv_harmonious_range
            * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max day harm and min night op prep
    let dayGC = 9490
    // EZ6-W6
    for i in 0..<365 { day7[dayGC + i] = day6[dayEZ + i] - day1[dayW + i] }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let dayGE = 9855
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FE6),1),IFERROR(FF6/(FF6-FH6),1),IFERROR(FI6/(FI6-FK6),1),IFERROR(FL6/(FL6-FN6),1),IFERROR(FO6/(FO6-FQ6),1),IFERROR(FR6/(FR6-FT6),1),IFERROR(FU6/(FU6-FW6),1),IFERROR(FX6/(FX6-FZ6),1),IFERROR(GA6/(GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGE + i] = iff(
        or(
          day7[dayFC + i] < Double.zero, day7[dayFF + i] < Double.zero, day7[dayFI + i] < Double.zero, day7[dayFL + i] < Double.zero,
          day7[dayFO + i] < Double.zero, day7[dayFR + i] < Double.zero, day1[dayFU + i] < Double.zero, day7[dayFX + i] < Double.zero,
          day7[dayGA + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dayFC + i] / (day7[dayFC + i] - day7[dayFE + i]), 1),
          ifFinite(day7[dayFF + i] / (day7[dayFF + i] - day7[dayFH + i]), 1),
          ifFinite(day7[dayFI + i] / (day7[dayFI + i] - day7[dayFK + i]), 1),
          ifFinite(day7[dayFL + i] / (day7[dayFL + i] - day7[dayFN + i]), 1),
          ifFinite(day7[dayFO + i] / (day7[dayFO + i] - day7[dayFQ + i]), 1),
          ifFinite(day7[dayFR + i] / (day7[dayFR + i] - day7[dayFT + i]), 1),
          ifFinite(day1[dayFU + i] / (day1[dayFU + i] - day7[dayFW + i]), 1),
          ifFinite(day7[dayFX + i] / (day7[dayFX + i] - day7[dayFZ + i]), 1),
          ifFinite(day7[dayGA + i] / (day7[dayGA + i] - day7[dayGC + i]), 1))
          * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let dayGF = 10220
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGF + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEB + i]
            + (day6[dayEC + i] - day6[dayEB + i])
              / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + (day1[dayEH + i]
              + (day6[dayEI + i] - day1[dayEH + i])
                / Overall_harmonious_range
                * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - day1[dayO + i]
            - min(
              day6[dayEK + i]
                + (day6[dayEL + i] - day6[dayEK + i])
                  / Overall_harmonious_range
                  * (day1[dayGE + i] - Overall_harmonious_min_perc),
              (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff)
                / BESS_chrg_eff) - max(
              Double.zero,
              day1[dayQ + i]
                - (day6[dayEE + i]
                  + (day6[dayEF + i] - day6[dayEE + i])
                    / Overall_harmonious_range
                    * (day7[dayGE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let dayGG = 10585
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGG + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEB + i]
            + (day6[dayEC + i] - day6[dayEB + i])
              / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + (day1[dayEH + i]
              + (day6[dayEI + i] - day1[dayEH + i])
                / Overall_harmonious_range
                * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - (day1[dayO + i]
              + (day1[dayP + i] - day1[dayO + i])
                / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            - min(
              day6[dayEK + i]
                + (day6[dayEL + i] - day6[dayEK + i])
                  / Overall_harmonious_range
                  * (day1[dayGE + i] - Overall_harmonious_min_perc),
              (day6[dayEA + i]
                + (day1[dayE + i]
                  + (day1[dayF + i] - day1[dayE + i])
                    / equiv_harmonious_range
                    * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                + (day1[dayG + i]
                  + (day1[dayH + i] - day1[dayG + i])
                    / equiv_harmonious_range
                    * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              Double.zero,
              (day1[dayQ + i]
                + (day1[dayR + i] - day1[dayQ + i])
                  / equiv_harmonious_range
                  * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                - (day6[dayEE + i]
                  + (day6[dayEF + i] - day6[dayEE + i])
                    / Overall_harmonious_range
                    * (day7[dayGE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayGH = 10950
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGH + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          ((day6[dayEK + i]
            + (day6[dayEL + i] - day6[dayEK + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - day1[dayE + i] - day1[dayG + i]
            / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayGI = 11315
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGI + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          ((day6[dayEK + i]
            + (day6[dayEL + i] - day6[dayEK + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
            - (day1[dayE + i]
              + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayGJ = 11680
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6,5))
    for i in 0..<365 {
      day7[dayGJ + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEE + i]
            + (day6[dayEF + i] - day6[dayEE + i])
              / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + ((day6[dayEB + i]
              + (day6[dayEC + i] - day6[dayEB + i])
                / Overall_harmonious_range
                * (day7[dayGE + i] - Overall_harmonious_min_perc))
              + (day1[dayEH + i]
                + (day6[dayEI + i] - day1[dayEH + i])
                  / Overall_harmonious_range
                  * (day7[dayGE + i] - Overall_harmonious_min_perc))
              - min(
                day6[dayEK + i]
                  + (day6[dayEL + i] - day6[dayEK + i])
                    / Overall_harmonious_range
                    * (day1[dayGE + i] - Overall_harmonious_min_perc),
                (day6[dayEA + i] + day1[dayE + i] + day1[dayG + i]
                  / El_boiler_eff) / BESS_chrg_eff) - day1[dayO + i]) * El_boiler_eff
            - day1[dayQ + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayGK = 12045
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGK + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEE + i]
            + (day6[dayEF + i] - day6[dayEE + i])
              / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            + ((day6[dayEB + i]
              + (day6[dayEC + i] - day6[dayEB + i])
                / Overall_harmonious_range
                * (day7[dayGE + i] - Overall_harmonious_min_perc))
              + (day1[dayEH + i]
                + (day6[dayEI + i] - day1[dayEH + i])
                  / Overall_harmonious_range
                  * (day7[dayGE + i] - Overall_harmonious_min_perc))
              - min(
                day6[dayEK + i]
                  + (day6[dayEL + i] - day6[dayEK + i])
                    / Overall_harmonious_range
                    * (day1[dayGE + i] - Overall_harmonious_min_perc),
                (day6[dayEA + i]
                  + (day1[dayE + i]
                    + (day1[dayF + i] - day1[dayE + i])
                      / equiv_harmonious_range
                      * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                  + (day1[dayG + i]
                    + (day1[dayH + i] - day1[dayG + i])
                      / equiv_harmonious_range
                      * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (day1[dayO + i]
                + (day1[dayP + i] - day1[dayO + i])
                  / equiv_harmonious_range
                  * (day1[dayAE + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (day1[dayQ + i]
              + (day1[dayR + i] - day1[dayQ + i])
                / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let dayGL = 12410
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-G6,5))
    for i in 0..<365 {
      day7[dayGL + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let dayGM = 12775
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGM + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let dayGN = 13140
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGN + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEP + i]
            + (day6[dayEQ + i] - day6[dayEP + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - max(
              Double.zero,
              day1[dayQ + i]
                - (day6[dayEE + i]
                  + (day6[dayEF + i] - day6[dayEE + i]) / Overall_harmonious_range
                    * (day7[dayGE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let dayGO = 13505
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGO + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEP + i]
            + (day6[dayEQ + i] - day6[dayEP + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - max(
              Double.zero,
              (day1[dayQ + i]
                + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                  * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
                - (day6[dayEE + i]
                  + (day6[dayEF + i] - day6[dayEE + i]) / Overall_harmonious_range
                    * (day7[dayGE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let dayGP = 13870
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGP + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let dayGQ = 14235
    // IF(GE6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGQ + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          day6[dayER + i] - max(
            Double.zero,
            (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j]))
              - day6[dayEG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let dayGR = 14600
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 {
      day7[dayGR + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayES + i]
            + (day6[dayET + i] - day6[dayES + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - day1[dayS + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let dayGS = 14965
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGS + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayES + i]
            + (day6[dayET + i] - day6[dayES + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - (day1[dayS + i]
              + (day1[dayT + i] - day1[dayS + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let dayGT = 15330
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 {
      day7[dayGT + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEV + i]
            + (day6[dayEW + i] - day6[dayEV + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - day1[dayU + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let dayGU = 15695
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGU + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEV + i]
            + (day6[dayEW + i] - day6[dayEV + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - (day1[dayU + i]
              + (day1[dayV + i] - day1[dayU + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let dayGV = 16060
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 {
      day7[dayGV + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEY + i]
            + (day6[dayEZ + i] - day6[dayEY + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - day1[dayW + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let dayGW = 16425
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGW + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEY + i]
            + (day6[dayEZ + i] - day6[dayEY + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            - (day1[dayW + i]
              + (day1[dayX + i] - day1[dayW + i]) / equiv_harmonious_range
                * (day1[dayAE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let dayGX = 16790
    // IF(OR(GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/(GF6-GG6),1),IFERROR(GH6/(GH6-GI6),1),IFERROR(GJ6/(GJ6-GK6),1),IFERROR(GL6/(GL6-GM6),1),IFERROR(GN6/(GN6-GO6),1),IFERROR(GP6/(GP6-GQ6),1),IFERROR(GR6/(GR6-GS6),1),IFERROR(GT6/(GT6-GU6),1),IFERROR(GV6/(GV6-GW6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGX + i] = iff(
        or(
          day7[dayGE + i].isZero, day7[dayGF + i] < Double.zero, day1[dayGH + i] < Double.zero, day1[dayGJ + i] < Double.zero,
          day7[dayGL + i] < Double.zero, day7[dayGN + i] < Double.zero, day1[dayGP + i] < Double.zero, day7[dayGR + i] < Double.zero,
          day7[dayGT + i] < Double.zero, day1[dayGV + i] < Double.zero), Double.zero,
        min(
          1, ifFinite(day7[dayGF + i] / (day7[dayGF + i] - day7[dayGG + i]), 1),
          ifFinite(day1[dayGH + i] / (day1[dayGH + i] - day7[dayGI + i]), 1),
          ifFinite(day1[dayGJ + i] / (day1[dayGJ + i] - day7[dayGK + i]), 1),
          ifFinite(day7[dayGL + i] / (day7[dayGL + i] - day7[dayGM + i]), 1),
          ifFinite(day7[dayGN + i] / (day7[dayGN + i] - day7[dayGO + i]), 1),
          ifFinite(day1[dayGP + i] / (day1[dayGP + i] - day1[dayGQ + i]), 1),
          ifFinite(day7[dayGR + i] / (day7[dayGR + i] - day7[dayGS + i]), 1),
          ifFinite(day7[dayGT + i] / (day7[dayGT + i] - day7[dayGU + i]), 1),
          ifFinite(day1[dayGV + i] / (day1[dayGV + i] - day7[dayGW + i]), 1))
          * (day1[dayAE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let dayGZ = 17155
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FD6),1),IFERROR(FF6/(FF6-FG6),1),IFERROR(FI6/(FI6-FJ6),1),IFERROR(FL6/(FL6-FM6),1),IFERROR(FO6/(FO6-FP6),1),IFERROR(FR6/(FR6-FS6),1),IFERROR(FU6/(FU6-FV6),1),IFERROR(FX6/(FX6-FY6),1),IFERROR(GA6/(GA6-GB6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGZ + i] = iff(
        or(
          day7[dayFC + i] < Double.zero, day7[dayFF + i] < Double.zero, day7[dayFI + i] < Double.zero, day7[dayFL + i] < Double.zero,
          day7[dayFO + i] < Double.zero, day7[dayFR + i] < Double.zero, day1[dayFU + i] < Double.zero, day7[dayFX + i] < Double.zero,
          day7[dayGA + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dayFC + i] / (day7[dayFC + i] - day7[dayFD + i]), 1),
          ifFinite(day7[dayFF + i] / (day7[dayFF + i] - day7[dayFG + i]), 1),
          ifFinite(day7[dayFI + i] / (day7[dayFI + i] - day7[dayFJ + i]), 1),
          ifFinite(day7[dayFL + i] / (day7[dayFL + i] - day7[dayFM + i]), 1),
          ifFinite(day7[dayFO + i] / (day7[dayFO + i] - day7[dayFP + i]), 1),
          ifFinite(day7[dayFR + i] / (day7[dayFR + i] - day7[dayFS + i]), 1),
          ifFinite(day1[dayFU + i] / (day1[dayFU + i] - day7[dayFV + i]), 1),
          ifFinite(day7[dayFX + i] / (day7[dayFX + i] - day7[dayFY + i]), 1),
          ifFinite(day7[dayGA + i] / (day7[dayGA + i] - day7[dayGB + i]), 1))
          * (day1[dayAE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let dayHA = 17520
    // IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHA + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEB + i] + day1[dayEH + i]
            - (day1[dayO + i]
              + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              day6[dayEK + i],
              (day6[dayEA + i]
                + (day1[dayE + i]
                  + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                    * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                + (day1[dayG + i]
                  + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                    * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              Double.zero,
              (day1[dayQ + i]
                + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                  * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                - day6[dayEE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after max day harm op and opt night op prep
    let dayHB = 17885
    // IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHB + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEC + i] + day6[dayEI + i]
            - (day1[dayO + i]
              + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              day6[dayEL + i],
              (day6[dayEA + i]
                + (day1[dayE + i]
                  + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                    * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                + (day1[dayG + i]
                  + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                    * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              Double.zero,
              (day1[dayQ + i]
                + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                  * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                - day6[dayEF + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after min day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayHC = 18250
    // IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHC + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
            - (day1[dayE + i]
              + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus outside harm op period el after max day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayHD = 18615
    // IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHD + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          (day6[dayEL + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
            - (day1[dayE + i]
              + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after min day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayHE = 18980
    // IF(GZ6=0,0,ROUND(EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHE + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEE + i]
            + (day6[dayEB + i] + day1[dayEH + i]
              - min(
                day6[dayEK + i],
                (day6[dayEA + i]
                  + (day1[dayE + i]
                    + (day1[dayF + i] - day1[dayE + i])
                      / equiv_harmonious_range
                      * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                  + (day1[dayG + i]
                    + (day1[dayH + i] - day1[dayG + i])
                      / equiv_harmonious_range
                      * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (day1[dayO + i]
                + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range
                  * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (day1[dayQ + i]
              + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harm op heat after max day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayHF = 19345
    // IF(GZ6=0,0,ROUND(EF6+(EC6+EI6-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHF + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEF + i]
            + (day6[dayEC + i] + day6[dayEI + i]
              - min(
                day6[dayEL + i],
                (day6[dayEA + i]
                  + (day1[dayE + i]
                    + (day1[dayF + i] - day1[dayE + i])
                      / equiv_harmonious_range
                      * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                  + (day1[dayG + i]
                    + (day1[dayH + i] - day1[dayG + i])
                      / equiv_harmonious_range
                      * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (day1[dayO + i]
                + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range
                  * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (day1[dayQ + i]
              + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after min day harm and opt night op prep
    let dayHG = 19710
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHG + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after max day harm and opt night op prep
    let dayHH = 20075
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHH + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
            - (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let dayHI = 20440
    // IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHI + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEP + i] - max(
            Double.zero,
            (day1[dayQ + i]
              + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              - day6[dayEE + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let dayHJ = 20805
    // IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHJ + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEQ + i] - max(
            Double.zero,
            (day1[dayQ + i]
              + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              - day6[dayEF + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let dayHK = 21170
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHK + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayER + i] - max(
            Double.zero,
            (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              - day6[dayEG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let dayHL = 21535
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHL + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayER + i] - max(
            Double.zero,
            (day1[dayG + i]
              + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
              - day6[dayEG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let dayHM = 21900
    // IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHM + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayES + i]
            - (day1[dayS + i]
              + (day1[dayT + i] - day1[dayS + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let dayHN = 22265
    // IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHN + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayET + i]
            - (day1[dayS + i]
              + (day1[dayT + i] - day1[dayS + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let dayHO = 22630
    // IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHO + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEV + i]
            - (day1[dayU + i]
              + (day1[dayV + i] - day1[dayU + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let dayHP = 22995
    // IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHP + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEW + i]
            - (day1[dayU + i]
              + (day1[dayV + i] - day1[dayU + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let dayHQ = 23360
    // IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHQ + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEY + i]
            - (day1[dayW + i]
              + (day1[dayX + i] - day1[dayW + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let dayHR = 23725
    // IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayHR + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEZ + i]
            - (day1[dayW + i]
              + (day1[dayX + i] - day1[dayW + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let dayHS = 24090
    // IF(GZ6<=0,0,MIN(1,MIN(IFERROR(HA6/(HA6-HB6),1),IFERROR(HC6/(HC6-HD6),1),IFERROR(HE6/(HE6-HF6),1),IFERROR(HG6/(HG6-HH6),1),IFERROR(HI6/(HI6-HJ6),1),IFERROR(HK6/(HK6-HL6),1),IFERROR(HM6/(HM6-HN6),1),IFERROR(HO6/(HO6-HP6),1),IFERROR(HQ6/(HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayHS + i] = iff(
        day7[dayGZ + i] <= Double.zero, Double.zero,
        min(
          1,
          min(
            ifFinite(day1[dayHA + i] / (day1[dayHA + i] - day1[dayHB + i]), 1),
            ifFinite(day7[dayHC + i] / (day7[dayHC + i] - day1[dayHD + i]), 1),
            ifFinite(day1[dayHE + i] / (day1[dayHE + i] - day1[dayHF + i]), 1),
            ifFinite(day7[dayHG + i] / (day7[dayHG + i] - day1[dayHH + i]), 1),
            ifFinite(day1[dayHI + i] / (day1[dayHI + i] - day7[dayHJ + i]), 1),
            ifFinite(day1[dayHK + i] / (day1[dayHK + i] - day1[dayHL + i]), 1),
            ifFinite(day1[dayHM + i] / (day1[dayHM + i] - day1[dayHN + i]), 1),
            ifFinite(day7[dayHO + i] / (day7[dayHO + i] - day1[dayHP + i]), 1),
            ifFinite(day1[dayHQ + i] / (day1[dayHQ + i] - day1[dayHR + i]), 1))
            * Overall_harmonious_range + Overall_harmonious_min_perc))
    }

    /// Heat cons for harm op during harm op period
    let dayID = 27740
    // IF(GE6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayID + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayDT + i] + (day6[dayDU + i] - day6[dayDT + i])
          / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let dayIE = 28105
    // IF(GX6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayIE + i] = iff(
        day7[dayGX + i].isZero, Double.zero,
        (day1[dayQ + i]
          + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let dayIF = 28470
    // IF(GE6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIF + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let dayIG = 28835
    // IF(GE6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      day7[dayIG + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        (day6[dayEN + i]
          + (day6[dayEO + i] - day6[dayEN + i]) / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc)) * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let dayIH = 29200
    // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
    for i in 0..<365 {
      day7[dayIH + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        min(
          (day6[dayEP + i]
            + (day6[dayEQ + i] - day6[dayEP + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(Double.zero, day1[dayIE + i] - day1[dayIF + i])))
    }

    /// Balance of heat during harm op period
    let dayII = 29565
    // IF6+IH6-IE6
    for i in 0..<365 { day7[dayII + i] = day1[dayIF + i] + day1[dayIH + i] - day1[dayIE + i] }

    /// el cons for harm op during harm op period
    let dayHU = 24455
    // IF(GE6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayHU + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayDR + i] + (day6[dayDS + i] - day6[dayDR + i]) / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let dayHV = 24820
    // IF(GX6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayHV + i] = iff(
        day7[dayGX + i].isZero, Double.zero,
        (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let dayHW = 25185
    // IF(OR(GE6=0,GX6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dayHW + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        min(
          (day6[dayEA + i]
            + (day1[dayE + i]
              + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
            + max(
              Double.zero,
              (day1[dayG + i]
                + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                  * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
                - day6[dayEG + i]) / El_boiler_eff - day6[dayED + i]) / BESS_chrg_eff,
          (day6[dayEK + i]
            + (day6[dayEL + i] - day6[dayEK + i]) / Overall_harmonious_range
              * (day7[dayGE + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let dayHX = 25550
    // IF(GE6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayHX + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i])
          / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let dayHY = 25915
    // IH6/El_boiler_eff
    for i in 0..<365 { day7[dayHY + i] = day7[dayIH + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let dayHZ = 26280
    // IF(GE6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayHZ + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i])
          / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let dayIA = 26645
    // IF(GE6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIA + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        day6[dayDY + i] + (day6[dayDZ + i] - day6[dayDY + i])
          / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let dayIB = 27010
    // IF(GE6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),MAX(0,-(HZ6-HV6-HW6-HY6))))
    for i in 0..<365 {
      day7[dayIB + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        min(
          day1[dayEH + i] + (day6[dayEI + i] - day1[dayEH + i]) / Overall_harmonious_range * (day7[dayGE + i] - Overall_harmonious_min_perc),
          max(Double.zero, -(day7[dayHZ + i] - day1[dayHV + i] - day1[dayHW + i] - day1[dayHY + i]))))
    }

    /// Balance of electricity during harm op period
    let dayIC = 27375
    // HZ6+IB6-HV6-HW6-HY6
    for i in 0..<365 {
      day7[dayIC + i] =
        day7[dayHZ + i] + day7[dayIB + i] - day1[dayHV + i] - day1[dayHW + i] - day1[dayHY + i]
    }

    /// heat cons for harm op outside of harm op period
    let dayIQ = 32485
    // IF(OR(GE6=0,GX6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIQ + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        day1[dayG + i] + (day1[dayH + i] - day1[dayG + i])
          / equiv_harmonious_range
          * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let dayIR = 32850
    // IF(OR(GE6=0,GX6=0),0,EG6)
    for i in 0..<365 {
      day7[dayIR + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayEG + i])
    }

    /// heat from el boiler outside of harm op period
    let dayIS = 33215
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 {
      day7[dayIS + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        min(day6[dayER + i] * El_boiler_eff, max(Double.zero, day1[dayIQ + i] - day1[dayIR + i])))
    }

    /// Balance of heat outside of harm op period
    let dayIT = 33580
    // IR6+IS6-IQ6
    for i in 0..<365 { day7[dayIT + i] = day1[dayIR + i] + day7[dayIS + i] - day1[dayIQ + i] }

    /// el cons for harm op outside of harm op period
    let dayIJ = 29930
    // IF(OR(GE6=0,GX6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIJ + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        day1[dayE + i] + (day1[dayF + i] - day1[dayE + i])
          / equiv_harmonious_range * (day7[dayGX + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let dayIK = 30295
    // IS6/El_boiler_eff
    for i in 0..<365 { day7[dayIK + i] = day7[dayIS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let dayIL = 30660
    // IF(OR(GE6=0,GX6=0),0,EA6)
    for i in 0..<365 {
      day7[dayIL + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayEA + i])
    }

    /// el from PV outside of harm op period
    let dayIM = 31025
    // IF(OR(GE6=0,GX6=0),0,ED6)
    for i in 0..<365 {
      day7[dayIM + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayED + i])
    }

    /// el from BESS outside of harm op period
    let dayIN = 31390
    // HW6*BESS_chrg_eff
    for i in 0..<365 { day7[dayIN + i] = day1[dayHW + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let dayIO = 31755
    // IF(OR(GE6=0,GX6=0),0,MIN(EJ6+EA6,MAX(0,-(IM6+IN6-IJ6-IK6-IL6))))
    for i in 0..<365 {
      day7[dayIO + i] = iff(
      or(day7[dayGE + i].isZero,day7[dayGX + i].isZero), Double.zero, min(day6[dayEJ + i] + day6[dayEA + i], max(Double.zero, -(day1[dayIM + i] + day7[dayIN + i] - day1[dayIJ + i] - day1[dayIK + i] - day7[dayIL + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayIP = 32120
    // IM6+IN6+IO6-IJ6-IK6-IL6
    for i in 0..<365 {
      day7[dayIP + i] =
        day1[dayIM + i] + day7[dayIN + i] + day7[dayIO + i] - day1[dayIJ + i] - day1[dayIK + i] - day7[dayIL + i]
    }

    /// Pure Methanol prod with min night prep and resp day op
    let dayIU = 33945
    // IF(HU6<=0,0,HU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(IJ6<=0,0,(IJ6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dayIU + i] =
        iff(
          day1[dayHU + i] <= Double.zero, Double.zero,
          day1[dayHU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day1[dayIJ + i] <= Double.zero, Double.zero,
          (day1[dayIJ + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let dayIV = 34310
    // MIN(IC6,IF(OR(GE6=0,GX6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))+MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))
    for i in 0..<365 {
      day7[dayIV + i] =
        min(
          day7[dayIC + i],
          iff(
            or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
            (day6[dayDV + i]
              + (day6[dayDW + i] - day6[dayDV + i]) / Overall_harmonious_range
                * (day7[dayGE + i] - Overall_harmonious_min_perc))
          ))
        + min(day7[dayIP + i], iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayDX + i]))
    }

    /// grid import
    let dayIW = 34675
    // IA6+IB6+IO6
    for i in 0..<365 { day7[dayIW + i] = day1[dayIA + i] + day7[dayIB + i] + day7[dayIO + i] }

    /// Checksum
    let dayIX = 35040
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    for i in 0..<365 {
      let IX = max(Double.zero, -day7[dayIC + i]) + max(Double.zero, -day1[dayII + i]) + max(Double.zero, -day7[dayIP + i]) + max(Double.zero, -day7[dayIT + i])
      if !IX.isZero { print("Checksum error", i) }
      day7[dayIX + i] = IX
    }

    /// Heat cons for harm op during harm op period
    let dayJI = 38690
    // IF(HS6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJI + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayDT + i] + (day6[dayDU + i] - day6[dayDT + i]) / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let dayJJ = 39055
    // IF(GZ6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayJJ + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) / equiv_harmonious_range * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let dayJK = 39420
    // IF(HS6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJK + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i])
          / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let dayJL = 39785
    // IF(HS6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      day7[dayJL + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        (day6[dayEN + i]
          + (day6[dayEO + i] - day6[dayEN + i]) / Overall_harmonious_range
            * (day7[dayHS + i] - Overall_harmonious_min_perc)) * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let dayJM = 40150
    // IF(HS6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 {
      day7[dayJM + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        min(
          (day6[dayEP + i]
            + (day6[dayEQ + i] - day6[dayEP + i]) / Overall_harmonious_range
              * (day7[dayHS + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(Double.zero, day7[dayJJ + i] - day7[dayJK + i])))
    }

    /// Balance of heat during harm op period
    let dayJN = 40515
    // JK6+JM6-JJ6
    for i in 0..<365 { day7[dayJN + i] = day7[dayJK + i] + day7[dayJM + i] - day7[dayJJ + i] }

    /// el cons for harm op during harm op period
    let dayIZ = 35405
    // IF(HS6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIZ + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayDR + i] + (day6[dayDS + i] - day6[dayDR + i])
          / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let dayJA = 35770
    // IF(GZ6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayJA + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) / equiv_harmonious_range * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let dayJB = 36135
    // IF(OR(HS6=0,GZ6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dayJB + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        min(
          (day6[dayEA + i]
            + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) / equiv_harmonious_range
                * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            + max(
              Double.zero,
              (day1[dayG + i]
                + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range
                  * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
                - day6[dayEG + i]) / El_boiler_eff - day6[dayED + i]) / BESS_chrg_eff,
          (day6[dayEK + i]
            + (day6[dayEL + i] - day6[dayEK + i]) / Overall_harmonious_range
              * (day7[dayHS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let dayJC = 36500
    // IF(HS6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJC + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i])
          / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let dayJD = 36865
    // JM6/El_boiler_eff
    for i in 0..<365 { day7[dayJD + i] = day7[dayJM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let dayJE = 37230
    // IF(HS6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJE + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i])
          / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let dayJF = 37595
    // IF(HS6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJF + i] = iff(
        day7[dayHS + i].isZero, Double.zero,
        day6[dayDY + i] + (day6[dayDZ + i] - day6[dayDY + i])
          / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let dayJG = 37960
    // IF(HS6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc),MAX(0,-(JE6-JA6-JB6-JD6))))
    for i in 0..<365 {
      day7[dayJG + i] = iff(
        day7[dayHS + i].isZero, Double.zero, min(day1[dayEH + i] + (day6[dayEI + i] - day1[dayEH + i]) / Overall_harmonious_range * (day7[dayHS + i] - Overall_harmonious_min_perc),max(Double.zero, -(day7[dayJE + i] - day7[dayJA + i] - day7[dayJB + i] - day7[dayJD + i]))))
    }

    /// Balance of electricity during harm op period
    let dayJH = 38325
    // JE6+JG6-JA6-JB6-JD6
    for i in 0..<365 {
      day7[dayJH + i] = day7[dayJE + i] + day7[dayJG + i] - day7[dayJA + i] - day7[dayJB + i] - day7[dayJD + i]
    }

    /// heat cons for harm op outside of harm op period
    let dayJV = 43435
    // IF(OR(HS6=0,GZ6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJV + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) / equiv_harmonious_range * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let dayJW = 43800
    // IF(OR(HS6=0,GZ6=0),0,EG6)
    for i in 0..<365 {
      day7[dayJW + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayEG + i])
    }

    /// heat from el boiler outside of harm op period
    let dayJX = 44165
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 {
      day7[dayJX + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        min(day6[dayER + i] * El_boiler_eff, max(Double.zero, day7[dayJV + i] - day7[dayJW + i])))
    }

    /// Balance of heat outside of harm op period
    let dayJY = 44530
    // JW6+JX6-JV6
    for i in 0..<365 { day7[dayJY + i] = day7[dayJW + i] + day7[dayJX + i] - day7[dayJV + i] }

    /// el cons for harm op outside of harm op period
    let dayJO = 40880
    // IF(OR(HS6=0,GZ6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJO + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        day1[dayE + i] + (day1[dayF + i] - day1[dayE + i])
          / equiv_harmonious_range * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let dayJP = 41245
    // JX6/El_boiler_eff
    for i in 0..<365 { day7[dayJP + i] = day7[dayJX + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let dayJQ = 41610
    // IF(OR(HS6=0,GZ6=0),0,EA6)
    for i in 0..<365 {
      day7[dayJQ + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayEA + i])
    }

    /// el from PV outside of harm op period
    let dayJR = 41975
    // IF(OR(HS6=0,GZ6=0),0,ED6)
    for i in 0..<365 {
      day7[dayJR + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayED + i])
    }

    /// el from BESS outside of harm op period
    let dayJS = 42340
    // JB6*BESS_chrg_eff
    for i in 0..<365 { day7[dayJS + i] = day7[dayJB + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let dayJT = 42705
    // IF(OR(HS6=0,GZ6=0),0,MIN(EJ6+EA6,MAX(0,-(JR6+JS6-JO6-JP6-JQ6))))
    for i in 0..<365 {
      day7[dayJT + i] = iff(
      or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, min(day6[dayEJ + i] + day6[dayEA + i],
       max(Double.zero, -(day7[dayJR + i] + day7[dayJS + i] - day7[dayJO + i] - day7[dayJP + i] - day7[dayJQ + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayJU = 43070
    // JR6+JS6+JT6-JO6-JP6-JQ6
    for i in 0..<365 {
      day7[dayJU + i] = day7[dayJR + i] + day7[dayJS + i] + day7[dayJT + i] - day7[dayJO + i] - day7[dayJP + i] - day7[dayJQ + i]
    }

    /// Pure Methanol prod with min night prep and resp day op
    let dayJZ = 44895
    // IF(IZ6<=0,0,IZ6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(GZ6<=0,0,(I6+(J6-I6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/MethDist_RawMeth_nom_cons*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dayJZ + i] =
        iff(
          day7[dayIZ + i] <= Double.zero, Double.zero,
          day7[dayIZ + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day7[dayGZ + i] <= Double.zero, Double.zero,
          (day1[dayI + i]
            + (day7[dayJ + i] - day1[dayI + i]) / equiv_harmonious_range * (day7[dayGZ + i] - equiv_harmonious_min_perc[j]))
            / MethDist_RawMeth_nom_cons * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let dayKA = 45260
    // MIN(JH6,IF(OR(HS6=0,GZ6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))+MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))
    for i in 0..<365 {
      day7[dayKA + i] =
        min(
          day7[dayJH + i],
          iff(
            or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
            (day6[dayDV + i]
              + (day6[dayDW + i] - day6[dayDV + i]) / Overall_harmonious_range
                * (day7[dayHS + i] - Overall_harmonious_min_perc))
          ))
        + min(day7[dayJU + i], iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayDX + i]))
    }

    /// grid import
    let dayKB = 45625
    // JF6+JG6+JT6
    for i in 0..<365 { day7[dayKB + i] = day7[dayJF + i] + day7[dayJG + i] + day7[dayJT + i] }

    /// Checksum
    let dayKC = 45990
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    for i in 0..<365 {
      let KC = max(Double.zero, -day7[dayJH + i]) + max(Double.zero, -day7[dayJN + i]) + max(Double.zero, -day7[dayJU + i]) + max(Double.zero, -day7[dayJY + i])
      if !KC.isZero { print("Checksum error", i) }
      day7[dayKC + i] = KC
    }
    return day7
  }
}
