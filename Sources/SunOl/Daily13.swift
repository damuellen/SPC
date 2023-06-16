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
    // Optimal harmonious day prod after min night prep due to prod cap limits
    // JP=IF(OR($AM3=0,IQ3<0,IT3<0,IW3<0,IZ3<0,JC3<0,JF3<0,JI3<0,JL3<0),-1,MIN(1,IFERROR(IQ3/MAX(0,IQ3-IS3),1),IFERROR(IT3/MAX(0,IT3-IV3),1),IFERROR(IW3/MAX(0,IW3-IY3),1),IFERROR(IZ3/MAX(0,IZ3-JB3),1),IFERROR(JC3/MAX(0,JC3-JE3),1),IFERROR(JF3/MAX(0,JF3-JH3),1),IFERROR(JI3/MAX(0,JI3-JK3),1),IFERROR(JL3/MAX(0,JL3-JN3),1)))
    for i in 0..<365 {
      d13[JP + i] = iff(
        or(
          d13[AM + i] == Double.zero, d13[IQ + i] < 0, d13[IT + i] < 0, d13[IW + i] < 0, d13[IZ + i] < 0, d13[JC + i] < 0,
          d13[JF + i] < 0, d13[JI + i] < 0, d13[JL + i] < 0), -1,
        min(
          1, ifFinite(d13[IQ + i] / max(0, d13[IQ + i] - d13[IS + i]), 1),
          ifFinite(d13[IT + i] / max(0, d13[IT + i] - d13[IV + i]), 1),
          ifFinite(d13[IW + i] / max(0, d13[IW + i] - d13[IY + i]), 1),
          ifFinite(d13[IZ + i] / max(0, d13[IZ + i] - d13[JB + i]), 1),
          ifFinite(d13[JC + i] / max(0, d13[JC + i] - d13[JE + i]), 1),
          ifFinite(d13[JF + i] / max(0, d13[JF + i] - d13[JH + i]), 1),
          ifFinite(d13[JI + i] / max(0, d13[JI + i] - d13[JK + i]), 1),
          ifFinite(d13[JL + i] / max(0, d13[JL + i] - d13[JN + i]), 1)))
    }
    let dJP: Int = 70810  // LA
    for i in 0..<365 {
      d13[dJP + i] =
        Overall_harmonious_range < 1E-10 ? 1 : (d13[JP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range
    }
    // Surplus harm op period electricity after opt harmonious and min night op prep
    // JQ=IF(JP3<0,0,ROUND((FS3+(FT3-FS3)*JP3)+(GE3+(GF3-GE3)*JP3)-$Z3-MIN((GH3+(GI3-GH3)*JP3),MAX(0,$AB3-(FV3+(FW3-FV3)*JP3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK3-GG3-GA3*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JQ + i] = iff(
        d13[JP + i] < 0, 0,
        round(
          (d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[JP + i]) + (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[JP + i])
            - d13[Z + i]
            - min(
              (d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[JP + i]),
              max(0, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[JP + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(0, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    // Surplus harm op period electricity after opt harmonious and max night op prep
    // JR=IF(JP3<0,0,ROUND((HO3+(HP3-HO3)*JP3)+(IA3+(IB3-IA3)*JP3)-$AA3-MIN((ID3+(IE3-ID3)*JP3),MAX(0,$AC3-(HR3+(HS3-HR3)*JP3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG3-IC3-HW3*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JR + i] = iff(
        d13[JP + i] < 0, 0,
        round(
          (d13[HO + i] + (d13[HP + i] - d13[HO + i]) * d13[JP + i]) + (d13[IA + i] + (d13[IB + i] - d13[IA + i]) * d13[JP + i])
            - d13[AA + i]
            - min(
              (d13[ID + i] + (d13[IE + i] - d13[ID + i]) * d13[JP + i]),
              max(0, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) * d13[JP + i])) / El_boiler_eff) - min(
              BESS_cap_ud, max(0, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    // Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    // JS=IF(JP3<0,0,ROUND((FV3+(FW3-FV3)*JP3)+MIN((GH3+(GI3-GH3)*JP3),MAX(0,(FS3+(FT3-FS3)*JP3)+(GE3+(GF3-GE3)*JP3)-$Z3-MIN(BESS_cap_ud,MAX(0,FK3-GG3-GA3*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AB3,5))
    for i in 0..<365 {
      d13[JS + i] = iff(
        d13[JP + i] < 0, 0,
        round(
          (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[JP + i]) + min(
            (d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[JP + i]),
            max(
              0,
              (d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[JP + i])
                + (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[JP + i]) - d13[Z + i] - min(
                  BESS_cap_ud, max(0, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff
            - d13[AB + i], 5))
    }
    // Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    // JT=IF(JP3<0,0,ROUND((HR3+(HS3-HR3)*JP3)+MIN((ID3+(IE3-ID3)*JP3),MAX(0,(HO3+(HP3-HO3)*JP3)+(IA3+(IB3-IA3)*JP3)-$AA3-MIN(BESS_cap_ud,MAX(0,HG3-IC3-HW3*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-$AC3,5))
    for i in 0..<365 {
      d13[JT + i] = iff(
        d13[JP + i] < 0, 0,
        round(
          (d13[HR + i] + (d13[HS + i] - d13[HR + i]) * d13[JP + i]) + min(
            (d13[ID + i] + (d13[IE + i] - d13[ID + i]) * d13[JP + i]),
            max(
              0,
              (d13[HO + i] + (d13[HP + i] - d13[HO + i]) * d13[JP + i])
                + (d13[IA + i] + (d13[IB + i] - d13[IA + i]) * d13[JP + i]) - d13[AA + i] - min(
                  BESS_cap_ud, max(0, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)) * El_boiler_eff
            - d13[AC + i], 5))
    }
    // Surplus el boiler cap after opt day harm and min night op prep
    // JU=IF(OR(JP3<0,El_boiler_cap_ud=0),0,ROUND((GH3+(GI3-GH3)*JP3)-MAX(0,$AB3-(FV3+(FW3-FV3)*JP3))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JU + i] = iff(
        or(d13[JP + i] < 0, El_boiler_cap_ud == Double.zero), 0,
        round(
          (d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[JP + i]) - max(
            0, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[JP + i])) / El_boiler_eff, 5))
    }
    // Surplus el boiler cap after opt day harm and max night op prep
    // JV=IF(OR(JP3<0,El_boiler_cap_ud=0),0,ROUND((ID3+(IE3-ID3)*JP3)-MAX(0,$AC3-(HR3+(HS3-HR3)*JP3))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[JV + i] = iff(
        or(d13[JP + i] < 0, El_boiler_cap_ud == Double.zero), 0,
        round(
          (d13[ID + i] + (d13[IE + i] - d13[ID + i]) * d13[JP + i]) - max(
            0, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) * d13[JP + i])) / El_boiler_eff, 5))
    }
    // Surplus BESS chrg cap after opt day harm and min night op prep
    // JW=IF(OR(JP3<0,BESS_cap_ud=0),0,ROUND((FY3+(FZ3-FY3)*JP3)-MAX(0,FK3-GG3-GA3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JW + i] = iff(
        or(d13[JP + i] < 0, BESS_cap_ud == Double.zero), 0,
        round(
          (d13[FY + i] + (d13[FZ + i] - d13[FY + i]) * d13[JP + i]) - max(
            0, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }
    // Surplus BESS chrg cap after opt day harm and max night op prep
    // JX=IF(OR(JP3<0,BESS_cap_ud=0),0,ROUND((HU3+(HV3-HU3)*JP3)-MAX(0,HG3-IC3-HW3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[JX + i] = iff(
        or(d13[JP + i] < 0, BESS_cap_ud == Double.zero), 0,
        round(
          (d13[HU + i] + (d13[HV + i] - d13[HU + i]) * d13[JP + i]) - max(
            0, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }
    // Surplus grid import cap after opt day harm and min night op prep
    // JY=IF(OR(JP3<0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE3+(GF3-GE3)*JP3)-MAX(0,-((FS3+(FT3-FS3)*JP3)-$Z3-MIN((GH3+(GI3-GH3)*JP3),MAX(0,$AB3-(FV3+(FW3-FV3)*JP3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,FK3-GG3-GA3*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[JY + i] = iff(
        or(d13[JP + i] < 0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero), 0,
        round(
          (d13[GE + i] + (d13[GF + i] - d13[GE + i]) * d13[JP + i])
            - max(
              0,
              -((d13[FS + i] + (d13[FT + i] - d13[FS + i]) * d13[JP + i]) - d13[Z + i]
                - min(
                  (d13[GH + i] + (d13[GI + i] - d13[GH + i]) * d13[JP + i]),
                  max(0, d13[AB + i] - (d13[FV + i] + (d13[FW + i] - d13[FV + i]) * d13[JP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(0, d13[FK + i] - d13[GG + i] - d13[GA + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    // Surplus grid import cap after opt day harm and max night op prep
    // JZ=IF(OR(JP3<0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((IA3+(IB3-IA3)*JP3)-MAX(0,-((HO3+(HP3-HO3)*JP3)-$AA3-MIN((ID3+(IE3-ID3)*JP3),MAX(0,$AC3-(HR3+(HS3-HR3)*JP3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,HG3-IC3-HW3*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[JZ + i] = iff(
        or(d13[JP + i] < 0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero), 0,
        round(
          (d13[IA + i] + (d13[IB + i] - d13[IA + i]) * d13[JP + i])
            - max(
              0,
              -((d13[HO + i] + (d13[HP + i] - d13[HO + i]) * d13[JP + i]) - d13[AA + i]
                - min(
                  (d13[ID + i] + (d13[IE + i] - d13[ID + i]) * d13[JP + i]),
                  max(0, d13[AC + i] - (d13[HR + i] + (d13[HS + i] - d13[HR + i]) * d13[JP + i])) / El_boiler_eff) - min(
                  BESS_cap_ud, max(0, d13[HG + i] - d13[IC + i] - d13[HW + i] * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    // Surplus RawMeth prod cap after opt day harm and min night op prep
    // KA=IF(JP3<0,0,ROUND(GK3+(GL3-GK3)*JP3-$AD3,5))
    for i in 0..<365 {
      d13[KA + i] = iff(d13[JP + i] < 0, 0, round(d13[GK + i] + (d13[GL + i] - d13[GK + i]) * d13[JP + i] - d13[AD + i], 5))
    }

    // Surplus RawMeth prod cap after opt day harm and max night op prep
    // KB=IF(JP3<0,0,ROUND(IG3+(IH3-IG3)*JP3-$AE3,5))
    for i in 0..<365 {
      d13[KB + i] = iff(d13[JP + i] < 0, 0, round(d13[IG + i] + (d13[IH + i] - d13[IG + i]) * d13[JP + i] - d13[AE + i], 5))
    }
    // Surplus CO2 prod cap after opt day harm and min night op prep
    // KC=IF(JP3<0,0,ROUND(GN3+(GO3-GN3)*JP3-$AF3,5))
    for i in 0..<365 {
      d13[KC + i] = iff(d13[JP + i] < 0, 0, round(d13[GN + i] + (d13[GO + i] - d13[GN + i]) * d13[JP + i] - d13[AF + i], 5))
    }
    // Surplus CO2 prod cap after opt day harm and max night op prep
    // KD=IF(JP3<0,0,ROUND(IJ3+(IK3-IJ3)*JP3-$AG3,5))
    for i in 0..<365 {
      d13[KD + i] = iff(d13[JP + i] < 0, 0, round(d13[IJ + i] + (d13[IK + i] - d13[IJ + i]) * d13[JP + i] - d13[AG + i], 5))
    }
    // Surplus H2 prod cap after opt day harm and min night op prep
    // KE=IF(JP3<0,0,ROUND(GQ3+(GR3-GQ3)*JP3-$AH3,5))
    for i in 0..<365 {
      d13[KE + i] = iff(d13[JP + i] < 0, 0, round(d13[GQ + i] + (d13[GR + i] - d13[GQ + i]) * d13[JP + i] - d13[AH + i], 5))
    }
    // Surplus H2 prod cap after opt day harm and max night op prep
    // KF=IF(JP3<0,0,ROUND(IM3+(IN3-IM3)*JP3-$AI3,5))
    for i in 0..<365 {
      d13[KF + i] = iff(d13[JP + i] < 0, 0, round(d13[IM + i] + (d13[IN + i] - d13[IM + i]) * d13[JP + i] - d13[AI + i], 5))
    }
    // Opt night prep during day prio operation
    // KG=IF(OR(JP3<0,JQ3<0,JS3<0,JU3<0,JW3<0,JY3<0,KA3<0,KC3<0,KE3<0),-1,MIN(1,IFERROR(JQ3/MAX(0,JQ3-JR3),1),IFERROR(JS3/MAX(0,JS3-JT3),1),IFERROR(JU3/MAX(0,JU3-JV3),1),IFERROR(JW3/MAX(0,JW3-JX3),1),IFERROR(JY3/MAX(0,JY3-JZ3),1),IFERROR(KA3/MAX(0,KA3-KB3),1),IFERROR(KC3/MAX(0,KC3-KD3),1),IFERROR(KE3/MAX(0,KE3-KF3),1)))
    for i in 0..<365 {
      d13[KG + i] = iff(
        or(
          d13[JP + i] < 0, d13[JQ + i] < 0, d13[JS + i] < 0, d13[JU + i] < 0, d13[JW + i] < 0, d13[JY + i] < 0, d13[KA + i] < 0,
          d13[KC + i] < 0, d13[KE + i] < 0), -1,
        min(
          1, ifFinite(d13[JQ + i] / max(0, d13[JQ + i] - d13[JR + i]), 1),
          ifFinite(d13[JS + i] / max(0, d13[JS + i] - d13[JT + i]), 1),
          ifFinite(d13[JU + i] / max(0, d13[JU + i] - d13[JV + i]), 1),
          ifFinite(d13[JW + i] / max(0, d13[JW + i] - d13[JX + i]), 1),
          ifFinite(d13[JY + i] / max(0, d13[JY + i] - d13[JZ + i]), 1),
          ifFinite(d13[KA + i] / max(0, d13[KA + i] - d13[KB + i]), 1),
          ifFinite(d13[KC + i] / max(0, d13[KC + i] - d13[KD + i]), 1),
          ifFinite(d13[KE + i] / max(0, d13[KE + i] - d13[KF + i]), 1)))
    }
    // min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    // KI=IF(OR($AM3=0,IQ3<0,IT3<0,IW3<0,IZ3<0,JC3<0,JF3<0,JI3<0,JL3<0),-1,MIN(1,IFERROR(IQ3/MAX(0,IQ3-IR3),1),IFERROR(IT3/MAX(0,IT3-IU3),1),IFERROR(IW3/MAX(0,IW3-IX3),1),IFERROR(IZ3/MAX(0,IZ3-JA3),1),IFERROR(JC3/MAX(0,JC3-JD3),1),IFERROR(JF3/MAX(0,JF3-JG3),1),IFERROR(JI3/MAX(0,JI3-JJ3),1),IFERROR(JL3/MAX(0,JL3-JM3),1)))
    for i in 0..<365 {
      d13[KI + i] = iff(
        or(
          d13[AM + i] == Double.zero, d13[IQ + i] < 0, d13[IT + i] < 0, d13[IW + i] < 0, d13[IZ + i] < 0, d13[JC + i] < 0,
          d13[JF + i] < 0, d13[JI + i] < 0, d13[JL + i] < 0), -1,
        min(
          1, ifFinite(d13[IQ + i] / max(0, d13[IQ + i] - d13[IR + i]), 1),
          ifFinite(d13[IT + i] / max(0, d13[IT + i] - d13[IU + i]), 1),
          ifFinite(d13[IW + i] / max(0, d13[IW + i] - d13[IX + i]), 1),
          ifFinite(d13[IZ + i] / max(0, d13[IZ + i] - d13[JA + i]), 1),
          ifFinite(d13[JC + i] / max(0, d13[JC + i] - d13[JD + i]), 1),
          ifFinite(d13[JF + i] / max(0, d13[JF + i] - d13[JG + i]), 1),
          ifFinite(d13[JI + i] / max(0, d13[JI + i] - d13[JJ + i]), 1),
          ifFinite(d13[JL + i] / max(0, d13[JL + i] - d13[JM + i]), 1)))
    }

    // let (AMKG, AMKI) = (56940, 63875)
    // for i in 0..<365 {
    //   d13[AMKG + i] = (d13[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KG + i] - equiv_harmonious_min_perc[j]) / (d13[AM + i] - equiv_harmonious_min_perc[j])
    //   d13[AMKI + i] = (d13[AM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (d13[KI + i] - equiv_harmonious_min_perc[j]) / (d13[AM + i] - equiv_harmonious_min_perc[j])
    // }
    // Surplus harm op period electricity after min day harmonious and opti night op prep
    // KJ=IF(KI3<0,0,ROUND((FS3+(HO3-FS3)*KI3)+(GE3+(IA3-GE3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN((GH3+(ID3-GH3)*KI3),MAX(0,($AB3+($AC3-$AB3)*KI3)-(FV3+(HR3-FV3)*KI3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KJ + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[KI + i]) + (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[KI + i])
            - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i])
            - min(
              (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[KI + i]),
              max(
                0,
                (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i])
                  - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[KI + i])) / El_boiler_eff) - min(
              BESS_cap_ud,
              max(
                0,
                (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                  - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                  - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    // Surplus harm op period electricity after max day harmonious and opti night op prep
    // KK=IF(KI3<0,0,ROUND((FT3+(HP3-FT3)*KI3)+(GF3+(IB3-GF3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN((GI3+(IE3-GI3)*KI3),MAX(0,($AB3+($AC3-$AB3)*KI3)-(FW3+(HS3-FW3)*KI3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KK + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[KI + i]) + (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[KI + i])
            - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i])
            - min(
              (d13[GI + i] + (d13[IE + i] - d13[GI + i]) * d13[KI + i]),
              max(
                0,
                (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i])
                  - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[KI + i])) / El_boiler_eff) - min(
              BESS_cap_ud,
              max(
                0,
                (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                  - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                  - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff, 5))
    }
    // Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    // KL=IF(KI3<0,0,ROUND((FV3+(HR3-FV3)*KI3)+MIN((GH3+(ID3-GH3)*KI3),MAX(0,(FS3+(HO3-FS3)*KI3)+(GE3+(IA3-GE3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB3+($AC3-$AB3)*KI3),5))
    for i in 0..<365 {
      d13[KL + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[KI + i]) + min(
            (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[KI + i]),
            max(
              0,
              (d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[KI + i])
                + (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[KI + i])
                - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i]) - min(
                  BESS_cap_ud,
                  max(
                    0,
                    (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                      - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                      - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff))
            * El_boiler_eff - (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i]), 5))
    }
    // Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    // KM=IF(KI3<0,0,ROUND((FW3+(HS3-FW3)*KI3)+MIN((GI3+(IE3-GI3)*KI3),MAX(0,(FT3+(HP3-FT3)*KI3)+(GF3+(IB3-GF3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff))*El_boiler_eff-($AB3+($AC3-$AB3)*KI3),5))
    for i in 0..<365 {
      d13[KM + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[KI + i]) + min(
            (d13[GI + i] + (d13[IE + i] - d13[GI + i]) * d13[KI + i]),
            max(
              0,
              (d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[KI + i])
                + (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[KI + i])
                - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i]) - min(
                  BESS_cap_ud,
                  max(
                    0,
                    (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                      - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                      - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff))
            * El_boiler_eff - (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i]), 5))
    }
    // Surplus el boiler cap after min day harmonious and opti night op prep
    // KN=IF(OR(KI3<0,El_boiler_cap_ud=0),0,ROUND((GH3+(ID3-GH3)*KI3)-MAX(0,($AB3+($AC3-$AB3)*KI3)-(FV3+(HR3-FV3)*KI3))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KN + i] = iff(
        or(d13[KI + i] < 0, El_boiler_cap_ud == Double.zero), 0,
        round(
          (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[KI + i]) - max(
            0,
            (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i]) - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[KI + i])
          ) / El_boiler_eff, 5))
    }
    // Surplus el boiler cap after max day harmonious and opti night op prep
    // KO=IF(OR(KI3<0,El_boiler_cap_ud=0),0,ROUND((GI3+(IE3-GI3)*KI3)-MAX(0,($AB3+($AC3-$AB3)*KI3)-(FW3+(HS3-FW3)*KI3))/El_boiler_eff,5))
    for i in 0..<365 {
      d13[KO + i] = iff(
        or(d13[KI + i] < 0, El_boiler_cap_ud == Double.zero), 0,
        round(
          (d13[GI + i] + (d13[IE + i] - d13[GI + i]) * d13[KI + i]) - max(
            0,
            (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i]) - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[KI + i])
          ) / El_boiler_eff, 5))
    }
    // Surplus BESS cap after min day harmonious and opti night op prep
    // KP=IF(OR(KI3<0,BESS_cap_ud=0),0,ROUND((FY3+(HU3-FY3)*KI3)-MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KP + i] = iff(
        or(d13[KI + i] < 0, BESS_cap_ud == Double.zero), 0,
        round(
          (d13[FY + i] + (d13[HU + i] - d13[FY + i]) * d13[KI + i]) - max(
            0,
            (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
              - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }
    // Surplus BESS cap after max day harmonious and opti night op prep
    // KQ=IF(OR(KI3<0,BESS_cap_ud=0),0,ROUND((FZ3+(HV3-FZ3)*KI3)-MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d13[KQ + i] = iff(
        or(d13[KI + i] < 0, BESS_cap_ud == Double.zero), 0,
        round(
          (d13[FZ + i] + (d13[HV + i] - d13[FZ + i]) * d13[KI + i]) - max(
            0,
            (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i]) - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
              - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }
    // Surplus grid import cap after min day harmonious and opti night op prep
    // KR=IF(OR(KI3<0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GE3+(IA3-GE3)*KI3)-MAX(0,-((FS3+(HO3-FS3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN((GH3+(ID3-GH3)*KI3),MAX(0,($AB3+($AC3-$AB3)*KI3)-(FV3+(HR3-FV3)*KI3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[KR + i] = iff(
        or(d13[KI + i] < 0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero), 0,
        round(
          (d13[GE + i] + (d13[IA + i] - d13[GE + i]) * d13[KI + i])
            - max(
              0,
              -((d13[FS + i] + (d13[HO + i] - d13[FS + i]) * d13[KI + i])
                - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i])
                - min(
                  (d13[GH + i] + (d13[ID + i] - d13[GH + i]) * d13[KI + i]),
                  max(
                    0,
                    (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i])
                      - (d13[FV + i] + (d13[HR + i] - d13[FV + i]) * d13[KI + i])) / El_boiler_eff) - min(
                  BESS_cap_ud,
                  max(
                    0,
                    (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                      - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                      - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    // Surplus grid import cap after max day harmonious and opti night op prep
    // KS=IF(OR(KI3<0,Grid_import_max_ud*Grid_import_yes_no_PB_strategy=0),0,ROUND((GF3+(IB3-GF3)*KI3)-MAX(0,-((FT3+(HP3-FT3)*KI3)-($Z3+($AA3-$Z3)*KI3)-MIN((GI3+(IE3-GI3)*KI3),MAX(0,($AB3+($AC3-$AB3)*KI3)-(FW3+(HS3-FW3)*KI3))/El_boiler_eff)-MIN(BESS_cap_ud,MAX(0,(FK3+(HG3-FK3)*KI3)-(GG3+(IC3-GG3)*KI3)-(GA3+(HW3-GA3)*KI3)*BESS_chrg_eff))/BESS_chrg_eff)),5))
    for i in 0..<365 {
      d13[KS + i] = iff(
        or(d13[KI + i] < 0, Grid_import_max_ud * Grid_import_yes_no_PB_strategy == Double.zero), 0,
        round(
          (d13[GF + i] + (d13[IB + i] - d13[GF + i]) * d13[KI + i])
            - max(
              0,
              -((d13[FT + i] + (d13[HP + i] - d13[FT + i]) * d13[KI + i])
                - (d13[Z + i] + (d13[AA + i] - d13[Z + i]) * d13[KI + i])
                - min(
                  (d13[GI + i] + (d13[IE + i] - d13[GI + i]) * d13[KI + i]),
                  max(
                    0,
                    (d13[AB + i] + (d13[AC + i] - d13[AB + i]) * d13[KI + i])
                      - (d13[FW + i] + (d13[HS + i] - d13[FW + i]) * d13[KI + i])) / El_boiler_eff) - min(
                  BESS_cap_ud,
                  max(
                    0,
                    (d13[FK + i] + (d13[HG + i] - d13[FK + i]) * d13[KI + i])
                      - (d13[GG + i] + (d13[IC + i] - d13[GG + i]) * d13[KI + i])
                      - (d13[GA + i] + (d13[HW + i] - d13[GA + i]) * d13[KI + i]) * BESS_chrg_eff)) / BESS_chrg_eff)), 5))
    }
    // Surplus RawMeth prod cap after min day harmonious and opti night op prep
    // KT=IF(KI3<0,0,ROUND((GK3+(IG3-GK3)*KI3)-($AD3+($AE3-$AD3)*KI3),5))
    for i in 0..<365 {
      d13[KT + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GK + i] + (d13[IG + i] - d13[GK + i]) * d13[KI + i]) - (d13[AD + i] + (d13[AE + i] - d13[AD + i]) * d13[KI + i]),
          5))
    }

    // Surplus RawMeth prod cap after max day harmonious and opti night op prep
    // KU=IF(KI3<0,0,ROUND((GL3+(IH3-GL3)*KI3)-($AD3+($AE3-$AD3)*KI3),5))
    for i in 0..<365 {
      d13[KU + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GL + i] + (d13[IH + i] - d13[GL + i]) * d13[KI + i]) - (d13[AD + i] + (d13[AE + i] - d13[AD + i]) * d13[KI + i]),
          5))
    }

    // Surplus CO2 prod cap after min day harmonious and opti night op prep
    // KV=IF(KI3<0,0,ROUND((GN3+(IJ3-GN3)*KI3)-($AF3+($AG3-$AF3)*KI3),5))
    for i in 0..<365 {
      d13[KV + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GN + i] + (d13[IJ + i] - d13[GN + i]) * d13[KI + i]) - (d13[AF + i] + (d13[AG + i] - d13[AF + i]) * d13[KI + i]),
          5))
    }

    // Surplus CO2 prod cap after max day harmonious and opti night op prep
    // KW=IF(KI3<0,0,ROUND((GO3+(IK3-GO3)*KI3)-($AF3+($AG3-$AF3)*KI3),5))
    for i in 0..<365 {
      d13[KW + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GO + i] + (d13[IK + i] - d13[GO + i]) * d13[KI + i]) - (d13[AF + i] + (d13[AG + i] - d13[AF + i]) * d13[KI + i]),
          5))
    }

    // Surplus H2 prod cap after min day harmonious and opti night op prep
    // KX=IF(KI3<0,0,ROUND((GQ3+(IM3-GQ3)*KI3)-($AH3+($AI3-$AH3)*KI3),5))
    for i in 0..<365 {
      d13[KX + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GQ + i] + (d13[IM + i] - d13[GQ + i]) * d13[KI + i]) - (d13[AH + i] + (d13[AI + i] - d13[AH + i]) * d13[KI + i]),
          5))
    }
    // Surplus H2 prod cap after max day harmonious and opti night op prep
    // KY=IF(KI3<0,0,ROUND((GR3+(IN3-GR3)*KI3)-($AH3+($AI3-$AH3)*KI3),5))
    for i in 0..<365 {
      d13[KY + i] = iff(
        d13[KI + i] < 0, 0,
        round(
          (d13[GR + i] + (d13[IN + i] - d13[GR + i]) * d13[KI + i]) - (d13[AH + i] + (d13[AI + i] - d13[AH + i]) * d13[KI + i]),
          5))
    }
    // Opt harm op period op during night prio operation
    // KZ=IF(OR(KI3<0,KJ3<0,KL3<0,KN3<0,KP3<0,KR3<0,KT3<0,KV3<0,KX3<0),-1,MIN(1,IFERROR(KJ3/MAX(0,KJ3-KK3),1),IFERROR(KL3/MAX(0,KL3-KM3),1),IFERROR(KN3/MAX(0,KN3-KO3),1),IFERROR(KP3/MAX(0,KP3-KQ3),1),IFERROR(KR3/MAX(0,KR3-KS3),1),IFERROR(KT3/MAX(0,KT3-KU3),1),IFERROR(KV3/MAX(0,KV3-KW3),1),IFERROR(KX3/MAX(0,KX3-KY3),1)))
    for i in 0..<365 {
      d13[KZ + i] = iff(
        or(
          d13[KI + i] < 0, d13[KJ + i] < 0, d13[KL + i] < 0, d13[KN + i] < 0, d13[KP + i] < 0, d13[KR + i] < 0, d13[KT + i] < 0,
          d13[KV + i] < 0, d13[KX + i] < 0), -1,
        min(
          1, ifFinite(d13[KJ + i] / max(0, d13[KJ + i] - d13[KK + i]), 1),
          ifFinite(d13[KL + i] / max(0, d13[KL + i] - d13[KM + i]), 1),
          ifFinite(d13[KN + i] / max(0, d13[KN + i] - d13[KO + i]), 1),
          ifFinite(d13[KP + i] / max(0, d13[KP + i] - d13[KQ + i]), 1),
          ifFinite(d13[KR + i] / max(0, d13[KR + i] - d13[KS + i]), 1),
          ifFinite(d13[KT + i] / max(0, d13[KT + i] - d13[KU + i]), 1),
          ifFinite(d13[KV + i] / max(0, d13[KV + i] - d13[KW + i]), 1),
          ifFinite(d13[KX + i] / max(0, d13[KX + i] - d13[KY + i]), 1)))
    }
  }
}
