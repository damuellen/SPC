extension TunOl {
  func d22(_ h: UnsafeMutableBufferPointer<Double>)  {
    let U: [[Int]] = h[113881..<(113880 + 8760)].indices.chunked { h[$0] == h[$1] }.map { $0.map { $0 - 113880 } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }

    let (DM, DN, DO, _) = (107675, 108040, 108405, 108770)
    let (
      DR, DS, DT, DU, DV, DW, DX, DY, DZ, EA, EB, EC, ED, EE, EF, EG, EH, EI, EJ,
      EK, EL, EM, EN, EO, EP, EQ, ER, ES, ET, EU, EV, EW, EX, EY, EZ, FA
    ) = (
      109500, 109865, 110230, 110595, 110960, 111325, 111690, 112055, 112420,
      112785, 113150, 113515, 113880, 114245, 114610, 114975, 115340, 115705,
      116070, 116435, 116800, 117165, 117530, 117895, 118260, 118625, 118990,
      119355, 119720, 120085, 120450, 120815, 121180, 121545, 121910, 122275
    )

    /// Available day op PV elec after CSP, PB stby aux
    // =SUMIFS(Calculation!$N$5:$N$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,">0")
    h.sumOf(N, days: U, at: DM, condition: S, predicate: notZero)
    /// Available night op PV elec after CSP, PB stby aux
    // =SUMIFS(Calculation!$AU$5:$AU$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,">0")
    h.sumOf(AU, days: U, at: DN, condition: AH, predicate: notZero)
    /// Available day op  CSP heat
    // =SUMIF(Calculation!$U$5:$U$8764,"="&$A3,Calculation!$N$5:$N$8764)-DM3
    h.sum(days: U, range: N, at: DO)
    for i in 0..<365 { h[DO + i] -= h[DM + i] }

    /// El cons considering min harm op during harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    h.sum(days: U, range: S, at: DR)

    /// El cons considering max harm op during harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    h.sum(days: U, range: AH, at: DS)

    /// El demand outside min harm op during standby
    // DT=SUMIFS(Calculation!$TX$5:$TX$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    h.sumOf(TX, days: U, at: DT, condition: S, predicate: { $0.isZero })

    /// El demand outside max harm op during standby
    // DU=SUMIFS(Calculation!$UB$5:$UB$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    h.sumOf(UB, days: U, at: DU, condition: AH, predicate: { $0.isZero })
    /// Max grid export after min harm op during harm op period
    // SUMIFS(CalculationAF5:AF8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AF, days: U, at: DV, condition: S, predicate: notZero)

    /// Max grid export after max harm op during harm op period
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AT, days: U, at: DW, condition: S, predicate: notZero)
    /// Max grid export after min/max harm op outside of harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    h.sum(days: U, range: AF, at: DX)
    for i in 0..<365 { h[DX + i] -= h[DV + i] }

    /// Heat demand outside min harm op during standby
    // DY=SUMIFS(Calculation!$TY$5:$TY$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    h.sumOf(TY, days: U, at: DY, condition: S, predicate: { $0.isZero })
    /// Heat demand outside max harm op during standby
    // DZ=SUMIFS(Calculation!$UC$5:$UC$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    h.sumOf(UC, days: U, at: DZ, condition: AH, predicate: { $0.isZero })
    /// Grid cons considering min/max harm op outside harm op period
    // EA=SUMIFS(Calculation!$X$5:$X$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    h.sumOf(X, days: U, at: EA, condition: S, predicate: { $0.isZero })

    /// Remaining PV el after min harm during harm op period
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(V, days: U, at: EB, condition: S, predicate: notZero)

    /// Remaining PV el after max harm during harm op period
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AJ, days: U, at: EC, condition: AH, predicate: notZero)

    /// Remaining PV el after min harm outside harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    h.sum(days: U, range: V, at: ED)
    for i in 0..<365 { h[ED + i] -= h[EB + i] }

    /// Remaining CSP heat after min harm during harm op period
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(W, days: U, at: EE, condition: S, predicate: notZero)

    /// Remaining CSP heat after max harm during harm op period
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AK, days: U, at: EF, condition: AH, predicate: notZero)

    /// Remaining CSP heat after min harm outside harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    h.sum(days: U, range: W, at: EG)
    for i in 0..<365 { h[EG + i] -= h[EE + i] }

    /// Remaining grid import cap after min harm during harm op period
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(Y, days: U, at: EH, condition: S, predicate: notZero)

    /// Remaining grid import cap after max harm during harm op period
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AM, days: U, at: EI, condition: AH, predicate: notZero)

    /// Remaining grid import cap after min harm outside harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    h.sum(days: U, range: Y, at: EJ)
    for i in 0..<365 { h[EJ + i] -= h[EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    h.sumOf(AE, days: U, at: EK, condition: S, predicate: notZero)
    for i in 0..<365 { h[EK + i] = min(h[EK + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
        h.sumOf(AS, days: U, at: EL, condition: AH, predicate: notZero)
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { h[EL + i] = min(h[EL + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
        h.sumOf(AE, days: U, at: EM, condition: S) { $0.isZero }
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { h[EM + i] = min(h[EM + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Remaining PV el outside min harm during standby
    // =SUMIFS(Calculation!$TZ$5:$TZ$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$S$5:$S$8764,"=0")
    h.sumOf(TZ, days: U, at: EN, condition: S, predicate: { $0.isZero })

    /// Remaining PV el outside max harm during standby
    // =SUMIFS(Calculation!$UD$5:$UD$8764,Calculation!$U$5:$U$8764,"="&$A3,Calculation!$AH$5:$AH$8764,"=0")
    h.sumOf(UD, days: U, at: EO, condition: AH, predicate: { $0.isZero })

    /// Remaining El boiler cap after min harm during harm op period
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AA, days: U, at: EP, condition: S, predicate: notZero)

    /// Remaining El boiler cap after max harm during harm op period
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AO, days: U, at: EQ, condition: AH, predicate: notZero)

    /// Remaining El boiler cap after min harm outside harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    h.sum(days: U, range: AA, at: ER)
    for i in 0..<365 { h[ER + i] -= h[EP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AB, days: U, at: ES, condition: S, predicate: notZero)

    /// Remaining MethSynt cap after max harm during harm op period
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AP, days: U, at: ET, condition: AH, predicate: notZero)

    /// Remaining MethSynt cap after min harm outside of harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    h.sum(days: U, range: AB, at: EU)
    for i in 0..<365 { h[EU + i] -= h[ES + i] }

    /// Remaining CCU cap after min harm during harm op period
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AC, days: U, at: EV, condition: S, predicate: notZero)

    /// Remaining CCU cap after max harm during harm op period
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AQ, days: U, at: EW, condition: AH, predicate: notZero)

    /// Remaining CCU cap after min harm outside of harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    h.sum(days: U, range: AC, at: EX)
    for i in 0..<365 { h[EX + i] -= h[EV + i] }

    /// Remaining EY cap after min harm during harm op period
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    h.sumOf(AD, days: U, at: EY, condition: S, predicate: notZero)

    /// Remaining EY cap after max harm during harm op period
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    h.sumOf(AR, days: U, at: EZ, condition: AH, predicate: notZero)
    /// Remaining EY cap after min harm outside of harm op period
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    h.sum(days: U, range: AD, at: FA)
    for i in 0..<365 { h[FA + i] -= h[EY + i] }
  }
}
