extension TunOl {
  func d14(_ d14: inout [Double], case j: Int) {
    // d10
    let (C, D, E, T, U, V, Z, AA, AB, AC, AM) = (0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125, 12775)
    let (
      EY, EZ, FA, _, FC, FD, FE, _, _, _, _, _, FK, FL, FM, FN, _, _, _, _, FS, FT, FU, FV, FW, FX, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI, _, _, _, _, _, _, _, _, _, _, GU, GV, GW, _, GY, GZ, HA, _, _, _, _, _, HG, HH, HI, HJ, _, _, _, _, HO, HP,
      HQ, HR, HS, HT, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE, _, _, _, _, _, _, _, _, _, _
    ) = (
      13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155, 17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805, 21170, 21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820, 25185,
      25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200, 29565, 29930, 30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580, 33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230, 37595, 37960,
      38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610, 41975, 42340, 42705, 43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625, 45990, 46355, 46720, 47085, 47450
    )

    let (JP, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, KG, _, KI) = (57305, 57670, 58035, 58400, 58765, 59130, 59495, 59860, 60225, 60590, 60955, 61320, 61685, 62050, 62415, 62780, 63145, 63510, 63875, 64240)
    let (AMKG, AMKI) = (56940, 63875)
    let dJP: Int = 70810  // LA

    let (
      KZ, LB, LC, LD, LE, _, LG, LH, LI, LJ, LK, LL, LM, LN, LO, LP, LQ, LR, LS, LT, LU, LV, LW, LX, LY, LZ, MA, MB, MC, MD, ME, MF, MG, MH, MI, _, MK, ML, MM, MN, _, MP, MQ, MR, MS, MT, MU, MV, MW, MX, MY, MZ, NA, NB, NC, ND, NE, NF, NG, NH, NI, NJ,
      NK, NL, NM, NN, NO, NP, NQ
    ) = (
      70445, 71175, 71540, 71905, 72270, 72635, 73000, 73365, 73730, 74095, 74460, 74825, 75190, 75555, 75920, 76285, 76650, 77015, 77380, 77745, 78110, 78475, 78840, 79205, 79570, 79935, 80300, 80665, 81030, 81395, 81760, 82125, 82490, 82855,
      83220, 83585, 83950, 84315, 84680, 85045, 85410, 85775, 86140, 86505, 86870, 87235, 87600, 87965, 88330, 88695, 89060, 89425, 89790, 90155, 90520, 90885, 91250, 91615, 91980, 92345, 92710, 93075, 93440, 93805, 94170, 94535, 94900, 95265,
      95630
    )

    /// el cons for harm op during harm op period
    // LB=IF(FC3=0,0,IF(OR(JP3=0,KG3=0),MAX(0,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)+((FD3+(GZ3-FD3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d14[LB + i] = iff(
        d14[FC + i] == Double.zero, 0,
        iff(
          or(d14[JP + i] == Double.zero, d14[KG + i] == Double.zero),
          max(0, d14[FD + i] - min(BESS_cap_ud / BESS_chrg_eff, max(0, d14[FK + i] / BESS_chrg_eff - d14[FZ + i] - d14[GA + i]))),
          d14[FC + i] + (d14[GY + i] - d14[FC + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])
            + ((d14[FD + i] + (d14[GZ + i] - d14[FD + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
              - (d14[FC + i] + (d14[GY + i] - d14[FC + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])))
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[JP + i] - Overall_harmonious_min_perc)))
    }
    let G: Int = 1460
    /// el cons for night prep during harm op period
    // LC=IF(KG6=0,0,$Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LC + i] = iff(d14[KG + i].isZero, Double.zero, d14[Z + i] + (d14[AA + i] - d14[Z + i]) * d14[AMKG + i]) }
    /// el to cover aux cons during harm op period
    for i in 0..<365 { d14[LD + i] = 99 }
    /// el cons for BESS charging during harm op period
    // LE=IF(OR(JP3=0,KG3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-LB3)),MIN(((FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))+((FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)),(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d14[LE + i] = iff(
        or(d14[JP + i] == Double.zero, d14[KG + i] == Double.zero),
        min(BESS_cap_ud / BESS_chrg_eff, max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[GA + i]), d14[FZ + i] + max(0, d14[FD + i] - d14[LB + i])),
        min(
          ((d14[FY + i] + (d14[HU + i] - d14[FY + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
            + ((d14[FZ + i] + (d14[HV + i] - d14[FZ + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
              - (d14[FY + i] + (d14[HU + i] - d14[FY + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[JP + i] - Overall_harmonious_min_perc)),
          (d14[FK + i] + (d14[HG + i] - d14[FK + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff)
      )
    }

    /// el cons for el boiler op for harm op during harm op period
    // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d14[LF + i] = iff(
    //     or(d14[JP + i].isZero, d14[KG + i].isZero), Double.zero,
    //     (d14[FL + i]
    //       + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d14[KG + i] - equiv_harmonious_min_perc[j]))
    //       + ((d14[FM + i]
    //         + (d14[HI + i] - d14[FM + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d14[KG + i] - equiv_harmonious_min_perc[j]))
    //         - (d14[FL + i]
    //           + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d14[KG + i] - equiv_harmonious_min_perc[j])))
    //       * d14[dJP + i])
    // }
    // /// heat cons for harm op during harm op period
    //     // LL=MIN(El_boiler_cap_ud*El_boiler_eff,MAX(0,LZ3-MA3))
    for i in 0..<365 {
      d14[LL + i] = min(El_boiler_cap_ud * El_boiler_eff, max(0, d14[LZ + i] - d14[MA + i]))
    }
    /// heat cons for night prep during harm op period
    // LM=IF(KG6=0,0,$AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LM + i] = iff(d14[KG + i].isZero, Double.zero, d14[AB + i] + (d14[AC + i] - d14[AB + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])) }

    // LD=LL3/El_boiler_eff
    for i in 0..<365 {
      d14[LD + i] = d14[LL + i] / El_boiler_eff
    }

    // /// heat prod by el boiler for harm op during harm op period
    // LN=IF(OR(JP3=0,KG3=0),FM3,(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))+((FM3+(HI3-FM3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))-(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[LN + i] = iff(
        or(d14[JP + i] == Double.zero, d14[KG + i] == Double.zero), d14[FM + i],
        (d14[FL + i] + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
          + ((d14[FM + i] + (d14[HI + i] - d14[FM + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
            - (d14[FL + i] + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[JP + i] - Overall_harmonious_min_perc))
    }

    /// Heat available during harm op period after TES chrg
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[LP + i] = iff(
        or(d14[JP + i].isZero, d14[KG + i].isZero), d14[FW + i],
        d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[AMKG + i] + ((d14[FW + i] + (d14[HS + i] - d14[FW + i]) * d14[AMKG + i]) - (d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[AMKG + i])) * d14[dJP + i])
    }
    /// heat prod by el boiler for night prep during harm op period
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 {
      d14[LO + i] = iff(
        or(d14[JP + i].isZero, d14[KG + i].isZero), Double.zero,
        min(
          (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[AMKG + i]) + ((d14[GI + i] + (d14[IE + i] - d14[GI + i]) * d14[AMKG + i]) - (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[AMKG + i])) * d14[dJP + i],
          max(Double.zero, d14[LM + i] - d14[LP + i])))
    }
    /// Balance of heat during harm op period
    // LQ=IF(LN3=0,LO3+LP3-LM3,-LN3)
    for i in 0..<365 { d14[LQ + i] = iff(d14[LN + i] == Double.zero, d14[LO + i] + d14[LP + i] - d14[LM + i], -d14[LN + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { d14[LG + i] = d14[LO + i] / El_boiler_eff }
    /// El available during harm op period after TES chrg
    // LH=IF(OR(JP6=0,KG6=0),MAX(0,FT6+MAX(0,FD6-LB6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[LH + i] = iff(
        or(d14[JP + i].isZero, d14[KG + i].isZero), max(Double.zero, d14[FT + i] + max(Double.zero, d14[FD + i] - d14[LB + i])),
        d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[AMKG + i] + ((d14[FT + i] + (d14[HP + i] - d14[FT + i]) * d14[AMKG + i]) - (d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[AMKG + i])) * d14[dJP + i])
    }
    /// Grid import for harm op during harm op period
    // LI=IF(OR(JP6=0,KG6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[LI + i] = iff(
        or(d14[JP + i].isZero, d14[KG + i].isZero), d14[EZ + i],
        (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[AMKG + i]) + ((d14[EZ + i] + (d14[GV + i] - d14[EZ + i]) * d14[AMKG + i]) - (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[AMKG + i])) * d14[dJP + i])
    }
    /// Grid import for night prep during harm op period
    // LJ=MIN(IF(OR(JP6=0,KG6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      d14[LJ + i] = min(
        iff(
          or(d14[JP + i].isZero, d14[KG + i].isZero), Double.zero,
          (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[AMKG + i]) + ((d14[GF + i] + (d14[IB + i] - d14[GF + i]) * d14[AMKG + i]) - (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[AMKG + i])) * d14[dJP + i]),
        max(Double.zero, d14[LC + i] - d14[LE + i] - d14[LG + i] - d14[LH + i]))
    }
    /// Balance of electricity during harm op period
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { d14[LK + i] = d14[LH + i] + d14[LJ + i] - d14[LC + i] - d14[LE + i] - d14[LG + i] }
    /// el cons for harm op outside of harm op period
    // LR=IF(OR(FE6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LR + i] = iff(or(d14[FE + i].isZero, d14[KG + i].isZero), Double.zero, d14[FE + i] + (d14[HA + i] - d14[FE + i]) * d14[AMKG + i]) }
    /// el to cover aux cons outside of harm op period
    // LS=IF(KG6=0,$G6+FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LS + i] = iff(d14[KG + i].isZero, d14[G + i] + d14[FK + i], d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[AMKG + i]) }
    /// el from BESS discharging outside of harm op period
    // LU=LE6*BESS_chrg_eff
    for i in 0..<365 { d14[LU + i] = d14[LE + i] * BESS_chrg_eff }
    /// el cons for el boiler for harm op outside of harm op period
    // LT=IF(KG6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LT + i] = iff(d14[KG + i].isZero, d14[FA + i], d14[FA + i] + (d14[GW + i] - d14[FA + i]) * d14[AMKG + i]) }
    /// El available outside of harm op period after TES chrg
    // LV=IF(KG6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[LV + i] = iff(d14[KG + i].isZero, d14[FU + i], d14[FU + i] + (d14[HQ + i] - d14[FU + i]) * d14[AMKG + i]) }
    /// heat cons for harm op outside of harm op period
    // LY=IF(LU6>=LS6,0,MIN((LS6-LU6)/BESS_chrg_eff,IF(KG6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 { d14[LY + i] = iff(d14[LU + i] >= d14[LS + i], Double.zero, min(BESS_cap_ud / BESS_chrg_eff, (d14[LS + i] - d14[LU + i]) / BESS_chrg_eff, iff(d14[KG + i].isZero, d14[GA + i], d14[GA + i] + (d14[HW + i] - d14[GA + i]) * d14[AMKG + i]))) }
    /// Grid import needed outside of harm op period
    // LW=MIN(IF(KG6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)),MAX(0,LS6-LT6-LU6-LY6*BESS_chrg_eff))
    for i in 0..<365 { d14[LW + i] = min(iff(d14[KG + i].isZero, d14[GG + i], d14[GG + i] + (d14[IC + i] - d14[GG + i]) * d14[AMKG + i]), max(Double.zero, d14[LS + i] - d14[LT + i] - d14[LU + i] - d14[LY + i] * BESS_chrg_eff)) }
    /// Balance of electricity outside of harm op period
    // LX=LT6+LU6+LW6+LY6*BESS_chrg_eff-MAX(0,LY6-LV6)-LS6-LD6
    for i in 0..<365 { d14[LX + i] = d14[LT + i] + d14[LU + i] + d14[LW + i] + d14[LY + i] * BESS_chrg_eff - max(Double.zero, d14[LY + i] - d14[LV + i]) - d14[LS + i] - d14[LD + i] }
    let I: Int = 2190
    /// Heat prod by el boiler for harm op outside of harm op period
    // LZ=IF(KG3=0,MAX($I3,FN3),FN3+(HJ3-FN3)/($AM3-A_equiv_harmonious_min_perc)*(KG3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d14[LZ + i] = iff(
        d14[KG + i] == Double.zero, max(d14[I + i], d14[FN + i]),
        d14[FN + i] + (d14[HJ + i] - d14[FN + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat available outside of harm op period after TES chrg
    // MA=IF(KG6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[MA + i] = iff(or(d14[JP + i].isZero, d14[KG + i].isZero), d14[FX + i], d14[FX + i] + (d14[HT + i] - d14[FX + i]) * d14[AMKG + i]) }
    /// Balance of heat outside of harm op period
    // MB=MA3+LL3-LZ3
    for i in 0..<365 { d14[MB + i] = d14[MA + i] + d14[LL + i] - d14[LZ + i] }
    /// grid export
    // MD=ROUND(MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LV6-LY6,IF(KG6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))),0)
    for i in 0..<365 {
      d14[MD + i] =
        max(Double.zero, min(
          d14[LK + i],
          iff(
            or(d14[JP + i].isZero, d14[KG + i].isZero), d14[GC + i],
            d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[AMKG + i] + ((d14[GC + i] + (d14[HY + i] - d14[GC + i]) * d14[AMKG + i]) - (d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[AMKG + i])) * d14[dJP + i]))
        + max(Double.zero, min(d14[LV + i] - d14[LY + i], iff(d14[KG + i].isZero, d14[GD + i], d14[GD + i] + (d14[HZ + i] - d14[GD + i]) * d14[AMKG + i])))).rounded()
    }
    /// Grid import
    // ME=ROUND(LI3+LW3+LT3+LJ3,0)+ROUND(MAX(0,-LK3)+MAX(0,-LX3)+MI3/El_boiler_eff,0)*EDG_elec_cost_factor
    for i in 0..<365 { 
      d14[ME + i] = round(d14[LI + i]+d14[LW + i]+d14[LT + i]+d14[LJ + i],0)+round(max(0,-d14[LK + i])+max(0,-d14[LX + i])+d14[MI + i]/El_boiler_eff,0)*EDG_elec_cost_factor
    }
    /// Outside harmonious operation period hours
    // MF=IF(LR6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d14[MF + i] = iff(d14[LR + i].isZero, Double.zero, d14[C + i] + (d14[T + i] - d14[C + i]) * d14[AMKG + i]) }
    /// Harmonious operation period hours
    // MG=IF(LB6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d14[MG + i] = iff(d14[LB + i].isZero, Double.zero, d14[D + i] + (d14[U + i] - d14[D + i]) * d14[AMKG + i]) }
    /// PB operating hours
    // MH=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { d14[MH + i] = d14[E + i] + (d14[V + i] - d14[E + i]) * d14[AMKG + i] }
    /// Pure Methanol prod with day priority and resp night op
    // MC=MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(LR6=0,0,IF(A_overall_var_max_cons=0,MF6*KG6,MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d14[MC + i] =
        max(Double.zero, d14[LB + i] - d14[MG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          d14[LR + i].isZero, Double.zero,
          iff(overall_var_max_cons[j].isZero, d14[MF + i] * d14[KG + i], max(Double.zero, d14[LR + i] - d14[MF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }
    /// Checksum
    // MI=ROUND(MAX(0,-LQ3)+MAX(0,-MB3),0)
    for i in 0..<365 { d14[MI + i] = round(max(0,-d14[LQ + i])+max(0,-d14[MB + i]),0) }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// el cons for harm op during harm op period
    // MK=IF(FC3=0,0,IF(OR(KI3=0,KZ3=0),MAX(0,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)+((FD3+(GZ3-FD3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FC3+(GY3-FC3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      d14[MK + i] = iff(
        d14[FC + i] == Double.zero, 0,
        iff(
          or(d14[KI + i] == Double.zero, d14[KZ + i] == Double.zero),
          max(0, d14[FD + i] - min(BESS_cap_ud / BESS_chrg_eff, max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[FZ + i] - d14[GA + i]))),
          d14[FC + i] + (d14[GY + i] - d14[FC + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j])
            + ((d14[FD + i] + (d14[GZ + i] - d14[FD + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
              - (d14[FC + i] + (d14[GY + i] - d14[FC + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j])))
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[KZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    // ML=IF(KI6=0,0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[ML + i] = iff(d14[KI + i].isZero, Double.zero, d14[Z + i] + (d14[AA + i] - d14[Z + i]) * d14[AMKI + i]) }
    /// el to cover aux cons during harm op period
    //     // for i in 0..<365 { d14[MM + i] = 99 }
    /// el cons for BESS charging during harm op period
    // MN=IF(OR(KI3=0,KZ3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-MK3)),MIN(((FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))+((FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc)),(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      d14[MN + i] = iff(
        or(d14[KI + i] == Double.zero, d14[KZ + i] == Double.zero),
        min(BESS_cap_ud / BESS_chrg_eff, max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[GA + i]), d14[FZ + i] + max(0, d14[FD + i] - d14[MK + i])),
        min(
          ((d14[FY + i] + (d14[HU + i] - d14[FY + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
            + ((d14[FZ + i] + (d14[HV + i] - d14[FZ + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
              - (d14[FY + i] + (d14[HU + i] - d14[FY + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[KZ + i] - Overall_harmonious_min_perc)),
          (d14[FK + i] + (d14[HG + i] - d14[FK + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff)
      )
    }

    /// el cons for el boiler op for harm op during harm op period
    //     // for i in 0..<365 { d14[MO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   d14[MO + i] = iff(
    //     or(d14[KZ + i].isZero, d14[KI + i].isZero), Double.zero,
    //     (d14[FL + i]
    //       + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //         * (d14[KI + i] - equiv_harmonious_min_perc[j]))
    //       + ((d14[FM + i]
    //         + (d14[HI + i] - d14[FM + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //           * (d14[KI + i] - equiv_harmonious_min_perc[j]))
    //         - (d14[FL + i]
    //           + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j])
    //             * (d14[KI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (d14[KZ + i] - Overall_harmonious_min_perc))
    // }
    // /// heat cons for harm op during harm op period
    // MU=MIN(El_boiler_cap_ud*El_boiler_eff,MAX(0,NI3-NJ3))
    for i in 0..<365 {
      d14[MU + i] = min(El_boiler_cap_ud * El_boiler_eff,max(0,d14[NI + i]-d14[NJ + i]))
    }
    // MM=MU3/El_boiler_eff
    for i in 0..<365 {
      d14[MM + i] = d14[MU + i] / El_boiler_eff
    }
    /// heat cons for night prep during harm op period
    // MV=IF(KI6=0,0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[MV + i] = iff(d14[KI + i].isZero, Double.zero, d14[AB + i] + (d14[AC + i] - d14[AB + i]) * d14[AMKI + i]) }
    // /// heat prod by el boiler for harm op during harm op period
    // MW=IF(OR(KZ3=0,KI3=0),FM3,(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))+((FM3+(HI3-FM3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(FL3+(HH3-FL3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[MW + i] = iff(
        or(d14[KZ + i] == Double.zero, d14[KI + i] == Double.zero), d14[FM + i],
        (d14[FL + i] + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
          + ((d14[FM + i] + (d14[HI + i] - d14[FM + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
            - (d14[FL + i] + (d14[HH + i] - d14[FL + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d14[KZ + i] - Overall_harmonious_min_perc))
    }

    /// Heat available during harm op period after TES chrg
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[MY + i] = iff(
        or(d14[KZ + i].isZero, d14[KI + i].isZero), d14[FW + i],
        d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[AMKI + i] + ((d14[FW + i] + (d14[HS + i] - d14[FW + i]) * d14[AMKI + i]) - (d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[AMKI + i])) / Overall_harmonious_range
          * (d14[KZ + i] - Overall_harmonious_min_perc))
    }
    /// heat prod by el boiler for night prep during harm op period
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      d14[MX + i] = iff(
        or(d14[KI + i].isZero, d14[KZ + i].isZero), Double.zero,
        min(
          (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[AMKI + i])
            + ((d14[GI + i] + (d14[IE + i] - d14[GI + i]) * d14[AMKI + i]) - (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[AMKI + i])) / Overall_harmonious_range * (d14[KZ + i] - Overall_harmonious_min_perc),
          max(Double.zero, d14[MV + i] - d14[MY + i])))
    }
    /// Balance of heat during harm op period
    // MZ=IF(MW3=0,MX3+MY3-MV3,-MW3)
    for i in 0..<365 { d14[MZ + i] = iff(d14[MW + i] == Double.zero, d14[MX + i] + d14[MY + i] - d14[MV + i], -d14[MW + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { d14[MP + i] = d14[MX + i] / El_boiler_eff }
    /// El available during harm op period after TES chrg
    // MQ=IF(OR(KI6=0,KZ6=0),MAX(0,FT6+MAX(0,FD6-MK6)),FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[MQ + i] = iff(
        or(d14[KZ + i].isZero, d14[KI + i].isZero), max(Double.zero, d14[FT + i] + max(Double.zero, d14[FD + i] - d14[MK + i])),
        d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[AMKI + i] + ((d14[FT + i] + (d14[HP + i] - d14[FT + i]) * d14[AMKI + i]) - (d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[AMKI + i])) / Overall_harmonious_range
          * (d14[KZ + i] - Overall_harmonious_min_perc))
    }
    /// Grid import for harm op during harm op period
    // MR=IF(OR(KI6=0,KZ6=0),EZ6,(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((EZ6+(GV6-EZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(EY6+(GU6-EY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      d14[MR + i] = iff(
        or(d14[KI + i].isZero, d14[KZ + i].isZero), d14[EZ + i],
        (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[AMKI + i]) + ((d14[EZ + i] + (d14[GV + i] - d14[EZ + i]) * d14[AMKI + i]) - (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[AMKI + i])) / Overall_harmonious_range
          * (d14[KZ + i] - Overall_harmonious_min_perc))
    }
    /// Grid import for night prep during harm op period
    // MS=MIN(IF(OR(KI6=0,KZ6=0),0,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      d14[MS + i] = min(
        iff(
          or(d14[KI + i].isZero, d14[KZ + i].isZero), Double.zero,
          (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[AMKI + i]) + ((d14[GF + i] + (d14[IB + i] - d14[GF + i]) * d14[AMKI + i]) - (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[AMKI + i])) / Overall_harmonious_range
            * (d14[KZ + i] - Overall_harmonious_min_perc)), max(Double.zero, d14[ML + i] + d14[MN + i] + d14[MP + i] - d14[MQ + i]))
    }
    /// Balance of electricity during harm op period
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { d14[MT + i] = d14[MQ + i] + d14[MS + i] - d14[ML + i] - d14[MN + i] - d14[MP + i] }
    /// el cons for harm op outside of harm op period
    // NA=IF(OR(FE6=0,KI6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[NA + i] = iff(or(d14[FE + i].isZero, d14[KI + i].isZero), Double.zero, d14[FE + i] + (d14[HA + i] - d14[FE + i]) * d14[AMKI + i]) }
    /// el to cover aux cons outside of harm op period
    // NB=IF(KI3=0,$G3+FK3,FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[NB + i] = iff(d14[KI + i].isZero, d14[FK + i], d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[AMKI + i]) }
    /// el from BESS discharging outside of harm op period
    // ND=MN6*BESS_chrg_eff
    for i in 0..<365 { d14[ND + i] = d14[MN + i] * BESS_chrg_eff }
    /// el cons for el boiler for harm op outside of harm op period
    // NC=IF(KI6=0,FA6,FA6+(GW6-FA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[NC + i] = iff(d14[KI + i].isZero, d14[FA + i], d14[FA + i] + (d14[GW + i] - d14[FA + i]) * d14[AMKI + i]) }
    /// El available outside of harm op period after TES chrg
    // NE=IF(KI6=0,FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[NE + i] = iff(d14[KI + i].isZero, d14[FU + i], d14[FU + i] + (d14[HQ + i] - d14[FU + i]) * d14[AMKI + i]) }
    // /// heat cons for harm op outside of harm op period
    // NH=IF(ND6>=NB6,0,MIN((NB6-ND6)/BESS_chrg_eff,IF(KI6=0,GA6,GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 { d14[NH + i] = iff(d14[ND + i] >= d14[NB + i], Double.zero, min(BESS_cap_ud / BESS_chrg_eff, (d14[NB + i] - d14[ND + i]) / BESS_chrg_eff, iff(d14[KI + i].isZero, d14[GA + i], d14[GA + i] + (d14[HW + i] - d14[GA + i]) * d14[AMKI + i]))) }
    /// Grid import needed outside of harm op period
    // NF=MIN(IF(KI6=0,GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,NB6-NC6-ND6-NH6*BESS_chrg_eff))
    for i in 0..<365 { d14[NF + i] = min(iff(d14[KI + i].isZero, d14[GG + i], d14[GG + i] + (d14[IC + i] - d14[GG + i]) * d14[AMKI + i]), max(Double.zero, d14[NB + i] - d14[NC + i] - d14[ND + i] - d14[NH + i] * BESS_chrg_eff)) }
    /// Balance of electricity outside of harm op period
    // NG=NC6+ND6+NF6+NH6*BESS_chrg_eff-MAX(0,NH6-NE6)-NB6-MM3
    for i in 0..<365 { d14[NG + i] = d14[NC + i] + d14[ND + i] + d14[NF + i] + d14[NH + i] * BESS_chrg_eff - max(Double.zero, d14[NH + i] - d14[NE + i]) - d14[NB + i] - d14[MM + i] }
    // /// Heat prod by el boiler for harm op outside of harm op period
    // NI=IF(KI3=0,MAX($I3,FN3),FN3+(HJ3-FN3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d14[NI + i] = iff(
        d14[KI + i] == Double.zero, max(d14[FN + i], d14[FN + i]),
        d14[FN + i] + (d14[HJ + i] - d14[FN + i]) / (d14[AM + i] - equiv_harmonious_min_perc[j]) * (d14[KI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat available outside of harm op period after TES chrg
    // NJ=IF(KI6=0,FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d14[NJ + i] = iff(d14[KI + i].isZero, d14[FX + i], d14[FX + i] + (d14[HT + i] - d14[FX + i]) * d14[AMKI + i]) }
    /// Balance of heat outside of harm op period
    // NK=NJ3+MU3-NI3
    for i in 0..<365 { d14[NK + i] = d14[NJ + i] + d14[MU + i] - d14[NI + i] }

    /// Grid export
    // NM=ROUND(MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NE6-NH6,IF(KI6=0,GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))),0)
    for i in 0..<365 {
      d14[NM + i] =
        (max(
          Double.zero,
          min(
            d14[MT + i],
            iff(or(d14[KI + i].isZero, d14[KZ + i].isZero), d14[GC + i], d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[AMKI + i])
              + ((d14[GC + i] + (d14[HY + i] - d14[GC + i]) * d14[AMKI + i]) - (d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[AMKI + i])) / Overall_harmonious_range * (d14[KZ + i] - Overall_harmonious_min_perc)))
        + max(Double.zero, min(d14[NE + i] + d14[NH + i], iff(d14[KI + i].isZero, d14[GD + i], d14[GD + i] + (d14[HZ + i] - d14[GD + i]) * d14[AMKI + i])))).rounded()
    }

    // NR=ROUND(MAX(0,-MZ3)+MAX(0,-NK3),0)
   
    /// Grid import
    // NN=ROUND(MR3+NF3+NC3+MS3,0)+ROUND(MAX(0,-MT3)+MAX(0,-NG3)+NR3/El_boiler_eff,0)*EDG_elec_cost_factor
    for i in 0..<365 {
      d14[NN + i] =
        round(d14[MR + i] + d14[NF + i] + d14[NC + i] + d14[MS + i], 0) + round(max(0, -d14[MT + i]) + max(0, -d14[NG + i]) + round(max(0, -d14[MZ + i]) + max(0, -d14[NK + i]), 0) / El_boiler_eff, 0)
        * EDG_elec_cost_factor
    }

    /// Outside harmonious operation period hours
    // NO=IF(NA6=0,0,$C6+IFERROR(($T6-$C6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d14[NO + i] = iff(d14[NA + i].isZero, Double.zero, d14[C + i] + (d14[T + i] - d14[C + i]) * d14[AMKI + i]) }
    /// Harmonious operation period hours
    // NP=IF(MK6=0,0,$D6+IFERROR(($U6-$D6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0))
    for i in 0..<365 { d14[NP + i] = iff(d14[MK + i].isZero, Double.zero, d14[D + i] + (d14[U + i] - d14[D + i]) * d14[AMKI + i]) }
    /// Pure Methanol prod with night priority and resp day op
    // NL=MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(NA6=0,0,IF(A_overall_var_max_cons=0,NO6*KI6,MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      d14[NL + i] =
        max(Double.zero, d14[MK + i] - d14[NP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          d14[NA + i].isZero, Double.zero,
          iff(overall_var_max_cons[j].isZero, d14[NO + i] * d14[KI + i], max(Double.zero, d14[NA + i] - d14[NO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }
    /// PB operating hours
    // NQ=$E6+IFERROR(($V6-$E6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),0)
    for i in 0..<365 { d14[NQ + i] = d14[E + i] + (d14[V + i] - d14[E + i]) * d14[AMKI + i] }
  }
}
