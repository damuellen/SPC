extension TunOl {
  func d11(case j: Int, _ d11: inout [Double], hour: [Double]) {
    let (CM, CN, CQ, CR, CS) = (727080, 735840, 762120, 770880, 779640)
    let (CT, CU, CV, CW, CX) = (788400, 797160, 805920, 814680, 823440)
    let (CY, CZ, DA, DB, DC) = (832200, 840960, 849720, 858480, 867240)
    let (DD, DE, DF, DH, DI) = (876000, 884760, 893520, 911040, 919800)
    let (DJ, DK, DL, DM, DN) = (928560, 937320, 946080, 954840, 963600)
    let (DO, DP, DQ, DR, DS, DT) = (972360, 981120, 989880, 998640, 1_007_400, 1_016_160)
    let days: [[Int]] = hour[(CS + 1)..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    /// Grid import for min harm and stby during  harm op
    let EY: Int = 0
    /// Grid import for max harm and stby during  harm opC
    let CO: Int = 271560

    // SUMIFS(Calculation!CO5:CO8764,Calculation!CS$5:CS8764,"="&$A6,Calculation!CQ5:CQ8764,">0")
    hour.sumOf(CO, days: days, into: &d11, at: EY, condition: CQ, predicate: notZero)
    let EZ: Int = 365
    let DU: Int = 280320

    // SUMIFS(Calculation!DU5:DU8764,Calculation!CS5:CS8764,"="&$A6,Calculation!DH5:DH8764,">0")
    hour.sumOf(DU, days: days, into: &d11, at: EZ, condition: DH, predicate: notZero)
    /// Grid import for min/max harm and stby outside harm op
    let FA: Int = 730
    /// Available heat after TES chrg outside of harm op period
    // let FB: Int = 1095

    let CS_COsum = hour.sum(days: days, range: CO)
    // SUMIF(Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CO$5:$CO$8764)-EY6
    for i in 0..<365 { d11[FA + i] = CS_COsum[i] - d11[EY + i] }

    // let CS_CQ_CJsum = hour.sumOfRanges(CJ, days: days, range1: hour, condition: CQ, predicate: { $0.isZero })
    // let CS_CQ_Jsum = hour0.sumOfRanges(J, days: days, range1: hour, condition: CQ, predicate: { $0.isZero })
    // let CS_CC_CQ_CBsum = hour.sumOfRanges(CB, days: days, range1: hour, condition1: CQ, predicate1: { $0.isZero }, range2: hour2, condition2: CC, predicate2: { $0 > 0.0 })
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    //+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output
    //-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // for i in 0..<365 { d11[FB + i] = CS_CQ_Jsum[i] + CS_CC_CQ_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i] }
    let CQsum = hour.sum(days: days, range: CQ)
    /// El cons considering min harm op during harm op period including grid import
    let FC: Int = 1460
    hour.sumOf(CT, days: days, into: &d11, at: FC, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FC + i] += CQsum[i] }

    let DHsum = hour.sum(days: days, range: DH)
    /// El cons considering max harm op during harm op period including grid import
    let FD: Int = 1825
    hour.sumOf(CT, days: days, into: &d11, at: FD, condition: DH, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FD + i] += DHsum[i] }

    /// El cons considering min/max harm op outside  harm op period including grid import (if any)
    let FE: Int = 2190
    hour.sumOf(CT, days: days, into: &d11, at: FE, condition: CQ, predicate: { $0.isZero })
    // =MAX(0,SUMIFS(Calculation!$CT$5:$CT$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d11[FE + i] = max(0, d11[FE + i] - overall_stup_cons[j]) }

    let CRsum = hour.sum(days: days, range: CR)
    /// Harm heat cons considering min harm op during harm op period
    let FF: Int = 2555
    hour.sumOf(CU, days: days, into: &d11, at: FF, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FF + i] += CRsum[i] }

    let DIsum = hour.sum(days: days, range: DI)
    /// Harm heat cons considering max harm op during harm op period
    let FG: Int = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(CU, days: days, into: &d11, at: FG, condition: DH, predicate: notZero)
    for i in 0..<365 { d11[FG + i] += DIsum[i] }

    /// Harm heat cons outside of harm op period
    let FH: Int = 3285
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    hour.sumOf(CU, days: days, into: &d11, at: FH, condition: CQ, predicate: { $0.isZero })

    /// Electr demand not covered after min harm and stby during harm op period
    let FI: Int = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CX, days: days, into: &d11, at: FI, condition: CQ, predicate: notZero)

    /// Electr demand not covered after max harm and stby during harm op period
    let FJ: Int = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DL, days: days, into: &d11, at: FJ, condition: DH, predicate: notZero)

    let CXsum = hour.sum(days: days, range: CX)
    /// Electr demand not covered after min/max harm and stby outside harm op period
    let FK: Int = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { d11[FK + i] = CXsum[i] - d11[FI + i] }

    /// El boiler op considering min harm op during harm op period
    let FL: Int = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CZ, days: days, into: &d11, at: FL, condition: CQ, predicate: notZero)

    /// El boiler op considering max harm op during harm op period
    let FM: Int = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DN, days: days, into: &d11, at: FM, condition: DH, predicate: notZero)

    let CZsum = hour.sum(days: days, range: CZ)
    /// El boiler op outside harm op period
    let FN: Int = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { d11[FN + i] = CZsum[i] - d11[FL + i] }

    let CS_CQ_CMsum = hour.sumOfRanges(CM, days: days, range1: hour, condition: CQ, predicate: notZero)
    /// Total aux cons during harm op period
    let FO: Int = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FO + i] = CS_CQ_CMsum[i] }

    let CMsum = hour.sum(days: days, range: CM)
    /// Total aux cons outside of harm op period
    let FP: Int = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { d11[FP + i] = CMsum[i] - d11[FO + i] }

    let CS_CQ_CNsum = hour.sumOfRanges(CN, days: days, range1: hour, condition: CQ, predicate: notZero)
    /// El cons not covered during harm op period
    let FQ: Int = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FQ + i] = CS_CQ_CNsum[i] }

    let CNsum = hour.sum(days: days, range: CN)
    /// El cons not covered outside of harm op period
    let FR: Int = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { d11[FR + i] = CNsum[i] - d11[FQ + i] }

    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let FS: Int = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CV, days: days, into: &d11, at: FS, condition: CQ, predicate: notZero)

    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let FT: Int = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DJ, days: days, into: &d11, at: FT, condition: DH, predicate: notZero)

    let CVsum = hour.sum(days: days, range: CV)
    /// Remaining PV el outside of harm op period
    let FU: Int = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { d11[FU + i] = CVsum[i] - d11[FS + i] }

    /// Remaining CSP heat after min harm during harm op period
    let FV: Int = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CW, days: days, into: &d11, at: FV, condition: CQ, predicate: notZero)

    /// Remaining CSP heat after max harm op during harm op period
    let FW: Int = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DK, days: days, into: &d11, at: FW, condition: DH, predicate: notZero)

    let CWsum = hour.sum(days: days, range: CW)
    /// Remaining CSP heat outside of harm op period
    let FX: Int = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { d11[FX + i] = CWsum[i] - d11[FV + i] }

    /// Max BESS night prep after min harm cons during harm op period
    let FY: Int = 9490
    hour.sumOf(DE, days: days, into: &d11, at: FY, condition: CQ, predicate: notZero)
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FY + i] = min(d11[FY + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let FZ: Int = 9855
    hour.sumOf(DS, days: days, into: &d11, at: FZ, condition: DH, predicate: notZero)
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FZ + i] = min(d11[FZ + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let GA: Int = 10220
    // =MIN(SUMIFS(Calculation!$DE$5:$DE$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0"),BESS_cap_ud/BESS_chrg_eff)
    hour.sumOf(DE, days: days, into: &d11, at: GA, condition: CQ, predicate: { $0.isZero })
    for i in 0..<365 { d11[GA + i] = min(d11[GA + i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max grid export after min harm cons during harm op period
    let GB: Int = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DF, days: days, into: &d11, at: GB, condition: CQ, predicate: notZero)

    /// Max grid export after max harm cons during harm op period
    let GC: Int = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DT, days: days, into: &d11, at: GC, condition: DH, predicate: notZero)

    let DFsum = hour.sum(days: days, range: DF)
    /// Max grid export outside of harm op period
    let GD: Int = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { d11[GD + i] = DFsum[i] - d11[GB + i] }

    /// Remaining grid import during harm op period after min harm
    let GE: Int = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CY, days: days, into: &d11, at: GE, condition: CQ, predicate: notZero)

    /// Remaining grid import during harm op period after max harm
    let GF: Int = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DM, days: days, into: &d11, at: GF, condition: DH, predicate: notZero)

    let CYsum = hour.sum(days: days, range: CY)
    /// Remaining grid import outside of harm op period
    let GG: Int = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { d11[GG + i] = CYsum[i] - d11[GE + i] }

    /// Remaining El boiler cap during harm op period after min harm
    let GH: Int = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DA, days: days, into: &d11, at: GH, condition: CQ, predicate: notZero)

    /// Remaining El boiler cap during harm op period after max harm
    let GI: Int = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DO, days: days, into: &d11, at: GI, condition: DH, predicate: notZero)

    let DAsum = hour.sum(days: days, range: DA)
    /// Remaining El boiler cap outside of harm op period
    let GJ: Int = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { d11[GJ + i] = DAsum[i] - d11[GH + i] }

    /// Remaining MethSynt cap during harm op after min harm op
    let GK: Int = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DB, days: days, into: &d11, at: GK, condition: CQ, predicate: notZero)

    /// Remaining MethSynt cap during harm op period after max harm op
    let GL: Int = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DP, days: days, into: &d11, at: GL, condition: DH, predicate: notZero)

    let DBsum = hour.sum(days: days, range: DB)
    /// Remaining MethSynt cap outside of harm op period
    let GM: Int = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { d11[GM + i] = DBsum[i] - d11[GK + i] }

    /// Remaining CCU cap during harm op after min harm
    let GN: Int = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DC, days: days, into: &d11, at: GN, condition: CQ, predicate: notZero)

    /// Remaining CCU cap during harm op after max harm
    let GO: Int = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DQ, days: days, into: &d11, at: GO, condition: DH, predicate: notZero)

    let DCsum = hour.sum(days: days, range: DC)
    /// Remaining CCU cap outside of harm op after min harm
    let GP: Int = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { d11[GP + i] = DCsum[i] - d11[GN + i] }

    /// Remaining EY cap during harm op after min harm
    let GQ: Int = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DD, days: days, into: &d11, at: GQ, condition: CQ, predicate: notZero)

    let DDsum = hour.sum(days: days, range: DD)

    /// Remaining EY cap during harm op period after max harm
    let GR: Int = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DR, days: days, into: &d11, at: GR, condition: DH, predicate: notZero)

    /// Remaining EY cap outside of harm op period
    let GS: Int = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { d11[GS + i] = DDsum[i] - d11[GQ + i] }
  }
}
