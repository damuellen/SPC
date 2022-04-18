extension TunOl {
  func d16(_ d16: inout [Double], hour0: [Double], hour4: [Double], d11: [Double], d15: [Double]) {
    let daysEZ: [[Int]] = hour4[254041..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] }).map { $0.map { $0 - 254040 } }

    let J = 26280
    let L = 43800

    let (EH, EI, EP, EQ, ET, EU, EX, EY, FA, FB, FC, FD, FE, FF, FG, FH, FI, FJ, FK, FL, FM, FO, FP, FQ, FR, FS, FT, FU, FV, FW, FX, FY, FZ, GA) = (
      105120, 113880, 175200, 183960, 210240, 219000, 236520, 245280, 262800, 271560, 280320, 289080, 297840, 306600, 315360, 324120, 332880, 341640, 350400, 359160, 367920, 385440, 394200, 402960, 411720, 420480, 429240, 438000, 446760, 455520, 464280, 473040, 481800, 490560
    )

    let GU = 0
    /// Available elec after TES chrg outside harm op period
    let GV = 365
    do {
      let EZ_EX_Lsum = hour0.sumOfRanges(L, days: daysEZ, range1: hour4, condition: EX, predicate: { $0 > 0 })
      let EZ_EX_EHsum = hour4.sumOf(EH, days: daysEZ, condition: EX, predicate: { $0 > 0 })
      let EZ_EX_EPsum = hour4.sumOf(EP, days: daysEZ, condition: EX, predicate: { $0 > 0 })
      /// Available elec after TES chrg during harm op period

      // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
      for i in 0..<365 { d16[GU + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }
    }
    do {
      let EZ_EX_Lsum = hour0.sumOfRanges(L, days: daysEZ, range1: hour4, condition: EX, predicate: { $0.isZero })
      let EZ_EX_EHsum = hour4.sumOf(EH, days: daysEZ, condition: EX, predicate: { $0.isZero })
      let EZ_EX_EPsum = hour4.sumOf(EP, days: daysEZ, condition: EX, predicate: { $0.isZero })
      // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
      for i in 0..<365 { d16[GV + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    }
    /// Available heat after TES chrg during harm op period
    let GW = 730
    /// Available heat after TES chrg outside of harm op period
    let GX = 1095

    do {
      let EZ_EX_Jsum = hour0.sumOfRanges(J, days: daysEZ, range1: hour4, condition: EX, predicate: { $0 > 0 })
      let EZ_EX_EQsum = hour4.sumOf(EQ, days: daysEZ, condition: EX, predicate: { $0 > 0 })
      let EZ_EX_EIsum = hour4.sumOf(EI, days: daysEZ, condition: EX, predicate: { $0 > 0 })
      // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
      for i in 0..<365 { d16[GW + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }
    }
    do {
      let EZ_EX_Jsum = hour0.sumOfRanges(J, days: daysEZ, range1: hour4, condition: EX, predicate: { $0.isZero })
      let EZ_EX_EQsum = hour4.sumOf(EQ, days: daysEZ, condition: EX, predicate: { $0.isZero })
      let EZ_EX_EIsum = hour4.sumOf(EI, days: daysEZ, condition: EX, predicate: { $0.isZero })
      // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
      for i in 0..<365 { d16[GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }
    }
    let EXsum = hour4.sum(days: daysEZ, range: EX)
    let EZ_EX_FAsum = hour4.sumOf(FA, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let GY = 1460
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[GY + i] = EXsum[i] + EZ_EX_FAsum[i] }

    let FOsum = hour4.sum(days: daysEZ, range: FO)
    let EZ_FO_FAsum = hour4.sumOf(FA, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let GZ = 1825
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[GZ + i] = FOsum[i] + EZ_FO_FAsum[i] }

    /// Harm el cons outside of harm op period
    let HA = 2190
    let EZ_EX_FAsum2 = hour4.sumOf(FA, days: daysEZ, condition: EX, predicate: { $0.isZero })
    // SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { d16[HA + i] = EZ_EX_FAsum2[i] }

    let EYsum = hour4.sum(days: daysEZ, range: EY)
    let EZ_EX_FBsum = hour4.sumOf(FB, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let HB = 2555
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HB + i] = EYsum[i] + EZ_EX_FBsum[i] }

    let FPsum = hour4.sum(days: daysEZ, range: FP)
    let EZ_FO_FBsum = hour4.sumOf(FB, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let HC = 2920
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HC + i] = FPsum[i] + EZ_FO_FBsum[i] }

    /// Harm heat cons outside of harm op period
    let HD = 3285
    let EZ_EX_FBsum2 = hour4.sumOf(FB, days: daysEZ, condition: EX, predicate: { $0.isZero })
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { d16[HD + i] = EZ_EX_FBsum2[i] }

    let EZ_EX_FEsum = hour4.sumOf(FE, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let HE = 3650
    // SUMIFS(CalculationFE5:FE8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HE + i] = EZ_EX_FEsum[i] }

    let EZ_FO_FSsum = hour4.sumOf(FS, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let HF = 4015
    // SUMIFS(CalculationFS5:FS8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HF + i] = EZ_FO_FSsum[i] }

    let FEsum = hour4.sum(days: daysEZ, range: FE)
    /// Grid import  outside of harm op period
    let HG = 4380
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFE5:FE8763)-HE6
    for i in 0..<365 { d16[HG + i] = FEsum[i] - d16[HE + i] }

    let EZ_EX_FGsum = hour4.sumOf(FG, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let HH = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HH + i] = EZ_EX_FGsum[i] }

    let EZ_FO_FUsum = hour4.sumOf(FU, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let HI = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HI + i] = EZ_FO_FUsum[i] }

    let FGsum = hour4.sum(days: daysEZ, range: FG)
    /// El boiler op outside harm op period
    let HJ = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    for i in 0..<365 { d16[HJ + i] = FGsum[i] - d16[HH + i] }
    let EZ_EX_ETsum = hour4.sumOf(ET, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let HK = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HK + i] = EZ_EX_ETsum[i] }

    let ETsum = hour4.sum(days: daysEZ, range: ET)
    /// Total aux cons outside of harm op period
    let HL = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    for i in 0..<365 { d16[HL + i] = ETsum[i] - d16[HK + i] }

    let EZ_EX_EUsum = hour4.sumOf(EU, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let HM = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HM + i] = EZ_EX_EUsum[i] }

    let EUsum = hour4.sum(days: daysEZ, range: EU)
    /// El cons not covered outside of harm op period
    let HN = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    for i in 0..<365 { d16[HN + i] = EUsum[i] - d16[HM + i] }

    let EZ_EX_FCsum = hour4.sumOf(FC, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let HO = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HO + i] = EZ_EX_FCsum[i] }

    let EZ_FO_FQsum = hour4.sumOf(FQ, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let HP = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HP + i] = EZ_FO_FQsum[i] }

    let FCsum = hour4.sum(days: daysEZ, range: FC)
    /// Remaining PV el outside of harm op period
    let HQ = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    for i in 0..<365 { d16[HQ + i] = FCsum[i] - d16[HO + i] }

    let EZ_EX_FDsum = hour4.sumOf(FD, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let HR = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HR + i] = EZ_EX_FDsum[i] }

    let EZ_FO_FRsum = hour4.sumOf(FR, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let HS = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HS + i] = EZ_FO_FRsum[i] }

    let FDsum = hour4.sum(days: daysEZ, range: FD)
    /// Remaining CSP heat outside of harm op period
    let HT = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    for i in 0..<365 { d16[HT + i] = FDsum[i] - d16[HR + i] }

    let EZ_EX_FLsum = hour4.sumOf(FL, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after min harm op during harm op period
    let HU = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d16[HU + i] = min(EZ_EX_FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_FO_FZsum = hour4.sumOf(FZ, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after max harm op during harm op period
    let HV = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d16[HV + i] = min(EZ_FO_FZsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FLsumZero = hour4.sumOf(FL, days: daysEZ, condition: EX, predicate: { $0.isZero })
    /// Max elec to BESS for night prep outside of harm op period
    let HW = 10220
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d16[HW + i] = min(EZ_EX_FLsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FMsum = hour4.sumOf(FM, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let HX = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[HX + i] = EZ_EX_FMsum[i] }

    let EZ_FO_GAsum = hour4.sumOf(GA, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let HY = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[HY + i] = EZ_FO_GAsum[i] }

    let FMsum = hour4.sum(days: daysEZ, range: FM)
    /// Max grid export outside of harm op period
    let HZ = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    for i in 0..<365 { d16[HZ + i] = FMsum[i] - d16[HX + i] }

    let EZ_EX_FFsum = hour4.sumOf(FF, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let IA = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[IA + i] = EZ_EX_FFsum[i] }

    let EZ_FO_FTsum = hour4.sumOf(FT, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let IB = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[IB + i] = EZ_FO_FTsum[i] }

    let FFsum = hour4.sum(days: daysEZ, range: FF)
    /// Remaining grid import outside of harm op period
    let IC = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    for i in 0..<365 { d16[IC + i] = FFsum[i] - d16[IA + i] }

    let EZ_EX_FHsum = hour4.sumOf(FH, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let ID = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[ID + i] = EZ_EX_FHsum[i] }

    let EZ_FO_FVsum = hour4.sumOf(FV, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let IE = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[IE + i] = EZ_FO_FVsum[i] }

    let FHsum = hour4.sum(days: daysEZ, range: FH)
    /// Remaining El boiler cap outside of harm op period
    let IF = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    for i in 0..<365 { d16[IF + i] = FHsum[i] - d16[ID + i] }

    let EZ_EX_FIsum = hour4.sumOf(FI, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let IG = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[IG + i] = EZ_EX_FIsum[i] }

    let EZ_FO_FWsum = hour4.sumOf(FW, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let IH = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[IH + i] = EZ_FO_FWsum[i] }

    let FIsum = hour4.sum(days: daysEZ, range: FI)
    /// Remaining MethSynt cap outside of harm op period
    let II = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    for i in 0..<365 { d16[II + i] = FIsum[i] - d16[IG + i] }

    let EZ_EX_FJsum = hour4.sumOf(FJ, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let IJ = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[IJ + i] = EZ_EX_FJsum[i] }

    let EZ_FO_FXsum = hour4.sumOf(FX, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let IK = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[IK + i] = EZ_FO_FXsum[i] }

    let FJsum = hour4.sum(days: daysEZ, range: FJ)
    /// Remaining CCU cap outside of harm op after min harm
    let IL = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    for i in 0..<365 { d16[IL + i] = FJsum[i] - d16[IJ + i] }

    let EZ_EX_FKsum = hour4.sumOf(FK, days: daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let IM = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d16[IM + i] = EZ_EX_FKsum[i] }

    let EZ_FO_FYsum = hour4.sumOf(FY, days: daysEZ, condition: FO, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let IN = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d16[IN + i] = EZ_FO_FYsum[i] }

    let FKsum = hour4.sum(days: daysEZ, range: FK)
    /// Remaining EY cap outside of harm op period
    let IO = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    for i in 0..<365 { d16[IO + i] = FKsum[i] - d16[IM + i] }
  }
}
