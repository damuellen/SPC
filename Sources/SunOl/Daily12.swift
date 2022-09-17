extension TunOl {
  func d12(case j: Int, _ d12: inout [Double], hour: [Double], hour4: [Double]) {
    let daysEZ: [[Int]] = hour4[254041..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] }).map { $0.map { $0 - 254040 } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let (ET, EU, EX, EY, FA) = (210240, 219000, 236520, 245280, 262800)
    let (FB, FC, FD, FE, FF) = (271560, 280320, 289080, 297840, 306600)
    let (FG, FH, FI, FJ, FK) = (315360, 324120, 332880, 341640, 350400)
    let (FL, FM, FO, FP, FQ) = (359160, 367920, 385440, 394200, 402960)
    let (FR, FS, FT, FU, FV) = (411720, 420480, 429240, 438000, 446760)
    let (FW, FX, FY, FZ, GA) = (455520, 464280, 473040, 481800, 490560)
    let GU: Int = 0
    /// Available elec after TES chrg outside harm op period
    let GV: Int = 365

    let TB: Int = 508080
    /// Available elec after TES chrg during harm op period
    // SUMIFS(Calculation!$TB$5:$TB$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hour4.sumOf(TB, days: daysEZ, into: &d12, at: GU, condition: EX, predicate: notZero)

    let TC: Int = 499320
    // SUMIFS(Calculation!$TC$5:$TC$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hour4.sumOf(TC, days: daysEZ, into: &d12, at: GV, condition: FO, predicate: notZero)

    /// Available heat after TES chrg during harm op period
    let GW: Int = 730
    let GX: Int = 1095

    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$TB$5:$TB$8764)-GU6
    hour4.sum(days: daysEZ, range: TB, into: &d12, at: GW)

    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    // for i in 0..<365 { d12[GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }

    /// Harm el cons considering min harm op during harm op period
    let GY: Int = 1460
    hour4.sumOf(FA, days: daysEZ, into: &d12, at: GY, condition: EX, predicate: notZero)
    // SUMIF(Calculation!EZ$5:EZ8764,"="A6,Calculation!$EX$5:$EX$8764)+SUMIFS(Calculation!FA5:FA8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hour4.sum(days: daysEZ, range: EX, into: &d12, at: GY)

    /// Harm el cons considering max harm op during harm op period
    let GZ: Int = 1825
    hour4.sum(days: daysEZ, range: FO, into: &d12, at: GX)
    hour4.sumOf(FA, days: daysEZ, into: &d12, at: GZ, condition: FO, predicate: notZero)
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764)+SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    for i in 0..<365 { d12[GZ + i] += d12[GX + i] }

    /// Harm el cons outside of harm op period
    let HA: Int = 2190
    hour4.sumOf(FA, days: daysEZ, into: &d12, at: HA, condition: EX, predicate: { $0.isZero })
    // MAX(0,SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d12[HA + i] = max(0, d12[HA + i] - overall_stup_cons[j]) }

    /// Harm heat cons considering min harm op during harm op period
    let HB: Int = 2555
    hour4.sum(days: daysEZ, range: EY, into: &d12, at: GX)
    hour4.sumOf(FB, days: daysEZ, into: &d12, at: HB, condition: EX, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d12[HB + i] += d12[GX + i] }

    /// Harm heat cons considering max harm op during harm op period
    let HC: Int = 2920
    hour4.sum(days: daysEZ, range: FP, into: &d12, at: GX)
    hour4.sumOf(FB, days: daysEZ, into: &d12, at: HC, condition: FO, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d12[HC + i] += d12[GX + i] }

    /// Harm heat cons outside of harm op period
    let HD: Int = 3285
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    hour4.sumOf(FB, days: daysEZ, into: &d12, at: HD, condition: EX, predicate: { $0.isZero })

    /// Grid import considering min harm op during harm op period
    let HE: Int = 3650
    // SUMIFS(Calculation!$FE$5:$FE$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hour4.sumOf(FE, days: daysEZ, into: &d12, at: HE, condition: EX, predicate: notZero)

    /// Grid import considering max harm op during harm op period
    let HF: Int = 4015
    // SUMIFS(Calculation!$FS$5:$FS$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hour4.sumOf(FS, days: daysEZ, into: &d12, at: HF, condition: FO, predicate: notZero)

    /// Grid import  outside of harm op period
    let HG: Int = 4380
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FE$5:$FE$8764)-HE6
    hour4.sum(days: daysEZ, range: FE, into: &d12, at: HG)
    for i in 0..<365 { d12[HG + i] -= d12[HE + i] }

    /// El boiler op considering min harm op during harm op period
    let HH: Int = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FG, days: daysEZ, into: &d12, at: HH, condition: EX, predicate: notZero)

    /// El boiler op considering max harm op during harm op period
    let HI: Int = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FU, days: daysEZ, into: &d12, at: HI, condition: FO, predicate: notZero)

    /// El boiler op outside harm op period
    let HJ: Int = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    hour4.sum(days: daysEZ, range: FG, into: &d12, at: HJ)
    for i in 0..<365 { d12[HJ + i] -= d12[HH + i] }
    /// Total aux cons during harm op period
    let HK: Int = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(ET, days: daysEZ, into: &d12, at: HK, condition: EX, predicate: notZero)

    /// Total aux cons outside of harm op period
    let HL: Int = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    hour4.sum(days: daysEZ, range: ET, into: &d12, at: HL)
    for i in 0..<365 { d12[HL + i] -= d12[HK + i] }

    /// El cons not covered during harm op period
    let HM: Int = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(EU, days: daysEZ, into: &d12, at: HM, condition: EX, predicate: notZero)

    /// El cons not covered outside of harm op period
    let HN: Int = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    hour4.sum(days: daysEZ, range: EU, into: &d12, at: HN)
    for i in 0..<365 { d12[HN + i] -= d12[HM + i] }

    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let HO: Int = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FC, days: daysEZ, into: &d12, at: HO, condition: EX, predicate: notZero)

    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let HP: Int = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FQ, days: daysEZ, into: &d12, at: HP, condition: FO, predicate: notZero)

    /// Remaining PV el outside of harm op period
    let HQ: Int = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    hour4.sum(days: daysEZ, range: FC, into: &d12, at: HQ)
    for i in 0..<365 { d12[HQ + i] -= d12[HO + i] }

    /// Remaining CSP heat after min harm during harm op period
    let HR: Int = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FD, days: daysEZ, into: &d12, at: HR, condition: EX, predicate: notZero)

    /// Remaining CSP heat after max harm op during harm op period
    let HS: Int = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FR, days: daysEZ, into: &d12, at: HS, condition: FO, predicate: notZero)

    /// Remaining CSP heat outside of harm op period
    let HT: Int = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    hour4.sum(days: daysEZ, range: FD, into: &d12, at: HT)
    for i in 0..<365 { d12[HT + i] -= d12[HR + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let HU: Int = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hour4.sumOf(FL, days: daysEZ, into: &d12, at: HU, condition: EX, predicate: notZero)
    for i in 0..<365 { d12[HU + i] = min(d12[HU + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after max harm op during harm op period
    let HV: Int = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hour4.sumOf(FZ, days: daysEZ, into: &d12, at: HV, condition: FO, predicate: notZero)
    for i in 0..<365 { d12[HV + i] = min(d12[HV + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep outside of harm op period
    let HW: Int = 10220
    hour4.sumOf(FL, days: daysEZ, into: &d12, at: HW, condition: EX, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d12[HW + i] = min(d12[HW + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max grid export after min harm cons during harm op period
    let HX: Int = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FM, days: daysEZ, into: &d12, at: HX, condition: EX, predicate: notZero)

    /// Max grid export after max harm cons during harm op period
    let HY: Int = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(GA, days: daysEZ, into: &d12, at: HY, condition: FO, predicate: notZero)

    /// Max grid export outside of harm op period
    let HZ: Int = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    hour4.sum(days: daysEZ, range: FM, into: &d12, at: HZ)
    for i in 0..<365 { d12[HZ + i] -= d12[HX + i] }

    /// Remaining grid import during harm op period after min harm
    let IA: Int = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FF, days: daysEZ, into: &d12, at: IA, condition: EX, predicate: notZero)

    /// Remaining grid import during harm op period after max harm
    let IB: Int = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FT, days: daysEZ, into: &d12, at: IB, condition: FO, predicate: notZero)

    /// Remaining grid import outside of harm op period
    let IC: Int = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    hour4.sum(days: daysEZ, range: FF, into: &d12, at: IC)
    for i in 0..<365 { d12[IC + i] -= d12[IA + i] }

    /// Remaining El boiler cap during harm op period after min harm
    let ID: Int = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FH, days: daysEZ, into: &d12, at: ID, condition: EX, predicate: notZero)

    /// Remaining El boiler cap during harm op period after max harm
    let IE: Int = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FV, days: daysEZ, into: &d12, at: IE, condition: FO, predicate: notZero)

    /// Remaining El boiler cap outside of harm op period
    let IF: Int = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    hour4.sum(days: daysEZ, range: FH, into: &d12, at: IF)
    for i in 0..<365 { d12[IF + i] -= d12[ID + i] }

    /// Remaining MethSynt cap during harm op after min harm op
    let IG: Int = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FI, days: daysEZ, into: &d12, at: IG, condition: EX, predicate: notZero)

    /// Remaining MethSynt cap during harm op period after max harm op
    let IH: Int = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FW, days: daysEZ, into: &d12, at: IH, condition: FO, predicate: notZero)

    /// Remaining MethSynt cap outside of harm op period
    let II: Int = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    hour4.sum(days: daysEZ, range: FI, into: &d12, at: II)
    for i in 0..<365 { d12[II + i] -= d12[IG + i] }

    /// Remaining CCU cap during harm op after min harm
    let IJ: Int = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FJ, days: daysEZ, into: &d12, at: IJ, condition: EX, predicate: notZero)

    /// Remaining CCU cap during harm op after max harm
    let IK: Int = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FX, days: daysEZ, into: &d12, at: IK, condition: FO, predicate: notZero)

    /// Remaining CCU cap outside of harm op after min harm
    let IL: Int = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    hour4.sum(days: daysEZ, range: FJ, into: &d12, at: IL)
    for i in 0..<365 { d12[IL + i] -= d12[IJ + i] }

    /// Remaining EY cap during harm op after min harm
    let IM: Int = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hour4.sumOf(FK, days: daysEZ, into: &d12, at: IM, condition: EX, predicate: notZero)

    /// Remaining EY cap during harm op period after max harm
    let IN: Int = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hour4.sumOf(FY, days: daysEZ, into: &d12, at: IN, condition: FO, predicate: notZero)

    /// Remaining EY cap outside of harm op period
    let IO: Int = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    hour4.sum(days: daysEZ, range: FK, into: &d12, at: IO)
    for i in 0..<365 { d12[IO + i] -= d12[IM + i] }
  }
}
