extension TunOl {
  func d13(_ h: inout [Double], case j: Int) {
    let (
      Z, AA, AB, AC, AD, AE, AF, AG, AH, AI, AM, _, _, _, _, _, _, _, _, _, _, _,
      _, FK, _, _, _, _, _, _, _, FS, FT, _, FV, FW, _, FY, FZ, GA, _, _, _, GE,
      GF, GG, GH, GI, _, GK, GL, _, GN, GO, _, GQ, GR, _, _, _, _, _, _, _, _, _,
      _, _, _, _, HG, _, _, _, _, _, _, _, HO, HP, _, HR, HS, _, HU, HV, HW, _, _,
      _, IA, IB, IC, ID, IE, _, IG, IH, _, IJ, IK, _, IM, IN, _, IQ, IR, IS, IT,
      IU, IV, IW, IX, IY, IZ, JA, JB, JC, JD, JE, JF, JG, JH, JI, JJ, JK, JL, JM,
      JN, _, JP, JQ, JR, JS, JT, JU, JV, JW, JX, JY, JZ, KA, KB, KC, KD, KE, KF,
      KG, _, KI, KJ, KK, KL, KM, KN, KO, KP, KQ, KR, KS, KT, KU, KV, KW, KX, KY, KZ
    ) = (
      8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775, 13140,
      13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155,
      17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805, 21170,
      21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820, 25185,
      25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200,
      29565, 29930, 30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580,
      33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230, 37595,
      37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610,
      41975, 42340, 42705, 43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625,
      45990, 46355, 46720, 47085, 47450, 48180, 48545, 48910, 49275, 49640, 50005,
      50370, 50735, 51100, 51465, 51830, 52195, 52560, 52925, 53290, 53655, 54020,
      54385, 54750, 55115, 55480, 55845, 56210, 56575, 56940, 57305, 57670, 58035,
      58400, 58765, 59130, 59495, 59860, 60225, 60590, 60955, 61320, 61685, 62050,
      62415, 62780, 63145, 63510, 63875, 64240, 64605, 64970, 65335, 65700, 66065,
      66430, 66795, 67160, 67525, 67890, 68255, 68620, 68985, 69350, 69715, 70080,
      70445
    )

    /// Surplus harm op period electricity after min harm op and min night op prep
    // =FS6+GE6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      h[IQ + i] =
        h[FS + i] + h[GE + i] - h[Z + i] - min(h[GH + i], max(Double.zero, h[AB + i] - h[FV + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op period electricity after min harm op and max night op prep
    // =HO6+IA6-$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      h[IR + i] =
        h[HO + i] + h[IA + i] - h[AA + i] - min(h[ID + i], max(Double.zero, h[AC + i] - h[HR + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op period electricity after max harm op and min night op prep
    // =FT6+GF6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      h[IS + i] =
        h[FT + i] + h[GF + i] - h[Z + i] - min(h[GI + i], max(Double.zero, h[AB + i] - h[FW + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    // =FV6+MIN(GH6,MAX(0,FS6+GE6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      h[IT + i] =
        h[FV + i] + min(h[GH + i], max(Double.zero, h[FS + i] + h[GE + i] - h[Z + i] - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - h[AB + i]
    }
    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    // =HR6+MIN(ID6,MAX(0,HO6+IA6-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6
    for i in 0..<365 {
      h[IU + i] =
        h[HR + i] + min(h[ID + i], max(Double.zero, h[HO + i] + h[IA + i] - h[AA + i] - min(BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - h[AC + i]
    }
    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    // =FW6+MIN(GI6,MAX(0,FT6+GF6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      h[IV + i] =
        h[FW + i] + min(h[GI + i], max(Double.zero, h[FT + i] + h[GF + i] - h[Z + i] - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - h[AB + i]
    }
    /// Surplus el boiler cap after min harm op and min night op prep
    // =IF(El_boiler_cap_ud=0,0,GH6-MAX(0,$AB6-FV6)/El_boiler_eff)
    for i in 0..<365 { h[IW + i] = h[GH + i] - max(Double.zero, h[AB + i] - h[FV + i]) / El_boiler_eff }
    /// Surplus el boiler cap after min harm op and max night op prep
    // =IF(El_boiler_cap_ud=0,0,ID6-MAX(0,$AC6-HR6)/El_boiler_eff)
    for i in 0..<365 { h[IX + i] = h[ID + i] - max(Double.zero, h[AC + i] - h[HR + i]) / El_boiler_eff }
    /// Surplus el boiler cap after max harm op and min night op prep
    // =IF(BESS_cap_ud=0,0,FY6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
    for i in 0..<365 { h[IY + i] = h[GI + i] - max(Double.zero, h[AB + i] - h[FW + i]) / El_boiler_eff }
    /// Surplus BESS chrg cap after min harm op and min night op prep
    /// Surplus BESS chrg cap after min harm op and max night op prep
    /// Surplus BESS chrg cap after max harm op and min night op prep
    for i in 0..<365 {
      // =IF(BESS_cap_ud=0,0,FY6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
      h[IZ + i] = h[FY + i] - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =IF(BESS_cap_ud=0,0,HU6-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)
      h[JA + i] = h[HU + i] - min(BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =IF(BESS_cap_ud=0,0,FZ6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
      h[JB + i] = h[FZ + i] - min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus Grid input cap after min harm op and min night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,GE6-MAX(0,-(FS6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      h[JC + i] = iff(
        Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero, 0,
        h[GE + i]
          - max(
            0,
            -(h[FS + i] - h[Z + i] - min(h[GH + i], max(0, h[AB + i] - h[FV + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(0, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after min harm op and max night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,IA6-MAX(0,-(HO6-$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      h[JD + i] = iff(
        Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero, 0,
        h[IA + i]
          - max(
            0,
            -(h[HO + i] - h[AA + i] - min(h[ID + i], max(0, h[AC + i] - h[HR + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(0, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after max harm op and min night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,GF6-MAX(0,-(FT6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      h[JE + i] = iff(
        Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero, 0,
        h[GF + i]
          - max(
            0,
            -(h[FT + i] - h[Z + i] - min(h[GI + i], max(0, h[AB + i] - h[FW + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(0, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus RawMeth prod cap after min harm op and min night op prep
    // JF=GK6-$AD6
    for i in 0..<365 { h[JF + i] = h[GK + i] - h[AD + i] }
    /// Surplus RawMeth prod cap after min harm op and max night op prep
    // =IG6-$AE6
    for i in 0..<365 { h[JG + i] = h[IG + i] - h[AE + i] }
    /// Surplus RawMeth prod cap after max harm op and min night op prep
    // JH=GL6-$AD6
    for i in 0..<365 { h[JH + i] = h[GL + i] - h[AD + i] }
    /// Surplus CO2 prod cap after min harm op and min night op prep
    // JI=GN6-$AF6
    for i in 0..<365 { h[JI + i] = h[GN + i] - h[AF + i] }
    /// Surplus CO2 prod cap after min harm op and max night op prep
    // JJ=IJ6-$AG6
    for i in 0..<365 { h[JJ + i] = h[IJ + i] - h[AG + i] }
    /// Surplus CO2 prod cap after max harm op and min night op prep
    // JK=GO6-$AF6
    for i in 0..<365 { h[JK + i] = h[GO + i] - h[AF + i] }
    /// Surplus H2 prod cap after min harm op and min night op prep
    // JL=GQ6-$AH6
    for i in 0..<365 { h[JL + i] = h[GQ + i] - h[AH + i] }
    /// Surplus H2 prod cap after min harm op and max night op prep
    // JM=IM6-$AI6
    for i in 0..<365 { h[JM + i] = h[IM + i] - h[AI + i] }
    /// Surplus H2 prod cap after max harm op and min night op prep
    // JN=GR6-$AH6
    for i in 0..<365 { h[JN + i] = h[GR + i] - h[AH + i] }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    // JP=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      if i + JP  == 57614 {
        
      }
      h[JP + i] = iff(
        or(h[AM + i].isZero, h[IQ + i] < Double.zero, h[IT + i] < Double.zero, h[IW + i] < Double.zero, h[IZ + i] < Double.zero, h[JC + i] < Double.zero, h[JF + i] < Double.zero, h[JI + i] < Double.zero, h[JL + i] < 0),
        Double.zero,
        min(
          1, ifFinite(h[IQ + i] / max(Double.zero, h[IQ + i] - h[IS + i]), 1.0), ifFinite(h[IT + i] / max(Double.zero, h[IT + i] - h[IV + i]), 1.0), ifFinite(h[IW + i] / max(Double.zero, h[IW + i] - h[IY + i]), 1.0),
          ifFinite(h[IZ + i] / max(Double.zero, h[IZ + i] - h[JB + i]), 1.0), ifFinite(h[JC + i] / max(Double.zero, h[JC + i] - h[JE + i]), 1.0), ifFinite(h[JF + i] / max(Double.zero, h[JF + i] - h[JH + i]), 1.0),
          ifFinite(h[JI + i] / max(Double.zero, h[JI + i] - h[JK + i]), 1.0), ifFinite(h[JL + i] / max(Double.zero, h[JL + i] - h[JN + i]), 1.0)) * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }
    let dJP: Int = 70810  // LA
    for i in 0..<365 { h[dJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (h[JP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }
    /// Surplus harm op period electricity after opt harmonious and min night op prep
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[JQ + i] = iff(
        h[JP + i].isZero, Double.zero,
        round(
          (h[FS + i] + (h[FT + i] - h[FS + i]) * h[dJP + i]) + (h[GE + i] + (h[GF + i] - h[GE + i]) * h[dJP + i]) - h[Z + i]
            - min((h[GH + i] + (h[GI + i] - h[GH + i]) * h[dJP + i]), max(Double.zero, h[AB + i] - (h[FV + i] + (h[FW + i] - h[FV + i]) * h[dJP + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus harm op period electricity after opt harmonious and max night op prep
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[JR + i] = iff(
        h[JP + i].isZero, Double.zero,
        round(
          (h[HO + i] + (h[HP + i] - h[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc))
            + (h[IA + i] + (h[IB + i] - h[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)) - h[AA + i]
            - min(
              (h[ID + i] + (h[IE + i] - h[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)),
              max(Double.zero, h[AC + i] - (h[HR + i] + (h[HS + i] - h[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc))) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6,5))
    for i in 0..<365 {
      h[JS + i] = iff(
        h[JP + i].isZero, Double.zero,
        round(
          (h[FV + i] + (h[FW + i] - h[FV + i]) * h[dJP + i]) + min(
            (h[GH + i] + (h[GI + i] - h[GH + i]) * h[dJP + i]),
            max(Double.zero, (h[FS + i] + (h[FT + i] - h[FS + i]) * h[dJP + i]) + (h[GE + i] + (h[GF + i] - h[GE + i]) * h[dJP + i]) - h[Z + i]) * El_boiler_eff
              - min((h[FY + i] + (h[FZ + i] - h[FY + i]) * h[dJP + i]), min(BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - h[AB + i], 5))
    }
    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6,5))
    for i in 0..<365 {
      h[JT + i] = iff(
        h[JP + i].isZero, Double.zero,
        round(
          (h[HR + i] + (h[HS + i] - h[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)) + min(
            h[ID + i] + (h[IE + i] - h[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc),
            max(
              Double.zero,
              (h[HO + i] + (h[HP + i] - h[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc))
                + (h[IA + i] + (h[IB + i] - h[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)) - h[AA + i] - min(
                  BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - h[AC + i], 5))
    }
    /// Surplus el boiler cap after opt day harm and min night op prep
    // JU=IF(OR(JP6=0,El_boiler_cap_ud=0),0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[JU + i] = iff(
        or(h[JP + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((h[GH + i] + (h[GI + i] - h[GH + i]) * h[dJP + i]) - max(Double.zero, h[AB + i] - (h[FV + i] + (h[FW + i] - h[FV + i]) * h[dJP + i])) / El_boiler_eff, 5))
    }
    /// Surplus el boiler cap after opt day harm and max night op prep
    // JV=IF(OR(JP6=0,El_boiler_cap_ud=0),0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[JV + i] = iff(
        or(h[JP + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round(
          (h[ID + i] + (h[IE + i] - h[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc)) - max(
            Double.zero, h[AC + i] - (h[HR + i] + (h[HS + i] - h[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))
    }
    /// Surplus BESS chrg cap after opt day harm and min night op prep
    // JW=IF(OR(JP6=0,BESS_cap_ud=0),0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[JW + i] = iff(
        or(h[JP + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round((h[FY + i] + (h[FZ + i] - h[FY + i]) * h[dJP + i]) - min(El_boiler_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus BESS chrg cap after opt day harm and max night op prep
    // JX=IF(OR(JP6=0,BESS_cap_ud=0),0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[JX + i] = iff(
        or(h[JP + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round((h[HU + i] + (h[HV + i] - h[HU + i]) * h[dJP + i]) - min(El_boiler_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus grid import cap after opt day harm and min night op prep
    // JY=IF(OR(JP6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      h[JY + i] = iff(
        or(h[JP + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (h[GE + i] + (h[GF + i] - h[GE + i]) * h[dJP + i])
            - max(
              Double.zero,
              -((h[FS + i] + (h[FT + i] - h[FS + i]) * h[dJP + i]) - h[Z + i]
                - min((h[GH + i] + (h[GI + i] - h[GH + i]) * h[dJP + i]), max(Double.zero, h[AB + i] - (h[FV + i] + (h[FW + i] - h[FV + i]) * h[dJP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(Double.zero, h[FK + i] - h[GG + i] - h[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    /// Surplus grid import cap after opt day harm and max night op prep
    // JZ=IF(OR(JP6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      h[JZ + i] = iff(
        or(h[JP + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (h[IA + i] + (h[IB + i] - h[IA + i]) * h[dJP + i])
            - max(
              Double.zero,
              -((h[HO + i] + (h[HP + i] - h[HO + i]) * h[dJP + i]) - h[AA + i]
                - min((h[ID + i] + (h[IE + i] - h[ID + i]) * h[dJP + i]), max(Double.zero, h[AC + i] - (h[HR + i] + (h[HS + i] - h[HR + i]) * h[dJP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(Double.zero, h[HG + i] - h[IC + i] - h[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    // KA=IF(JP6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AD6,5))
    for i in 0..<365 {
      h[KA + i] = iff(h[JP + i].isZero, Double.zero, round(h[GK + i] + (h[GL + i] - h[GK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc) - h[AD + i], 5))
    }
    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    // KB=IF(JP6=0,0,ROUND(IG6+(IH6-IG6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AE6,5))
    for i in 0..<365 {
      h[KB + i] = iff(h[JP + i].isZero, Double.zero, round(h[IG + i] + (h[IH + i] - h[IG + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc) - h[AE + i], 5))
    }
    /// Surplus CO2 prod cap after opt day harm and min night op prep
    // KC=IF(JP6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AF6,5))
    for i in 0..<365 {
      h[KC + i] = iff(h[JP + i].isZero, Double.zero, round(h[GN + i] + (h[GO + i] - h[GN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc) - h[AF + i], 5))
    }
    /// Surplus CO2 prod cap after opt day harm and max night op prep
    // KD=IF(JP6=0,0,ROUND(IJ6+(IK6-IJ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AG6,5))
    for i in 0..<365 {
      h[KD + i] = iff(h[JP + i].isZero, Double.zero, round(h[IJ + i] + (h[IK + i] - h[IJ + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (h[JP + i] - Overall_harmonious_min_perc) - h[AG + i], 5))
    }
    /// Surplus H2 prod cap after opt day harm and min night op prep
    // KE=IF(JP6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AH6,5))
    for i in 0..<365 { h[KE + i] = iff(h[JP + i].isZero, Double.zero, round((h[GQ + i] + (h[GR + i] - h[GQ + i]) * h[dJP + i]) - h[AH + i], 5)) }
    /// Surplus H2 prod cap after opt day harm and max night op prep
    // KF=IF(JP6=0,0,ROUND(IM6+(IN6-IM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AI6,5))
    for i in 0..<365 { h[KF + i] = iff(h[JP + i].isZero, Double.zero, round(h[IM + i] + (h[IN + i] - h[IM + i]) * h[dJP + i] - h[AI + i], 5)) }
    /// Opt night prep during day prio operation
    // KG=IF(OR($AM6=0,JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[KG + i] = iff(
        or(
          h[AM + i].isZero, h[JP + i].isZero, h[JQ + i] < Double.zero, h[JS + i] < Double.zero, h[JU + i] < Double.zero, h[JW + i] < Double.zero, h[JY + i] < Double.zero, h[KA + i] < Double.zero, h[KC + i] < Double.zero,
          h[KE + i] < Double.zero), Double.zero,
        min(
          1, ifFinite(h[JQ + i] / max(Double.zero, h[JQ + i] - h[JR + i]), 1.0), ifFinite(h[JS + i] / max(Double.zero, h[JS + i] - h[JT + i]), 1.0), ifFinite(h[JU + i] / max(Double.zero, h[JU + i] - h[JV + i]), 1.0),
          ifFinite(h[JW + i] / max(Double.zero, h[JW + i] - h[JX + i]), 1.0), ifFinite(h[JY + i] / max(Double.zero, h[JY + i] - h[JZ + i]), 1.0), ifFinite(h[KA + i] / max(Double.zero, h[KA + i] - h[KB + i]), 1.0),
          ifFinite(h[KC + i] / max(Double.zero, h[KC + i] - h[KD + i]), 1.0), ifFinite(h[KE + i] / max(Double.zero, h[KE + i] - h[KF + i]), 1.0)) * (h[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    // KI=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[KI + i] = iff(
        or(h[AM + i].isZero, h[IQ + i] < Double.zero, h[IT + i] < Double.zero, h[IW + i] < Double.zero, h[IZ + i] < Double.zero, h[JC + i] < Double.zero, h[JF + i] < Double.zero, h[JI + i] < Double.zero, h[JL + i] < 0),
        Double.zero,
        min(
          1, ifFinite(h[IQ + i] / max(Double.zero, h[IQ + i] - h[IR + i]), 1.0), ifFinite(h[IT + i] / max(Double.zero, h[IT + i] - h[IU + i]), 1.0), ifFinite(h[IW + i] / max(Double.zero, h[IW + i] - h[IX + i]), 1.0),
          ifFinite(h[IZ + i] / max(Double.zero, h[IZ + i] - h[JA + i]), 1.0), ifFinite(h[JC + i] / max(Double.zero, h[JC + i] - h[JD + i]), 1.0), ifFinite(h[JF + i] / max(Double.zero, h[JF + i] - h[JG + i]), 1.0),
          ifFinite(h[JI + i] / max(Double.zero, h[JI + i] - h[JJ + i]), 1.0), ifFinite(h[JL + i] / max(Double.zero, h[JL + i] - h[JM + i]), 1.0)) * (h[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    let (AMKG, AMKI) = (64240+365, 64240+730)
    for i in 0..<365 {
      h[AMKG + i] = (h[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (h[KG + i] - equiv_harmonious_min_perc[j]) / (h[AM + i] - equiv_harmonious_min_perc[j])
      h[AMKI + i] = (h[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (h[KI + i] - equiv_harmonious_min_perc[j]) / (h[AM + i] - equiv_harmonious_min_perc[j])
    }
    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[KJ + i] = iff(
        h[KI + i].isZero, Double.zero,
        round(
          (h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKI + i]) + (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i])
            - min((h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]), max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]) - (h[GA + i] + (h[HW + i] - h[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[KK + i] = iff(
        h[KI + i].isZero, Double.zero,
        round(
          (h[FT + i] + (h[HP + i] - h[FT + i]) * h[AMKI + i]) + (h[GF + i] + (h[IB + i] - h[GF + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i])
            - min((h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]), max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]) - (h[GA + i] + (h[HW + i] - h[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[KL + i] = iff(
        h[KI + i].isZero, Double.zero,
        round(
          (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i])
            + min(
              (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]),
              (max(Double.zero, (h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKI + i]) + (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i]))) * El_boiler_eff)
            - min(
              (h[FY + i] + (h[HU + i] - h[FY + i]) * h[AMKI + i]),
              min(BESS_cap_ud, max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i])) / BESS_chrg_eff))
            - (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]), 5))
    }
    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[KM + i] = iff(
        h[KI + i].isZero, Double.zero,
        round(
          (h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKI + i])
            + min(
              (h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]),
              (max(Double.zero, (h[FT + i] + (h[HP + i] - h[FT + i]) * h[AMKI + i]) + (h[GF + i] + (h[IB + i] - h[GF + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i]))) * El_boiler_eff
                - min(
                  (h[FZ + i] + (h[HV + i] - h[FZ + i]) * h[AMKI + i]),
                  min(BESS_cap_ud, max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]))) / BESS_chrg_eff))
            - (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]), 5))
    }
    /// Surplus el boiler cap after min day harmonious and opti night op prep
    // KN=IF(OR(KI6=0,El_boiler_cap_ud=0),0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[KN + i] = iff(
        or(h[KI + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]) - max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i])) / El_boiler_eff, 5))
    }
    /// Surplus el boiler cap after max day harmonious and opti night op prep
    // KO=IF(OR(KI6=0,El_boiler_cap_ud=0),0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[KO + i] = iff(
        or(h[KI + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((h[GI + i] + (h[IE + i] - h[GI + i]) * h[AMKI + i]) - max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKI + i])) / El_boiler_eff, 5))
    }
    /// Surplus BESS cap after min day harmonious and opti night op prep
    // KP=IF(OR(KI6=0,BESS_cap_ud=0),0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[KP + i] = iff(
        or(h[KI + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round(
          (h[FY + i] + (h[HU + i] - h[FY + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])) - max(
            Double.zero,
            (h[FK + i] + (h[HG + i] - h[FK + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
              - min(BESS_cap_ud, (h[GG + i] + (h[IC + i] - h[GG + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])) - (h[GA + i] + (h[HW + i] - h[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus BESS cap after max day harmonious and opti night op prep
    // KQ=IF(OR(KI6=0,BESS_cap_ud=0),0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[KQ + i] = iff(
        or(h[KI + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round(
          (h[FZ + i] + (h[HV + i] - h[FZ + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])) - max(
            Double.zero,
            (h[FK + i] + (h[HG + i] - h[FK + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j]))
              - min(BESS_cap_ud, (h[GG + i] + (h[IC + i] - h[GG + i]) / (h[AM + i] - equiv_harmonious_min_perc[j]) * (h[KI + i] - equiv_harmonious_min_perc[j])) - (h[GA + i] + (h[HW + i] - h[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus grid import cap after min day harmonious and opti night op prep
    // KR=IF(OR(KI6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      h[KR + i] = iff(
        or(h[KI + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (h[GE + i] + (h[IA + i] - h[GE + i]) * h[AMKI + i])
            - max(
              Double.zero,
              -((h[FS + i] + (h[HO + i] - h[FS + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i])
                - min((h[GH + i] + (h[ID + i] - h[GH + i]) * h[AMKI + i]), max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FV + i] + (h[HR + i] - h[FV + i]) * h[AMKI + i])) / El_boiler_eff)
                - min(
                  BESS_cap_ud,
                  max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]) - (h[GA + i] + (h[HW + i] - h[GA + i]) * h[AMKI + i]) * BESS_chrg_eff))
                / BESS_chrg_eff)), 5))
    }
    /// Surplus grid import cap after max day harmonious and opti night op prep
    // KS=IF(OR(KI6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      h[KS + i] = iff(
        or(h[KI + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (h[GF + i] + (h[IB + i] - h[GF + i]) * h[AMKI + i])
            - max(
              Double.zero,
              -((h[FT + i] + (h[HP + i] - h[FT + i]) * h[AMKI + i]) - (h[Z + i] + (h[AA + i] - h[Z + i]) * h[AMKI + i])
                - min((h[GI + i] + (h[IR + i] - h[GI + i]) * h[AMKI + i]), max(Double.zero, (h[AB + i] + (h[AC + i] - h[AB + i]) * h[AMKI + i]) - (h[FW + i] + (h[HS + i] - h[FW + i]) * h[AMKI + i])) / El_boiler_eff)
                - min(
                  BESS_cap_ud,
                  max(Double.zero, (h[FK + i] + (h[HG + i] - h[FK + i]) * h[AMKI + i]) - (h[GG + i] + (h[IC + i] - h[GG + i]) * h[AMKI + i]) - (h[GA + i] + (h[HW + i] - h[GA + i]) * h[AMKI + i]) * BESS_chrg_eff))
                / BESS_chrg_eff)), 5))
    }
    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KT + i] = iff(h[KI + i].isZero, Double.zero, round((h[GK + i] + (h[IG + i] - h[GK + i]) * h[AMKI + i]) - (h[AD + i] + (h[AE + i] - h[AD + i]) * h[AMKI + i]), 5)) }
    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KU + i] = iff(h[KI + i].isZero, Double.zero, round((h[GL + i] + (h[IH + i] - h[GL + i]) * h[AMKI + i]) - (h[AD + i] + (h[AE + i] - h[AD + i]) * h[AMKI + i]), 5)) }
    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KV + i] = iff(h[KI + i].isZero, Double.zero, round((h[GN + i] + (h[IJ + i] - h[GN + i]) * h[AMKI + i]) - (h[AF + i] + (h[AG + i] - h[AF + i]) * h[AMKI + i]), 5)) }
    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KW + i] = iff(h[KI + i].isZero, Double.zero, round((h[GO + i] + (h[IK + i] - h[GO + i]) * h[AMKI + i]) - (h[AF + i] + (h[AG + i] - h[AF + i]) * h[AMKI + i]), 5)) }
    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KX + i] = iff(h[KI + i].isZero, Double.zero, round((h[GQ + i] + (h[IM + i] - h[GQ + i]) * h[AMKI + i]) - (h[AH + i] + (h[AI + i] - h[AH + i]) * h[AMKI + i]), 5)) }
    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { h[KY + i] = iff(h[KI + i].isZero, Double.zero, round((h[GR + i] + (h[IN + i] - h[GR + i]) * h[AMKI + i]) - (h[AH + i] + (h[AI + i] - h[AH + i]) * h[AMKI + i]), 5)) }
    /// Opt harm op period op during night prio operation
    // KZ=IF(OR(JP6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      h[KZ + i] = iff(
        or(h[JP + i].isZero, h[KJ + i] < Double.zero, h[KL + i] < Double.zero, h[KN + i] < Double.zero, h[KP + i] < Double.zero, h[KR + i] < Double.zero, h[KT + i] < Double.zero, h[KV + i] < Double.zero, h[KX + i] < 0),
        Double.zero,
        min(
          1, ifFinite(h[KJ + i] / max(Double.zero, h[KJ + i] - h[KK + i]), 1.0), ifFinite(h[KL + i] / max(Double.zero, h[KL + i] - h[KM + i]), 1.0), ifFinite(h[KN + i] / max(Double.zero, h[KN + i] - h[KO + i]), 1.0),
          ifFinite(h[KP + i] / max(Double.zero, h[KP + i] - h[KQ + i]), 1.0), ifFinite(h[KR + i] / max(Double.zero, h[KR + i] - h[KS + i]), 1.0), ifFinite(h[KT + i] / max(Double.zero, h[KT + i] - h[KU + i]), 1.0),
          ifFinite(h[KV + i] / max(Double.zero, h[KV + i] - h[KW + i]), 1.0), ifFinite(h[KX + i] / max(Double.zero, h[KX + i] - h[KY + i]), 1.0)) * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }
  }
}
