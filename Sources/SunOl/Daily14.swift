extension TunOl {
  func d14(_ h: inout [Double], case j: Int) {
    // d10
    let (C, D, E, T, U, V, Z, AA, AB, AC, AM) = (
      0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125, 12775
    )
    let (
      EY, EZ, FA, _, FC, FD, FE, _, _, _, _, _, FK, FL, FM, FN, _, _, _, _, FS, FT,
      FU, FV, FW, FX, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI, _, _, _, _, _, _,
      _, _, _, _, GU, GV, GW, _, GY, GZ, HA, _, _, _, _, _, HG, HH, HI, HJ, _, _,
      _, _, HO, HP, HQ, HR, HS, HT, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE, _,
      _, _, _, _, _, _, _, _, _
    ) = (
      13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790,
      17155, 17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805,
      21170, 21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820,
      25185, 25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835,
      29200, 29565, 29930, 30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215,
      33580, 33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230,
      37595, 37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245,
      41610, 41975, 42340, 42705, 43070, 43435, 43800, 44165, 44530, 44895, 45260,
      45625, 45990, 46355, 46720, 47085, 47450
    )

    let (JP, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, KG, _, KI) = (
      57305, 57670, 58035, 58400, 58765, 59130, 59495, 59860, 60225, 60590, 60955,
      61320, 61685, 62050, 62415, 62780, 63145, 63510, 63875, 64240
    )
    let (AMKG, AMKI) = (64240+365, 64240+730)
    // LA
    let dJP: Int = 64240+1095

    let (
      KZ, LB, LC, LD, LE, _, LG, LH, LI, LJ, LK, _, LM, LN, LO, LP, LQ, LR, LS, LT,
      LU, LV, LW, LX, LY, LZ, MA, MB, MC, MD, ME, MF, MG, MH, MI, _, MK, ML, _, MN,
      _, MP, MQ, MR, MS, MT, _, MV, MW, MX, MY, MZ, NA, NB, NC, ND, NE, NF, NG, NH,
      NI, NJ, NK, NL, NM, NN, NO, NP, NQ
    ) = (
      70445, 71175, 71540, 71905, 72270, 72635, 73000, 73365, 73730, 74095, 74460,
      74825, 75190, 75555, 75920, 76285, 76650, 77015, 77380, 77745, 78110, 78475,
      78840, 79205, 79570, 79935, 80300, 80665, 81030, 81395, 81760, 82125, 82490,
      82855, 83220, 83585, 83950, 84315, 84680, 85045, 85410, 85775, 86140, 86505,
      86870, 87235, 87600, 87965, 88330, 88695, 89060, 89425, 89790, 90155, 90520,
      90885, 91250, 91615, 91980, 92345, 92710, 93075, 93440, 93805, 94170, 94535,
      94900, 95265, 95630
    )

    /// el cons for harm op during harm op period
    // LB=IF(FC3=0,0,IF(OR(JP3=0,KG3=0),MAX(0,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,FK3/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)+((FD3+(GZ3-FD3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[LB + i] = iff(
        h[FC + i] == Double.zero, 0,
        iff(
          or(h[JP + i] == Double.zero, h[KG + i] == Double.zero),
          max(0, h[FD + i] - min(BESS_cap_ud / BESS_chrg_eff, max(0, h[FK + i] / BESS_chrg_eff - h[FZ + i] - h[GA + i]))),
          h[FC + i] + (h[GY + i] - h[FC + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])
            + ((h[FD + i] + (h[GZ + i] - h[FD + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
              - (h[FC + i] + (h[GY + i] - h[FC + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])))
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    // LC=IF(KG6=0,0,$Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LC + i] = iff(h[KG + i].isZero, Double.zero, h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKG + i]) }
    /// el to cover aux cons during harm op period
    for i in 0..<365 { h[LD + i] = 99 }
    // // LD=IF(OR(JP6=0,KG6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[LD + i] = iff(
    //     or(h[JP + i].isZero, h[KG + i].isZero), Double.zero,
    //     h[FO + i] + (h[HK + i] - h[FO + i])
    //       * h[AMKG + i])
    // }
    /// el cons for BESS charging during harm op period
    // LE=IF(OR(JP3=0,KG3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,FK3/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-LB3)),MIN(((FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))+((FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)),(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      h[LE + i] = iff(
        or(h[JP + i] == Double.zero, h[KG + i] == Double.zero),
        min(BESS_cap_ud / BESS_chrg_eff, max(0, h[FK + i] / BESS_chrg_eff - h[GA + i]), h[FZ + i] + max(0, h[FD + i] - h[LB + i])),
        min(
          ((h[FY + i] + (h[HU + i] - h[FY + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
            + ((h[FZ + i] + (h[HV + i] - h[FZ + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
              - (h[FY + i] + (h[HU + i] - h[FY + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)),
          (h[FK + i] + (h[HG + i] - h[FK + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff)
      )
    }

    /// el cons for el boiler op for harm op during harm op period
    // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[LF + i] = iff(
    //     or(h[JP + i].isZero, h[KG + i].isZero), Double.zero,
    //     (h[FL + i]
    //       + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //         * (h[KG + i] - equiv_harmonious_min_perc[j]))
    //       + ((h[FM + i]
    //         + (h[HI + i] - h[FM + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //           * (h[KG + i] - equiv_harmonious_min_perc[j]))
    //         - (h[FL + i]
    //           + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //             * (h[KG + i] - equiv_harmonious_min_perc[j])))
    //       * h[dJP + i])
    // }
    // /// heat cons for harm op during harm op period
    //     // // LL=IF(OR(JP6=0,KG6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[LL + i] = iff(
    //     or(h[JP + i].isZero, h[KG + i].isZero), Double.zero,
    //     (h[FF + i]
    //       + (h[HB + i] - h[FF + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //         * (h[KG + i] - equiv_harmonious_min_perc[j]))
    //       + ((h[FG + i]
    //         + (h[HC + i] - h[FG + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //           * (h[KG + i] - equiv_harmonious_min_perc[j]))
    //         - (h[FF + i]
    //           + (h[HB + i] - h[FF + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //             * (h[KG + i] - equiv_harmonious_min_perc[j])))
    //       * h[dJP + i])
    // }
    /// heat cons for night prep during harm op period
    // LM=IF(KG6=0,0,$AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LM + i] = iff(h[KG + i].isZero, Double.zero, h[AB + i] + (h[AC + i] - h[AB + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])) }
    // /// heat prod by el boiler for harm op during harm op period
    // LN=IF(OR(JP3=0,KG3=0),FM3,(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))+((FM3+(HI3-FM3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[LN + i] = iff(
        or(h[JP + i] == Double.zero, h[KG + i] == Double.zero), h[FM + i],
        (h[FL + i] + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
          + ((h[FM + i] + (h[HI + i] - h[FM + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
            - (h[FL + i] + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc))
    }

    /// Heat available during harm op period after TES chrg
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[LP + i] = iff(
        or(h[JP + i].isZero, h[KG + i].isZero), h[FW + i],
        h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKG + i] + ((h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKG + i]) - (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKG + i])) * h[dJP + i])
    }
    /// heat prod by el boiler for night prep during harm op period
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 {
      h[LO + i] = iff(
        or(h[JP + i].isZero, h[KG + i].isZero), Double.zero,
        min(
          (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKG + i]) + ((h[GI + i] + (h[IE + i] - h[GI + i]) * h[AMKG + i]) - (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKG + i])) * h[dJP + i],
          max(Double.zero, h[LM + i] - h[LP + i])))
    }
    /// Balance of heat during harm op period
    // LQ=IF(LN3=0,LO3+LP3-LM3,-LN3)
    for i in 0..<365 { h[LQ + i] = iff(h[LN + i] == Double.zero, h[LO + i] + h[LP + i] - h[LM + i], -h[LN + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { h[LG + i] = h[LO + i] / El_boiler_eff }
    /// El available during harm op period after TES chrg
    // LH=IF(OR(JP6=0,KG6=0),MAX(0,FT6+MAX(0,FD6-LB6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[LH + i] = iff(
        or(h[JP + i].isZero, h[KG + i].isZero), max(Double.zero, h[FT + i] + max(Double.zero, h[FD + i] - h[LB + i])),
        h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKG + i] + ((h[FT + i] + (h[HP + i] - h[FT + i]) * h[AMKG + i]) - (h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKG + i])) * h[dJP + i])
    }
    /// Grid import for harm op during harm op period
    // LI=IF(OR(JP6=0,KG6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[LI + i] = iff(
        or(h[JP + i].isZero, h[KG + i].isZero), h[EZ + i],
        (h[EY + i] + (h[GU + i] - h[EY + i]) * h[AMKG + i]) + ((h[EZ + i] + (h[GV + i] - h[EZ + i]) * h[AMKG + i]) - (h[EY + i] + (h[GU + i] - h[EY + i]) * h[AMKG + i])) * h[dJP + i])
    }
    /// Grid import for night prep during harm op period
    // LJ=MIN(IF(OR(JP6=0,KG6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      h[LJ + i] = min(
        iff(
          or(h[JP + i].isZero, h[KG + i].isZero), Double.zero,
          (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKG + i]) + ((h[GF + i] + (h[IB + i] - h[GF + i]) * h[AMKG + i]) - (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKG + i])) * h[dJP + i]),
        max(Double.zero, h[LC + i] - h[LE + i] - h[LG + i] - h[LH + i]))
    }
    /// Balance of electricity during harm op period
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { h[LK + i] = h[LH + i] + h[LJ + i] - h[LC + i] - h[LE + i] - h[LG + i] }
    /// el cons for harm op outside of harm op period
    // LR=IF(OR(FE6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LR + i] = iff(or(h[FE + i].isZero, h[KG + i].isZero), Double.zero, h[FE + i] + (h[HA + i] - h[FE + i]) * h[AMKG + i]) }
    /// el to cover aux cons outside of harm op period
    // LS=IF(KG6=0,FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LS + i] = iff(h[KG + i].isZero, h[FK + i], h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKG + i]) }
    /// el from BESS discharging outside of harm op period
    // LU=LE6*BESS_chrg_eff
    for i in 0..<365 { h[LU + i] = h[LE + i] * BESS_chrg_eff }
    /// el cons for el boiler for harm op outside of harm op period
    // LT=IF(KG6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LT + i] = iff(h[KG + i].isZero, h[FA + i], h[FA + i] + (h[GW + i] - h[FA + i]) * h[AMKG + i]) }
    /// El available outside of harm op period after TES chrg
    // LV=IF(KG6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[LV + i] = iff(h[KG + i].isZero, h[FU + i], h[FU + i] + (h[HQ + i] - h[FU + i]) * h[AMKG + i]) }
    /// heat cons for harm op outside of harm op period
    // LY=IF(LU6>=LS6,0,MIN((LS6-LU6)/BESS_chrg_eff,IF(KG6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 { h[LY + i] = iff(h[LU + i] >= h[LS + i], Double.zero, min((h[LS + i] - h[LU + i]) / BESS_chrg_eff, iff(h[KG + i].isZero, h[GA + i], h[GA + i] + (h[HW + i] - h[GA + i]) * h[AMKG + i]))) }
    /// Grid import needed outside of harm op period
    // LW=MIN(IF(KG6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)),MAX(0,LS6-LT6-LU6-LY6*BESS_chrg_eff))
    for i in 0..<365 { h[LW + i] = min(iff(h[KG + i].isZero, h[GG + i], h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKG + i]), max(Double.zero, h[LS + i] - h[LT + i] - h[LU + i] - h[LY + i] * BESS_chrg_eff)) }
    /// Balance of electricity outside of harm op period
    // LX=LT6+LU6+LW6+LY6*BESS_chrg_eff-MAX(0,LY6-LV6)-LS6
    for i in 0..<365 { h[LX + i] = h[LT + i] + h[LU + i] + h[LW + i] + h[LY + i] * BESS_chrg_eff - max(Double.zero, h[LY + i] - h[LV + i]) - h[LS + i] }
    /// Heat prod by el boiler for harm op outside of harm op period
    // LZ=IF(KG3=0,FN3,FN3+(HJ3-FN3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[LZ + i] = iff(
        h[KG + i] == Double.zero, h[FN + i],
        h[FN + i] + (h[HJ + i] - h[FN + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat available outside of harm op period after TES chrg
    // MA=IF(KG6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[MA + i] = iff(or(h[JP + i].isZero, h[KG + i].isZero), h[FX + i], h[FX + i] + (h[HT + i] - h[FX + i]) * h[AMKG + i]) }
    /// Balance of heat outside of harm op period
    // MB=IF(LZ3=0,MA3,-LZ3)
    for i in 0..<365 { h[MB + i] = iff(h[LZ + i] == Double.zero,h[MA + i],-h[LZ + i]) }
    /// grid export
    // MD=ROUND(MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LV6-LY6,IF(KG6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))),0)
    for i in 0..<365 {
      h[MD + i] =
        max(Double.zero, min(
          h[LK + i],
          iff(
            or(h[JP + i].isZero, h[KG + i].isZero), h[GC + i],
            h[GB + i] + (h[HX + i] - h[GB + i]) * h[AMKG + i] + ((h[GC + i] + (h[HY + i] - h[GC + i]) * h[AMKG + i]) - (h[GB + i] + (h[HX + i] - h[GB + i]) * h[AMKG + i])) * h[dJP + i]))
        + max(Double.zero, min(h[LV + i] - h[LY + i], iff(h[KG + i].isZero, h[GD + i], h[GD + i] + (h[HZ + i] - h[GD + i]) * h[AMKG + i])))).rounded()
    }
    /// Grid import
    // ME=ROUND(LI3+LW3+LT3+LJ3,0)+ROUND(MAX(0,-LK3)+MAX(0,-LX3)+MI3/El_boiler_eff,0)*EDG_elec_cost_factor
    for i in 0..<365 { 
      h[ME + i] = round(h[LI + i]+h[LW + i]+h[LT + i]+h[LJ + i],0)+round(max(0,-h[LK + i])+max(0,-h[LX + i])+h[MI + i]/El_boiler_eff,0)*EDG_elec_cost_factor
    }
    /// Outside harmonious operation period hours
    // MF=IF(LR6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { h[MF + i] = iff(h[LR + i].isZero, Double.zero, h[C + i] + (h[T + i] - h[C + i]) * h[AMKG + i]) }
    /// Harmonious operation period hours
    // MG=IF(LB6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { h[MG + i] = iff(h[LB + i].isZero, Double.zero, h[D + i] + (h[U + i] - h[D + i]) * h[AMKG + i]) }
    /// PB operating hours
    // MH=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { h[MH + i] = h[E + i] + (h[V + i] - h[E + i]) * h[AMKG + i] }
    /// Pure Methanol prod with day priority and resp night op
    // MC=MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(LR6=0,0,IF(A_overall_var_max_cons=0,MF6*KG6,MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      h[MC + i] =
        max(Double.zero, h[LB + i] - h[MG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          h[LR + i].isZero, Double.zero,
          iff(overall_var_max_cons[j].isZero, h[MF + i] * h[KG + i], max(Double.zero, h[LR + i] - h[MF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }
    /// Checksum
    // MI=ROUND(MAX(0,-LQ3)+MAX(0,-MB3),0)
    for i in 0..<365 { h[MI + i] = round(max(0,-h[LQ + i])+max(0,-h[MB + i]),0) }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// el cons for harm op during harm op period
    // MK=IF(FC3=0,0,IF(OR(KI3=0,KZ3=0),MAX(0,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,FK3/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)+((FD3+(GZ3-FD3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[MK + i] = iff(
        h[FC + i] == Double.zero, 0,
        iff(
          or(h[KI + i] == Double.zero, h[KZ + i] == Double.zero),
          max(0, h[FD + i] - min(BESS_cap_ud / BESS_chrg_eff, max(0, h[FK + i] / BESS_chrg_eff - h[FZ + i] - h[GA + i]))),
          h[FC + i] + (h[GY + i] - h[FC + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])
            + ((h[FD + i] + (h[GZ + i] - h[FD + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
              - (h[FC + i] + (h[GY + i] - h[FC + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])))
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[KZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    // ML=IF(KI6=0,0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[ML + i] = iff(h[KI + i].isZero, Double.zero, h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i]) }
    /// el to cover aux cons during harm op period
    //     // for i in 0..<365 { h[MM + i] = 99 }
    // // MM=IF(OR(KZ6=0,KI6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[MM + i] = iff(
    //     or(h[KZ + i].isZero, h[KI + i].isZero), Double.zero,
    //     h[FO + i] + (h[HK + i] - h[FO + i])
    //       * h[AMKI + i])
    // }
    /// el cons for BESS charging during harm op period
    // MN=IF(OR(KI3=0,KZ3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,FK3/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-MK3)),MIN(((FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))+((FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc)),(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      h[MN + i] = iff(
        or(h[KI + i] == Double.zero, h[KZ + i] == Double.zero),
        min(BESS_cap_ud / BESS_chrg_eff, max(0, h[FK + i] / BESS_chrg_eff - h[GA + i]), h[FZ + i] + max(0, h[FD + i] - h[MK + i])),
        min(
          ((h[FY + i] + (h[HU + i] - h[FY + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
            + ((h[FZ + i] + (h[HV + i] - h[FZ + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
              - (h[FY + i] + (h[HU + i] - h[FY + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[KZ + i] - Overall_harmonious_min_perc)),
          (h[FK + i] + (h[HG + i] - h[FK + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff)
      )
    }

    /// el cons for el boiler op for harm op during harm op period
    //     // for i in 0..<365 { h[MO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[MO + i] = iff(
    //     or(h[KZ + i].isZero, h[KI + i].isZero), Double.zero,
    //     (h[FL + i]
    //       + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //         * (h[KI + i] - equiv_harmonious_min_perc[j]))
    //       + ((h[FM + i]
    //         + (h[HI + i] - h[FM + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //           * (h[KI + i] - equiv_harmonious_min_perc[j]))
    //         - (h[FL + i]
    //           + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //             * (h[KI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (h[KZ + i] - Overall_harmonious_min_perc))
    // }
    // /// heat cons for harm op during harm op period
    //     // // MU=IF(OR(KZ6=0,KI6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   h[MU + i] = iff(
    //     or(h[KZ + i].isZero, h[KI + i].isZero), Double.zero,
    //     (h[FF + i]
    //       + (h[HB + i] - h[FF + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //         * (h[KI + i] - equiv_harmonious_min_perc[j]))
    //       + ((h[FG + i]
    //         + (h[HC + i] - h[FG + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //           * (h[KI + i] - equiv_harmonious_min_perc[j]))
    //         - (h[FF + i]
    //           + (h[HB + i] - h[FF + i]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    //             * (h[KI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (h[KZ + i] - Overall_harmonious_min_perc))
    // }
    /// heat cons for night prep during harm op period
    // MV=IF(KI6=0,0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[MV + i] = iff(h[KI + i].isZero, Double.zero, h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) }
    // /// heat prod by el boiler for harm op during harm op period
    // MW=IF(OR(KZ3=0,KI3=0),FM3,(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))+((FM3+(HI3-FM3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[MW + i] = iff(
        or(h[KZ + i] == Double.zero, h[KI + i] == Double.zero), h[FM + i],
        (h[FL + i] + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
          + ((h[FM + i] + (h[HI + i] - h[FM + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
            - (h[FL + i] + (h[HH + i] - h[FL + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[KZ + i] - Overall_harmonious_min_perc))
    }

    /// Heat available during harm op period after TES chrg
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[MY + i] = iff(
        or(h[KZ + i].isZero, h[KI + i].isZero), h[FW + i],
        h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i] + ((h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKI + i]) - (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i])) / Overall_harmonious_range
          * (h[KZ + i] - Overall_harmonious_min_perc))
    }
    /// heat prod by el boiler for night prep during harm op period
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      h[MX + i] = iff(
        or(h[KI + i].isZero, h[KZ + i].isZero), Double.zero,
        min(
          (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i])
            + ((h[GI + i] + (h[IE + i] - h[GI + i]) * h[AMKI + i]) - (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i])) / Overall_harmonious_range * (h[KZ + i] - Overall_harmonious_min_perc),
          max(Double.zero, h[MV + i] - h[MY + i])))
    }
    /// Balance of heat during harm op period
    // MZ=IF(MW3=0,MX3+MY3-MV3,-MW3)
    for i in 0..<365 { h[MZ + i] = iff(h[MW + i] == Double.zero, h[MX + i] + h[MY + i] - h[MV + i], -h[MW + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { h[MP + i] = h[MX + i] / El_boiler_eff }
    /// El available during harm op period after TES chrg
    // MQ=IF(OR(KI6=0,KZ6=0),MAX(0,FT6+MAX(0,FD6-MK6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[MQ + i] = iff(
        or(h[KZ + i].isZero, h[KI + i].isZero), max(Double.zero, h[FT + i] + max(Double.zero, h[FD + i] - h[MK + i])),
        h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKI + i] + ((h[FT + i] + (h[HP + i] - h[FT + i]) * h[AMKI + i]) - (h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKI + i])) / Overall_harmonious_range
          * (h[KZ + i] - Overall_harmonious_min_perc))
    }
    /// Grid import for harm op during harm op period
    // MR=IF(OR(KI6=0,KZ6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[MR + i] = iff(
        or(h[KI + i].isZero, h[KZ + i].isZero), h[EZ + i],
        (h[EY + i] + (h[GU + i] - h[EY + i]) * h[AMKI + i]) + ((h[EZ + i] + (h[GV + i] - h[EZ + i]) * h[AMKI + i]) - (h[EY + i] + (h[GU + i] - h[EY + i]) * h[AMKI + i])) / Overall_harmonious_range
          * (h[KZ + i] - Overall_harmonious_min_perc))
    }
    /// Grid import for night prep during harm op period
    // MS=MIN(IF(OR(KI6=0,KZ6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      h[MS + i] = min(
        iff(
          or(h[KI + i].isZero, h[KZ + i].isZero), Double.zero,
          (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKI + i]) + ((h[GF + i] + (h[IB + i] - h[GF + i]) * h[AMKI + i]) - (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKI + i])) / Overall_harmonious_range
            * (h[KZ + i] - Overall_harmonious_min_perc)), max(Double.zero, h[ML + i] + h[MN + i] + h[MP + i] - h[MQ + i]))
    }
    /// Balance of electricity during harm op period
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { h[MT + i] = h[MQ + i] + h[MS + i] - h[ML + i] - h[MN + i] - h[MP + i] }
    /// el cons for harm op outside of harm op period
    // NA=IF(OR(FE6=0,KI6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[NA + i] = iff(or(h[FE + i].isZero, h[KI + i].isZero), Double.zero, h[FE + i] + (h[HA + i] - h[FE + i]) * h[AMKI + i]) }
    /// el to cover aux cons outside of harm op period
    // NB=IF(KI6=0,FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[NB + i] = iff(h[KI + i].isZero, h[FK + i], h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) }
    /// el from BESS discharging outside of harm op period
    // ND=MN6*BESS_chrg_eff
    for i in 0..<365 { h[ND + i] = h[MN + i] * BESS_chrg_eff }
    /// el cons for el boiler for harm op outside of harm op period
    // NC=IF(KI6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[NC + i] = iff(h[KI + i].isZero, h[FA + i], h[FA + i] + (h[GW + i] - h[FA + i]) * h[AMKI + i]) }
    /// El available outside of harm op period after TES chrg
    // NE=IF(KI6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[NE + i] = iff(h[KI + i].isZero, h[FU + i], h[FU + i] + (h[HQ + i] - h[FU + i]) * h[AMKI + i]) }
    // /// heat cons for harm op outside of harm op period
    // NH=IF(ND6>=NB6,0,MIN((NB6-ND6)/BESS_chrg_eff,IF(KI6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 { h[NH + i] = iff(h[ND + i] >= h[NB + i], Double.zero, min((h[NB + i] - h[ND + i]) / BESS_chrg_eff, iff(h[KI + i].isZero, h[GA + i], h[GA + i] + (h[HW + i] - h[GA + i]) * h[AMKI + i]))) }
    /// Grid import needed outside of harm op period
    // NF=MIN(IF(KI6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,NB6-NC6-ND6-NH6*BESS_chrg_eff))
    for i in 0..<365 { h[NF + i] = min(iff(h[KI + i].isZero, h[GG + i], h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]), max(Double.zero, h[NB + i] - h[NC + i] - h[ND + i] - h[NH + i] * BESS_chrg_eff)) }
    /// Balance of electricity outside of harm op period
    // NG=NC6+ND6+NF6+NH6*BESS_chrg_eff-MAX(0,NH6-NE6)-NB6
    for i in 0..<365 { h[NG + i] = h[NC + i] + h[ND + i] + h[NF + i] + h[NH + i] * BESS_chrg_eff - max(Double.zero, h[NH + i] - h[NE + i]) - h[NB + i] }
    // /// Heat prod by el boiler for harm op outside of harm op period
    // NI=IF(KI3=0,FN3,FN3+(HJ3-FN3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[NI + i] = iff(
        h[KI + i] == Double.zero, h[FN + i],
        h[FN + i] + (h[HJ + i] - h[FN + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat available outside of harm op period after TES chrg
    // NJ=IF(KI6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { h[NJ + i] = iff(h[KI + i].isZero, h[FX + i], h[FX + i] + (h[HT + i] - h[FX + i]) * h[AMKI + i]) }
    /// Balance of heat outside of harm op period
    // NK=IF(NI3=0,NJ3,-NI3)
    for i in 0..<365 { h[NK + i] = iff(h[NI + i] == Double.zero, h[NJ + i], -h[NI + i]) }

    /// Grid export
    // NM=ROUND(MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NE6-NH6,IF(KI6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))),0)
    for i in 0..<365 {
      h[NM + i] =
        (max(
          Double.zero,
          min(
            h[MT + i],
            iff(or(h[KI + i].isZero, h[KZ + i].isZero), h[GC + i], h[GB + i] + (h[HX + i] - h[GB + i]) * h[AMKI + i])
              + ((h[GC + i] + (h[HY + i] - h[GC + i]) * h[AMKI + i]) - (h[GB + i] + (h[HX + i] - h[GB + i]) * h[AMKI + i])) / Overall_harmonious_range * (h[KZ + i] - Overall_harmonious_min_perc)))
        + max(Double.zero, min(h[NE + i] + h[NH + i], iff(h[KI + i].isZero, h[GD + i], h[GD + i] + (h[HZ + i] - h[GD + i]) * h[AMKI + i])))).rounded()
    }

    // NR=ROUND(MAX(0,-MZ3)+MAX(0,-NK3),0)
   
    /// Grid import
    // NN=ROUND(MR3+NF3+NC3+MS3,0)+ROUND(MAX(0,-MT3)+MAX(0,-NG3)+NR3/El_boiler_eff,0)*EDG_elec_cost_factor
    for i in 0..<365 {
      h[NN + i] =
        round(h[MR + i] + h[NF + i] + h[NC + i] + h[MS + i], 0) + round(max(0, -h[MT + i]) + max(0, -h[NG + i]) + round(max(0, -h[MZ + i]) + max(0, -h[NK + i]), 0) / El_boiler_eff, 0)
        * EDG_elec_cost_factor
    }

    /// Outside harmonious operation period hours
    // NO=IF(NA6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { h[NO + i] = iff(h[NA + i].isZero, Double.zero, h[C + i] + (h[T + i] - h[C + i]) * h[AMKI + i]) }
    /// Harmonious operation period hours
    // NP=IF(MK6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { h[NP + i] = iff(h[MK + i].isZero, Double.zero, h[D + i] + (h[U + i] - h[D + i]) * h[AMKI + i]) }
    /// Pure Methanol prod with night priority and resp day op
    // NL=MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(NA6=0,0,IF(A_overall_var_max_cons=0,NO6*KI6,MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      h[NL + i] =
        max(Double.zero, h[MK + i] - h[NP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          h[NA + i].isZero, Double.zero,
          iff(overall_var_max_cons[j].isZero, h[NO + i] * h[KI + i], max(Double.zero, h[NA + i] - h[NO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }
    /// PB operating hours
    // NQ=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { h[NQ + i] = h[E + i] + (h[V + i] - h[E + i]) * h[AMKI + i] }
  }
}
