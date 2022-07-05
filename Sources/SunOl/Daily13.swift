extension TunOl {
  func d13(_ d13: inout [Double], case j: Int, d10: [Double], d11: [Double], d12: [Double]) {
    let (Z, AA, AB, AC, AD, AE, AF, AG, AH, AI, AM) = (8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775)  // d1

    let (FS, FT, FV, FW, FY, FZ, GE, GF, GG, GH, GI, GK, GL, GN, GO, GQ, GR) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d5

    let (HO, HP, HR, HS, HU, HV, IA, IB, IC, ID, IE, IG, IH, IJ, IK, IM, IN) = (
      7300, 7665, 8395, 8760, 9490, 9855, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // d6

    let FK = 4380
    let HG = 4380
    let GA = 10220
    /// Surplus harm op period electricity after min harm op and min night op prep
    let ddIQ = 0
    // =FS6+GE6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 { d13[ddIQ + i] = d11[FS + i] + d11[GE + i] - d10[Z + i] - max(0, d10[AB + i] - d11[FV + i]) / El_boiler_eff - max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff }
    
    let HW = 10220
    /// Surplus harm op period electricity after min harm op and max night op prep
    let ddIR = 365
    // =HO6+IA6-$AA6-MAX(0,$AC6-HR6)/El_boiler_eff-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 { d13[ddIR + i] = d12[HO + i] + d12[IA + i] - d10[AA + i] - max(0, d10[AC + i] - d12[HR + i]) / El_boiler_eff - max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let ddIS = 730
    // =FT5+GF5-$Z5-MAX(0,$AB5-FW5)/El_boiler_eff-MAX(0,FK5-GG5-GA5*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 { d13[ddIS + i] = d11[FT + i] + d11[GF + i] - d10[Z + i] - max(0, d10[AB + i] - d11[FW + i]) / El_boiler_eff - max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let ddIT = 1095
    // =FV6+MAX(0,FS6+GE6-$Z6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-$AB6
    for i in 0..<365 { d13[ddIT + i] = d11[FV + i] + max(0, d11[FS + i] + d11[GE + i] - d10[Z + i] - max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff) * El_boiler_eff - d10[AB + i] }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let ddIU = 1460
    // =HR6+MAX(0,HO6+IA6-$AA6-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-$AC6
    for i in 0..<365 { d13[ddIU + i] = d12[HR + i] + max(0, d12[HO + i] + d12[IA + i] - d10[AA + i] - max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff) * El_boiler_eff - d10[AC + i]  }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let ddIV = 1825
    // =FW6+MAX(0,FT6+GF6-$Z6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-$AB6
    for i in 0..<365 { d13[ddIV + i] = d11[FW + i] + max(0, d11[FT + i] + d11[GF + i] - d10[Z + i] - max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff) * El_boiler_eff - d10[AB + i] }

    /// Surplus el boiler cap after min harm op and min night op prep
    let ddIW = 2190
    // GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 { d13[ddIW + i] = d11[GH + i] - max(.zero, d10[AB + i] - d11[FV + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep
    let ddIX = 2555
    // =ID6-MAX(0,$AC6-HR6)/El_boiler_eff
    for i in 0..<365 { d13[ddIX + i] = d12[ID + i] - max(.zero, d10[AC + i] - d12[HR + i]) / El_boiler_eff }

    /// Surplus el boiler cap after max harm op and min night op prep
    let ddIY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 { d13[ddIY + i] = d11[GI + i] - max(.zero, (d10[AB + i] - d11[FW + i]) / El_boiler_eff) }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let ddIZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let ddJA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let ddJB = 4015

    for i in 0..<365 {
      // =FY6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff
      d13[ddIZ + i] = d11[FY + i] - max(.zero, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff
      // =HU6-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff
      d13[ddJA + i] = d12[HU + i] - max(.zero, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff
      // =FZ6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff
      d13[ddJB + i] = d11[FZ + i] - max(.zero, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus Grid input cap after min harm op and min night op prep
    let ddJC = 4380
    /// =GE6-MAX(0,-(FS6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MAX(0,(FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)))
    for i in 0..<365 { d13[ddJC + i] = d11[GE + i] - max(.zero, -(d11[FS + i] - d10[Z + i] - max(0, d10[AB + i] - d11[FV + i]) / El_boiler_eff - max(.zero, (d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff))) }

    ///	Surplus grid import cap after min harm op and max night op prep
    let ddJD = 4745
    /// =IA6-MAX(0,-(HO6-$AA6-MAX(0,$AC6-HR6)/El_boiler_eff-MAX(0,(HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)))
    for i in 0..<365 {
      //  let equiv_harmonious = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]
      d13[ddJD + i] = d12[IA + i] - max(0, -(d12[HO + i] - d10[AA + i] - max(0, d10[AC + i] - d12[HR + i]) / El_boiler_eff - max(0, (d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff)))

    }
    /// Surplus grid import cap after max harm op and min night op prep
    let ddJE = 5110
    /// =GF6-MAX(0,-(FT6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-MAX(0,(FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)))
    for i in 0..<365 { d13[ddJE + i] = d11[GF + i] - max(.zero, -(d11[FT + i] - d10[Z + i] - max(0, d10[AB + i] - d11[FW + i]) / El_boiler_eff - max(.zero, (d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff))) }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let ddJF = 5475
    // JF=GK6-$AD6
    for i in 0..<365 { d13[ddJF + i] = d11[GK + i] - d10[AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let ddJG = 5840
    // =IG6-$AE6
    for i in 0..<365 { d13[ddJG + i] = d12[IG + i] - d10[AE + i] }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let ddJH = 6205
    // JH=GL6-$AD6
    for i in 0..<365 { d13[ddJH + i] = d11[GL + i] - d10[AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let ddJI = 6570
    // JI=GN6-$AF6
    for i in 0..<365 { d13[ddJI + i] = d11[GN + i] - d10[AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let ddJJ = 6935
    // JJ=IJ6-$AG6
    for i in 0..<365 { d13[ddJJ + i] = d12[IJ + i] - d10[AG + i] }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let ddJK = 7300
    // JK=GO6-$AF6
    for i in 0..<365 { d13[ddJK + i] = d11[GO + i] - d10[AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let ddJL = 7665
    // JL=GQ6-$AH6
    for i in 0..<365 { d13[ddJL + i] = d11[GQ + i] - d10[AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let ddJM = 8030
    // JM=IM6-$AI6
    for i in 0..<365 { d13[ddJM + i] = d12[IM + i] - d10[AI + i] }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let ddJN = 8395
    // JN=GR6-$AH6
    for i in 0..<365 { d13[ddJN + i] = d11[GR + i] - d10[AH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let ddJP = 8760
    // JP=IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d13[ddJP + i] = iff(
        or(d13[ddIQ + i] < .zero, d13[ddIT + i] < .zero, d13[ddIW + i] < .zero, d13[ddIZ + i] < .zero, d13[ddJC + i] < .zero, d13[ddJF + i] < .zero, d13[ddJI + i] < .zero, d13[ddJL + i] < .zero), .zero,
        min(
          1, ifFinite(d13[ddIQ + i] / max(0, d13[ddIQ + i] - d13[ddIS + i]), 1), ifFinite(d13[ddIT + i] / max(0, d13[ddIT + i] - d13[ddIV + i]), 1), ifFinite(d13[ddIW + i] / max(0, d13[ddIW + i] - d13[ddIY + i]), 1), ifFinite(d13[ddIZ + i] / max(0, d13[ddIZ + i] - d13[ddJB + i]), 1),
          ifFinite(d13[ddJC + i] / max(0, d13[ddJC + i] - d13[ddJE + i]), 1), ifFinite(d13[ddJF + i] / max(0, d13[ddJF + i] - d13[ddJH + i]), 1), ifFinite(d13[ddJI + i] / max(0, d13[ddJI + i] - d13[ddJK + i]), 1), ifFinite(d13[ddJL + i] / max(0, d13[ddJL + i] - d13[ddJN + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }
    let dddJP = 26280  // let ddLN = 26280
    for i in 0..<365 { d13[dddJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (d13[ddJP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let ddJQ = 9125
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddJQ + i] = iff(
        d13[ddJP + i].isZero, .zero,
        round(
          (d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dddJP + i]) + (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dddJP + i]) - d10[Z + i] - max(.zero, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dddJP + i])) / El_boiler_eff
            - max(0, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let ddJR = 9490
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddJR + i] = iff(
        d13[ddJP + i].isZero, 0,
        round(
          (d12[HO + i] + (d12[HP + i] - d12[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))
            + (d12[IA + i] + (d12[IB + i] - d12[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc)) - d10[AA + i] - max(
              0, d10[AC + i] - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))) / El_boiler_eff - max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff)
            / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let ddJS = 9855
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-$AB6,5))
    for i in 0..<365 {
      d13[ddJS + i] = iff(
        d13[ddJP + i].isZero, .zero,
        round(
          (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dddJP + i]) + max(.zero, (d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dddJP + i]) + (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dddJP + i]) - d10[Z + i]) * El_boiler_eff
            - min((d11[FY + i] + (d11[FZ + i] - d11[FY + i]) * d13[dddJP + i]), max(.zero, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff) * El_boiler_eff - d10[AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let ddJT = 10220
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-$AC6,5))
    for i in 0..<365 {
      d13[ddJT + i] = iff(
        d13[ddJP + i].isZero, .zero,
        round(
          (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc)) + max(
            0,
            (d12[HO + i] + (d12[HP + i] - d12[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))
              + (d12[IA + i] + (d12[IB + i] - d12[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc)) - d10[AA + i] - max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff) * El_boiler_eff
            - d10[AC + i], 5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let ddJU = 10585
    // JU=IF(JP6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d13[ddJU + i] = iff(d13[ddJP + i].isZero, .zero, round((d11[GH + i] + (d11[GI + i] - d11[GH + i]) * d13[dddJP + i]) - max(.zero, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dddJP + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let ddJV = 10950
    // JV=IF(JP6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[ddJV + i] = iff(
        d13[ddJP + i].isZero, 0,
        round(
          (d12[ID + i] + (d12[IE + i] - d12[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc)) - max(
            0, d10[AC + i] - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let ddJW = 11315
    // JW=IF(JP6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 { d13[ddJW + i] = iff(d13[ddJP + i].isZero, .zero, round((d11[FY + i] + (d11[FZ + i] - d11[FY + i]) / Overall_harmonious_range * (d13[ddJP + i] - Overall_harmonious_min_perc)) - max(.zero, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff, 5)) }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let ddJX = 11680
    // JX=IF(JP6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 { d13[ddJX + i] = iff(d13[ddJP + i].isZero, .zero, round((d12[HU + i] + (d12[HV + i] - d12[HU + i]) / Overall_harmonious_range * (d13[ddJP + i] - Overall_harmonious_min_perc)) - max(.zero, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff, 5)) }

    /// Surplus grid import cap after opt day harm and min night op prep
    let ddJY = 12045
    // JY=IF(JP6=0,0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[ddJY + i] = iff(
        d13[ddJP + i].isZero, 0,
        round(
          (d11[GE + i] + (d11[GF + i] - d11[GE + i]) * d13[dddJP + i])
            - max(.zero, -((d11[FS + i] + (d11[FT + i] - d11[FS + i]) * d13[dddJP + i]) - d10[Z + i] - max(.zero, d10[AB + i] - (d11[FV + i] + (d11[FW + i] - d11[FV + i]) * d13[dddJP + i])) / El_boiler_eff - min((d11[FY + i] + (d11[FZ + i] - d11[FY + i]) * d13[dddJP + i]), max(.zero, d11[FK + i] - d11[GG + i] - d11[GA + i] * BESS_chrg_eff) / BESS_chrg_eff))), 5))
    }

    /// Surplus grid import cap after opt day harm and max night op prep
    let ddJZ = 12410
    // JZ=IF(JP6=0,0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[ddJZ + i] = iff(
        d13[ddJP + i].isZero, 0,
        round(
          (d12[IA + i] + (d12[IB + i] - d12[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))
            - max(
              0,
              -((d12[HO + i] + (d12[HP + i] - d12[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc)) - d10[AA + i] - max(
                0, d10[AC + i] - (d12[HR + i] + (d12[HS + i] - d12[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc))) / El_boiler_eff - max(0, d12[HG + i] - d12[IC + i] - d12[HW + i] * BESS_chrg_eff) / BESS_chrg_eff)
            ), 5))

    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let ddKA = 12775
    // KA=IF(JP6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AD6,5))
    for i in 0..<365 { d13[ddKA + i] = iff(d13[ddJP + i].isZero, 0, round(d11[GK + i] + (d11[GL + i] - d11[GK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc) - d10[AD + i], 5)) }


    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let ddKB = 13140
    // KB=IF(JP6=0,0,ROUND(IG6+(IH6-IG6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AE6,5))
    for i in 0..<365 { d13[ddKB + i] = iff(d13[ddJP + i].isZero, 0, round(d12[IG + i] + (d12[IH + i] - d12[IG + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc) - d10[AE + i], 5)) }


    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let ddKC = 13505
    // KC=IF(JP6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AF6,5))
    for i in 0..<365 { d13[ddKC + i] = iff(d13[ddJP + i].isZero, 0, round(d11[GN + i] + (d11[GO + i] - d11[GN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc) - d10[AF + i], 5)) }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let ddKD = 13870
    // KD=IF(JP6=0,0,ROUND(IJ6+(IK6-IJ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AG6,5))
    for i in 0..<365 { d13[ddKD + i] = iff(d13[ddJP + i].isZero, 0, round(d12[IJ + i] + (d12[IK + i] - d12[IJ + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[ddJP + i] - Overall_harmonious_min_perc) - d10[AG + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let ddKE = 14235
    // KE=IF(JP6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AH6,5))
    for i in 0..<365 { d13[ddKE + i] = iff(d13[ddJP + i].isZero, .zero, round((d11[GQ + i] + (d11[GR + i] - d11[GQ + i]) * d13[dddJP + i]) - d10[AH + i], 5)) }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let ddKF = 14600
    // KF=IF(JP6=0,0,ROUND(IM6+(IN6-IM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AI6,5))
    for i in 0..<365 { d13[ddKF + i] = iff(d13[ddJP + i].isZero, .zero, round(d12[IM + i] + (d12[IN + i] - d12[IM + i]) * d13[dddJP + i] - d10[AI + i], 5)) }

    /// Opt night prep during day prio operation
    let ddKG = 14965
    // KG=IF(OR($AM6=0,JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[ddKG + i] = iff(
        or(d10[AM + i].isZero, d13[ddJP + i].isZero, d13[ddJQ + i] < .zero, d13[ddJS + i] < .zero, d13[ddJU + i] < .zero, d13[ddJW + i] < .zero, d13[ddJY + i] < .zero, d13[ddKA + i] < .zero, d13[ddKC + i] < .zero, d13[ddKE + i] < .zero), 0,
        min(
          1, ifFinite(d13[ddJQ + i] / max(0, d13[ddJQ + i] - d13[ddJR + i]), 1), ifFinite(d13[ddJS + i] / max(0, d13[ddJS + i] - d13[ddJT + i]), 1), ifFinite(d13[ddJU + i] / max(0, d13[ddJU + i] - d13[ddJV + i]), 1), ifFinite(d13[ddJW + i] / max(0, d13[ddJW + i] - d13[ddJX + i]), 1),
          ifFinite(d13[ddJY + i] / max(0, d13[ddJY + i] - d13[ddJZ + i]), 1), ifFinite(d13[ddKA + i] / max(0, d13[ddKA + i] - d13[ddKB + i]), 1), ifFinite(d13[ddKC + i] / max(0, d13[ddKC + i] - d13[ddKD + i]), 1), ifFinite(d13[ddKE + i] / max(0, d13[ddKE + i] - d13[ddKF + i]), 1)) * (d10[AM + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let ddKI = 15330
    // KI=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[ddKI + i] = iff(
        or(d10[AM + i].isZero, d13[ddIQ + i] < .zero, d13[ddIT + i] < .zero, d13[ddIW + i] < .zero, d13[ddIZ + i] < .zero, d13[ddJC + i] < .zero, d13[ddJF + i] < .zero, d13[ddJI + i] < .zero, d13[ddJL + i] < .zero), 0,
        min(
          1, ifFinite(d13[ddIQ + i] / max(0, d13[ddIQ + i] - d13[ddIR + i]), 1), ifFinite(d13[ddIT + i] / max(0, d13[ddIT + i] - d13[ddIU + i]), 1), ifFinite(d13[ddIW + i] / max(0, d13[ddIW + i] - d13[ddIX + i]), 1), ifFinite(d13[ddIZ + i] / max(0, d13[ddIZ + i] - d13[ddJA + i]), 1),
          ifFinite(d13[ddJC + i] / max(0, d13[ddJC + i] - d13[ddJD + i]), 1), ifFinite(d13[ddJF + i] / max(0, d13[ddJF + i] - d13[ddJG + i]), 1), ifFinite(d13[ddJI + i] / max(0, d13[ddJI + i] - d13[ddJJ + i]), 1), ifFinite(d13[ddJL + i] / max(0, d13[ddJL + i] - d13[ddJM + i]), 1)) * (d10[AM + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }
    let ddAMKG = 23360  // let ddLF = 23360
   
    let ddAMKI = 38690  // let ddMW = 38690
    for i in 0..<365 {

      d13[ddAMKG + i] = (d10[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[ddKG + i] - equiv_harmonious_min_perc[j]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
      d13[ddAMKI + i] = (d10[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[ddKI + i] - equiv_harmonious_min_perc[j]) / (d10[AM + i] - equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let ddKJ = 15695
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddKJ + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKI + i]) + (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]) - max(.zero, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i])) / El_boiler_eff
            - max(.zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i]) - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let ddKK = 16060
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddKK + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[ddAMKI + i]) + (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]) - max(.zero, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKI + i])) / El_boiler_eff
            - max(.zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i]) - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let ddKL = 16425
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[ddKL + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i]) + (max(.zero, (d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKI + i]) + (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]))) * El_boiler_eff
            - min((d11[FY + i] + (d12[HU + i] - d11[FY + i]) * d13[ddAMKI + i]), max(.zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i])) / BESS_chrg_eff) - (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let ddKM = 16790
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff)*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[ddKM + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKI + i]) + (max(.zero, (d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[ddAMKI + i]) + (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]))) * El_boiler_eff
            - min((d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) * d13[ddAMKI + i]), max(.zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i]) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i])) / BESS_chrg_eff) - (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]), 5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let ddKN = 17155
    // KN=IF(KI6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d13[ddKN + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GH + i] + (d12[ID + i] - d11[GH + i]) * d13[ddAMKI + i]) - max(.zero, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i])) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let ddKO = 17520
    // KO=IF(KI6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 { d13[ddKO + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GI + i] + (d12[IE + i] - d11[GI + i]) * d13[ddAMKI + i]) - max(.zero, (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKI + i])) / El_boiler_eff, 5)) }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let ddKP = 17885
    // KP=IF(KI6=0,0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddKP + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FY + i] + (d12[HU + i] - d11[FY + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - max(
            .zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let ddKQ = 18250
    // KQ=IF(KI6=0,0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[ddKQ + i] = iff(
        d13[ddKI + i].isZero, .zero,
        round(
          (d11[FZ + i] + (d12[HV + i] - d11[FZ + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - max(
            .zero, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) / (d10[AM + i] - equiv_harmonious_min_perc[j]) * (d13[ddKI + i] - equiv_harmonious_min_perc[j])) - (d11[GA + i] + (d12[HW + i] - d11[GA + i])) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus grid import cap after min day harmonious and opti night op prep
    let ddKR = 18615
    // KR=IF(KI6=0,0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff)),5))
    for i in 0..<365 {

      d13[ddKR + i] = iff(
        d13[ddKI + i].isZero, 0,
        round(
          (d11[GE + i] + (d12[IA + i] - d11[GE + i]) * d13[ddAMKI + i])
            - max(
              .zero,
              -((d11[FS + i] + (d12[HO + i] - d11[FS + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]) - max(
                .zero,
                (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FV + i] + (d12[HR + i] - d11[FV + i]) * d13[ddAMKI + i])) / El_boiler_eff - max(0, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i])
                  - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i]) - (d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[ddAMKI + i]) * BESS_chrg_eff) / BESS_chrg_eff)), 5))
    }

    /// Surplus grid import cap after max day harmonious and opti night op prep
    let ddKS = 18980
    // KS=IF(KI6=0,0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[ddKS + i] = iff(
        d13[ddKI + i].isZero, 0,
        round(
          (d11[GF + i] + (d12[IB + i] - d11[GF + i]) * d13[ddAMKI + i])
            - max(
              .zero,
              -((d11[FT + i] + (d12[HP + i] - d11[FT + i]) * d13[ddAMKI + i]) - (d10[Z + i] + (d10[AA + i] - d10[Z + i]) * d13[ddAMKI + i]) - max(
                .zero,
                (d10[AB + i] + (d10[AC + i] - d10[AB + i]) * d13[ddAMKI + i]) - (d11[FW + i] + (d12[HS + i] - d11[FW + i]) * d13[ddAMKI + i])) / El_boiler_eff - max(0, (d11[FK + i] + (d12[HG + i] - d11[FK + i]) * d13[ddAMKI + i])
                  - (d11[GG + i] + (d12[IC + i] - d11[GG + i]) * d13[ddAMKI + i]) - (d11[GA + i] + (d12[HW + i] - d11[GA + i]) * d13[ddAMKI + i]) * BESS_chrg_eff) / BESS_chrg_eff)), 5))
    }


    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let ddKT = 19345
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKT + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GK + i] + (d12[IG + i] - d11[GK + i]) * d13[ddAMKI + i]) - (d10[AD + i] + (d10[AE + i] - d10[AD + i]) * d13[ddAMKI + i]), 5)) }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let ddKU = 19710
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKU + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GL + i] + (d12[IH + i] - d11[GL + i]) * d13[ddAMKI + i]) - (d10[AD + i] + (d10[AE + i] - d10[AD + i]) * d13[ddAMKI + i]), 5)) }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let ddKV = 20075
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKV + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GN + i] + (d12[IJ + i] - d11[GN + i]) * d13[ddAMKI + i]) - (d10[AF + i] + (d10[AG + i] - d10[AF + i]) * d13[ddAMKI + i]), 5)) }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let ddKW = 20440
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKW + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GO + i] + (d12[IK + i] - d11[GO + i]) * d13[ddAMKI + i]) - (d10[AF + i] + (d10[AG + i] - d10[AF + i]) * d13[ddAMKI + i]), 5)) }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let ddKX = 20805
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKX + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GQ + i] + (d12[IM + i] - d11[GQ + i]) * d13[ddAMKI + i]) - (d10[AH + i] + (d10[AI + i] - d10[AH + i]) * d13[ddAMKI + i]), 5)) }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let ddKY = 21170
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[ddKY + i] = iff(d13[ddKI + i].isZero, .zero, round((d11[GR + i] + (d12[IN + i] - d11[GR + i]) * d13[ddAMKI + i]) - (d10[AH + i] + (d10[AI + i] - d10[AH + i]) * d13[ddAMKI + i]), 5)) }

    /// Opt harm op period op during night prio operation
    let ddKZ = 21535
    // KZ=IF(OR(JP6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d13[ddKZ + i] = iff(
        or(d13[ddJP + i].isZero, d13[ddKJ + i] < .zero, d13[ddKL + i] < .zero, d13[ddKN + i] < .zero, d13[ddKP + i] < .zero, d13[ddKR + i] < .zero, d13[ddKT + i] < .zero, d13[ddKV + i] < .zero, d13[ddKX + i] < .zero), 0,
        min(
          1, ifFinite(d13[ddKJ + i] / max(0, d13[ddKJ + i] - d13[ddKK + i]), 1), ifFinite(d13[ddKL + i] / max(0, d13[ddKL + i] - d13[ddKM + i]), 1), ifFinite(d13[ddKN + i] / max(0, d13[ddKN + i] - d13[ddKO + i]), 1), ifFinite(d13[ddKP + i] / max(0, d13[ddKP + i] - d13[ddKQ + i]), 1),
          ifFinite(d13[ddKR + i] / max(0, d13[ddKR + i] - d13[ddKS + i]), 1), ifFinite(d13[ddKT + i] / max(0, d13[ddKT + i] - d13[ddKU + i]), 1), ifFinite(d13[ddKV + i] / max(0, d13[ddKV + i] - d13[ddKW + i]), 1), ifFinite(d13[ddKX + i] / max(0, d13[ddKX + i] - d13[ddKY + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }
  }
}
