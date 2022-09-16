extension TunOl {
  func d13(_ d13: inout [Double], case j: Int, d10: [Double], d11: [Double], d12: [Double]) {
    let (Z, AA, AB, AC, AD, AE, AF, AG, AH, AI, AM) = (8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775)  // d1

    let (FS, FT, FV, FW, FY, FZ, GE, GF, GG, GH, GI, GK, GL, GN, GO, GQ, GR) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d5

    let (HO, HP, HR, HS, HU, HV, IA, IB, IC, ID, IE, IG, IH, IJ, IK, IM, IN) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d6

    let FK: Int = 4380
    let HG: Int = 4380
    let GA: Int = 10220
    /// Surplus harm op period electricity after min harm op and min night op prep
    let IQ = 0
    // =FS6+GE6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IQ + i] =
        d11[FS + i] + d11[GE + i] - d10[Z + i] - min(d11[GH + i], max(0, d10[AB + i] - d11[FV + i]) / El_boiler_eff) - min(
          BESS_cap_ud, max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    let HW: Int = 10220
    /// Surplus harm op period electricity after min harm op and max night op prep
    let IR = 365
    // =HO6+IA6-$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IR + i] =
        d12[HO + i] + d12[IA + i] - d10[AA + i] - min(d12[ID + i], max(0, d10[AC + i] - d12[HR + i]) / El_boiler_eff) - min(
          BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let IS = 730
    // =FT6+GF6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IS + i] =
        d11[FT + i] + d11[GF + i] - d10[Z + i] - min(d11[GI + i], max(0, d10[AB + i] - d11[FW + i]) / El_boiler_eff) - min(
          BESS_cap_ud, max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let IT = 1095
    // =FV6+MIN(GH6,MAX(0,FS6+GE6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      d13[IT + i] =
        d11[FV + i] + min(
          d11[GH + i], max(0, d11[FS + i] + d11[GE + i] - d10[Z + i] - min(BESS_cap_ud, max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))
        * El_boiler_eff - d10[AB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let IU = 1460
    // =HR6+MIN(ID6,MAX(0,HO6+IA6-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6
    for i in 0..<365 {
      d13[IU + i] =
        d12[HR + i] + min(
          d12[ID + i], max(0, d12[HO + i] + d12[IA + i] - d10[AA + i] - min(BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff))
        * El_boiler_eff - d10[AC + i]
    }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let IV = 1825
    // =FW6+MIN(GI6,MAX(0,FT6+GF6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      d13[IV + i] =
        d11[FW + i] + min(
          d11[GI + i], max(0, d11[FT + i] + d11[GF + i] - d10[Z + i] - min(BESS_cap_ud, max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))
        * El_boiler_eff - d10[AB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let IW = 2190
    // =GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 { d13[IW + i] = d11[GH + i] - max(0.0, d10[AB + i] - d11[FV + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep
    let IX = 2555
    // =ID6-MAX(0,$AC6-HR6)/El_boiler_eff
    for i in 0..<365 { d13[IX + i] = d12[ID + i] - max(0.0, d10[AC + i] - d12[HR + i]) / El_boiler_eff }

    /// Surplus el boiler cap after max harm op and min night op prep
    let IY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 { d13[IY + i] = d11[GI + i] - max(0.0, d10[AB + i] - d11[FW + i]) / El_boiler_eff }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let IZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let JA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let JB = 4015

    for i in 0..<365 {
      // =FY6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
      d13[IZ + i] = d11[FY + i] - min(BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =HU6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff
      d13[JA + i] = d12[HU + i] - min(BESS_cap_ud, max(0.0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =FZ6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
      d13[JB + i] = d11[FZ + i] - min(BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }

    /// Surplus Grid input cap after min harm op and min night op prep
    let JC = 4380
    /// =GE6-MAX(0,-(FS6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[JC + i] =
        d11[GE + i]
        - max(
          0.0,
          -(d11[FS + i] - d10[Z + i] - min(d11[GH + i], max(0, d10[AB + i] - d11[FV + i]) / El_boiler_eff) - min(
            BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))
    }

    ///	Surplus grid import cap after min harm op and max night op prep
    let JD = 4745
    /// =IA6-MAX(0,-(HO6+$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))
    for i in 0..<365 {
      //  let equiv_harmonious = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]
      d13[JD + i] =
        d12[IA + i]
        - max(
          0,
          -(d12[HO + i] + d10[AA + i] - min(d12[ID + i], max(0, d10[AC + i] - d12[HR + i]) / El_boiler_eff) - min(
            BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff))

    }
    /// Surplus grid import cap after max harm op and min night op prep
    let JE = 5110
    /// =GF6-MAX(0,-(FT6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))
    for i in 0..<365 {
      d13[JE + i] =
        d11[GF + i]
        - max(
          0.0,
          -(d11[FT + i] - d10[Z + i] - min(d11[GI + i], max(0, d10[AB + i] - d11[FW + i]) / El_boiler_eff) - min(
            BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))
    }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let JF = 5475
    // JF=GK6-$AD6
    for i in 0..<365 { d13[JF + i] = d11[GK + i] - d10[AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let JG = 5840
    // =IG6-$AE6
    for i in 0..<365 { d13[JG + i] = d12[IG + i] - d10[AE + i] }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let JH = 6205
    // JH=GL6-$AD6
    for i in 0..<365 { d13[JH + i] = d11[GL + i] - d10[AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let JI = 6570
    // JI=GN6-$AF6
    for i in 0..<365 { d13[JI + i] = d11[GN + i] - d10[AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let JJ = 6935
    // JJ=IJ6-$AG6
    for i in 0..<365 { d13[JJ + i] = d12[IJ + i] - d10[AG + i] }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let JK = 7300
    // JK=GO6-$AF6
    for i in 0..<365 { d13[JK + i] = d11[GO + i] - d10[AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let JL = 7665
    // JL=GQ6-$AH6
    for i in 0..<365 { d13[JL + i] = d11[GQ + i] - d10[AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let JM = 8030
    // JM=IM6-$AI6
    for i in 0..<365 { d13[JM + i] = d12[IM + i] - d10[AI + i] }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let JN = 8395
    // JN=GR6-$AH6
    for i in 0..<365 { d13[JN + i] = d11[GR + i] - d10[AH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let JP = 8760
    let AM0 = 12775
    // JP=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d13[JP + i] = iff(
        or(d10[AM0 + i].isZero, d13[IQ + i] < 0, d13[IT + i] < 0, d13[IW + i] < 0, d13[IZ + i] < 0, d13[JC + i] < 0, d13[JF + i] < 0, d13[JI + i] < 0, d13[JL + i] < 0), 0,
        min(
          1, ifFinite(d13[IQ + i] / max(0, d13[IQ + i] - d13[IS + i]), 1), ifFinite(d13[IT + i] / max(0, d13[IT + i] - d13[IV + i]), 1),
          ifFinite(d13[IW + i] / max(0, d13[IW + i] - d13[IY + i]), 1), ifFinite(d13[IZ + i] / max(0, d13[IZ + i] - d13[JB + i]), 1),
          ifFinite(d13[JC + i] / max(0, d13[JC + i] - d13[JE + i]), 1), ifFinite(d13[JF + i] / max(0, d13[JF + i] - d13[JH + i]), 1),
          ifFinite(d13[JI + i] / max(0, d13[JI + i] - d13[JK + i]), 1), ifFinite(d13[JL + i] / max(0, d13[JL + i] - d13[JN + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    let dJP = 26280  // let LN = 26280
    for i in 0..<365 { d13[dJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (d13[JP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let JQ = 9125
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JQ + i] = iff(
        d13[JP + i].isZero, 0.0,
        round(
          (d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dJP + i]) + (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dJP + i]) - d10[Z + i]
            - min((d11[GH + i] + (d11[GI + i] - d11[GH + i]) * d13[dJP + i]), max(0.0, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dJP + i])) / El_boiler_eff)
            - min(BESS_cap_ud, max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let JR = 9490
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JR + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          (d12[HO + i] + (d12[HP + i] - d12[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))
            + (d12[IA + i] + (d12[IB + i] - d12[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) - d10[AA + i]
            - min(
              (d12[ID + i] + (d12[IE + i] - d12[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)),
              max(
                0,
                d10[AC + i]
                  - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)))
                / El_boiler_eff) - min(BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let JS = 9855
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6,5))
    for i in 0..<365 {
      d13[JS + i] = iff(
        d13[JP + i].isZero, 0.0,
        round(
          (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dJP + i]) + min(
            (d11[GH + i] + (d11[GI + i] - d11[GH + i]) * d13[dJP + i]),
            max(0.0, (d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dJP + i]) + (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dJP + i]) - d10[Z + i]) * El_boiler_eff
              - min(
                (d11[FY + i] + (d11[FZ + i] - d11[FY + i]) * d13[dJP + i]), min(BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))
            * El_boiler_eff - d10[AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let JT = 10220
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6,5))
    for i in 0..<365 {
      d13[JT + i] = iff(
        d13[JP + i].isZero, 0.0,
        round(
          (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) + min(
            d12[ID + i] + (d12[IE + i] - d12[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc),
            max(
              0,
              (d12[HO + i] + (d12[HP + i] - d12[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))
                + (d12[IA + i] + (d12[IB + i] - d12[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))
                - d10[AA + i] - min(BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d10[AC + i], 5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let JU = 10585
    // JU=IF(JP6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JU + i] = iff(
        d13[JP + i].isZero, 0.0,
        round((d11[GH + i] + (d11[GI + i] - d11[GH + i]) * d13[dJP + i]) - max(0.0, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dJP + i])) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let JV = 10950
    // JV=IF(JP6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JV + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          (d12[ID + i] + (d12[IE + i] - d12[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) - max(
            0,
            d10[AC + i] - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)))
            / El_boiler_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let JW = 11315
    // JW=IF(JP6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JW + i] = iff(
        d13[JP + i].isZero, 0.0,
        round(
          (d11[FY + i] + (d11[FZ + i] - d11[FY + i]) * d13[dJP + i]) - min(El_boiler_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5)
      )
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let JX = 11680
    // JX=IF(JP6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JX + i] = iff(
        d13[JP + i].isZero, 0.0,
        round(
          (d12[HU + i] + (d12[HV + i] - d12[HU + i]) * d13[dJP + i]) - min(El_boiler_cap_ud, max(0.0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5)
      )
    }

    /// Surplus grid import cap after opt day harm and min night op prep
    let JY = 12045
    // JY=IF(JP6=0,0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MIN(Grid_import_max_ud*Grid_import_yes_no_PB_strategy,MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d13[JY + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dJP + i])
            - min(
              Grid_import_max_ud * Grid_import_yes_no_PB_strategy,
              max(
                0.0,
                -((d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dJP + i]) - d10[Z + i]
                  - min(
                    (d11[GH + i] + (d11[GI + i] - d11[GH + i]) * d13[dJP + i]), max(0.0, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dJP + i])) / El_boiler_eff)
                  - min(BESS_cap_ud, max(0.0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff))), 5))
    }

    /// Surplus grid import cap after opt day harm and max night op prep
    let JZ = 12410
    // JZ=IF(JP6=0,0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MIN(Grid_import_max_ud*Grid_import_yes_no_PB_strategy,MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d13[JZ + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          (d12[IA + i] + (d12[IB + i] - d12[IA + i]) * d13[dJP + i])
            - min(
              Grid_import_max_ud * Grid_import_yes_no_PB_strategy,
              max(
                0,
                -((d12[HO + i] + (d12[HP + i] - d12[HO + i]) * d13[dJP + i]) - d10[AA + i]
                  - min(
                    (d12[ID + i] + (d12[IE + i] - d12[ID + i]) * d13[dJP + i]), max(0, d10[AC + i] - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) * d13[dJP + i])) / El_boiler_eff)
                  - min(BESS_cap_ud, max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let KA = 12775
    // KA=IF(JP6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AD6,5))
    for i in 0..<365 {
      d13[KA + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          d11[GK + i] + (d11[GL + i] - d11[GK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d10[AD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let KB = 13140
    // KB=IF(JP6=0,0,ROUND(IG6+(IH6-IG6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AE6,5))
    for i in 0..<365 {
      d13[KB + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          d12[IG + i] + (d12[IH + i] - d12[IG + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d10[AE + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let KC = 13505
    // KC=IF(JP6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AF6,5))
    for i in 0..<365 {
      d13[KC + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          d11[GN + i] + (d11[GO + i] - d11[GN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d10[AF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let KD = 13870
    // KD=IF(JP6=0,0,ROUND(IJ6+(IK6-IJ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AG6,5))
    for i in 0..<365 {
      d13[KD + i] = iff(
        d13[JP + i].isZero, 0,
        round(
          d12[IJ + i] + (d12[IK + i] - d12[IJ + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d10[AG + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let KE = 14235
    // KE=IF(JP6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AH6,5))
    for i in 0..<365 { d13[KE + i] = iff(d13[JP + i].isZero, 0.0, round((d11[GQ + i] + (d11[GR + i] - d11[GQ + i]) * d13[dJP + i]) - d10[AH + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let KF = 14600
    // KF=IF(JP6=0,0,ROUND(IM6+(IN6-IM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AI6,5))
    for i in 0..<365 { d13[KF + i] = iff(d13[JP + i].isZero, 0.0, round(d12[IM + i] + (d12[IN + i] - d12[IM + i]) * d13[dJP + i] - d10[AI + i], 5)) }

    /// Opt night prep during day prio operation
    let KG = 14965
    // KG=IF(OR($AM6=0,JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[KG + i] = iff(
        or(
          d10[AM + i].isZero, d13[JP + i].isZero, d13[JQ + i] < 0, d13[JS + i] < 0, d13[JU + i] < 0, d13[JW + i] < 0, d13[JY + i] < 0, d13[KA + i] < 0, d13[KC + i] < 0,
          d13[KE + i] < 0), 0,
        min(
          1, ifFinite(d13[JQ + i] / max(0, d13[JQ + i] - d13[JR + i]), 1), ifFinite(d13[JS + i] / max(0, d13[JS + i] - d13[JT + i]), 1),
          ifFinite(d13[JU + i] / max(0, d13[JU + i] - d13[JV + i]), 1), ifFinite(d13[JW + i] / max(0, d13[JW + i] - d13[JX + i]), 1),
          ifFinite(d13[JY + i] / max(0, d13[JY + i] - d13[JZ + i]), 1), ifFinite(d13[KA + i] / max(0, d13[KA + i] - d13[KB + i]), 1),
          ifFinite(d13[KC + i] / max(0, d13[KC + i] - d13[KD + i]), 1), ifFinite(d13[KE + i] / max(0, d13[KE + i] - d13[KF + i]), 1))
          * (d10[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let KI = 15330
    // KI=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[KI + i] = iff(
        or(d10[AM + i].isZero, d13[IQ + i] < 0, d13[IT + i] < 0, d13[IW + i] < 0, d13[IZ + i] < 0, d13[JC + i] < 0, d13[JF + i] < 0, d13[JI + i] < 0, d13[JL + i] < 0), 0,
        min(
          1,
          ifFinite(d13[IQ + i] / max(0, d13[IQ + i] - d13[IR + i]), 1),
          ifFinite(d13[IT + i] / max(0, d13[IT + i] - d13[IU + i]), 1),
          ifFinite(d13[IW + i] / max(0, d13[IW + i] - d13[IX + i]), 1),
          ifFinite(d13[IZ + i] / max(0, d13[IZ + i] - d13[JA + i]), 1),
          ifFinite(d13[JC + i] / max(0, d13[JC + i] - d13[JD + i]), 1),
          ifFinite(d13[JF + i] / max(0, d13[JF + i] - d13[JG + i]), 1),
          ifFinite(d13[JI + i] / max(0, d13[JI + i] - d13[JJ + i]), 1),
          ifFinite(d13[JL + i] / max(0, d13[JL + i] - d13[JM + i]), 1))
          * (d10[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    let AMKG = 23360  // let LF = 23360

    let AMKI = 38690  // let MW = 38690
    for i in 0..<365 {
      d13[AMKG + i] = (d10[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KG + i] - equiv_harmonious_min_perc[j]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
      d13[AMKI + i] = (d10[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KI + i] - equiv_harmonious_min_perc[j]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let KJ = 15695
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KJ + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKI + i]) + (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKI + i])
            - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i])
            - min(
              (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]),
              max(0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud,
              max(
                0.0,
                (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])
                  - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let KK = 16060
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KK + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[AMKI + i]) + (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[AMKI + i])
            - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i])
            - min(
              (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]),
              max(0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud,
              max(
                0.0,
                (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])
                  - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let KL = 16425
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KL + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i])
            + min(
              (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]),
              (max(
                0.0,
                (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKI + i]) + (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKI + i])
                  - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i]))) * El_boiler_eff)
            - min(
              (d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[AMKI + i]),
              min(BESS_cap_ud, max(0.0, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])) / BESS_chrg_eff)
            ) - (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let KM = 16790
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KM + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKI + i])
            + min(
              (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]),
              (max(
                0.0,
                (d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[AMKI + i]) + (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[AMKI + i])
                  - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i]))) * El_boiler_eff
                - min(
                  (d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[AMKI + i]),
                  min(BESS_cap_ud, max(0.0, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])))
                    / BESS_chrg_eff)) - (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let KN = 17155
    // KN=IF(KI6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KN + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]) - max(
            0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i])) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let KO = 17520
    // KO=IF(KI6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KO + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[AMKI + i]) - max(
            0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKI + i])) / El_boiler_eff, 5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let KP = 17885
    // KP=IF(KI6=0,0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KP + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FY + i] + (d12[HU + i] - d11[FY + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - max(
            0.0,
            (d11[FK + i] + (d12[HG + i] - d11[FK + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
              - min(
                BESS_cap_ud,
                (d11[GG + i] + (d12[IC + i] - d11[GG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
                  - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let KQ = 18250
    // KQ=IF(KI6=0,0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KQ + i] = iff(
        d13[KI + i].isZero, 0.0,
        round(
          (d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - max(
            0.0,
            (d11[FK + i] + (d12[HG + i] - d11[FK + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
              - min(
                BESS_cap_ud,
                (d11[GG + i] + (d12[IC + i] - d11[GG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
                  - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }

    /// Surplus grid import cap after min day harmonious and opti night op prep
    let KR = 18615
    // KR=IF(KI6=0,0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(Grid_import_max_ud*Grid_import_yes_no_PB_strategy,MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d13[KR + i] = iff(
        d13[KI + i].isZero, 0,
        round(
          (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[AMKI + i])
            - min(
              Grid_import_max_ud * Grid_import_yes_no_PB_strategy,
              max(
                0.0,
                -((d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[AMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i])
                  - min(
                    (d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[AMKI + i]),
                    max(0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
                    BESS_cap_ud,
                    max(
                      0,
                      (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])
                        - (d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[AMKI + i]) * BESS_chrg_eff)) / BESS_chrg_eff))), 5))
    }

    /// Surplus grid import cap after max day harmonious and opti night op prep
    let KS = 18980
    // KS=IF(KI6=0,0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(Grid_import_max_ud*Grid_import_yes_no_PB_strategy,MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d13[KS + i] = iff(
        d13[KI + i].isZero, 0,
        round(
          (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[AMKI + i])
            - min(
              Grid_import_max_ud * Grid_import_yes_no_PB_strategy,
              max(
                0.0,
                -((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[AMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[AMKI + i])
                  - min(
                    (d11[GI + i] + (d12[IR + i] - d11[GI + i]) * d13[AMKI + i]),
                    max(0.0, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[AMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
                    BESS_cap_ud,
                    max(
                      0,
                      (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[AMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[AMKI + i])
                        - (d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[AMKI + i]) * BESS_chrg_eff)) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let KT = 19345
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KT + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GK + i] + (d12[IG + i] - d11[GK + i]) * d13[AMKI + i]) - (d10[AD + i] + (d10[AE + i] - d10[AD + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let KU = 19710
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KU + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GL + i] + (d12[IH + i] - d11[GL + i]) * d13[AMKI + i]) - (d10[AD + i] + (d10[AE + i] - d10[AD + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let KV = 20075
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KV + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GN + i] + (d12[IJ + i] - d11[GN + i]) * d13[AMKI + i]) - (d10[AF + i] + (d10[AG + i] - d10[AF + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let KW = 20440
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KW + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GO + i] + (d12[IK + i] - d11[GO + i]) * d13[AMKI + i]) - (d10[AF + i] + (d10[AG + i] - d10[AF + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let KX = 20805
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KX + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GQ + i] + (d12[IM + i] - d11[GQ + i]) * d13[AMKI + i]) - (d10[AH + i] + (d10[AI + i] - d10[AH + i]) * d13[AMKI + i]), 5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let KY = 21170
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KY + i] = iff(
        d13[KI + i].isZero, 0.0, round((d11[GR + i] + (d12[IN + i] - d11[GR + i]) * d13[AMKI + i]) - (d10[AH + i] + (d10[AI + i] - d10[AH + i]) * d13[AMKI + i]), 5))
    }

    /// Opt harm op period op during night prio operation
    let KZ = 21535
    // KZ=IF(OR(JP6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d13[KZ + i] = iff(
        or(d13[JP + i].isZero, d13[KJ + i] < 0, d13[KL + i] < 0, d13[KN + i] < 0, d13[KP + i] < 0, d13[KR + i] < 0, d13[KT + i] < 0, d13[KV + i] < 0, d13[KX + i] < 0), 0,
        min(
          1, ifFinite(d13[KJ + i] / max(0, d13[KJ + i] - d13[KK + i]), 1), ifFinite(d13[KL + i] / max(0, d13[KL + i] - d13[KM + i]), 1),
          ifFinite(d13[KN + i] / max(0, d13[KN + i] - d13[KO + i]), 1), ifFinite(d13[KP + i] / max(0, d13[KP + i] - d13[KQ + i]), 1),
          ifFinite(d13[KR + i] / max(0, d13[KR + i] - d13[KS + i]), 1), ifFinite(d13[KT + i] / max(0, d13[KT + i] - d13[KU + i]), 1),
          ifFinite(d13[KV + i] / max(0, d13[KV + i] - d13[KW + i]), 1), ifFinite(d13[KX + i] / max(0, d13[KX + i] - d13[KY + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }
  }
}
