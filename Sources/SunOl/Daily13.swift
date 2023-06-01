extension TunOl {
  func d13(_ d13: inout [Double], case j: Int) {
    let (
      Z, AA, AB, AC, AD, AE, AF, AG, AH, AI, AM, _, _, _, _, _, _, _, _, _, _, _, _, FK, _, _, _, _, _, _, _, FS, FT, _, FV, FW, _, FY, FZ, GA, _, _, _, GE, GF, GG, GH, GI, _, GK, GL, _, GN, GO, _, GQ, GR, _, _, _, _, _, _, _, _, _, _, _, _, _,
      HG, _, _, _, _, _, _, _, HO, HP, _, HR, HS, _, HU, HV, HW, _, _, _, IA, IB, IC, ID, IE, _, IG, IH, _, IJ, IK, _, IM, IN, _, IQ, IR, IS, IT, IU, IV, IW, IX, IY, IZ, JA, JB, JC, JD, JE, JF, JG, JH, JI, JJ, JK, JL, JM, JN, _, JP, JQ, JR, JS,
      JT, JU, JV, JW, JX, JY, JZ, KA, KB, KC, KD, KE, KF, KG, _, KI, KJ, KK, KL, KM, KN, KO, KP, KQ, KR, KS, KT, KU, KV, KW, KX, KY, KZ
    ) = (
      8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775, 13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155, 17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805, 21170, 21535,
      21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820, 25185, 25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200, 29565, 29930, 30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580, 33945, 34310,
      34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230, 37595, 37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610, 41975, 42340, 42705, 43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625, 45990, 46355, 46720,
      47085, 47450, 48180, 48545, 48910, 49275, 49640, 50005, 50370, 50735, 51100, 51465, 51830, 52195, 52560, 52925, 53290, 53655, 54020, 54385, 54750, 55115, 55480, 55845, 56210, 56575, 56940, 57305, 57670, 58035, 58400, 58765, 59130, 59495,
      59860, 60225, 60590, 60955, 61320, 61685, 62050, 62415, 62780, 63145, 63510, 63875, 64240, 64605, 64970, 65335, 65700, 66065, 66430, 66795, 67160, 67525, 67890, 68255, 68620, 68985, 69350, 69715, 70080, 70445
    )

    /// Surplus harm op period electricity after min harm op and min night op prep
    // =FS6+GE6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IQ + i] =
        d13[FS + i] + d13[GE + i] - d13[Z + i] - min(d13[GH + i], max(Double.zero, d13[AB + i] - d13[FV + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op period electricity after min harm op and max night op prep
    // =HO6+IA6-$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IR + i] =
        d13[HO + i] + d13[IA + i] - d13[AA + i] - min(d13[ID + i], max(Double.zero, d13[AC + i] - d13[HR + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op period electricity after max harm op and min night op prep
    // =FT6+GF6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff
    for i in 0..<365 {
      d13[IS + i] =
        d13[FT + i] + d13[GF + i] - d13[Z + i] - min(d13[GI + i], max(Double.zero, d13[AB + i] - d13[FW + i]) / El_boiler_eff) - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    // =FV6+MIN(GH6,MAX(0,FS6+GE6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      d13[IT + i] =
        d13[FV + i] + min(d13[GH + i], max(Double.zero, d13[FS + i] + d13[GE + i] - d13[Z + i] - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d13[AB + i]
    }
    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    // =HR6+MIN(ID6,MAX(0,HO6+IA6-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6
    for i in 0..<365 {
      d13[IU + i] =
        d13[HR + i] + min(d13[ID + i], max(Double.zero, d13[HO + i] + d13[IA + i] - d13[AA + i] - min(BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d13[AC + i]
    }
    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    // =FW6+MIN(GI6,MAX(0,FT6+GF6-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 {
      d13[IV + i] =
        d13[FW + i] + min(d13[GI + i], max(Double.zero, d13[FT + i] + d13[GF + i] - d13[Z + i] - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d13[AB + i]
    }
    /// Surplus el boiler cap after min harm op and min night op prep
    // =IF(El_boiler_cap_ud=0,0,GH6-MAX(0,$AB6-FV6)/El_boiler_eff)
    for i in 0..<365 { d13[IW + i] = d13[GH + i] - max(Double.zero, d13[AB + i] - d13[FV + i]) / El_boiler_eff }
    /// Surplus el boiler cap after min harm op and max night op prep
    // =IF(El_boiler_cap_ud=0,0,ID6-MAX(0,$AC6-HR6)/El_boiler_eff)
    for i in 0..<365 { d13[IX + i] = d13[ID + i] - max(Double.zero, d13[AC + i] - d13[HR + i]) / El_boiler_eff }
    /// Surplus el boiler cap after max harm op and min night op prep
    // =IF(BESS_cap_ud=0,0,FY6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
    for i in 0..<365 { d13[IY + i] = d13[GI + i] - max(Double.zero, d13[AB + i] - d13[FW + i]) / El_boiler_eff }
    /// Surplus BESS chrg cap after min harm op and min night op prep
    /// Surplus BESS chrg cap after min harm op and max night op prep
    /// Surplus BESS chrg cap after max harm op and min night op prep
    for i in 0..<365 {
      // =IF(BESS_cap_ud=0,0,FY6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
      d13[IZ + i] = d13[FY + i] - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =IF(BESS_cap_ud=0,0,HU6-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff)
      d13[JA + i] = d13[HU + i] - min(BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff
      // =IF(BESS_cap_ud=0,0,FZ6-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff)
      d13[JB + i] = d13[FZ + i] - min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff
    }
    /// Surplus Grid input cap after min harm op and min night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,GE6-MAX(0,-(FS6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      d13[JC + i] = iff(
        (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero, Double.zero,
        d13[GE + i]
          - max(
            0,
            -(d13[FS + i] - d13[Z + i] - min(d13[GH + i], max(Double.zero, d13[AB + i] - d13[FV + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after min harm op and max night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,IA6-MAX(0,-(HO6-$AA6-MIN(ID6,MAX(0,$AC6-HR6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      d13[JD + i] = iff(
        (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero, Double.zero,
        d13[IA + i]
          - max(
            0,
            -(d13[HO + i] - d13[AA + i] - min(d13[ID + i], max(Double.zero, d13[AC + i] - d13[HR + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after max harm op and min night op prep
    /// =IF(Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0,0,GF6-MAX(0,-(FT6-$Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)))
    for i in 0..<365 {
      d13[JE + i] = iff(
        (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero, Double.zero,
        d13[GF + i]
          - max(
            0,
            -(d13[FT + i] - d13[Z + i] - min(d13[GI + i], max(Double.zero, d13[AB + i] - d13[FW + i]) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)))
    }
    /// Surplus RawMeth prod cap after min harm op and min night op prep
    // JF=GK6-$AD6
    for i in 0..<365 { d13[JF + i] = d13[GK + i] - d13[AD + i] }
    /// Surplus RawMeth prod cap after min harm op and max night op prep
    // =IG6-$AE6
    for i in 0..<365 { d13[JG + i] = d13[IG + i] - d13[AE + i] }
    /// Surplus RawMeth prod cap after max harm op and min night op prep
    // JH=GL6-$AD6
    for i in 0..<365 { d13[JH + i] = d13[GL + i] - d13[AD + i] }
    /// Surplus CO2 prod cap after min harm op and min night op prep
    // JI=GN6-$AF6
    for i in 0..<365 { d13[JI + i] = d13[GN + i] - d13[AF + i] }
    /// Surplus CO2 prod cap after min harm op and max night op prep
    // JJ=IJ6-$AG6
    for i in 0..<365 { d13[JJ + i] = d13[IJ + i] - d13[AG + i] }
    /// Surplus CO2 prod cap after max harm op and min night op prep
    // JK=GO6-$AF6
    for i in 0..<365 { d13[JK + i] = d13[GO + i] - d13[AF + i] }
    /// Surplus H2 prod cap after min harm op and min night op prep
    // JL=GQ6-$AH6
    for i in 0..<365 { d13[JL + i] = d13[GQ + i] - d13[AH + i] }
    /// Surplus H2 prod cap after min harm op and max night op prep
    // JM=IM6-$AI6
    for i in 0..<365 { d13[JM + i] = d13[IM + i] - d13[AI + i] }
    /// Surplus H2 prod cap after max harm op and min night op prep
    // JN=GR6-$AH6
    for i in 0..<365 { d13[JN + i] = d13[GR + i] - d13[AH + i] }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    // JP=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      if i + JP  == 57614 {
        
      }
      d13[JP + i] = iff(
        or(d13[AM + i].isZero, d13[IQ + i] < Double.zero, d13[IT + i] < Double.zero, d13[IW + i] < Double.zero, d13[IZ + i] < Double.zero, d13[JC + i] < Double.zero, d13[JF + i] < Double.zero, d13[JI + i] < Double.zero, d13[JL + i] < 0),
        Double.zero,
        min(
          1, ifFinite(d13[IQ + i] / max(Double.zero, d13[IQ + i] - d13[IS + i]), 1.0), ifFinite(d13[IT + i] / max(Double.zero, d13[IT + i] - d13[IV + i]), 1.0), ifFinite(d13[IW + i] / max(Double.zero, d13[IW + i] - d13[IY + i]), 1.0),
          ifFinite(d13[IZ + i] / max(Double.zero, d13[IZ + i] - d13[JB + i]), 1.0), ifFinite(d13[JC + i] / max(Double.zero, d13[JC + i] - d13[JE + i]), 1.0), ifFinite(d13[JF + i] / max(Double.zero, d13[JF + i] - d13[JH + i]), 1.0),
          ifFinite(d13[JI + i] / max(Double.zero, d13[JI + i] - d13[JK + i]), 1.0), ifFinite(d13[JL + i] / max(Double.zero, d13[JL + i] - d13[JN + i]), 1.0)) * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }
    let dJP: Int = 70810  // LA
    for i in 0..<365 { d13[dJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (d13[JP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }
    /// Surplus harm op period electricity after opt harmonious and min night op prep
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JQ + i] = iff(
        d13[JP + i].isZero, Double.zero,
        round(
          (d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[dJP + i]) + (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[dJP + i]) - d13[Z + i]
            - min((d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[dJP + i]), max(Double.zero, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[dJP + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus harm op period electricity after opt harmonious and max night op prep
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JR + i] = iff(
        d13[JP + i].isZero, Double.zero,
        round(
          (d13[HO + i] + (d13[HP + i] - d13[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))
            + (d13[IA + i] + (d13[IB + i] - d13[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) - d13[AA + i]
            - min(
              (d13[ID + i] + (d13[IE + i] - d13[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)),
              max(Double.zero, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB6,5))
    for i in 0..<365 {
      d13[JS + i] = iff(
        d13[JP + i].isZero, Double.zero,
        round(
          (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[dJP + i]) + min(
            (d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[dJP + i]),
            max(Double.zero, (d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[dJP + i]) + (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[dJP + i]) - d13[Z + i]) * El_boiler_eff
              - min((d13[FY + i] + (d13[FZ + i] - d13[FY + i]) * d13[dJP + i]), min(BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d13[AB + i], 5))
    }
    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC6,5))
    for i in 0..<365 {
      d13[JT + i] = iff(
        d13[JP + i].isZero, Double.zero,
        round(
          (d13[HR + i] + (d13[HS + i] - d13[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) + min(
            d13[ID + i] + (d13[IE + i] - d13[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc),
            max(
              Double.zero,
              (d13[HO + i] + (d13[HP + i] - d13[HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))
                + (d13[IA + i] + (d13[IB + i] - d13[IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) - d13[AA + i] - min(
                  BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff - d13[AC + i], 5))
    }
    /// Surplus el boiler cap after opt day harm and min night op prep
    // JU=IF(OR(JP6=0,El_boiler_cap_ud=0),0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JU + i] = iff(
        or(d13[JP + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[dJP + i]) - max(Double.zero, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[dJP + i])) / El_boiler_eff, 5))
    }
    /// Surplus el boiler cap after opt day harm and max night op prep
    // JV=IF(OR(JP6=0,El_boiler_cap_ud=0),0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JV + i] = iff(
        or(d13[JP + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round(
          (d13[ID + i] + (d13[IE + i] - d13[ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc)) - max(
            Double.zero, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc))) / El_boiler_eff, 5))
    }
    /// Surplus BESS chrg cap after opt day harm and min night op prep
    // JW=IF(OR(JP6=0,BESS_cap_ud=0),0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,FK6-GG6-GA6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JW + i] = iff(
        or(d13[JP + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round((d13[FY + i] + (d13[FZ + i] - d13[FY + i]) * d13[dJP + i]) - min(El_boiler_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus BESS chrg cap after opt day harm and max night op prep
    // JX=IF(OR(JP6=0,BESS_cap_ud=0),0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,HG6-IC6-HW6*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JX + i] = iff(
        or(d13[JP + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round((d13[HU + i] + (d13[HV + i] - d13[HU + i]) * d13[dJP + i]) - min(El_boiler_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    /// Surplus grid import cap after opt day harm and min night op prep
    // JY=IF(OR(JP6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MIN((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK6-GG6-GA6*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[JY + i] = iff(
        or(d13[JP + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[dJP + i])
            - max(
              Double.zero,
              -((d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[dJP + i]) - d13[Z + i]
                - min((d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[dJP + i]), max(Double.zero, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[dJP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(Double.zero, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    /// Surplus grid import cap after opt day harm and max night op prep
    // JZ=IF(OR(JP6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AA6-MIN((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,$AC6-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG6-IC6-HW6*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[JZ + i] = iff(
        or(d13[JP + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (d13[IA + i] + (d13[IB + i] - d13[IA + i]) * d13[dJP + i])
            - max(
              Double.zero,
              -((d13[HO + i] + (d13[HP + i] - d13[HO + i]) * d13[dJP + i]) - d13[AA + i]
                - min((d13[ID + i] + (d13[IE + i] - d13[ID + i]) * d13[dJP + i]), max(Double.zero, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) * d13[dJP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(Double.zero, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    // KA=IF(JP6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AD6,5))
    for i in 0..<365 {
      d13[KA + i] = iff(d13[JP + i].isZero, Double.zero, round(d13[GK + i] + (d13[GL + i] - d13[GK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d13[AD + i], 5))
    }
    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    // KB=IF(JP6=0,0,ROUND(IG6+(IH6-IG6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AE6,5))
    for i in 0..<365 {
      d13[KB + i] = iff(d13[JP + i].isZero, Double.zero, round(d13[IG + i] + (d13[IH + i] - d13[IG + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d13[AE + i], 5))
    }
    /// Surplus CO2 prod cap after opt day harm and min night op prep
    // KC=IF(JP6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AF6,5))
    for i in 0..<365 {
      d13[KC + i] = iff(d13[JP + i].isZero, Double.zero, round(d13[GN + i] + (d13[GO + i] - d13[GN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d13[AF + i], 5))
    }
    /// Surplus CO2 prod cap after opt day harm and max night op prep
    // KD=IF(JP6=0,0,ROUND(IJ6+(IK6-IJ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AG6,5))
    for i in 0..<365 {
      d13[KD + i] = iff(d13[JP + i].isZero, Double.zero, round(d13[IJ + i] + (d13[IK + i] - d13[IJ + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (d13[JP + i] - Overall_harmonious_min_perc) - d13[AG + i], 5))
    }
    /// Surplus H2 prod cap after opt day harm and min night op prep
    // KE=IF(JP6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AH6,5))
    for i in 0..<365 { d13[KE + i] = iff(d13[JP + i].isZero, Double.zero, round((d13[GQ + i] + (d13[GR + i] - d13[GQ + i]) * d13[dJP + i]) - d13[AH + i], 5)) }
    /// Surplus H2 prod cap after opt day harm and max night op prep
    // KF=IF(JP6=0,0,ROUND(IM6+(IN6-IM6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-$AI6,5))
    for i in 0..<365 { d13[KF + i] = iff(d13[JP + i].isZero, Double.zero, round(d13[IM + i] + (d13[IN + i] - d13[IM + i]) * d13[dJP + i] - d13[AI + i], 5)) }
    /// Opt night prep during day prio operation
    // KG=IF(OR($AM6=0,JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[KG + i] = iff(
        or(
          d13[AM + i].isZero, d13[JP + i].isZero, d13[JQ + i] < Double.zero, d13[JS + i] < Double.zero, d13[JU + i] < Double.zero, d13[JW + i] < Double.zero, d13[JY + i] < Double.zero, d13[KA + i] < Double.zero, d13[KC + i] < Double.zero,
          d13[KE + i] < Double.zero), Double.zero,
        min(
          1, ifFinite(d13[JQ + i] / max(Double.zero, d13[JQ + i] - d13[JR + i]), 1.0), ifFinite(d13[JS + i] / max(Double.zero, d13[JS + i] - d13[JT + i]), 1.0), ifFinite(d13[JU + i] / max(Double.zero, d13[JU + i] - d13[JV + i]), 1.0),
          ifFinite(d13[JW + i] / max(Double.zero, d13[JW + i] - d13[JX + i]), 1.0), ifFinite(d13[JY + i] / max(Double.zero, d13[JY + i] - d13[JZ + i]), 1.0), ifFinite(d13[KA + i] / max(Double.zero, d13[KA + i] - d13[KB + i]), 1.0),
          ifFinite(d13[KC + i] / max(Double.zero, d13[KC + i] - d13[KD + i]), 1.0), ifFinite(d13[KE + i] / max(Double.zero, d13[KE + i] - d13[KF + i]), 1.0)) * (d13[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    // KI=IF(OR($AM6=0,IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d13[KI + i] = iff(
        or(d13[AM + i].isZero, d13[IQ + i] < Double.zero, d13[IT + i] < Double.zero, d13[IW + i] < Double.zero, d13[IZ + i] < Double.zero, d13[JC + i] < Double.zero, d13[JF + i] < Double.zero, d13[JI + i] < Double.zero, d13[JL + i] < 0),
        Double.zero,
        min(
          1, ifFinite(d13[IQ + i] / max(Double.zero, d13[IQ + i] - d13[IR + i]), 1.0), ifFinite(d13[IT + i] / max(Double.zero, d13[IT + i] - d13[IU + i]), 1.0), ifFinite(d13[IW + i] / max(Double.zero, d13[IW + i] - d13[IX + i]), 1.0),
          ifFinite(d13[IZ + i] / max(Double.zero, d13[IZ + i] - d13[JA + i]), 1.0), ifFinite(d13[JC + i] / max(Double.zero, d13[JC + i] - d13[JD + i]), 1.0), ifFinite(d13[JF + i] / max(Double.zero, d13[JF + i] - d13[JG + i]), 1.0),
          ifFinite(d13[JI + i] / max(Double.zero, d13[JI + i] - d13[JJ + i]), 1.0), ifFinite(d13[JL + i] / max(Double.zero, d13[JL + i] - d13[JM + i]), 1.0)) * (d13[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    let (AMKG, AMKI) = (56940, 63875)
    for i in 0..<365 {
      d13[AMKG + i] = (d13[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KG + i] - equiv_harmonious_min_perc[j]) / (d13[AM + i] - equiv_harmonious_min_perc[j])
      d13[AMKI + i] = (d13[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KI + i] - equiv_harmonious_min_perc[j]) / (d13[AM + i] - equiv_harmonious_min_perc[j])
    }
    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KJ + i] = iff(
        d13[KI + i].isZero, Double.zero,
        round(
          (d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[AMKI + i]) + (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i])
            - min((d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]), max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i]) - (d13[GA + i] + (d13[HW + i] - d13[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KK + i] = iff(
        d13[KI + i].isZero, Double.zero,
        round(
          (d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[AMKI + i]) + (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i])
            - min((d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]), max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[AMKI + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i]) - (d13[GA + i] + (d13[HW + i] - d13[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KL + i] = iff(
        d13[KI + i].isZero, Double.zero,
        round(
          (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[AMKI + i])
            + min(
              (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]),
              (max(Double.zero, (d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[AMKI + i]) + (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i]))) * El_boiler_eff)
            - min(
              (d13[FY + i] + (d13[HU + i] - d13[FY + i]) * d13[AMKI + i]),
              min(BESS_cap_ud, max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i])) / BESS_chrg_eff))
            - (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]), 5))
    }
    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      d13[KM + i] = iff(
        d13[KI + i].isZero, Double.zero,
        round(
          (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[AMKI + i])
            + min(
              (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]),
              (max(Double.zero, (d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[AMKI + i]) + (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i]))) * El_boiler_eff
                - min(
                  (d13[FZ + i] + (d13[HV + i] - d13[FZ + i]) * d13[AMKI + i]),
                  min(BESS_cap_ud, max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i]))) / BESS_chrg_eff))
            - (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]), 5))
    }
    /// Surplus el boiler cap after min day harmonious and opti night op prep
    // KN=IF(OR(KI6=0,El_boiler_cap_ud=0),0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KN + i] = iff(
        or(d13[KI + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]) - max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[AMKI + i])) / El_boiler_eff, 5))
    }
    /// Surplus el boiler cap after max day harmonious and opti night op prep
    // KO=IF(OR(KI6=0,El_boiler_cap_ud=0),0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KO + i] = iff(
        or(d13[KI + i].isZero, El_boiler_cap_ud.isZero), Double.zero,
        round((d13[GI + i] + (d13[IE + i] - d13[GI + i]) * d13[AMKI + i]) - max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[AMKI + i])) / El_boiler_eff, 5))
    }
    /// Surplus BESS cap after min day harmonious and opti night op prep
    // KP=IF(OR(KI6=0,BESS_cap_ud=0),0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KP + i] = iff(
        or(d13[KI + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round(
          (d13[FY + i] + (d13[HU + i] - d13[FY + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - max(
            Double.zero,
            (d13[FK + i] + (d13[HG + i] - d13[FK + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
              - min(BESS_cap_ud, (d13[GG + i] + (d13[IC + i] - d13[GG + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - (d13[GA + i] + (d13[HW + i] - d13[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus BESS cap after max day harmonious and opti night op prep
    // KQ=IF(OR(KI6=0,BESS_cap_ud=0),0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KQ + i] = iff(
        or(d13[KI + i].isZero, BESS_cap_ud.isZero), Double.zero,
        round(
          (d13[FZ + i] + (d13[HV + i] - d13[FZ + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - max(
            Double.zero,
            (d13[FK + i] + (d13[HG + i] - d13[FK + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j]))
              - min(BESS_cap_ud, (d13[GG + i] + (d13[IC + i] - d13[GG + i]) / (d13[AM + i] - equiv_harmonious_min_perc[j]) * (d13[KI + i] - equiv_harmonious_min_perc[j])) - (d13[GA + i] + (d13[HW + i] - d13[GA + i])) * BESS_chrg_eff))
            / BESS_chrg_eff, 5))
    }
    /// Surplus grid import cap after min day harmonious and opti night op prep
    // KR=IF(OR(KI6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[KR + i] = iff(
        or(d13[KI + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[AMKI + i])
            - max(
              Double.zero,
              -((d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i])
                - min((d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[AMKI + i]), max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[AMKI + i])) / El_boiler_eff)
                - min(
                  BESS_cap_ud,
                  max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i]) - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[AMKI + i]) * BESS_chrg_eff))
                / BESS_chrg_eff)), 5))
    }
    /// Surplus grid import cap after max day harmonious and opti night op prep
    // KS=IF(OR(KI6=0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MIN((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),MAX(0,($AB6+($AC6-$AB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GA6+(HW6-GA6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[KS + i] = iff(
        or(d13[KI + i].isZero, (Grid_import_max_ud * Grid_import_yes_no_PB_strategy).isZero), Double.zero,
        round(
          (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[AMKI + i])
            - max(
              Double.zero,
              -((d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[AMKI + i]) - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[AMKI + i])
                - min((d13[GI + i] + (d13[IR + i] - d13[GI + i]) * d13[AMKI + i]), max(Double.zero, (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[AMKI + i]) - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[AMKI + i])) / El_boiler_eff)
                - min(
                  BESS_cap_ud,
                  max(Double.zero, (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[AMKI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[AMKI + i]) - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[AMKI + i]) * BESS_chrg_eff))
                / BESS_chrg_eff)), 5))
    }
    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KT + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GK + i] + (d13[IG + i] - d13[GK + i]) * d13[AMKI + i]) - (d13[AD + i] + (d13[AE + i] - d13[AD + i]) * d13[AMKI + i]), 5)) }
    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KU + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GL + i] + (d13[IH + i] - d13[GL + i]) * d13[AMKI + i]) - (d13[AD + i] + (d13[AE + i] - d13[AD + i]) * d13[AMKI + i]), 5)) }
    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KV + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GN + i] + (d13[IJ + i] - d13[GN + i]) * d13[AMKI + i]) - (d13[AF + i] + (d13[AG + i] - d13[AF + i]) * d13[AMKI + i]), 5)) }
    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KW + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GO + i] + (d13[IK + i] - d13[GO + i]) * d13[AMKI + i]) - (d13[AF + i] + (d13[AG + i] - d13[AF + i]) * d13[AMKI + i]), 5)) }
    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KX + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GQ + i] + (d13[IM + i] - d13[GQ + i]) * d13[AMKI + i]) - (d13[AH + i] + (d13[AI + i] - d13[AH + i]) * d13[AMKI + i]), 5)) }
    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 { d13[KY + i] = iff(d13[KI + i].isZero, Double.zero, round((d13[GR + i] + (d13[IN + i] - d13[GR + i]) * d13[AMKI + i]) - (d13[AH + i] + (d13[AI + i] - d13[AH + i]) * d13[AMKI + i]), 5)) }
    /// Opt harm op period op during night prio operation
    // KZ=IF(OR(JP6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      d13[KZ + i] = iff(
        or(d13[JP + i].isZero, d13[KJ + i] < Double.zero, d13[KL + i] < Double.zero, d13[KN + i] < Double.zero, d13[KP + i] < Double.zero, d13[KR + i] < Double.zero, d13[KT + i] < Double.zero, d13[KV + i] < Double.zero, d13[KX + i] < 0),
        Double.zero,
        min(
          1, ifFinite(d13[KJ + i] / max(Double.zero, d13[KJ + i] - d13[KK + i]), 1.0), ifFinite(d13[KL + i] / max(Double.zero, d13[KL + i] - d13[KM + i]), 1.0), ifFinite(d13[KN + i] / max(Double.zero, d13[KN + i] - d13[KO + i]), 1.0),
          ifFinite(d13[KP + i] / max(Double.zero, d13[KP + i] - d13[KQ + i]), 1.0), ifFinite(d13[KR + i] / max(Double.zero, d13[KR + i] - d13[KS + i]), 1.0), ifFinite(d13[KT + i] / max(Double.zero, d13[KT + i] - d13[KU + i]), 1.0),
          ifFinite(d13[KV + i] / max(Double.zero, d13[KV + i] - d13[KW + i]), 1.0), ifFinite(d13[KX + i] / max(Double.zero, d13[KX + i] - d13[KY + i]), 1.0)) * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }
  }
}
