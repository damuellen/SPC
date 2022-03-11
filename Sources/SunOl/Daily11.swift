
extension TunOl {
  func day(hour0: [Double], hour2: [Double], hour3: [Double], day11: [Double]) -> [Double] {

    let hourJ = 26280
    let hourL = 43800

    let hourBX = 26280
    let hourCB = 61320
    let hourCC = 70080
    let hourCI = 122640
    let hourCJ = 131400

    let hourCM = 157680
    let hourCN = 166440

    let hourCQ = 8760
    let hourCR = 17520
    let hourCS = 26280
    let hourCT = 35040
    let hourCU = 43800
    let hourCV = 52560
    let hourCW = 61320
    let hourCX = 70080
    let hourCY = 78840
    let hourCZ = 87600
    let hourDA = 96360
    let hourDB = 105120
    let hourDC = 113880
    let hourDD = 122640
    let hourDE = 131400
    let hourDF = 140160

    let hourDH = 157680
    let hourDI = 166440
    let hourDJ = 175200
    let hourDK = 183960
    let hourDL = 192720
    let hourDM = 201480
    let hourDN = 210240
    let hourDO = 219000
    let hourDP = 227760
    let hourDQ = 236520
    let hourDR = 245280
    let hourDS = 254040
    let hourDT = 262800
    let daysCS: [[Int]] = hour3[hourCS..<(hourCS + 8760)].indices.chunked(by: { hour3[$0] == hour3[$1] })
      .map { $0.map { $0 - hourCS } }
   // let end = daysCS.removeLast()
   // daysCS[0].append(contentsOf: end)
    var day15 = [Double](repeating: Double.zero, count: 17_155)
    /// Available elec after TES chrg during harm op period
    let day1EY = 0
    /// Available elec after TES chrg outside harm op period
    let day1EZ = 365
    do {
      let CS_CQ_Lsum = hour0.sumOfRanges(hourL, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
      let CS_CC_CQ_BXsum = hour2.sumOfRanges(hourBX, days: daysCS, range1: hour3, condition1: hourCQ, predicate1: { $0 > 0 }, range2: hour2, condition2: hourCC, predicate2: { $0 > 0 })
      let CS_CQ_CIsum = hour2.sumOfRanges(hourCI, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
      // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      // +SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      // -SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      for i in 0..<365 { day15[day1EY + i] = CS_CQ_Lsum[i] + CS_CC_CQ_BXsum[i] - CS_CQ_CIsum[i] }
    }
    do {
      let CS_CQ_Lsum = hour0.sumOfRanges(hourL, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0.isZero })
      let CS_CC_CQ_BXsum = hour2.sumOfRanges(hourBX, days: daysCS, range1: hour3, condition1: hourCQ, predicate1: { $0.isZero }, range2: hour2, condition2: hourCC, predicate2: { $0 > 0 })
      let CS_CQ_CIsum = hour2.sumOfRanges(hourCI, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0.isZero })
      // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      for i in 0..<365 { day15[day1EZ + i] = CS_CQ_Lsum[i] + CS_CC_CQ_BXsum[i] - CS_CQ_CIsum[i] }
    }
    /// Available heat after TES chrg during harm op period
    let day1FA = 730
    /// Available heat after TES chrg outside of harm op period
    let day1FB = 1095
    do {
      let CS_CQ_CJsum = hour2.sumOfRanges(hourCJ, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
      let CS_CQ_Jsum = hour0.sumOfRanges(hourJ, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
      let CS_CC_CQ_CBsum = hour2.sumOfRanges(hourCB, days: daysCS, range1: hour3, condition1: hourCQ, predicate1: { $0 > 0 }, range2: hour2, condition2: hourCC, predicate2: { $0 > 0 })
      // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      //+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")/PB_Ratio_Heat_input_vs_output
      //-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      for i in 0..<365 { day15[day1FA + i] = CS_CQ_Jsum[i] + CS_CC_CQ_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i] }
    }
    do {
      let CS_CQ_CJsum = hour2.sumOfRanges(hourCJ, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0.isZero })
      let CS_CQ_Jsum = hour0.sumOfRanges(hourJ, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0.isZero })
      let CS_CC_CQ_CBsum = hour2.sumOfRanges(hourCB, days: daysCS, range1: hour3, condition1: hourCQ, predicate1: { $0.isZero }, range2: hour2, condition2: hourCC, predicate2: { $0 > 0 })
      // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output
      //-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      for i in 0..<365 { day15[day1FB + i] = CS_CQ_Jsum[i] + CS_CC_CQ_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i] }
    }
    let CQsum = hour3.sum(days: daysCS, range: hourCQ)
    let CS_CQ_CTsum = hour3.sumOf(hourCT, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let day1FC = 1460
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FC + i] = CQsum[i] + CS_CQ_CTsum[i] }

    let DHsum = hour3.sum(days: daysCS, range: hourDH)
    let CS_DH_CTsum = hour3.sumOf(hourCT, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let day1FD = 1825
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FD + i] = DHsum[i] + CS_DH_CTsum[i] }

    /// Harm el cons outside of harm op period
    let day1FE = 2190
    let CS_CQ_CTsum2 = hour3.sumOf(hourCT, days: daysCS, condition: hourCQ, predicate: { $0.isZero })
    // SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { day15[day1FE + i] = CS_CQ_CTsum2[i] }

    let CRsum = hour3.sum(days: daysCS, range: hourCR)
    let CS_CQ_CUsum = hour3.sumOf(hourCU, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let day1FF = 2555
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FF + i] = CRsum[i] + CS_CQ_CUsum[i] }

    let DIsum = hour3.sum(days: daysCS, range: hourDI)
    let CS_DH_CUsum = hour3.sumOf(hourCU, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let day1FG = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FG + i] = DIsum[i] + CS_DH_CUsum[i] }

    /// Harm heat cons outside of harm op period
    let day1FH = 3285
    let CS_CQ_CUsum2 = hour3.sumOf(hourCU, days: daysCS, condition: hourCQ, predicate: { $0.isZero })
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { day15[day1FH + i] = CS_CQ_CUsum2[i] }

    let CS_CQ_CXsum = hour3.sumOf(hourCX, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let day1FI = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FI + i] = CS_CQ_CXsum[i] }

    let CS_DH_DLsum = hour3.sumOf(hourDL, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let day1FJ = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FJ + i] = CS_DH_DLsum[i] }

    let CXsum = hour3.sum(days: daysCS, range: hourCX)
    /// Grid import  outside of harm op period
    let day1FK = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { day15[day1FK + i] = CXsum[i] - day15[day1FI + i] }

    let CS_CQ_CZsum = hour3.sumOf(hourCZ, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let day1FL = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FL + i] = CS_CQ_CZsum[i] }

    let CS_DH_DNsum = hour3.sumOf(hourDN, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let day1FM = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FM + i] = CS_DH_DNsum[i] }

    let CZsum = hour3.sum(days: daysCS, range: hourCZ)
    /// El boiler op outside harm op period
    let day1FN = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { day15[day1FN + i] = CZsum[i] - day15[day1FL + i] }

    let CS_CQ_CMsum = hour2.sumOfRanges(hourCM, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let day1FO = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FO + i] = CS_CQ_CMsum[i] }

    let CMsum = hour2.sum(days: daysCS, range: hourCM)
    /// Total aux cons outside of harm op period
    let day1FP = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { day15[day1FP + i] = CMsum[i] - day15[day1FO + i] }

    let CS_CQ_CNsum = hour2.sumOfRanges(hourCN, days: daysCS, range1: hour3, condition: hourCQ, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let day1FQ = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FQ + i] = CS_CQ_CNsum[i] }

    let CNsum = hour2.sum(days: daysCS, range: hourCN)
    /// El cons not covered outside of harm op period
    let day1FR = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { day15[day1FR + i] = CNsum[i] - day15[day1FQ + i] }

    let CS_CQ_CVsum = hour3.sumOf(hourCV, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let day1FS = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FS + i] = CS_CQ_CVsum[i] }

    let CS_DH_DJsum = hour3.sumOf(hourDJ, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let day1FT = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FT + i] = CS_DH_DJsum[i] }

    let CVsum = hour3.sum(days: daysCS, range: hourCV)
    /// Remaining PV el outside of harm op period
    let day1FU = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { day15[day1FU + i] = CVsum[i] - day15[day1FS + i] }

    let CS_CQ_CWsum = hour3.sumOf(hourCW, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let day1FV = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1FV + i] = CS_CQ_CWsum[i] }

    let CS_DH_DKsum = hour3.sumOf(hourDK, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let day1FW = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1FW + i] = CS_DH_DKsum[i] }

    let CWsum = hour3.sum(days: daysCS, range: hourCW)
    /// Remaining CSP heat outside of harm op period
    let day1FX = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { day15[day1FX + i] = CWsum[i] - day15[day1FV + i] }

    let CS_CQ_DEsum = hour3.sumOf(hourDE, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Max BESS night prep after min harm cons during harm op period
    let day1FY = 9490
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day15[day1FY + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_DH_DSsum = hour3.sumOf(hourDS, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Max BESS night prep after max harm cons during harm op period
    let day1FZ = 9855
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day15[day1FZ + i] = min(CS_DH_DSsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let day1GA = 10220
    let CS_CQ_DEsum2 = hour3.sumOf(hourDE, days: daysCS, condition: hourCQ, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { day15[day1GA + i] = min(CS_CQ_DEsum2[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_CQ_DFsum = hour3.sumOf(hourDF, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let day1GB = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GB + i] = CS_CQ_DFsum[i] }

    let CS_DH_DTsum = hour3.sumOf(hourDT, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let day1GC = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GC + i] = CS_DH_DTsum[i] }

    let DFsum = hour3.sum(days: daysCS, range: hourDF)
    /// Max grid export outside of harm op period
    let day1GD = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { day15[day1GD + i] = DFsum[i] - day15[day1GB + i] }

    let CS_CQ_CYsum = hour3.sumOf(hourCY, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let day1GE = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GE + i] = CS_CQ_CYsum[i] }

    let CS_DH_DMsum = hour3.sumOf(hourDM, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let day1GF = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GF + i] = CS_DH_DMsum[i] }

    let CYsum = hour3.sum(days: daysCS, range: hourCY)
    /// Remaining grid import outside of harm op period
    let day1GG = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { day15[day1GG + i] = CYsum[i] - day15[day1GE + i] }

    let CS_CQ_DAsum = hour3.sumOf(hourDA, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let day1GH = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GH + i] = CS_CQ_DAsum[i] }

    let CS_DH_DOsum = hour3.sumOf(hourDO, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let day1GI = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GI + i] = CS_DH_DOsum[i] }

    let DAsum = hour3.sum(days: daysCS, range: hourDA)
    /// Remaining El boiler cap outside of harm op period
    let day1GJ = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { day15[day1GJ + i] = DAsum[i] - day15[day1GH + i] }

    let CS_CQ_DBsum = hour3.sumOf(hourDB, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let day1GK = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GK + i] = CS_CQ_DBsum[i] }

    let CS_DH_DPsum = hour3.sumOf(hourDP, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let day1GL = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GL + i] = CS_DH_DPsum[i] }

    let DBsum = hour3.sum(days: daysCS, range: hourDB)
    /// Remaining MethSynt cap outside of harm op period
    let day1GM = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { day15[day1GM + i] = DBsum[i] - day15[day1GK + i] }

    let CS_CQ_DCsum = hour3.sumOf(hourDC, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let day1GN = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GN + i] = CS_CQ_DCsum[i] }

    let CS_DH_DQsum = hour3.sumOf(hourDQ, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let day1GO = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GO + i] = CS_DH_DQsum[i] }

    let DCsum = hour3.sum(days: daysCS, range: hourDC)
    /// Remaining CCU cap outside of harm op after min harm
    let day1GP = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { day15[day1GP + i] = DCsum[i] - day15[day1GN + i] }

    let CS_CQ_DDsum = hour3.sumOf(hourDD, days: daysCS, condition: hourCQ, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let day1GQ = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day15[day1GQ + i] = CS_CQ_DDsum[i] }

    let DDsum = hour3.sum(days: daysCS, range: hourDD)
    let CS_DH_DRsum = hour3.sumOf(hourDR, days: daysCS, condition: hourDH, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let day1GR = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { day15[day1GR + i] = CS_DH_DRsum[i] }

    /// Remaining EY cap outside of harm op period
    let day1GS = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { day15[day1GS + i] = DDsum[i] - day15[day1GQ + i] }
    return day15
  }
}
