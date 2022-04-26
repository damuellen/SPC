extension TunOl {
  func d17(_ d7: inout [Double], case j: Int, d1: [Double], d5: [Double], d6: [Double]) {
    let (Z, AA, AB, AC, AD, AE, AF, AG, AH, AI, AM) = (8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775)  // d1

    let (FS, FT, FV, FW, FY, FZ, GE, GF, GG, GH, GI, GK, GL, GN, GO, GQ, GR) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d5

    let (HO, HP, HR, HS, HU, HV, IA, IB, IC, ID, IE, IG, IH, IJ, IK, IM, IN) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d6

    let FK = 4380
    let HG = 4380

    /// Surplus harm op period electricity after min harm op and min night op prep
    let ddIQ = 0
    // =FS6+GE6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff)
    for i in 0..<365 { d7[ddIQ + i] = d5[FS + i] + d5[GE + i] - d1[Z + i] - max(.zero, d1[AB + i] - d5[FV + i]) / El_boiler_eff - min(d5[FY + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff) }

    let equiv_harmonious_range = (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    let ddAM = 30295  // let ddLY = 30295
    for i in 0..<365 { d7[ddAM + i] = equiv_harmonious_range < 1E-10 ? 1 : (d1[AM + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range }

    /// Surplus harm op period electricity after min harm op and max night op prep
    let ddIR = 365
    // =HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff)
    for i in 0..<365 { d7[ddIR + i] = d6[HO + i] + d6[IA + i] - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[ddAM + i]) - max(0, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) - d6[HR + i]) / El_boiler_eff - min(d6[HU + i], max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff) }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let ddIS = 730
    // =FT6+GF6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff)
    for i in 0..<365 { d7[ddIS + i] = d5[FT + i] + d5[GF + i] - d1[Z + i] - max(.zero, d1[AB + i] - d5[FW + i]) / El_boiler_eff - min(d5[FZ + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff) }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let ddIT = 1095
    // =FV6+MAX(0,FS6+GE6-$Z6-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 { d7[ddIT + i] = d5[FV + i] + max(.zero, d5[FS + i] + d5[GE + i] - d1[Z + i] - min(d5[FY + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff)) * El_boiler_eff - d1[AB + i] }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let ddIU = 1460
    // =HR6+MAX(0,HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddIU + i] = d6[HR + i] + max(.zero, d6[HO + i] + d6[IA + i] - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[ddAM + i]) - min(d6[HU + i], max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff)) * El_boiler_eff - (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let ddIV = 1825
    // =FW6+MAX(0,FT6+GF6-Z6-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 { d7[ddIV + i] = d5[FW + i] + max(.zero, d5[FT + i] + d5[GF + i] - d1[Z + i] - min(d5[FZ + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff)) * El_boiler_eff - d1[AB + i] }

    /// Surplus el boiler cap after min harm op and min night op prep
    let ddIW = 2190
    // GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 { d7[ddIW + i] = d5[GH + i] - max(.zero, d1[AB + i] - d5[FV + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep
    let ddIX = 2555
    // ID6-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 { d7[ddIX + i] = d6[ID + i] - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) - d6[HR + i]) / El_boiler_eff }

    /// Surplus el boiler cap after max harm op and min night op prep
    let ddIY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 { d7[ddIY + i] = d5[GI + i] - max(.zero, (d1[AB + i] - d5[FW + i]) / El_boiler_eff) }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let ddIZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let ddJA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let ddJB = 4015

    for i in 0..<365 {
      // FY6-MAX(0,FK6-GG6)/BESS_chrg_eff
      d7[ddIZ + i] = d5[FY + i] - max(.zero, d5[FK + i] - d5[GG + i]) / BESS_chrg_eff
      // HU6-MAX(0,HG6-IC6)/BESS_chrg_eff
      d7[ddJA + i] = d6[HU + i] - max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff
      // FZ6-MAX(0,FK6-GG6)/BESS_chrg_eff
      d7[ddJB + i] = d5[FZ + i] - max(.zero, d5[FK + i] - d5[GG + i]) / BESS_chrg_eff
    }

    /// Surplus Grid input cap after min harm op and min night op prep
    let ddJC = 4380
    /// =GE6-MAX(0,-(FS6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff)))
    for i in 0..<365 { d7[ddJC + i] = d5[GE + i] - max(.zero, -(d5[FS + i] - d1[Z + i] - max(0, d1[AB + i] - d5[FV + i]) / El_boiler_eff - min(d5[FY + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff))) }

    ///	Surplus grid import cap after min harm op and max night op prep
    let ddJD = 4745
    /// =IA6-MAX(0,-(HO6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff)))
    for i in 0..<365 {
      //  let equiv_harmonious = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]
      d7[ddJD + i] = d6[IA + i] - max(.zero, -(d6[HO + i] - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[ddAM + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) - d6[HR + i]) / El_boiler_eff - min(d6[HU + i], max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after max harm op and min night op prep
    let ddJE = 5110
    /// =GF6-MAX(0,-(FT6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff)))
    for i in 0..<365 { d7[ddJE + i] = d5[GF + i] - max(.zero, -(d5[FT + i] - d1[Z + i] - max(0, d1[AB + i] - d5[FW + i]) / El_boiler_eff - min(d5[FZ + i], max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff))) }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let ddJF = 5475
    // JF=GK6-$AD6
    for i in 0..<365 { d7[ddJF + i] = d5[GK + i] - d1[AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let ddJG = 5840
    // JG=IG6-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddJG + i] = d6[IG + i] - (d1[AD + i] + (d1[AE + i] - d1[AD + i]) * d7[ddAM + i]) }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let ddJH = 6205
    // JH=GL6-$AD6
    for i in 0..<365 { d7[ddJH + i] = d5[GL + i] - d1[AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let ddJI = 6570
    // JI=GN6-$AF6
    for i in 0..<365 { d7[ddJI + i] = d5[GN + i] - d1[AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let ddJJ = 6935
    // JJ=IJ6-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddJJ + i] = d6[IJ + i] - (d1[AF + i] + (d1[AG + i] - d1[AF + i]) * d7[ddAM + i]) }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let ddJK = 7300
    // JK=GO6-$AF6
    for i in 0..<365 { d7[ddJK + i] = d5[GO + i] - d1[AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let ddJL = 7665
    // JL=GQ6-$AH6
    for i in 0..<365 { d7[ddJL + i] = d5[GQ + i] - d1[AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let ddJM = 8030
    // JM=IM6-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { d7[ddJM + i] = d6[IM + i] - (d1[AH + i] + (d1[AI + i] - d1[AH + i]) * d7[ddAM + i]) }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let ddJN = 8395
    // JN=GR6-$AH6
    for i in 0..<365 { d7[ddJN + i] = d5[GR + i] - d1[AH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let ddJP = 8760
    // JP=IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d7[ddJP + i] = iff(
        or(d7[ddIQ + i] < .zero, d7[ddIT + i] < .zero, d7[ddIW + i] < .zero, d7[ddIZ + i] < .zero, d7[ddJC + i] < .zero, d7[ddJF + i] < .zero, d7[ddJI + i] < .zero, d7[ddJL + i] < .zero), .zero,
        min(
          1, ifFinite(d7[ddIQ + i] / max(0, d7[ddIQ + i] - d7[ddIS + i]), 1), ifFinite(d7[ddIT + i] / max(0, d7[ddIT + i] - d7[ddIV + i]), 1), ifFinite(d7[ddIW + i] / max(0, d7[ddIW + i] - d7[ddIY + i]), 1), ifFinite(d7[ddIZ + i] / max(0, d7[ddIZ + i] - d7[ddJB + i]), 1),
          ifFinite(d7[ddJC + i] / max(0, d7[ddJC + i] - d7[ddJE + i]), 1), ifFinite(d7[ddJF + i] / max(0, d7[ddJF + i] - d7[ddJH + i]), 1), ifFinite(d7[ddJI + i] / max(0, d7[ddJI + i] - d7[ddJK + i]), 1), ifFinite(d7[ddJL + i] / max(0, d7[ddJL + i] - d7[ddJN + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }
    let dddJP = 26280  // let ddLN = 26280
    for i in 0..<365 { d7[dddJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (d7[ddJP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let ddJQ = 9125
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff),5))
    for i in 0..<365 {
      d7[ddJQ + i] = iff(
        d7[ddJP + i].isZero, .zero,
        round(
          (d5[FS + i] + (d5[FT + i] - d5[FS + i]) * d7[dddJP + i]) + (d5[GE + i] + (d5[GF + i] - d5[GE + i]) * d7[dddJP + i]) - d1[Z + i] - max(.zero, d1[AB + i] - (d5[FV + i] + (d5[FW + i] - d5[FV + i]) * d7[dddJP + i])) / El_boiler_eff
            - min((d5[FY + i] + (d5[FZ + i] - d5[FY + i]) * d7[dddJP + i]), max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let ddJR = 9490
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff),5))
    for i in 0..<365 {
      d7[ddJR + i] = iff(
        d7[ddJP + i].isZero, .zero,
        round(
          (d6[HO + i] + (d6[HP + i] - d6[HO + i]) * d7[dddJP + i]) + (d6[IA + i] + (d6[IB + i] - d6[IA + i]) * d7[dddJP + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[ddAM + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) - (d6[HR + i] + (d6[HS + i] - d6[HR + i]) * d7[dddJP + i])) / El_boiler_eff
            - min((d6[HU + i] + (d6[HV + i] - d6[HU + i]) * d7[dddJP + i]), max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let ddJS = 9855
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6)*El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff)-$AB6,5))
    for i in 0..<365 {
      d7[ddJS + i] = iff(
        d7[ddJP + i].isZero, .zero,
        round(
          (d5[FV + i] + (d5[FW + i] - d5[FV + i]) * d7[dddJP + i]) + max(.zero, (d5[FS + i] + (d5[FT + i] - d5[FS + i]) * d7[dddJP + i]) + (d5[GE + i] + (d5[GF + i] - d5[GE + i]) * d7[dddJP + i]) - d1[Z + i]) * El_boiler_eff
            - min((d5[FY + i] + (d5[FZ + i] - d5[FY + i]) * d7[dddJP + i]), max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff) - d1[AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let ddJT = 10220
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)))*El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d7[ddJT + i] = iff(
        d7[ddJP + i].isZero, .zero,
        round(
          (d6[HR + i] + (d6[HS + i] - d6[HR + i]) * d7[dddJP + i]) + max(.zero, (d6[HO + i] + (d6[HP + i] - d6[HO + i]) * d7[dddJP + i]) + (d6[IA + i] + (d6[IB + i] - d6[IA + i]) * d7[dddJP + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[ddAM + i])) * El_boiler_eff
            - min((d6[HU + i] + (d6[HV + i] - d6[HU + i]) * d7[dddJP + i]), max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff) - (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]), 5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let ddJU = 10585
    // JU=IF(JP6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[ddJU + i] = iff(d7[ddJP + i].isZero, .zero, round((d5[GH + i] + (d5[GI + i] - d5[GH + i]) * d7[dddJP + i]) - max(.zero, d1[AB + i] - (d5[FV + i] + (d5[FW + i] - d5[FV + i]) * d7[dddJP + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let ddJV = 10950
    // JV=IF(JP6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[ddJV + i] = iff(d7[ddJP + i].isZero, .zero, round((d6[ID + i] + (d6[IE + i] - d6[ID + i]) * d7[dddJP + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[ddAM + i]) - (d6[HR + i] + (d6[HS + i] - d6[HR + i]) * d7[dddJP + i])) / El_boiler_eff, 5)) }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let ddJW = 11315
    // JW=IF(JP6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,FK6-GG6)/BESS_chrg_eff,5))
    for i in 0..<365 { d7[ddJW + i] = iff(d7[ddJP + i].isZero, .zero, round((d5[FY + i] + (d5[FZ + i] - d5[FY + i]) / Overall_harmonious_range * (d7[ddJP + i] - Overall_harmonious_min_perc)) - max(.zero, d5[FK + i] - d5[GG + i]) / BESS_chrg_eff, 5)) }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let ddJX = 11680
    // JX=IF(JP6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,HG6-IC6)/BESS_chrg_eff,5))
    for i in 0..<365 { d7[ddJX + i] = iff(d7[ddJP + i].isZero, .zero, round((d6[HU + i] + (d6[HV + i] - d6[HU + i]) / Overall_harmonious_range * (d7[ddJP + i] - Overall_harmonious_min_perc)) - max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff, 5)) }

    /// Surplus grid import cap after opt day harm and min night op prep
    let ddJY = 12045
    // JY=IF(JP6=0,0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d7[ddJY + i] = iff(
        d7[ddJP + i].isZero, 0,
        round(
          (d5[GE + i] + (d5[GF + i] - d5[GE + i]) * d7[dddJP + i])
            - max(.zero, -((d5[FS + i] + (d5[FT + i] - d5[FS + i]) * d7[dddJP + i]) - d1[Z + i] - max(.zero, d1[AB + i] - (d5[FV + i] + (d5[FW + i] - d5[FV + i]) * d7[dddJP + i])) / El_boiler_eff - min((d5[FY + i] + (d5[FZ + i] - d5[FY + i]) * d7[dddJP + i]), max(.zero, d5[FK + i] - d6[GG + i]) / BESS_chrg_eff))), 5))
    }

    /// Surplus grid import cap after opt day harm and max night op prep
    let ddJZ = 12410
    // JZ=IF(JP6=0,0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff))),5))
    for i in 0..<365 {
      d7[ddJZ + i] = iff(
        d7[ddJP + i].isZero, .zero,
        round(
          (d6[IA + i] + (d6[IB + i] - d6[IA + i]) * d7[dddJP + i])
            - max(
              .zero,
              -((d6[HO + i] + (d6[HP + i] - d6[HO + i]) * d7[dddJP + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d1[AM + i] - equiv_harmonious_min_perc[j])) - max(
                .zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d1[AM + i] - equiv_harmonious_min_perc[j])) - (d6[HR + i] + (d6[HS + i] - d6[HR + i]) * d7[dddJP + i])) / El_boiler_eff
                - min((d6[HU + i] + (d6[HV + i] - d6[HU + i]) * d7[dddJP + i]), max(.zero, d6[HG + i] - d6[IC + i]) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let ddKA = 12775
    // KA=IF(JP6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AD6,5))
    for i in 0..<365 { d7[ddKA + i] = iff(d7[ddJP + i].isZero, .zero, round((d5[GK + i] + (d5[GL + i] - d5[GK + i]) * d7[dddJP + i]) - d1[AD + i], 5)) }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let ddKB = 13140
    // KB=IF(JP3=0;0;ROUND(IG3+(IH3-IG3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)-($AD3+($AE3-$AD3)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM3-A_equiv_harmonious_min_perc));5))
    for i in 0..<365 { d7[ddKB + i] = iff(d7[ddJP + i].isZero, .zero, round(d6[IG + i] + (d6[IH + i] - d6[IG + i]) * d7[dddJP + i] - (d1[AD + i] + (d1[AE + i] - d1[AD + i]) * d7[ddAM + i]), 5)) }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let ddKC = 13505
    // KC=IF(JP6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AF6,5))
    for i in 0..<365 { d7[ddKC + i] = iff(d7[ddJP + i].isZero, .zero, round((d5[GN + i] + (d5[GO + i] - d5[GN + i]) * d7[dddJP + i]) - d1[AF + i], 5)) }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let ddKD = 13870
    // KD=IF(JP3=0;0;ROUND(IJ3+(IK3-IJ3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)-($AF3+($AG3-$AF3)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM3-A_equiv_harmonious_min_perc));5))
    for i in 0..<365 { d7[ddKD + i] = iff(d7[ddJP + i].isZero, .zero, round(d6[IJ + i] + (d6[IK + i] - d6[IJ + i]) * d7[dddJP + i] - (d1[AF + i] + (d1[AG + i] - d1[AF + i]) * d7[ddAM + i]), 5)) }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let ddKE = 14235
    // KE=IF(JP6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AH6,5))
    for i in 0..<365 { d7[ddKE + i] = iff(d7[ddJP + i].isZero, .zero, round((d5[GQ + i] + (d5[GR + i] - d5[GQ + i]) * d7[dddJP + i]) - d1[AH + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let ddKF = 14600
    // KF=IF(JP3=0;0;ROUND(IM3+(IN3-IM3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP3-Overall_harmonious_min_perc)-($AH3+($AI3-$AH3)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM3-A_equiv_harmonious_min_perc));5))
    for i in 0..<365 { d7[ddKF + i] = iff(d7[ddJP + i].isZero, .zero, round(d6[IM + i] + (d6[IN + i] - d6[IM + i]) * d7[dddJP + i] - (d1[AH + i] + (d1[AI + i] - d1[AH + i]) * d7[ddAM + i]), 5)) }

    /// Opt night prep during day prio operation
    let ddKG = 14965
    // KG=IF(OR(JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d7[ddKG + i] = iff(
        or(d7[ddJP + i].isZero, d7[ddJQ + i] < .zero, d7[ddJS + i] < .zero, d7[ddJU + i] < .zero, d7[ddJW + i] < .zero, d7[ddJY + i] < .zero, d7[ddKA + i] < .zero, d7[ddKC + i] < .zero, d7[ddKE + i] < .zero), 0,
        min(
          1, ifFinite(d7[ddJQ + i] / max(0, d7[ddJQ + i] - d7[ddJR + i]), 1), ifFinite(d7[ddJS + i] / max(0, d7[ddJS + i] - d7[ddJT + i]), 1), ifFinite(d7[ddJU + i] / max(0, d7[ddJU + i] - d7[ddJV + i]), 1), ifFinite(d7[ddJW + i] / max(0, d7[ddJW + i] - d7[ddJX + i]), 1),
          ifFinite(d7[ddJY + i] / max(0, d7[ddJY + i] - d7[ddJZ + i]), 1), ifFinite(d7[ddKA + i] / max(0, d7[ddKA + i] - d7[ddKB + i]), 1), ifFinite(d7[ddKC + i] / max(0, d7[ddKC + i] - d7[ddKD + i]), 1), ifFinite(d7[ddKE + i] / max(0, d7[ddKE + i] - d7[ddKF + i]), 1)) * (d1[AM + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let ddKI = 15330
    // KI=IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d7[ddKI + i] = iff(
        or(d7[ddIQ + i] < .zero, d7[ddIT + i] < .zero, d7[ddIW + i] < .zero, d7[ddIZ + i] < .zero, d7[ddJC + i] < .zero, d7[ddJF + i] < .zero, d7[ddJI + i] < .zero, d7[ddJL + i] < .zero), 0,
        min(
          1, ifFinite(d7[ddIQ + i] / max(0, d7[ddIQ + i] - d7[ddIR + i]), 1), ifFinite(d7[ddIT + i] / max(0, d7[ddIT + i] - d7[ddIU + i]), 1), ifFinite(d7[ddIW + i] / max(0, d7[ddIW + i] - d7[ddIX + i]), 1), ifFinite(d7[ddIZ + i] / max(0, d7[ddIZ + i] - d7[ddJA + i]), 1),
          ifFinite(d7[ddJC + i] / max(0, d7[ddJC + i] - d7[ddJD + i]), 1), ifFinite(d7[ddJF + i] / max(0, d7[ddJF + i] - d7[ddJG + i]), 1), ifFinite(d7[ddJI + i] / max(0, d7[ddJI + i] - d7[ddJJ + i]), 1), ifFinite(d7[ddJL + i] / max(0, d7[ddJL + i] - d7[ddJM + i]), 1)) * (d1[AM + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }
    let ddAMKG = 23360  // let ddLF = 23360
    let dddKI = 25550  // let ddLL = 25550
    let ddAMKI = 38690  // let ddMW = 38690
    for i in 0..<365 {
      d7[dddKI + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (d7[ddKI + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j]
      d7[ddAMKG + i] = (d1[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d7[ddKG + i] - equiv_harmonious_min_perc[j]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
      d7[ddAMKI + i] = (d1[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d7[ddKI + i] - equiv_harmonious_min_perc[j]) / (d1[AM + i] - equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let ddKJ = 15695
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/BESS_chrg_eff),5))
    for i in 0..<365 {
      d7[ddKJ + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKI + i]) + (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKI + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[dddKI + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]) - (d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i])) / El_boiler_eff
            - min((d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let ddKK = 16060
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff),5))
    for i in 0..<365 {
      d7[ddKK + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FT + i] + (d6[HP + i] - d5[FT + i]) * d7[ddAMKI + i]) + (d5[GF + i] + (d6[IB + i] - d5[GF + i]) * d7[ddAMKI + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[dddKI + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]) - (d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKI + i])) / El_boiler_eff
            - min((d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let ddKL = 16425
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))*El_boiler_eff-MIN(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5)),5))
    for i in 0..<365 {
      d7[ddKL + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i]) + (max(.zero, (d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKI + i]) + (d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKI + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[dddKI + i]))) * El_boiler_eff
            - min((d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff) - (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let ddKM = 16790
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))*El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d7[ddKM + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKI + i]) + (max(.zero, (d5[FT + i] + (d6[HP + i] - d5[FT + i]) * d7[ddAMKI + i]) + (d5[GF + i] + (d6[IB + i] - d5[GF + i]) * d7[ddAMKI + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) * d7[dddKI + i]))) * El_boiler_eff
            - min((d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff) - (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]), 5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let ddKN = 17155
    // KN=IF(KI6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[ddKN + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GH + i] + (d6[ID + i] - d5[GH + i]) * d7[ddAMKI + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]) - (d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let ddKO = 17520
    // KO=IF(KI6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d7[ddKO + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GI + i] + (d6[IE + i] - d5[GI + i]) * d7[ddAMKI + i]) - max(.zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) * d7[dddKI + i]) - (d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKI + i])) / El_boiler_eff, 5)) }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let ddKP = 17885
    // KP=IF(KI6=0,0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d7[ddKP + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FY + i] + (d6[HU + i] - d5[FY + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - max(
            .zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let ddKQ = 18250
    // KQ=IF(KI6=0,0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d7[ddKQ + i] = iff(
        d7[ddKI + i].isZero, .zero,
        round(
          (d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - max(
            .zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) / (d1[AM + i] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j]))) / BESS_chrg_eff, 5))
    }

    /// Surplus grid import cap after min day harmonious and opti night op prep
    let ddKR = 18615
    // KR=IF(KI6=0,0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff))),5))
    for i in 0..<365 {

      let x1 = d5[GE + i] + (d6[IA + i] - d5[GE + i]) * d7[ddAMKI + i]
      let x2 = d5[FV + i] + (d6[HR + i] - d5[FV + i]) * d7[ddAMKI + i]
      let x3 = min((d5[FY + i] + (d6[HU + i] - d5[FY + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff)
      let x4 = d5[FS + i] + (d6[HO + i] - d5[FS + i]) * d7[ddAMKI + i]
      let x5 = d1[Z + i] + (d1[AA + i] - d1[Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])

      let x00 = d1[AB + i] + (d1[AC + i] - d1[AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])

      let x13 = (x4 - x5 - iff(x00 - x2 > 0, x00 - x2, 0) / El_boiler_eff - x3)

      d7[ddKR + i] = iff(d7[ddKI + i].isZero, .zero, round(x1 + iff(x13 < .zero, x13, .zero), 5))
    }

    /// Surplus grid import cap after max day harmonious and opti night op prep
    let ddKS = 18980
    // KS=IF(KI6=0,0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))),5))
    for i in 0..<365 {
      d7[ddKS + i] = iff(
        d7[ddKI + i].isZero, 0,
        round(
          (d5[GF + i] + (d6[IB + i] - d5[GF + i]) * d7[ddAMKI + i])
            - max(
              .zero,
              -((d5[FT + i] + (d6[HP + i] - d5[FT + i]) * d7[ddAMKI + i]) - (d1[Z + i] + (d1[AA + i] - d1[Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - max(
                .zero, (d1[AB + i] + (d1[AC + i] - d1[AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (d7[ddKI + i] - equiv_harmonious_min_perc[j])) - (d5[FW + i] + (d6[HS + i] - d5[FW + i]) * d7[ddAMKI + i])) / El_boiler_eff
                - min((d5[FZ + i] + (d6[HV + i] - d5[FZ + i]) * d7[ddAMKI + i]), max(.zero, (d5[FK + i] + (d6[HG + i] - d5[FK + i]) * d7[ddAMKI + i]) - (d5[GG + i] + (d6[IC + i] - d5[GG + i]) * d7[ddAMKI + i])) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let ddKT = 19345
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKT + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GK + i] + (d6[IG + i] - d5[GK + i]) * d7[ddAMKI + i]) - (d1[AD + i] + (d1[AE + i] - d1[AD + i]) * d7[dddKI + i]), 5)) }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let ddKU = 19710
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKU + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GL + i] + (d6[IH + i] - d5[GL + i]) * d7[ddAMKI + i]) - (d1[AD + i] + (d1[AE + i] - d1[AD + i]) * d7[dddKI + i]), 5)) }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let ddKV = 20075
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKV + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GN + i] + (d6[IJ + i] - d5[GN + i]) * d7[ddAMKI + i]) - (d1[AF + i] + (d1[AG + i] - d1[AF + i]) * d7[dddKI + i]), 5)) }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let ddKW = 20440
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKW + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GO + i] + (d6[IK + i] - d5[GO + i]) * d7[ddAMKI + i]) - (d1[AF + i] + (d1[AG + i] - d1[AF + i]) * d7[dddKI + i]), 5)) }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let ddKX = 20805
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKX + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GQ + i] + (d6[IM + i] - d5[GQ + i]) * d7[ddAMKI + i]) - (d1[AH + i] + (d1[AI + i] - d1[AH + i]) * d7[dddKI + i]), 5)) }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let ddKY = 21170
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d7[ddKY + i] = iff(d7[ddKI + i].isZero, .zero, round((d5[GR + i] + (d6[IN + i] - d5[GR + i]) * d7[ddAMKI + i]) - (d1[AH + i] + (d1[AI + i] - d1[AH + i]) * d7[dddKI + i]), 5)) }

    /// Opt harm op period op during night prio operation
    let ddKZ = 21535
    // KZ=IF(OR(KI6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d7[ddKZ + i] = iff(
        or(d7[ddKI + i].isZero, d7[ddKJ + i] < .zero, d7[ddKL + i] < .zero, d7[ddKN + i] < .zero, d7[ddKP + i] < .zero, d7[ddKR + i] < .zero, d7[ddKT + i] < .zero, d7[ddKV + i] < .zero, d7[ddKX + i] < .zero), 0,
        min(
          1, ifFinite(d7[ddKJ + i] / max(0, d7[ddKJ + i] - d7[ddKK + i]), 1), ifFinite(d7[ddKL + i] / max(0, d7[ddKL + i] - d7[ddKM + i]), 1), ifFinite(d7[ddKN + i] / max(0, d7[ddKN + i] - d7[ddKO + i]), 1), ifFinite(d7[ddKP + i] / max(0, d7[ddKP + i] - d7[ddKQ + i]), 1),
          ifFinite(d7[ddKR + i] / max(0, d7[ddKR + i] - d7[ddKS + i]), 1), ifFinite(d7[ddKT + i] / max(0, d7[ddKT + i] - d7[ddKU + i]), 1), ifFinite(d7[ddKV + i] / max(0, d7[ddKV + i] - d7[ddKW + i]), 1), ifFinite(d7[ddKX + i] / max(0, d7[ddKX + i] - d7[ddKY + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }
  }
}
