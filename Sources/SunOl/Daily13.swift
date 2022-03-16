
extension TunOl {
  func day(case j: Int, day1: [Double], day5: [Double], day6: [Double]) -> [Double] {
    let (dayC, dayD, dayE, dayT, dayU, dayV, dayZ, dayAA, dayAB, dayAC, dayAD, dayAE, dayAF, dayAG, dayAH, dayAI, dayAM) = (
      0, 365, 730, 5840, 6205, 6570, 8030, 8395, 8760, 9125, 9490, 9855, 10220, 10585, 10950, 11315, 12775 
    ) // day1

    let (dayEY, dayEZ, dayFA, dayFB, dayFC, dayFD, dayFE, dayFF, dayFG, dayFH, dayFI, dayFJ, dayFL, dayFM, dayFN, dayFO, dayFP, dayFR, dayFS, dayFT, dayFV, dayFW, dayFY, dayFZ, dayGB, dayGC, dayGD, dayGE, dayGF, dayGG, dayGH, dayGI, dayGK, dayGL, dayGN, dayGO, dayGQ, dayGR) = (
      0, 365, 730, 1095, 1460, 1825, 2190, 2555, 2920, 3285, 3650, 4015, 4745, 5110, 5475, 5840, 6205, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    ) // day5

    let (dayGU, dayGV, dayGW, dayGX, dayGY, dayGZ, dayHA, dayHB, dayHC, dayHD, dayHE, dayHF, dayHH, dayHI, dayHJ, dayHK, dayHL, dayHN, dayHO, dayHP, dayHR, dayHS, dayHU, dayHV, dayHX, dayHY, dayHZ, dayIA, dayIB, dayIC, dayID, dayIE, dayIG, dayIH, dayIJ, dayIK, dayIM, dayIN) = (
      0, 365, 730, 1095, 1460, 1825, 2190, 2555, 2920, 3285, 3650, 4015, 4745, 5110, 5475, 5840, 6205, 6935, 7300, 7665, 8395, 8760, 9490, 9855, 10585, 10950, 11315, 11680, 12045, 12410, 12775, 13140, 13870, 14235, 14965, 15330, 16060, 16425
    ) // day6
    var day7 = [Double](repeating: Double.zero, count: 46_720)
    
    /// Surplus harm op period electricity after min harm op and min night op prep
    let dddIQ = 0 
    // FS6+GE6-$Z6-MAX(0;$AB6-FV6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      day7[dddIQ + i] =
        day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i] - max(
          Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff
    }

    let equiv_harmonious_range = (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    /// Surplus harm op period electricity after min harm op and max night op prep
    let dddIR = 365
    // HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0;($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-HN6/BESS_chrg_eff
    for i in 0..<365 {
      day7[dddIR + i] =
        day6[dayHO + i] + day6[dayIA + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
        - max(
            0,
            (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - day6[dayHR + i]) / El_boiler_eff - day6[dayHN + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let dddIS = 730 
    // FT6+GF6-$Z6-MAX(0;$AB6-FW6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      day7[dddIS + i] =
        day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i] - max(
          Double.zero, day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let dddIT = 1095 
    // FV6+MAX(0;FS6+GE6-$Z6-FR6/BESS_chrg_eff)*El_boiler_eff-$AB6
    for i in 0..<365 {
      day7[dddIT + i] =
        day5[dayFV + i] + max(
          Double.zero, day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i] - day5[dayFR + i] / BESS_chrg_eff)
        * El_boiler_eff - day1[dayAB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let dddIU = 1460 
    // =HR6+MAX(0;HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddIU + i] =
        day6[dayHR + i]
        + max(Double.zero,
            day6[dayHO + i] + day6[dayIA + i]-(day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - day6[dayHN + i] / BESS_chrg_eff) * El_boiler_eff
        - (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }


    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let dddIV = 1825
    // =FW6+MAX(0;FT6+GF6-$Z6-FR6/BESS_chrg_eff)*El_boiler_eff-$AB6
    for i in 0..<365 { 
      day7[dddIV + i] =
        day5[dayFW + i] + max(
          Double.zero, day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i] - day5[dayFR + i] / BESS_chrg_eff)
        * El_boiler_eff - day1[dayAB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let dddIW = 2190
    // GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 {
      day7[dddIW + i] = day5[dayGH + i] - max(Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep
    let dddIX = 2555
    // ID6-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 { 
      day7[dddIX + i] =
        day6[dayID + i]
        - max(Double.zero, (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
          - day6[dayHR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let dddIY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 {
      day7[dddIY + i] = day5[dayGI + i] - max(0,(day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff)
    }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let dddIZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let dddJA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let dddJB = 4015

    for i in 0..<365 {
      // FY6-FR6/BESS_chrg_eff
      day7[dddIZ + i] = day5[dayFY + i] - day5[dayFR + i] / BESS_chrg_eff
      // HU6-HN6/BESS_chrg_eff
      day7[dddJA + i] = day6[dayHU + i] - day6[dayHN + i] / BESS_chrg_eff
      // FZ6-FR6/BESS_chrg_eff
      day7[dddJB + i] = day5[dayFZ + i] - day5[dayFR + i] / BESS_chrg_eff
    }

    /// Surplus Grid input cap after min harm op and min night op prep
    let ddJC = 4380
    /// =GE6-MAX(0,-(FS6-$Z6-MAX(0,$AB6-FV6)/El_boiler_eff-FR6/BESS_chrg_eff))	
    for i in 0..<365 {
      day7[ddJC + i] =
        day5[dayGE + i]
        - max(0, -(day5[dayFS + i] - day1[dayZ + i] - max(0, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff))
    }

    ///	Surplus grid import cap after min harm op and max night op prep
    let ddJD = 4745
    /// =IA6-MAX(0,-(HO6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-HN6/BESS_chrg_eff))
    for i in 0..<365 {
      let equiv_harmonious = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]
      day7[ddJD + i] =
        day6[dayIA + i]
        - max(
          Double.zero, -(day6[dayHO + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious
                  * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                - day6[dayHR + i]) / El_boiler_eff - day6[dayHN + i] / BESS_chrg_eff))
    }
    /// Surplus grid import cap after max harm op and min night op prep
    let ddJE = 5110
    /// =GF6-MAX(0,-(FT6-$Z6-MAX(0,$AB6-FW6)/El_boiler_eff-FR6/BESS_chrg_eff))
    for i in 0..<365 {
      day7[ddJE + i] =
        day5[dayGF + i] - max(Double.zero, -(day5[dayFT + i] - day1[dayZ + i] - max(0, day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff))
    }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let ddJF = 5475
      // GK6-AD6
    for i in 0..<365 { day7[ddJF + i] = day5[dayGK + i] - day1[dayAD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let ddJG = 5840
    // IG6-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJG + i] =
        day6[dayIG + i]
        - (day1[dayAD + i]
          + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let ddJH = 6205
    // GL6-AD6
    for i in 0..<365 { day7[ddJH + i] = day5[dayGL + i] - day1[dayAD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let ddJI = 6570
    // GN6-AF6
    for i in 0..<365 { day7[ddJI + i] = day5[dayGN + i] - day1[dayAF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let ddJJ = 6935
    // IJ6-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJJ + i] =
        day6[dayIJ + i] - (day1[dayAF + i]
          + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let ddJK = 7300
    // GO6-AF6
    for i in 0..<365 { day7[ddJK + i] = day5[dayGO + i] - day1[dayAF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let ddJL = 7665
    // GQ6-AH6
    for i in 0..<365 { day7[ddJL + i] = day5[dayGQ + i] - day1[dayAH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let ddJM = 8030
    // IM6-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddJM + i] =
        day6[dayIM + i] - (day1[dayAH + i]
          + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let ddJN = 8395
    // GR6-AH6
    for i in 0..<365 { day7[ddJN + i] = day5[dayGR + i] - day1[dayAH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let ddJP = 8760
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IS6),1),IFERROR(IT6/(IT6-IV6),1),IFERROR(IW6/(IW6-IY6),1),IFERROR(IZ6/(IZ6-JB6),1),IFERROR(JC6/(JC6-JE6),1),IFERROR(JF6/(JF6-JH6),1),IFERROR(JI6/(JI6-JK6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddJP + i] = iff(
        or(
          day7[dddIQ + i] < Double.zero, day7[dddIT + i] < Double.zero, day7[dddIW + i] < Double.zero, day7[dddIZ + i] < Double.zero,
          day7[ddJF + i] < Double.zero, day7[ddJI + i] < Double.zero, day7[ddJL + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dddIQ + i] / max(Double.zero, (day7[dddIQ + i] - day7[dddIS + i])), 1),
          ifFinite(day7[dddIT + i] / max(Double.zero, (day7[dddIT + i] - day7[dddIV + i])), 1),
          ifFinite(day7[dddIW + i] / max(Double.zero, (day7[dddIW + i] - day7[dddIY + i])), 1),
          ifFinite(day7[dddIZ + i] / max(Double.zero, (day7[dddIZ + i] - day7[dddJB + i])), 1),
          ifFinite(day7[ddJF + i] / max(Double.zero, (day7[ddJF + i] - day7[ddJH + i])), 1),
          ifFinite(day7[ddJI + i] / max(Double.zero, (day7[ddJI + i] - day7[ddJK + i])), 1),
          ifFinite(day7[ddJL + i] / max(Double.zero, (day7[ddJL + i] - day7[ddJN + i])), 1))
          * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let ddJQ = 9125
    // IF(JM6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-MAX(0,AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddJQ + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayFS + i]
            + (day5[dayFT + i] - day5[dayFS + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            + (day5[dayGE + i]
              + (day5[dayGF + i] - day5[dayGE + i]) / Overall_harmonious_range
                * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - day1[dayZ + i] - max(
              Double.zero,
              day1[dayAB + i]
                - (day5[dayFV + i]
                  + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
                    * (day7[ddJP + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let ddJR = 9490
    // IF(JM6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddJR + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayHO + i]
            + (day6[dayHP + i] - day6[dayHO + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            + (day6[dayIA + i]
              + (day6[dayIB + i] - day6[dayIA + i]) / Overall_harmonious_range
                * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - (day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                - (day6[dayHR + i]
                  + (day6[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
                    * (day7[ddJP + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - day6[dayHN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let ddJS = 9855
    // IF(JM6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6,5))
    for i in 0..<365 {
      day7[ddJS + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayFV + i]
            + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            + max(
              Double.zero,
              (day5[dayFS + i]
                + (day5[dayFT + i] - day5[dayFS + i]) / Overall_harmonious_range
                  * (day7[ddJP + i] - Overall_harmonious_min_perc))
                + (day5[dayGE + i]
                  + (day5[dayGF + i] - day5[dayGE + i]) / Overall_harmonious_range
                    * (day7[ddJP + i] - Overall_harmonious_min_perc))
                - day1[dayZ + i] - day5[dayFR + i] / BESS_chrg_eff) * El_boiler_eff - day1[dayAB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let ddJT = 10220
    // IF(JM6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddJT + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayHR + i]
            + (day6[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            + max(
              Double.zero,
              (day6[dayHO + i]
                + (day6[dayHP + i] - day6[dayHO + i]) / Overall_harmonious_range
                  * (day7[ddJP + i] - Overall_harmonious_min_perc))
                + (day6[dayIA + i]
                  + (day6[dayIB + i] - day6[dayIA + i]) / Overall_harmonious_range
                    * (day7[ddJP + i] - Overall_harmonious_min_perc))
                - (day1[dayZ + i]
                  + (day1[dayAA + i] - day1[dayZ + i])
                    / equiv_harmonious_range
                    * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                - day6[dayHN + i] / BESS_chrg_eff) * El_boiler_eff
            - (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let ddJU = 10585
    // =IF(JM6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddJU + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayGH + i]
            + (day5[dayGI + i] - day5[dayGH + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - max(Double.zero, day1[dayAB + i]
              - (day5[dayFV + i]
                + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
                  * (day7[ddJP + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let ddJV = 10950
    // =IF(JM6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddJV + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayID + i]
            + (day6[dayIE + i] - day6[dayID + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - (day6[dayHR + i]
                + (day6[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
                  * (day7[ddJP + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let ddJW = 11315
    // IF(JM6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddJW + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayFY + i]
            + (day5[dayFZ + i] - day5[dayFY + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - day5[dayFR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let ddJX = 11680
    // IF(JM6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddJX + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day6[dayHU + i]
            + (day6[dayHV + i] - day6[dayHU + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - day6[dayHN + i] / BESS_chrg_eff, 5))
    }
    /// Surplus grid import cap after opt day harm and min night op prep
    let ddJY = 12045
    // =IF(JP4=0,0,ROUND((GE4+(GF4-GE4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc))-MAX(0,-((FS4+(FT4-FS4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc))-$Z4-MAX(0,$AB4-(FV4+(FW4-FV4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc)))/El_boiler_eff-FR4/BESS_chrg_eff)),5))
for i in 0..<365 {
    day7[ddJY + i] = iff(
      day7[ddJP + i].isZero, 0,
      round(
        (day5[dayGE + i]
          + (day5[dayGF + i] - day5[dayGE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (day7[ddJP + i] - Overall_harmonious_min_perc))
          - max(
            0,
            -((day5[dayFS + i]
              + (day5[dayFT + i] - day5[dayFS + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (day7[ddJP + i] - Overall_harmonious_min_perc))
              - day1[dayZ + i] - max(
                0,
                day1[dayAB + i]
                  - (day5[dayFV + i]
                    + (day5[dayFW + i] - day5[dayFV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                      * (day7[ddJP + i] - Overall_harmonious_min_perc))
              ) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff)), 5))
}
    /// Surplus grid import cap after opt day harm and max night op prep
    let ddJZ = 12410
    // =IF(JP4=0,0,ROUND((IA4+(IB4-IA4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc))-MAX(0,-((HO4+(HP4-HO4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc))-($Z4+($AA4-$Z4)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM4-A_equiv_harmonious_min_perc))-MAX(0,($AB4+($AC4-$AB4)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM4-A_equiv_harmonious_min_perc))-(HR4+(HS4-HR4)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JP4-Overall_harmonious_min_perc)))/El_boiler_eff-HN4/BESS_chrg_eff)),5))
    for i in 0..<365 {
    day7[ddJZ + i] = iff(
      day7[ddJP + i].isZero, 0,
      round(
        (day6[dayIA + i]
          + (day6[dayIB + i] - day6[dayIA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (day7[ddJP + i] - Overall_harmonious_min_perc))
          - max(
            0,
            -((day6[dayHO + i]
              + (day6[dayHP + i] - day6[dayHO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (day7[ddJP + i] - Overall_harmonious_min_perc))
              - (day1[dayZ + i]
                + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - max(
                0,
                (day1[dayAB + i]
                  + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                  - (day6[dayHR + i]
                    + (day6[dayHS + i] - day6[dayHR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                      * (day7[ddJP + i] - Overall_harmonious_min_perc))
              ) / El_boiler_eff - day6[dayHN + i] / BESS_chrg_eff)), 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let ddKA = 12775
    // IF(JM6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AD6,5))
    for i in 0..<365 {
      day7[ddKA + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayGK + i]
            + (day5[dayGL + i] - day5[dayGK + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc))
            - day1[dayAD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let ddKB = 13140
    // IF(JM6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKB + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGK + i] + (day5[dayGL + i] - day5[dayGK + i])
            / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc)
            - (day1[dayAD + i]
              + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let ddKC = 13505
    // IF(JM6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AF6,5))
    for i in 0..<365 {
      day7[ddKC + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayGN + i]
            + (day5[dayGO + i] - day5[dayGN + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc)) - day1[dayAF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let ddKD = 13870
    // IF(JM6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKD + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGN + i] + (day5[dayGO + i] - day5[dayGN + i])
            / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc)
            - (day1[dayAF + i]
              + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let ddKE = 14235
    // IF(JM6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AH6,5))
    for i in 0..<365 {
      day7[ddKE + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          (day5[dayGQ + i]
            + (day5[dayGR + i] - day5[dayGQ + i]) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc)) - day1[dayAH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let ddKF = 14600
    // IF(JM6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKF + i] = iff(
        day7[ddJP + i].isZero, Double.zero,
        round(
          day5[dayGQ + i] + (day5[dayGR + i] - day5[dayGQ + i])
            / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc)
            - (day1[dayAH + i]
              + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt night prep during day prio operation
    let ddKG = 14965
    // IF(OR(JM6=0,JN6<0,JP6<0,JR6<0,JT6<0,JV6<0,JX6<0,JZ6<0),0,MIN(1,IFERROR(JN6/(JN6-JO6),1),IFERROR(JP6/(JP6-JQ6),1),IFERROR(JR6/(JR6-JS6),1),IFERROR(JT6/(JT6-JU6),1),IFERROR(JV6/(JV6-JW6),1),IFERROR(JX6/(JX6-JY6),1),IFERROR(JZ6/(JZ6-KA6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKG + i] = iff(
        or(
          day7[ddJP + i].isZero, day7[ddJQ + i] < Double.zero, day7[ddJS + i] < Double.zero, day7[ddJU + i] < Double.zero,
          day7[ddJW + i] < Double.zero, day7[ddKA + i] < Double.zero, day7[ddKC + i] < Double.zero, day7[ddKE + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[ddJQ + i] / max(Double.zero, (day7[ddJQ + i] - day7[ddJR + i])), 1),
          ifFinite(day7[ddJS + i] / max(Double.zero, (day7[ddJS + i] - day7[ddJT + i])), 1),
          ifFinite(day7[ddJU + i] / max(Double.zero, (day7[ddJU + i] - day7[ddJV + i])), 1),
          ifFinite(day7[ddJW + i] / max(Double.zero, (day7[ddJW + i] - day7[ddJX + i])), 1),
          ifFinite(day7[ddKA + i] / max(Double.zero, (day7[ddKA + i] - day7[ddKB + i])), 1),
          ifFinite(day7[ddKC + i] / max(Double.zero, (day7[ddKC + i] - day7[ddKD + i])), 1),
          ifFinite(day7[ddKE + i] / max(Double.zero, (day7[ddKE + i] - day7[ddKF + i])), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let ddKI = 15330
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IR6),1),IFERROR(IT6/(IT6-IU6),1),IFERROR(IW6/(IW6-IX6),1),IFERROR(IZ6/(IZ6-JA6),1),IFERROR(JC6/(JC6-JD6),1),IFERROR(JF6/(JF6-JG6),1),IFERROR(JI6/(JI6-JJ6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKI + i] = iff(
        or(
          day7[dddIQ + i] < Double.zero, day7[dddIT + i] < Double.zero, day7[dddIW + i] < Double.zero, day7[dddIZ + i] < Double.zero,
          day7[ddJF + i] < Double.zero, day7[ddJI + i] < Double.zero, day7[ddJL + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dddIQ + i] / max(Double.zero, (day7[dddIQ + i] - day7[dddIR + i])), 1),
          ifFinite(day7[dddIT + i] / max(Double.zero, (day7[dddIT + i] - day7[dddIU + i])), 1),
          ifFinite(day7[dddIW + i] / max(Double.zero, (day7[dddIW + i] - day7[dddIX + i])), 1),
          ifFinite(day7[dddIZ + i] / max(Double.zero, (day7[dddIZ + i] - day7[dddJA + i])), 1),
          ifFinite(day7[ddJF + i] / max(Double.zero, (day7[ddJF + i] - day7[ddJG + i])), 1),
          ifFinite(day7[ddJI + i] / max(Double.zero, (day7[ddJI + i] - day7[ddJJ + i])), 1),
          ifFinite(day7[ddJL + i] / max(Double.zero, (day7[ddJL + i] - day7[ddJM + i])), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let ddKJ = 15698
    // IF(KD6=0,0,ROUND((FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKJ + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFS + i]
            + (day6[dayHO + i] - day5[dayFS + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            + (day5[dayGE + i]
              + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (day5[dayFR + i]
              + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let ddKK = 16060
    // IF(KD6=0,0,ROUND((FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKK + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFT + i]
            + (day6[dayHP + i] - day5[dayFT + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            + (day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFW + i]
                  + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (day5[dayFR + i]
              + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let ddKL = 16425
    // IF(KD6=0,0,ROUND((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKL + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFV + i]
            + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            + (max(
              Double.zero,
              (day5[dayFS + i]
                + (day6[dayHO + i] - day5[dayFS + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                + (day5[dayGE + i]
                  + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayZ + i]
                  + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - ((day5[dayFR + i]
                  + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let ddKM = 16790
    // IF(KD6=0,0,ROUND((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKM + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFW + i]
            + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            + (max(
              Double.zero,
              (day5[dayFT + i]
                + (day6[dayHP + i] - day5[dayFT + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                + (day5[dayGF + i]
                  + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayZ + i]
                  + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - ((day5[dayFR + i]
                  + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let ddKN = 17155
    // IF(KD6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddKN + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGH + i]
            + (day6[dayID + i] - day5[dayGH + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFV + i]
                + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let ddKO = 17520
    // =IF(KD6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[ddKO + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGI + i]
            + (day6[dayIE + i] - day5[dayGI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFW + i] + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let ddKP = 17885
    // IF(KD6=0,0,ROUND((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKP + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let ddKQ = 18250
    // IF(KD6=0,0,ROUND((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[ddKQ + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayFZ + i]
            + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }
    /// Surplus grid import cap after min day harmonious and opti night op prep
    let ddKR = 18615
    for i in 0..<365 {
    day7[ddKR + i] = iff(
      day7[ddKI + i].isZero, 0,
      round(
        (day5[dayGE + i]
          + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          - max(
            Double.zero,
            -((day5[dayFS + i]
              + (day6[dayHO + i] - day5[dayFS + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (day1[dayZ + 1]
                + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - max(
                Double.zero,
                (day1[dayAB + i]
                  + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                  - (day5[dayFV + i]
                    + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                      * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              ) / El_boiler_eff
              - (day5[dayFR + i]
                + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                / BESS_chrg_eff)
          ), 5))
    }
    /// Surplus grid import cap after max day harmonious and opti night op prep
    let ddKS = 18980
    for i in 0..<365 {
    day7[ddKS + i] = iff(
      day7[ddKI + i].isZero, 0,
      round(
        (day5[dayGF + i]
          + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          - max(
            Double.zero,
            -((day5[dayFT + i]
              + (day6[dayHP + i] - day5[dayFT + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (day1[dayZ + 1]
                + (day1[dayAA + i] - day1[dayZ + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (max(
                Double.zero,
                (day1[dayAB + i]
                  + (day1[dayAC + i] - day1[dayAB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                  - (day5[dayFW + i]
                    + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                      * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              ) / El_boiler_eff)
              - ((day5[dayFR + i]
                + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                / BESS_chrg_eff))
          ), 5))
    }
    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let ddKT = 19345
    // IF(KD6=0,0,ROUND((GK6+(IG6-GK6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKT + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGK + i]
            + (day6[dayIG + i] - day5[dayGK + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let ddKU = 19710
    // IF(KD6=0,0,ROUND((GL6+(IH6-GL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKU + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGL + i]
            + (day6[dayIH + i] - day5[dayGL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let ddKV = 20075
    // IF(KD6=0,0,ROUND((GN6+(IJ6-GN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKV + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGN + i]
            + (day6[dayIJ + i] - day5[dayGN + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let ddKW = 20440
    // IF(KD6=0,0,ROUND((GO6+(IK6-GO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKW + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGO + i]
            + (day6[dayIK + i] - day5[dayGO + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let ddKX = 20805
    // IF(KD6=0,0,ROUND((GQ6+(IM6-GQ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKX + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGQ + i]
            + (day6[dayIM + i] - day5[dayGQ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let ddKY = 21170
    // IF(KD6=0,0,ROUND((GR6+(IN6-GR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[ddKY + i] = iff(
        day7[ddKI + i].isZero, Double.zero,
        round(
          (day5[dayGR + i]
            + (day6[dayIN + i] - day5[dayGR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let ddKZ = 21535
    // IF(KD6<=0,0,MIN(1,IFERROR(KE6/(KE6-KF6),1),IFERROR(KG6/(KG6-KH6),1),IFERROR(KI6/(KI6-KJ6),1),IFERROR(KK6/(KK6-KL6),1),IFERROR(KM6/(KM6-KN6),1),IFERROR(KO6/(KO6-KP6),1),IFERROR(KQ6/(KQ6-KR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[ddKZ + i] = iff(
        day7[ddKI + i] <= Double.zero, Double.zero,
        min(
          1, ifFinite(day7[ddKJ + i] / max(Double.zero, (day7[ddKJ + i] - day7[ddKK + i])), 1),
          ifFinite(day7[ddKL + i] / max(Double.zero, (day7[ddKL + i] - day7[ddKM + i])), 1),
          ifFinite(day7[ddKN + i] / max(Double.zero, (day7[ddKN + i] - day7[ddKO + i])), 1),
          ifFinite(day7[ddKP + i] / max(Double.zero, (day7[ddKP + i] - day7[ddKQ + i])), 1),
          ifFinite(day7[ddKT + i] / max(Double.zero, (day7[ddKT + i] - day7[ddKU + i])), 1),
          ifFinite(day7[ddKV + i] / max(Double.zero, (day7[ddKV + i] - day7[ddKW + i])), 1),
          ifFinite(day7[ddKX + i] / max(Double.zero, (day7[ddKX + i] - day7[ddKY + i])), 1))
          * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period
    let ddLB = 21900
    // IF(OR(JM6=0,KB6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[ddLB + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day5[dayFC + i]
          + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFD + i]
            + (day6[dayGZ + i] - day5[dayFD + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFC + i]
              + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc))
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////

    /// el cons for night prep during harm op period
    let dddKV = 19710
    // IF(OR(JM6=0,KB6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddKV + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let dddKW = 20075
    // IF(OR(JM6=0,KB6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddKW + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let dddKX = 20440
    // IF(OR(JM6=0,KB6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[dddKX + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        min(
          ((day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            + ((day5[dayFZ + i]
              + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFY + i]
                + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc)),
          (day5[dayFR + i]
            + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let dddKY = 20805
    // IF(OR(JM6=0,KB6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddKY + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day5[dayFL + i]
          + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFM + i]
            + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFL + i]
              + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for harm op during harm op period
    let dddLE = 22995
    // IF(OR(JM6=0,KB6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLE + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day5[dayFF + i]
          + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFG + i]
            + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFF + i]
              + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let dddLF = 23360
    // IF(OR(JM6=0,KB6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddLF + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let dddLG = 23725
    // IF(OR(JM6=0,KB6=0),0,KY6*El_boiler_eff)
    for i in 0..<365 {
      day7[dddLG + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day7[dddKY + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let dddLH = 24090
    // IF(OR(JM6=0,KB6=0),0,MAX(0,LF6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dddLH + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        max(
          Double.zero,
          day7[dddLF + i]
            - ((day5[dayFV + i]
              + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayFW + i]
                + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i]
                  + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
                / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let dddLI = 24455
    // IF(OR(JM6=0,KB6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLI + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFA + i] + (day6[dayGW + i] - day5[dayFA + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let dddLJ = 24820
    // LG6+LH6+LI6-LE6-LF6
    for i in 0..<365 {
      day7[dddLJ + i] =
        day7[dddLG + i] + day7[dddLH + i] + day7[dddLI + i] - day7[dddLE + i] - day7[dddLF + i]
    }

    /// el cons for el boiler op for night prep during harm op period
    let dddKZ = 21170
    // LH6/El_boiler_eff
    for i in 0..<365 { day7[dddKZ + i] = day7[dddLH + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let dddLA = 21535
    // IF(OR(JM6=0,KB6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      let a: Double = day5[dayEY + i] + (day6[dayGU + i] - day5[dayEY + i])
      let b: Double = (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j])
      day7[dddLA + i] = iff(or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, a / b)
    }

    /// Grid import for harm op during harm op period
    let dddLB = 21900
    // IF(OR(JM6=0,KB6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLB + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        (day5[dayFI + i]
          + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFJ + i]
            + (day6[dayHF + i] - day5[dayFJ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFI + i]
              + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let dddLC = 22265
    // IF(OR(JM6=0,KB6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc),MAX(0,-(LA6+LB6-KU6-KV6-KW6-KX6-KY6-KZ6))))
    for i in 0..<365 {
      day7[dddLC + i] = iff(
      or(
     day7[ddJP + i].isZero,day7[ddKG + i].isZero),0, min((day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j])) + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j])) - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range * (day7[ddJP + i] - Overall_harmonious_min_perc),max(Double.zero, -(day7[dddLA + i] + day7[dddLB + i] - day7[ddLB + i] - day7[dddKV + i] - day7[dddKW + i] - day7[dddKX + i] - day7[dddKY + i] - day7[dddKZ + i]))))
    }

    /// Balance of electricity during harm op period
    let dddLD = 22630
    // LA6+LB6+LC6-KU6-KV6-KW6-KX6-KY6-KZ6
    for i in 0..<365 {
      day7[dddLD + i] =
        day7[dddLA + i] + day7[dddLB + i] + day7[dddLC + i] - day7[ddLB + i] - day7[dddKV + i] - day7[dddKW + i] - day7[dddKX + i] - day7[dddKY + i] - day7[dddKZ + i]
    }  

    /// el cons for harm op outside of harm op period
    let dddLK = 25185
    // IF(OR(JM6=0,KB6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLK + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let dddLL = 25550
    // IF(OR(JM6=0,KB6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLL + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFP + i] + (day6[dayHL + i] - day5[dayFP + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let dddLM = 25915
    // IF(OR(JM6=0,KB6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLM + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFN + i] + (day6[dayHJ + i] - day5[dayFN + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let dddLN = 26280
    // KX6*BESS_chrg_eff
    for i in 0..<365 { day7[dddLN + i] = day7[dddKX + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let dddLO = 26645
    // IF(OR(JM6=0,KB6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLO + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayEZ + i] + (day6[dayGV + i] - day5[dayEZ + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let dddLP = 27010
    // IF(OR(JM6=0,KB6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc),MAX(0,-(LN6+LO6-LK6-LL6-LM6))))
    for i in 0..<365 {
      day7[dddLP + i] = iff(
      or(
     day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, min(day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]),max(Double.zero, -(day7[dddLN + i] + day7[dddLO + i] - day7[dddLK + i] - day7[dddLL + i] - day7[dddLM + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dddLQ = 27375
    // LN6+LO6+LP6-LK6-LL6-LM6
    for i in 0..<365 {
      day7[dddLQ + i] =
        day7[dddLN + i] + day7[dddLO + i] + day7[dddLP + i] - day7[dddLK + i] - day7[dddLL + i] - day7[dddLM + i]
    }

    /// heat cons for harm op outside of harm op period
    let dddLR = 27740
    // IF(OR(JM6=0,KB6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLR + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let dddLS = 28105
    // IF(OR(JM6=0,KB6=0),0,LM6*El_boiler_eff)
    for i in 0..<365 {
      day7[dddLS + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero, day7[dddLM + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let dddLT = 28470
    // IF(OR(JM6=0,KB6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddLT + i] = iff(
        or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
        day5[dayFB + i] + (day6[dayGX + i] - day5[dayFB + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let dddLU = 28835
    // LS6+LT6-LR6
    for i in 0..<365 { day7[dddLU + i] = day7[dddLS + i] + day7[dddLT + i] - day7[dddLR + i] }

    /// Pure Methanol prod with day priority and resp night op
    let dddLV = 29200
    // IF(KU6<=0,0,KU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(LK6<=0,0,(LK6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dddLV + i] =
        iff(
          day7[ddLB + i] <= Double.zero, Double.zero,
          day7[ddLB + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day7[dddLK + i] <= Double.zero, Double.zero,
          (day7[dddLK + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let dddLW = 29565
    // MIN(LD6,IF(OR(JM6=0,KB6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))+MIN(LQ6,IF(OR(JM6=0,KB6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddLW + i] =
        min(
          day7[dddLD + i],
          iff(
            or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
            (day5[dayGB + i]
              + (day6[dayHX + i] - day5[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayGC + i]
                + (day6[dayHY + i] - day5[dayGC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayGB + i]
                  + (day6[dayHX + i] - day5[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[ddJP + i] - Overall_harmonious_min_perc)))
        + min(
          day7[dddLQ + i],
          iff(
            or(day7[ddJP + i].isZero, day7[ddKG + i].isZero), Double.zero,
            day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i])
              / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKG + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let dddLX = 29930
    // LP6+LC6
    for i in 0..<365 { day7[dddLX + i] = day7[dddLP + i] + day7[dddLC + i] }

    /// Outside harmonious operation period hours
    let dddLY = 30295
    // IF(KB6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddLY + i] = iff(
        day7[ddKG + i] <= Double.zero, Double.zero,
        (day1[dayC + i] + (day1[dayT + i] - day1[dayC + i]) / equiv_harmonious_range
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let dddLZ = 30660
    // IF(KB6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddLZ + i] = iff(
        day7[ddKG + i] <= Double.zero, Double.zero,
        (day1[dayD + i] + (day1[dayU + i] - day1[dayD + i]) / equiv_harmonious_range
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let dddMA = 31025
    // IF(KB6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddMA + i] = iff(
        day7[ddKG + i] <= Double.zero, Double.zero,
        (day1[dayE + i] + (day1[dayV + i] - day1[dayE + i]) / equiv_harmonious_range
            * (day7[ddKG + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let dddMB = 31390
    // MAX(0,-LD6)+MAX(0,-LJ6)+MAX(0,-LQ6)+MAX(0,-LU6)
    for i in 0..<365 {
      let MB = max(Double.zero, -day7[dddLD + i]) + max(Double.zero, -day7[dddLJ + i]) + max(Double.zero, -day7[dddLQ + i]) + max(Double.zero, -day7[dddLU + i])
      // if MB > 1E-13 { print("Checksum error daily 1", i, j, MB); break }
      day7[dddMB + i] = MB
    }

    /// el cons for harm op during harm op period
    let dddMD = 31755
    // IF(OR(KS6=0,KD6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMD + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        (day5[dayFC + i]
          + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFD + i]
            + (day6[dayGZ + i] - day5[dayFD + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFC + i]
              + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let dddME = 32120
    // IF(OR(KS6=0,KD6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddME + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let dddMF = 32485
    // IF(OR(KS6=0,KD6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMF + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let dddMG = 32850
    // IF(OR(KS6=0,KD6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[dddMG + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        min(
          ((day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            + ((day5[dayFZ + i]
              + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFY + i]
                + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[ddKZ + i] - Overall_harmonious_min_perc)),
          (day5[dayFR + i]
            + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let dddMH = 33215
    // IF(OR(KS6=0,KD6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMH + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        (day5[dayFL + i]
          + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFM + i]
            + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFL + i]
              + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for harm op during harm op period
    let dddMN = 35405
    // IF(OR(KS6=0,KD6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMN + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        (day5[dayFF + i]
          + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFG + i]
            + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFF + i]
              + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let dddMO = 35770
    // IF(OR(KS6=0,KD6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddMO + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let dddMP = 36135
    // IF(OR(KS6=0,KD6=0),0,MH6*El_boiler_eff)
    for i in 0..<365 {
      day7[dddMP + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero, day7[dddMH + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let dddMQ = 36500
    // IF(OR(KS6=0,KD6=0),0,MAX(0,MO6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dddMQ + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        max(
          Double.zero,
          day7[dddMO + i]
            - ((day5[dayFV + i]
              + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayFW + i]
                + (day6[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i]
                  + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
                / Overall_harmonious_range
                * (day7[ddKZ + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let dddMR = 37595
    // IF(OR(KS6=0,KD6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMR + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFA + i] + (day6[dayGW + i] - day5[dayFA + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let dddMS = 37960
    // MP6+MQ6+MR6-MN6-MO6
    for i in 0..<365 {
      day7[dddMS + i] =
        day7[dddMP + i] + day7[dddMQ + i] + day7[dddMR + i] - day7[dddMN + i] - day7[dddMO + i]
    }

    /// el cons for el boiler op for night prep during harm op period
    let dddMI = 38325
    // MQ6/El_boiler_eff
    for i in 0..<365 { day7[dddMI + i] = day7[dddMQ + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let dddMJ = 38690
    // IF(OR(KS6=0,KD6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMJ + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayEY + i] + (day6[dayGU + i] - day5[dayEY + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let dddMK = 39055
    // IF(OR(KD6=0,KS6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddMK + i] = iff(
        or(day7[ddKI + i].isZero, day7[ddKZ + i].isZero), Double.zero,
        (day5[dayFI + i]
          + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFJ + i]
            + (day6[dayHF + i] - day5[dayFJ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFI + i]
              + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let dddML = 39420
    // IF(OR(KD6=0,KS6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc),MAX(0,-(MJ6+MK6-MD6-ME6-MF6-MG6-MH6-MI6))))
    for i in 0..<365 {
      day7[dddML + i] = iff(
      or(
     day7[ddKI + i].isZero, day7[ddKZ + i].isZero),0, min((day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j])) + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j])) - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range * (day7[ddKZ + i] - Overall_harmonious_min_perc),max(Double.zero, -(day7[dddMJ + i] + day7[dddMK + i] - day7[dddMD + i] - day7[dddME + i] - day7[dddMF + i] - day7[dddMG + i] - day7[dddMH + i] - day7[dddMI + i]))))
    }

//////////////////////////////////////////////////////////////////

    /// Balance of electricity during harm op period
    let dddMZ = 39785
    // MJ6+MK6+ML6-MD6-ME6-MF6-MG6-MH6-MI6
    for i in 0..<365 {
      day7[dddMZ + i] =
        day7[dddMJ + i] + day7[dddMK + i] + day7[dddML + i] - day7[dddMD + i] - day7[dddME + i]
        - day7[dddMF + i] - day7[dddMG + i] - day7[dddMH + i] - day7[dddMI + i]
    }

    
    /// el cons for harm op outside of harm op period
    let dddNA = 40150
    // IF(OR(KS6=0,KD6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNA + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let dddNB = 40515
    // IF(OR(KS6=0,KD6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNB + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFP + i] + (day6[dayHL + i] - day5[dayFP + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let dddNC = 40880
    // IF(OR(KS6=0,KD6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNC + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFN + i] + (day6[dayHJ + i] - day5[dayFN + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let dddND = 41245
    // MG6*BESS_chrg_eff
    for i in 0..<365 { day7[dddND + i] = day7[dddMG + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let dddNE = 41610
    // IF(OR(KS6=0,KD6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNE + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayEZ + i] + (day6[dayGV + i] - day5[dayEZ + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let dddNF = 41975
    // IF(OR(KS6=0,KD6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc),MAX(0,-(MW6+MX6-MT6-MU6-MV6))))
    for i in 0..<365 {
      day7[dddNF + i] = iff(
      or(
     day7[ddKZ + i].isZero, day7[ddKI + i].isZero),0, min(day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]),max(Double.zero, -(day7[dddND + i] + day7[dddNE + i] - day7[dddNA + i] - day7[dddNB + i] - day7[dddNC + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dddNG = 42340
    // MW6+MX6+MY6-MT6-MU6-MV6
    for i in 0..<365 {
      day7[dddNG + i] =
        day7[dddND + i] + day7[dddNE + i] + day7[dddNF + i] - day7[dddNA + i] - day7[dddNB + i] - day7[dddNC + i]
    }

    /// heat cons for harm op outside of harm op period
    let dddNH = 42705
    // IF(OR(KS6=0,KD6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNH + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let dddNI = 43070
    // IF(OR(KS6=0,KD6=0),0,MV6*El_boiler_eff)
    for i in 0..<365 {
      day7[dddNI + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero, day7[dddNC + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let dddNJ = 43435
    // IF(OR(KS6=0,KD6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dddNJ + i] = iff(
        or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
        day5[dayFB + i] + (day6[dayGX + i] - day5[dayFB + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    /// let dddND = 43800
    // NB6+NC6-NA6
    for i in 0..<365 { day7[dddND + i] = day7[dddNI + i] + day7[dddNJ + i] - day7[dddNH + i] }

    /// Pure Methanol prod with night priority and resp day op
    let dddNL = 44165
    // IF(MD6<=0,0,MD6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(MT6<=0,0,(MT6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dddNL + i] =
        iff(
          day7[dddMD + i] <= Double.zero, Double.zero,
          day7[dddMD + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day7[dddNA + i] <= Double.zero, Double.zero,
          (day7[dddNA + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// Grid export
    let dddNM = 44530
    // MIN(MM6,IF(OR(KS6=0,KD6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)))+MIN(MZ6,IF(OR(KS6=0,KD6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddNM + i] =
        min(
          day7[dddMZ + i],
          iff(
            or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
            (day5[dayGB + i]
              + (day6[dayHX + i] - day5[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayGC + i]
                + (day6[dayHY + i] - day5[dayGC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayGB + i]
                  + (day6[dayHX + i] - day5[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[ddKZ + i] - Overall_harmonious_min_perc)))
        + min(
          day7[dddNG + i],
          iff(
            or(day7[ddKZ + i].isZero, day7[ddKI + i].isZero), Double.zero,
            day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i])
              / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[ddKI + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let dddNN = 44895
    // MY6+ML6
    for i in 0..<365 { day7[dddNN + i] = day7[dddNF + i] + day7[dddML + i] }

    /// Outside harmonious operation period hours
    let dddNO = 45260
    // IF(KD6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddNO + i] = iff(
        day7[ddKI + i] <= Double.zero, Double.zero,
        (day1[dayC + i]
          + (day1[dayT + i] - day1[dayC + i]) / equiv_harmonious_range
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let dddNP = 45625
    // IF(KD6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddNP + i] = iff(
        day7[ddKI + i] <= Double.zero, Double.zero,
        (day1[dayD + i]
          + (day1[dayU + i] - day1[dayD + i]) / equiv_harmonious_range
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let dddNQ = 45990
    // IF(KD6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dddNQ + i] = iff(
        day7[ddKI + i] <= Double.zero, Double.zero,
        (day1[dayE + i]
          + (day1[dayV + i] - day1[dayE + i]) / equiv_harmonious_range
            * (day7[ddKI + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let dddNR = 46355
    // MAX(0,-MM6)+MAX(0,-MS6)+MAX(0,-MZ6)+MAX(0,-ND6)
    for i in 0..<365 {
      let NK = max(Double.zero, -day7[dddMZ + i]) + max(Double.zero, -day7[dddMS + i]) + max(Double.zero, -day7[dddNG + i]) + max(Double.zero, -day7[dddND + i])
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      day7[dddNR + i] = NK
    }
    return day7
  }
}


