extension TunOl {
  func d14(_ d14: inout [Double], case j: Int) {
    // d10
    let (C, D, E, T, U, V, Z, AA, AB, AC) = (0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125)
    let (
      EY, EZ, FA, _, FC, FD, FE, _, _, _, _, _, FK, FL, FM, FN, _, _, _, _, FS, FT, FU, FV, FW, FX, FY, FZ, GA, GB, GC,
      GD, GE, GF, GG, GH, GI, _, _, _, _, _, _, _, _, _, _, GU, GV, GW, _, GY, GZ, HA, _, _, _, _, _, HG, HH, HI, HJ,
      _, _, _, _, HO, HP, HQ, HR, HS, HT, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE, _, _, _, _, _, _, _, _, _, _
    ) = (
      13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155, 17520, 17885, 18250, 18615,
      18980, 19345, 19710, 20075, 20440, 20805, 21170, 21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455,
      24820, 25185, 25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200, 29565, 29930, 30660,
      31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580, 33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500,
      36865, 37230, 37595, 37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610, 41975, 42340,
      42705, 43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625, 45990, 46355, 46720, 47085, 47450
    )

    let (JP, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, KG, _, KI) = (
      57305, 57670, 58035, 58400, 58765, 59130, 59495, 59860, 60225, 60590, 60955, 61320, 61685, 62050, 62415, 62780,
      63145, 63510, 63875, 64240
    )

    let (
      KZ, LB, LC, LD, LE, _, LG, LH, LI, LJ, LK, LL, LM, LN, LO, LP, LQ, LR, LS, LT, LU, LV, LW, LX, LY, LZ, MA, MB,
      MC, MD, ME, MF, MG, MH, MI, _, MK, ML, MM, MN, NR, MP, MQ, MR, MS, MT, MU, MV, MW, MX, MY, MZ, NA, NB, NC, ND, NE,
      NF, NG, NH, NI, NJ, NK, NL, NM, NN, NO, NP, NQ
    ) = (
      70445, 71175, 71540, 71905, 72270, 72635, 73000, 73365, 73730, 74095, 74460, 74825, 75190, 75555, 75920, 76285,
      76650, 77015, 77380, 77745, 78110, 78475, 78840, 79205, 79570, 79935, 80300, 80665, 81030, 81395, 81760, 82125,
      82490, 82855, 83220, 83585, 83950, 84315, 84680, 85045, 85410, 85775, 86140, 86505, 86870, 87235, 87600, 87965,
      88330, 88695, 89060, 89425, 89790, 90155, 90520, 90885, 91250, 91615, 91980, 92345, 92710, 93075, 93440, 93805,
      94170, 94535, 94900, 95265, 95630
    )
    let G: Int = 1460
    /// el cons for harm op during harm op period
    // el cons for harm op during harm op period (incl grid import)
    // LB=IF(FC3=0,0,IF(OR(JP3<0,KG3<0),MAX(FC3,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)*KG3+((FD3+(GZ3-FD3)*KG3)-(FC3+(GY3-FC3)*KG3))*JP3))
    for i in 0..<365 {
      d14[LB + i] = iff(
        d14[FC + i] == Double.zero, 0,
        iff(
          or(d14[JP + i] < 0, d14[KG + i] < 0),
          max(
            d14[FC + i],
            d14[FD + i]
              - min(
                BESS_cap_ud / BESS_chrg_eff,
                max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[FZ + i] - d14[GA + i]))),
          d14[FC + i] + (d14[GY + i] - d14[FC + i]) * d14[KG + i]
            + ((d14[FD + i] + (d14[GZ + i] - d14[FD + i]) * d14[KG + i])
              - (d14[FC + i] + (d14[GY + i] - d14[FC + i]) * d14[KG + i])) * d14[JP + i]))
    }
    // el cons for night prep during harm op period
    // LC=IF(KG3<0,0,$Z3+($AA3-$Z3)*KG3)
    for i in 0..<365 { d14[LC + i] = iff(d14[KG + i] < 0, 0, d14[Z + i] + (d14[AA + i] - d14[Z + i]) * d14[KG + i]) }
    /// el to cover aux cons during harm op period

    // el cons for BESS charging during harm op period for stby covered by plant
    // LE=IF(OR(JP3<0,KG3<0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-LB3)),MIN(((FY3+(HU3-FY3)*KG3)+((FZ3+(HV3-FZ3)*KG3)-(FY3+(HU3-FY3)*KG3))*JP3),(FK3+(HG3-FK3)*KG3)/BESS_chrg_eff))
    for i in 0..<365 {
      d14[LE + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0),
        min(
          BESS_cap_ud / BESS_chrg_eff, max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[GA + i]),
          d14[FZ + i] + max(0, d14[FD + i] - d14[LB + i])),
        min(
          ((d14[FY + i] + (d14[HU + i] - d14[FY + i]) * d14[KG + i])
            + ((d14[FZ + i] + (d14[HV + i] - d14[FZ + i]) * d14[KG + i])
              - (d14[FY + i] + (d14[HU + i] - d14[FY + i]) * d14[KG + i])) * d14[JP + i]),
          (d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[KG + i]) / BESS_chrg_eff))
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
    // Heat available outside of harm op period after TES chrg
    // MA=IF(KG3<0,FX3,FX3+(HT3-FX3)*KG3)
    for i in 0..<365 {
      d14[MA + i] = iff(d14[KG + i] < 0, d14[FX + i], d14[FX + i] + (d14[HT + i] - d14[FX + i]) * d14[KG + i])
    }
    // heat cons for night prep during harm op period
    // LM=IF(KG3<0,0,$AB3+($AC3-$AB3)*KG3)
    for i in 0..<365 { d14[LM + i] = iff(d14[KG + i] < 0, 0, d14[AB + i] + (d14[AC + i] - d14[AB + i]) * d14[KG + i]) }

    // heat cons not covered during harm op period
    // LN=IF(OR(JP3<0,KG3<0),FM3,(FL3+(HH3-FL3)*KG3)+((FM3+(HI3-FM3)*KG3)-(FL3+(HH3-FL3)*KG3))*JP3)
    for i in 0..<365 {
      d14[LN + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0), d14[FM + i],
        (d14[FL + i] + (d14[HH + i] - d14[FL + i]) * d14[KG + i])
          + ((d14[FM + i] + (d14[HI + i] - d14[FM + i]) * d14[KG + i])
            - (d14[FL + i] + (d14[HH + i] - d14[FL + i]) * d14[KG + i])) * d14[JP + i])
    }

    // Heat available during harm op period after harm op and TES chrg
    // LP=IF(OR(JP3<0,KG3<0),FW3,FV3+(HR3-FV3)*KG3+((FW3+(HS3-FW3)*KG3)-(FV3+(HR3-FV3)*KG3))*JP3)
    for i in 0..<365 {
      d14[LP + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0), d14[FW + i],
        d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[KG + i]
          + ((d14[FW + i] + (d14[HS + i] - d14[FW + i]) * d14[KG + i])
            - (d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[KG + i])) * d14[JP + i])
    }
    // heat prod by el boiler for night prep during harm op period
    // LO=IF(OR(JP3<0,KG3<0),0,MIN((GH3+(ID3-GH3)*KG3)+((GI3+(IE3-GI3)*KG3)-(GH3+(ID3-GH3)*KG3))*JP3,MAX(0,LM3-LP3)))
    for i in 0..<365 {
      d14[LO + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0), 0,
        min(
          (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[KG + i])
            + ((d14[GI + i] + (d14[IE + i] - d14[GI + i]) * d14[KG + i])
              - (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[KG + i])) * d14[JP + i],
          max(0, d14[LM + i] - d14[LP + i])))
    }
    /// Balance of heat during harm op period
    // LQ=IF(LN3=0,LO3+LP3-LM3,-LN3)
    for i in 0..<365 { d14[LQ + i] = iff(d14[LN + i] < 0.000001, d14[LO + i] + d14[LP + i] - d14[LM + i], -d14[LN + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { d14[LG + i] = d14[LO + i] / El_boiler_eff }
    // El available during harm op period after harm op and TES chrg
    // LH=IF(OR(JP3<0,KG3<0),MAX(0,FT3+MAX(0,FD3-LB3)),FS3+(HO3-FS3)*KG3+((FT3+(HP3-FT3)*KG3)-(FS3+(HO3-FS3)*KG3))*JP3)
    for i in 0..<365 {
      d14[LH + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0), max(0, d14[FT + i] + max(0, d14[FD + i] - d14[LB + i])),
        d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[KG + i]
          + ((d14[FT + i] + (d14[HP + i] - d14[FT + i]) * d14[KG + i])
            - (d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[KG + i])) * d14[JP + i])
    }
    // Grid import for harm op during harm op period
    // LI=IF(OR(JP3<0,KG3<0),EZ3,(EY3+(GU3-EY3)*KG3)+((EZ3+(GV3-EZ3)*KG3)-(EY3+(GU3-EY3)*KG3))*JP3)
    for i in 0..<365 {
      d14[LI + i] = iff(
        or(d14[JP + i] < 0, d14[KG + i] < 0), d14[EZ + i],
        (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[KG + i])
          + ((d14[EZ + i] + (d14[GV + i] - d14[EZ + i]) * d14[KG + i])
            - (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[KG + i])) * d14[JP + i])
    }
    // Grid import for night prep during harm op period
    // LJ=MIN(IF(OR(JP3<0,KG3<0),0,(GE3+(IA3-GE3)*KG3)+((GF3+(IB3-GF3)*KG3)-(GE3+(IA3-GE3)*KG3))*JP3),MAX(0,LC3+LE3+LG3-LH3))
    for i in 0..<365 {
      d14[LJ + i] = min(
        iff(
          or(d14[JP + i] < 0, d14[KG + i] < 0), 0,
          (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[KG + i])
            + ((d14[GF + i] + (d14[IB + i] - d14[GF + i]) * d14[KG + i])
              - (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[KG + i])) * d14[JP + i]),
        max(0, d14[LC + i] + d14[LE + i] + d14[LG + i] - d14[LH + i]))
    }
    /// Balance of electricity during harm op period
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { d14[LK + i] = d14[LH + i] + d14[LJ + i] - d14[LC + i] - d14[LE + i] - d14[LG + i] }
    // el cons for harm op outside of harm op period incl grid import
    // LR=IF(OR(FE3=0,KG3<0),0,FE3+(HA3-FE3)*KG3)
    for i in 0..<365 {
      d14[LR + i] = iff(
        or(d14[FE + i] == Double.zero, d14[KG + i] < 0), 0, d14[FE + i] + (d14[HA + i] - d14[FE + i]) * d14[KG + i])
    }
    // El cons for harm op and stby not covered by plant outside of harm op period
    // LS=IF(KG3<0,$G3+FK3,FK3+(HG3-FK3)*KG3)
    for i in 0..<365 {
      d14[LS + i] = iff(
        d14[KG + i] < 0, d14[G + i] + d14[FK + i], d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[KG + i])
    }
    /// el from BESS discharging outside of harm op period
    // LU=LE6*BESS_chrg_eff
    for i in 0..<365 { d14[LU + i] = d14[LE + i] * BESS_chrg_eff }
    // grid import for harm op+aux outside of harm op period
    // LT=IF(KG3<0,FA3,FA3+(GW3-FA3)*KG3)
    for i in 0..<365 {
      d14[LT + i] = iff(d14[KG + i] < 0, d14[FA + i], d14[FA + i] + (d14[GW + i] - d14[FA + i]) * d14[KG + i])
    }
    // El available outside harm op period after harm op and TES chrg
    // LV=IF(KG3<0,FU3,FU3+(HQ3-FU3)*KG3)
    for i in 0..<365 {
      d14[LV + i] = iff(d14[KG + i] < 0, d14[FU + i], d14[FU + i] + (d14[HQ + i] - d14[FU + i]) * d14[KG + i])
    }
    // El to BESS charging outside harm op period
    // LY=IF(LU3>=LS3,0,MIN(BESS_cap_ud/BESS_chrg_eff,(LS3-LU3)/BESS_chrg_eff,IF(KG3<0,GA3,GA3+(HW3-GA3)*KG3)))
    for i in 0..<365 {
      d14[LY + i] = iff(
        d14[LU + i] >= d14[LS + i], 0,
        min(
          BESS_cap_ud / BESS_chrg_eff, (d14[LS + i] - d14[LU + i]) / BESS_chrg_eff,
          iff(d14[KG + i] < 0, d14[GA + i], d14[GA + i] + (d14[HW + i] - d14[GA + i]) * d14[KG + i])))
    }
    // Addtl. grid import needed outside of harm op period
    // LW=MIN(IF(KG3<0,GG3,GG3+(IC3-GG3)*KG3),MAX(0,LS3-LT3-LU3-LY3*BESS_chrg_eff))
    for i in 0..<365 {
      d14[LW + i] = min(
        iff(d14[KG + i] < 0, d14[GG + i], d14[GG + i] + (d14[IC + i] - d14[GG + i]) * d14[KG + i]),
        max(0, d14[LS + i] - d14[LT + i] - d14[LU + i] - d14[LY + i] * BESS_chrg_eff))
    }

    let I: Int = 2190
    // heat cons not covered outside harm op period
    // LZ=IF(KG3<0,$I3+FN3,FN3+(HJ3-FN3)*KG3)
    for i in 0..<365 {
      d14[LZ + i] = iff(
        d14[KG + i] < 0, d14[I + i] + d14[FN + i], d14[FN + i] + (d14[HJ + i] - d14[FN + i]) * d14[KG + i])
    }

    for i in 0..<365 { d14[LL + i] = min(El_boiler_cap_ud*El_boiler_eff, max(0, d14[LZ + i] - d14[MA + i])) }
    // LD=LL3/El_boiler_eff
    for i in 0..<365 { d14[LD + i] = d14[LL + i] / El_boiler_eff }

    /// Balance of electricity outside of harm op period
    // LX=LT6+LU6+LW6+LY6*BESS_chrg_eff-MAX(0,LY6-LV6)-LS6-LD6
    for i in 0..<365 {
      d14[LX + i] =
        d14[LT + i] + d14[LU + i] + d14[LW + i] + d14[LY + i] * BESS_chrg_eff
        - max(Double.zero, d14[LY + i] - d14[LV + i]) - d14[LS + i] - d14[LD + i]
    }

    /// Balance of heat outside of harm op period
    // MB=MA3+LL3-LZ3
    for i in 0..<365 { d14[MB + i] = d14[MA + i] + d14[LL + i] - d14[LZ + i] }
    // grid export
    // MD=MAX(0,MIN(LK3,IF(OR(JP3<0,KG3<0),GC3,GB3+(HX3-GB3)*KG3+((GC3+(HY3-GC3)*KG3)-(GB3+(HX3-GB3)*KG3))*JP3)))+MAX(0,MIN(LV3-LY3,IF(KG3<0,GD3,GD3+(HZ3-GD3)*KG3)))
    for i in 0..<365 {
      d14[MD + i] =
        max(
          0,
          min(
            d14[LK + i],
            iff(
              or(d14[JP + i] < 0, d14[KG + i] < 0), d14[GC + i],
              d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[KG + i]
                + ((d14[GC + i] + (d14[HY + i] - d14[GC + i]) * d14[KG + i])
                  - (d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[KG + i])) * d14[JP + i])))
        + max(
          0,
          min(
            d14[LV + i] - d14[LY + i],
            iff(d14[KG + i] < 0, d14[GD + i], d14[GD + i] + (d14[HZ + i] - d14[GD + i]) * d14[KG + i])))
    }
    // Grid import
    // ME=LI3+LW3+LT3+LJ3+(MAX(0,-LK3)+MAX(0,-LX3)+MI3/El_boiler_eff)*EDG_elec_cost_factor
    for i in 0..<365 {
      d14[ME + i] =
        d14[LI + i] + d14[LW + i] + d14[LT + i] + d14[LJ + i]
        + (max(0, -d14[LK + i]) + max(0, -d14[LX + i]) + d14[MI + i] / El_boiler_eff) * EDG_elec_cost_factor
    }
    // Outside harmonious operation period op hours
    // MF=IF(KG3<0,0,$C3+($T3-$C3)*KG3)
    for i in 0..<365 { d14[MF + i] = iff(d14[KG + i] < 0, 0, d14[C + i] + (d14[T + i] - d14[C + i]) * d14[KG + i]) }
    // Harmonious operation period op hours
    // MG=IF(LB3=0,0,$D3+IF(KG3<0,0,($U3-$D3)*KG3))
    for i in 0..<365 {
      d14[MG + i] = iff(
        d14[LB + i] == Double.zero, 0, d14[D + i] + iff(d14[KG + i] < 0, 0, (d14[U + i] - d14[D + i]) * d14[KG + i]))
    }
    // PB operating hours
    // MH=IF(KG3<0,0,$E3+($V3-$E3)*KG3)
    for i in 0..<365 { d14[MH + i] = iff(d14[KG + i] < 0, 0, d14[E + i] + (d14[V + i] - d14[E + i]) * d14[KG + i]) }
    // Pure Methanol prod with day priority and resp night op
    // MC=IFERROR(((MAX(0,LB3/MG3-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethDist_harmonious_max_perc-MethDist_harmonious_min_perc)+MethDist_harmonious_min_perc)*MG3+IF(KG3<0,0,(IF(OR(A_overall_var_max_cons=0,A_overall_var_min_cons=0,A_overall_var_max_cons=A_overall_var_min_cons),KG3,(MAX(0,LR3/MF3-A_overall_fix_stby_cons)-A_overall_var_min_cons)/(A_overall_var_max_cons-A_overall_var_min_cons))*(A_MethDist_max_perc-A_MethDist_Min_perc)+A_MethDist_Min_perc)*MF3),0)*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      d14[MC + i] =
        ifFinite(
          ((max(0, d14[LB + i] / d14[MG + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
            * (MethDist_harmonious_max_perc - MethDist_harmonious_min_perc) + MethDist_harmonious_min_perc) * d14[MG + i]
            + iff(
              d14[KG + i] < 0, 0,
              (iff(
                or(overall_var_max_cons[j] == Double.zero, overall_var_min_cons[j] == Double.zero, overall_var_max_cons[j] == overall_var_min_cons[j]), d14[KG + i],
                (max(0, d14[LR + i] / d14[MF + i] - overall_fix_stby_cons[j]) - overall_var_min_cons[j]) / (overall_var_max_cons[j] - overall_var_min_cons[j]))
                * (MethDist_max_perc[j] - MethDist_min_perc[j]) + MethDist_min_perc[j]) * d14[MF + i]), 0) * MethDist_Meth_nom_prod_ud
    }

    // Missing heat
    // MI=MAX(0,-LQ3)+MAX(0,-MB3)
    for i in 0..<365 { d14[MI + i] = max(0, -d14[LQ + i]) + max(0, -d14[MB + i]) }

    // el cons for harm op during harm op period (incl grid import)
    // MK=IF(FC3=0,0,IF(OR(KI3<0,KZ3<0),MAX(FC3,FD3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-FZ3-GA3))),FC3+(GY3-FC3)*KI3+((FD3+(GZ3-FD3)*KI3)-(FC3+(GY3-FC3)*KI3))*KZ3))
    for i in 0..<365 {
      d14[MK + i] = iff(
        d14[FC + i] == Double.zero, 0,
        iff(
          or(d14[KI + i] < 0, d14[KZ + i] < 0),
          max(
            d14[FC + i],
            d14[FD + i]
              - min(
                BESS_cap_ud / BESS_chrg_eff,
                max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[FZ + i] - d14[GA + i]))),
          d14[FC + i] + (d14[GY + i] - d14[FC + i]) * d14[KI + i]
            + ((d14[FD + i] + (d14[GZ + i] - d14[FD + i]) * d14[KI + i])
              - (d14[FC + i] + (d14[GY + i] - d14[FC + i]) * d14[KI + i])) * d14[KZ + i]))
    }

    // el cons for night prep during harm op period
    // ML=IF(KI3<0,0,$Z3+($AA3-$Z3)*KI3)
    for i in 0..<365 { d14[ML + i] = iff(d14[KI + i] < 0, 0, d14[Z + i] + (d14[AA + i] - d14[Z + i]) * d14[KI + i]) }
    // el cons for BESS charging during harm op period for stby covered by plant
    // MN=IF(OR(KI3<0,KZ3<0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,($G3+FK3)/BESS_chrg_eff-GA3),FZ3+MAX(0,FD3-MK3)),MIN(((FY3+(HU3-FY3)*KI3)+((FZ3+(HV3-FZ3)*KI3)-(FY3+(HU3-FY3)*KI3))*KZ3),(FK3+(HG3-FK3)*KI3)/BESS_chrg_eff))
    for i in 0..<365 {
      d14[MN + i] = iff(
        or(d14[KI + i] < 0, d14[KZ + i] < 0),
        min(
          BESS_cap_ud / BESS_chrg_eff, max(0, (d14[G + i] + d14[FK + i]) / BESS_chrg_eff - d14[GA + i]),
          d14[FZ + i] + max(0, d14[FD + i] - d14[MK + i])),
        min(
          ((d14[FY + i] + (d14[HU + i] - d14[FY + i]) * d14[KI + i])
            + ((d14[FZ + i] + (d14[HV + i] - d14[FZ + i]) * d14[KI + i])
              - (d14[FY + i] + (d14[HU + i] - d14[FY + i]) * d14[KI + i])) * d14[KZ + i]),
          (d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[KI + i]) / BESS_chrg_eff))
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

    // heat cons for night prep during harm op period
    // MV=IF(KI3<0,0,$AB3+($AC3-$AB3)*KI3)
    for i in 0..<365 { d14[MV + i] = iff(d14[KI + i] < 0, 0, d14[AB + i] + (d14[AC + i] - d14[AB + i]) * d14[KI + i]) }
    // heat cons not covered during harm op period
    // MW=IF(OR(KZ3<0,KI3<0),FM3,(FL3+(HH3-FL3)*KI3)+((FM3+(HI3-FM3)*KI3)-(FL3+(HH3-FL3)*KI3))*KZ3)
    for i in 0..<365 {
      d14[MW + i] = iff(
        or(d14[KZ + i] < 0, d14[KI + i] < 0), d14[FM + i],
        (d14[FL + i] + (d14[HH + i] - d14[FL + i]) * d14[KI + i])
          + ((d14[FM + i] + (d14[HI + i] - d14[FM + i]) * d14[KI + i])
            - (d14[FL + i] + (d14[HH + i] - d14[FL + i]) * d14[KI + i])) * d14[KZ + i])
    }

    // Heat available during harm op period after harm op and TES chrg
    // MY=IF(OR(KI3<0,KZ3<0),FW3,FV3+(HR3-FV3)*KI3+((FW3+(HS3-FW3)*KI3)-(FV3+(HR3-FV3)*KI3))*KZ3)
    for i in 0..<365 {
      d14[MY + i] = iff(
        or(d14[KI + i] < 0, d14[KZ + i] < 0), d14[FW + i],
        d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[KI + i]
          + ((d14[FW + i] + (d14[HS + i] - d14[FW + i]) * d14[KI + i])
            - (d14[FV + i] + (d14[HR + i] - d14[FV + i]) * d14[KI + i])) * d14[KZ + i])
    }
    // heat prod by el boiler for night prep during harm op period
    // MX=IF(OR(KI3<0,KZ3<0),0,MIN((GH3+(ID3-GH3)*KI3)+((GI3+(IE3-GI3)*KI3)-(GH3+(ID3-GH3)*KI3))*KZ3,MAX(0,MV3-MY3)))
    for i in 0..<365 {
      d14[MX + i] = iff(
        or(d14[KI + i] < 0, d14[KZ + i] < 0), 0,
        min(
          (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[KI + i])
            + ((d14[GI + i] + (d14[IE + i] - d14[GI + i]) * d14[KI + i])
              - (d14[GH + i] + (d14[ID + i] - d14[GH + i]) * d14[KI + i])) * d14[KZ + i],
          max(0, d14[MV + i] - d14[MY + i])))
    }
    /// Balance of heat during harm op period
    // MZ=IF(MW3=0,MX3+MY3-MV3,-MW3)
    for i in 0..<365 { d14[MZ + i] = iff(d14[MW + i] < 0.000001, d14[MX + i] + d14[MY + i] - d14[MV + i], -d14[MW + i]) }

    /// el cons for el boiler op for night prep during harm op period
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { d14[MP + i] = d14[MX + i] / El_boiler_eff }
    // El available during harm op period after harm op and TES chrg
    // MQ=IF(OR(KI3<0,KZ3<0),MAX(0,FT3+MAX(0,FD3-MK3)),FS3+(HO3-FS3)*KI3+((FT3+(HP3-FT3)*KI3)-(FS3+(HO3-FS3)*KI3))*KZ3)
    for i in 0..<365 {
      d14[MQ + i] = iff(
        or(d14[KI + i] < 0, d14[KZ + i] < 0), max(0, d14[FT + i] + max(0, d14[FD + i] - d14[MK + i])),
        d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[KI + i]
          + ((d14[FT + i] + (d14[HP + i] - d14[FT + i]) * d14[KI + i])
            - (d14[FS + i] + (d14[HO + i] - d14[FS + i]) * d14[KI + i])) * d14[KZ + i])
    }
    // Grid import for harm op during harm op period
    // MR=IF(OR(KI3<0,KZ3<0),EZ3,(EY3+(GU3-EY3)*KI3)+((EZ3+(GV3-EZ3)*KI3)-(EY3+(GU3-EY3)*KI3))*KZ3)
    for i in 0..<365 {
      d14[MR + i] = iff(
        or(d14[KI + i] < 0, d14[KZ + i] < 0), d14[EZ + i],
        (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[KI + i])
          + ((d14[EZ + i] + (d14[GV + i] - d14[EZ + i]) * d14[KI + i])
            - (d14[EY + i] + (d14[GU + i] - d14[EY + i]) * d14[KI + i])) * d14[KZ + i])
    }
    // Grid import for night prep during harm op period
    // MS=MIN(IF(OR(KI3<0,KZ3<0),0,(GE3+(IA3-GE3)*KI3)+((GF3+(IB3-GF3)*KI3)-(GE3+(IA3-GE3)*KI3))*KZ3),MAX(0,ML3+MN3+MP3-MQ3))
    for i in 0..<365 {
      d14[MS + i] = min(
        iff(
          or(d14[KI + i] < 0, d14[KZ + i] < 0), 0,
          (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[KI + i])
            + ((d14[GF + i] + (d14[IB + i] - d14[GF + i]) * d14[KI + i])
              - (d14[GE + i] + (d14[IA + i] - d14[GE + i]) * d14[KI + i])) * d14[KZ + i]),
        max(0, d14[ML + i] + d14[MN + i] + d14[MP + i] - d14[MQ + i]))
    }
    /// Balance of electricity during harm op period
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { d14[MT + i] = d14[MQ + i] + d14[MS + i] - d14[ML + i] - d14[MN + i] - d14[MP + i] }
    // el cons for harm op outside of harm op period
    // NA=IF(OR(FE3=0,KI3<0),0,FE3+(HA3-FE3)*KI3)
    for i in 0..<365 {
      d14[NA + i] = iff(
        or(d14[FE + i] == Double.zero, d14[KI + i] < 0), 0, d14[FE + i] + (d14[HA + i] - d14[FE + i]) * d14[KI + i])
    }
    // El cons for harm op and stby not covered by plant outside of harm op period
    // NB=IF(KI3<0,$G3+FK3,FK3+(HG3-FK3)*KI3)
    for i in 0..<365 {
      d14[NB + i] = iff(
        d14[KI + i] < 0, d14[G + i] + d14[FK + i], d14[FK + i] + (d14[HG + i] - d14[FK + i]) * d14[KI + i])
    }
    /// el from BESS discharging outside of harm op period
    // ND=MN6*BESS_chrg_eff
    for i in 0..<365 { d14[ND + i] = d14[MN + i] * BESS_chrg_eff }
    // grid import for harm op+aux outside of harm op period
    // NC=IF(KI3<0,FA3,FA3+(GW3-FA3)*KI3)
    for i in 0..<365 {
      d14[NC + i] = iff(d14[KI + i] < 0, d14[FA + i], d14[FA + i] + (d14[GW + i] - d14[FA + i]) * d14[KI + i])
    }

    /// El available outside of harm op period after TES chrg
    // El available outside harm op period after harm op and TES chrg
    // NE=IF(KI3<0,FU3,FU3+(HQ3-FU3)*KI3)
    for i in 0..<365 {
      d14[NE + i] = iff(d14[KI + i] < 0, d14[FU + i], d14[FU + i] + (d14[HQ + i] - d14[FU + i]) * d14[KI + i])
    }
    // El to BESS charging outside harm op period
    // NH=IF(ND3>=NB3,0,MIN(BESS_cap_ud/BESS_chrg_eff,(NB3-ND3)/BESS_chrg_eff,IF(KI3<0,GA3,GA3+(HW3-GA3)*KI3)))
    for i in 0..<365 {
      d14[NH + i] = iff(
        d14[ND + i] >= d14[NB + i], 0,
        min(
          BESS_cap_ud / BESS_chrg_eff, (d14[NB + i] - d14[ND + i]) / BESS_chrg_eff,
          iff(d14[KI + i] < 0, d14[GA + i], d14[GA + i] + (d14[HW + i] - d14[GA + i]) * d14[KI + i])))
    }
    // Grid import needed outside of harm op period
    // NF=MIN(IF(KI3<0,GG3,GG3+(IC3-GG3)*KI3),MAX(0,NB3-NC3-ND3-NH3*BESS_chrg_eff))
    for i in 0..<365 {
      d14[NF + i] = min(
        iff(d14[KI + i] < 0, d14[GG + i], d14[GG + i] + (d14[IC + i] - d14[GG + i]) * d14[KI + i]),
        max(0, d14[NB + i] - d14[NC + i] - d14[ND + i] - d14[NH + i] * BESS_chrg_eff))
    }

    // heat cons not covered outside harm op period
    // NI=IF(KI3<0,$I3+FN3,FN3+(HJ3-FN3)*KI3)
    for i in 0..<365 {
      d14[NI + i] = iff(
        d14[KI + i] < 0, d14[I + i] + d14[FN + i], d14[FN + i] + (d14[HJ + i] - d14[FN + i]) * d14[KI + i])
    }

    // Heat available outside of harm op period after TES chrg
    // NJ=IF(KI3<0,FX3,FX3+(HT3-FX3)*KI3)
    for i in 0..<365 {
      d14[NJ + i] = iff(d14[KI + i] < 0, d14[FX + i], d14[FX + i] + (d14[HT + i] - d14[FX + i]) * d14[KI + i])
    }
    // /// heat cons for harm op during harm op period
    // MU=MIN(El_boiler_cap_ud*El_boiler_eff,MAX(0,NI3-NJ3))
    for i in 0..<365 { d14[MU + i] = min(El_boiler_cap_ud * El_boiler_eff, max(0, d14[NI + i] - d14[NJ + i])) }
    // MM=MU3/El_boiler_eff
    for i in 0..<365 { d14[MM + i] = d14[MU + i] / El_boiler_eff }
    /// Balance of heat outside of harm op period
    // NK=NJ3+MU3-NI3
    for i in 0..<365 { d14[NK + i] = d14[NJ + i] + d14[MU + i] - d14[NI + i] }
    /// Balance of electricity outside of harm op period
    // NG=NC6+ND6+NF6+NH6*BESS_chrg_eff-MAX(0,NH6-NE6)-NB6-MM6
    for i in 0..<365 {
      d14[NG + i] =
        d14[NC + i] + d14[ND + i] + d14[NF + i] + d14[NH + i] * BESS_chrg_eff
        - max(Double.zero, d14[NH + i] - d14[NE + i]) - d14[NB + i] - d14[MM + i]
    }
    // grid export
    // NM=MAX(0,MIN(MT3,IF(OR(KI3<0,KZ3<0),GC3,GB3+(HX3-GB3)*KI3+((GC3+(HY3-GC3)*KI3)-(GB3+(HX3-GB3)*KI3))*KZ3)))+MAX(0,MIN(NE3-NH3,IF(KI3<0,GD3,GD3+(HZ3-GD3)*KI3)))
    for i in 0..<365 {
      d14[NM + i] =
        max(
          0,
          min(
            d14[MT + i],
            iff(
              or(d14[KI + i] < 0, d14[KZ + i] < 0), d14[GC + i],
              d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[KI + i]
                + ((d14[GC + i] + (d14[HY + i] - d14[GC + i]) * d14[KI + i])
                  - (d14[GB + i] + (d14[HX + i] - d14[GB + i]) * d14[KI + i])) * d14[KZ + i])))
        + max(
          0,
          min(
            d14[NE + i] - d14[NH + i],
            iff(d14[KI + i] < 0, d14[GD + i], d14[GD + i] + (d14[HZ + i] - d14[GD + i]) * d14[KI + i])))
    }

    // Missing heat
    // NR=MAX(0,-MZ3)+MAX(0,-NK3)
    for i in 0..<365 { d14[NR + i] = max(0, -d14[MZ + i]) + max(0, -d14[NK + i]) }

    // Grid import
    // NN=MR3+NF3+NC3+MS3+(MAX(0,-MT3)+MAX(0,-NG3)+NR3/El_boiler_eff)*EDG_elec_cost_factor
    for i in 0..<365 {
      d14[NN + i] =
        d14[MR + i] + d14[NF + i] + d14[NC + i] + d14[MS + i]
        + (max(0, -d14[MT + i]) + max(0, -d14[NG + i]) + d14[NR + i] / El_boiler_eff) * EDG_elec_cost_factor
    }

    // Outside harmonious operation period op hours
    // NO=IF(KI3<0,0,$C3+($T3-$C3)*KI3)
    for i in 0..<365 { d14[NO + i] = iff(d14[KI + i] < 0, 0, d14[C + i] + (d14[T + i] - d14[C + i]) * d14[KI + i]) }
    // Harmonious operation period op hours
    // NP=IF(MK3=0,0,$D3+IF(KI3<0,0,($U3-$D3)*KI3))
    for i in 0..<365 {
      d14[NP + i] = iff(
        d14[MK + i] == Double.zero, 0, d14[D + i] + iff(d14[KI + i] < 0, 0, (d14[U + i] - d14[D + i]) * d14[KI + i]))
    }
    let AM: Int = 12775
    // Pure Methanol prod with night priority and resp day op
    // NL=IFERROR(((MAX(0,MK3/NP3-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethDist_harmonious_max_perc-MethDist_harmonious_min_perc)+MethDist_harmonious_min_perc)*NP3+IF(KI3<0,0,NO3*(($AM3-A_equiv_harmonious_min_perc)*KI3/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_MethDist_max_perc-A_MethDist_min_perc)+A_MethDist_min_perc)),0)*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      d14[NL + i] =
        ifFinite(
          ((max(0, d14[MK + i] / d14[NP + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
            * (MethDist_harmonious_max_perc - MethDist_harmonious_min_perc) + MethDist_harmonious_min_perc) * d14[NP + i]
            + iff(
              d14[KI + i] < 0, 0,
              d14[NO + i]
                * ((d14[AM + i] - equiv_harmonious_min_perc[j]) * d14[KI + i] / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (MethDist_max_perc[j] - MethDist_min_perc[j]) + MethDist_min_perc[j])), 0) * MethDist_Meth_nom_prod_ud
      assert(d14[NL + i] >= 0)
    }
    // PB operating hours
    // NQ=IF(KI3<0,0,$E3+($V3-$E3)*KI3)
    for i in 0..<365 { d14[NQ + i] = iff(d14[KI + i] < 0, 0, d14[E + i] + (d14[V + i] - d14[E + i]) * d14[KI + i]) }
  }
}
