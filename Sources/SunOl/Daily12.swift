
extension TunOl {
  func daily16(hourly0: [Double], hourly4: [Double], daily11: [Double], daily15: [Double]) -> [Double] {
    let daysEZ = [[Int]]()
    let hourlyJ = 26280
    let hourlyL = 43800

    let hourlyEH = 105120
    let hourlyEI = 113880

    let hourlyEP = 175200
    let hourlyEQ = 183960

    let hourlyET = 210240
    let hourlyEU = 219000

    let hourlyEX = 236520
    let hourlyEY = 245280

    let hourlyFA = 262800
    let hourlyFB = 271560
    let hourlyFC = 280320
    let hourlyFD = 289080
    let hourlyFE = 297840
    let hourlyFF = 306600
    let hourlyFG = 315360
    let hourlyFH = 324120
    let hourlyFI = 332880
    let hourlyFJ = 341640
    let hourlyFK = 350400
    let hourlyFL = 359160
    let hourlyFM = 367920

    let hourlyFO = 385440
    let hourlyFP = 394200
    let hourlyFQ = 402960
    let hourlyFR = 411720
    let hourlyFS = 420480
    let hourlyFT = 429240
    let hourlyFU = 438000
    let hourlyFV = 446760
    let hourlyFW = 455520
    let hourlyFX = 464280
    let hourlyFY = 473040
    let hourlyFZ = 481800
    let hourlyGA = 490560
     
    var daily16 = [Double](repeating: 0, count: 17_155)

    let EZ_EX_Lsum = hourly0.sumOf(hourlyL, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    let EZ_EX_EHsum = hourly4.sumOf(hourlyEH, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    let EZ_EX_EPsum = hourly4.sumOf(hourlyEP, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Available elec after TES chrg during harm op period
    let daily1GU = 0
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1GU + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    /// Available elec after TES chrg outside harm op period
    let daily1GV = 365
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1GV + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    let EZ_EX_Jsum = hourly0.sumOf(hourlyJ, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })  // FIXME
    let EZ_EX_EQsum = hourly4.sumOf(hourlyEQ, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    let EZ_EX_EIsum = hourly4.sumOf(hourlyEI, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Available heat after TES chrg during harm op period
    let daily1GW = 730
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1GW + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }

    /// Available heat after TES chrg outside of harm op period
    let daily1GX = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }

    let EXsum = hourly4.sum(days: daysEZ, range: hourlyEX)
    let EZ_EX_FAsum = hourly4.sumOf(hourlyFA, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let daily1GY = 1460
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1GY + i] = EXsum[i] + EZ_EX_FAsum[i] }

    let FOsum = hourly4.sum(days: daysEZ, range: hourlyFO)
    let EZ_FO_FAsum = hourly4.sumOf(hourlyFA, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let daily1GZ = 1825
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1GZ + i] = FOsum[i] + EZ_FO_FAsum[i] }

    /// Harm el cons outside of harm op period
    let daily1HA = 2190
    // SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1HA + i] = EZ_EX_FAsum[i] }

    let EYsum = hourly4.sum(days: daysEZ, range: hourlyEY)
    let EZ_EX_FBsum = hourly4.sumOf(hourlyFB, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let daily1HB = 2555
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HB + i] = EYsum[i] + EZ_EX_FBsum[i] }

    let FPsum = hourly4.sum(days: daysEZ, range: hourlyFP)
    let EZ_FO_FBsum = hourly4.sumOf(hourlyFB, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let daily1HC = 2920
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HC + i] = FPsum[i] + EZ_FO_FBsum[i] }

    /// Harm heat cons outside of harm op period
    let daily1HD = 3285
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1HD + i] = EZ_EX_FBsum[i] }

    let EZ_EX_FEsum = hourly4.sumOf(hourlyFE, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let daily1HE = 3650
    // SUMIFS(CalculationFE5:FE8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HE + i] = EZ_EX_FEsum[i] }

    let EZ_FO_FSsum = hourly4.sumOf(hourlyFS, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let daily1HF = 4015
    // SUMIFS(CalculationFS5:FS8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HF + i] = EZ_FO_FSsum[i] }

    let FEsum = hourly4.sum(days: daysEZ, range: hourlyFE)
    /// Grid import  outside of harm op period
    let daily1HG = 4380
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFE5:FE8763)-HE6
    for i in 0..<365 { daily16[daily1HG + i] = FEsum[i] - daily11[daily1HE + i] }

    let EZ_EX_FGsum = hourly4.sumOf(hourlyFG, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let daily1HH = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HH + i] = EZ_EX_FGsum[i] }

    let EZ_FO_FUsum = hourly4.sumOf(hourlyFU, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let daily1HI = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HI + i] = EZ_FO_FUsum[i] }

    let FGsum = hourly4.sum(days: daysEZ, range: hourlyFG)
    /// El boiler op outside harm op period
    let daily1HJ = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    for i in 0..<365 { daily16[daily1HJ + i] = FGsum[i] - daily16[daily1HH + i] }
    let EZ_EX_ETsum = hourly4.sumOf(hourlyET, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let daily1HK = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HK + i] = EZ_EX_ETsum[i] }

    let ETsum = hourly4.sum(days: daysEZ, range: hourlyET)
    /// Total aux cons outside of harm op period
    let daily1HL = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    for i in 0..<365 { daily16[daily1HL + i] = ETsum[i] - daily16[daily1HK + i] }

    let EZ_EX_EUsum = hourly4.sumOf(hourlyEU, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let daily1HM = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HM + i] = EZ_EX_EUsum[i] }

    let EUsum = hourly4.sum(days: daysEZ, range: hourlyEU)
    /// El cons not covered outside of harm op period
    let daily1HN = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    for i in 0..<365 { daily16[daily1HN + i] = EUsum[i] - daily11[daily1HM + i] }

    let EZ_EX_FCsum = hourly4.sumOf(hourlyFC, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let daily1HO = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HO + i] = EZ_EX_FCsum[i] }

    let EZ_FO_FQsum = hourly4.sumOf(hourlyFQ, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let daily1HP = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HP + i] = EZ_FO_FQsum[i] }

    let FCsum = hourly4.sum(days: daysEZ, range: hourlyFC)
    /// Remaining PV el outside of harm op period
    let daily1HQ = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    for i in 0..<365 { daily16[daily1HQ + i] = FCsum[i] - daily11[daily1HO + i] }

    let EZ_EX_FDsum = hourly4.sumOf(hourlyFD, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let daily1HR = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HR + i] = EZ_EX_FDsum[i] }

    let EZ_FO_FRsum = hourly4.sumOf(hourlyFR, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let daily1HS = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HS + i] = EZ_FO_FRsum[i] }

    let FDsum = hourly4.sum(days: daysEZ, range: hourlyFD)
    /// Remaining CSP heat outside of harm op period
    let daily1HT = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    for i in 0..<365 { daily16[daily1HT + i] = FDsum[i] - daily11[daily1HR + i] }

    let EZ_EX_FLsum = hourly4.sumOf(hourlyFL, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after min harm op during harm op period
    let daily1HU = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HU + i] = min(EZ_EX_FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_FO_FZsum = hourly4.sumOf(hourlyFZ, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Max elec to BESS for night prep after max harm op during harm op period
    let daily1HV = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HV + i] = min(EZ_FO_FZsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FLsumZero = hourly4.sumOf(hourlyFL, days: daysEZ, condition: hourlyEX, predicate: { $0.isZero })
    /// Max elec to BESS for night prep outside of harm op period
    let daily1HW = 10220
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HW + i] = min(EZ_EX_FLsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FMsum = hourly4.sumOf(hourlyFM, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let daily1HX = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HX + i] = EZ_EX_FMsum[i] }

    let EZ_FO_GAsum = hourly4.sumOf(hourlyGA, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let daily1HY = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HY + i] = EZ_FO_GAsum[i] }

    let FMsum = hourly4.sum(days: daysEZ, range: hourlyFM)
    /// Max grid export outside of harm op period
    let daily1HZ = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    for i in 0..<365 { daily16[daily1HZ + i] = FMsum[i] - daily16[daily1HX + i] }

    let EZ_EX_FFsum = hourly4.sumOf(hourlyFF, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let daily1IA = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IA + i] = EZ_EX_FFsum[i] }

    let EZ_FO_FTsum = hourly4.sumOf(hourlyFT, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let daily1IB = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IB + i] = EZ_FO_FTsum[i] }

    let FFsum = hourly4.sum(days: daysEZ, range: hourlyFF)
    /// Remaining grid import outside of harm op period
    let daily1IC = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    for i in 0..<365 { daily16[daily1IC + i] = FFsum[i] - daily16[daily1IA + i] }

    let EZ_EX_FHsum = hourly4.sumOf(hourlyFH, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let daily1ID = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1ID + i] = EZ_EX_FHsum[i] }

    let EZ_FO_FVsum = hourly4.sumOf(hourlyFV, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let daily1IE = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IE + i] = EZ_FO_FVsum[i] }

    let FHsum = hourly4.sum(days: daysEZ, range: hourlyFH)
    /// Remaining El boiler cap outside of harm op period
    let daily1IF = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    for i in 0..<365 { daily16[daily1IF + i] = FHsum[i] - daily16[daily1ID + i] }

    let EZ_EX_FIsum = hourly4.sumOf(hourlyFI, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let daily1IG = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IG + i] = EZ_EX_FIsum[i] }

    let EZ_FO_FWsum = hourly4.sumOf(hourlyFW, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let daily1IH = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IH + i] = EZ_FO_FWsum[i] }

    let FIsum = hourly4.sum(days: daysEZ, range: hourlyFI)
    /// Remaining MethSynt cap outside of harm op period
    let daily1II = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    for i in 0..<365 { daily16[daily1II + i] = FIsum[i] - daily16[daily1IG + i] }

    let EZ_EX_FJsum = hourly4.sumOf(hourlyFJ, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let daily1IJ = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IJ + i] = EZ_EX_FJsum[i] }

    let EZ_FO_FXsum = hourly4.sumOf(hourlyFX, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let daily1IK = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IK + i] = EZ_FO_FXsum[i] }

    let FJsum = hourly4.sum(days: daysEZ, range: hourlyFJ)
    /// Remaining CCU cap outside of harm op after min harm
    let daily1IL = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    for i in 0..<365 { daily16[daily1IL + i] = FJsum[i] - daily16[daily1IJ + i] }

    let EZ_EX_FKsum = hourly4.sumOf(hourlyFK, days: daysEZ, condition: hourlyEX, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let daily1IM = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IM + i] = EZ_EX_FKsum[i] }

    let EZ_FO_FYsum = hourly4.sumOf(hourlyFY, days: daysEZ, condition: hourlyFO, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let daily1IN = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IN + i] = EZ_FO_FYsum[i] }

    let FKsum = hourly4.sum(days: daysEZ, range: hourlyFK)
    /// Remaining EY cap outside of harm op period
    let daily1IO = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    for i in 0..<365 { daily16[daily1IO + i] = FKsum[i] - daily16[daily1IM + i] }
    return daily16
  }
}
