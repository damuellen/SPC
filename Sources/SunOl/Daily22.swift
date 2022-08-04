extension TunOl {
  func d22(hour0: [Float]) -> [Float] {
    let U: [[Int]] = hour0[113881..<(113880 + 8760)].indices.chunked(by: { hour0[$0] == hour0[$1] }).map { $0.map { $0 - 113880 } }

    let S = 96360
    let T = 105120
    let V = 122640
    let W = 131400
    let X = 140160
    let Y = 148920
    let Z = 157680
    let AA = 166440
    let AB = 175200
    let AC = 183960
    let AD = 192720
    let AE = 201480
    let AF = 210240
    let AH = 227760
    let AI = 236520
    let AJ = 245280
    let AK = 254040
    let AL = 262800
    let AM = 271560
    let AN = 280320
    let AO = 289080
    let AP = 297840
    let AQ = 306600
    let AR = 315360
    let AS = 324120
    let AT = 332880

    let U_S_AFsum = hour0.sumOf(AF, days: U, condition: S, predicate: { $0 > 0 })
    let U_S_ATsum = hour0.sumOf(AT, days: U, condition: S, predicate: { $0 > 0 })
    let U_S_Xsum = hour0.sumOf(X, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_ALsum = hour0.sumOf(AL, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_Vsum = hour0.sumOf(V, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_AJsum = hour0.sumOf(AJ, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_Wsum = hour0.sumOf(W, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_AKsum = hour0.sumOf(AK, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_Ysum = hour0.sumOf(Y, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_AMsum = hour0.sumOf(AM, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_AEsum = hour0.sumOf(AE, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_ASsum = hour0.sumOf(AS, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_AEsumZero = hour0.sumOf(AE, days: U, condition: S, predicate: { $0.isZero })
    let U_S_Zsum = hour0.sumOf(Z, days: U, condition: S, predicate: { $0 > 0 })
    let U_S_ANsum = hour0.sumOf(AN, days: U, condition: S, predicate: { $0 > 0 })
    let U_S_AAsum = hour0.sumOf(AA, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_AOsum = hour0.sumOf(AO, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_ABsum = hour0.sumOf(AB, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_APsum = hour0.sumOf(AP, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_ACsum = hour0.sumOf(AC, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_AQsum = hour0.sumOf(AQ, days: U, condition: AH, predicate: { $0 > 0 })
    let U_S_ADsum = hour0.sumOf(AD, days: U, condition: S, predicate: { $0 > 0 })
    let U_AH_ARsum = hour0.sumOf(AR, days: U, condition: AH, predicate: { $0 > 0 })

    let N = 341640
    let S_Nsum = hour0.sumOf(N, days: U, condition: S, predicate: { $0 > 0 })
    let AU = 271560
    let U_AH_AUsum = hour0.sumOf(AU, days: U, condition: AH, predicate: { $0 > 0 })
    let Nsum = hour0.sum(days: U, range: N)

    let Ssum = hour0.sum(days: U, range: S)
    let Tsum = hour0.sum(days: U, range: T)
    let AIsum = hour0.sum(days: U, range: AI)
    let AFsum = hour0.sum(days: U, range: AF)
    let Xsum = hour0.sum(days: U, range: X)
    let Ysum = hour0.sum(days: U, range: Y)
    let Vsum = hour0.sum(days: U, range: V)
    let Wsum = hour0.sum(days: U, range: W)

    let AAsum = hour0.sum(days: U, range: AA)
    let ABsum = hour0.sum(days: U, range: AB)
    let ACsum = hour0.sum(days: U, range: AC)
    let ADsum = hour0.sum(days: U, range: AD)
    let AHsum = hour0.sum(days: U, range: AH)

    var d22 = [Float](repeating: .zero, count: 14235)

    /// Available day op PV elec after CSP, PB stby aux
    let DM = 13140
    // =SUMIFS(Calculation!$N$5:$N$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,">0")
    for i in 0..<365 { d22[DM + i] = S_Nsum[i] }

    /// Available night op PV elec after CSP, PB stby aux
    let DN = 13505
    // =SUMIFS(Calculation!$AU$5:$AU$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,">0")
    for i in 0..<365 { d22[DN + i] = U_AH_AUsum[i] }

    /// Available day op  CSP heat
    let DO = 13870
    // =SUMIF(Calculation!$U$5:$U$8764,"="&$A3,Calculation!$N$5:$N$8764)-DM3
    for i in 0..<365 { d22[DO + i] = Nsum[i] - d22[DM + i] }

    /// El cons considering min harm op during harm op period
    let DR = 0
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    for i in 0..<365 { d22[DR + i] = Ssum[i] }

    /// El cons considering max harm op during harm op period
    let DS = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    for i in 0..<365 { d22[DS + i] = AHsum[i] }

    /// Heat cons considering min harm op during harm op period
    let DT = 730
    // SUMIF(CalculationU5:U8763,"="A6,CalculationT5:T8763)
    for i in 0..<365 { d22[DT + i] = Tsum[i] }

    /// Heat cons considering max harm op during harm op period
    let DU = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAI5:AI8763)
    for i in 0..<365 { d22[DU + i] = AIsum[i] }

    /// Max grid export after min harm op during harm op period
    let DV = 1460
    // SUMIFS(CalculationAF5:AF8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[DV + i] = U_S_AFsum[i] }

    /// Max grid export after max harm op during harm op period
    let DW = 1825
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[DW + i] = U_S_ATsum[i] }

    /// Max grid export after min/max harm op outside of harm op period
    let DX = 2190
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    for i in 0..<365 { d22[DX + i] = AFsum[i] - d22[DV + i] }

    /// Grid cons considering min harm op during harm op period
    let DY = 2555
    // SUMIFS(CalculationX5:X8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[DY + i] = U_S_Xsum[i] }

    /// Grid cons considering max harm op during harm op period
    let DZ = 2920
    // SUMIFS(CalculationAL5:AL8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[DZ + i] = U_AH_ALsum[i] }

    /// Grid cons considering min/max harm op outside harm op period
    let EA = 3285
    // SUMIF(CalculationU5:U8763,"="A6,CalculationX5:X8763)-DY6
    for i in 0..<365 { d22[EA + i] = Xsum[i] - d22[DY + i] }

    /// Remaining PV el after min harm during harm op period
    let EB = 3650
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EB + i] = U_S_Vsum[i] }

    /// Remaining PV el after max harm during harm op period
    let EC = 4015
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EC + i] = U_AH_AJsum[i] }

    /// Remaining PV el after min harm outside harm op period
    let ED = 4380
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    for i in 0..<365 { d22[ED + i] = Vsum[i] - d22[EB + i] }

    /// Remaining CSP heat after min harm during harm op period
    let EE = 4745
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EE + i] = U_S_Wsum[i] }

    /// Remaining CSP heat after max harm during harm op period
    let EF = 5110
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EF + i] = U_AH_AKsum[i] }

    /// Remaining CSP heat after min harm outside harm op period
    let EG = 5475
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    for i in 0..<365 { d22[EG + i] = Wsum[i] - d22[EE + i] }

    /// Remaining grid import cap after min harm during harm op period
    let EH = 5840
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EH + i] = U_S_Ysum[i] }

    /// Remaining grid import cap after max harm during harm op period
    let EI = 6205
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EI + i] = U_AH_AMsum[i] }

    /// Remaining grid import cap after min harm outside harm op period
    let EJ = 6570
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    for i in 0..<365 { d22[EJ + i] = Ysum[i] - d22[EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let EK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EK + i] = min(U_S_AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let EL = 7300
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EL + i] = min(U_AH_ASsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
    let EM = 7665
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EM + i] = min(U_S_AEsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

    /// El boiler op for min harm during harm op period
    let EN = 8030
    // SUMIFS(CalculationZ5:Z8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EN + i] = U_S_Zsum[i] }

    /// El boiler op for max harm during harm op period
    let EO = 8395
    // SUMIFS(CalculationAN5:AN8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EO + i] = U_S_ANsum[i] }

    /// Remaining El boiler cap after min harm during harm op period
    let EP = 8760
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EP + i] = U_S_AAsum[i] }

    /// Remaining El boiler cap after max harm during harm op period
    let EQ = 9125
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EQ + i] = U_AH_AOsum[i] }

    /// Remaining El boiler cap after min harm outside harm op period
    let ER = 9490
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    for i in 0..<365 { d22[ER + i] = AAsum[i] - d22[EP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    let ES = 9855
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[ES + i] = U_S_ABsum[i] }

    /// Remaining MethSynt cap after max harm during harm op period
    let ET = 10220
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[ET + i] = U_AH_APsum[i] }

    /// Remaining MethSynt cap after min harm outside of harm op period
    let EU = 10585
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    for i in 0..<365 { d22[EU + i] = ABsum[i] - d22[ES + i] }

    /// Remaining CCU cap after min harm during harm op period
    let EV = 10950
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EV + i] = U_S_ACsum[i] }

    /// Remaining CCU cap after max harm during harm op period
    let EW = 11315
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EW + i] = U_AH_AQsum[i] }

    /// Remaining CCU cap after min harm outside of harm op period
    let EX = 11680
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    for i in 0..<365 { d22[EX + i] = ACsum[i] - d22[EV + i] }

    /// Remaining EY cap after min harm during harm op period
    let EY = 12045
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { d22[EY + i] = U_S_ADsum[i] }

    /// Remaining EY cap after max harm during harm op period
    let EZ = 12410
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { d22[EZ + i] = U_AH_ARsum[i] }

    /// Remaining EY cap after min harm outside of harm op period
    let FA = 12775
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    for i in 0..<365 { d22[FA + i] = ADsum[i] - d22[EY + i] }
    return d22
  }
}
