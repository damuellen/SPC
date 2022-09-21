extension TunOl {
  func d12(_ d12: inout [Double], hourFinal: [Double] , case j: Int) {
    let daysEZ: [[Int]] = hourFinal[254041..<(254040 + 8760)].indices.chunked(by: { hourFinal[$0] == hourFinal[$1] }).map { $0.map { $0 - 254040 } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let (ET, EU, EX, EY, FA) = (210240, 219000, 236520, 245280, 262800)
    let (FB, FC, FD, FE, FF) = (271560, 280320, 289080, 297840, 306600)
    let (FG, FH, FI, FJ, FK) = (315360, 324120, 332880, 341640, 350400)
    let (FL, FM, FO, FP, FQ) = (359160, 367920, 385440, 394200, 402960)
    let (FR, FS, FT, FU, FV) = (411720, 420480, 429240, 438000, 446760)
    let (FW, FX, FY, FZ, GA) = (455520, 464280, 473040, 481800, 490560)
    let GU: Int = 17155
    /// Available elec after TES chrg outside harm op period
    let GV: Int = 17520
    let TB: Int = 508080
    /// Available elec after TES chrg during harm op period
    // SUMIFS(Calculation!$TB$5:$TB$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(TB, days: daysEZ, into: &d12, at: GU, condition: EX, predicate: notZero)
    let TC: Int = 499320
    // SUMIFS(Calculation!$TC$5:$TC$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(TC, days: daysEZ, into: &d12, at: GV, condition: FO, predicate: notZero)
    /// Available heat after TES chrg during harm op period
    let GW: Int = 17885
    let GX: Int = 18250
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$TB$5:$TB$8764)-GU6
    hourFinal.sum(days: daysEZ, range: TB, into: &d12, at: GW)
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    // for i in 0..<365 { d12[GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }
    /// Harm el cons considering min harm op during harm op period
    let GY: Int = 18615
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GY, condition: EX, predicate: notZero)
    // SUMIF(Calculation!EZ$5:EZ8764,"="A6,Calculation!$EX$5:$EX$8764)+SUMIFS(Calculation!FA5:FA8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sum(days: daysEZ, range: EX, into: &d12, at: GY)
    /// Harm el cons considering max harm op during harm op period
    let GZ: Int = 18980
    hourFinal.sum(days: daysEZ, range: FO, into: &d12, at: GX)
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GZ, condition: FO, predicate: notZero)
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764)+SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    for i in 0..<365 { d12[GZ + i] += d12[GX + i] }
    /// Harm el cons outside of harm op period
    let HA: Int = 19345
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: HA, condition: EX, predicate: { $0.isZero })
    // MAX(0,SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d12[HA + i] = max(0, d12[HA + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    let HB: Int = 19710
    hourFinal.sum(days: daysEZ, range: EY, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HB, condition: EX, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d12[HB + i] += d12[GX + i] }
    /// Harm heat cons considering max harm op during harm op period
    let HC: Int = 20075
    hourFinal.sum(days: daysEZ, range: FP, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HC, condition: FO, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d12[HC + i] += d12[GX + i] }
    /// Harm heat cons outside of harm op period
    let HD: Int = 20440
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HD, condition: EX, predicate: { $0.isZero })
    /// Grid import considering min harm op during harm op period
    let HE: Int = 20805
    // SUMIFS(Calculation!$FE$5:$FE$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(FE, days: daysEZ, into: &d12, at: HE, condition: EX, predicate: notZero)
    /// Grid import considering max harm op during harm op period
    let HF: Int = 21170
    // SUMIFS(Calculation!$FS$5:$FS$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(FS, days: daysEZ, into: &d12, at: HF, condition: FO, predicate: notZero)
    /// Grid import  outside of harm op period
    let HG: Int = 21535
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FE$5:$FE$8764)-HE6
    hourFinal.sum(days: daysEZ, range: FE, into: &d12, at: HG)
    for i in 0..<365 { d12[HG + i] -= d12[HE + i] }
    /// El boiler op considering min harm op during harm op period
    let HH: Int = 21900
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FG, days: daysEZ, into: &d12, at: HH, condition: EX, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    let HI: Int = 22265
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FU, days: daysEZ, into: &d12, at: HI, condition: FO, predicate: notZero)
    /// El boiler op outside harm op period
    let HJ: Int = 22630
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    hourFinal.sum(days: daysEZ, range: FG, into: &d12, at: HJ)
    for i in 0..<365 { d12[HJ + i] -= d12[HH + i] }
    /// Total aux cons during harm op period
    let HK: Int = 22995
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(ET, days: daysEZ, into: &d12, at: HK, condition: EX, predicate: notZero)
    /// Total aux cons outside of harm op period
    let HL: Int = 23360
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    hourFinal.sum(days: daysEZ, range: ET, into: &d12, at: HL)
    for i in 0..<365 { d12[HL + i] -= d12[HK + i] }
    /// El cons not covered during harm op period
    let HM: Int = 23725
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(EU, days: daysEZ, into: &d12, at: HM, condition: EX, predicate: notZero)
    /// El cons not covered outside of harm op period
    let HN: Int = 24090
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    hourFinal.sum(days: daysEZ, range: EU, into: &d12, at: HN)
    for i in 0..<365 { d12[HN + i] -= d12[HM + i] }
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let HO: Int = 24455
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FC, days: daysEZ, into: &d12, at: HO, condition: EX, predicate: notZero)
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let HP: Int = 24820
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FQ, days: daysEZ, into: &d12, at: HP, condition: FO, predicate: notZero)
    /// Remaining PV el outside of harm op period
    let HQ: Int = 25185
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    hourFinal.sum(days: daysEZ, range: FC, into: &d12, at: HQ)
    for i in 0..<365 { d12[HQ + i] -= d12[HO + i] }
    /// Remaining CSP heat after min harm during harm op period
    let HR: Int = 25550
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FD, days: daysEZ, into: &d12, at: HR, condition: EX, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    let HS: Int = 25915
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FR, days: daysEZ, into: &d12, at: HS, condition: FO, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    let HT: Int = 26280
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    hourFinal.sum(days: daysEZ, range: FD, into: &d12, at: HT)
    for i in 0..<365 { d12[HT + i] -= d12[HR + i] }
    /// Max elec to BESS for night prep after min harm op during harm op period
    let HU: Int = 26645
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HU, condition: EX, predicate: notZero)
    for i in 0..<365 { d12[HU + i] = min(d12[HU + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep after max harm op during harm op period
    let HV: Int = 27010
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FZ, days: daysEZ, into: &d12, at: HV, condition: FO, predicate: notZero)
    for i in 0..<365 { d12[HV + i] = min(d12[HV + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep outside of harm op period
    let HW: Int = 27375
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HW, condition: EX, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d12[HW + i] = min(d12[HW + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    let HX: Int = 27740
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FM, days: daysEZ, into: &d12, at: HX, condition: EX, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    let HY: Int = 28105
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(GA, days: daysEZ, into: &d12, at: HY, condition: FO, predicate: notZero)
    /// Max grid export outside of harm op period
    let HZ: Int = 28470
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    hourFinal.sum(days: daysEZ, range: FM, into: &d12, at: HZ)
    for i in 0..<365 { d12[HZ + i] -= d12[HX + i] }
    /// Remaining grid import during harm op period after min harm
    let IA: Int = 28835
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FF, days: daysEZ, into: &d12, at: IA, condition: EX, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    let IB: Int = 29200
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FT, days: daysEZ, into: &d12, at: IB, condition: FO, predicate: notZero)
    /// Remaining grid import outside of harm op period
    let IC: Int = 29565
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    hourFinal.sum(days: daysEZ, range: FF, into: &d12, at: IC)
    for i in 0..<365 { d12[IC + i] -= d12[IA + i] }
    /// Remaining El boiler cap during harm op period after min harm
    let ID: Int = 29930
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FH, days: daysEZ, into: &d12, at: ID, condition: EX, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    let IE: Int = 30295
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FV, days: daysEZ, into: &d12, at: IE, condition: FO, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    let IF: Int = 30660
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    hourFinal.sum(days: daysEZ, range: FH, into: &d12, at: IF)
    for i in 0..<365 { d12[IF + i] -= d12[ID + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    let IG: Int = 31025
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FI, days: daysEZ, into: &d12, at: IG, condition: EX, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    let IH: Int = 31390
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FW, days: daysEZ, into: &d12, at: IH, condition: FO, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    let II: Int = 31755
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    hourFinal.sum(days: daysEZ, range: FI, into: &d12, at: II)
    for i in 0..<365 { d12[II + i] -= d12[IG + i] }
    /// Remaining CCU cap during harm op after min harm
    let IJ: Int = 32120
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FJ, days: daysEZ, into: &d12, at: IJ, condition: EX, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    let IK: Int = 32485
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FX, days: daysEZ, into: &d12, at: IK, condition: FO, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    let IL: Int = 32850
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    hourFinal.sum(days: daysEZ, range: FJ, into: &d12, at: IL)
    for i in 0..<365 { d12[IL + i] -= d12[IJ + i] }
    /// Remaining EY cap during harm op after min harm
    let IM: Int = 33215
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FK, days: daysEZ, into: &d12, at: IM, condition: EX, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    let IN: Int = 33580
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FY, days: daysEZ, into: &d12, at: IN, condition: FO, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    let IO: Int = 33945
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    hourFinal.sum(days: daysEZ, range: FK, into: &d12, at: IO)
    for i in 0..<365 { d12[IO + i] -= d12[IM + i] }
  }
}
