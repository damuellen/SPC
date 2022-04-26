extension TunOl {
  func d172(_ d7: inout [Double], case j: Int, d1: [Double], d5: [Double], d6: [Double]) {
    let (C, D, E, T, U, V, Z, AA, AB, AC) = (0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125)  // d1

    let (FC, FD, FE, FI, FJ, FR, FS, FT, FV, FW, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI) = (
      1460, 1825, 2190, 2555, 4015, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d5

    let (GY, GZ, HA, HE, HF, HN, HO, HP, HR, HS, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE) = (
      1460, 1825, 2190, 3650, 4015, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d6
    let FX = 9125
    let HT = 9125
    let FK = 4380
    let HG = 4380
    let ddJP = 8760
    let dddJP = 26280
    let ddKG = 14965
    let ddKI = 15330
    let ddAMKG = 23360  // let ddLF = 23360
    let dddKI = 25550  // let ddLL = 25550
    let ddAMKI = 38690  // let ddMW = 38690
    let ddKZ = 21535
    let equiv_harmonious_range = (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    /// el cons for harm op during harm op period
    let ddLB = 21900
    // LB=IF(FC6=0,0,IF(OR(JP6=0;KG6=0),FD6,FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))
    for i in 0..<365 { d7[ddLB + i] = iff(d5[FC + i].isZero, .zero, iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FD + i], (d5[FC + i] + (d6[GY + i] - d5[FC + i]) * d7[ddAMKG + i]) + ((d5[FD + i] + (d6[GZ + i] - d5[FD + i]) * d7[ddAMKG + i]) - (d5[FC + i] + (d6[GY + i] - d5[FC + i]) * d7[ddAMKG + i])) * d7[dddJP + i])) }

    /// el cons for night prep during harm op period
    let ddLC = 22265
    // LC=IF(or(JP6=0,kg6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddLC + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero, d1[Z + i] + (d1[AA + i] - d1[Z + i]) / equiv_harmonious_range * (d7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// el to cover aux cons during harm op period
    let ddLD = 22630
    for i in 0..<365 { d7[ddLD + i] = 99 }
    // // LD=IF(OR(JP6=0,KG6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddLD + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero,
    //     d5[FO + i] + (d6[HK + i] - d5[FO + i])
    //       * d7[ddAMKG + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddLE = 22995
    // LE=IF(OR(JP6=0,KG6=0),MIN(FR6/BESS_chrg_eff,FZ6),MIN(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d7[ddLE + i] = iff(
        or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), min(d5[FR + i] / BESS_chrg_eff, d5[FZ + i]),
        min((d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKG + i] + ((d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) * d7[ddAMKG + i]) - (d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKG + i])) * d7[dddJP + i]), (d5[FR + i] + (d6[HN + i] - d5[FR + i]) * d7[ddAMKG + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddLF = 23360 // reused
    // // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddLF + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero,
    //     (d5[FL + i]
    //       + (d6[HH + i] - d5[FL + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d5[FM + i]
    //         + (d6[HI + i] - d5[FM + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (d5[FL + i]
    //           + (d6[HH + i] - d5[FL + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d7[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * d7[dddJP + i])
    // }

    // /// heat cons for harm op during harm op period
    // let ddLL = 25550 // reused
    // // LL=IF(OR(JP6=0,KG6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddLL + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero,
    //     (d5[FF + i]
    //       + (d6[HB + i] - d5[FF + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d5[FG + i]
    //         + (d6[HC + i] - d5[FG + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (d5[FF + i]
    //           + (d6[HB + i] - d5[FF + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d7[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * d7[dddJP + i])
    // }

    /// heat cons for night prep during harm op period
    let ddLM = 25915
    // LM=IF(OR(JP6=0,KG6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddLM + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero, d1[AB + i] + (d1[AC + i] - d1[AB + i]) / equiv_harmonious_range * (d7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddLN = 26280 // reused
    // // LN=IF(OR(JP6=0,KG6=0),0,LF6*El_boiler_eff)
    // for i in 0..<365 {
    //   d7[ddLN + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero, d7[ddLF + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddLP = 27010
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[ddLP + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FW + i], d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKG + i] + ((d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKG + i]) - (d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKG + i])) * d7[dddJP + i]) }

    /// heat prod by el boiler for night prep during harm op period
    let ddLO = 26645
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 { d7[ddLO + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), 0, min((d5[GH + i] + (d6[ID + i] - d5[GH + i]) * d7[ddAMKG + i]) + ((d5[GI + i] + (d6[IE + i] - d5[GI + i]) * d7[ddAMKG + i]) - (d5[GH + i] + (d6[ID + i] - d5[GH + i]) * d7[ddAMKG + i])) * d7[dddJP + i], max(0, d7[ddLM + i] - d7[ddLP + i]))) }

    /// Balance of heat during harm op period
    let ddLQ = 27375
    // LQ=LO6+LP6-LM6
    for i in 0..<365 { d7[ddLQ + i] = d7[ddLO + i] + d7[ddLP + i] - d7[ddLM + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddLG = 23725
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { d7[ddLG + i] = d7[ddLO + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddLH = 24090
    // LH=IF(OR(JP6=0,KG6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 { d7[ddLH + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FT + i], d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKG + i] + ((d5[FT + i] + (d6[HP + i] - d5[FT + i]) * d7[ddAMKG + i]) - (d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKG + i])) * d7[dddJP + i]) }

    /// Grid import for harm op during harm op period
    let ddLI = 24455
    // LI=IF(OR(JP6=0,KG6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[ddLI + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FJ + i], (d5[FI + i] + (d6[HE + i] - d5[FI + i]) * d7[ddAMKG + i]) + ((d5[FJ + i] + (d6[HF + i] - d5[FJ + i]) * d7[ddAMKG + i]) - (d5[FI + i] + (d6[HE + i] - d5[FI + i]) * d7[ddAMKG + i])) * d7[dddJP + i])

    }

    /// Grid import for night prep during harm op period
    let ddLJ = 24820
    // LJ=MIN(IF(OR(JP6=0,KG6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      d7[ddLJ + i] = min(
        iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[GF + i], (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKG + i]) + ((d5[GF + i] + (d6[IB + i] - d5[GF + i]) * d7[ddAMKG + i]) - (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKG + i])) * d7[dddJP + i]),
        max(.zero, d7[ddLC + i] - d7[ddLE + i] - d7[ddLG + i] - d7[ddLH + i]))
    }

    /// Balance of electricity during harm op period
    let ddLK = 25185
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { d7[ddLK + i] = d7[ddLH + i] + d7[ddLJ + i] - d7[ddLC + i] - d7[ddLE + i] - d7[ddLG + i] }

    /// el cons for harm op outside of harm op period
    let ddLR = 27740
    // LR=IF(OR(FE6=0,JP6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddLR + i] = iff(or(d5[FE + i].isZero, d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero, d5[FE + i] + (d6[HA + i] - d5[FE + i]) * d7[ddAMKG + i]) }

    /// el to cover aux cons outside of harm op period
    let ddLS = 28105
    // LS=IF(OR(JP6=0,KG6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddLS + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FK + i], d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKG + i]) }

    /// el from BESS discharging outside of harm op period
    let ddLU = 28835
    // LU=MIN(LS6,(IF(LE6*BESS_chrg_eff>=LS6,0,IF(OR(JP6=0,KG6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+LE6)*BESS_chrg_eff)
    for i in 0..<365 { d7[ddLU + i] = min(d7[ddLS + i], (iff(d7[ddLE + i] * BESS_chrg_eff >= d7[ddLS + i], .zero, iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[GA + i], d5[GA + i] + (d6[HW + i] - d5[GA + i]) * d7[ddAMKG + i])) + d7[ddLE + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddLT = 28470
    // LT=LS6-LU6
    for i in 0..<365 { d7[ddLT + i] = d7[ddLS + i] - d7[ddLU + i] }
    let HQ = 8030
    let FU = 8030
    /// El available outside of harm op period after TES chrg
    let ddLV = 29200
    // LV=max(0,IF(OR(JP6=0,KG6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(LU6/BESS_chrg_eff-LE6))
    for i in 0..<365 { d7[ddLV + i] = max(.zero, iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FU + i], d5[FU + i] + (d6[HQ + i] - d5[FU + i]) * d7[ddAMKG + i]) - (d7[ddLU + i] / BESS_chrg_eff - d7[ddLE + i])) }

    /// Grid import needed outside of harm op period
    let ddLW = 29565
    // LW=MIN(IF(OR(JP6=0,KG6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+LU6),MAX(0,LS6-LT6-LU6-LV6))
    for i in 0..<365 { d7[ddLW + i] = min(iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[GG + i], d6[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKG + i] + d7[ddLU + i]), max(.zero, d7[ddLS + i] - d7[ddLT + i] - d7[ddLU + i] - d7[ddLV + i])) }

    /// Balance of electricity outside of harm op period
    let ddLX = 29930
    // LX=LT6+LU6+LV6+LW6-LS6
    for i in 0..<365 { d7[ddLX + i] = d7[ddLT + i] + d7[ddLU + i] + d7[ddLV + i] + d7[ddLW + i] - d7[ddLS + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddLY = 30295
    // // LY=IF(OR(JP6=0,KG6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddLY + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero,
    //     d5[FH + i] + (d6[HD + i] - d5[FH + i])
    //       * d7[ddAMKG + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddLZ = 30660
    // // LZ=IF(OR(JP6=0,KG6=0),0,LT6*El_boiler_eff)
    // for i in 0..<365 {
    //   d7[ddLZ + i] = iff(
    //     or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), .zero, d7[ddLT + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddMA = 31025
    // MA=IF(OR(JP6=0,KG6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddMA + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[FX + i], d5[FX + i] + (d6[HT + i] - d5[FX + i]) * d7[ddAMKG + i]) }

    /// Balance of heat outside of harm op period
    let ddMB = 31390
    // MB=MA6
    for i in 0..<365 { d7[ddMB + i] = d7[ddMA + i] }

    /// grid export
    let ddMD = 32120
    // MD=MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LX6,IF(OR(JP6=0,KG6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d7[ddMD + i] =
        min(d7[ddLK + i], iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[GC + i], d5[GB + i] + (d6[HX + i] - d5[GB + i]) * d7[ddAMKG + i] + ((d5[GC + i] + (d6[HY + i] - d5[GC + i]) * d7[ddAMKG + i]) - (d5[GB + i] + (d6[HX + i] - d5[GB + i]) * d7[ddAMKG + i])) * d7[dddJP + i]))
        + max(.zero, min(d7[ddLX + i], iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d5[GD + i], d5[GD + i] + (d6[HZ + i] - d5[GD + i]) * d7[ddAMKG + i])))
    }

    /// Grid import
    let ddME = 32485
    // ME=LI6+LW6+LT6+LJ6
    for i in 0..<365 { d7[ddME + i] = d7[ddLI + i] + d7[ddLW + i] + d7[ddLT + i] + d7[ddLJ + i] }

    /// Outside harmonious operation period hours
    let ddMF = 32850
    // MF=IF(OR(JP6=0,KG6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d7[ddMF + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d1[C + i], d1[C + i] + (d1[T + i] - d1[C + i]) / equiv_harmonious_range * (d7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Harmonious operation period hours
    let ddMG = 33215
    // MG=IF(OR(JP6=0,KG6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d7[ddMG + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d1[D + i], d1[D + i] + (d1[U + i] - d1[D + i]) / equiv_harmonious_range * (d7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// PB operating hours
    let ddMH = 33580
    // MH=IF(OR(JP6=0,KG6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d7[ddMH + i] = iff(or(d7[ddJP + i].isZero, d7[ddKG + i].isZero), d1[E + i], d1[E + i] + (d1[V + i] - d1[E + i]) / equiv_harmonious_range * (d7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Pure Methanol prod with day priority and resp night op
    let ddMC = 31755
    // MC=(MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d7[ddMC + i] = max(.zero, d7[ddLB + i] - d7[ddMG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d7[ddLR + i] - d7[ddMF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud
    }

    /// Checksum
    let ddMI = 33945
    // MI=MAX(0,-LK6)+MAX(0,-LQ6)+MAX(0,-LX6)+MAX(0,-MB6)
    for i in 0..<365 {
      let MB = max(.zero, -d7[ddLK + i]) + max(.zero, -d7[ddLQ + i]) + max(.zero, -d7[ddLX + i]) + max(.zero, -d7[ddMB + i])
      // if MB > 1E-13 { print("Checksum error daily 1", i, j, MB); break }
      d7[ddMI + i] = MB
    }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// el cons for harm op during harm op period
    let ddMK = 34310
    // MK=IF(FC6=0;0;IF(OR(KZ6=0,KI6=0),FD6,FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d7[ddMK + i] = iff(
        d5[FC + i].isZero, .zero,
        iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[FD + i], d5[FC + i] + (d6[GY + i] - d5[FC + i]) * d7[ddAMKI + i] + ((d5[FD + i] + (d6[GZ + i] - d5[FD + i]) * d7[ddAMKI + i]) - (d5[FC + i] + (d6[GY + i] - d5[FC + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    let ddML = 34675
    // ML=IF(OR(KI6=0,KZ6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddML + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), .zero, d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[dddKI + i]) }

    /// el to cover aux cons during harm op period
    // let ddMM = 35040
    // for i in 0..<365 { d7[ddMM + i] = 99 }
    // // MM=IF(OR(KZ6=0,KI6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddMM + i] = iff(
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero,
    //     d5[FO + i] + (d6[HK + i] - d5[FO + i])
    //       * d7[ddAMKI + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddMN = 35405
    // MN=MIN(IF(OR(KI6=0,KZ6=0),MIN(FR6/BESS_chrg_eff,FZ6),(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d7[ddMN + i] = iff(
        or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), min(d5[FR + i] / BESS_chrg_eff, d5[FZ + i]),
        min(
          (d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKI + i] + ((d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) * d7[ddAMKI + i]) - (d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc)),
          (d5[FR + i] + (d6[HN + i] - d5[FR + i]) * d7[ddAMKI + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddMO = 35770
    // for i in 0..<365 { d7[ddMO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddMO + i] = iff(
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero,
    //     (d5[FL + i]
    //       + (d6[HH + i] - d5[FL + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d5[FM + i]
    //         + (d6[HI + i] - d5[FM + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (d5[FL + i]
    //           + (d6[HH + i] - d5[FL + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d7[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    // /// heat cons for harm op during harm op period
    // let ddMU = 37960
    // // MU=IF(OR(KZ6=0,KI6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddMU + i] = iff(
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero,
    //     (d5[FF + i]
    //       + (d6[HB + i] - d5[FF + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d5[FG + i]
    //         + (d6[HC + i] - d5[FG + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (d5[FF + i]
    //           + (d6[HB + i] - d5[FF + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d7[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    /// heat cons for night prep during harm op period
    let ddMV = 38325
    // MV=IF(OR(KI6=0,KZ6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddMV + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), .zero, d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]) }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddMW = 38690
    // // MW=IF(OR(KZ6=0,KI6=0),0,MO6*El_boiler_eff)
    // for i in 0..<365 {
    //   d7[ddMW + i] = iff(
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero, d7[ddMO + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddMY = 39420
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[ddMY + i] = iff(
        or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), d5[FW + i], d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i] + ((d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKI + i]) - (d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// heat prod by el boiler for night prep during harm op period
    let ddMX = 39055
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      d7[ddMX + i] = iff(
        or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), .zero,
        min((d5[GH + i] + (d6[ID + i] - d5[GH + i]) * d7[ddAMKI + i]) + ((d5[GI + i] + (d6[IE + i] - d5[GI + i]) * d7[ddAMKI + i]) - (d5[GH + i] + (d6[ID + i] - d5[GH + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc), max(.zero, d7[ddMV + i] - d7[ddMY + i])))
    }

    /// Balance of heat during harm op period
    let ddMZ = 39785
    // MZ=MX6+MY6-MV6
    for i in 0..<365 { d7[ddMZ + i] = d7[ddMX + i] + d7[ddMY + i] - d7[ddMV + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddMP = 36135
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { d7[ddMP + i] = d7[ddMX + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddMQ = 36500
    // MQ=IF(OR(KI6=0,KZ6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[ddMQ + i] = iff(
        or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), d5[FT + i], d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKI + i] + ((d5[FT + i] + (d6[HP + i] - d5[FT + i]) * d7[ddAMKI + i]) - (d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for harm op during harm op period
    let ddMR = 36865
    // MR=IF(OR(KI6=0,KZ6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d7[ddMR + i] = iff(
        or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[FJ + i], (d5[FI + i] + (d6[HE + i] - d5[FI + i]) * d7[ddAMKI + i]) + ((d5[FJ + i] + (d6[HF + i] - d5[FJ + i]) * d7[ddAMKI + i]) - (d5[FI + i] + (d6[HE + i] - d5[FI + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let ddMS = 37230
    // MS=MIN(IF(OR(KI6=0,KZ6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      d7[ddMS + i] = min(
        iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[GF + i], (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKI + i]) + ((d5[GF + i] + (d6[IB + i] - d5[GF + i]) * d7[ddAMKI + i]) - (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc)),
        max(0, d7[ddML + i] + d7[ddMN + i] + d7[ddMP + i] - d7[ddMQ + i]))
    }

    /// Balance of electricity during harm op period
    let ddMT = 37595
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { d7[ddMT + i] = d7[ddMQ + i] + d7[ddMS + i] - d7[ddML + i] - d7[ddMN + i] - d7[ddMP + i] }
    /// el cons for harm op outside of harm op period
    let ddNA = 40150
    // NA=IF(OR(KI6=0,KZ6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddNA + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), .zero, d5[FE + i] + (d6[HA + i] - d5[FE + i]) * d7[ddAMKI + i]) }

    /// el to cover aux cons outside of harm op period
    let ddNB = 40515
    // NB=IF(OR(KI6=0,KZ6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddNB + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[FK + i], d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) }

    /// el from BESS discharging outside of harm op period
    let ddND = 41245
    // ND=MIN(NB6,(IF(MN6*BESS_chrg_eff>=NB6,0,IF(OR(KI6=0,KZ6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+MN3)*BESS_chrg_eff)
    for i in 0..<365 { d7[ddND + i] = min(d7[ddNB + i], (iff(d7[ddMN + i] * BESS_chrg_eff >= d7[ddNB + i], .zero, iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[GA + i], d5[GA + i] + (d6[HW + i] - d5[GA + i]) * d7[ddAMKG + i])) + d7[ddMN + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddNC = 40880
    // NC=NB6-ND6
    for i in 0..<365 { d7[ddNC + i] = d7[ddNB + i] - d7[ddND + i] }

    /// El available outside of harm op period after TES chrg
    let ddNE = 41610
    // NE=IF(OR(KI6=0,KZ6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(ND6/BESS_chrg_eff-MN6))
    for i in 0..<365 { d7[ddNE + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[FU + i], d5[FU + i] + (d6[HQ + i] - d5[FU + i]) * d7[ddAMKI + i]) - (d7[ddND + i] / BESS_chrg_eff - d7[ddMN + i]) }

    /// Grid import needed outside of harm op period
    let ddNF = 41975
    // NF=MIN(IF(OR(KI6=0,KZ6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+ND6),MAX(0,NB6-NC6-ND6-NE6))
    for i in 0..<365 { d7[ddNF + i] = min(iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[GG + i], d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i] + d7[ddND + i]), max(.zero, d7[ddNB + i] - d7[ddNC + i] - d7[ddND + i] - d7[ddNE + i])) }

    /// Balance of electricity outside of harm op period
    let ddNG = 42340
    // NG=NC6+ND6+NE6+NF6-NB6
    for i in 0..<365 { d7[ddNG + i] = d7[ddNC + i] + d7[ddND + i] + d7[ddNE + i] + d7[ddNF + i] - d7[ddNB + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddNH = 42705
    // // NH=IF(OR(KZ6=0,KI6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d7[ddNH + i] = iff(
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero,
    //     d5[FH + i] + (d6[HD + i] - d5[FH + i])
    //       * d7[ddAMKI + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddNI = 43070
    // // NI=IF(OR(KZ6=0,KI6=0),0,NC6*El_boiler_eff)
    // for i in 0..<365 {
    //   d7[ddNI + i] = if
    //     or(d7[ddKZ + i].isZero, d7[ddKI + i].isZero), .zero, d7[ddNC + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddNJ = 43435
    // NJ=IF(OR(KI6=0,KZ6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddNJ + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[FX + i], d5[FX + i] + (d6[HT + i] - d5[FX + i]) * d7[ddAMKI + i]) }

    /// Balance of heat outside of harm op period
    let ddNK = 43800
    // NK=NJ6
    for i in 0..<365 { d7[ddNK + i] = d7[ddNJ + i] }

    /// Grid export
    let ddNM = 44530
    // NM=MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NG6,IF(OR(KI6=0,KZ6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d7[ddNM + i] =
        max(
          .zero,
          min(
            d7[ddMT + i],
            iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[GC + i], d5[GB + i] + (d6[HX + i] - d5[GB + i]) * d7[ddAMKI + i]) + ((d5[GC + i] + (d6[HY + i] - d5[GC + i]) * d7[ddAMKI + i]) - (d5[GB + i] + (d6[HX + i] - d5[GB + i]) * d7[ddAMKI + i])) / Overall_harmonious_range * (d7[ddKZ + i] - Overall_harmonious_min_perc)))
        + max(.zero, min(d7[ddNG + i], iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d5[GD + i], d5[GD + i] + (d6[HZ + i] - d5[GD + i]) * d7[ddAMKI + i])))
    }

    /// Grid import
    let ddNN = 44895
    // NN=MR6+NF6+NC6+MS6
    for i in 0..<365 { d7[ddNN + i] = d7[ddMR + i] + d7[ddNF + i] + d7[ddNC + i] + d7[ddMS + i] }

    /// Outside harmonious operation period hours
    let ddNO = 45260
    // NO=IF(OR(KI6=0,KZ6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { 
      d7[ddNO + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d1[C + i], d1[C + i] + (d1[T + i] - d1[C + i]) * d7[dddKI + i])
    }

    /// Harmonious operation period hours
    let ddNP = 45625
    // NP=IF(OR(KI6=0,KZ6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddNP + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d1[D + i], d1[D + i] + (d1[U + i] - d1[D + i]) * d7[dddKI + i]) }

    /// Pure Methanol prod with night priority and resp day op
    let ddNL = 44165
    // NL=(MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {

      d7[ddNL + i] = max(.zero, d7[ddMK + i] - d7[ddNP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d7[ddNA + i] - d7[ddNO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud

    }

    /// PB operating hours
    let ddNQ = 45990
    // NQ=IF(OR(KI6=0,KZ6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddNQ + i] = iff(or(d7[ddKI + i].isZero, d7[ddKZ + i].isZero), d1[E + i], d1[E + i] + (d1[V + i] - d1[E + i]) * d7[dddKI + i]) }

    /// Checksum
    let ddNR = 46355
    // NR=MAX(0,-MT6)+MAX(0,-MZ6)+MAX(0,-NG6)+MAX(0,-NK6)
    for i in 0..<365 {
      let NR = max(.zero, -d7[ddMT + i]) + max(.zero, -d7[ddMZ + i]) + max(.zero, -d7[ddNG + i]) + max(.zero, -d7[ddNK + i])
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      d7[ddNR + i] = NR
    }
  }
}
