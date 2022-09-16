extension TunOl {
  func d14(_ d13: inout [Double], case j: Int, d10: [Double], d11: [Double], d12: [Double]) {
    let (C, D, E, T, U, V, Z, AA, AB, AC) = (0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125)  // d10

    let (EY, EZ, FA, FC, FD, FE, FS, FT, FV, FW, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI) = (
      0, 365, 730, 1460, 1825, 2190, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d11

    let (GU, GV, GW, GY, GZ, HA, HO, HP, HR, HS, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE) = (
      0, 365, 730, 1460, 1825, 2190, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140
    )  // d12
    let FX: Int = 9125  //d11
    let HT: Int = 9125  //d12
    let FK: Int = 4380
    let HG: Int = 4380
    let JP: Int = 8760
    let dJP: Int = 26280
    let KG: Int = 14965
    let KI: Int = 15330
    let AMKG: Int = 23360  // let LF: Int = 23360

    let AMKI: Int = 38690  // let MW: Int = 38690
    let KZ: Int = 21535

    /// el cons for harm op during harm op period
    let LB: Int = 21900
    // LB=IF(FC6=0,0,IF(OR(JP6=0,KG6=0),MAX(0,FD6-MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-FZ6-GA6)),FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d13[LB + i] = iff(
        d11[FC + i].isZero, 0.0,
        iff(
          or(d13[JP + i].isZero, d13[KG + i].isZero), max(0, d11[FD + i] - max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[FZ + i] - d11[GA + i])),
          (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[AMKG + i])
            + ((d11[FD + i] + (d12[GZ + i] - d11[FD + i]) * d13[AMKG + i]) - (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[AMKG + i])) * d13[dJP + i]))
    }

    /// el cons for night prep during harm op period
    let LC: Int = 22265
    // LC=IF(KG6=0,0,$Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[LC + i] = iff(d13[KG + i].isZero, 0.0, d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKG + i]) }

    /// el to cover aux cons during harm op period
    let LD: Int = 22630
    for i in 0..<365 { d13[LD + i] = 99 }
    // // LD=IF(OR(JP6=0,KG6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[LD + i] = iff(
    //     or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0,
    //     d11[FO + i] + (d12[HK + i] - d11[FO + i])
    //       * d13[AMKG + i])
    // }

    /// el cons for BESS charging during harm op period
    let LE: Int = 22995
    // LE=IF(OR(JP6=0,KG6=0),MIN(MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-GA6),FZ6),MIN(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[LE + i] = iff(
        or(d13[JP + i].isZero, d13[KG + i].isZero), min(max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[GA + i]), d11[FZ + i]),
        min(
          (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[AMKG + i]
            + ((d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[AMKG + i]) - (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[AMKG + i])) * d13[dJP + i]),
          (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKG + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let LF: Int = 23360 // reused
    // // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[LF + i] = iff(
    //     or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0,
    //     (d11[FL + i]
    //       + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[KG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FM + i]
    //         + (d12[HI + i] - d11[FM + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[KG + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FL + i]
    //           + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[KG + i] - equiv_harmonious_min_perc[j])))
    //       * d13[dJP + i])
    // }

    // /// heat cons for harm op during harm op period
    // let LL: Int = 25550 // reused
    // // LL=IF(OR(JP6=0,KG6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[LL + i] = iff(
    //     or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0,
    //     (d11[FF + i]
    //       + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[KG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FG + i]
    //         + (d12[HC + i] - d11[FG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[KG + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FF + i]
    //           + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[KG + i] - equiv_harmonious_min_perc[j])))
    //       * d13[dJP + i])
    // }
    let AM: Int = 12775
    /// heat cons for night prep during harm op period
    let LM: Int = 25915
    // LM=IF(KG6=0,0,$AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d13[LM + i] = iff(
        d13[KG + i].isZero, 0.0, d10[AB + i] + (d10[AC + i] - d10[AB + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KG + i] - equiv_harmonious_min_perc[j]))
    }

    // /// heat prod by el boiler for harm op during harm op period
    // let LN: Int = 26280 // reused
    // // LN=IF(OR(JP6=0,KG6=0),0,LF6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[LN + i] = iff(
    //     or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0, d13[LF + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let LP: Int = 27010
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[LP + i] = iff(
        or(d13[JP + i].isZero, d13[KG + i].isZero), d11[FW + i],
        d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKG + i]
          + ((d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKG + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKG + i])) * d13[dJP + i])
    }

    /// heat prod by el boiler for night prep during harm op period
    let LO: Int = 26645
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 {
      d13[LO + i] = iff(
        or(d13[JP + i].isZero, d13[KG + i].isZero), 0,
        min(
          (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKG + i])
            + ((d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[AMKG + i]) - (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKG + i])) * d13[dJP + i],
          max(0, d13[LM + i] - d13[LP + i])))
    }

    /// Balance of heat during harm op period
    let LQ: Int = 27375
    // LQ=LO6+LP6-LM6
    for i in 0..<365 { d13[LQ + i] = d13[LO + i] + d13[LP + i] - d13[LM + i] }

    /// el cons for el boiler op for night prep during harm op period
    let LG: Int = 23725
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { d13[LG + i] = d13[LO + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let LH: Int = 24090
    // LH=IF(OR(JP6=0,KG6=0),MAX(0,FT6-MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-FZ6-GA6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[LH + i] = iff(
        or(d13[JP + i].isZero, d13[KG + i].isZero), max(0, d11[FT + i] - max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[FZ + i] - d11[GA + i])),
        d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKG + i]
          + ((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[AMKG + i]) - (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKG + i])) * d13[dJP + i])
    }

    /// Grid import for harm op during harm op period
    let LI: Int = 24455
    // LI=IF(OR(JP6=0,KG6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[LI + i] = iff(
        or(d13[JP + i].isZero, d13[KG + i].isZero), d11[EZ + i],
        (d11[EY + i] + (d12[GU + i] - d11[EY + i]) * d13[AMKG + i])
          + ((d11[EZ + i] + (d12[GV + i] - d11[EZ + i]) * d13[AMKG + i]) - (d11[EY + i] + (d12[GU + i] - d11[EY + i]) * d13[AMKG + i])) * d13[dJP + i])
    }

    /// Grid import for night prep during harm op period
    let LJ: Int = 24820
    // LJ=MIN(IF(OR(JP6=0,KG6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      d13[LJ + i] = min(
        iff(
          or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0,
          (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKG + i])
            + ((d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[AMKG + i]) - (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKG + i])) * d13[dJP + i]),
        max(0.0, d13[LC + i] - d13[LE + i] - d13[LG + i] - d13[LH + i]))
    }

    /// Balance of electricity during harm op period
    let LK: Int = 25185
    // LK=ROUND(LH6+LJ6-LC6-LE6-LG6,5)
    for i in 0..<365 { d13[LK + i] = round(d13[LH + i] + d13[LJ + i] - d13[LC + i] - d13[LE + i] - d13[LG + i], 5) }

    /// el cons for harm op outside of harm op period
    let LR: Int = 27740
    // LR=IF(OR(FE6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[LR + i] = iff(or(d11[FE + i].isZero, d13[KG + i].isZero), 0.0, d11[FE + i] + (d12[HA + i] - d11[FE + i]) * d13[AMKG + i]) }

    /// el to cover aux cons outside of harm op period
    let LS: Int = 28105
    // LS=IF(KG6=0,FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[LS + i] = iff(d13[KG + i].isZero, d11[FK + i], d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKG + i]) }

    /// el from BESS discharging outside of harm op period
    let LU: Int = 28835
    // LU=LE6*BESS_chrg_eff
    for i in 0..<365 { d13[LU + i] = d13[LE + i] * BESS_chrg_eff }

    /// el cons for el boiler for harm op outside of harm op period
    let LT: Int = 28470
    // LT=IF(KG6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[LT + i] = iff(d13[KG + i].isZero, d11[FA + i], d11[FA + i] + (d12[GW + i] - d11[FA + i]) * d13[AMKG + i]) }
    let HQ: Int = 8030
    let FU: Int = 8030
    /// El available outside of harm op period after TES chrg
    let LV: Int = 29200
    // LV=IF(KG6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[LV + i] = iff(d13[KG + i].isZero, d11[FU + i], d11[FU + i] + (d12[HQ + i] - d11[FU + i]) * d13[AMKG + i]) }

    /// heat cons for harm op outside of harm op period
    let LY: Int = 30295
    // LY=IF(LU6>=LS6,0,MIN((LS6-LU6)/BESS_chrg_eff,IF(KG6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[LY + i] = iff(
        d13[LU + i] >= d13[LS + i], 0,
        min((d13[LS + i] - d13[LU + i]) / BESS_chrg_eff, iff(d13[KG + i].isZero, d11[GA + i], d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[AMKG + i])))
    }

    /// Grid import needed outside of harm op period
    let LW: Int = 29565
    // LW=MIN(IF(KG6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)),MAX(0,LS6-LT6-LU6-LY6*BESS_chrg_eff))
    for i in 0..<365 {
      d13[LW + i] = min(
        iff(d13[KG + i].isZero, d11[GG + i], d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKG + i]),
        max(0.0, d13[LS + i] - d13[LT + i] - d13[LU + i] - d13[LY + i] * BESS_chrg_eff))
    }

    /// Balance of electricity outside of harm op period
    let LX: Int = 29930
    // LX=ROUND(LT6+LU6+LW6+LY6*BESS_chrg_eff-MAX(0,LY6-LV6)-LS6,5)
    for i in 0..<365 { d13[LX + i] = round(d13[LT + i] + d13[LU + i] + d13[LW + i] + d13[LY + i] * BESS_chrg_eff - max(0, d13[LY + i] - d13[LV + i]) - d13[LS + i], 5) }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let LZ: Int = 30660
    // // LZ=IF(OR(JP6=0,KG6=0),0,LT6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[LZ + i] = iff(
    //     or(d13[JP + i].isZero, d13[KG + i].isZero), 0.0, d13[LT + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let MA: Int = 31025
    // MA=IF(KG6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[MA + i] = iff(or(d13[JP + i].isZero, d13[KG + i].isZero), d11[FX + i], d11[FX + i] + (d12[HT + i] - d11[FX + i]) * d13[AMKG + i]) }

    /// Balance of heat outside of harm op period
    let MB: Int = 31390
    // MB=MA6
    for i in 0..<365 { d13[MB + i] = d13[MA + i] }

    /// grid export
    let MD: Int = 32120
    // MD=MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LV6-LY6,IF(KG6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[MD + i] =
        min(
          d13[LK + i],
          iff(
            or(d13[JP + i].isZero, d13[KG + i].isZero), d11[GC + i],
            d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[AMKG + i]
              + ((d11[GC + i] + (d12[HY + i] - d11[GC + i]) * d13[AMKG + i]) - (d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[AMKG + i])) * d13[dJP + i]))
        + max(0.0, min(d13[LV + i] - d13[LY + i], iff(d13[KG + i].isZero, d11[GD + i], d11[GD + i] + (d12[HZ + i] - d11[GD + i]) * d13[AMKG + i])))
    }

    /// Grid import
    let ME: Int = 32485
    // ME=ROUND(LI6+LW6+LT6+LJ6+(MAX(0,-LK6)+MAX(0,-LX6))*EDG_elec_cost_factor,5)
    for i in 0..<365 { d13[ME + i] = round(d13[LI + i] + d13[LW + i] + d13[LT + i] + d13[LJ + i] + (max(0, -d13[LK + i]) + max(0.0, -d13[LX + i])) * EDG_elec_cost_factor, 5) }

    /// Outside harmonious operation period hours
    let MF: Int = 32850
    // MF=IF(LR6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d13[MF + i] = iff(d13[LR + i].isZero, 0, d10[C + i] + (d10[T + i] - d10[C + i]) * d13[AMKG + i]) }

    /// Harmonious operation period hours
    let MG: Int = 33215
    // MG=IF(LB6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d13[MG + i] = iff(d13[LB + i].isZero, 0, d10[D + i] + (d10[U + i] - d10[D + i]) * d13[AMKG + i]) }

    /// PB operating hours
    let MH: Int = 33580
    // MH=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { d13[MH + i] = d10[E + i] + (d10[V + i] - d10[E + i]) * d13[AMKG + i] }

    /// Pure Methanol prod with day priority and resp night op
    let MC: Int = 31755
    // MC=MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(LR6=0,0,IF(A_overall_var_max_cons=0,MF6*KG6,MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d13[MC + i] =
        max(0.0, d13[LB + i] - d13[MG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          d13[LR + i].isZero, 0.0,
          iff(
            overall_var_max_cons[j].isZero, d13[MF + i] * d13[KG + i],
            max(0.0, d13[LR + i] - d13[MF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// Checksum
    let MI: Int = 33945
    // MI=MAX(0,-LK6)+MAX(0,-LQ6)+MAX(0,-LX6)+MAX(0,-MB6)
    for i in 0..<365 { d13[MI + i] = max(0.0, -d13[LK + i]) + max(0.0, -d13[LQ + i]) + max(0.0, -d13[LX + i]) + max(0.0, -d13[MB + i]) }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// el cons for harm op during harm op period
    let MK: Int = 34310
    // MK=IF(FC6=0,0,IF(OR(KI6=0,KZ6=0),MAX(0,FD6-MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-FZ6-GA6)),FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d13[MK + i] = iff(
        d11[FC + i].isZero, 0.0,
        iff(
          or(d13[KI + i].isZero, d13[KZ + i].isZero), max(0, d11[FD + i] - max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[FZ + i] - d11[GA + i])),
          d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[AMKI + i]
            + ((d11[FD + i] + (d12[GZ + i] - d11[FD + i]) * d13[AMKI + i]) - (d11[FC + i] + (d12[GY + i] - d11[FC + i]) * d13[AMKI + i])) / Overall_harmonious_range
            * (d13[KZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    let ML: Int = 34675
    // ML=IF(KI6=0,0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[ML + i] = iff(d13[KI + i].isZero, 0.0, d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i]) }

    /// el to cover aux cons during harm op period
    // let MM: Int = 35040
    // for i in 0..<365 { d13[MM + i] = 99 }
    // // MM=IF(OR(KZ6=0,KI6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[MM + i] = iff(
    //     or(d13[KZ + i].isZero, d13[KI + i].isZero), 0.0,
    //     d11[FO + i] + (d12[HK + i] - d11[FO + i])
    //       * d13[AMKI + i])
    // }

    /// el cons for BESS charging during harm op period
    let MN: Int = 35405
    // MN=IF(OR(KI6=0,KZ6=0),MIN(MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-GA6),FZ6),MIN(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[MN + i] = iff(
        or(d13[KI + i].isZero, d13[KZ + i].isZero), min(max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[GA + i]), d11[FZ + i]),
        min(
          (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[AMKI + i]
            + ((d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[AMKI + i]) - (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[AMKI + i])) / Overall_harmonious_range
              * (d13[KZ + i] - Overall_harmonious_min_perc)),
          (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let MO: Int = 35770
    // for i in 0..<365 { d13[MO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[MO + i] = iff(
    //     or(d13[KZ + i].isZero, d13[KI + i].isZero), 0.0,
    //     (d11[FL + i]
    //       + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[KI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FM + i]
    //         + (d12[HI + i] - d11[FM + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[KI + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FL + i]
    //           + (d12[HH + i] - d11[FL + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[KI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d13[KZ + i] - Overall_harmonious_min_perc))
    // }

    // /// heat cons for harm op during harm op period
    // let MU: Int = 37960
    // // MU=IF(OR(KZ6=0,KI6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d13[MU + i] = iff(
    //     or(d13[KZ + i].isZero, d13[KI + i].isZero), 0.0,
    //     (d11[FF + i]
    //       + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d13[KI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d11[FG + i]
    //         + (d12[HC + i] - d11[FG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d13[KI + i] - equiv_harmonious_min_perc[j]))
    //         - (d11[FF + i]
    //           + (d12[HB + i] - d11[FF + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d13[KI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d13[KZ + i] - Overall_harmonious_min_perc))
    // }

    /// heat cons for night prep during harm op period
    let MV: Int = 38325
    // MV=IF(KI6=0,0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[MV + i] = iff(d13[KI + i].isZero, 0.0, d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) }

    // /// heat prod by el boiler for harm op during harm op period
    // let MW: Int = 38690
    // // MW=IF(OR(KZ6=0,KI6=0),0,MO6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[MW + i] = iff(
    //     or(d13[KZ + i].isZero, d13[KI + i].isZero), 0.0, d13[MO + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let MY: Int = 39420
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[MY + i] = iff(
        or(d13[KZ + i].isZero, d13[KI + i].isZero), d11[FW + i],
        d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i]
          + ((d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i])) / Overall_harmonious_range
          * (d13[KZ + i] - Overall_harmonious_min_perc))
    }

    /// heat prod by el boiler for night prep during harm op period
    let MX: Int = 39055
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      d13[MX + i] = iff(
        or(d13[KI + i].isZero, d13[KZ + i].isZero), 0.0,
        min(
          (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i])
            + ((d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[AMKI + i]) - (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i])) / Overall_harmonious_range
              * (d13[KZ + i] - Overall_harmonious_min_perc),
          max(0.0, d13[MV + i] - d13[MY + i])))
    }

    /// Balance of heat during harm op period
    let MZ: Int = 39785
    // MZ=MX6+MY6-MV6
    for i in 0..<365 { d13[MZ + i] = d13[MX + i] + d13[MY + i] - d13[MV + i] }

    /// el cons for el boiler op for night prep during harm op period
    let MP: Int = 36135
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { d13[MP + i] = d13[MX + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let MQ: Int = 36500
    // MQ=IF(OR(KI6=0,KZ6=0),MAX(0,FT6-MAX(0,MIN(BESS_cap_ud,FK6)/BESS_chrg_eff-FZ6-GA6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[MQ + i] = iff(
        or(d13[KZ + i].isZero, d13[KI + i].isZero), max(0, d11[FT + i] - max(0, min(BESS_cap_ud, d11[FK + i]) / BESS_chrg_eff - d11[FZ + i] - d11[GA + i])),
        d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKI + i]
          + ((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[AMKI + i]) - (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKI + i])) / Overall_harmonious_range
          * (d13[KZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for harm op during harm op period
    let MR: Int = 36865
    // MR=IF(OR(KI6=0,KZ6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d13[MR + i] = iff(
        or(d13[KI + i].isZero, d13[KZ + i].isZero), d11[EZ + i],
        (d11[EY + i] + (d12[GU + i] - d11[EY + i]) * d13[AMKI + i])
          + ((d11[EZ + i] + (d12[GV + i] - d11[EZ + i]) * d13[AMKI + i]) - (d11[EY + i] + (d12[GU + i] - d11[EY + i]) * d13[AMKI + i])) / Overall_harmonious_range
          * (d13[KZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let MS: Int = 37230
    // MS=MIN(IF(OR(KI6=0,KZ6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      d13[MS + i] = min(
        iff(
          or(d13[KI + i].isZero, d13[KZ + i].isZero), 0.0,
          (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKI + i])
            + ((d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[AMKI + i]) - (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKI + i])) / Overall_harmonious_range
            * (d13[KZ + i] - Overall_harmonious_min_perc)), max(0, d13[ML + i] + d13[MN + i] + d13[MP + i] - d13[MQ + i]))
    }

    /// Balance of electricity during harm op period
    let MT: Int = 37595
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { d13[MT + i] = d13[MQ + i] + d13[MS + i] - d13[ML + i] - d13[MN + i] - d13[MP + i] }
    /// el cons for harm op outside of harm op period
    let NA: Int = 40150
    // NA=IF(OR(FE6=0,KI6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[NA + i] = iff(or(d11[FE + i].isZero, d13[KI + i].isZero), 0.0, d11[FE + i] + (d12[HA + i] - d11[FE + i]) * d13[AMKI + i]) }

    /// el to cover aux cons outside of harm op period
    let NB: Int = 40515
    // NB=IF(KI6=0,FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[NB + i] = iff(d13[KI + i].isZero, d11[FK + i], d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) }

    /// el from BESS discharging outside of harm op period
    let ND: Int = 41245
    // ND=MN6*BESS_chrg_eff
    for i in 0..<365 { d13[ND + i] = d13[MN + i] * BESS_chrg_eff }

    /// el cons for el boiler for harm op outside of harm op period
    let NC: Int = 40880
    // NC=IF(KI6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[NC + i] = iff(d13[KI + i].isZero, d11[FA + i], d11[FA + i] + (d12[GW + i] - d11[FA + i]) * d13[AMKI + i]) }

    /// El available outside of harm op period after TES chrg
    let NE: Int = 41610
    // NE=IF(KI6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[NE + i] = iff(d13[KI + i].isZero, d11[FU + i], d11[FU + i] + (d12[HQ + i] - d11[FU + i]) * d13[AMKI + i]) }

    // /// heat cons for harm op outside of harm op period
    let NH: Int = 42705
    // NH=IF(ND6>=NB6,0,MIN((NB6-ND6)/BESS_chrg_eff,IF(KI6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[NH + i] = iff(
        d13[ND + i] >= d13[NB + i], 0,
        min((d13[NB + i] - d13[ND + i]) / BESS_chrg_eff, iff(d13[KI + i].isZero, d11[GA + i], d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[AMKI + i])))
    }

    /// Grid import needed outside of harm op period
    let NF: Int = 41975
    // NF=MIN(IF(KI6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,NB6-NC6-ND6-NH6*BESS_chrg_eff))
    for i in 0..<365 {
      d13[NF + i] = min(
        iff(d13[KI + i].isZero, d11[GG + i], d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i]),
        max(0.0, d13[NB + i] - d13[NC + i] - d13[ND + i] - d13[NH + i] * BESS_chrg_eff))
    }

    /// Balance of electricity outside of harm op period
    let NG: Int = 42340
    // NG=NC6+ND6+NF6+NH6*BESS_chrg_eff-MAX(0,NH6-NE6)-NB6
    for i in 0..<365 { d13[NG + i] = d13[NC + i] + d13[ND + i] + d13[NF + i] + d13[NH + i] * BESS_chrg_eff - max(0, d13[NH + i] - d13[NE + i]) - d13[NB + i] }
    // /// Heat prod by el boiler for harm op outside of harm op period
    // let NI: Int = 43070
    // // NI=IF(OR(KZ6=0,KI6=0),0,NC6*El_boiler_eff)
    // for i in 0..<365 {
    //   d13[NI + i] = if
    //     or(d13[KZ + i].isZero, d13[KI + i].isZero), 0.0, d13[NC + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let NJ: Int = 43435
    // NJ=IF(KI6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d13[NJ + i] = iff(d13[KI + i].isZero, d11[FX + i], d11[FX + i] + (d12[HT + i] - d11[FX + i]) * d13[AMKI + i]) }

    /// Balance of heat outside of harm op period
    let NK: Int = 43800
    // NK=NJ6
    for i in 0..<365 { d13[NK + i] = d13[NJ + i] }

    /// Grid export
    let NM: Int = 44530
    // NM=MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NE6-NH6,IF(KI6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      d13[NM + i] =
        max(
          0.0,
          min(
            d13[MT + i],
            iff(or(d13[KI + i].isZero, d13[KZ + i].isZero), d11[GC + i], d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[AMKI + i])
              + ((d11[GC + i] + (d12[HY + i] - d11[GC + i]) * d13[AMKI + i]) - (d11[GB + i] + (d12[HX + i] - d11[GB + i]) * d13[AMKI + i])) / Overall_harmonious_range
              * (d13[KZ + i] - Overall_harmonious_min_perc)))
        + max(0.0, min(d13[NE + i] + d13[NH + i], iff(d13[KI + i].isZero, d11[GD + i], d11[GD + i] + (d12[HZ + i] - d11[GD + i]) * d13[AMKI + i])))
    }

    /// Grid import
    let NN: Int = 44895
    // NN=ROUND(MR6+NF6+NC6+MS6+(MAX(0,-MT6)+MAX(0,-NG6))*EDG_elec_cost_factor,5)
    for i in 0..<365 { d13[NN + i] = round(d13[MR + i] + d13[NF + i] + d13[NC + i] + d13[MS + i] + (max(0.0, -13[MT + i]) + max(0.0, -d13[NG + i])) * EDG_elec_cost_factor, 5) }

    /// Outside harmonious operation period hours
    let NO: Int = 45260
    // NO=IF(NA6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d13[NO + i] = iff(d13[NA + i].isZero, 0, d10[C + i] + (d10[T + i] - d10[C + i]) * d13[AMKI + i]) }

    /// Harmonious operation period hours
    let NP: Int = 45625
    // NP=IF(MK6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d13[NP + i] = iff(d13[MK + i].isZero, 0, d10[D + i] + (d10[U + i] - d10[D + i]) * d13[AMKI + i]) }

    /// Pure Methanol prod with night priority and resp day op
    let NL: Int = 44165
    // NL=MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(NA6=0,0,IF(A_overall_var_max_cons=0,NO6*KI6,MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d13[NL + i] =
        max(0.0, d13[MK + i] - d13[NP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          d13[NA + i].isZero, 0.0,
          iff(
            overall_var_max_cons[j].isZero, d13[NO + i] * d13[KI + i],
            max(0.0, d13[NA + i] - d13[NO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// PB operating hours
    let NQ: Int = 45990
    // NQ=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { d13[NQ + i] = d10[E + i] + (d10[V + i] - d10[E + i]) * d13[AMKI + i] }

    /// Checksum
    let NR: Int = 46355
    // NR=MAX(0,-MT6)+MAX(0,-MZ6)+MAX(0,-NG6)+MAX(0,-NK6)
    for i in 0..<365 {
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      d13[NR + i] = max(0.0, -d13[MT + i]) + max(0.0, -d13[MZ + i]) + max(0.0, -d13[NG + i]) + max(0.0, -d13[NK + i])
    }
  }
}
