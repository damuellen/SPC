extension TunOl {
  func d22(hour: [Double]) -> [Double] {
    let U: [[Int]] = hour[113881..<(113880 + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - 113880 } }

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
    let notZero: (Double) -> Bool = { $0 > 0.0 }

    let N = 341640
    let S_Nsum = hour.sumOf(N, days: U, condition: S, predicate: notZero)
    let AU = 271560
    let U_AH_AUsum = hour.sumOf(AU, days: U, condition: AH, predicate: notZero)
    let Nsum = hour.sum(days: U, range: N)

    let Ssum = hour.sum(days: U, range: S)
    let Tsum = hour.sum(days: U, range: T)
    let AIsum = hour.sum(days: U, range: AI)
    let AFsum = hour.sum(days: U, range: AF)
    let Xsum = hour.sum(days: U, range: X)
    let Ysum = hour.sum(days: U, range: Y)
    let Vsum = hour.sum(days: U, range: V)
    let Wsum = hour.sum(days: U, range: W)

    let AAsum = hour.sum(days: U, range: AA)
    let ABsum = hour.sum(days: U, range: AB)
    let ACsum = hour.sum(days: U, range: AC)
    let ADsum = hour.sum(days: U, range: AD)
    let AHsum = hour.sum(days: U, range: AH)

    var d22 = [Double](repeating: 0.0, count: 14235)

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
    hour.sumOf(AF, days: U, into: &d22, at: DV, condition: S, predicate: notZero)

    /// Max grid export after max harm op during harm op period
    let DW = 1825
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AT, days: U, into: &d22, at: DW, condition: S, predicate: notZero)
    /// Max grid export after min/max harm op outside of harm op period
    let DX = 2190
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    for i in 0..<365 { d22[DX + i] = AFsum[i] - d22[DV + i] }

    /// Grid cons considering min harm op during harm op period
    let DY = 2555
    // SUMIFS(CalculationX5:X8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(X, days: U, into: &d22, at: DY, condition: S, predicate: notZero)

    /// Grid cons considering max harm op during harm op period
    let DZ = 2920
    // SUMIFS(CalculationAL5:AL8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AL, days: U, into: &d22, at: DZ, condition: AH, predicate: notZero)

    /// Grid cons considering min/max harm op outside harm op period
    let EA = 3285
    // SUMIF(CalculationU5:U8763,"="A6,CalculationX5:X8763)-DY6
    for i in 0..<365 { d22[EA + i] = Xsum[i] - d22[DY + i] }

    /// Remaining PV el after min harm during harm op period
    let EB = 3650
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(V, days: U, into: &d22, at: EB, condition: S, predicate: notZero)

    /// Remaining PV el after max harm during harm op period
    let EC = 4015
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AJ, days: U, into: &d22, at: EC, condition: AH, predicate: notZero)

    /// Remaining PV el after min harm outside harm op period
    let ED = 4380
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    for i in 0..<365 { d22[ED + i] = Vsum[i] - d22[EB + i] }

    /// Remaining CSP heat after min harm during harm op period
    let EE = 4745
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(W, days: U, into: &d22, at: EE, condition: S, predicate: notZero)

    /// Remaining CSP heat after max harm during harm op period
    let EF = 5110
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AK, days: U, into: &d22, at: EF, condition: AH, predicate: notZero)

    /// Remaining CSP heat after min harm outside harm op period
    let EG = 5475
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    for i in 0..<365 { d22[EG + i] = Wsum[i] - d22[EE + i] }

    /// Remaining grid import cap after min harm during harm op period
    let EH = 5840
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(Y, days: U, into: &d22, at: EH, condition: S, predicate: notZero)

    /// Remaining grid import cap after max harm during harm op period
    let EI = 6205
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AM, days: U, into: &d22, at: EI, condition: AH, predicate: notZero)

    /// Remaining grid import cap after min harm outside harm op period
    let EJ = 6570
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    for i in 0..<365 { d22[EJ + i] = Ysum[i] - d22[EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let EK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EK + i] = min(d22[EK + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let EL = 7300
    hour.sumOf(AS, days: U, into: &d22, at: EL, condition: AH, predicate: notZero)
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EL + i] = min(d22[EL + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
    let EM = 7665
    hour.sumOf(AE, days: U, into: &d22, at: EM, condition: S) { $0.isZero }
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d22[EM + i] = min(d22[EM + i], BESS_cap_ud / BESS_chrg_eff) }

    /// El boiler op for min harm during harm op period
    let EN = 8030
    // SUMIFS(CalculationZ5:Z8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(Z, days: U, into: &d22, at: EN, condition: S, predicate: notZero)

    /// El boiler op for max harm during harm op period
    let EO = 8395
    // SUMIFS(CalculationAN5:AN8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AN, days: U, into: &d22, at: EO, condition: S, predicate: notZero)

    /// Remaining El boiler cap after min harm during harm op period
    let EP = 8760
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AA, days: U, into: &d22, at: EP, condition: S, predicate: notZero)

    /// Remaining El boiler cap after max harm during harm op period
    let EQ = 9125
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AO, days: U, into: &d22, at: EQ, condition: AH, predicate: notZero)

    /// Remaining El boiler cap after min harm outside harm op period
    let ER = 9490
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    for i in 0..<365 { d22[ER + i] = AAsum[i] - d22[EP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    let ES = 9855
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AB, days: U, into: &d22, at: ES, condition: S, predicate: notZero)

    /// Remaining MethSynt cap after max harm during harm op period
    let ET = 10220
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AP, days: U, into: &d22, at: ET, condition: AH, predicate: notZero)

    /// Remaining MethSynt cap after min harm outside of harm op period
    let EU = 10585
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    for i in 0..<365 { d22[EU + i] = ABsum[i] - d22[ES + i] }

    /// Remaining CCU cap after min harm during harm op period
    let EV = 10950
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AC, days: U, into: &d22, at: EV, condition: S, predicate: notZero)

    /// Remaining CCU cap after max harm during harm op period
    let EW = 11315
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AQ, days: U, into: &d22, at: EW, condition: AH, predicate: notZero)

    /// Remaining CCU cap after min harm outside of harm op period
    let EX = 11680
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    for i in 0..<365 { d22[EX + i] = ACsum[i] - d22[EV + i] }

    /// Remaining EY cap after min harm during harm op period
    let EY = 12045
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    hour.sumOf(AD, days: U, into: &d22, at: EY, condition: S, predicate: notZero)

    /// Remaining EY cap after max harm during harm op period
    let EZ = 12410
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    hour.sumOf(AR, days: U, into: &d22, at: EZ, condition: AH, predicate: notZero)
    /// Remaining EY cap after min harm outside of harm op period
    let FA = 12775
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    for i in 0..<365 { d22[FA + i] = ADsum[i] - d22[EY + i] }
    return d22
  }
}
