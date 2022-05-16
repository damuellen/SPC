extension TunOl {
  func d14(_ d13: inout [Double], case j: Int, d10: [Double], d11: [Double], d12: [Double]) {
    let (C, D, E, T, U, V, Z, AA, AB, AC) = (0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125)  // d1

    let (FC, FD, FE, FI, FJ, FR, FS, FT, FV, FW, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI) = (
      1460, 1825, 2190, 2555, 4015, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d11

    let (GY, GZ, HA, HE, HF, HN, HO, HP, HR, HS, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE) = (
      1460, 1825, 2190, 3650, 4015, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d12
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
    for i in 0..<365 { d13[ddLB + i] = iff(d11[FC + i].isZero, .zero, iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FD + i], (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[ddAMKG + i]) + ((d11[FD + i] + (d12[GZ + i] - d11[FD + i]) * d13[ddAMKG + i]) - (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[ddAMKG + i])) * d13[dddJP + i])) }

    /// el cons for night prep during harm op period
    let ddLC = 22265
    // LC=IF(or(JP6=0,kg6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddLC + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero, d10[Z + i] + (d10[AA + i] - d10[Z + i]) / equiv_harmonious_range * (d13[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// el to cover aux cons during harm op period
    let ddLD = 22630
    for i in 0..<365 { d13[ddLD + i] = 99 }
    // // LD=IF(OR(JP6=0,KG6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddLD + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero,
    //     d11[FO + i] + (d12[HK + i] - d11[FO + i])
    //       * d13[ddAMKG + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddLE = 22995
    // LE=IF(OR(JP6=0,KG6=0),MIN(FR6/BESS_chrg_eff,FZ6),MIN(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[ddLE + i] = iff(
        or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), min(d11[FR + i] / BESS_chrg_eff, d11[FZ + i]),
        min((d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[ddAMKG + i] + ((d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[ddAMKG + i]) - (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[ddAMKG + i])) * d13[dddJP + i]), (d11[FR + i] + (d12[HN + i] - d11[FR + i]) * d13[ddAMKG + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddLF = 23360 // reused
    // // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddLF + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero,
    //     (d11[FL + i]
    //       + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FM + i]
    //         + (d12[HI + i] - d11[FM + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FL + i]
    //           + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * d13[dddJP + i])
    // }

    // /// heat cons for harm op during harm op period
    // let ddLL = 25550 // reused
    // // LL=IF(OR(JP6=0,KG6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddLL + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero,
    //     (d11[FF + i]
    //       + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FG + i]
    //         + (d12[HC + i] - d11[FG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FF + i]
    //           + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * d13[dddJP + i])
    // }

    /// heat cons for night prep during harm op period
    let ddLM = 25915
    // LM=IF(OR(JP6=0,KG6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddLM + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero, d10[AB + i] + (d10[AC + i] - d10[AB + i]) / equiv_harmonious_range * (d13[ddKG + i] - equiv_harmonious_min_perc[j])) }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddLN = 26280 // reused
    // // LN=IF(OR(JP6=0,KG6=0),0,LF6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[ddLN + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero, d13[ddLF + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddLP = 27010
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 { d13[ddLP + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FW + i], d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKG + i] + ((d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKG + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKG + i])) * d13[dddJP + i]) }

    /// heat prod by el boiler for night prep during harm op period
    let ddLO = 26645
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 { d13[ddLO + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), 0, min((d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[ddAMKG + i]) + ((d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[ddAMKG + i]) - (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[ddAMKG + i])) * d13[dddJP + i], max(0, d13[ddLM + i] - d13[ddLP + i]))) }

    /// Balance of heat during harm op period
    let ddLQ = 27375
    // LQ=LO6+LP6-LM6
    for i in 0..<365 { d13[ddLQ + i] = d13[ddLO + i] + d13[ddLP + i] - d13[ddLM + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddLG = 23725
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { d13[ddLG + i] = d13[ddLO + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddLH = 24090
    // LH=IF(OR(JP6=0,KG6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 { d13[ddLH + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FT + i], d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKG + i] + ((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[ddAMKG + i]) - (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKG + i])) * d13[dddJP + i]) }

    /// Grid import for harm op during harm op period
    let ddLI = 24455
    // LI=IF(OR(JP6=0,KG6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[ddLI + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FJ + i], (d11[FI + i] + (d12[HE + i] - d11[FI + i]) * d13[ddAMKG + i]) + ((d11[FJ + i] + (d12[HF + i] - d11[FJ + i]) * d13[ddAMKG + i]) - (d11[FI + i] + (d12[HE + i] - d11[FI + i]) * d13[ddAMKG + i])) * d13[dddJP + i])

    }

    /// Grid import for night prep during harm op period
    let ddLJ = 24820
    // LJ=MIN(IF(OR(JP6=0,KG6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      d13[ddLJ + i] = min(
        iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[GF + i], (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKG + i]) + ((d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[ddAMKG + i]) - (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKG + i])) * d13[dddJP + i]),
        max(.zero, d13[ddLC + i] - d13[ddLE + i] - d13[ddLG + i] - d13[ddLH + i]))
    }

    /// Balance of electricity during harm op period
    let ddLK = 25185
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { d13[ddLK + i] = d13[ddLH + i] + d13[ddLJ + i] - d13[ddLC + i] - d13[ddLE + i] - d13[ddLG + i] }

    /// el cons for harm op outside of harm op period
    let ddLR = 27740
    // LR=IF(OR(FE6=0,JP6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddLR + i] = iff(or(d11[FE + i].isZero, d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero, d11[FE + i] + (d12[HA + i] - d11[FE + i]) * d13[ddAMKG + i]) }

    /// el to cover aux cons outside of harm op period
    let ddLS = 28105
    // LS=IF(OR(JP6=0,KG6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddLS + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FK + i], d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKG + i]) }

    /// el from BESS discharging outside of harm op period
    let ddLU = 28835
    // LU=MIN(LS6,(IF(LE6*BESS_chrg_eff>=LS6,0,IF(OR(JP6=0,KG6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+LE6)*BESS_chrg_eff)
    for i in 0..<365 { d13[ddLU + i] = min(d13[ddLS + i], (iff(d13[ddLE + i] * BESS_chrg_eff >= d13[ddLS + i], .zero, iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[GA + i], d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[ddAMKG + i])) + d13[ddLE + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddLT = 28470
    // LT=LS6-LU6
    for i in 0..<365 { d13[ddLT + i] = d13[ddLS + i] - d13[ddLU + i] }
    let HQ = 8030
    let FU = 8030
    /// El available outside of harm op period after TES chrg
    let ddLV = 29200
    // LV=max(0,IF(OR(JP6=0,KG6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(LU6/BESS_chrg_eff-LE6))
    for i in 0..<365 { d13[ddLV + i] = max(.zero, iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FU + i], d11[FU + i] + (d12[HQ + i] - d11[FU + i]) * d13[ddAMKG + i]) - (d13[ddLU + i] / BESS_chrg_eff - d13[ddLE + i])) }

    /// Grid import needed outside of harm op period
    let ddLW = 29565
    // LW=MIN(IF(OR(JP6=0,KG6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+LU6),MAX(0,LS6-LT6-LU6-LV6))
    for i in 0..<365 { d13[ddLW + i] = min(iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[GG + i], d12[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKG + i] + d13[ddLU + i]), max(.zero, d13[ddLS + i] - d13[ddLT + i] - d13[ddLU + i] - d13[ddLV + i])) }

    /// Balance of electricity outside of harm op period
    let ddLX = 29930
    // LX=LT6+LU6+LV6+LW6-LS6
    for i in 0..<365 { d13[ddLX + i] = d13[ddLT + i] + d13[ddLU + i] + d13[ddLV + i] + d13[ddLW + i] - d13[ddLS + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddLY = 30295
    // // LY=IF(OR(JP6=0,KG6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddLY + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero,
    //     d11[FH + i] + (d12[HD + i] - d11[FH + i])
    //       * d13[ddAMKG + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddLZ = 30660
    // // LZ=IF(OR(JP6=0,KG6=0),0,LT6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[ddLZ + i] = iff(
    //     or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), .zero, d13[ddLT + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddMA = 31025
    // MA=IF(OR(JP6=0,KG6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddMA + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[FX + i], d11[FX + i] + (d12[HT + i] - d11[FX + i]) * d13[ddAMKG + i]) }

    /// Balance of heat outside of harm op period
    let ddMB = 31390
    // MB=MA6
    for i in 0..<365 { d13[ddMB + i] = d13[ddMA + i] }

    /// grid export
    let ddMD = 32120
    // MD=MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LX6,IF(OR(JP6=0,KG6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[ddMD + i] =
        min(d13[ddLK + i], iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[GC + i], d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[ddAMKG + i] + ((d11[GC + i] + (d12[HY + i] - d11[GC + i]) * d13[ddAMKG + i]) - (d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[ddAMKG + i])) * d13[dddJP + i]))
        + max(.zero, min(d13[ddLX + i], iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d11[GD + i], d11[GD + i] + (d12[HZ + i] - d11[GD + i]) * d13[ddAMKG + i])))
    }

    /// Grid import
    let ddME = 32485
    // ME=LI6+LW6+LT6+LJ6
    for i in 0..<365 { d13[ddME + i] = d13[ddLI + i] + d13[ddLW + i] + d13[ddLT + i] + d13[ddLJ + i] }

    /// Outside harmonious operation period hours
    let ddMF = 32850
    // MF=IF(OR(JP6=0,KG6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d13[ddMF + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d10[C + i], d10[C + i] + (d10[T + i] - d10[C + i]) / equiv_harmonious_range * (d13[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Harmonious operation period hours
    let ddMG = 33215
    // MG=IF(OR(JP6=0,KG6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d13[ddMG + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d10[D + i], d10[D + i] + (d10[U + i] - d10[D + i]) / equiv_harmonious_range * (d13[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// PB operating hours
    let ddMH = 33580
    // MH=IF(OR(JP6=0,KG6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { d13[ddMH + i] = iff(or(d13[ddJP + i].isZero, d13[ddKG + i].isZero), d10[E + i], d10[E + i] + (d10[V + i] - d10[E + i]) / equiv_harmonious_range * (d13[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Pure Methanol prod with day priority and resp night op
    let ddMC = 31755
    // MC=(MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d13[ddMC + i] = max(.zero, d13[ddLB + i] - d13[ddMG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d13[ddLR + i] - d13[ddMF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud
    }

    /// Checksum
    let ddMI = 33945
    // MI=MAX(0,-LK6)+MAX(0,-LQ6)+MAX(0,-LX6)+MAX(0,-MB6)
    for i in 0..<365 {
      let MB = max(.zero, -d13[ddLK + i]) + max(.zero, -d13[ddLQ + i]) + max(.zero, -d13[ddLX + i]) + max(.zero, -d13[ddMB + i])
      // if MB > 1E-13 { print("Checksum error daily 1", i, j, MB); break }
      d13[ddMI + i] = MB
    }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// el cons for harm op during harm op period
    let ddMK = 34310
    // MK=IF(FC6=0;0;IF(OR(KZ6=0,KI6=0),FD6,FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d13[ddMK + i] = iff(
        d11[FC + i].isZero, .zero,
        iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[FD + i], d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[ddAMKI + i] + ((d11[FD + i] + (d12[GZ + i] - d11[FD + i]) * d13[ddAMKI + i]) - (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    let ddML = 34675
    // ML=IF(OR(KI6=0,KZ6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddML + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), .zero, d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[dddKI + i]) }

    /// el to cover aux cons during harm op period
    // let ddMM = 35040
    // for i in 0..<365 { d13[ddMM + i] = 99 }
    // // MM=IF(OR(KZ6=0,KI6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddMM + i] = iff(
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero,
    //     d11[FO + i] + (d12[HK + i] - d11[FO + i])
    //       * d13[ddAMKI + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddMN = 35405
    // MN=MIN(IF(OR(KI6=0,KZ6=0),MIN(FR6/BESS_chrg_eff,FZ6),(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[ddMN + i] = iff(
        or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), min(d11[FR + i] / BESS_chrg_eff, d11[FZ + i]),
        min(
          (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[ddAMKI + i] + ((d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[ddAMKI + i]) - (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc)),
          (d11[FR + i] + (d12[HN + i] - d11[FR + i]) * d13[ddAMKI + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddMO = 35770
    // for i in 0..<365 { d13[ddMO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddMO + i] = iff(
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero,
    //     (d11[FL + i]
    //       + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FM + i]
    //         + (d12[HI + i] - d11[FM + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FL + i]
    //           + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    // /// heat cons for harm op during harm op period
    // let ddMU = 37960
    // // MU=IF(OR(KZ6=0,KI6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddMU + i] = iff(
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero,
    //     (d11[FF + i]
    //       + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FG + i]
    //         + (d12[HC + i] - d11[FG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FF + i]
    //           + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    /// heat cons for night prep during harm op period
    let ddMV = 38325
    // MV=IF(OR(KI6=0,KZ6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddMV + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), .zero, d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[dddKI + i]) }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddMW = 38690
    // // MW=IF(OR(KZ6=0,KI6=0),0,MO6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[ddMW + i] = iff(
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero, d13[ddMO + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddMY = 39420
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[ddMY + i] = iff(
        or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), d11[FW + i], d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i] + ((d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// heat prod by el boiler for night prep during harm op period
    let ddMX = 39055
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      d13[ddMX + i] = iff(
        or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), .zero,
        min((d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[ddAMKI + i]) + ((d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[ddAMKI + i]) - (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc), max(.zero, d13[ddMV + i] - d13[ddMY + i])))
    }

    /// Balance of heat during harm op period
    let ddMZ = 39785
    // MZ=MX6+MY6-MV6
    for i in 0..<365 { d13[ddMZ + i] = d13[ddMX + i] + d13[ddMY + i] - d13[ddMV + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddMP = 36135
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { d13[ddMP + i] = d13[ddMX + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddMQ = 36500
    // MQ=IF(OR(KI6=0,KZ6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[ddMQ + i] = iff(
        or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), d11[FT + i], d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKI + i] + ((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[ddAMKI + i]) - (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for harm op during harm op period
    let ddMR = 36865
    // MR=IF(OR(KI6=0,KZ6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[ddMR + i] = iff(
        or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[FJ + i], (d11[FI + i] + (d12[HE + i] - d11[FI + i]) * d13[ddAMKI + i]) + ((d11[FJ + i] + (d12[HF + i] - d11[FJ + i]) * d13[ddAMKI + i]) - (d11[FI + i] + (d12[HE + i] - d11[FI + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let ddMS = 37230
    // MS=MIN(IF(OR(KI6=0,KZ6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      d13[ddMS + i] = min(
        iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[GF + i], (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKI + i]) + ((d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[ddAMKI + i]) - (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc)),
        max(0, d13[ddML + i] + d13[ddMN + i] + d13[ddMP + i] - d13[ddMQ + i]))
    }

    /// Balance of electricity during harm op period
    let ddMT = 37595
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { d13[ddMT + i] = d13[ddMQ + i] + d13[ddMS + i] - d13[ddML + i] - d13[ddMN + i] - d13[ddMP + i] }
    /// el cons for harm op outside of harm op period
    let ddNA = 40150
    // NA=IF(OR(KI6=0,KZ6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddNA + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), .zero, d11[FE + i] + (d12[HA + i] - d11[FE + i]) * d13[ddAMKI + i]) }

    /// el to cover aux cons outside of harm op period
    let ddNB = 40515
    // NB=IF(OR(KI6=0,KZ6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddNB + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[FK + i], d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i]) }

    /// el from BESS discharging outside of harm op period
    let ddND = 41245
    // ND=MIN(NB6,(IF(MN6*BESS_chrg_eff>=NB6,0,IF(OR(KI6=0,KZ6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+MN3)*BESS_chrg_eff)
    for i in 0..<365 { d13[ddND + i] = min(d13[ddNB + i], (iff(d13[ddMN + i] * BESS_chrg_eff >= d13[ddNB + i], .zero, iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[GA + i], d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[ddAMKG + i])) + d13[ddMN + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddNC = 40880
    // NC=NB6-ND6
    for i in 0..<365 { d13[ddNC + i] = d13[ddNB + i] - d13[ddND + i] }

    /// El available outside of harm op period after TES chrg
    let ddNE = 41610
    // NE=IF(OR(KI6=0,KZ6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(ND6/BESS_chrg_eff-MN6))
    for i in 0..<365 { d13[ddNE + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[FU + i], d11[FU + i] + (d12[HQ + i] - d11[FU + i]) * d13[ddAMKI + i]) - (d13[ddND + i] / BESS_chrg_eff - d13[ddMN + i]) }

    /// Grid import needed outside of harm op period
    let ddNF = 41975
    // NF=MIN(IF(OR(KI6=0,KZ6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+ND6),MAX(0,NB6-NC6-ND6-NE6))
    for i in 0..<365 { d13[ddNF + i] = min(iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[GG + i], d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i] + d13[ddND + i]), max(.zero, d13[ddNB + i] - d13[ddNC + i] - d13[ddND + i] - d13[ddNE + i])) }

    /// Balance of electricity outside of harm op period
    let ddNG = 42340
    // NG=NC6+ND6+NE6+NF6-NB6
    for i in 0..<365 { d13[ddNG + i] = d13[ddNC + i] + d13[ddND + i] + d13[ddNE + i] + d13[ddNF + i] - d13[ddNB + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddNH = 42705
    // // NH=IF(OR(KZ6=0,KI6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[ddNH + i] = iff(
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero,
    //     d11[FH + i] + (d12[HD + i] - d11[FH + i])
    //       * d13[ddAMKI + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddNI = 43070
    // // NI=IF(OR(KZ6=0,KI6=0),0,NC6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[ddNI + i] = if
    //     or(d13[ddKZ + i].isZero, d13[ddKI + i].isZero), .zero, d13[ddNC + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddNJ = 43435
    // NJ=IF(OR(KI6=0,KZ6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddNJ + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[FX + i], d11[FX + i] + (d12[HT + i] - d11[FX + i]) * d13[ddAMKI + i]) }

    /// Balance of heat outside of harm op period
    let ddNK = 43800
    // NK=NJ6
    for i in 0..<365 { d13[ddNK + i] = d13[ddNJ + i] }

    /// Grid export
    let ddNM = 44530
    // NM=MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NG6,IF(OR(KI6=0,KZ6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[ddNM + i] =
        max(
          .zero,
          min(
            d13[ddMT + i],
            iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[GC + i], d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[ddAMKI + i]) + ((d11[GC + i] + (d12[HY + i] - d11[GC + i]) * d13[ddAMKI + i]) - (d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[ddAMKI + i])) / Overall_harmonious_range * (d13[ddKZ + i] - Overall_harmonious_min_perc)))
        + max(.zero, min(d13[ddNG + i], iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d11[GD + i], d11[GD + i] + (d12[HZ + i] - d11[GD + i]) * d13[ddAMKI + i])))
    }

    /// Grid import
    let ddNN = 44895
    // NN=MR6+NF6+NC6+MS6
    for i in 0..<365 { d13[ddNN + i] = d13[ddMR + i] + d13[ddNF + i] + d13[ddNC + i] + d13[ddMS + i] }

    /// Outside harmonious operation period hours
    let ddNO = 45260
    // NO=IF(OR(KI6=0,KZ6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { 
      d13[ddNO + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d10[C + i], d10[C + i] + (d10[T + i] - d10[C + i]) * d13[dddKI + i])
    }

    /// Harmonious operation period hours
    let ddNP = 45625
    // NP=IF(OR(KI6=0,KZ6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddNP + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d10[D + i], d10[D + i] + (d10[U + i] - d10[D + i]) * d13[dddKI + i]) }

    /// Pure Methanol prod with night priority and resp day op
    let ddNL = 44165
    // NL=(MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {

      d13[ddNL + i] = max(.zero, d13[ddMK + i] - d13[ddNP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(.zero, d13[ddNA + i] - d13[ddNO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud

    }

    /// PB operating hours
    let ddNQ = 45990
    // NQ=IF(OR(KI6=0,KZ6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ddNQ + i] = iff(or(d13[ddKI + i].isZero, d13[ddKZ + i].isZero), d10[E + i], d10[E + i] + (d10[V + i] - d10[E + i]) * d13[dddKI + i]) }

    /// Checksum
    let ddNR = 46355
    // NR=MAX(0,-MT6)+MAX(0,-MZ6)+MAX(0,-NG6)+MAX(0,-NK6)
    for i in 0..<365 {
      let NR = max(.zero, -d13[ddMT + i]) + max(.zero, -d13[ddMZ + i]) + max(.zero, -d13[ddNG + i]) + max(.zero, -d13[ddNK + i])
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      d13[ddNR + i] = NR
    }
  }
}
