extension TunOl {
  func day26(hour0: [Double]) -> [Double] {
    let daysU: [[Int]] = hour0[113881..<(113880 + 8760)].indices.chunked(by: { hour0[$0] == hour0[$1] }).map { $0.map { $0 - 113880 } }
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
    let U_S_AEsumZero = hour0.sumOf(hourAE, days: daysU, condition: hourS, predicate: { $0.isZero })
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

    var day5 = [Double](repeating: Double.zero, count: 1095 + 365)

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

    var day6 = [Double](repeating: Double.zero, count: 12775 + 365)

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
    for i in 0..<365 { day6[dayEM + i] = min(U_S_AEsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

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
}
