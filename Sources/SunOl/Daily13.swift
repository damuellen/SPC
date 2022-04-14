extension TunOl {
  func day17(_ day7: inout [Double], case j: Int, day1: [Double], day5: [Double], day6: [Double]) {
    let (dayC, dayD, dayE, dayT, dayU, dayV, dayZ, dayAA, dayAB, dayAC, dayAD, dayAE, dayAF, dayAG, dayAH, dayAI, dayAM) = (
      0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775
    )  // day1

    let (
      dayFC, dayFD, dayFE, dayFI, dayFJ, _, _, _, _, _, dayFR, dayFS, dayFT, dayFV, dayFW, dayFY, dayFZ, dayGA, dayGB, dayGC,
      dayGD, dayGE, dayGF, dayGG, dayGH, dayGI, dayGK, dayGL, dayGN, dayGO, dayGQ, dayGR
    ) = (
      1460, 1825, 2190, 2555, 4015, 4745, 5110, 5475, 5840, 6205, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410,
      12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // day5

    let (
      dayGY, dayGZ, dayHA, _, _, _, dayHE, dayHF, _, _, _, _, _, dayHN, dayHO, dayHP, dayHR, dayHS, dayHU, dayHV, dayHW, dayHX, dayHY,
      dayHZ, dayIA, dayIB, dayIC, dayID, dayIE, dayIG, dayIH, dayIJ, dayIK, dayIM, dayIN
    ) = (
      1460, 1825, 2190, 2555, 2920, 3285, 3650, 4015, 4745, 5110, 5475, 5840, 6205, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10220, 10585, 10950, 11315, 11680, 12045, 12410,
      12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    )  // day6

    let dayFX = 9125
    let dayHT = 9125
    let dayFK = 4380
    let dayHG = 4380

    /// Surplus harm op period electricity after min harm op and min night op prep
    let ddIQ = 0
    // =FS6+GE6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff)
    for i in 0..<365 { day7[ddIQ + i] = day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i] - max(Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff
        - min(day5[dayFY + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff) }

    let equiv_harmonious_range = (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])    
    let ddAM = 30295 // let ddLY = 30295
    for i in 0..<365 { day7[ddAM + i] = equiv_harmonious_range < 1E-10 ? 1 : (day1[dayAM + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range }

    /// Surplus harm op period electricity after min harm op and max night op prep
    let ddIR = 365
    // =HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff)
    for i in 0..<365 {
      day7[ddIR + i] =
        day6[dayHO + i] + day6[dayIA + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[ddAM + i]) - max(
          0, (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i]) - day6[dayHR + i]) / El_boiler_eff
          - min(day6[dayHU + i], max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff)
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let ddIS = 730
    // =FT6+GF6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff)
    for i in 0..<365 { day7[ddIS + i] = day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i] - max(Double.zero, day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff
        - min(day5[dayFZ + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff) }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let ddIT = 1095
    // =FV6+MAX(0,FS6+GE6-$Z6-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 { day7[ddIT + i] = day5[dayFV + i] + max(Double.zero, day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i]
        - min(day5[dayFY + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff)) * El_boiler_eff - day1[dayAB + i] }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let ddIU = 1460
    // =HR6+MAX(0,HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff))*El_boiler_eff-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddIU + i] =
        day6[dayHR + i] + max(
          Double.zero, day6[dayHO + i] + day6[dayIA + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[ddAM + i])
          - min(day6[dayHU + i], max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff))
        * El_boiler_eff - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i])
    }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let ddIV = 1825
    // =FW6+MAX(0,FT6+GF6-Z6-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff))*El_boiler_eff-$AB6
    for i in 0..<365 { day7[ddIV + i] = day5[dayFW + i] + max(Double.zero, day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i]
        - min(day5[dayFZ + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff)) * El_boiler_eff - day1[dayAB + i] }

    /// Surplus el boiler cap after min harm op and min night op prep
    let ddIW = 2190
    // GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 { day7[ddIW + i] = day5[dayGH + i] - max(Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep
    let ddIX = 2555
    // ID6-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 {
      day7[ddIX + i] =
        day6[dayID + i] - max(
          Double.zero, (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i]) - day6[dayHR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let ddIY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 { day7[ddIY + i] = day5[dayGI + i] - max(Double.zero, (day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff) }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let ddIZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let ddJA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let ddJB = 4015

    for i in 0..<365 {
      // FY6-MAX(0,FK6-GG6)/BESS_chrg_eff
      day7[ddIZ + i] = day5[dayFY + i] - max(Double.zero, day5[dayFK + i] - day5[dayGG + i]) / BESS_chrg_eff
      // HU6-MAX(0,HG6-IC6)/BESS_chrg_eff
      day7[ddJA + i] = day6[dayHU + i] - max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff
      // FZ6-MAX(0,FK6-GG6)/BESS_chrg_eff
      day7[ddJB + i] = day5[dayFZ + i] - max(Double.zero, day5[dayFK + i] - day5[dayGG + i]) / BESS_chrg_eff
    }

    /// Surplus Grid input cap after min harm op and min night op prep
    let ddJC = 4380
    /// =GE6-MAX(0,-(FS6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-MIN(FY6,MAX(0,FK6-GG6)/BESS_chrg_eff)))
    for i in 0..<365 { day7[ddJC + i] = day5[dayGE + i] - max(Double.zero, -(day5[dayFS + i] - day1[dayZ + i] - max(0, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff
        - min(day5[dayFY + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff))) }

    ///	Surplus grid import cap after min harm op and max night op prep
    let ddJD = 4745
    /// =IA6-MAX(0,-(HO6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-MIN(HU6,MAX(0,HG6-IC6)/BESS_chrg_eff)))
    for i in 0..<365 {
      //  let equiv_harmonious = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]
      day7[ddJD + i] =
        day6[dayIA + i]
        - max(
          Double.zero,
          -(day6[dayHO + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[ddAM + i]) - max(
            Double.zero, (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i]) - day6[dayHR + i])
            / El_boiler_eff - min(day6[dayHU + i], max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff)))
    }
    /// Surplus grid import cap after max harm op and min night op prep
    let ddJE = 5110
    /// =GF6-MAX(0,-(FT6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-MIN(FZ6,MAX(0,FK6-GG6)/BESS_chrg_eff)))
    for i in 0..<365 { day7[ddJE + i] = day5[dayGF + i] - max(Double.zero, -(day5[dayFT + i] - day1[dayZ + i] - max(0, day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff
        - min(day5[dayFZ + i], max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff))) }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let ddJF = 5475
    // JF=GK6-$AD6
    for i in 0..<365 { day7[ddJF + i] = day5[dayGK + i] - day1[dayAD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let ddJG = 5840
    // JG=IG6-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJG + i] = day6[dayIG + i] - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) * day7[ddAM + i])
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let ddJH = 6205
    // JH=GL6-$AD6
    for i in 0..<365 { day7[ddJH + i] = day5[dayGL + i] - day1[dayAD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let ddJI = 6570
    // JI=GN6-$AF6
    for i in 0..<365 { day7[ddJI + i] = day5[dayGN + i] - day1[dayAF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let ddJJ = 6935
    // JJ=IJ6-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJJ + i] = day6[dayIJ + i] - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) * day7[ddAM + i])
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let ddJK = 7300
    // JK=GO6-$AF6
    for i in 0..<365 { day7[ddJK + i] = day5[dayGO + i] - day1[dayAF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let ddJL = 7665
    // JL=GQ6-$AH6
    for i in 0..<365 { day7[ddJL + i] = day5[dayGQ + i] - day1[dayAH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let ddJM = 8030
    // JM=IM6-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJM + i] = day6[dayIM + i] - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) * day7[ddAM + i])
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let ddJN = 8395
    // JN=GR6-$AH6
    for i in 0..<365 { day7[ddJN + i] = day5[dayGR + i] - day1[dayAH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let ddJP = 8760
    // JP=IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IS6),1),IFERROR(IT6/MAX(0,IT6-IV6),1),IFERROR(IW6/MAX(0,IW6-IY6),1),IFERROR(IZ6/MAX(0,IZ6-JB6),1),IFERROR(JC6/MAX(0,JC6-JE6),1),IFERROR(JF6/MAX(0,JF6-JH6),1),IFERROR(JI6/MAX(0,JI6-JK6),1),IFERROR(JL6/MAX(0,JL6-JN6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddJP + i] = iff(
        or(
          day7[ddIQ + i] < Double.zero, day7[ddIT + i] < Double.zero, day7[ddIW + i] < Double.zero, day7[ddIZ + i] < Double.zero, day7[ddJC + i] < Double.zero,
          day7[ddJF + i] < Double.zero, day7[ddJI + i] < Double.zero, day7[ddJL + i] < Double.zero), Double.zero,
        min(
          1, ifFinite(day7[ddIQ + i] / max(0, day7[ddIQ + i] - day7[ddIS + i]), 1), ifFinite(day7[ddIT + i] / max(0, day7[ddIT + i] - day7[ddIV + i]), 1),
          ifFinite(day7[ddIW + i] / max(0, day7[ddIW + i] - day7[ddIY + i]), 1), ifFinite(day7[ddIZ + i] / max(0, day7[ddIZ + i] - day7[ddJB + i]), 1),
          ifFinite(day7[ddJC + i] / max(0, day7[ddJC + i] - day7[ddJE + i]), 1), ifFinite(day7[ddJF + i] / max(0, day7[ddJF + i] - day7[ddJH + i]), 1),
          ifFinite(day7[ddJI + i] / max(0, day7[ddJI + i] - day7[ddJK + i]), 1), ifFinite(day7[ddJL + i] / max(0, day7[ddJL + i] - day7[ddJN + i]), 1)) * Overall_harmonious_range
          + Overall_harmonious_min_perc)
    }
    let dddJP = 26280 // let ddLN = 26280
    for i in 0..<365 { day7[dddJP + i] = Overall_harmonious_range < 1E-10 ? 1 : (day7[ddJP + i] - Overall_harmonious_min_perc) / Overall_harmonious_range }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let ddJQ = 9125
    // JQ=IF(JP6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff),5))
    for i in 0..<365 {
      day7[ddJQ + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayFS + i] + (day5[dayFT + i] - day5[dayFS + i]) * day7[dddJP + i])
            + (day5[dayGE + i] + (day5[dayGF + i] - day5[dayGE + i]) * day7[dddJP + i]) - day1[dayZ + i] - max(
              Double.zero, day1[dayAB + i] - (day5[dayFV + i] + (day5[dayFW + i] - day5[dayFV + i]) * day7[dddJP + i]))
            / El_boiler_eff - min((day5[dayFY + i] + (day5[dayFZ + i] - day5[dayFY + i]) * day7[dddJP + i]),
              max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let ddJR = 9490
    // JR=IF(JP6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff),5))
    for i in 0..<365 {
      day7[ddJR + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayHO + i] + (day6[dayHP + i] - day6[dayHO + i]) * day7[dddJP + i])
            + (day6[dayIA + i] + (day6[dayIB + i] - day6[dayIA + i]) * day7[dddJP + i])
            - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[ddAM + i]) - max(
              Double.zero,
              (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i])
                - (day6[dayHR + i] + (day6[dayHS + i] - day6[dayHR + i]) * day7[dddJP + i])) / El_boiler_eff
                - min((day6[dayHU + i] + (day6[dayHV + i] - day6[dayHU + i]) * day7[dddJP + i]), max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let ddJS = 9855
    // JS=IF(JP6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6)*El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff)-$AB6,5))
    for i in 0..<365 {
      day7[ddJS + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayFV + i] + (day5[dayFW + i] - day5[dayFV + i]) * day7[dddJP + i]) + max(
            Double.zero,
            (day5[dayFS + i] + (day5[dayFT + i] - day5[dayFS + i]) * day7[dddJP + i])
              + (day5[dayGE + i] + (day5[dayGF + i] - day5[dayGE + i]) * day7[dddJP + i]) - day1[dayZ + i]) * El_boiler_eff
              - min((day5[dayFY + i] + (day5[dayFZ + i] - day5[dayFY + i]) * day7[dddJP + i]),
                max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff) - day1[dayAB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let ddJT = 10220
    // JT=IF(JP6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)))*El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddJT + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayHR + i] + (day6[dayHS + i] - day6[dayHR + i]) * day7[dddJP + i]) + max(
            Double.zero,
            (day6[dayHO + i] + (day6[dayHP + i] - day6[dayHO + i]) * day7[dddJP + i])
              + (day6[dayIA + i] + (day6[dayIB + i] - day6[dayIA + i]) * day7[dddJP + i])
              - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[ddAM + i])) * El_boiler_eff
              - min((day6[dayHU + i] + (day6[dayHV + i] - day6[dayHU + i]) * day7[dddJP + i]),
                max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff)
            - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i]), 5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let ddJU = 10585
    // JU=IF(JP6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddJU + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayGH + i] + (day5[dayGI + i] - day5[dayGH + i]) * day7[dddJP + i]) - max(
            Double.zero, day1[dayAB + i] - (day5[dayFV + i] + (day5[dayFW + i] - day5[dayFV + i]) * day7[dddJP + i]))
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let ddJV = 10950
    // JV=IF(JP6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddJV + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayID + i] + (day6[dayIE + i] - day6[dayID + i]) * day7[dddJP + i]) - max(
            Double.zero,
            (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[ddAM + i])
              - (day6[dayHR + i] + (day6[dayHS + i] - day6[dayHR + i]) * day7[dddJP + i])) / El_boiler_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let ddJW = 11315
    // JW=IF(JP6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,FK6-GG6)/BESS_chrg_eff,5))
     for i in 0..<365 {
       day7[ddJW + i] = iff(
         day7[ddJP + i].isZero, Double.zero,
         round(
           (day5[dayFY + i]
             + (day5[dayFZ + i] - day5[dayFY + i]) / Overall_harmonious_range
               * (day7[ddJP + i] - Overall_harmonious_min_perc))
               - max(Double.zero, day5[dayFK + i] - day5[dayGG + i]) / BESS_chrg_eff, 5))
     }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let ddJX = 11680
    // JX=IF(JP6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,HG6-IC6)/BESS_chrg_eff,5))
     for i in 0..<365 {
       day7[ddJX + i] = iff(
         day7[ddJP + i].isZero, Double.zero,
         round(
           (day6[dayHU + i]
             + (day6[dayHV + i] - day6[dayHU + i]) / Overall_harmonious_range
               * (day7[ddJP + i] - Overall_harmonious_min_perc))
             - max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff, 5))
     }

    /// Surplus grid import cap after opt day harm and min night op prep
    let ddJY = 12045
    // JY=IF(JP6=0,0,ROUND((GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$Z6-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,FK6-GG6)/BESS_chrg_eff))),5))
    for i in 0..<365 {
      day7[ddJY + i] = iff(
        day7[ddJP + i].isZero, 0,
        round(
          (day5[dayGE + i] + (day5[dayGF + i] - day5[dayGE + i]) * day7[dddJP + i])
            - max(
              Double.zero,
              -((day5[dayFS + i] + (day5[dayFT + i] - day5[dayFS + i]) * day7[dddJP + i]) - day1[dayZ + i] - max(
                Double.zero, day1[dayAB + i] - (day5[dayFV + i] + (day5[dayFW + i] - day5[dayFV + i]) * day7[dddJP + i]))
                / El_boiler_eff - min((day5[dayFY + i] + (day5[dayFZ + i] - day5[dayFY + i]) * day7[dddJP + i]),
                  max(Double.zero, day5[dayFK + i] - day6[dayGG + i]) / BESS_chrg_eff))), 5))
    }

    /// Surplus grid import cap after opt day harm and max night op prep
    let ddJZ = 12410
    // JZ=IF(JP6=0,0,ROUND((IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-MAX(0,-((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))/El_boiler_eff-MIN((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,HG6-IC6)/BESS_chrg_eff))),5))
    for i in 0..<365 {
      day7[ddJZ + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayIA + i] + (day6[dayIB + i] - day6[dayIA + i]) * day7[dddJP + i])
            - max(
              Double.zero,
              -((day6[dayHO + i] + (day6[dayHP + i] - day6[dayHO + i]) * day7[dddJP + i])
                - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                - max(
                  Double.zero,
                  (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                    - (day6[dayHR + i] + (day6[dayHS + i] - day6[dayHR + i]) * day7[dddJP + i])) / El_boiler_eff
                    - min((day6[dayHU + i] + (day6[dayHV + i] - day6[dayHU + i]) * day7[dddJP + i]),
                      max(Double.zero, day6[dayHG + i] - day6[dayIC + i]) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let ddKA = 12775
    // KA=IF(JP6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AD6,5))
    for i in 0..<365 {
      day7[ddKA + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round((day5[dayGK + i] + (day5[dayGL + i] - day5[dayGK + i]) * day7[dddJP + i]) - day1[dayAD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let ddKB = 13140
    // KB=IF(JP6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKB + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGK + i] + (day5[dayGL + i] - day5[dayGK + i]) * day7[dddJP + i]
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) * day7[ddAM + i]), 5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let ddKC = 13505
    // KC=IF(JP6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AF6,5))
    for i in 0..<365 {
      day7[ddKC + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round((day5[dayGN + i] + (day5[dayGO + i] - day5[dayGN + i]) * day7[dddJP + i]) - day1[dayAF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let ddKD = 13870
    // KD=IF(JP6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKD + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGN + i] + (day5[dayGO + i] - day5[dayGN + i]) * day7[dddJP + i]
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) * day7[ddAM + i]), 5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let ddKE = 14235
    // KE=IF(JP6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))-$AH6,5))
    for i in 0..<365 {
      day7[ddKE + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round((day5[dayGQ + i] + (day5[dayGR + i] - day5[dayGQ + i]) * day7[dddJP + i]) - day1[dayAH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let ddKF = 14600
    // KF=IF(JP6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKF + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGQ + i] + (day5[dayGR + i] - day5[dayGQ + i]) * day7[dddJP + i]
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) * day7[ddAM + i]), 5))
    }

    /// Opt night prep during day prio operation
    let ddKG = 14965
    // KG=IF(OR(JP6=0,JQ6<0,JS6<0,JU6<0,JW6<0,JY6<0,KA6<0,KC6<0,KE6<0),0,MIN(1,IFERROR(JQ6/MAX(0,JQ6-JR6),1),IFERROR(JS6/MAX(0,JS6-JT6),1),IFERROR(JU6/MAX(0,JU6-JV6),1),IFERROR(JW6/MAX(0,JW6-JX6),1),IFERROR(JY6/MAX(0,JY6-JZ6),1),IFERROR(KA6/MAX(0,KA6-KB6),1),IFERROR(KC6/MAX(0,KC6-KD6),1),IFERROR(KE6/MAX(0,KE6-KF6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKG + i] = iff(
        or(
          day7[ddJP + i].isZero, day7[ddJQ + i] < Double.zero, day7[ddJS + i] < Double.zero, day7[ddJU + i] < Double.zero, day7[ddJW + i] < Double.zero,
          day7[ddJY + i] < Double.zero, day7[ddKA + i] < Double.zero, day7[ddKC + i] < Double.zero, day7[ddKE + i] < Double.zero), 0,
        min(
          1, ifFinite(day7[ddJQ + i] / max(0, day7[ddJQ + i] - day7[ddJR + i]), 1), ifFinite(day7[ddJS + i] / max(0, day7[ddJS + i] - day7[ddJT + i]), 1),
          ifFinite(day7[ddJU + i] / max(0, day7[ddJU + i] - day7[ddJV + i]), 1), ifFinite(day7[ddJW + i] / max(0, day7[ddJW + i] - day7[ddJX + i]), 1),
          ifFinite(day7[ddJY + i] / max(0, day7[ddJY + i] - day7[ddJZ + i]), 1), ifFinite(day7[ddKA + i] / max(0, day7[ddKA + i] - day7[ddKB + i]), 1),
          ifFinite(day7[ddKC + i] / max(0, day7[ddKC + i] - day7[ddKD + i]), 1), ifFinite(day7[ddKE + i] / max(0, day7[ddKE + i] - day7[ddKF + i]), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let ddKI = 15330
    // KI=IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0,JL6<0),0,MIN(1,IFERROR(IQ6/MAX(0,IQ6-IR6),1),IFERROR(IT6/MAX(0,IT6-IU6),1),IFERROR(IW6/MAX(0,IW6-IX6),1),IFERROR(IZ6/MAX(0,IZ6-JA6),1),IFERROR(JC6/MAX(0,JC6-JD6),1),IFERROR(JF6/MAX(0,JF6-JG6),1),IFERROR(JI6/MAX(0,JI6-JJ6),1),IFERROR(JL6/MAX(0,JL6-JM6),1))*($AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKI + i] = iff(
        or(
          day7[ddIQ + i] < Double.zero, day7[ddIT + i] < Double.zero, day7[ddIW + i] < Double.zero, day7[ddIZ + i] < Double.zero, day7[ddJC + i] < Double.zero,
          day7[ddJF + i] < Double.zero, day7[ddJI + i] < Double.zero, day7[ddJL + i] < Double.zero), 0,
        min(
          1, ifFinite(day7[ddIQ + i] / max(0, day7[ddIQ + i] - day7[ddIR + i]), 1), ifFinite(day7[ddIT + i] / max(0, day7[ddIT + i] - day7[ddIU + i]), 1),
          ifFinite(day7[ddIW + i] / max(0, day7[ddIW + i] - day7[ddIX + i]), 1), ifFinite(day7[ddIZ + i] / max(0, day7[ddIZ + i] - day7[ddJA + i]), 1),
          ifFinite(day7[ddJC + i] / max(0, day7[ddJC + i] - day7[ddJD + i]), 1), ifFinite(day7[ddJF + i] / max(0, day7[ddJF + i] - day7[ddJG + i]), 1),
          ifFinite(day7[ddJI + i] / max(0, day7[ddJI + i] - day7[ddJJ + i]), 1), ifFinite(day7[ddJL + i] / max(0, day7[ddJL + i] - day7[ddJM + i]), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    
    let ddAMKG = 23360 // let ddLF = 23360 
    let dddKI = 25550 // let ddLL = 25550
    let ddAMKI = 38690 // let ddMW = 38690
    for i in 0..<365 { 
      day7[dddKI + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (day7[ddKI + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j]
      day7[ddAMKG + i] = (day1[dayAM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (day7[ddKG + i] - equiv_harmonious_min_perc[j]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
      day7[ddAMKI + i] = (day1[dayAM + i] - equiv_harmonious_min_perc[j]) < 1E-10 ? 1 : (day7[ddKI + i] - equiv_harmonious_min_perc[j]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let ddKJ = 15695
    // KJ=IF(KI6=0,0,ROUND((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc),MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/BESS_chrg_eff),5))
    for i in 0..<365 {
      day7[ddKJ + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKI + i])
            + (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKI + i])
            - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[dddKI + i]) - max(
              Double.zero,
              (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i])
                - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i]))
            / El_boiler_eff
              - min((day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKI + i]),
                max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff), 5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let ddKK = 16060
    // KK=IF(KI6=0,0,ROUND((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff),5))
    for i in 0..<365 {
      day7[ddKK + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFT + i] + (day6[dayHP + i] - day5[dayFT + i]) * day7[ddAMKI + i])
            + (day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) * day7[ddAMKI + i])
            - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[dddKI + i]) - max(
              Double.zero,
              (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i])
                - (day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKI + i]))
            / El_boiler_eff
              - min((day5[dayFZ + i] + (day6[dayHV + i] - day5[dayFZ + i]) * day7[ddAMKI + i]),
                max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let ddKL = 16425
    // KL=IF(KI6=0,0,ROUND((FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))*El_boiler_eff-MIN(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5)),5))
    for i in 0..<365 {
      day7[ddKL + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i])
            + (max(
              Double.zero,
              (day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKI + i])
                + (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKI + i])
                - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[dddKI + i]))) * El_boiler_eff
            - min((day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKI + i]),
                max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff)
            - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let ddKM = 16790
    // KM=IF(KI6=0,0,ROUND((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))*El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKM + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKI + i])
            + (max(
              Double.zero,
              (day5[dayFT + i] + (day6[dayHP + i] - day5[dayFT + i]) * day7[ddAMKI + i])
                + (day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) * day7[ddAMKI + i])
                - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[dddKI + i]))) * El_boiler_eff
                - min((day5[dayFZ + i] + (day6[dayHV + i] - day5[dayFZ + i]) * day7[ddAMKI + i]),
                  max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff)
            - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let ddKN = 17155
    // KN=IF(KI6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddKN + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGH + i] + (day6[dayID + i] - day5[dayGH + i]) * day7[ddAMKI + i]) - max(
            Double.zero,
            (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i])
              - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i]))
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let ddKO = 17520
    // KO=IF(KI6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddKO + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGI + i] + (day6[dayIE + i] - day5[dayGI + i]) * day7[ddAMKI + i]) - max(
            Double.zero,
            (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i])
              - (day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKI + i]))
            / El_boiler_eff, 5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let ddKP = 17885
    // KP=IF(KI6=0,0,ROUND((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,(FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKP + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let ddKQ = 18250
    // KQ=IF(KI6=0,0,ROUND((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKQ + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFZ + i]
            + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))) / BESS_chrg_eff, 5))
    }

    /// Surplus grid import cap after min day harmonious and opti night op prep
    let ddKR = 18615
    // KR=IF(KI6=0,0,ROUND((GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FY3+(HU3-FY3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc))-(GG3+(IC3-GG3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))/BESS_chrg_eff))),5))
    for i in 0..<365 {

      let x1 = day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKI + i]
      let x2 = day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i]
      let x3 = min((day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKI + i]),
                max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff)
      let x4 = day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKI + i]
      let x5 = day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j])

      let x00 = day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j])

      let x13 = (x4 - x5 - iff(x00 - x2 > 0, x00 - x2, 0) / El_boiler_eff - x3)

      day7[ddKR + i] = iff(day7[ddKI + i].isZero, Double.zero, round(x1 + iff(x13 < Double.zero, x13, Double.zero), 5))
    }

    /// Surplus grid import cap after max day harmonious and opti night op prep
    let ddKS = 18980
    // KS=IF(KI6=0,0,ROUND((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,-((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/El_boiler_eff-MIN(FZ3+(HV3-FZ3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc),MAX(0,(FK3+(HG3-FK3)/($AM3-A_equiv_harmonious_min_perc)*(KI3-A_equiv_harmonious_min_perc)))),5))
    for i in 0..<365 {
      day7[ddKS + i] = iff(
        day7[ddKI + i].isZero, 0,
        round(
          (day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) * day7[ddAMKI + i])
            - max(
              Double.zero,
              -((day5[dayFT + i] + (day6[dayHP + i] - day5[dayFT + i]) * day7[ddAMKI + i])
                - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - max(
                  Double.zero,
                  (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                    - (day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKI + i]))
                / El_boiler_eff
                  - min((day5[dayFZ + i] + (day6[dayHV + i] - day5[dayFZ + i]) * day7[ddAMKI + i]),
                    max(Double.zero, (day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i]) - (day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i])) / BESS_chrg_eff))), 5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let ddKT = 19345
    // KT=IF(KI6=0,0,ROUND((GK6+(IG6-GK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKT + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGK + i] + (day6[dayIG + i] - day5[dayGK + i]) * day7[ddAMKI + i])
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let ddKU = 19710
    // KU=IF(KI6=0,0,ROUND((GL6+(IH6-GL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AD6+($AE6-$AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKU + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGL + i] + (day6[dayIH + i] - day5[dayGL + i]) * day7[ddAMKI + i])
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let ddKV = 20075
    // KV=IF(KI6=0,0,ROUND((GN6+(IJ6-GN6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKV + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGN + i] + (day6[dayIJ + i] - day5[dayGN + i]) * day7[ddAMKI + i])
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let ddKW = 20440
    // KW=IF(KI6=0,0,ROUND((GO6+(IK6-GO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AF6+($AG6-$AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKW + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGO + i] + (day6[dayIK + i] - day5[dayGO + i]) * day7[ddAMKI + i])
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let ddKX = 20805
    // KX=IF(KI6=0,0,ROUND((GQ6+(IM6-GQ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKX + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGQ + i] + (day6[dayIM + i] - day5[dayGQ + i]) * day7[ddAMKI + i])
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) * day7[dddKI + i]), 5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let ddKY = 21170
    // KY=IF(KI6=0,0,ROUND((GR6+(IN6-GR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-($AH6+($AI6-$AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKY + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGR + i] + (day6[dayIN + i] - day5[dayGR + i]) * day7[ddAMKI + i])
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) * day7[dddKI + i]), 5))
    }

    /// Opt harm op period op during night prio operation
    let ddKZ = 21535
    // KZ=IF(OR(KI6=0,KJ6<0,KL6<0,KN6<0,KP6<0,KR6<0,KT6<0,KV6<0,KX6<0),0,MIN(1,IFERROR(KJ6/MAX(0,KJ6-KK6),1),IFERROR(KL6/MAX(0,KL6-KM6),1),IFERROR(KN6/MAX(0,KN6-KO6),1),IFERROR(KP6/MAX(0,KP6-KQ6),1),IFERROR(KR6/MAX(0,KR6-KS6),1),IFERROR(KT6/MAX(0,KT6-KU6),1),IFERROR(KV6/MAX(0,KV6-KW6),1),IFERROR(KX6/MAX(0,KX6-KY6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKZ + i] = iff(
        or(
          day7[ddKI + i].isZero, day7[ddKJ + i] < Double.zero, day7[ddKL + i] < Double.zero, day7[ddKN + i] < Double.zero, day7[ddKP + i] < Double.zero,
          day7[ddKR + i] < Double.zero, day7[ddKT + i] < Double.zero, day7[ddKV + i] < Double.zero, day7[ddKX + i] < Double.zero), 0,
        min(
          1, ifFinite(day7[ddKJ + i] / max(0, day7[ddKJ + i] - day7[ddKK + i]), 1), ifFinite(day7[ddKL + i] / max(0, day7[ddKL + i] - day7[ddKM + i]), 1),
          ifFinite(day7[ddKN + i] / max(0, day7[ddKN + i] - day7[ddKO + i]), 1), ifFinite(day7[ddKP + i] / max(0, day7[ddKP + i] - day7[ddKQ + i]), 1),
          ifFinite(day7[ddKR + i] / max(0, day7[ddKR + i] - day7[ddKS + i]), 1), ifFinite(day7[ddKT + i] / max(0, day7[ddKT + i] - day7[ddKU + i]), 1),
          ifFinite(day7[ddKV + i] / max(0, day7[ddKV + i] - day7[ddKW + i]), 1), ifFinite(day7[ddKX + i] / max(0, day7[ddKX + i] - day7[ddKY + i]), 1)) * Overall_harmonious_range
          + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period
    let ddLB = 21900
    // LB=IF(FC6=0,0,IF(OR(JP6=0;KG6=0),FD6,FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      day7[ddLB + i] = iff(day5[dayFC + i].isZero, Double.zero, iff(or(
        day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFD + i],
        (day5[dayFC + i] + (day6[dayGY + i] - day5[dayFC + i]) * day7[ddAMKG + i])
          + ((day5[dayFD + i] + (day6[dayGZ + i] - day5[dayFD + i]) * day7[ddAMKG + i])
            - (day5[dayFC + i] + (day6[dayGY + i] - day5[dayFC + i]) * day7[ddAMKG + i]))
          * day7[dddJP + i]))
    }

    /// el cons for night prep during harm op period
    let ddLC = 22265
    // LC=IF(or(JP6=0,kg6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLC + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons during harm op period
    let ddLD = 22630
    for i in 0..<365 { day7[ddLD + i] = 99 }
    // // LD=IF(OR(JP6=0,KG6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddLD + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
    //     day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
    //       * day7[ddAMKG + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddLE = 22995
    // LE=IF(OR(JP6=0,KG6=0),MIN(FR6/BESS_chrg_eff,FZ6),MIN(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[ddLE + i] = iff(
          or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), min(day5[dayFR + i] / BESS_chrg_eff, day5[dayFZ + i]),
          min((day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKG + i]
            + ((day5[dayFZ + i] + (day6[dayHV + i] - day5[dayFZ + i]) * day7[ddAMKG + i])
              - (day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKG + i]))
              * day7[dddJP + i]), (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) * day7[ddAMKG + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddLF = 23360 // reused
    // // LF=IF(OR(JP6=0,KG6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddLF + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
    //     (day5[dayFL + i]
    //       + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //         * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((day5[dayFM + i]
    //         + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //           * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (day5[dayFL + i]
    //           + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //             * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * day7[dddJP + i])
    // }

    // /// heat cons for harm op during harm op period
    // let ddLL = 25550 // reused
    // // LL=IF(OR(JP6=0,KG6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddLL + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
    //     (day5[dayFF + i]
    //       + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //         * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //       + ((day5[dayFG + i]
    //         + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //           * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    //         - (day5[dayFF + i]
    //           + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //             * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
    //       * day7[dddJP + i])
    // }

    /// heat cons for night prep during harm op period
    let ddLM = 25915
    // LM=IF(OR(JP6=0,KG6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLM + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddLN = 26280 // reused
    // // LN=IF(OR(JP6=0,KG6=0),0,LF6*El_boiler_eff)
    // for i in 0..<365 {
    //   day7[ddLN + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day7[ddLF + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddLP = 27010
    // LP=IF(OR(JP6=0,KG6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLP + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFW + i],
        day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKG + i]
          + ((day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKG + i])
            - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKG + i])) * day7[dddJP + i])
    }

    /// heat prod by el boiler for night prep during harm op period
    let ddLO = 26645
    // LO=IF(OR(JP6=0,KG6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc),MAX(0,LM6-LP6)))
    for i in 0..<365 {
      day7[ddLO + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), 0,
        min(
          (day5[dayGH + i] + (day6[dayID + i] - day5[dayGH + i]) * day7[ddAMKG + i])
            + ((day5[dayGI + i] + (day6[dayIE + i] - day5[dayGI + i]) * day7[ddAMKG + i])
              - (day5[dayGH + i] + (day6[dayID + i] - day5[dayGH + i]) * day7[ddAMKG + i])) * day7[dddJP + i],
          max(0, day7[ddLM + i] - day7[ddLP + i])))
    }

    /// Balance of heat during harm op period
    let ddLQ = 27375
    // LQ=LO6+LP6-LM6
    for i in 0..<365 { day7[ddLQ + i] = day7[ddLO + i] + day7[ddLP + i] - day7[ddLM + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddLG = 23725
    // LG=LO6/El_boiler_eff
    for i in 0..<365 { day7[ddLG + i] = day7[ddLO + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddLH = 24090
    // LH=IF(OR(JP6=0,KG6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLH + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFT + i],
        day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKG + i]
          + ((day5[dayFT + i] + (day6[dayHP + i] - day5[dayFT + i]) * day7[ddAMKG + i])
            - (day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKG + i])) * day7[dddJP + i])
    }

    /// Grid import for harm op during harm op period
    let ddLI = 24455
    // LI=IF(OR(JP6=0,KG6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLI + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFJ + i],
        (day5[dayFI + i] + (day6[dayHE + i] - day5[dayFI + i]) * day7[ddAMKG + i])
          + ((day5[dayFJ + i] + (day6[dayHF + i] - day5[dayFJ + i]) * day7[ddAMKG + i])
            - (day5[dayFI + i] + (day6[dayHE + i] - day5[dayFI + i]) * day7[ddAMKG + i])) * day7[dddJP + i])

    }

    /// Grid import for night prep during harm op period
    let ddLJ = 24820
    // LJ=MIN(IF(OR(JP6=0,KG6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc)),MAX(0,LC6+LE6+LG6-LH6))
    for i in 0..<365 {
      day7[ddLJ + i] = min(
        iff(
          or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayGF + i],
          (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKG + i])
            + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) * day7[ddAMKG + i])
              - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKG + i]))
            * day7[dddJP + i]), max(Double.zero, day7[ddLC + i] - day7[ddLE + i] - day7[ddLG + i] - day7[ddLH + i]))
    }

    /// Balance of electricity during harm op period
    let ddLK = 25185
    // LK=LH6+LJ6-LC6-LE6-LG6
    for i in 0..<365 { day7[ddLK + i] = day7[ddLH + i] + day7[ddLJ + i] - day7[ddLC + i] - day7[ddLE + i] - day7[ddLG + i] }

    /// el cons for harm op outside of harm op period
    let ddLR = 27740
    // LR=IF(OR(FE6=0,JP6=0,KG6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLR + i] = iff(
        or(day5[dayFE + i].isZero, day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i]) * day7[ddAMKG + i])
    }

    /// el to cover aux cons outside of harm op period
    let ddLS = 28105
    // LS=IF(OR(JP6=0,KG6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLS + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFK + i],
        day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKG + i])
    }

    /// el from BESS discharging outside of harm op period
    let ddLU = 28835
    // LU=MIN(LS6,(IF(LE6*BESS_chrg_eff>=LS6,0,IF(OR(JP6=0,KG6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+LE6)*BESS_chrg_eff)
    for i in 0..<365 { day7[ddLU + i] = min(day7[ddLS + i], (
        iff(day7[ddLE + i] * BESS_chrg_eff >= day7[ddLS + i], Double.zero,
          iff(or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayGA + i], day5[dayGA + i] + (day6[dayHW + i] - day5[dayGA + i]) * day7[ddAMKG + i])) + day7[ddLE + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddLT = 28470
    // LT=LS6-LU6
    for i in 0..<365 { day7[ddLT + i] = day7[ddLS + i] - day7[ddLU + i] }
    let dayHQ = 8030
    let dayFU = 8030
    /// El available outside of harm op period after TES chrg
    let ddLV = 29200
    // LV=max(0,IF(OR(JP6=0,KG6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(LU6/BESS_chrg_eff-LE6))
    for i in 0..<365 {
      day7[ddLV + i] = max(Double.zero, iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFU + i],
        day5[dayFU + i] + (day6[dayHQ + i] - day5[dayFU + i]) * day7[ddAMKG + i])
        - (day7[ddLU + i] / BESS_chrg_eff - day7[ddLE + i]))
    }

    /// Grid import needed outside of harm op period
    let ddLW = 29565
    // LW=MIN(IF(OR(JP6=0,KG6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+LU6),MAX(0,LS6-LT6-LU6-LV6))
    for i in 0..<365 {
      day7[ddLW + i] = min(
        iff(
          or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayGG + i],
          day6[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKG + i] + day7[ddLU + i]),
        max(Double.zero, day7[ddLS + i] - day7[ddLT + i] - day7[ddLU + i] - day7[ddLV + i]))
    }

    /// Balance of electricity outside of harm op period
    let ddLX = 29930
    // LX=LT6+LU6+LV6+LW6-LS6
    for i in 0..<365 { day7[ddLX + i] = day7[ddLT + i] + day7[ddLU + i] + day7[ddLV + i] + day7[ddLW + i] - day7[ddLS + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddLY = 30295
    // // LY=IF(OR(JP6=0,KG6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddLY + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
    //     day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
    //       * day7[ddAMKG + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddLZ = 30660
    // // LZ=IF(OR(JP6=0,KG6=0),0,LT6*El_boiler_eff)
    // for i in 0..<365 {
    //   day7[ddLZ + i] = iff(
    //     or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day7[ddLT + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddMA = 31025
    // MA=IF(OR(JP6=0,KG6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddMA + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayFX + i],
        day5[dayFX + i] + (day6[dayHT + i] - day5[dayFX + i]) * day7[ddAMKG + i])
    }

    /// Balance of heat outside of harm op period
    let ddMB = 31390
    // MB=MA6
    for i in 0..<365 { day7[ddMB + i] = day7[ddMA + i] }

    /// grid export
    let ddMD = 32120
    // MD=MAX(0,MIN(LK6,IF(OR(JP6=0,KG6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP6-Overall_harmonious_min_perc))))+MAX(0,MIN(LX6,IF(OR(JP6=0,KG6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      day7[ddMD + i] =
        min(
          day7[ddLK + i],
          iff(
            or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayGC + i],
            day5[dayGB + i] + (day6[dayHX + i] - day5[dayGB + i]) * day7[ddAMKG + i]
              + ((day5[dayGC + i] + (day6[dayHY + i] - day5[dayGC + i]) * day7[ddAMKG + i])
                - (day5[dayGB + i] + (day6[dayHX + i] - day5[dayGB + i]) * day7[ddAMKG + i]))
              * day7[dddJP + i]))
        + max(
          Double.zero,
          min(
            day7[ddLX + i],
            iff(
              or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day5[dayGD + i],
              day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i]) * day7[ddAMKG + i])))
    }

    /// Grid import
    let ddME = 32485
    // ME=LI6+LW6+LT6+LJ6
    for i in 0..<365 { day7[ddME + i] = day7[ddLI + i] + day7[ddLW + i] + day7[ddLT + i] + day7[ddLJ + i] }

    /// Outside harmonious operation period hours
    let ddMF = 32850
    // MF=IF(OR(JP6=0,KG6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { day7[ddMF + i] =
        iff(or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day1[dayC + i], day1[dayC + i] + (day1[dayT + i] - day1[dayC + i]) / equiv_harmonious_range * (day7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Harmonious operation period hours
    let ddMG = 33215
    // MG=IF(OR(JP6=0,KG6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { day7[ddMG + i] =
        iff(or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day1[dayD + i], day1[dayD + i] + (day1[dayU + i] - day1[dayD + i]) / equiv_harmonious_range * (day7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// PB operating hours
    let ddMH = 33580
    // MH=IF(OR(JP6=0,KG6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KG6-A_equiv_harmonious_min_perc)
    for i in 0..<365 { day7[ddMH + i] =
        iff(or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), day1[dayE + i], day1[dayE + i] + (day1[dayV + i] - day1[dayE + i]) / equiv_harmonious_range * (day7[ddKG + i] - equiv_harmonious_min_perc[j])) }

    /// Pure Methanol prod with day priority and resp night op
    let ddMC = 31755
    // MC=(MAX(0,LB6-MG6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,LR6-MF6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[ddMC + i] =
        max(Double.zero, day7[ddLB + i] - day7[ddMG + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(
          Double.zero, day7[ddLR + i] - day7[ddMF + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud
    }

    /// Checksum
    let ddMI = 33945
    // MI=MAX(0,-LK6)+MAX(0,-LQ6)+MAX(0,-LX6)+MAX(0,-MB6)
    for i in 0..<365 {
      let MB = max(Double.zero, -day7[ddLK + i]) + max(Double.zero, -day7[ddLQ + i]) + max(Double.zero, -day7[ddLX + i]) + max(Double.zero, -day7[ddMB + i])
      // if MB > 1E-13 { print("Checksum error daily 1", i, j, MB); break }
      day7[ddMI + i] = MB
    }

    /// el cons for harm op during harm op period
    let ddMK = 34310
    // MK=IF(FC6=0;0;IF(OR(KZ6=0,KI6=0),FD6,FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FD6+(GZ6-FD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      day7[ddMK + i] = iff(day5[dayFC + i].isZero, Double.zero, iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayFD + i],
        day5[dayFC + i] + (day6[dayGY + i] - day5[dayFC + i]) * day7[ddAMKI + i]
          + ((day5[dayFD + i] + (day6[dayGZ + i] - day5[dayFD + i]) * day7[ddAMKI + i])
            - (day5[dayFC + i] + (day6[dayGY + i] - day5[dayFC + i]) * day7[ddAMKI + i]))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    let ddML = 34675
    // ML=IF(OR(KI6=0,KZ6=0),0,$Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddML + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), Double.zero, day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) * day7[dddKI + i])
    }

    /// el to cover aux cons during harm op period
    // let ddMM = 35040
    // for i in 0..<365 { day7[ddMM + i] = 99 }
    // // MM=IF(OR(KZ6=0,KI6=0),0,FO6+(HK6-FO6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddMM + i] = iff(
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
    //     day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
    //       * day7[ddAMKI + i])
    // }

    /// el cons for BESS charging during harm op period
    let ddMN = 35405
    // MN=MIN(IF(OR(KI6=0,KZ6=0),MIN(FR6/BESS_chrg_eff,FZ6),(((FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[ddMN + i] = iff(
          or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), min(day5[dayFR + i] / BESS_chrg_eff, day5[dayFZ + i]), min(
          (day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKI + i]
            + ((day5[dayFZ + i] + (day6[dayHV + i] - day5[dayFZ + i]) * day7[ddAMKI + i])
              - (day5[dayFY + i] + (day6[dayHU + i] - day5[dayFY + i]) * day7[ddAMKI + i]))
              / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
        ,
        (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) * day7[ddAMKI + i]) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    // let ddMO = 35770
    // for i in 0..<365 { day7[ddMO + i] = 99 }
    // // MO=IF(OR(KZ6=0,KI6=0),0,(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddMO + i] = iff(
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
    //     (day5[dayFL + i]
    //       + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //         * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((day5[dayFM + i]
    //         + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //           * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (day5[dayFL + i]
    //           + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //             * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    // /// heat cons for harm op during harm op period
    // let ddMU = 37960
    // // MU=IF(OR(KZ6=0,KI6=0),0,(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddMU + i] = iff(
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
    //     (day5[dayFF + i]
    //       + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //         * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //       + ((day5[dayFG + i]
    //         + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //           * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    //         - (day5[dayFF + i]
    //           + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
    //             * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
    //       / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    // }

    /// heat cons for night prep during harm op period
    let ddMV = 38325
    // MV=IF(OR(KI6=0,KZ6=0),0,$AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddMV + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), Double.zero, day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) * day7[dddKI + i])
    }

    // /// heat prod by el boiler for harm op during harm op period
    // let ddMW = 38690
    // // MW=IF(OR(KZ6=0,KI6=0),0,MO6*El_boiler_eff)
    // for i in 0..<365 {
    //   day7[ddMW + i] = iff(
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero, day7[ddMO + i] * El_boiler_eff)
    // }

    /// Heat available during harm op period after TES chrg
    let ddMY = 39420
    // MY=IF(OR(KI6=0,KZ6=0),FW6,FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddMY + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), day5[dayFW + i],
        day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i]
            + ((day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) * day7[ddAMKI + i])
              - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) * day7[ddAMKI + i]))
              / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// heat prod by el boiler for night prep during harm op period
    let ddMX = 39055
    // MX=IF(OR(KI6=0,KZ6=0),0,MIN((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc),MAX(0,MV6-MY6)))
    for i in 0..<365 {
      day7[ddMX + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), Double.zero,
        min(
          (day5[dayGH + i] + (day6[dayID + i] - day5[dayGH + i]) * day7[ddAMKI + i])
            + ((day5[dayGI + i] + (day6[dayIE + i] - day5[dayGI + i]) * day7[ddAMKI + i])
              - (day5[dayGH + i] + (day6[dayID + i] - day5[dayGH + i]) * day7[ddAMKI + i]))
              / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc),
          max(Double.zero, day7[ddMV + i] - day7[ddMY + i])))
    }

    /// Balance of heat during harm op period
    let ddMZ = 39785
    // MZ=MX6+MY6-MV6
    for i in 0..<365 { day7[ddMZ + i] = day7[ddMX + i] + day7[ddMY + i] - day7[ddMV + i] }

    /// el cons for el boiler op for night prep during harm op period
    let ddMP = 36135
    // MP=MX6/El_boiler_eff
    for i in 0..<365 { day7[ddMP + i] = day7[ddMX + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let ddMQ = 36500
    // MQ=IF(OR(KI6=0,KZ6=0),FT6,FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((FT6+(HP6-FT6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FS6+(HO6-FS6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddMQ + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), day5[dayFT + i],
        day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKI + i]
            + ((day5[dayFT + i] + (day6[dayHP + i] - day5[dayFT + i]) * day7[ddAMKI + i])
              - (day5[dayFS + i] + (day6[dayHO + i] - day5[dayFS + i]) * day7[ddAMKI + i]))
              / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for harm op during harm op period
    let ddMR = 36865
    // MR=IF(OR(KI6=0,KZ6=0),FJ6,(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddMR + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayFJ + i],
        (day5[dayFI + i] + (day6[dayHE + i] - day5[dayFI + i]) * day7[ddAMKI + i])
          + ((day5[dayFJ + i] + (day6[dayHF + i] - day5[dayFJ + i]) * day7[ddAMKI + i])
            - (day5[dayFI + i] + (day6[dayHE + i] - day5[dayFI + i]) * day7[ddAMKI + i]))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let ddMS = 37230
    // MS=MIN(IF(OR(KI6=0,KZ6=0),GF6,(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc)),MAX(0,ML6+MN6+MP6-MQ6))
    for i in 0..<365 {
      day7[ddMS + i] = min(
        iff(
          or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayGF + i],
          (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKI + i])
            + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) * day7[ddAMKI + i])
              - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) * day7[ddAMKI + i]))
            / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc)),
        max(0, day7[ddML + i] + day7[ddMN + i] + day7[ddMP + i] - day7[ddMQ + i]))
    }

    /// Balance of electricity during harm op period
    let ddMT = 37595
    //  MT=MQ6+MS6-ML6-MN6-MP6
    for i in 0..<365 { day7[ddMT + i] = day7[ddMQ + i] + day7[ddMS + i] - day7[ddML + i] - day7[ddMN + i] - day7[ddMP + i] }
    /// el cons for harm op outside of harm op period
    let ddNA = 40150
    // NA=IF(OR(KI6=0,KZ6=0),0,FE6+(HA6-FE6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddNA + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i]) * day7[ddAMKI + i])
    }

    /// el to cover aux cons outside of harm op period
    let ddNB = 40515
    // NB=IF(OR(KI6=0,KZ6=0),FK6,FK6+(HG6-FK6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddNB + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayFK + i],
        day5[dayFK + i] + (day6[dayHG + i] - day5[dayFK + i]) * day7[ddAMKI + i])
    }

    /// el from BESS discharging outside of harm op period
    let ddND = 41245
    // ND=MIN(NB6,(IF(MN6*BESS_chrg_eff>=NB6,0,IF(OR(KI6=0,KZ6=0),GA6,GA6+(HW6-GA6)/($AM6-D_equiv_harmonious_min_perc)*(KG6-D_equiv_harmonious_min_perc)))+MN3)*BESS_chrg_eff)
    for i in 0..<365 { day7[ddND + i] = min(day7[ddNB + i], (
        iff(day7[ddMN + i] * BESS_chrg_eff >= day7[ddNB + i], Double.zero,
          iff(or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayGA + i], day5[dayGA + i] + (day6[dayHW + i] - day5[dayGA + i]) * day7[ddAMKG + i])) + day7[ddMN + i]) * BESS_chrg_eff) }

    /// el cons for el boiler for harm op outside of harm op period
    let ddNC = 40880
    // NC=NB6-ND6
    for i in 0..<365 { day7[ddNC + i] = day7[ddNB + i] - day7[ddND + i] }

    /// El available outside of harm op period after TES chrg
    let ddNE = 41610
    // NE=IF(OR(KI6=0,KZ6=0),FU6,FU6+(HQ6-FU6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(ND6/BESS_chrg_eff-MN6))
    for i in 0..<365 {
      day7[ddNE + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayFU + i],
        day5[dayFU + i] + (day6[dayHQ + i] - day5[dayFU + i]) * day7[ddAMKI + i]) - (day7[ddND + i] / BESS_chrg_eff - day7[ddMN + i])
    }

    /// Grid import needed outside of harm op period
    let ddNF = 41975
    // NF=MIN(IF(OR(KI6=0,KZ6=0),GG6,GG6+(IC6-GG6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+ND6),MAX(0,NB6-NC6-ND6-NE6))
    for i in 0..<365 {
      day7[ddNF + i] = min(
        iff(
          or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayGG + i],
          day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) * day7[ddAMKI + i] + day7[ddND + i]),
        max(Double.zero, day7[ddNB + i] - day7[ddNC + i] - day7[ddND + i] - day7[ddNE + i]))
    }

    /// Balance of electricity outside of harm op period
    let ddNG = 42340
    // NG=NC6+ND6+NE6+NF6-NB6
    for i in 0..<365 { day7[ddNG + i] = day7[ddNC + i] + day7[ddND + i] + day7[ddNE + i] + day7[ddNF + i] - day7[ddNB + i] }

    // /// heat cons for harm op outside of harm op period
    // let ddNH = 42705
    // // NH=IF(OR(KZ6=0,KI6=0),0,FH6+(HD6-FH6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    // for i in 0..<365 {
    //   day7[ddNH + i] = iff(
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
    //     day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
    //       * day7[ddAMKI + i])
    // }

    // /// Heat prod by el boiler for harm op outside of harm op period
    // let ddNI = 43070
    // // NI=IF(OR(KZ6=0,KI6=0),0,NC6*El_boiler_eff)
    // for i in 0..<365 {
    //   day7[ddNI + i] = if
    //     or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero, day7[ddNC + i] * El_boiler_eff)
    // }

    /// Heat available outside of harm op period after TES chrg
    let ddNJ = 43435
    // NJ=IF(OR(KI6=0,KZ6=0),FX6,FX6+(HT6-FX6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddNJ + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayFX + i],
        day5[dayFX + i] + (day6[dayHT + i] - day5[dayFX + i]) * day7[ddAMKI + i])
    }

    /// Balance of heat outside of harm op period
    let ddNK = 43800
    // NK=NJ6
    for i in 0..<365 { day7[ddNK + i] = day7[ddNJ + i] }

    /// Grid export
    let ddNM = 44530
    // NM=MAX(0,MIN(MT6,IF(OR(KI6=0,KZ6=0),GC6,GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)+((GC6+(HY6-GC6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KZ6-Overall_harmonious_min_perc))))+MAX(0,MIN(NG6,IF(OR(KI6=0,KZ6=0),GD6,GD6+(HZ6-GD6)/($AM6-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))))
    for i in 0..<365 {
      day7[ddNM + i] =
        max(
          Double.zero,
          min(
            day7[ddMT + i],
            iff(
              or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayGC + i],
              day5[dayGB + i] + (day6[dayHX + i] - day5[dayGB + i]) * day7[ddAMKI + i])
              + ((day5[dayGC + i] + (day6[dayHY + i] - day5[dayGC + i]) * day7[ddAMKI + i])
                - (day5[dayGB + i] + (day6[dayHX + i] - day5[dayGB + i]) * day7[ddAMKI + i]))
              / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc)))
        + max(
          Double.zero,
          min(
            day7[ddNG + i],
            iff(
              or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day5[dayGD + i],
              day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i]) * day7[ddAMKI + i])))
    }

    /// Grid import
    let ddNN = 44895
    // NN=MR6+NF6+NC6+MS6
    for i in 0..<365 { day7[ddNN + i] = day7[ddMR + i] + day7[ddNF + i] + day7[ddNC + i] + day7[ddMS + i] }

    /// Outside harmonious operation period hours
    let ddNO = 45260
    // NO=IF(OR(KI6=0,KZ6=0),$C6,$C6+($T6-$C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { day7[ddNO + i] =
        iff(or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day1[dayC + i], day1[dayC + i] + (day1[dayT + i] - day1[dayC + i]) * day7[dddKI + i]) }

    /// Harmonious operation period hours
    let ddNP = 45625
    // NP=IF(OR(KI6=0,KZ6=0),$D6,$D6+($U6-$D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { day7[ddNP + i] =
        iff(or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day1[dayD + i], day1[dayD + i] + (day1[dayU + i] - day1[dayD + i]) * day7[dddKI + i]) }

    /// Pure Methanol prod with night priority and resp day op
    let ddNL = 44165
    // NL=(MAX(0,MK6-NP6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,NA6-NO6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[ddNL + i] =
        (max(Double.zero, day7[ddMK + i] - day7[ddNP + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + max(
          Double.zero, day7[ddNA + i] - day7[ddNO + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// PB operating hours
    let ddNQ = 45990
    // NQ=IF(OR(KI6=0,KZ6=0),$E6,$E6+($V6-$E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KI6-A_equiv_harmonious_min_perc))
    for i in 0..<365 { day7[ddNQ + i] =
        iff(or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), day1[dayE + i], day1[dayE + i] + (day1[dayV + i] - day1[dayE + i]) * day7[dddKI + i]) }

    /// Checksum
    let ddNR = 46355
    // NR=MAX(0,-MT6)+MAX(0,-MZ6)+MAX(0,-NG6)+MAX(0,-NK6)
    for i in 0..<365 {
      let NR = max(Double.zero, -day7[ddMT + i]) + max(Double.zero, -day7[ddMZ + i]) + max(Double.zero, -day7[ddNG + i]) + max(Double.zero, -day7[ddNK + i])
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      day7[ddNR + i] = NR
    }
  }
}
