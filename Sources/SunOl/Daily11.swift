
extension TunOl {
  mutating func daily15(hourly0: [Double], hourly2: [Double], hourly3: [Double], daily11: [Double]) -> [Double] {
    let daysCS = [[Int]]()
    let hourlyJ = 26280
    let hourlyL = 43800

    let hourlyCI = 122640
    let hourlyCJ = 131400

    let hourlyCM = 157680
    let hourlyCN = 166440

    let hourlyCQ = 8760
    let hourlyCR = 17520

    let hourlyCT = 35040
    let hourlyCU = 43800
    let hourlyCV = 52560
    let hourlyCW = 61320
    let hourlyCX = 70080
    let hourlyCY = 78840
    let hourlyCZ = 87600
    let hourlyDA = 96360
    let hourlyDB = 105120
    let hourlyDC = 113880
    let hourlyDD = 122640
    let hourlyDE = 131400
    let hourlyDF = 140160

    let hourlyDH = 157680
    let hourlyDI = 166440
    let hourlyDJ = 175200
    let hourlyDK = 183960
    let hourlyDL = 192720
    let hourlyDM = 201480
    let hourlyDN = 210240
    let hourlyDO = 219000
    let hourlyDP = 227760
    let hourlyDQ = 236520
    let hourlyDR = 245280
    let hourlyDS = 254040
    let hourlyDT = 262800

    var daily15 = [Double](repeating: 0, count: 17_155)
    let CS_CQ_Lsum = hourly0.sumOf(hourlyL, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    let CS_CQ_CIsum = hourly2.sumOf(hourlyCI, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })

    /// Available elec after TES chrg during harm op period
    let daily1EY = 0
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // +SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // -SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { daily15[daily1EY + i] = CS_CQ_Lsum[i] + CC_CS_BXsum[i] - CS_CQ_CIsum[i] }

    /// Available elec after TES chrg outside harm op period
    let daily1EZ = 365
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    //+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    //-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // for i in 0..<365 { daily15[daily1EZ + i] = CS_CQ_Lsum[i] + CC_CS_BXsum[i] - CS_CQ_CIsum[i] }

    let CS_CQ_CJsum = hourly2.sumOf(hourlyCJ, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    let CS_CQ_Jsum = hourly0.sumOf(hourlyJ, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Available heat after TES chrg during harm op period
    let daily1FA = 730
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 {
    //   daily15[daily1FA + i] =
    //     CS_CQ_Jsum[i] + CC_CS_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i]
    // }

    /// Available heat after TES chrg outside of harm op period
    let daily1FB = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // for i in 0..<365 {
    //   daily15[daily1FB + i] =
    //     CS_CQ_Jsum[i] + CC_CS_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i]
    // }
    let CQsum = hourly3.sum(days: daysCS, range: hourlyCQ)
    let CS_CQ_CTsum = hourly3.sumOf(hourlyCT, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Harm el cons considering min harm op during harm op period
    let daily1FC = 1460
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FC + i] = CQsum[i] + CS_CQ_CTsum[i] }

    let DHsum = hourly3.sum(days: daysCS, range: hourlyDH)
    let CS_DH_CTsum = hourly3.sumOf(hourlyCT, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Harm el cons considering max harm op during harm op period
    let daily1FD = 1825
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FD + i] = DHsum[i] + CS_DH_CTsum[i] }

    /// Harm el cons outside of harm op period
    let daily1FE = 2190
    // SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { daily15[daily1FE + i] = CS_CQ_CTsum[i] }

    let CRsum = hourly3.sum(days: daysCS, range: hourlyCR)
    let CS_CQ_CUsum = hourly3.sumOf(hourlyCU, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Harm heat cons considering min harm op during harm op period
    let daily1FF = 2555
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FF + i] = CRsum[i] + CS_CQ_CUsum[i] }

    let DIsum = hourly3.sum(days: daysCS, range: hourlyDI)
    let CS_DH_CUsum = hourly3.sumOf(hourlyCU, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Harm heat cons considering max harm op during harm op period
    let daily1FG = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FG + i] = DIsum[i] + CS_DH_CUsum[i] }

    /// Harm heat cons outside of harm op period
    let daily1FH = 3285
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { daily15[daily1FH + i] = CS_CQ_CUsum[i] }

    let CS_CQ_CXsum = hourly3.sumOf(hourlyCX, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Grid import considering min harm op during harm op period
    let daily1FI = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FI + i] = CS_CQ_CXsum[i] }

    let CS_DH_DLsum = hourly3.sumOf(hourlyDL, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Grid import considering max harm op during harm op period
    let daily1FJ = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FJ + i] = CS_DH_DLsum[i] }

    let CXsum = hourly3.sum(days: daysCS, range: hourlyCX)
    /// Grid import  outside of harm op period
    let daily1FK = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { daily15[daily1FK + i] = CXsum[i] - daily15[daily1FI + i] }

    let CS_CQ_CZsum = hourly3.sumOf(hourlyCZ, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// El boiler op considering min harm op during harm op period
    let daily1FL = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FL + i] = CS_CQ_CZsum[i] }

    let CS_DH_DNsum = hourly3.sumOf(hourlyDN, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// El boiler op considering max harm op during harm op period
    let daily1FM = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FM + i] = CS_DH_DNsum[i] }

    let CZsum = hourly3.sum(days: daysCS, range: hourlyCZ)
    /// El boiler op outside harm op period
    let daily1FN = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { daily15[daily1FN + i] = CZsum[i] - daily15[daily1FL + i] }

    let CS_CQ_CMsum = hourly2.sumOf(hourlyCM, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Total aux cons during harm op period
    let daily1FO = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FO + i] = CS_CQ_CMsum[i] }

    let CMsum = hourly3.sum(days: daysCS, range: hourlyCM)
    /// Total aux cons outside of harm op period
    let daily1FP = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { daily15[daily1FP + i] = CMsum[i] - daily15[daily1FO + i] }

    let CS_CQ_CNsum = hourly2.sumOf(hourlyCN, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// El cons not covered during harm op period
    let daily1FQ = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FQ + i] = CS_CQ_CNsum[i] }

    let CNsum = hourly3.sum(days: daysCS, range: hourlyCN)
    /// El cons not covered outside of harm op period
    let daily1FR = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { daily15[daily1FR + i] = CNsum[i] - daily15[daily1FQ + i] }

    let CS_CQ_CVsum = hourly3.sumOf(hourlyCV, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let daily1FS = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FS + i] = CS_CQ_CVsum[i] }

    let CS_DH_DJsum = hourly3.sumOf(hourlyDJ, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let daily1FT = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FT + i] = CS_DH_DJsum[i] }

    let CVsum = hourly3.sum(days: daysCS, range: hourlyCV)
    /// Remaining PV el outside of harm op period
    let daily1FU = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { daily15[daily1FU + i] = CVsum[i] - daily15[daily1FS + i] }

    let CS_CQ_CWsum = hourly3.sumOf(hourlyCW, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining CSP heat after min harm during harm op period
    let daily1FV = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FV + i] = CS_CQ_CWsum[i] }

    let CS_DH_DKsum = hourly3.sumOf(hourlyDK, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining CSP heat after max harm op during harm op period
    let daily1FW = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FW + i] = CS_DH_DKsum[i] }

    let CWsum = hourly3.sum(days: daysCS, range: hourlyCW)
    /// Remaining CSP heat outside of harm op period
    let daily1FX = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { daily15[daily1FX + i] = CWsum[i] - daily15[daily1FV + i] }

    let CS_CQ_DEsum = hourly3.sumOf(hourlyDE, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Max BESS night prep after min harm cons during harm op period
    let daily1FY = 9490
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1FY + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_DH_DSsum = hourly3.sumOf(hourlyDS, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Max BESS night prep after max harm cons during harm op period
    let daily1FZ = 9855
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1FZ + i] = min(CS_DH_DSsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let daily1GA = 10220
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1GA + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_CQ_DFsum = hourly3.sumOf(hourlyDF, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Max grid export after min harm cons during harm op period
    let daily1GB = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GB + i] = CS_CQ_DFsum[i] }

    let CS_DH_DTsum = hourly3.sumOf(hourlyDT, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Max grid export after max harm cons during harm op period
    let daily1GC = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GC + i] = CS_DH_DTsum[i] }

    let DFsum = hourly3.sum(days: daysCS, range: hourlyDF)
    /// Max grid export outside of harm op period
    let daily1GD = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { daily15[daily1GD + i] = DFsum[i] - daily15[daily1GB + i] }

    let CS_CQ_CYsum = hourly3.sumOf(hourlyCY, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after min harm
    let daily1GE = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GE + i] = CS_CQ_CYsum[i] }

    let CS_DH_DMsum = hourly3.sumOf(hourlyDM, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining grid import during harm op period after max harm
    let daily1GF = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GF + i] = CS_DH_DMsum[i] }

    let CYsum = hourly3.sum(days: daysCS, range: hourlyCY)
    /// Remaining grid import outside of harm op period
    let daily1GG = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { daily15[daily1GG + i] = CYsum[i] - daily15[daily1GE + i] }

    let CS_CQ_DAsum = hourly3.sumOf(hourlyDA, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after min harm
    let daily1GH = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GH + i] = CS_CQ_DAsum[i] }

    let CS_DH_DOsum = hourly3.sumOf(hourlyDO, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining El boiler cap during harm op period after max harm
    let daily1GI = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GI + i] = CS_DH_DOsum[i] }

    let DAsum = hourly3.sum(days: daysCS, range: hourlyDA)
    /// Remaining El boiler cap outside of harm op period
    let daily1GJ = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { daily15[daily1GJ + i] = DAsum[i] - daily11[daily1GH + i] }

    let CS_CQ_DBsum = hourly3.sumOf(hourlyDB, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op after min harm op
    let daily1GK = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GK + i] = CS_CQ_DBsum[i] }

    let CS_DH_DPsum = hourly3.sumOf(hourlyDP, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining MethSynt cap during harm op period after max harm op
    let daily1GL = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GL + i] = CS_DH_DPsum[i] }

    let DBsum = hourly3.sum(days: daysCS, range: hourlyDB)
    /// Remaining MethSynt cap outside of harm op period
    let daily1GM = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { daily15[daily1GM + i] = DBsum[i] - daily15[daily1GK + i] }

    let CS_CQ_DCsum = hourly3.sumOf(hourlyDC, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after min harm
    let daily1GN = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GN + i] = CS_CQ_DCsum[i] }

    let CS_DH_DQsum = hourly3.sumOf(hourlyDQ, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining CCU cap during harm op after max harm
    let daily1GO = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GO + i] = CS_DH_DQsum[i] }

    let DCsum = hourly3.sum(days: daysCS, range: hourlyDC)
    /// Remaining CCU cap outside of harm op after min harm
    let daily1GP = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { daily15[daily1GP + i] = DCsum[i] - daily15[daily1GN + i] }

    let CS_CQ_DDsum = hourly3.sumOf(hourlyDD, days: daysCS, condition: hourlyCQ, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op after min harm
    let daily1GQ = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GQ + i] = CS_CQ_DDsum[i] }

    let DDsum = hourly3.sum(days: daysCS, range: hourlyDD)
    let CS_DH_DRsum = hourly3.sumOf(hourlyDR, days: daysCS, condition: hourlyDH, predicate: { $0 > 0 })
    /// Remaining EY cap during harm op period after max harm
    let daily1GR = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GR + i] = CS_DH_DRsum[i] }

    /// Remaining EY cap outside of harm op period
    let daily1GS = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { daily15[daily1GS + i] = DDsum[i] - daily15[daily1GQ + i] }
    return daily15
  }
}
