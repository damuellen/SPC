extension TunOl {
  func d11(_ d11: inout [Double], hour0: [Double], hour2: [Double], hour3: [Double]) {
    let (J, L, BX, CB, CC, CI, CJ, CM, CN, CQ, CR, CS, CT, CU, CV, CW, CX, CY, CZ, DA, DB, DC, DD, DE, DF, DH, DI, DJ, DK, DL, DM, DN, DO, DP, DQ, DR, DS, DT) = (
      26280, 43800, 26280, 61320, 70080, 122640, 131400, 157680, 166440, 8760, 17520, 26280, 35040, 43800, 52560, 61320, 70080, 78840, 87600, 96360, 105120, 113880, 122640, 131400, 140160, 157680, 166440, 175200, 183960, 192720, 201480, 210240, 219000, 227760, 236520, 245280, 254040, 262800
    )
    let daysCS: [[Int]] = hour3[(CS + 1)..<(CS + 8760)].indices.chunked(by: { hour3[$0] == hour3[$1] }).map { $0.map { $0 - CS } }

    /// Available elec after TES chrg during harm op period
    let EY = 0
    /// Available elec after TES chrg outside harm op period
    let EZ = 365
    do {
      let CS_CQ_Lsum = hour0.sumOfRanges(L, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
      let CS_CC_CQ_BXsum = hour2.sumOfRanges(BX, days: daysCS, range1: hour3, condition1: CQ, predicate1: { $0 > 0 }, range2: hour2, condition2: CC, predicate2: { $0 > 0 })
      let CS_CQ_CIsum = hour2.sumOfRanges(CI, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
      // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      // +SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      // -SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      for i in 0..<365 { d11[EY + i] = CS_CQ_Lsum[i] + CS_CC_CQ_BXsum[i] - CS_CQ_CIsum[i] }
    }
    do {
      let CS_CQ_Lsum = hour0.sumOfRanges(L, days: daysCS, range1: hour3, condition: CQ, predicate: { $0.isZero })
      let CS_CC_CQ_BXsum = hour2.sumOfRanges(BX, days: daysCS, range1: hour3, condition1: CQ, predicate1: { $0.isZero }, range2: hour2, condition2: CC, predicate2: { $0 > 0 })
      let CS_CQ_CIsum = hour2.sumOfRanges(CI, days: daysCS, range1: hour3, condition: CQ, predicate: { $0.isZero })
      // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      for i in 0..<365 { d11[EZ + i] = CS_CQ_Lsum[i] + CS_CC_CQ_BXsum[i] - CS_CQ_CIsum[i] }
    }
    /// Available heat after TES chrg during harm op period
    let FA = 730
    /// Available heat after TES chrg outside of harm op period
    let FB = 1095
    do {
      let CS_CQ_CJsum = hour2.sumOfRanges(CJ, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
      let CS_CQ_Jsum = hour0.sumOfRanges(J, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
      let CS_CC_CQ_CBsum = hour2.sumOfRanges(CB, days: daysCS, range1: hour3, condition1: CQ, predicate1: { $0 > 0 }, range2: hour2, condition2: CC, predicate2: { $0 > 0 })
      // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      //+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")/PB_Ratio_Heat_input_vs_output
      //-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
      for i in 0..<365 { d11[FA + i] = CS_CQ_Jsum[i] + CS_CC_CQ_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i] }
    }
    do {
      let CS_CQ_CJsum = hour2.sumOfRanges(CJ, days: daysCS, range1: hour3, condition: CQ, predicate: { $0.isZero })
      let CS_CQ_Jsum = hour0.sumOfRanges(J, days: daysCS, range1: hour3, condition: CQ, predicate: { $0.isZero })
      let CS_CC_CQ_CBsum = hour2.sumOfRanges(CB, days: daysCS, range1: hour3, condition1: CQ, predicate1: { $0.isZero }, range2: hour2, condition2: CC, predicate2: { $0 > 0 })
      // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      //+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output
      //-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
      for i in 0..<365 { d11[FB + i] = CS_CQ_Jsum[i] + CS_CC_CQ_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i] }
    }
    let CQsum = hour3.sum(days: daysCS, range: CQ)
    let CS_CQ_CTsum = hour3.sumOf(CT, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let FC = 1460
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FC + i] = CQsum[i] + CS_CQ_CTsum[i] }

    let DHsum = hour3.sum(days: daysCS, range: DH)
    let CS_DH_CTsum = hour3.sumOf(CT, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let FD = 1825
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FD + i] = DHsum[i] + CS_DH_CTsum[i] }

    /// Harm el cons outside of harm op period
    let FE = 2190
    let CS_CQ_CTsum2 = hour3.sumOf(CT, days: daysCS, condition: CQ, predicate: { $0.isZero })
    // SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { d11[FE + i] = CS_CQ_CTsum2[i] }

    let CRsum = hour3.sum(days: daysCS, range: CR)
    let CS_CQ_CUsum = hour3.sumOf(CU, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let FF = 2555
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FF + i] = CRsum[i] + CS_CQ_CUsum[i] }

    let DIsum = hour3.sum(days: daysCS, range: DI)
    let CS_DH_CUsum = hour3.sumOf(CU, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let FG = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FG + i] = DIsum[i] + CS_DH_CUsum[i] }

    /// Harm heat cons outside of harm op period
    let FH = 3285
    let CS_CQ_CUsum2 = hour3.sumOf(CU, days: daysCS, condition: CQ, predicate: { $0.isZero })
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { d11[FH + i] = CS_CQ_CUsum2[i] }

    let CS_CQ_CXsum = hour3.sumOf(CX, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let FI = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FI + i] = CS_CQ_CXsum[i] }

    let CS_DH_DLsum = hour3.sumOf(DL, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let FJ = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FJ + i] = CS_DH_DLsum[i] }

    let CXsum = hour3.sum(days: daysCS, range: CX)
    /// Grid import  outside of harm op period
    let FK = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { d11[FK + i] = CXsum[i] - d11[FI + i] }

    let CS_CQ_CZsum = hour3.sumOf(CZ, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let FL = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FL + i] = CS_CQ_CZsum[i] }

    let CS_DH_DNsum = hour3.sumOf(DN, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let FM = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FM + i] = CS_DH_DNsum[i] }

    let CZsum = hour3.sum(days: daysCS, range: CZ)
    /// El boiler op outside harm op period
    let FN = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { d11[FN + i] = CZsum[i] - d11[FL + i] }

    let CS_CQ_CMsum = hour2.sumOfRanges(CM, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let FO = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FO + i] = CS_CQ_CMsum[i] }

    let CMsum = hour2.sum(days: daysCS, range: CM)
    /// Total aux cons outside of harm op period
    let FP = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { d11[FP + i] = CMsum[i] - d11[FO + i] }

    let CS_CQ_CNsum = hour2.sumOfRanges(CN, days: daysCS, range1: hour3, condition: CQ, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let FQ = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FQ + i] = CS_CQ_CNsum[i] }

    let CNsum = hour2.sum(days: daysCS, range: CN)
    /// El cons not covered outside of harm op period
    let FR = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { d11[FR + i] = CNsum[i] - d11[FQ + i] }

    let CS_CQ_CVsum = hour3.sumOf(CV, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let FS = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FS + i] = CS_CQ_CVsum[i] }

    let CS_DH_DJsum = hour3.sumOf(DJ, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let FT = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FT + i] = CS_DH_DJsum[i] }

    let CVsum = hour3.sum(days: daysCS, range: CV)
    /// Remaining PV el outside of harm op period
    let FU = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { d11[FU + i] = CVsum[i] - d11[FS + i] }

    let CS_CQ_CWsum = hour3.sumOf(CW, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let FV = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FV + i] = CS_CQ_CWsum[i] }

    let CS_DH_DKsum = hour3.sumOf(DK, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let FW = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FW + i] = CS_DH_DKsum[i] }

    let CWsum = hour3.sum(days: daysCS, range: CW)
    /// Remaining CSP heat outside of harm op period
    let FX = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { d11[FX + i] = CWsum[i] - d11[FV + i] }

    let CS_CQ_DEsum = hour3.sumOf(DE, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Max BESS night prep after min harm cons during harm op period
    let FY = 9490
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FY + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_DH_DSsum = hour3.sumOf(DS, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Max BESS night prep after max harm cons during harm op period
    let FZ = 9855
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FZ + i] = min(CS_DH_DSsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let GA = 10220
    let CS_CQ_DEsum2 = hour3.sumOf(DE, days: daysCS, condition: CQ, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[GA + i] = min(CS_CQ_DEsum2[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_CQ_DFsum = hour3.sumOf(DF, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let GB = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GB + i] = CS_CQ_DFsum[i] }

    let CS_DH_DTsum = hour3.sumOf(DT, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let GC = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GC + i] = CS_DH_DTsum[i] }

    let DFsum = hour3.sum(days: daysCS, range: DF)
    /// Max grid export outside of harm op period
    let GD = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { d11[GD + i] = DFsum[i] - d11[GB + i] }

    let CS_CQ_CYsum = hour3.sumOf(CY, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let GE = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GE + i] = CS_CQ_CYsum[i] }

    let CS_DH_DMsum = hour3.sumOf(DM, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let GF = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GF + i] = CS_DH_DMsum[i] }

    let CYsum = hour3.sum(days: daysCS, range: CY)
    /// Remaining grid import outside of harm op period
    let GG = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { d11[GG + i] = CYsum[i] - d11[GE + i] }

    let CS_CQ_DAsum = hour3.sumOf(DA, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let GH = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GH + i] = CS_CQ_DAsum[i] }

    let CS_DH_DOsum = hour3.sumOf(DO, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let GI = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GI + i] = CS_DH_DOsum[i] }

    let DAsum = hour3.sum(days: daysCS, range: DA)
    /// Remaining El boiler cap outside of harm op period
    let GJ = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { d11[GJ + i] = DAsum[i] - d11[GH + i] }

    let CS_CQ_DBsum = hour3.sumOf(DB, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let GK = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GK + i] = CS_CQ_DBsum[i] }

    let CS_DH_DPsum = hour3.sumOf(DP, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let GL = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GL + i] = CS_DH_DPsum[i] }

    let DBsum = hour3.sum(days: daysCS, range: DB)
    /// Remaining MethSynt cap outside of harm op period
    let GM = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { d11[GM + i] = DBsum[i] - d11[GK + i] }

    let CS_CQ_DCsum = hour3.sumOf(DC, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let GN = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GN + i] = CS_CQ_DCsum[i] }

    let CS_DH_DQsum = hour3.sumOf(DQ, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let GO = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GO + i] = CS_DH_DQsum[i] }

    let DCsum = hour3.sum(days: daysCS, range: DC)
    /// Remaining CCU cap outside of harm op after min harm
    let GP = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { d11[GP + i] = DCsum[i] - d11[GN + i] }

    let CS_CQ_DDsum = hour3.sumOf(DD, days: daysCS, condition: CQ, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let GQ = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[GQ + i] = CS_CQ_DDsum[i] }

    let DDsum = hour3.sum(days: daysCS, range: DD)
    let CS_DH_DRsum = hour3.sumOf(DR, days: daysCS, condition: DH, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let GR = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[GR + i] = CS_DH_DRsum[i] }

    /// Remaining EY cap outside of harm op period
    let GS = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { d11[GS + i] = DDsum[i] - d11[GQ + i] }
  }
}
