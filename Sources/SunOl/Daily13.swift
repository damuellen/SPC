
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
    var day7 = [Double](repeating: Double.zero, count: 44_165)
    
    /// Surplus harm op period electricity after min harm op and min night op prep
    let dayIQ = 0 
    // FS6+GE6-$Z6-MIN(GH6,MAX(0,$AB6-FV6)/El_boiler_eff)-MIN(FY6,FR6/BESS_chrg_eff)
    for i in 0..<365 {
      day7[dayIQ + i] =
        day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i] - min(day5[dayGH + i], max(
          Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff) - min(day5[dayFY + i], day5[dayFR + i] / BESS_chrg_eff)
    }

    let equiv_harmonious_range = (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    /// Surplus harm op period electricity after min harm op and max night op prep
    let dayIR = 365
    // =HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MIN(ID6,MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff)-MIN(HU6,HN6/BESS_chrg_eff)
    for i in 0..<365 {
      day7[dayIR + i] =
        day6[dayHO + i] + day6[dayIA + i] - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
        - min(
          day6[dayHN + i],
          max(
            0,
            (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - day6[dayHR + i]) / El_boiler_eff) - min(day6[dayHU + i], day6[dayHN + i] / BESS_chrg_eff)
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let dayIS = 730 
    // FT6+GF6-Z6-MIN(GI6,MAX(0,$AB6-FW6)/El_boiler_eff)-MIN(FZ6,FR6/BESS_chrg_eff)
    for i in 0..<365 {
      day7[dayIS + i] =
        day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i] - min(day5[dayGI + i], max(
          Double.zero, day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff) - min(day5[dayFZ + i], day5[dayFR + i] / BESS_chrg_eff)
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let dayIT = 1095 
    // FV6+MIN(GH6,MAX(0,FS6+GE6-Z6-MIN(FY6,FR6/BESS_chrg_eff))*El_boiler_eff)-$AB6
    for i in 0..<365 {
      day7[dayIT + i] =
        day5[dayFV + i] + min(day1[dayGH + i], max(
          Double.zero, day5[dayFS + i] + day5[dayGE + i] - day1[dayZ + i] - min(day5[dayFY + i], day5[dayFR + i] / BESS_chrg_eff))
        * El_boiler_eff) - day1[dayAB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let dayIU = 1460 
    // =HR6+MIN(ID6,MAX(0,HO6+IA6-($Z6+($AA6-$Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-MIN(HU6,HN6/BESS_chrg_eff))*El_boiler_eff)-($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIU + i] =
        day6[dayHR + i]
        + min(
          day6[dayHN + i],
          max(
            0,
            day6[dayHO + i] + day6[dayIA + i]-(day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - min(day6[dayHU + i], day6[dayHN + i] / BESS_chrg_eff)) * El_boiler_eff)
        - (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }


    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let dayIV = 1825
    // FW6+MIN(GI6,MAX(0,FT6+GF6-Z6-MIN(FZ6,FR6/BESS_chrg_eff))*El_boiler_eff)-$AB6
    for i in 0..<365 { 
      day7[dayIV + i] =
        day5[dayFW + i] + min(day5[dayGI + i], max(
          Double.zero, day5[dayFT + i] + day5[dayGF + i] - day1[dayZ + i] - min(day5[dayFZ + i], day5[dayFR + i] / BESS_chrg_eff))
        * El_boiler_eff) - day1[dayAB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let dayIW = 2190
    // GH6-MAX(0,$AB6-FV6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayIW + i] = day1[dayGH + i] - max(Double.zero, day1[dayAB + i] - day5[dayFV + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep
    let dayIX = 2555
    // ID6-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 { 
      day7[dayIX + i] =
        day6[dayID + i]
        - max(Double.zero, (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
          - day6[dayHR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let dayIY = 2920
    // =GI6-MAX(0,$AB6-FW6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayIY + i] = day5[dayGI + i] - max(0,(day1[dayAB + i] - day5[dayFW + i]) / El_boiler_eff)
    }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let dayIZ = 3285
    /// Surplus BESS chrg cap after min harm op and max night op prep
    let dayJA = 3650
    /// Surplus BESS chrg cap after max harm op and min night op prep
    let dayJB = 4015
    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let dayJC = 4380
    for i in 0..<365 {
      // FY6-FR6/BESS_chrg_eff
      day7[dayIZ + i] = day5[dayFY + i] - day5[dayFR + i] / BESS_chrg_eff
      // HU6-HN6/BESS_chrg_eff
      day7[dayJA + i] = day6[dayHU + i] - day6[dayHN + i] / BESS_chrg_eff
      // FZ6-FR6/BESS_chrg_eff
      day7[dayJB + i] = day5[dayFZ + i] - day5[dayFR + i] / BESS_chrg_eff
      // GK6-AD6
      day7[dayJC + i] = day5[dayGK + i] - day1[dayAD + i]
    }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let dayJD = 4745
    // IG6-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJD + i] =
        day6[dayIG + i]
        - (day1[dayAD + i]
          + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let dayJE = 5110
    // GL6-AD6
    for i in 0..<365 { day7[dayJE + i] = day7[dayGL + i] - day1[dayAD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let dayJF = 5475
    // GN6-AF6
    for i in 0..<365 { day7[dayJF + i] = day5[dayGN + i] - day1[dayAF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let dayJG = 5840
    // IJ6-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJG + i] =
        day6[dayIJ + i]
        - (day1[dayAF + i]
          + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let dayJH = 6205
    // GO6-AF6
    for i in 0..<365 { day7[dayJH + i] = day5[dayGO + i] - day1[dayAF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let dayJI = 6570
    // GQ6-AH6
    for i in 0..<365 { day7[dayJI + i] = day5[dayGQ + i] - day1[dayAH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let dayJJ = 6935
    // IM6-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJJ + i] =
        day6[dayIM + i]
        - (day1[dayAH + i]
          + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
            * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let dayJK = 7300
    // GR6-AH6
    for i in 0..<365 { day7[dayJK + i] = day7[dayGR + i] - day1[dayAH + i] }

    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let dayJM = 7665
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IS6),1),IFERROR(IT6/(IT6-IV6),1),IFERROR(IW6/(IW6-IY6),1),IFERROR(IZ6/(IZ6-JB6),1),IFERROR(JC6/(JC6-JE6),1),IFERROR(JF6/(JF6-JH6),1),IFERROR(JI6/(JI6-JK6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayJM + i] = iff(
        or(
          day6[dayIQ + i] < Double.zero, day7[dayIT + i] < Double.zero, day7[dayIW + i] < Double.zero, day7[dayIZ + i] < Double.zero,
          day7[dayJC + i] < Double.zero, day7[dayJF + i] < Double.zero, day7[dayJI + i] < 0), Double.zero,
        min(
          1, ifFinite(day6[dayIQ + i] / max(Double.zero, (day6[dayIQ + i] - day7[dayIS + i])), 1),
          ifFinite(day7[dayIT + i] / max(Double.zero, (day7[dayIT + i] - day7[dayIV + i])), 1),
          ifFinite(day7[dayIW + i] / max(Double.zero, (day7[dayIW + i] - day7[dayIY + i])), 1),
          ifFinite(day7[dayIZ + i] / max(Double.zero, (day7[dayIZ + i] - day7[dayJB + i])), 1),
          ifFinite(day7[dayJC + i] / max(Double.zero, (day7[dayJC + i] - day7[dayJE + i])), 1),
          ifFinite(day7[dayJF + i] / max(Double.zero, (day7[dayJF + i] - day7[dayJH + i])), 1),
          ifFinite(day7[dayJI + i] / max(Double.zero, (day7[dayJI + i] - day7[dayJK + i])), 1))
          * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let dayJN = 8030
    // IF(JM6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-MAX(0,AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayJN + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day5[dayFS + i]
            + (day5[dayFT + i] - day5[dayFS + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            + (day5[dayGE + i]
              + (day5[dayGF + i] - day5[dayGE + i]) / Overall_harmonious_range
                * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - day1[dayZ + i] - max(
              Double.zero,
              day1[dayAB + i]
                - (day5[dayFV + i]
                  + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
                    * (day7[dayJM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - day5[dayFR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let dayJO = 8395
    // IF(JM6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayJO + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day6[dayHO + i]
            + (day6[dayHP + i] - day6[dayHO + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            + (day6[dayIA + i]
              + (day6[dayIB + i] - day6[dayIA + i]) / Overall_harmonious_range
                * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - (day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
                - (day6[dayHR + i]
                  + (day7[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
                    * (day7[dayJM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - day6[dayHN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let dayJP = 8760
    // IF(JM6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6,5))
    for i in 0..<365 {
      day7[dayJP + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day5[dayFV + i]
            + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            + max(
              Double.zero,
              (day5[dayFS + i]
                + (day5[dayFT + i] - day5[dayFS + i]) / Overall_harmonious_range
                  * (day7[dayJM + i] - Overall_harmonious_min_perc))
                + (day5[dayGE + i]
                  + (day5[dayGF + i] - day5[dayGE + i]) / Overall_harmonious_range
                    * (day7[dayJM + i] - Overall_harmonious_min_perc))
                - day1[dayZ + i] - day5[dayFR + i] / BESS_chrg_eff) * El_boiler_eff - day1[dayAB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let dayJQ = 9125
    // IF(JM6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayJQ + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day6[dayHR + i]
            + (day7[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            + max(
              Double.zero,
              (day6[dayHO + i]
                + (day6[dayHP + i] - day6[dayHO + i]) / Overall_harmonious_range
                  * (day7[dayJM + i] - Overall_harmonious_min_perc))
                + (day6[dayIA + i]
                  + (day6[dayIB + i] - day6[dayIA + i]) / Overall_harmonious_range
                    * (day7[dayJM + i] - Overall_harmonious_min_perc))
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
    let dayJR = 9490
    // =IF(JM6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-MAX(0,$AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayJR + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day1[dayGH + i]
            + (day5[dayGI + i] - day1[dayGH + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - max(Double.zero, day1[dayAB + i]
              - (day5[dayFV + i]
                + (day5[dayFW + i] - day5[dayFV + i]) / Overall_harmonious_range
                  * (day7[dayJM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let dayJS = 9855
    // =IF(JM6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*($AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayJS + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day6[dayID + i]
            + (day6[dayIE + i] - day6[dayID + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j]))
              - (day6[dayHR + i]
                + (day7[dayHS + i] - day6[dayHR + i]) / Overall_harmonious_range
                  * (day7[dayJM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let dayJT = 10220
    // IF(JM6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayJT + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day5[dayFY + i]
            + (day5[dayFZ + i] - day5[dayFY + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - day5[dayFR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let dayJU = 10585
    // IF(JM6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayJU + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day6[dayHU + i]
            + (day6[dayHV + i] - day6[dayHU + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - day6[dayHN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let dayJV = 10950
    // IF(JM6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AD6,5))
    for i in 0..<365 {
      day7[dayJV + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day5[dayGK + i]
            + (day7[dayGL + i] - day5[dayGK + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc))
            - day1[dayAD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let dayJW = 11315
    // IF(JM6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayJW + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          day5[dayGK + i] + (day7[dayGL + i] - day5[dayGK + i])
            / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc)
            - (day1[dayAD + i]
              + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let dayJX = 11680
    // IF(JM6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AF6,5))
    for i in 0..<365 {
      day7[dayJX + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day5[dayGN + i]
            + (day5[dayGO + i] - day5[dayGN + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc)) - day1[dayAF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let dayJY = 12045
    // IF(JM6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayJY + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          day5[dayGN + i] + (day5[dayGO + i] - day5[dayGN + i])
            / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc)
            - (day1[dayAF + i]
              + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let dayJZ = 12410
    // IF(JM6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AH6,5))
    for i in 0..<365 {
      day7[dayJZ + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          (day7[dayGQ + i]
            + (day7[dayGR + i] - day7[dayGQ + i]) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc)) - day1[dayAH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let dayKA = 12775
    // IF(JM6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKA + i] = iff(
        day7[dayJM + i].isZero, Double.zero,
        round(
          day7[dayGQ + i] + (day7[dayGR + i] - day7[dayGQ + i])
            / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc)
            - (day1[dayAH + i]
              + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day1[dayAM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt night prep during day prio operation
    let dayKB = 13140
    // IF(OR(JM6=0,JN6<0,JP6<0,JR6<0,JT6<0,JV6<0,JX6<0,JZ6<0),0,MIN(1,IFERROR(JN6/(JN6-JO6),1),IFERROR(JP6/(JP6-JQ6),1),IFERROR(JR6/(JR6-JS6),1),IFERROR(JT6/(JT6-JU6),1),IFERROR(JV6/(JV6-JW6),1),IFERROR(JX6/(JX6-JY6),1),IFERROR(JZ6/(JZ6-KA6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayKB + i] = iff(
        or(
          day7[dayJM + i].isZero, day7[dayJN + i] < Double.zero, day7[dayJP + i] < Double.zero, day7[dayJR + i] < Double.zero,
          day7[dayJT + i] < Double.zero, day7[dayJV + i] < Double.zero, day7[dayJX + i] < Double.zero, day7[dayJZ + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dayJN + i] / max(Double.zero, (day7[dayJN + i] - day7[dayJO + i])), 1),
          ifFinite(day7[dayJP + i] / max(Double.zero, (day7[dayJP + i] - day7[dayJQ + i])), 1),
          ifFinite(day7[dayJR + i] / max(Double.zero, (day7[dayJR + i] - day7[dayJS + i])), 1),
          ifFinite(day7[dayJT + i] / max(Double.zero, (day7[dayJT + i] - day7[dayJU + i])), 1),
          ifFinite(day7[dayJV + i] / max(Double.zero, (day7[dayJV + i] - day7[dayJW + i])), 1),
          ifFinite(day7[dayJX + i] / max(Double.zero, (day7[dayJX + i] - day7[dayJY + i])), 1),
          ifFinite(day7[dayJZ + i] / max(Double.zero, (day7[dayJZ + i] - day7[dayKA + i])), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let dayKD = 13505
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IR6),1),IFERROR(IT6/(IT6-IU6),1),IFERROR(IW6/(IW6-IX6),1),IFERROR(IZ6/(IZ6-JA6),1),IFERROR(JC6/(JC6-JD6),1),IFERROR(JF6/(JF6-JG6),1),IFERROR(JI6/(JI6-JJ6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayKD + i] = iff(
        or(
          day6[dayIQ + i] < Double.zero, day6[dayIT + i] < Double.zero, day7[dayIW + i] < Double.zero, day6[dayIZ + i] < Double.zero,
          day7[dayJC + i] < Double.zero, day7[dayJF + i] < Double.zero, day7[dayJI + i] < 0), Double.zero,
        min(
          1, ifFinite(day6[dayIQ + i] / max(Double.zero, (day6[dayIQ + i] - day6[dayIR + i])), 1),
          ifFinite(day6[dayIT + i] / max(Double.zero, (day6[dayIT + i] - day6[dayIU + i])), 1),
          ifFinite(day7[dayIW + i] / max(Double.zero, (day7[dayIW + i] - day6[dayIX + i])), 1),
          ifFinite(day6[dayIZ + i] / max(Double.zero, (day6[dayIZ + i] - day7[dayJA + i])), 1),
          ifFinite(day7[dayJC + i] / max(Double.zero, (day7[dayJC + i] - day7[dayJD + i])), 1),
          ifFinite(day7[dayJF + i] / max(Double.zero, (day7[dayJF + i] - day7[dayJG + i])), 1),
          ifFinite(day7[dayJI + i] / max(Double.zero, (day7[dayJI + i] - day7[dayJJ + i])), 1))
          * (day1[dayAM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let dayKE = 13870
    // IF(KD6=0,0,ROUND((FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayKE + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFS + i]
            + (day6[dayHO + i] - day5[dayFS + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            + (day5[dayGE + i]
              + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayZ + i]
              + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i] + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (day5[dayFR + i]
              + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let dayKF = 14235
    // IF(KD6=0,0,ROUND((FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayKF + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFT + i]
            + (day6[dayHP + i] - day5[dayFT + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            + (day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - max(
              Double.zero,
              (day1[dayAB + i]
                + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFW + i]
                  + (day7[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (day5[dayFR + i]
              + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let dayKG = 14600
    // IF(KD6=0,0,ROUND((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKG + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFV + i]
            + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              Double.zero,
              (day5[dayFS + i]
                + (day6[dayHO + i] - day5[dayFS + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                + (day5[dayGE + i]
                  + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayZ + i]
                  + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - ((day5[dayFR + i]
                  + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let dayKH = 14965
    // IF(KD6=0,0,ROUND((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKH + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFW + i]
            + (day7[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              Double.zero,
              (day5[dayFT + i]
                + (day6[dayHP + i] - day5[dayFT + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                + (day5[dayGF + i]
                  + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayZ + i]
                  + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - ((day5[dayFR + i]
                  + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let dayKI = 15330
    // IF(KD6=0,0,ROUND((GH6+(ID6-GH6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayKI + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day1[dayGH + i]
            + (day6[dayID + i] - day1[dayGH + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFV + i]
                + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let dayKJ = 15695
    // =IF(KD6=0,0,ROUND((GI6+(IE6-GI6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,($AB6+($AC6-$AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/($AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayKJ + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayGI + i]
            + (day6[dayIE + i] - day5[dayGI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - max(Double.zero, (day1[dayAB + i]
              + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFW + i] + (day7[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let dayKK = 16060
    // IF(KD6=0,0,ROUND((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayKK + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let dayKL = 16425
    // IF(KD6=0,0,ROUND((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      day7[dayKL + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayFZ + i]
            + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFR + i] + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let dayKM = 16790
    // IF(KD6=0,0,ROUND((GK6+(IG6-GK6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKM + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day7[dayGK + i]
            + (day6[dayIG + i] - day7[dayGK + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let dayKN = 17155
    // IF(KD6=0,0,ROUND((GL6+(IH6-GL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKN + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayGL + i]
            + (day6[dayIH + i] - day5[dayGL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAD + i] + (day1[dayAE + i] - day1[dayAD + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let dayKO = 17520
    // IF(KD6=0,0,ROUND((GN6+(IJ6-GN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKO + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayGN + i]
            + (day6[dayIJ + i] - day5[dayGN + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let dayKP = 17885
    // IF(KD6=0,0,ROUND((GO6+(IK6-GO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKP + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day5[dayGO + i]
            + (day6[dayIK + i] - day5[dayGO + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAF + i] + (day1[dayAG + i] - day1[dayAF + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let dayKQ = 18250
    // IF(KD6=0,0,ROUND((GQ6+(IM6-GQ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKQ + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day7[dayGQ + i]
            + (day6[dayIM + i] - day7[dayGQ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let dayKR = 18615
    // IF(KD6=0,0,ROUND((GR6+(IN6-GR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayKR + i] = iff(
        day7[dayKD + i].isZero, Double.zero,
        round(
          (day7[dayGR + i]
            + (day6[dayIN + i] - day7[dayGR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day1[dayAH + i] + (day1[dayAI + i] - day1[dayAH + i]) / equiv_harmonious_range
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let dayKS = 18980
    // IF(KD6<=0,0,MIN(1,IFERROR(KE6/(KE6-KF6),1),IFERROR(KG6/(KG6-KH6),1),IFERROR(KI6/(KI6-KJ6),1),IFERROR(KK6/(KK6-KL6),1),IFERROR(KM6/(KM6-KN6),1),IFERROR(KO6/(KO6-KP6),1),IFERROR(KQ6/(KQ6-KR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayKS + i] = iff(
        day7[dayKD + i] <= Double.zero, Double.zero,
        min(
          1, ifFinite(day7[dayKE + i] / max(Double.zero, (day7[dayKE + i] - day7[dayKF + i])), 1),
          ifFinite(day7[dayKG + i] / max(Double.zero, (day7[dayKG + i] - day7[dayKH + i])), 1),
          ifFinite(day7[dayKI + i] / max(Double.zero, (day7[dayKI + i] - day7[dayKJ + i])), 1),
          ifFinite(day7[dayKK + i] / max(Double.zero, (day7[dayKK + i] - day7[dayKL + i])), 1),
          ifFinite(day7[dayKM + i] / max(Double.zero, (day7[dayKM + i] - day7[dayKN + i])), 1),
          ifFinite(day7[dayKO + i] / max(Double.zero, (day7[dayKO + i] - day7[dayKP + i])), 1),
          ifFinite(day7[dayKQ + i] / max(Double.zero, (day7[dayKQ + i] - day7[dayKR + i])), 1))
          * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period
    let dayKU = 19345
    // IF(OR(JM6=0,KB6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayKU + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day5[dayFC + i]
          + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFD + i]
            + (day6[dayGZ + i] - day5[dayFD + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFC + i]
              + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let dayKV = 19710
    // IF(OR(JM6=0,KB6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayKV + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let dayKW = 20075
    // IF(OR(JM6=0,KB6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayKW + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let dayKX = 20440
    // IF(OR(JM6=0,KB6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[dayKX + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        min(
          ((day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            + ((day5[dayFZ + i]
              + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFY + i]
                + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc)),
          (day5[dayFR + i]
            + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let dayKY = 20805
    // IF(OR(JM6=0,KB6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayKY + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day5[dayFL + i]
          + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFM + i]
            + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFL + i]
              + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for harm op during harm op period
    let dayLE = 22995
    // IF(OR(JM6=0,KB6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLE + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day5[dayFF + i]
          + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFG + i]
            + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFF + i]
              + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let dayLF = 23360
    // IF(OR(JM6=0,KB6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayLF + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day1[dayAB + i] + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let dayLG = 23725
    // IF(OR(JM6=0,KB6=0),0,KY6*El_boiler_eff)
    for i in 0..<365 {
      day7[dayLG + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero, day7[dayKY + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let dayLH = 24090
    // IF(OR(JM6=0,KB6=0),0,MAX(0,LF6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dayLH + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        max(
          Double.zero,
          day7[dayLF + i]
            - ((day5[dayFV + i]
              + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayFW + i]
                + (day7[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i]
                  + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
                / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let dayLI = 24455
    // IF(OR(JM6=0,KB6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLI + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFA + i] + (day6[dayGW + i] - day5[dayFA + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let dayLJ = 24820
    // LG6+LH6+LI6-LE6-LF6
    for i in 0..<365 {
      day7[dayLJ + i] =
        day7[dayLG + i] + day7[dayLH + i] + day7[dayLI + i] - day7[dayLE + i] - day7[dayLF + i]
    }

    /// el cons for el boiler op for night prep during harm op period
    let dayKZ = 21170
    // LH6/El_boiler_eff
    for i in 0..<365 { day7[dayKZ + i] = day7[dayLH + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let dayLA = 21535
    // IF(OR(JM6=0,KB6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      let a: Double = day5[dayEY + i] + (day6[dayGU + i] - day5[dayEY + i])
      let b: Double = (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j])
      day7[dayLA + i] = iff(or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero, a / b)
    }

    /// Grid import for harm op during harm op period
    let dayLB = 21900
    // IF(OR(JM6=0,KB6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLB + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        (day5[dayFI + i]
          + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFJ + i]
            + (day6[dayHF + i] - day5[dayFJ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFI + i]
              + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let dayLC = 22265
    // IF(OR(JM6=0,KB6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc),MAX(0,-(LA6+LB6-KU6-KV6-KW6-KX6-KY6-KZ6))))
    for i in 0..<365 {
      day7[dayLC + i] = iff(
      or(
     day7[dayJM + i].isZero,day7[dayKB + i].isZero),0, min((day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j])) + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j])) - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range * (day7[dayJM + i] - Overall_harmonious_min_perc),max(Double.zero, -(day7[dayLA + i] + day7[dayLB + i] - day7[dayKU + i] - day7[dayKV + i] - day7[dayKW + i] - day7[dayKX + i] - day7[dayKY + i] - day7[dayKZ + i]))))
    }

    /// Balance of electricity during harm op period
    let dayLD = 22630
    // LA6+LB6+LC6-KU6-KV6-KW6-KX6-KY6-KZ6
    for i in 0..<365 {
      day7[dayLD + i] =
        day7[dayLA + i] + day7[dayLB + i] + day7[dayLC + i] - day7[dayKU + i] - day7[dayKV + i] - day7[dayKW + i] - day7[dayKX + i] - day7[dayKY + i] - day7[dayKZ + i]
    }  

    /// el cons for harm op outside of harm op period
    let dayLK = 25185
    // IF(OR(JM6=0,KB6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLK + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let dayLL = 25550
    // IF(OR(JM6=0,KB6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLL + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFP + i] + (day6[dayHL + i] - day5[dayFP + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let dayLM = 25915
    // IF(OR(JM6=0,KB6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLM + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFN + i] + (day6[dayHJ + i] - day5[dayFN + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let dayLN = 26280
    // KX6*BESS_chrg_eff
    for i in 0..<365 { day7[dayLN + i] = day7[dayKX + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let dayLO = 26645
    // IF(OR(JM6=0,KB6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLO + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day1[dayEZ + i] + (day6[dayGV + i] - day1[dayEZ + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let dayLP = 27010
    // IF(OR(JM6=0,KB6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc),MAX(0,-(LN6+LO6-LK6-LL6-LM6))))
    for i in 0..<365 {
      day7[dayLP + i] = iff(
      or(
     day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero, min(day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]),max(Double.zero, -(day7[dayLN + i] + day7[dayLO + i] - day7[dayLK + i] - day7[dayLL + i] - day7[dayLM + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayLQ = 27375
    // LN6+LO6+LP6-LK6-LL6-LM6
    for i in 0..<365 {
      day7[dayLQ + i] =
        day7[dayLN + i] + day7[dayLO + i] + day7[dayLP + i] - day7[dayLK + i] - day7[dayLL + i] - day7[dayLM + i]
    }

    /// heat cons for harm op outside of harm op period
    let dayLR = 27740
    // IF(OR(JM6=0,KB6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLR + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let dayLS = 28105
    // IF(OR(JM6=0,KB6=0),0,LM6*El_boiler_eff)
    for i in 0..<365 {
      day7[dayLS + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero, day7[dayLM + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let dayLT = 28470
    // IF(OR(JM6=0,KB6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayLT + i] = iff(
        or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
        day5[dayFB + i] + (day6[dayGX + i] - day5[dayFB + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let dayLU = 28835
    // LS6+LT6-LR6
    for i in 0..<365 { day7[dayLU + i] = day7[dayLS + i] + day7[dayLT + i] - day7[dayLR + i] }

    /// Pure Methanol prod with day priority and resp night op
    let dayLV = 29200
    // IF(KU6<=0,0,KU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(LK6<=0,0,(LK6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dayLV + i] =
        iff(
          day7[dayKU + i] <= Double.zero, Double.zero,
          day7[dayKU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day7[dayLK + i] <= Double.zero, Double.zero,
          (day7[dayLK + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let dayLW = 29565
    // MIN(LD6,IF(OR(JM6=0,KB6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))+MIN(LQ6,IF(OR(JM6=0,KB6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayLW + i] =
        min(
          day7[dayLD + i],
          iff(
            or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
            (day1[dayGB + i]
              + (day6[dayHX + i] - day1[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayGC + i]
                + (day6[dayHY + i] - day5[dayGC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayGB + i]
                  + (day6[dayHX + i] - day1[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[dayJM + i] - Overall_harmonious_min_perc)))
        + min(
          day7[dayLQ + i],
          iff(
            or(day7[dayJM + i].isZero, day7[dayKB + i].isZero), Double.zero,
            day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i])
              / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKB + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let dayLX = 29930
    // LP6+LC6
    for i in 0..<365 { day7[dayLX + i] = day7[dayLP + i] + day7[dayLC + i] }

    /// Outside harmonious operation period hours
    let dayLY = 30295
    // IF(KB6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayLY + i] = iff(
        day7[dayKB + i] <= Double.zero, Double.zero,
        (day1[dayC + i] + (day1[dayT + i] - day1[dayC + i]) / equiv_harmonious_range
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let dayLZ = 30660
    // IF(KB6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayLZ + i] = iff(
        day7[dayKB + i] <= Double.zero, Double.zero,
        (day1[dayD + i] + (day1[dayU + i] - day1[dayD + i]) / equiv_harmonious_range
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let dayMA = 31025
    // IF(KB6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayMA + i] = iff(
        day7[dayKB + i] <= Double.zero, Double.zero,
        (day1[dayE + i] + (day1[dayV + i] - day1[dayE + i]) / equiv_harmonious_range
            * (day7[dayKB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let dayMB = 31390
    // MAX(0,-LD6)+MAX(0,-LJ6)+MAX(0,-LQ6)+MAX(0,-LU6)
    for i in 0..<365 {
      let MB = max(Double.zero, -day7[dayLD + i]) + max(Double.zero, -day7[dayLJ + i]) + max(Double.zero, -day7[dayLQ + i]) + max(Double.zero, -day7[dayLU + i])
      // if MB > 1E-13 { print("Checksum error daily 1", i, j, MB); break }
      day7[dayMB + i] = MB
    }

    /// el cons for harm op during harm op period
    let dayMD = 31755
    // IF(OR(KS6=0,KD6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMD + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        (day5[dayFC + i]
          + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFD + i]
            + (day6[dayGZ + i] - day5[dayFD + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFC + i]
              + (day6[dayGY + i] - day5[dayFC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayKS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let dayME = 32120
    // IF(OR(KS6=0,KD6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayME + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        (day1[dayZ + i] + (day1[dayAA + i] - day1[dayZ + i]) / equiv_harmonious_range
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let dayMF = 32485
    // IF(OR(KS6=0,KD6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMF + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFO + i] + (day6[dayHK + i] - day5[dayFO + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let dayMG = 32850
    // IF(OR(KS6=0,KD6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      day7[dayMG + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        min(
          ((day5[dayFY + i]
            + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            + ((day5[dayFZ + i]
              + (day6[dayHV + i] - day5[dayFZ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              - (day5[dayFY + i]
                + (day6[dayHU + i] - day5[dayFY + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[dayKS + i] - Overall_harmonious_min_perc)),
          (day5[dayFR + i]
            + (day6[dayHN + i] - day5[dayFR + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j])) / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let dayMH = 33215
    // IF(OR(KS6=0,KD6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMH + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        (day5[dayFL + i]
          + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFM + i]
            + (day6[dayHI + i] - day5[dayFM + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFL + i]
              + (day6[dayHH + i] - day5[dayFL + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayKS + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for harm op during harm op period
    let dayMN = 35405
    // IF(OR(KS6=0,KD6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMN + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        (day5[dayFF + i]
          + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFG + i]
            + (day6[dayHC + i] - day5[dayFG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFF + i]
              + (day6[dayHB + i] - day5[dayFF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayKS + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let dayMO = 35770
    // IF(OR(KS6=0,KD6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayMO + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        (day1[dayAB + i]
          + (day1[dayAC + i] - day1[dayAB + i]) / equiv_harmonious_range
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let dayMP = 36135
    // IF(OR(KS6=0,KD6=0),0,MH6*El_boiler_eff)
    for i in 0..<365 {
      day7[dayMP + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero, day7[dayMH + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let dayMQ = 36500
    // IF(OR(KS6=0,KD6=0),0,MAX(0,MO6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dayMQ + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        max(
          Double.zero,
          day7[dayMO + i]
            - ((day5[dayFV + i]
              + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayFW + i]
                + (day7[dayHS + i] - day5[dayFW + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day5[dayFV + i]
                  + (day6[dayHR + i] - day5[dayFV + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
                / Overall_harmonious_range
                * (day7[dayKS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let dayMR = 36865
    // IF(OR(KS6=0,KD6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMR + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFA + i] + (day6[dayGW + i] - day5[dayFA + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let dayMS = 37230
    // MP6+MQ6+MR6-MN6-MO6
    for i in 0..<365 {
      day7[dayMS + i] =
        day7[dayMP + i] + day7[dayMQ + i] + day7[dayMR + i] - day7[dayMN + i] - day7[dayMO + i]
    }

    /// el cons for el boiler op for night prep during harm op period
    let dayMI = 33580
    // MQ6/El_boiler_eff
    for i in 0..<365 { day7[dayMI + i] = day7[dayMQ + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let dayMJ = 33945
    // IF(OR(KS6=0,KD6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMJ + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayEY + i] + (day6[dayGU + i] - day5[dayEY + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let dayMK = 34310
    // IF(OR(KD6=0,KS6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMK + i] = iff(
        or(day7[dayKD + i].isZero, day7[dayKS + i].isZero), Double.zero,
        (day5[dayFI + i]
          + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
          + ((day5[dayFJ + i]
            + (day6[dayHF + i] - day5[dayFJ + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
              * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
            - (day5[dayFI + i]
              + (day6[dayHE + i] - day5[dayFI + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
          / Overall_harmonious_range * (day7[dayKS + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let dayML = 34675
    // IF(OR(KD6=0,KS6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc),MAX(0,-(MJ6+MK6-MD6-ME6-MF6-MG6-MH6-MI6))))
    for i in 0..<365 {
      day7[dayML + i] = iff(
      or(
     day7[dayKD + i].isZero, day7[dayKS + i].isZero),0, min((day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j])) + ((day5[dayGF + i] + (day6[dayIB + i] - day5[dayGF + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j])) - (day5[dayGE + i] + (day6[dayIA + i] - day5[dayGE + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))) / Overall_harmonious_range * (day7[dayKS + i] - Overall_harmonious_min_perc),max(Double.zero, -(day7[dayMJ + i] + day7[dayMK + i] - day7[dayMD + i] - day7[dayME + i] - day7[dayMF + i] - day7[dayMG + i] - day7[dayMH + i] - day7[dayMI + i]))))
    }

    /// Balance of electricity during harm op period
    let dayMM = 35040
    // MJ6+MK6+ML6-MD6-ME6-MF6-MG6-MH6-MI6
    for i in 0..<365 {
      day7[dayMM + i] =
        day7[dayMJ + i] + day7[dayMK + i] + day7[dayML + i] - day7[dayMD + i] - day7[dayME + i]
        - day7[dayMF + i] - day7[dayMG + i] - day7[dayMH + i] - day7[dayMI + i]
    }

    
    /// el cons for harm op outside of harm op period
    let dayMT = 37595
    // IF(OR(KS6=0,KD6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMT + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFE + i] + (day6[dayHA + i] - day5[dayFE + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let dayMU = 37960
    // IF(OR(KS6=0,KD6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMU + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFP + i] + (day6[dayHL + i] - day5[dayFP + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let dayMV = 38325
    // IF(OR(KS6=0,KD6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMV + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFN + i] + (day6[dayHJ + i] - day5[dayFN + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let dayMW = 38690
    // MG6*BESS_chrg_eff
    for i in 0..<365 { day7[dayMW + i] = day7[dayMG + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let dayMX = 39055
    // IF(OR(KS6=0,KD6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayMX + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day1[dayEZ + i] + (day6[dayGV + i] - day1[dayEZ + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let dayMY = 39420
    // IF(OR(KS6=0,KD6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc),MAX(0,-(MW6+MX6-MT6-MU6-MV6))))
    for i in 0..<365 {
      day7[dayMY + i] = iff(
      or(
     day7[dayKS + i].isZero, day7[dayKD + i].isZero),0, min(day5[dayGG + i] + (day6[dayIC + i] - day5[dayGG + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]),max(Double.zero, -(day7[dayMW + i] + day7[dayMX + i] - day7[dayMT + i] - day7[dayMU + i] - day7[dayMV + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayMZ = 39785
    // MW6+MX6+MY6-MT6-MU6-MV6
    for i in 0..<365 {
      day7[dayMZ + i] =
        day7[dayMW + i] + day7[dayMX + i] + day7[dayMY + i] - day7[dayMT + i] - day7[dayMU + i] - day7[dayMV + i]
    }

    /// heat cons for harm op outside of harm op period
    let dayNA = 40150
    // IF(OR(KS6=0,KD6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayNA + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFH + i] + (day6[dayHD + i] - day5[dayFH + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let dayNB = 40515
    // IF(OR(KS6=0,KD6=0),0,MV6*El_boiler_eff)
    for i in 0..<365 {
      day7[dayNB + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero, day7[dayMV + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let dayNC = 40880
    // IF(OR(KS6=0,KD6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayNC + i] = iff(
        or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
        day5[dayFB + i] + (day6[dayGX + i] - day5[dayFB + i])
          / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let dayND = 41245
    // NB6+NC6-NA6
    for i in 0..<365 { day7[dayND + i] = day7[dayNB + i] + day7[dayNC + i] - day7[dayNA + i] }

    /// Pure Methanol prod with night priority and resp day op
    let dayNE = 41610
    // IF(MD6<=0,0,MD6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(MT6<=0,0,(MT6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      day7[dayNE + i] =
        iff(
          day7[dayMD + i] <= Double.zero, Double.zero,
          day7[dayMD + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          day7[dayMT + i] <= Double.zero, Double.zero,
          (day7[dayMT + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// Grid export
    let dayNF = 41975
    // MIN(MM6,IF(OR(KS6=0,KD6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)))+MIN(MZ6,IF(OR(KS6=0,KD6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayNF + i] =
        min(
          day7[dayMM + i],
          iff(
            or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
            (day1[dayGB + i]
              + (day6[dayHX + i] - day1[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
              + ((day5[dayGC + i]
                + (day6[dayHY + i] - day5[dayGC + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                  * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
                - (day1[dayGB + i]
                  + (day6[dayHX + i] - day1[dayGB + i]) / (day1[dayAM + i] - equiv_harmonious_min_perc[j])
                    * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
              / Overall_harmonious_range
              * (day7[dayKS + i] - Overall_harmonious_min_perc)))
        + min(
          day7[dayMZ + i],
          iff(
            or(day7[dayKS + i].isZero, day7[dayKD + i].isZero), Double.zero,
            day5[dayGD + i] + (day6[dayHZ + i] - day5[dayGD + i])
              / (day1[dayAM + i] - equiv_harmonious_min_perc[j]) * (day7[dayKD + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let dayNG = 42340
    // MY6+ML6
    for i in 0..<365 { day7[dayNG + i] = day7[dayMY + i] + day7[dayML + i] }

    /// Outside harmonious operation period hours
    let dayNH = 42705
    // IF(KD6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayNH + i] = iff(
        day7[dayKD + i] <= Double.zero, Double.zero,
        (day1[dayC + i]
          + (day1[dayT + i] - day1[dayC + i]) / equiv_harmonious_range
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let dayNI = 43070
    // IF(KD6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayNI + i] = iff(
        day7[dayKD + i] <= Double.zero, Double.zero,
        (day1[dayD + i]
          + (day1[dayU + i] - day1[dayD + i]) / equiv_harmonious_range
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let dayNJ = 43435
    // IF(KD6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayNJ + i] = iff(
        day7[dayKD + i] <= Double.zero, Double.zero,
        (day1[dayE + i]
          + (day1[dayV + i] - day1[dayE + i]) / equiv_harmonious_range
            * (day7[dayKD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let dayNK = 43800
    // MAX(0,-MM6)+MAX(0,-MS6)+MAX(0,-MZ6)+MAX(0,-ND6)
    for i in 0..<365 {
      let NK = max(Double.zero, -day7[dayMM + i]) + max(Double.zero, -day7[dayMS + i]) + max(Double.zero, -day7[dayMZ + i]) + max(Double.zero, -day7[dayND + i])
      // if NK > 1E-13 { print("Checksum error daily 1", i, j, NK); break }
      day7[dayNK + i] = NK
    }
    return day7
  }
}
