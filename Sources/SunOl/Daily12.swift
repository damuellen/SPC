
extension TunOl {
  func day(hour0: [Double], hour4: [Double], day11: [Double], day15: [Double]) -> [Double] {
    let daysEZ: [[Int]] = Array(hour4[254040..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] })
      .map { $0.map { $0 - 254040 } }.dropFirst())

    let hourJ = 26280
    let hourL = 43800

    let (
      hourEH, hourEI, hourEP, hourEQ, hourET, hourEU, hourEX, hourEY, hourFA, hourFB, hourFC, hourFD, hourFE, hourFF, hourFG, hourFH,
      hourFI, hourFJ, hourFK, hourFL, hourFM, hourFO, hourFP, hourFQ, hourFR, hourFS, hourFT, hourFU, hourFV, hourFW, hourFX, hourFY,
      hourFZ, hourGA
    ) = (
      105120, 113880, 175200, 183960, 210240, 219000, 236520, 245280, 262800, 271560, 280320, 289080, 297840, 306600, 315360, 324120,
      332880, 341640, 350400, 359160, 367920, 385440, 394200, 402960, 411720, 420480, 429240, 438000, 446760, 455520, 464280, 473040,
      481800, 490560
    )

    var day16 = [Double](repeating: Double.zero, count: 17_155)

    let EZ_EX_Lsum = hour0.sumOf(hourL, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    let EZ_EX_EHsum = hour4.sumOf(hourEH, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    let EZ_EX_EPsum = hour4.sumOf(hourEP, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Available elec after TES chrg during harm op period
    let day1GU = 0
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1GU + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    /// Available elec after TES chrg outside harm op period
    let day1GV = 365
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { day16[day1GV + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    let EZ_EX_Jsum = hour0.sumOf(hourJ, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    let EZ_EX_EQsum = hour4.sumOf(hourEQ, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    let EZ_EX_EIsum = hour4.sumOf(hourEI, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Available heat after TES chrg during harm op period
    let day1GW = 730
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1GW + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }

    /// Available heat after TES chrg outside of harm op period
    let day1GX = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { day16[day1GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }

    let EXsum = hour4.sum(days: daysEZ, range: hourEX)
    let EZ_EX_FAsum = hour4.sumOf(hourFA, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let day1GY = 1460
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1GY + i] = EXsum[i] + EZ_EX_FAsum[i] }

    let FOsum = hour4.sum(days: daysEZ, range: hourFO)
    let EZ_FO_FAsum = hour4.sumOf(hourFA, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let day1GZ = 1825
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1GZ + i] = FOsum[i] + EZ_FO_FAsum[i] }

    /// Harm el cons outside of harm op period
    let day1HA = 2190
    // SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { day16[day1HA + i] = EZ_EX_FAsum[i] }

    let EYsum = hour4.sum(days: daysEZ, range: hourEY)
    let EZ_EX_FBsum = hour4.sumOf(hourFB, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let day1HB = 2555
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HB + i] = EYsum[i] + EZ_EX_FBsum[i] }

    let FPsum = hour4.sum(days: daysEZ, range: hourFP)
    let EZ_FO_FBsum = hour4.sumOf(hourFB, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let day1HC = 2920
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HC + i] = FPsum[i] + EZ_FO_FBsum[i] }

    /// Harm heat cons outside of harm op period
    let day1HD = 3285
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { day16[day1HD + i] = EZ_EX_FBsum[i] }

    let EZ_EX_FEsum = hour4.sumOf(hourFE, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let day1HE = 3650
    // SUMIFS(CalculationFE5:FE8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HE + i] = EZ_EX_FEsum[i] }

    let EZ_FO_FSsum = hour4.sumOf(hourFS, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let day1HF = 4015
    // SUMIFS(CalculationFS5:FS8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HF + i] = EZ_FO_FSsum[i] }

    let FEsum = hour4.sum(days: daysEZ, range: hourFE)
    /// Grid import  outside of harm op period
    let day1HG = 4380
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFE5:FE8763)-HE6
    for i in 0..<365 { day16[day1HG + i] = FEsum[i] - day11[day1HE + i] }

    let EZ_EX_FGsum = hour4.sumOf(hourFG, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let day1HH = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HH + i] = EZ_EX_FGsum[i] }

    let EZ_FO_FUsum = hour4.sumOf(hourFU, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let day1HI = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HI + i] = EZ_FO_FUsum[i] }

    let FGsum = hour4.sum(days: daysEZ, range: hourFG)
    /// El boiler op outside harm op period
    let day1HJ = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    for i in 0..<365 { day16[day1HJ + i] = FGsum[i] - day16[day1HH + i] }
    let EZ_EX_ETsum = hour4.sumOf(hourET, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let day1HK = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HK + i] = EZ_EX_ETsum[i] }

    let ETsum = hour4.sum(days: daysEZ, range: hourET)
    /// Total aux cons outside of harm op period
    let day1HL = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    for i in 0..<365 { day16[day1HL + i] = ETsum[i] - day16[day1HK + i] }

    let EZ_EX_EUsum = hour4.sumOf(hourEU, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let day1HM = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HM + i] = EZ_EX_EUsum[i] }

    let EUsum = hour4.sum(days: daysEZ, range: hourEU)
    /// El cons not covered outside of harm op period
    let day1HN = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    for i in 0..<365 { day16[day1HN + i] = EUsum[i] - day11[day1HM + i] }

    let EZ_EX_FCsum = hour4.sumOf(hourFC, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let day1HO = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HO + i] = EZ_EX_FCsum[i] }

    let EZ_FO_FQsum = hour4.sumOf(hourFQ, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let day1HP = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HP + i] = EZ_FO_FQsum[i] }

    let FCsum = hour4.sum(days: daysEZ, range: hourFC)
    /// Remaining PV el outside of harm op period
    let day1HQ = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    for i in 0..<365 { day16[day1HQ + i] = FCsum[i] - day11[day1HO + i] }

    let EZ_EX_FDsum = hour4.sumOf(hourFD, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let day1HR = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HR + i] = EZ_EX_FDsum[i] }

    let EZ_FO_FRsum = hour4.sumOf(hourFR, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let day1HS = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HS + i] = EZ_FO_FRsum[i] }

    let FDsum = hour4.sum(days: daysEZ, range: hourFD)
    /// Remaining CSP heat outside of harm op period
    let day1HT = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    for i in 0..<365 { day16[day1HT + i] = FDsum[i] - day11[day1HR + i] }

    let EZ_EX_FLsum = hour4.sumOf(hourFL, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after min harm op during harm op period
    let day1HU = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day16[day1HU + i] = min(EZ_EX_FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_FO_FZsum = hour4.sumOf(hourFZ, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after max harm op during harm op period
    let day1HV = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day16[day1HV + i] = min(EZ_FO_FZsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FLsumZero = hour4.sumOf(hourFL, days: daysEZ, condition: hourEX, predicate: { $0.isZero })
    /// Max elec to BESS for night prep outside of harm op period
    let day1HW = 10220
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day16[day1HW + i] = min(EZ_EX_FLsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FMsum = hour4.sumOf(hourFM, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let day1HX = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1HX + i] = EZ_EX_FMsum[i] }

    let EZ_FO_GAsum = hour4.sumOf(hourGA, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let day1HY = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1HY + i] = EZ_FO_GAsum[i] }

    let FMsum = hour4.sum(days: daysEZ, range: hourFM)
    /// Max grid export outside of harm op period
    let day1HZ = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    for i in 0..<365 { day16[day1HZ + i] = FMsum[i] - day16[day1HX + i] }

    let EZ_EX_FFsum = hour4.sumOf(hourFF, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let day1IA = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1IA + i] = EZ_EX_FFsum[i] }

    let EZ_FO_FTsum = hour4.sumOf(hourFT, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let day1IB = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1IB + i] = EZ_FO_FTsum[i] }

    let FFsum = hour4.sum(days: daysEZ, range: hourFF)
    /// Remaining grid import outside of harm op period
    let day1IC = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    for i in 0..<365 { day16[day1IC + i] = FFsum[i] - day16[day1IA + i] }

    let EZ_EX_FHsum = hour4.sumOf(hourFH, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let day1ID = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1ID + i] = EZ_EX_FHsum[i] }

    let EZ_FO_FVsum = hour4.sumOf(hourFV, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let day1IE = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1IE + i] = EZ_FO_FVsum[i] }

    let FHsum = hour4.sum(days: daysEZ, range: hourFH)
    /// Remaining El boiler cap outside of harm op period
    let day1IF = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    for i in 0..<365 { day16[day1IF + i] = FHsum[i] - day16[day1ID + i] }

    let EZ_EX_FIsum = hour4.sumOf(hourFI, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let day1IG = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1IG + i] = EZ_EX_FIsum[i] }

    let EZ_FO_FWsum = hour4.sumOf(hourFW, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let day1IH = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1IH + i] = EZ_FO_FWsum[i] }

    let FIsum = hour4.sum(days: daysEZ, range: hourFI)
    /// Remaining MethSynt cap outside of harm op period
    let day1II = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    for i in 0..<365 { day16[day1II + i] = FIsum[i] - day16[day1IG + i] }

    let EZ_EX_FJsum = hour4.sumOf(hourFJ, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let day1IJ = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1IJ + i] = EZ_EX_FJsum[i] }

    let EZ_FO_FXsum = hour4.sumOf(hourFX, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let day1IK = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1IK + i] = EZ_FO_FXsum[i] }

    let FJsum = hour4.sum(days: daysEZ, range: hourFJ)
    /// Remaining CCU cap outside of harm op after min harm
    let day1IL = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    for i in 0..<365 { day16[day1IL + i] = FJsum[i] - day16[day1IJ + i] }

    let EZ_EX_FKsum = hour4.sumOf(hourFK, days: daysEZ, condition: hourEX, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let day1IM = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day16[day1IM + i] = EZ_EX_FKsum[i] }

    let EZ_FO_FYsum = hour4.sumOf(hourFY, days: daysEZ, condition: hourFO, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let day1IN = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { day16[day1IN + i] = EZ_FO_FYsum[i] }

    let FKsum = hour4.sum(days: daysEZ, range: hourFK)
    /// Remaining EY cap outside of harm op period
    let day1IO = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    for i in 0..<365 { day16[day1IO + i] = FKsum[i] - day16[day1IM + i] }
    return day16
  }
}
