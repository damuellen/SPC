extension TunOl {
  func d22(hour: [Double], d20: [Double]) -> [Double] {
    let U: [[Int]] = hour[113881..<(113880 + 8760)].indices.chunked { hour[$0] == hour[$1] }.map { $0.map { $0 - 113880 } }
    let (S, _, V, W, X, Y, _, AA, AB, AC, AD, AE, AF, AH, _, AJ, AK, _, AM, _, AO, AP, AQ, AR, AS, AT) = (
      96360, 105120, 122640, 131400, 140160, 148920, 157680, 166440, 175200, 183960, 192720, 201480, 210240, 227760, 236520, 245280, 254040, 262800, 271560, 280320, 289080, 297840, 306600, 315360, 324120, 332880
    )
    let notZero: (Double) -> Bool = { $0 > Double.zero }

    let N = 52560
    let AU = 341640
    let (TX, TY, TZ) = (1033680, 1042440, 1051200)
    let (UB, UC, UD) = (1059960, 1068720, 1077480)
    var d22 = [Double](repeating: Double.zero, count: 14235)

    /// Available day op PV elec after CSP, PB stby aux
    let DM = 13140
    // =SUMIFS(Calculation!$N$5:$N$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,">0")
    hour.sumOf(N, days: U, into: &d22, at: DM, condition: S, predicate: notZero)
    /// Available night op PV elec after CSP, PB stby aux
    let DN = 13505
    // =SUMIFS(Calculation!$AU$5:$AU$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,">0")
    hour.sumOf(AU, days: U, into: &d22, at: DN, condition: AH, predicate: notZero)
    /// Available day op  CSP heat
    let DO = 13870
    // =SUMIF(Calculation!$U$5:$U$8764,"="&$A3,Calculation!$N$5:$N$8764)-DM3
    hour.sum(days: U, range: N, into: &d22, at: DO)
    for i in 0..<365 { d22[DO + i] -= d22[DM + i] }

    /// El cons considering min harm op during harm op period
    let DR = 0
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    hour.sum(days: U, range: S, into: &d22, at: DR)

    /// El cons considering max harm op during harm op period
    let DS = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    hour.sum(days: U, range: AH, into: &d22, at: DS)

    /// El demand outside min harm op during standby
    let DT = 730
    // DT=SUMIFS(Calculation!$TX$5:$TX$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    hour.sumOf(TX, days: U, into: &d22, at: DT, condition: S, predicate: { $0.isZero })

    /// El demand outside max harm op during standby
    let DU = 1095
    // DU=SUMIFS(Calculation!$UB$5:$UB$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    hour.sumOf(UB, days: U, into: &d22, at: DU, condition: AH, predicate: { $0.isZero })
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
    hour.sum(days: U, range: AF, into: &d22, at: DX)
    for i in 0..<365 { d22[DX + i] -= d22[DV + i] }

    /// Heat demand outside min harm op during standby
    let DY = 2555
    // DY=SUMIFS(Calculation!$TY$5:$TY$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    hour.sumOf(TY, days: U, into: &d22, at: DY, condition: S, predicate: { $0.isZero })
    /// Heat demand outside max harm op during standby
    let DZ = 2920
    // DZ=SUMIFS(Calculation!$UC$5:$UC$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    hour.sumOf(UC, days: U, into: &d22, at: DZ, condition: AH, predicate: { $0.isZero })
    /// Grid cons considering min/max harm op outside harm op period
    let EA = 3285
    // EA=SUMIFS(Calculation!$X$5:$X$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    hour.sumOf(X, days: U, into: &d22, at: EA, condition: S, predicate: { $0.isZero })

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
    hour.sum(days: U, range: V, into: &d22, at: ED)
    for i in 0..<365 { d22[ED + i] -= d22[EB + i] }

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
    hour.sum(days: U, range: W, into: &d22, at: EG)
    for i in 0..<365 { d22[EG + i] -= d22[EE + i] }

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
    hour.sum(days: U, range: Y, into: &d22, at: EJ)
    for i in 0..<365 { d22[EJ + i] -= d22[EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let EK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hour.sumOf(AE, days: U, into: &d22, at: EK, condition: S, predicate: notZero)
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

    /// Remaining PV el outside min harm during standby
    let EN = 8030
    // =SUMIFS(Calculation!$TZ$5:$TZ$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    hour.sumOf(TZ, days: U, into: &d22, at: EN, condition: S, predicate: { $0.isZero })

    /// Remaining PV el outside max harm during standby
    let EO = 8395
    // =SUMIFS(Calculation!$UD$5:$UD$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    hour.sumOf(UD, days: U, into: &d22, at: EO, condition: AH, predicate: { $0.isZero })

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
    hour.sum(days: U, range: AA, into: &d22, at: ER)
    for i in 0..<365 { d22[ER + i] -= d22[EP + i] }

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
    hour.sum(days: U, range: AB, into: &d22, at: EU)
    for i in 0..<365 { d22[EU + i] -= d22[ES + i] }

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
    hour.sum(days: U, range: AC, into: &d22, at: EX)
    for i in 0..<365 { d22[EX + i] -= d22[EV + i] }

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
    hour.sum(days: U, range: AD, into: &d22, at: FA)
    for i in 0..<365 { d22[FA + i] -= d22[EY + i] }
    return d22
  }
}
