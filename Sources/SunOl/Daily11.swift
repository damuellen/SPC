extension TunOl {
  func d11(_ d11: inout [Double], hour: [Double], case j: Int) {
    let (CM, CN, CQ, CR, CS) = (727080, 735840, 762120, 770880, 779640)
    let (CT, CU, CV, CW, CX) = (788400, 797160, 805920, 814680, 823440)
    let (CY, CZ, DA, DB, DC) = (832200, 840960, 849720, 858480, 867240)
    let (DD, DE, DF, DH, DI) = (876000, 884760, 893520, 911040, 919800)
    let (DJ, DK, DL, DM, DN) = (928560, 937320, 946080, 954840, 963600)
    let (DO, DP, DQ, DR, DS, DT) = (972360, 981120, 989880, 998640, 1_007_400, 1_016_160)
    let days: [[Int]] = hour[(CS + 1)..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    /// Grid import for min harm and stby during  harm op
    let EY: Int = 11680
    /// Grid import for max harm and stby during  harm opC
    let CO: Int = 271560
    // SUMIFS(Calculation!CO5:CO8764,Calculation!CS$5:CS8764,"="&$A6,Calculation!CQ5:CQ8764,">0")
    hour.sumOf(CO, days: days, into: &d11, at: EY, condition: CQ, predicate: notZero)
    let EZ: Int = 12045
    let DU: Int = 280320
    // SUMIFS(Calculation!DU5:DU8764,Calculation!CS5:CS8764,"="&$A6,Calculation!DH5:DH8764,">0")
    hour.sumOf(DU, days: days, into: &d11, at: EZ, condition: DH, predicate: notZero)
    /// Grid import for min/max harm and stby outside harm op
    let FA: Int = 12410
    let FB: Int = 12775
    // SUMIF(Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CO$5:$CO$8764)-EY6
    hour.sum(days: days, range: CO, into: &d11, at: FA)
    for i in 0..<365 { d11[FA + i] -= d11[EY + i] }
    /// El cons considering min harm op during harm op period including grid import
    let FC: Int = 13140
    hour.sum(days: days, range: CQ, into: &d11, at: FB)
    hour.sumOf(CT, days: days, into: &d11, at: FC, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FC + i] += d11[FB + i] }
    /// El cons considering max harm op during harm op period including grid import
    let FD: Int = 13505
    hour.sum(days: days, range: DH, into: &d11, at: FB)
    hour.sumOf(CT, days: days, into: &d11, at: FD, condition: DH, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FD + i] += d11[FB + i] }
    /// El cons considering min/max harm op outside  harm op period including grid import (if any)
    let FE: Int = 13870
    hour.sumOf(CT, days: days, into: &d11, at: FE, condition: CQ, predicate: { $0.isZero })
    // =MAX(0,SUMIFS(Calculation!$CT$5:$CT$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d11[FE + i] = max(0, d11[FE + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    let FF: Int = 14235
    hour.sum(days: days, range: CR, into: &d11, at: FB)
    hour.sumOf(CU, days: days, into: &d11, at: FF, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FF + i] += d11[FB + i] }
    /// Harm heat cons considering max harm op during harm op period
    let FG: Int = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sum(days: days, range: DI, into: &d11, at: FB)
    hour.sumOf(CU, days: days, into: &d11, at: FG, condition: DH, predicate: notZero)
    for i in 0..<365 { d11[FG + i] += d11[FB + i] }
    /// Harm heat cons outside of harm op period
    let FH: Int = 14965
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    hour.sumOf(CU, days: days, into: &d11, at: FH, condition: CQ, predicate: { $0.isZero })
    /// Electr demand not covered after min harm and stby during harm op period
    let FI: Int = 15330
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CX, days: days, into: &d11, at: FI, condition: CQ, predicate: notZero)
    /// Electr demand not covered after max harm and stby during harm op period
    let FJ: Int = 15695
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DL, days: days, into: &d11, at: FJ, condition: DH, predicate: notZero)
    /// Electr demand not covered after min/max harm and stby outside harm op period
    let FK: Int = 16060
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    hour.sum(days: days, range: CX, into: &d11, at: FK)
    for i in 0..<365 { d11[FK + i] -= d11[FI + i] }
    /// El boiler op considering min harm op during harm op period
    let FL: Int = 16425
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CZ, days: days, into: &d11, at: FL, condition: CQ, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    let FM: Int = 16790
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DN, days: days, into: &d11, at: FM, condition: DH, predicate: notZero)
    /// El boiler op outside harm op period
    let FN: Int = 17155
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    hour.sum(days: days, range: CZ, into: &d11, at: FN)
    for i in 0..<365 { d11[FN + i] -= d11[FL + i] }
    /// Total aux cons during harm op period
    let FO: Int = 17520
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOfRanges(CM, days: days, into: &d11, at: FO, range1: hour, condition: CQ, predicate: notZero)
    /// Total aux cons outside of harm op period
    let FP: Int = 17885
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    hour.sum(days: days, range: CM, into: &d11, at: FP)
    for i in 0..<365 { d11[FP + i] -= d11[FO + i] }
    /// El cons not covered during harm op period
    let FQ: Int = 18250
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOfRanges(CN, days: days, into: &d11, at: FQ, range1: hour, condition: CQ, predicate: notZero)
    /// El cons not covered outside of harm op period
    let FR: Int = 18615
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    hour.sum(days: days, range: CN, into: &d11, at: FR)
    for i in 0..<365 { d11[FR + i] -= d11[FQ + i] }
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let FS: Int = 18980
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CV, days: days, into: &d11, at: FS, condition: CQ, predicate: notZero)
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let FT: Int = 19345
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DJ, days: days, into: &d11, at: FT, condition: DH, predicate: notZero)
    /// Remaining PV el outside of harm op period
    let FU: Int = 19710
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    hour.sum(days: days, range: CV, into: &d11, at: FU)
    for i in 0..<365 { d11[FU + i] -= d11[FS + i] }
    /// Remaining CSP heat after min harm during harm op period
    let FV: Int = 20075
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CW, days: days, into: &d11, at: FV, condition: CQ, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    let FW: Int = 20440
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DK, days: days, into: &d11, at: FW, condition: DH, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    let FX: Int = 20805
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    hour.sum(days: days, range: CW, into: &d11, at: FX)
    for i in 0..<365 { d11[FX + i] -= d11[FV + i] }
    /// Max BESS night prep after min harm cons during harm op period
    let FY: Int = 21170
    hour.sumOf(DE, days: days, into: &d11, at: FY, condition: CQ, predicate: notZero)
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FY + i] = min(d11[FY + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep after max harm cons during harm op period
    let FZ: Int = 21535
    hour.sumOf(DS, days: days, into: &d11, at: FZ, condition: DH, predicate: notZero)
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FZ + i] = min(d11[FZ + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep outside of harm op period
    let GA: Int = 21900
    // =MIN(SUMIFS(Calculation!$DE$5:$DE$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0"),BESS_cap_ud/BESS_chrg_eff)
    hour.sumOf(DE, days: days, into: &d11, at: GA, condition: CQ, predicate: { $0.isZero })
    for i in 0..<365 { d11[GA + i] = min(d11[GA + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    let GB: Int = 22265
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DF, days: days, into: &d11, at: GB, condition: CQ, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    let GC: Int = 22630
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DT, days: days, into: &d11, at: GC, condition: DH, predicate: notZero)
    /// Max grid export outside of harm op period
    let GD: Int = 22995
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    hour.sum(days: days, range: DF, into: &d11, at: GD)
    for i in 0..<365 { d11[GD + i] -= d11[GB + i] }
    /// Remaining grid import during harm op period after min harm
    let GE: Int = 23360
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CY, days: days, into: &d11, at: GE, condition: CQ, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    let GF: Int = 23725
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DM, days: days, into: &d11, at: GF, condition: DH, predicate: notZero)
    /// Remaining grid import outside of harm op period
    let GG: Int = 24090
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    hour.sum(days: days, range: CY, into: &d11, at: GG)
    for i in 0..<365 { d11[GG + i] -= d11[GE + i] }
    /// Remaining El boiler cap during harm op period after min harm
    let GH: Int = 24455
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DA, days: days, into: &d11, at: GH, condition: CQ, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    let GI: Int = 24820
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DO, days: days, into: &d11, at: GI, condition: DH, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    let GJ: Int = 25185
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    hour.sum(days: days, range: DA, into: &d11, at: GJ)
    for i in 0..<365 { d11[GJ + i] -= d11[GH + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    let GK: Int = 25550
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DB, days: days, into: &d11, at: GK, condition: CQ, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    let GL: Int = 25915
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DP, days: days, into: &d11, at: GL, condition: DH, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    let GM: Int = 26280
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    hour.sum(days: days, range: DB, into: &d11, at: GM)
    for i in 0..<365 { d11[GM + i] -= d11[GK + i] }
    /// Remaining CCU cap during harm op after min harm
    let GN: Int = 26645
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DC, days: days, into: &d11, at: GN, condition: CQ, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    let GO: Int = 27010
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DQ, days: days, into: &d11, at: GO, condition: DH, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    let GP: Int = 27375
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    hour.sum(days: days, range: DC, into: &d11, at: GP)
    for i in 0..<365 { d11[GP + i] -= d11[GN + i] }
    /// Remaining EY cap during harm op after min harm
    let GQ: Int = 27740
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DD, days: days, into: &d11, at: GQ, condition: CQ, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    let GR: Int = 28105
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DR, days: days, into: &d11, at: GR, condition: DH, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    let GS: Int = 28470
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    hour.sum(days: days, range: DD, into: &d11, at: GS)
    for i in 0..<365 { d11[GS + i] -= d11[GQ + i] }
  }
}
