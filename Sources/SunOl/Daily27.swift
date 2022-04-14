extension TunOl {
  func day27(_ day7: inout [Double], case j: Int, day0: [Double], day1: [Double], day6: [Double]) {
    let dayB = 365
    let dayC = 730
    let dayE = 0
    let dayF = 365
    let dayG = 730
    let dayH = 1095

    let dayO = 3650
    let dayP = 4015
    let dayQ = 4380
    let dayR = 4745
    let dayS = 5110
    let dayT = 5475
    let dayU = 5840
    let dayV = 6205
    let dayW = 6570
    let dayX = 6935

    let dayAE = 9490
    let (dayEA, dayEB, dayEC, dayED, dayEE, dayEF, dayEG, dayEH, dayEI, dayEJ, dayEK, dayEL, dayEM, dayEN, dayEO, dayEP, dayEQ, dayER, dayES, dayET, dayEV, dayEW, dayEY, dayEZ) = (
      3285, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935, 7300, 7665, 8030, 8395, 8760, 9125, 9490, 9855, 10220, 10950, 11315, 12045, 12410
    )

    let dayDR = 0
    let dayDS = 365
    let dayDT = 730
    let dayDU = 1095
    let dayDV = 1460
    let dayDW = 1825
    let dayDX = 2190
    let dayDY = 2555
    let dayDZ = 2920

    let equiv_harmonious_range = equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]

    let ddAE = 45990
    for i in 0..<365 { day7[ddAE + i] = equiv_harmonious_range < 1E-10 ? 1 : (day1[dayAE + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range }
    
    /// Surplus harm op period el after min day harm op and min night op prep
    let dayFC = 0
    // EB6+EH6-O6-MIN(EK6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFC + i] =
        day6[dayEB + i] + day6[dayEH + i] - day1[dayO + i] - min(day6[dayEK + i], max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
          Double.zero, day1[dayQ + i] - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let dayFD = 365
    // EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFD + i] =
        day6[dayEB + i] + day6[dayEH + i] - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddAE + i])
        - min(
          day6[dayEK + i],
          max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i]) + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff - day6[dayEJ + i])
            / BESS_chrg_eff) - max(Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i]) - day6[dayEE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let dayFE = 730
    // EC6+EI6-O6-MIN(EL6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 {
      day7[dayFE + i] =
        day6[dayEC + i] + day6[dayEI + i] - day1[dayO + i] - min(day6[dayEL + i], max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
          Double.zero, day1[dayQ + i] - day6[dayEF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFF = 1095
    // (EK6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 { day7[dayFF + i] = (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - day1[dayE + i] - day1[dayG + i] / El_boiler_eff }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFG = 1460
    // (EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff
    for i in 0..<365 {
      day7[dayFG + i] =
        (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i])
        - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayFH = 1825
    // (EL6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 { day7[dayFH + i] = (day6[dayEL + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i] - day1[dayE + i] - day1[dayG + i] / El_boiler_eff }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFI = 2190
    // EE6+(EB6+EH6-MIN(EK6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      day7[dayFI + i] =
        day6[dayEE + i] + (day6[dayEB + i] + day6[dayEH + i] - min(day6[dayEK + i], max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - day1[dayO + i])
        * El_boiler_eff - day1[dayQ + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFJ = 2555
    // EE6+(EB6+EH6-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff-EJ6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayFJ + i] =
        day6[dayEE + i]
        + (day6[dayEB + i] + day6[dayEH + i]
          - min(
            day6[dayEK + i],
            max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i]) + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff - day6[dayEJ + i])
              / BESS_chrg_eff) - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddAE + i])) * El_boiler_eff
        - (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i])
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayFK = 2920
    // EF6+(EC6+EI6-MIN(EL6,max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      day7[dayFK + i] =
        day6[dayEF + i] + (day6[dayEC + i] + day6[dayEI + i] - min(day6[dayEL + i], max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - day1[dayO + i])
        * El_boiler_eff - day1[dayQ + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let dayFL = 3285
    /// Surplus outside harm op heat after min day harm and max night op prep
    let dayFM = 3650
    /// Surplus outside harm op heat after max day harm and min night op prep
    let dayFN = 4015
    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let dayFO = 4380
    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let dayFP = 4745
    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let dayFQ = 5110
    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let dayFR = 5475
    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let dayFS = 5840
    for i in 0..<365 {
      // EG6+ER6*El_boiler_eff-G6
      day7[dayFL + i] = day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i]
      // EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      day7[dayFM + i] = day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i])
      // EG6+ER6*El_boiler_eff-G6
      day7[dayFN + i] = day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i]
      // EP6-MAX(0,Q6-EE6)/El_boiler_eff
      day7[dayFO + i] = day6[dayEP + i] - max(Double.zero, day1[dayQ + i] - day6[dayEE + i]) / El_boiler_eff
      // EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
      day7[dayFP + i] = day6[dayEP + i] - max(Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i]) - day6[dayEE + i]) / El_boiler_eff
      // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
      day7[dayFQ + i] = day6[dayEQ + i] - max(Double.zero, day1[dayQ + i] - day6[dayEF + i]) / El_boiler_eff
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      day7[dayFR + i] = day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff  
      // ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff
      day7[dayFS + i] = day6[dayER + i] - max(Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) - day6[dayEG + i]) / El_boiler_eff
     }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let dayFT = 6205
    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let dayFU = 6570
    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let dayFV = 6935
    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let dayFW = 7300
    /// Surplus CO2 prod cap after min day harm and min night op prep
    let dayFX = 7665
    /// Surplus CO2 prod cap after min day harm and max night op prep
    let dayFY = 8030
    /// Surplus CO2 prod cap after max day harm and min night op prep
    let dayFZ = 8395
    /// Surplus H2 prod cap after min day harm and min night op prep
    let dayGA = 8760
    /// Surplus H2 prod cap after min day harm and max night op prep
    let dayGB = 9125
    /// Surplus H2 prod cap after max day harm and min night op prep
    let dayGC = 9490

    for i in 0..<365 {
      // ER6-MAX(0,G6-EG6)/El_boiler_eff
      day7[dayFT + i] = day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff
      // ES6-S6
      day7[dayFU + i] = day6[dayES + i] - day1[dayS + i]
      // ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      day7[dayFV + i] = day6[dayES + i] - (day1[dayS + i] + (day1[dayT + i] - day1[dayS + i]) * day7[ddAE + i])
      // ET6-S6
      day7[dayFW + i] = day6[dayET + i] - day1[dayS + i]
      // EV6-U6
      day7[dayFX + i] = day6[dayEV + i] - day1[dayU + i]
      // EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      day7[dayFY + i] = day6[dayEV + i] - (day1[dayU + i] + (day1[dayV + i] - day1[dayU + i]) * day7[ddAE + i])
      // EW6-U6
      day7[dayFZ + i] = day6[dayEW + i] - day1[dayU + i]
      // EY6-W6
      day7[dayGA + i] = day6[dayEY + i] - day1[dayW + i]
      // EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
      day7[dayGB + i] = day6[dayEY + i] - (day1[dayW + i] + (day1[dayX + i] - day1[dayW + i]) * day7[ddAE + i])
      // EZ6-W6
      day7[dayGC + i] = day6[dayEZ + i] - day1[dayW + i]
    }
    let Overall_harmonious_range = Overall_harmonious_max_perc - Overall_harmonious_min_perc
    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let dayGE = 9855
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FE6),1),IFERROR(FF6/MAX(0,FF6-FH6),1),IFERROR(FI6/MAX(0,FI6-FK6),1),IFERROR(FL6/MAX(0,FL6-FN6),1),IFERROR(FO6/MAX(0,FO6-FQ6),1),IFERROR(FR6/MAX(0,FR6-FT6),1),IFERROR(FU6/MAX(0,FU6-FW6),1),IFERROR(FX6/MAX(0,FX6-FZ6),1),IFERROR(GA6/MAX(0,GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGE + i] = iff(
        or(
          day7[dayFC + i] < Double.zero, day7[dayFF + i] < Double.zero, day7[dayFI + i] < Double.zero, day7[dayFL + i] < Double.zero, day7[dayFO + i] < Double.zero,
          day7[dayFR + i] < Double.zero, day7[dayFU + i] < Double.zero, day7[dayFX + i] < Double.zero, day7[dayGA + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dayFC + i] / (day7[dayFC + i] - day7[dayFE + i]), 1), ifFinite(day7[dayFF + i] / max(Double.zero, day7[dayFF + i] - day7[dayFH + i]), 1),
          ifFinite(day7[dayFI + i] / max(Double.zero, day7[dayFI + i] - day7[dayFK + i]), 1), ifFinite(day7[dayFL + i] / max(Double.zero, day7[dayFL + i] - day7[dayFN + i]), 1),
          ifFinite(day7[dayFO + i] / max(Double.zero, day7[dayFO + i] - day7[dayFQ + i]), 1), ifFinite(day7[dayFR + i] / max(Double.zero, day7[dayFR + i] - day7[dayFT + i]), 1),
          ifFinite(day7[dayFU + i] / max(Double.zero, day7[dayFU + i] - day7[dayFW + i]), 1), ifFinite(day7[dayFX + i] / max(Double.zero, day7[dayFX + i] - day7[dayFZ + i]), 1),
          ifFinite(day7[dayGA + i] / max(Double.zero, day7[dayGA + i] - day7[dayGC + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc)
    }

    let ddGE = 46355 
    for i in 0..<365 { day7[ddGE + i] = Overall_harmonious_range < 1E-10 ? 1 : (day7[dayGE + i] - Overall_harmonious_min_perc) / Overall_harmonious_range } 

    /// Surplus harm op period el after opt day harm op and min night op prep
    let dayGF = 10220
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),max(0,EA6+E6+G6/El_boiler_eff-EJ6)/BESS_chrg_eff)-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGF + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddGE + i])
            + (day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddGE + i]) - day1[dayO + i]
            - min(
              day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i],
              max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
              Double.zero, day1[dayQ + i] - (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i]))
            / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let dayGG = 10585
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGG + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddGE + i])
            + (day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddGE + i])
            - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddAE + i])
            - min(
              day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i],
              max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i])
                + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
              Double.zero,
              (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i])
                - (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i])) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayGH = 10950
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGH + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          ((day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i]) + day6[dayEM + i]) * BESS_chrg_eff
            + day6[dayEJ + i] - day1[dayE + i] - day1[dayG + i] / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayGI = 11315
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGI + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          ((day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i]) + day6[dayEM + i]) * BESS_chrg_eff
            + day6[dayEJ + i] - (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i])
            - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayGJ = 11680
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6,5))
    for i in 0..<365 {
      day7[dayGJ + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i])
            + ((day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddGE + i])
              + (day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddGE + i])
              - min(
                day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i],
                max(Double.zero, day6[dayEA + i] + day1[dayE + i] + day1[dayG + i] / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - day1[dayO + i]) * El_boiler_eff - day1[dayQ + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayGK = 12045
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGK + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i])
            + ((day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddGE + i])
              + (day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddGE + i])
              - min(
                day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i],
                max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddAE + i])
                  + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff)
              - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddAE + i])) * El_boiler_eff - (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i]), 5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let dayGL = 12410
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-G6,5))
    for i in 0..<365 { day7[dayGL + i] = iff(day7[dayGE + i].isZero, Double.zero, round(day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - day1[dayG + i], 5)) }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let dayGM = 12775
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGM + i] = iff(
        day7[dayGE + i].isZero, Double.zero, round(day6[dayEG + i] + day6[dayER + i] * El_boiler_eff - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]), 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let dayGN = 13140
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGN + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEP + i] + (day6[dayEQ + i] - day6[dayEP + i]) * day7[ddGE + i]) - max(
            Double.zero, day1[dayQ + i] - (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i]))
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let dayGO = 13505
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGO + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEP + i] + (day6[dayEQ + i] - day6[dayEP + i]) * day7[ddGE + i]) - max(
            Double.zero,
            (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddAE + i])
              - (day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i])) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let dayGP = 13870
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 { day7[dayGP + i] = iff(day7[dayGE + i].isZero, Double.zero, round(day6[dayER + i] - max(Double.zero, day1[dayG + i] - day6[dayEG + i]) / El_boiler_eff, 5)) }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let dayGQ = 14235
    // IF(GE6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayGQ + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(day6[dayER + i] - max(Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddAE + i]) - day6[dayEG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let dayGR = 14600
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 {
      day7[dayGR + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round((day6[dayES + i] + (day6[dayET + i] - day6[dayES + i]) * day7[ddGE + i]) - day1[dayS + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let dayGS = 14965
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGS + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayES + i] + (day6[dayET + i] - day6[dayES + i]) * day7[ddGE + i])
            - (day1[dayS + i] + (day1[dayT + i] - day1[dayS + i]) * day7[ddAE + i]), 5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let dayGT = 15330
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 {
      day7[dayGT + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round((day6[dayEV + i] + (day6[dayEW + i] - day6[dayEV + i]) * day7[ddGE + i]) - day1[dayU + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let dayGU = 15695
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGU + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEV + i] + (day6[dayEW + i] - day6[dayEV + i]) * day7[ddGE + i])
            - (day1[dayU + i] + (day1[dayV + i] - day1[dayU + i]) * day7[ddAE + i]), 5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let dayGV = 16060
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 {
      day7[dayGV + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round((day6[dayEY + i] + (day6[dayEZ + i] - day6[dayEY + i]) * day7[ddGE + i]) - day1[dayW + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let dayGW = 16425
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      day7[dayGW + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        round(
          (day6[dayEY + i] + (day6[dayEZ + i] - day6[dayEY + i]) * day7[ddGE + i])
            - (day1[dayW + i] + (day1[dayX + i] - day1[dayW + i]) * day7[ddAE + i]), 5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let dayGX = 16790
    // IF(OR(GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/MAX(0,GF6-GG6),1),IFERROR(GH6/MAX(0,GH6-GI6),1),IFERROR(GJ6/MAX(0,GJ6-GK6),1),IFERROR(GL6/MAX(0,GL6-GM6),1),IFERROR(GN6/MAX(0,GN6-GO6),1),IFERROR(GP6/MAX(0,GP6-GQ6),1),IFERROR(GR6/MAX(0,GR6-GS6),1),IFERROR(GT6/MAX(0,GT6-GU6),1),IFERROR(GV6/MAX(0,GV6-GW6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGX + i] = iff(
        or(day7[dayGE + i].isZero,
          day7[dayGF + i] < Double.zero, day7[dayGH + i] < Double.zero, day7[dayGJ + i] < Double.zero, day7[dayGL + i] < Double.zero, day7[dayGN + i] < Double.zero,
          day7[dayGP + i] < Double.zero, day7[dayGR + i] < Double.zero, day7[dayGT + i] < Double.zero, day7[dayGV + i] < 0), Double.zero,        
        min(
          1, ifFinite(day7[dayGF + i] / max(Double.zero, day7[dayGF + i] - day7[dayGG + i]), 1), ifFinite(day7[dayGH + i] / max(Double.zero, day7[dayGH + i] - day7[dayGI + i]), 1),
          ifFinite(day7[dayGJ + i] / max(Double.zero, day7[dayGJ + i] - day7[dayGK + i]), 1), ifFinite(day7[dayGL + i] / max(Double.zero, day7[dayGL + i] - day7[dayGM + i]), 1),
          ifFinite(day7[dayGN + i] / max(Double.zero, day7[dayGN + i] - day7[dayGO + i]), 1), ifFinite(day7[dayGP + i] / max(Double.zero, day7[dayGP + i] - day7[dayGQ + i]), 1),
          ifFinite(day7[dayGR + i] / max(Double.zero, day7[dayGR + i] - day7[dayGS + i]), 1), ifFinite(day7[dayGT + i] / max(Double.zero, day7[dayGT + i] - day7[dayGU + i]), 1),
          ifFinite(day7[dayGV + i] / max(Double.zero, day7[dayGV + i] - day7[dayGW + i]), 1)) * (day1[dayAE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let dayGZ = 17155
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/MAX(0,FC6-FD6),1),IFERROR(FF6/MAX(0,FF6-FG6),1),IFERROR(FI6/MAX(0,FI6-FJ6),1),IFERROR(FL6/MAX(0,FL6-FM6),1),IFERROR(FO6/MAX(0,FO6-FP6),1),IFERROR(FR6/MAX(0,FR6-FS6),1),IFERROR(FU6/MAX(0,FU6-FV6),1),IFERROR(FX6/MAX(0,FX6-FY6),1),IFERROR(GA6/MAX(0,GA6-GB6),1))*($AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day7[dayGZ + i] = iff(
        or(
          day7[dayFC + i] < Double.zero, day7[dayFF + i] < Double.zero, day7[dayFI + i] < Double.zero, day7[dayFL + i] < Double.zero,
          day7[dayFO + i] < Double.zero, day7[dayFR + i] < Double.zero, day7[dayFU + i] < Double.zero, day7[dayFX + i] < Double.zero, day7[dayGA + i] < 0), Double.zero,
        min(
          1, ifFinite(day7[dayFC + i] / max(Double.zero, day7[dayFC + i] - day7[dayFD + i]), 1), ifFinite(day7[dayFF + i] / max(Double.zero, day7[dayFF + i] - day7[dayFG + i]), 1),
          ifFinite(day7[dayFI + i] / max(Double.zero, day7[dayFI + i] - day7[dayFJ + i]), 1), ifFinite(day7[dayFL + i] / max(Double.zero, day7[dayFL + i] - day7[dayFM + i]), 1),
          ifFinite(day7[dayFO + i] / max(Double.zero, day7[dayFO + i] - day7[dayFP + i]), 1), ifFinite(day7[dayFR + i] / max(Double.zero, day7[dayFR + i] - day7[dayFS + i]), 1),
          ifFinite(day7[dayFU + i] / max(Double.zero, day7[dayFU + i] - day7[dayFV + i]), 1), ifFinite(day7[dayFX + i] / max(Double.zero, day7[dayFX + i] - day7[dayFY + i]), 1),
          ifFinite(day7[dayGA + i] / max(Double.zero, day7[dayGA + i] - day7[dayGB + i]), 1)) * (day1[dayAE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let dayHA = 17520
    /// Surplus harm op period el after max day harm op and opt night op prep
    let dayHB = 17885
    /// Surplus outside harm op period el after min day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayHC = 18250
    /// Surplus outside harm op period el after max day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let dayHD = 18615
    /// Surplus harm op heat after min day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayHE = 18980
    /// Surplus harm op heat after max day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let dayHF = 19345
    /// Surplus outside harm op heat after min day harm and opt night op prep
    let dayHG = 19710
    /// Surplus outside harm op heat after max day harm and opt night op prep
    let dayHH = 20075
    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let dayHI = 20440
    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let dayHJ = 20805
    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let dayHK = 21170
    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let dayHL = 21535
    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let dayHM = 21900
    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let dayHN = 22265
    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let dayHO = 22630
    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let dayHP = 22995
    /// Surplus H2 prod cap after min day harm and opt night op prep
    let dayHQ = 23360
    /// Surplus H2 prod cap after min day harm and opt night op prep
    let dayHR = 23725

    let ddGZ = 47085 
    for i in 0..<365 { day7[ddGZ + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (day7[dayGZ + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j] } 

    // IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      day7[dayHA + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEB + i] + day6[dayEH + i] - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGZ + i])
            - min(
              day6[dayEK + i],
              max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
                + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
              Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]) - day6[dayEE + i])
            / El_boiler_eff, 5))

      // IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EL6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
      day7[dayHB + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEC + i] + day6[dayEI + i] - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGZ + i])
            - min(
              day6[dayEL + i],
              max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
                + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff) - max(
              Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]) - day6[dayEF + i])
            / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
      day7[dayHC + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          (day6[dayEK + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
            - (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
            - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
      day7[dayHD + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          (day6[dayEL + i] + day6[dayEM + i]) * BESS_chrg_eff + day6[dayEJ + i]
            - (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
            - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff, 5))
      // IF(GZ6=0,0,ROUND(EE6+(EB6+EH6-MIN(EK6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHE + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEE + i]
            + (day6[dayEB + i] + day6[dayEH + i]
              - min(
                day6[dayEK + i],
                max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
                  + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff)
              - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGZ + i])) * El_boiler_eff
            - (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]), 5))
      // IF(GZ6=0,0,ROUND(EF6+(EC6+EI6-MIN(EL6,max(0,EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff-ej6)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHF + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEF + i]
            + (day6[dayEC + i] + day6[dayEI + i]
              - min(
                day6[dayEL + i],
                max(Double.zero, day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
                  + (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) / El_boiler_eff - day6[dayEJ + i]) / BESS_chrg_eff)
              - (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGZ + i])) * El_boiler_eff
            - (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]), 5))
      // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHG + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
            - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHH + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEG + i] + day6[dayER + i] * El_boiler_eff
            - (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
      day7[dayHI + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEP + i] - max(
            Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]) - day6[dayEE + i]) / El_boiler_eff,
          5))

      // IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
      day7[dayHJ + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayEQ + i] - max(
            Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]) - day6[dayEF + i]) / El_boiler_eff,
          5))

      // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      day7[dayHK + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayER + i] - max(
            Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) - day6[dayEG + i]) / El_boiler_eff,
          5))

      // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
      day7[dayHL + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(
          day6[dayER + i] - max(
            Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) - day6[dayEG + i]) / El_boiler_eff,
          5))

      // IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHM + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayES + i] - (day1[dayS + i] + (day1[dayT + i] - day1[dayS + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHN + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayET + i] - (day1[dayS + i] + (day1[dayT + i] - day1[dayS + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHO + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayEV + i] - (day1[dayU + i] + (day1[dayV + i] - day1[dayU + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHP + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayEW + i] - (day1[dayU + i] + (day1[dayV + i] - day1[dayU + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHQ + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayEY + i] - (day1[dayW + i] + (day1[dayX + i] - day1[dayW + i]) * day7[ddGZ + i]), 5))

      // IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
      day7[dayHR + i] = iff(
        day7[dayGZ + i].isZero, Double.zero,
        round(day6[dayEZ + i] - (day1[dayW + i] + (day1[dayX + i] - day1[dayW + i]) * day7[ddGZ + i]), 5))
    }

    /// Opt harm op period op during night prio operation
    let dayHS = 24090
    // IF(OR(GZ3=0,HA3<0,HC3<0,HE3<0,HG3<0,HI3<0,HK3<0,HM3<0,HO3<0,HQ3<0),0,MIN(1,MIN(IFERROR(HA6/MAX(0,HA6-HB6),1),IFERROR(HC6/MAX(0,HC6-HD6),1),IFERROR(HE6/MAX(0,HE6-HF6),1),IFERROR(HG6/MAX(0,HG6-HH6),1),IFERROR(HI6/MAX(0,HI6-HJ6),1),IFERROR(HK6/MAX(0,HK6-HL6),1),IFERROR(HM6/MAX(0,HM6-HN6),1),IFERROR(HO6/MAX(0,HO6-HP6),1),IFERROR(HQ6/MAX(0,HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayHS + i] = iff(
        or(day7[dayGZ + i].isZero,
          day7[dayHA + i] < Double.zero, day7[dayHC + i] < Double.zero, day7[dayHE + i] < Double.zero, day7[dayHG + i] < Double.zero, day7[dayHI + i] < Double.zero,
          day7[dayHK + i] < Double.zero, day7[dayHM + i] < Double.zero, day7[dayHO + i] < Double.zero, day7[dayHQ + i] < 0), Double.zero,
        min(
          1,
          min(
            ifFinite(day7[dayHA + i] / max(Double.zero, day7[dayHA + i] - day7[dayHB + i]), 1), ifFinite(day7[dayHC + i] / max(Double.zero, day7[dayHC + i] - day7[dayHD + i]), 1),
            ifFinite(day7[dayHE + i] / max(Double.zero, day7[dayHE + i] - day7[dayHF + i]), 1), ifFinite(day7[dayHG + i] / max(Double.zero, day7[dayHG + i] - day7[dayHH + i]), 1),
            ifFinite(day7[dayHI + i] / max(Double.zero, day7[dayHI + i] - day7[dayHJ + i]), 1), ifFinite(day7[dayHK + i] / max(Double.zero, day7[dayHK + i] - day7[dayHL + i]), 1),
            ifFinite(day7[dayHM + i] / max(Double.zero, day7[dayHM + i] - day7[dayHN + i]), 1), ifFinite(day7[dayHO + i] / max(Double.zero, day7[dayHO + i] - day7[dayHP + i]), 1),
            ifFinite(day7[dayHQ + i] / max(Double.zero, day7[dayHQ + i] - day7[dayHR + i]), 1)) * Overall_harmonious_range + Overall_harmonious_min_perc))
    }

    /// Heat cons for harm op during harm op period
    let dayID = 27740
    /// Heat cons for night prep during harm op period
    let dayIE = 28105
    /// CSP heat available after harm op during harm op period
    let dayIF = 28470
    /// El boiler heat prod for harm op during harm op period
    let dayIG = 28835
    /// El boiler heat prod for night prep during harm op period
    let dayIH = 29200
    /// el cons for harm op during harm op period
    let dayHU = 24455
    /// Balance of heat during harm op period
    let dayII = 29565
    /// el cons for night prep during harm op period
    let dayHV = 24820
    /// el cons for BESS charging during harm op period
    let dayHW = 25185
    /// el cons of el boiler for harm op during harm op period
    let dayHX = 25550
    /// el cons of el boiler for night prep during harm op period
    let dayHY = 25915
    /// PV available after harm op during harm op period
    let dayHZ = 26280
    /// grid input for harm op during harm op period
    let dayIA = 26645

    let ddGX = 46720
    for i in 0..<365 { day7[ddGX + i] = equiv_harmonious_range[j] < 1E-10 ? 1 : (day7[dayGX + i] - equiv_harmonious_min_perc[j]) / equiv_harmonious_range[j] } 

    // IF(GE6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayID + i] = iff(
        day7[dayGE + i].isZero, Double.zero, day6[dayDT + i] + (day6[dayDU + i] - day6[dayDT + i]) * day7[ddGE + i])

      // IF(GX6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      day7[dayIE + i] = iff(
        day7[dayGX + i].isZero, Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGX + i]))

      // IF=IF(GE6=0,EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      day7[dayIF + i] = iff(
        day7[dayGE + i].isZero, day6[dayEF + i], day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddGE + i])

      // IG=IF(GE6=0,EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
      day7[dayIG + i] = iff(
        day7[dayGE + i].isZero, day6[dayEO + i],
        (day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i]) * day7[ddGE + i]) * El_boiler_eff)

      // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
      day7[dayIH + i] = iff(
        day7[dayGE + i].isZero, Double.zero,
        min(
          (day6[dayEP + i] + (day6[dayEQ + i] - day6[dayEP + i]) * day7[ddGE + i]) * El_boiler_eff,
          max(Double.zero, day7[dayIE + i] - day7[dayIF + i])))

      // IF6+IH6-IE6
      day7[dayII + i] = day7[dayIF + i] + day7[dayIH + i] - day7[dayIE + i]

      // HU=IF(DR6=0,0,IF(GE6=0,DS6,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))
      day7[dayHU + i] = iff(day6[dayDR + i].isZero, Double.zero, iff(
        day7[dayGE + i].isZero, day6[dayDS + i], day6[dayDR + i] + (day6[dayDS + i] - day6[dayDR + i]) * day7[ddGE + i]))

      // HV=IF(GX6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
      day7[dayHV + i] = iff(
        day7[dayGX + i].isZero, Double.zero, (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGX + i]))

      // HW=IF(OR(GE6=0,GX6=0),MIN(EA6/BESS_chrg_eff,EL6),MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))
      day7[dayHW + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), min(day6[dayEA + i] / BESS_chrg_eff, day6[dayEL + i]),
        min(
          (day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGX + i]) + max(
            Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGX + i]) - day6[dayEG + i]) / El_boiler_eff
            - day6[dayED + i]) / BESS_chrg_eff, (day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddGE + i])))

      // IF(GE6=0,EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      day7[dayHX + i] = iff(
        day7[dayGE + i].isZero, day6[dayEO + i], day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i]) * day7[ddGE + i])

      // IH6/El_boiler_eff
      day7[dayHY + i] = day7[dayIH + i] / El_boiler_eff

      // HZ=IF(GE6=0,EC6,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      day7[dayHZ + i] = iff(
        day7[dayGE + i].isZero, day6[dayEC + i], day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddGE + i])
      
      // IF(GE6=0,DZ6,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
      day7[dayIA + i] = iff(
        day7[dayGE + i].isZero, day6[dayDZ + i], day6[dayDY + i] + (day6[dayDZ + i] - day6[dayDY + i]) * day7[ddGE + i])
    }

    /// grid input for night prep during harm op period
    let dayIB = 27010
    // IB=MIN(IF(GE6=0,0,EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)),MAX(0,-(HZ6-HV6-HW6-HY6)))
    for i in 0..<365 {
      day7[dayIB + i] = min(iff(
        day7[dayGE + i].isZero, Double.zero,
          day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddGE + i]),
          max(Double.zero, -(day7[dayHZ + i] - day7[dayHV + i] - day7[dayHW + i] - day7[dayHY + i])))
    }

    /// Balance of electricity during harm op period
    let dayIC = 27375
    // HZ6+IB6-HV6-HW6-HY6
    for i in 0..<365 { day7[dayIC + i] = day7[dayHZ + i] + day7[dayIB + i] - day7[dayHV + i] - day7[dayHW + i] - day7[dayHY + i] }

    /// heat cons for harm op outside of harm op period
    let dayIQ = 32485
    // IF(OR(GE6=0,GX6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIQ + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGX + i])
    }

    /// heat from CSP outside of harm op period
    let dayIR = 32850
    // IF(OR(GE6=0,GX6=0),0,EG6)
    for i in 0..<365 { day7[dayIR + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayEG + i]) }

    /// heat from el boiler outside of harm op period
    let dayIS = 33215
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 {
      day7[dayIS + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, min(day6[dayER + i] * El_boiler_eff, max(Double.zero, day7[dayIQ + i] - day7[dayIR + i])))
    }

    /// Balance of heat outside of harm op period
    let dayIT = 33580
    // IR6+IS6-IQ6
    for i in 0..<365 { day7[dayIT + i] = day7[dayIR + i] + day7[dayIS + i] - day7[dayIQ + i] }

    /// el cons for harm op outside of harm op period
    let dayIJ = 29930
    // IF(OR(GE6=0,GX6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayIJ + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGX + i])
    }

    /// el cons by el boiler outside of harm op period
    let dayIK = 30295
    // IS6/El_boiler_eff
    for i in 0..<365 { day7[dayIK + i] = day7[dayIS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let dayIL = 30660
    // IF(OR(GE6=0,GX6=0),0,EA6)
    for i in 0..<365 { day7[dayIL + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayEA + i]) }

    /// el from PV outside of harm op period
    let dayIM = 31025
    // IF(OR(GE6=0,GX6=0),0,ED6)
    for i in 0..<365 { day7[dayIM + i] = iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayED + i]) }

    /// el from BESS outside of harm op period
    let dayIN = 31390
    // HW6*BESS_chrg_eff
    for i in 0..<365 { day7[dayIN + i] = day7[dayHW + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let dayIO = 31755
    // IF(OR(GE6=0,GX6=0),0,MIN(EJ6+EA6,MAX(0,-(IM6+IN6-IJ6-IK6-IL6))))
    for i in 0..<365 {
      day7[dayIO + i] = iff(
        or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero,
        min(day6[dayEJ + i] + day6[dayEA + i], max(Double.zero, -(day7[dayIM + i] + day7[dayIN + i] - day7[dayIJ + i] - day7[dayIK + i] - day7[dayIL + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayIP = 32120
    // IM6+IN6+IO6-IJ6-IK6-IL6
    for i in 0..<365 { day7[dayIP + i] = day7[dayIM + i] + day7[dayIN + i] + day7[dayIO + i] - day7[dayIJ + i] - day7[dayIK + i] - day7[dayIL + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let dayIU = 33945
    // MAX(0,HU6-$C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,IJ6-$B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      day7[dayIU + i] =
        max(Double.zero,
          day7[dayHU + i] - day0[dayC + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud          
        + max(Double.zero,
          day7[dayIJ + i] - day0[dayB + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud          
    }

    /// grid export
    let dayIV = 34310
    // MIN(IC6,IF(OR(GE6=0,GX6=0),DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))+MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))
    for i in 0..<365 {
      day7[dayIV + i] =
        min(
          day7[dayIC + i],
          iff(
            or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), day6[dayDW + i],
            (day6[dayDV + i] + (day6[dayDW + i] - day6[dayDV + i]) * day7[ddGE + i])))
        + min(day7[dayIP + i], iff(or(day7[dayGE + i].isZero, day7[dayGX + i].isZero), Double.zero, day6[dayDX + i]))
    }

    /// grid import
    let dayIW = 34675
    // IA6+IB6+IO6
    for i in 0..<365 { day7[dayIW + i] = day7[dayIA + i] + day7[dayIB + i] + day7[dayIO + i] }

    /// Checksum
    let dayIX = 35040
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    for i in 0..<365 {
      let IX = max(Double.zero, -day7[dayIC + i]) + max(Double.zero, -day7[dayII + i]) + max(Double.zero, -day7[dayIP + i]) + max(Double.zero, -day7[dayIT + i])
      // if IX > 1E-13 { print("Checksum error daily 2", i, j, IX) }
      day7[dayIX + i] = IX
    }

    let ddHS = 47450
    for i in 0..<365 { day7[ddHS + i] = Overall_harmonious_range < 1E-10 ? 1 : (day7[dayHS + i] - Overall_harmonious_min_perc) / Overall_harmonious_range } 

    /// Heat cons for harm op during harm op period
    let dayJI = 38690
    // JI=IF(OR(HS6=0,GZ6=0),0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJI + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayDT + i] + (day6[dayDU + i] - day6[dayDT + i]) * day7[ddHS + i])
    }

    /// Heat cons for night prep during harm op period
    let dayJJ = 39055
    // JJ=IF(OR(HS6=0,GZ6=0),0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayJJ + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, (day1[dayQ + i] + (day1[dayR + i] - day1[dayQ + i]) * day7[ddGZ + i]))
    }

    /// CSP heat available after harm op during harm op period
    let dayJK = 39420
    // JK=IF(OR(HS6=0,GZ6=0),EF6,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJK + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayEF + i], day6[dayEE + i] + (day6[dayEF + i] - day6[dayEE + i]) * day7[ddHS + i])
    }

    /// El boiler heat prod for harm op during harm op period
    let dayJL = 39785
    // JL=IF(OR(HS6=0,GZ6=0),EO6,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      day7[dayJL + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayEO + i],
        (day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i]) * day7[ddHS + i]) * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let dayJM = 40150
    // IF(OR(HS6=0,GZ6=0),0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 {
      day7[dayJM + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        min(
          (day6[dayEP + i] + (day6[dayEQ + i] - day6[dayEP + i]) * day7[ddHS + i]) * El_boiler_eff,
          max(Double.zero, day7[dayJJ + i] - day7[dayJK + i])))
    }

    /// Balance of heat during harm op period
    let dayJN = 40515
    // JK6+JM6-JJ6
    for i in 0..<365 { day7[dayJN + i] = day7[dayJK + i] + day7[dayJM + i] - day7[dayJJ + i] }

    /// el cons for harm op during harm op period
    let dayIZ = 35405
    // IZ=IF(DR6=0,0,IF(OR(HS6=0,GZ6=0),DS6,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayIZ + i] = iff(day6[dayDR + i].isZero, Double.zero, iff( 
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayDS + i], day6[dayDR + i] + (day6[dayDS + i] - day6[dayDR + i]) * day7[ddHS + i]))
    }

    /// el cons for night prep during harm op period
    let dayJA = 35770
    // JA=IF(GZ6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      day7[dayJA + i] = iff(
        day7[dayGZ + i].isZero, Double.zero, (day1[dayO + i] + (day1[dayP + i] - day1[dayO + i]) * day7[ddGZ + i]))
    }

    /// el cons for BESS charging during harm op period
    let dayJB = 36135
    // JB=IF(OR(HS6=0,GZ6=0),MIN(EA3/BESS_chrg_eff,EL3),MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      day7[dayJB + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), min(day6[dayEA + i] / BESS_chrg_eff, day6[dayEL + i]),
        min(
          (day6[dayEA + i] + (day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i]) + max(
            Double.zero, (day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i]) - day6[dayEG + i]) / El_boiler_eff
            - day6[dayED + i]) / BESS_chrg_eff, (day6[dayEK + i] + (day6[dayEL + i] - day6[dayEK + i]) * day7[ddHS + i])))
    }

    /// el cons of el boiler for harm op during harm op period
    let dayJC = 36500
    // JC=IF(OR(HS6=0,GZ6=0),EO6,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJC + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayEO + i], day6[dayEN + i] + (day6[dayEO + i] - day6[dayEN + i]) * day7[ddHS + i])
    }

    /// el cons of el boiler for night prep during harm op period
    let dayJD = 36865
    // JM6/El_boiler_eff
    for i in 0..<365 { day7[dayJD + i] = day7[dayJM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let dayJE = 37230
    // IF(OR(HS6=0,GZ6=0),EC6,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJE + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayEC + i], day6[dayEB + i] + (day6[dayEC + i] - day6[dayEB + i]) * day7[ddHS + i])
    }

    /// grid input for harm op during harm op period
    let dayJF = 37595
    // IF(OR(HS6=0,GZ6=0),DZ6,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJF + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayDZ + i], day6[dayDY + i] + (day6[dayDZ + i] - day6[dayDY + i]) * day7[ddHS + i])
    }

    /// grid input for night prep during harm op period
    let dayJG = 37960
    // IF(OR(HS6=0,GZ6=0),0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc),MAX(0,-(JE6-JA6-JB6-JD6))))
    for i in 0..<365 {
      day7[dayJG + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        min(
          day6[dayEH + i] + (day6[dayEI + i] - day6[dayEH + i]) * day7[ddHS + i],
          max(Double.zero, -(day7[dayJE + i] - day7[dayJA + i] - day7[dayJB + i] - day7[dayJD + i]))))
    }

    /// Balance of electricity during harm op period
    let dayJH = 38325
    // JE6+JG6-JA6-JB6-JD6
    for i in 0..<365 { day7[dayJH + i] = day7[dayJE + i] + day7[dayJG + i] - day7[dayJA + i] - day7[dayJB + i] - day7[dayJD + i] }

    /// heat cons for harm op outside of harm op period
    let dayJV = 43435
    // IF(OR(HS6=0,GZ6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJV + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        day1[dayG + i] + (day1[dayH + i] - day1[dayG + i]) * day7[ddGZ + i])
    }

    /// heat from CSP outside of harm op period
    let dayJW = 43800
    // IF(OR(HS6=0,GZ6=0),0,EG6)
    for i in 0..<365 { day7[dayJW + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayEG + i]) }

    /// heat from el boiler outside of harm op period
    let dayJX = 44165
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 {
      day7[dayJX + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, min(day6[dayER + i] * El_boiler_eff, max(Double.zero, day7[dayJV + i] - day7[dayJW + i])))
    }

    /// Balance of heat outside of harm op period
    let dayJY = 44530
    // JW6+JX6-JV6
    for i in 0..<365 { day7[dayJY + i] = day7[dayJW + i] + day7[dayJX + i] - day7[dayJV + i] }

    /// el cons for harm op outside of harm op period
    let dayJO = 40880
    // IF(OR(HS6=0,GZ6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      day7[dayJO + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        day1[dayE + i] + (day1[dayF + i] - day1[dayE + i]) * day7[ddGZ + i])
    }

    /// el cons by el boiler outside of harm op period
    let dayJP = 41245
    /// el cons for aux cons outside of harm op period
    let dayJQ = 41610
    /// el from PV outside of harm op period
    let dayJR = 41975
    /// el from BESS outside of harm op period
    let dayJS = 42340
    
    for i in 0..<365 { 
      // JX6/El_boiler_eff
      day7[dayJP + i] = day7[dayJX + i] / El_boiler_eff
      // IF(OR(HS6=0,GZ6=0),0,EA6)
      day7[dayJQ + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayEA + i])
      // IF(OR(HS6=0,GZ6=0),0,ED6)
      day7[dayJR + i] = iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayED + i])
      // JB6*BESS_chrg_eff
      day7[dayJS + i] = day7[dayJB + i] * BESS_chrg_eff 
     }

    /// grid input outside of harm op period
    let dayJT = 42705
    // IF(OR(HS6=0,GZ6=0),0,MIN(EJ6+EA6,MAX(0,-(JR6+JS6-JO6-JP6-JQ6))))
    for i in 0..<365 {
      day7[dayJT + i] = iff(
        or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero,
        min(day6[dayEJ + i] + day6[dayEA + i], max(Double.zero, -(day7[dayJR + i] + day7[dayJS + i] - day7[dayJO + i] - day7[dayJP + i] - day7[dayJQ + i]))))
    }

    /// Balance of electricity outside of harm op period
    let dayJU = 43070
    // JR6+JS6+JT6-JO6-JP6-JQ6
    for i in 0..<365 { day7[dayJU + i] = day7[dayJR + i] + day7[dayJS + i] + day7[dayJT + i] - day7[dayJO + i] - day7[dayJP + i] - day7[dayJQ + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let dayJZ = 44895
    // MAX(0,IZ6-C6*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+MAX(0,JO6-B6*A_overall_fix_stby_cons)/A_overall_var_max_cons*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      day7[dayJZ + i] =        
        max(Double.zero,
          day7[dayIZ + i] - day0[dayC + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud          
        + max(Double.zero,
          day7[dayJO + i] - day0[dayB + i] * overall_fix_stby_cons[j]) / overall_var_max_cons[j] * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud          
    }

    /// grid export
    let dayKA = 45260
    // MIN(JH6,IF(OR(HS6=0,GZ6=0),DW6,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))+MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))
    for i in 0..<365 {
      day7[dayKA + i] =
        min(
          day7[dayJH + i],
          iff(
            or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), day6[dayDW + i],
            (day6[dayDV + i] + (day6[dayDW + i] - day6[dayDV + i]) * day7[ddHS + i])))
        + min(day7[dayJU + i], iff(or(day7[dayHS + i].isZero, day7[dayGZ + i].isZero), Double.zero, day6[dayDX + i]))
    }

    /// grid import
    let dayKB = 45625
    // JF6+JG6+JT6
    for i in 0..<365 { day7[dayKB + i] = day7[dayJF + i] + day7[dayJG + i] + day7[dayJT + i] }

    /// Checksum
    // let dayKC = 45990
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    // for i in 0..<365 {
    //   let KC = max(Double.zero, -day7[dayJH + i]) + max(Double.zero, -day7[dayJN + i]) + max(Double.zero, -day7[dayJU + i]) + max(Double.zero, -day7[dayJY + i])
    // if KC > 1E-13 { print("Checksum error daily 2", i, j, KC) }
    //   day7[dayKC + i] = KC
    //  }
  }
}