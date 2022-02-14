
extension TunOl {
  mutating func daily17(daily10: [Double], daily11: [Double], daily15: [Double], daily16: [Double]) -> [Double] {
    let daily1C = 0
    let daily1D = 365
    let daily1E = 730

    let daily1T = 5840
    let daily1U = 6205
    let daily1V = 6570

    let daily1Z = 8030
    let daily1AA = 8395
    let daily1AB = 8760
    let daily1AC = 9125
    let daily1AD = 9490
    let daily1AE = 9855
    let daily1AF = 10220
    let daily1AG = 10585
    let daily1AH = 10950
    let daily1AI = 11315

    let daily1AM = 12775
    
    let daily1EY = 0
    let daily1EZ = 365
    let daily1FA = 730
    let daily1FB = 1095
    let daily1FC = 1460
    let daily1FD = 1825
    let daily1FE = 2190
    let daily1FF = 2555
    let daily1FG = 2920
    let daily1FH = 3285
    let daily1FI = 3650
    let daily1FJ = 4015

    let daily1FL = 4745
    let daily1FM = 5110
    let daily1FN = 5475
    let daily1FO = 5840
    let daily1FP = 6205

    let daily1FR = 6935
    let daily1FS = 7300
    let daily1FT = 7665

    let daily1FV = 8395
    let daily1FW = 8760

    let daily1FY = 9490
    let daily1FZ = 9855

    let daily1GB = 10585
    let daily1GC = 10950
    let daily1GD = 11315
    let daily1GE = 11680
    let daily1GF = 12045
    let daily1GG = 12410
    let daily1GH = 12775
    let daily1GI = 13140

    let daily1GK = 13870
    let daily1GL = 14235

    let daily1GN = 14965
    let daily1GO = 15330

    let daily1GQ = 16060
    let daily1GR = 16425

    let daily1GU = 0
    let daily1GV = 365
    let daily1GW = 730
    let daily1GX = 1095
    let daily1GY = 1460
    let daily1GZ = 1825
    let daily1HA = 2190
    let daily1HB = 2555
    let daily1HC = 2920
    let daily1HD = 3285
    let daily1HE = 3650
    let daily1HF = 4015

    let daily1HH = 4745
    let daily1HI = 5110
    let daily1HJ = 5475
    let daily1HK = 5840
    let daily1HL = 6205

    let daily1HN = 6935
    let daily1HO = 7300
    let daily1HP = 7665

    let daily1HR = 8395
    let daily1HS = 8760

    let daily1HU = 9490
    let daily1HV = 9855

    let daily1HX = 10585
    let daily1HY = 10950
    let daily1HZ = 11315
    let daily1IA = 11680
    let daily1IB = 12045
    let daily1IC = 12410
    let daily1ID = 12775
    let daily1IE = 13140

    let daily1IG = 13870
    let daily1IH = 14235

    let daily1IJ = 14965
    let daily1IK = 15330

    let daily1IM = 16060
    let daily1IN = 16425


    var j = 0

    var daily17 = [Double](repeating: 0, count: 44_165)

    /// Surplus harm op period electricity after min harm op and min night op prep
    let daily1IQ = 0
    // FS6+GE6-Z6-MAX(0,AB6-FV6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IQ + i] =
        daily15[daily1FS + i] + daily15[daily1GE + i] - daily11[daily1Z + i] - max(
          0, daily10[daily1AB + i] - daily15[daily1FV + i]) / El_boiler_eff - daily15[daily1FR + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after min harm op and max night op prep
    let daily1IR = 365
    // HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-HN6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IR + i] =
        daily11[daily1HO + i] + daily16[daily1IA + i]
        - (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
        - max(
          0,
          (daily10[daily1AB + i]
            + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - daily11[daily1HR + i]) / El_boiler_eff - daily11[daily1HN + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let daily1IS = 730
    // FT6+GF6-Z6-MAX(0,AB6-FW6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IS + i] =
        daily15[daily1FT + i] + daily15[daily1GF + i] - daily11[daily1Z + i] - max(
          0, daily10[daily1AB + i] - daily15[daily1FW + i]) / El_boiler_eff - daily15[daily1FR + i] / BESS_chrg_eff
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let daily1IT = 1095
    // FV6+MAX(0,FS6+GE6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      daily17[daily1IT + i] =
        daily15[daily1FV + i] + max(
          0, daily15[daily1FS + i] + daily15[daily1GE + i] - daily11[daily1Z + i] - daily15[daily1FR + i] / BESS_chrg_eff)
        * El_boiler_eff - daily10[daily1AB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let daily1IU = 1460
    // HR6+MAX(0,HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1IU + i] =
        daily11[daily1HR + i] + max(
          0,
          daily11[daily1HO + i] + daily16[daily1IA + i]
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - daily11[daily1HN + i] / BESS_chrg_eff) * El_boiler_eff
        - (daily10[daily1AB + i]
          + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let daily1IV = 1825
    // FW6+MAX(0,FT6+GF6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      daily17[daily1IV + i] =
        daily15[daily1FW + i] + max(
          0, daily15[daily1FT + i] + daily15[daily1GF + i] - daily11[daily1Z + i] - daily15[daily1FR + i] / BESS_chrg_eff)
        * El_boiler_eff - daily10[daily1AB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let daily1IW = 2190
    // GH6-(AB6-FV6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IW + i] = daily11[daily1GH + i] - (daily10[daily1AB + i] - daily15[daily1FV + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep
    let daily1IX = 2555
    // ID6-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IX + i] =
        daily16[daily1ID + i]
        - ((daily10[daily1AB + i]
          + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
          - daily11[daily1HR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let daily1IY = 2920
    // GI6-(AB6-FW6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IY + i] = daily15[daily1GI + i] - (daily10[daily1AB + i] - daily15[daily1FW + i]) / El_boiler_eff
    }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let daily1IZ = 3285
    // FY6-FR6/BESS_chrg_eff
    for i in 0..<365 { daily17[daily1IZ + i] = daily15[daily1FY + i] - daily15[daily1FR + i] / BESS_chrg_eff }

    /// Surplus BESS chrg cap after min harm op and max night op prep
    let daily1JA = 3650
    // HU6-HN6/BESS_chrg_eff
    for i in 0..<365 { daily17[daily1JA + i] = daily16[daily1HU + i] - daily11[daily1HN + i] / BESS_chrg_eff }

    /// Surplus BESS chrg cap after max harm op and min night op prep
    let daily1JB = 4015
    // FZ6-FR6/BESS_chrg_eff
    for i in 0..<365 { daily17[daily1JB + i] = daily15[daily1FZ + i] - daily15[daily1FR + i] / BESS_chrg_eff }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let daily1JC = 4380
    // GK6-AD6
    for i in 0..<365 { daily17[daily1JC + i] = daily15[daily1GK + i] - daily11[daily1AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let daily1JD = 4745
    // IG6-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JD + i] =
        daily16[daily1IG + i]
        - (daily11[daily1AD + i]
          + (daily11[daily1AE + i] - daily11[daily1AD + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let daily1JE = 5110
    // GL6-AD6
    for i in 0..<365 { daily17[daily1JE + i] = daily11[daily1GL + i] - daily11[daily1AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let daily1JF = 5475
    // GN6-AF6
    for i in 0..<365 { daily17[daily1JF + i] = daily15[daily1GN + i] - daily10[daily1AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let daily1JG = 5840
    // IJ6-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JG + i] =
        daily16[daily1IJ + i]
        - (daily10[daily1AF + i]
          + (daily11[daily1AG + i] - daily10[daily1AF + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let daily1JH = 6205
    // GO6-AF6
    for i in 0..<365 { daily17[daily1JH + i] = daily15[daily1GO + i] - daily10[daily1AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let daily1JI = 6570
    // GQ6-AH6
    for i in 0..<365 { daily17[daily1JI + i] = daily15[daily1GQ + i] - daily10[daily1AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let daily1JJ = 6935
    // IM6-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JJ + i] =
        daily16[daily1IM + i]
        - (daily10[daily1AH + i]
          + (daily11[daily1AI + i] - daily10[daily1AH + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let daily1JK = 7300
    // GR6-AH6
    for i in 0..<365 { daily17[daily1JK + i] = daily11[daily1GR + i] - daily10[daily1AH + i] }

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let daily1JM = 7665
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IS6),1),IFERROR(IT6/(IT6-IV6),1),IFERROR(IW6/(IW6-IY6),1),IFERROR(IZ6/(IZ6-JB6),1),IFERROR(JC6/(JC6-JE6),1),IFERROR(JF6/(JF6-JH6),1),IFERROR(JI6/(JI6-JK6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1JM + i] = iff(
        or(
          daily11[daily1IQ + i] < 0, daily17[daily1IT + i] < 0, daily17[daily1IW + i] < 0, daily17[daily1IZ + i] < 0,
          daily11[daily1JC + i] < 0, daily11[daily1JF + i] < 0, daily11[daily1JI + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1IQ + i] / (daily11[daily1IQ + i] - daily17[daily1IS + i]), 1),
          ifFinite(daily17[daily1IT + i] / (daily17[daily1IT + i] - daily17[daily1IV + i]), 1),
          ifFinite(daily17[daily1IW + i] / (daily17[daily1IW + i] - daily17[daily1IY + i]), 1),
          ifFinite(daily17[daily1IZ + i] / (daily17[daily1IZ + i] - daily11[daily1JB + i]), 1),
          ifFinite(daily11[daily1JC + i] / (daily11[daily1JC + i] - daily11[daily1JE + i]), 1),
          ifFinite(daily11[daily1JF + i] / (daily11[daily1JF + i] - daily11[daily1JH + i]), 1),
          ifFinite(daily11[daily1JI + i] / (daily11[daily1JI + i] - daily11[daily1JK + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let daily1JN = 8030
    // IF(JM6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-MAX(0,AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JN + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FS + i]
            + (daily15[daily1FT + i] - daily15[daily1FS + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + (daily15[daily1GE + i]
              + (daily15[daily1GF + i] - daily15[daily1GE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1Z + i] - max(
              0,
              daily10[daily1AB + i]
                - (daily15[daily1FV + i]
                  + (daily15[daily1FW + i] - daily15[daily1FV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - daily15[daily1FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let daily1JO = 8395
    // IF(JM6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JO + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1HO + i]
            + (daily11[daily1HP + i] - daily11[daily1HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + (daily16[daily1IA + i]
              + (daily16[daily1IB + i] - daily16[daily1IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1HR + i]
                  + (daily11[daily1HS + i] - daily11[daily1HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - daily11[daily1HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let daily1JP = 8760
    // IF(JM6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6,5))
    for i in 0..<365 {
      daily17[daily1JP + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FV + i]
            + (daily15[daily1FW + i] - daily15[daily1FV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (daily15[daily1FS + i]
                + (daily15[daily1FT + i] - daily15[daily1FS + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                + (daily15[daily1GE + i]
                  + (daily15[daily1GF + i] - daily15[daily1GE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                - daily11[daily1Z + i] - daily15[daily1FR + i] / BESS_chrg_eff) * El_boiler_eff - daily10[daily1AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let daily1JQ = 9125
    // IF(JM6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JQ + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1HR + i]
            + (daily11[daily1HS + i] - daily11[daily1HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (daily11[daily1HO + i]
                + (daily11[daily1HP + i] - daily11[daily1HO + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                + (daily16[daily1IA + i]
                  + (daily16[daily1IB + i] - daily16[daily1IA + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
                - daily11[daily1HN + i] / BESS_chrg_eff) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let daily1JR = 9490
    // IF(JM6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1JR + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1GH + i]
            + (daily15[daily1GI + i] - daily11[daily1GH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - (daily10[daily1AB + i]
              - (daily15[daily1FV + i]
                + (daily15[daily1FW + i] - daily15[daily1FV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let daily1JS = 9855
    // IF(JM6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1JS + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily16[daily1ID + i]
            + (daily16[daily1IE + i] - daily16[daily1ID + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - ((daily10[daily1AB + i]
              + (daily11[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
              - (daily11[daily1HR + i]
                + (daily11[daily1HS + i] - daily11[daily1HR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let daily1JT = 10220
    // IF(JM6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JT + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FY + i]
            + (daily15[daily1FZ + i] - daily15[daily1FY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily15[daily1FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let daily1JU = 10585
    // IF(JM6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JU + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily16[daily1HU + i]
            + (daily11[daily1HV + i] - daily16[daily1HU + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let daily1JV = 10950
    // IF(JM6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AD6,5))
    for i in 0..<365 {
      daily17[daily1JV + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1GK + i]
            + (daily11[daily1GL + i] - daily15[daily1GK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1AD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let daily1JW = 11315
    // IF(JM6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JW + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          daily15[daily1GK + i] + (daily11[daily1GL + i] - daily15[daily1GK + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily11[daily1AD + i]
              + (daily11[daily1AE + i] - daily11[daily1AD + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let daily1JX = 11680
    // IF(JM6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AF6,5))
    for i in 0..<365 {
      daily17[daily1JX + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1GN + i]
            + (daily15[daily1GO + i] - daily15[daily1GN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily10[daily1AF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let daily1JY = 12045
    // IF(JM6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JY + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          daily15[daily1GN + i] + (daily15[daily1GO + i] - daily15[daily1GN + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily10[daily1AF + i]
              + (daily11[daily1AG + i] - daily10[daily1AF + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let daily1JZ = 12410
    // IF(JM6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AH6,5))
    for i in 0..<365 {
      daily17[daily1JZ + i] = iff(
        daily17[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1GQ + i]
            + (daily11[daily1GR + i] - daily11[daily1GQ + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
            - daily10[daily1AH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let daily1KA = 12775
    // IF(JM6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KA + i] = iff(
        daily17[daily1JM + i].isZero, 0,
        round(
          daily11[daily1GQ + i] + (daily11[daily1GR + i] - daily11[daily1GQ + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt night prep during day prio operation
    let daily1KB = 13140
    // IF(OR(JM6=0,JN6<0,JP6<0,JR6<0,JT6<0,JV6<0,JX6<0,JZ6<0),0,MIN(1,IFERROR(JN6/(JN6-JO6),1),IFERROR(JP6/(JP6-JQ6),1),IFERROR(JR6/(JR6-JS6),1),IFERROR(JT6/(JT6-JU6),1),IFERROR(JV6/(JV6-JW6),1),IFERROR(JX6/(JX6-JY6),1),IFERROR(JZ6/(JZ6-KA6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KB + i] = iff(
        or(
          daily17[daily1JM + i].isZero, daily11[daily1JN + i] < 0, daily11[daily1JP + i] < 0, daily17[daily1JR + i] < 0,
          daily11[daily1JT + i] < 0, daily17[daily1JV + i] < 0, daily11[daily1JX + i] < 0, daily17[daily1JZ + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1JN + i] / (daily11[daily1JN + i] - daily17[daily1JO + i]), 1),
          ifFinite(daily11[daily1JP + i] / (daily11[daily1JP + i] - daily11[daily1JQ + i]), 1),
          ifFinite(daily17[daily1JR + i] / (daily17[daily1JR + i] - daily11[daily1JS + i]), 1),
          ifFinite(daily11[daily1JT + i] / (daily11[daily1JT + i] - daily11[daily1JU + i]), 1),
          ifFinite(daily17[daily1JV + i] / (daily17[daily1JV + i] - daily11[daily1JW + i]), 1),
          ifFinite(daily11[daily1JX + i] / (daily11[daily1JX + i] - daily11[daily1JY + i]), 1),
          ifFinite(daily17[daily1JZ + i] / (daily17[daily1JZ + i] - daily11[daily1KA + i]), 1))
          * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let daily1KD = 13505
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IR6),1),IFERROR(IT6/(IT6-IU6),1),IFERROR(IW6/(IW6-IX6),1),IFERROR(IZ6/(IZ6-JA6),1),IFERROR(JC6/(JC6-JD6),1),IFERROR(JF6/(JF6-JG6),1),IFERROR(JI6/(JI6-JJ6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KD + i] = iff(
        or(
          daily11[daily1IQ + i] < 0, daily11[daily1IT + i] < 0, daily17[daily1IW + i] < 0, daily11[daily1IZ + i] < 0,
          daily11[daily1JC + i] < 0, daily11[daily1JF + i] < 0, daily11[daily1JI + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1IQ + i] / (daily11[daily1IQ + i] - daily11[daily1IR + i]), 1),
          ifFinite(daily11[daily1IT + i] / (daily11[daily1IT + i] - daily11[daily1IU + i]), 1),
          ifFinite(daily17[daily1IW + i] / (daily17[daily1IW + i] - daily11[daily1IX + i]), 1),
          ifFinite(daily11[daily1IZ + i] / (daily11[daily1IZ + i] - daily11[daily1JA + i]), 1),
          ifFinite(daily11[daily1JC + i] / (daily11[daily1JC + i] - daily11[daily1JD + i]), 1),
          ifFinite(daily11[daily1JF + i] / (daily11[daily1JF + i] - daily17[daily1JG + i]), 1),
          ifFinite(daily11[daily1JI + i] / (daily11[daily1JI + i] - daily17[daily1JJ + i]), 1))
          * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let daily1KE = 13870
    // IF(KD6=0,0,ROUND((FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KE + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FS + i]
            + (daily16[daily1HO + i] - daily15[daily1FS + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (daily15[daily1GE + i]
              + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let daily1KF = 14235
    // IF(KD6=0,0,ROUND((FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KF + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FT + i]
            + (daily16[daily1HP + i] - daily15[daily1FT + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (daily15[daily1GF + i]
              + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FW + i]
                  + (daily11[daily1HS + i] - daily15[daily1FW + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let daily1KG = 14600
    // IF(KD6=0,0,ROUND((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KG + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FV + i]
            + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (daily15[daily1FS + i]
                + (daily16[daily1HO + i] - daily15[daily1FS + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                + (daily15[daily1GE + i]
                  + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - ((daily15[daily1FR + i]
                  + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let daily1KH = 14965
    // IF(KD6=0,0,ROUND((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KH + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FW + i]
            + (daily11[daily1HS + i] - daily15[daily1FW + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (daily15[daily1FT + i]
                + (daily16[daily1HP + i] - daily15[daily1FT + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                + (daily15[daily1GF + i]
                  + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - ((daily15[daily1FR + i]
                  + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let daily1KI = 15330
    // IF(KD6=0,0,ROUND((GH6+(ID6-GH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1KI + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GH + i]
            + (daily11[daily1ID + i] - daily11[daily1GH + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - ((daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FV + i]
                + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let daily1KJ = 15695
    // IF(KD6=0,0,ROUND((GI6+(IE6-GI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1KJ + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GI + i]
            + (daily11[daily1IE + i] - daily15[daily1GI + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - ((daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let daily1KK = 16060
    // IF(KD6=0,0,ROUND((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KK + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let daily1KL = 16425
    // IF(KD6=0,0,ROUND((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KL + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FZ + i]
            + (daily16[daily1HV + i] - daily15[daily1FZ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let daily1KM = 16790
    // IF(KD6=0,0,ROUND((GK6+(IG6-GK6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KM + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GK + i]
            + (daily11[daily1IG + i] - daily11[daily1GK + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AD + i]
              + (daily10[daily1AE + i] - daily10[daily1AD + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let daily1KN = 17155
    // IF(KD6=0,0,ROUND((GL6+(IH6-GL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KN + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GL + i]
            + (daily11[daily1IH + i] - daily15[daily1GL + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AD + i]
              + (daily10[daily1AE + i] - daily10[daily1AD + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let daily1KO = 17520
    // IF(KD6=0,0,ROUND((GN6+(IJ6-GN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KO + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GN + i]
            + (daily11[daily1IJ + i] - daily15[daily1GN + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AF + i]
              + (daily10[daily1AG + i] - daily10[daily1AF + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let daily1KP = 17885
    // IF(KD6=0,0,ROUND((GO6+(IK6-GO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KP + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GO + i]
            + (daily11[daily1IK + i] - daily15[daily1GO + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AF + i]
              + (daily10[daily1AG + i] - daily10[daily1AF + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let daily1KQ = 18250
    // IF(KD6=0,0,ROUND((GQ6+(IM6-GQ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KQ + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GQ + i]
            + (daily11[daily1IM + i] - daily11[daily1GQ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let daily1KR = 18615
    // IF(KD6=0,0,ROUND((GR6+(IN6-GR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KR + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GR + i]
            + (daily11[daily1IN + i] - daily11[daily1GR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let daily1KS = 18980
    // IF(KD6<=0,0,MIN(1,IFERROR(KE6/(KE6-KF6),1),IFERROR(KG6/(KG6-KH6),1),IFERROR(KI6/(KI6-KJ6),1),IFERROR(KK6/(KK6-KL6),1),IFERROR(KM6/(KM6-KN6),1),IFERROR(KO6/(KO6-KP6),1),IFERROR(KQ6/(KQ6-KR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KS + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        min(
          1, ifFinite(daily11[daily1KE + i] / (daily11[daily1KE + i] - daily11[daily1KF + i]), 1),
          ifFinite(daily17[daily1KG + i] / (daily17[daily1KG + i] - daily11[daily1KH + i]), 1),
          ifFinite(daily11[daily1KI + i] / (daily11[daily1KI + i] - daily11[daily1KJ + i]), 1),
          ifFinite(daily11[daily1KK + i] / (daily11[daily1KK + i] - daily11[daily1KL + i]), 1),
          ifFinite(daily17[daily1KM + i] / (daily17[daily1KM + i] - daily11[daily1KN + i]), 1),
          ifFinite(daily11[daily1KO + i] / (daily11[daily1KO + i] - daily11[daily1KP + i]), 1),
          ifFinite(daily11[daily1KQ + i] / (daily11[daily1KQ + i] - daily11[daily1KR + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period
    let daily1KU = 19345
    // IF(OR(JM6=0,KB6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KU + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FC + i]
          + (daily16[daily1GY + i] - daily15[daily1FC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FD + i]
            + (daily11[daily1GZ + i] - daily15[daily1FD + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FC + i]
              + (daily16[daily1GY + i] - daily15[daily1FC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily1KV = 19710
    // IF(OR(JM6=0,KB6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1KV + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let daily1KW = 20075
    // IF(OR(JM6=0,KB6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KW + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FO + i] + (daily16[daily1HK + i] - daily15[daily1FO + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let daily1KX = 20440
    // IF(OR(JM6=0,KB6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      daily17[daily1KX + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        min(
          ((daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            + ((daily15[daily1FZ + i]
              + (daily16[daily1HV + i] - daily15[daily1FZ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FY + i]
                + (daily16[daily1HU + i] - daily15[daily1FY + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc)),
          (daily15[daily1FR + i]
            + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let daily1KY = 20805
    // IF(OR(JM6=0,KB6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KY + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FL + i]
          + (daily16[daily1HH + i] - daily15[daily1FL + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FM + i]
            + (daily16[daily1HI + i] - daily15[daily1FM + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FL + i]
              + (daily16[daily1HH + i] - daily15[daily1FL + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let daily1KZ = 21170
    // LH6/El_boiler_eff
    // for i in 0..<365 { daily17[daily1KZ + i] = daily11[daily1LH + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let daily1LA = 21535
    // IF(OR(JM6=0,KB6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LA + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1EY + i] + (daily16[daily1GU + i] - daily11[daily1EY + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let daily1LB = 21900
    // IF(OR(JM6=0,KB6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LB + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FI + i]
          + (daily16[daily1HE + i] - daily15[daily1FI + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FJ + i]
            + (daily11[daily1HF + i] - daily15[daily1FJ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FI + i]
              + (daily16[daily1HE + i] - daily15[daily1FI + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let daily1LC = 22265
    // IF(OR(JM6=0,KB6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc),MAX(0,-(LA6+LB6-KU6-KV6-KW6-KX6-KY6-KZ6))))
    for i in 0..<365 {
      daily17[daily1LC + i] = iff(
      or(
     daily17[daily1JM + i].isZero,daily11[daily1KB + i].isZero),0, min((daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])) + ((daily15[daily1GF + i] + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])) - (daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc),max(0, -(daily11[daily1LA + i] + daily11[daily1LB + i] - daily11[daily1KU + i] - daily11[daily1KV + i] - daily11[daily1KW + i] - daily17[daily1KX + i] - daily17[daily1KY + i] - daily11[daily1KZ + i]))))
    }

    /// Balance of electricity during harm op period
    let daily1LD = 22630
    // LA6+LB6+LC6-KU6-KV6-KW6-KX6-KY6-KZ6
    for i in 0..<365 {
      daily17[daily1LD + i] =
        daily11[daily1LA + i] + daily11[daily1LB + i] + daily11[daily1LC + i] - daily11[daily1KU + i] - daily11[daily1KV + i]
        - daily11[daily1KW + i] - daily17[daily1KX + i] - daily17[daily1KY + i] - daily11[daily1KZ + i]
    }

    /// heat cons for harm op during harm op period
    let daily1LE = 22995
    // IF(OR(JM6=0,KB6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LE + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FF + i]
          + (daily16[daily1HB + i] - daily15[daily1FF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FG + i]
            + (daily11[daily1HC + i] - daily15[daily1FG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FF + i]
              + (daily16[daily1HB + i] - daily15[daily1FF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let daily1LF = 23360
    // IF(OR(JM6=0,KB6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LF + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily10[daily1AB + i]
          + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let daily1LG = 23725
    // IF(OR(JM6=0,KB6=0),0,KY6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1LG + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0, daily17[daily1KY + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let daily1LH = 24090
    // IF(OR(JM6=0,KB6=0),0,MAX(0,LF6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily17[daily1LH + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        max(
          0,
          daily11[daily1LF + i]
            - ((daily15[daily1FV + i]
              + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              + ((daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let daily1LI = 24455
    // IF(OR(JM6=0,KB6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LI + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1FA + i] + (daily11[daily1GW + i] - daily11[daily1FA + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let daily1LJ = 24820
    // LG6+LH6+LI6-LE6-LF6
    for i in 0..<365 {
      daily17[daily1LJ + i] =
        daily11[daily1LG + i] + daily11[daily1LH + i] + daily11[daily1LI + i] - daily11[daily1LE + i] - daily11[daily1LF + i]
    }

    /// el cons for harm op outside of harm op period
    let daily1LK = 25185
    // IF(OR(JM6=0,KB6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LK + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FE + i] + (daily11[daily1HA + i] - daily15[daily1FE + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let daily1LL = 25550
    // IF(OR(JM6=0,KB6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LL + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FP + i] + (daily11[daily1HL + i] - daily15[daily1FP + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let daily1LM = 25915
    // IF(OR(JM6=0,KB6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LM + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FN + i] + (daily11[daily1HJ + i] - daily15[daily1FN + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let daily1LN = 26280
    // KX6*BESS_chrg_eff
    for i in 0..<365 { daily17[daily1LN + i] = daily17[daily1KX + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let daily1LO = 26645
    // IF(OR(JM6=0,KB6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LO + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1EZ + i] + (daily11[daily1GV + i] - daily11[daily1EZ + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let daily1LP = 27010
    // IF(OR(JM6=0,KB6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc),MAX(0,-(LN6+LO6-LK6-LL6-LM6))))
    for i in 0..<365 {
      daily17[daily1LP + i] = iff(
      or(
     daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0, min(daily15[daily1GG + i] + (daily11[daily1IC + i] - daily15[daily1GG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]),max(0, -(daily17[daily1LN + i] + daily11[daily1LO + i] - daily11[daily1LK + i] - daily11[daily1LL + i] - daily11[daily1LM + i]))))
    }

    /// Balance of electricity outside of harm op period
    let daily1LQ = 27375
    // LN6+LO6+LP6-LK6-LL6-LM6
    for i in 0..<365 {
      daily17[daily1LQ + i] =
        daily17[daily1LN + i] + daily11[daily1LO + i] + daily11[daily1LP + i] - daily11[daily1LK + i] - daily11[daily1LL + i]
        - daily11[daily1LM + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily1LR = 27740
    // IF(OR(JM6=0,KB6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LR + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FH + i] + (daily11[daily1HD + i] - daily15[daily1FH + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let daily1LS = 28105
    // IF(OR(JM6=0,KB6=0),0,LM6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1LS + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0, daily11[daily1LM + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let daily1LT = 28470
    // IF(OR(JM6=0,KB6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LT + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FB + i] + (daily11[daily1GX + i] - daily15[daily1FB + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let daily1LU = 28835
    // LS6+LT6-LR6
    for i in 0..<365 { daily17[daily1LU + i] = daily17[daily1LS + i] + daily11[daily1LT + i] - daily11[daily1LR + i] }

    /// Pure Methanol prod with day priority and resp night op
    let daily1LV = 29200
    // IF(KU6<=0,0,KU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(LK6<=0,0,(LK6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily17[daily1LV + i] =
        iff(
          daily11[daily1KU + i] <= 0, 0,
          daily11[daily1KU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          daily11[daily1LK + i] <= 0, 0,
          (daily11[daily1LK + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let daily1LW = 29565
    // MIN(LD6,IF(OR(JM6=0,KB6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))+MIN(LQ6,IF(OR(JM6=0,KB6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LW + i] =
        min(
          daily11[daily1LD + i],
          iff(
            or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
            (daily11[daily1GB + i]
              + (daily16[daily1HX + i] - daily11[daily1GB + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              + ((daily11[daily1GC + i]
                + (daily11[daily1HY + i] - daily11[daily1GC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1GB + i]
                  + (daily16[daily1HX + i] - daily11[daily1GB + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc)))
        + min(
          daily17[daily1LQ + i],
          iff(
            or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
            daily15[daily1GD + i] + (daily16[daily1HZ + i] - daily15[daily1GD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let daily1LX = 29930
    // LP6+LC6
    for i in 0..<365 { daily17[daily1LX + i] = daily11[daily1LP + i] + daily11[daily1LC + i] }

    /// Outside harmonious operation period hours
    let daily1LY = 30295
    // IF(KB6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LY + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1C + i]
          + (daily11[daily1T + i] - daily11[daily1C + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let daily1LZ = 30660
    // IF(KB6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LZ + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1D + i]
          + (daily11[daily1U + i] - daily11[daily1D + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let daily1MA = 31025
    // IF(KB6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1MA + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1E + i]
          + (daily11[daily1V + i] - daily11[daily1E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let daily1MB = 31390
    // MAX(0,-LD6)+MAX(0,-LJ6)+MAX(0,-LQ6)+MAX(0,-LU6)
    for i in 0..<365 {
      daily17[daily1MB + i] =
        max(0, -daily11[daily1LD + i]) + max(0, -daily11[daily1LJ + i]) + max(0, -daily17[daily1LQ + i])
        + max(0, -daily11[daily1LU + i])
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////

    /// el cons for harm op during harm op period
    let daily1MD = 31755
    // IF(OR(KS6=0,KD6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MD + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FC + i]
          + (daily16[daily1GY + i] - daily15[daily1FC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FD + i]
            + (daily11[daily1GZ + i] - daily15[daily1FD + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FC + i]
              + (daily16[daily1GY + i] - daily15[daily1FC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily1ME = 32120
    // IF(OR(KS6=0,KD6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1ME + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let daily1MF = 32485
    // IF(OR(KS6=0,KD6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MF + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FO + i] + (daily16[daily1HK + i] - daily15[daily1FO + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let daily1MG = 32850
    // IF(OR(KS6=0,KD6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      daily17[daily1MG + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        min(
          ((daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + ((daily15[daily1FZ + i]
              + (daily16[daily1HV + i] - daily15[daily1FZ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FY + i]
                + (daily16[daily1HU + i] - daily15[daily1FY + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1KS + i] - Overall_harmonious_min_perc)),
          (daily15[daily1FR + i]
            + (daily16[daily1HN + i] - daily15[daily1FR + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let daily1MH = 33215
    // IF(OR(KS6=0,KD6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MH + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FL + i]
          + (daily16[daily1HH + i] - daily15[daily1FL + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FM + i]
            + (daily16[daily1HI + i] - daily15[daily1FM + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FL + i]
              + (daily16[daily1HH + i] - daily15[daily1FL + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let daily1MI = 33580
    // MQ6/El_boiler_eff
    // for i in 0..<365 { daily17[daily1MI + i] = daily11[daily1MQ + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let daily1MJ = 33945
    // IF(OR(KS6=0,KD6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MJ + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1EY + i] + (daily16[daily1GU + i] - daily11[daily1EY + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let daily1MK = 34310
    // IF(OR(KD6=0,KS6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MK + i] = iff(
        or(daily11[daily1KD + i].isZero, daily11[daily1KS + i].isZero), 0,
        (daily15[daily1FI + i]
          + (daily16[daily1HE + i] - daily15[daily1FI + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FJ + i]
            + (daily11[daily1HF + i] - daily15[daily1FJ + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FI + i]
              + (daily16[daily1HE + i] - daily15[daily1FI + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let daily1ML = 34675
    // IF(OR(KD6=0,KS6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc),MAX(0,-(MJ6+MK6-MD6-ME6-MF6-MG6-MH6-MI6))))
    for i in 0..<365 {
      daily17[daily1ML + i] = iff(
      or(
     daily11[daily1KD + i].isZero, daily11[daily1KS + i].isZero),0, min((daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])) + ((daily15[daily1GF + i] + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])) - (daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc),max(0, -(daily11[daily1MJ + i] + daily11[daily1MK + i] - daily11[daily1MD + i] - daily11[daily1ME + i] - daily17[daily1MF + i] - daily11[daily1MG + i] - daily11[daily1MH + i] - daily11[daily1MI + i]))))
    }

    /// Balance of electricity during harm op period
    let daily1MM = 35040
    // MJ6+MK6+ML6-MD6-ME6-MF6-MG6-MH6-MI6
    for i in 0..<365 {
      daily17[daily1MM + i] =
        daily11[daily1MJ + i] + daily11[daily1MK + i] + daily11[daily1ML + i] - daily11[daily1MD + i] - daily11[daily1ME + i]
        - daily17[daily1MF + i] - daily11[daily1MG + i] - daily11[daily1MH + i] - daily11[daily1MI + i]
    }

    /// heat cons for harm op during harm op period
    let daily1MN = 35405
    // IF(OR(KS6=0,KD6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MN + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FF + i]
          + (daily16[daily1HB + i] - daily15[daily1FF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FG + i]
            + (daily11[daily1HC + i] - daily15[daily1FG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FF + i]
              + (daily16[daily1HB + i] - daily15[daily1FF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let daily1MO = 35770
    // IF(OR(KS6=0,KD6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1MO + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily10[daily1AB + i]
          + (daily10[daily1AC + i] - daily10[daily1AB + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let daily1MP = 36135
    // IF(OR(KS6=0,KD6=0),0,MH6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1MP + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0, daily11[daily1MH + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let daily1MQ = 36500
    // IF(OR(KS6=0,KD6=0),0,MAX(0,MO6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily17[daily1MQ + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        max(
          0,
          daily11[daily1MO + i]
            - ((daily15[daily1FV + i]
              + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              + ((daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let daily1MR = 36865
    // IF(OR(KS6=0,KD6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MR + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1FA + i] + (daily11[daily1GW + i] - daily11[daily1FA + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let daily1MS = 37230
    // MP6+MQ6+MR6-MN6-MO6
    for i in 0..<365 {
      daily17[daily1MS + i] =
        daily11[daily1MP + i] + daily17[daily1MQ + i] + daily11[daily1MR + i] - daily11[daily1MN + i] - daily11[daily1MO + i]
    }

    /// el cons for harm op outside of harm op period
    let daily1MT = 37595
    // IF(OR(KS6=0,KD6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MT + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FE + i] + (daily11[daily1HA + i] - daily15[daily1FE + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let daily1MU = 37960
    // IF(OR(KS6=0,KD6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MU + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FP + i] + (daily11[daily1HL + i] - daily15[daily1FP + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let daily1MV = 38325
    // IF(OR(KS6=0,KD6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MV + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FN + i] + (daily11[daily1HJ + i] - daily15[daily1FN + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let daily1MW = 38690
    // MG6*BESS_chrg_eff
    for i in 0..<365 { daily17[daily1MW + i] = daily11[daily1MG + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let daily1MX = 39055
    // IF(OR(KS6=0,KD6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MX + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1EZ + i] + (daily11[daily1GV + i] - daily11[daily1EZ + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let daily1MY = 39420
    // IF(OR(KS6=0,KD6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc),MAX(0,-(MW6+MX6-MT6-MU6-MV6))))
    for i in 0..<365 {
      daily17[daily1MY + i] = iff(
      or(
     daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero),0, min(daily15[daily1GG + i] + (daily11[daily1IC + i] - daily15[daily1GG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]),max(0, -(daily11[daily1MW + i] + daily11[daily1MX + i] - daily11[daily1MT + i] - daily11[daily1MU + i] - daily17[daily1MV + i]))))
    }

    /// Balance of electricity outside of harm op period
    let daily1MZ = 39785
    // MW6+MX6+MY6-MT6-MU6-MV6
    for i in 0..<365 {
      daily17[daily1MZ + i] =
        daily11[daily1MW + i] + daily11[daily1MX + i] + daily11[daily1MY + i] - daily11[daily1MT + i] - daily11[daily1MU + i]
        - daily17[daily1MV + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily1NA = 40150
    // IF(OR(KS6=0,KD6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1NA + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FH + i] + (daily11[daily1HD + i] - daily15[daily1FH + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let daily1NB = 40515
    // IF(OR(KS6=0,KD6=0),0,MV6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1NB + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0, daily17[daily1MV + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let daily1NC = 40880
    // IF(OR(KS6=0,KD6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1NC + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FB + i] + (daily11[daily1GX + i] - daily15[daily1FB + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let daily1ND = 41245
    // NB6+NC6-NA6
    for i in 0..<365 { daily17[daily1ND + i] = daily11[daily1NB + i] + daily11[daily1NC + i] - daily11[daily1NA + i] }

    /// Pure Methanol prod with night priority and resp day op
    let daily1NE = 41610
    // IF(MD6<=0,0,MD6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(MT6<=0,0,(MT6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily17[daily1NE + i] =
        iff(
          daily11[daily1MD + i] <= 0, 0,
          daily11[daily1MD + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          daily11[daily1MT + i] <= 0, 0,
          (daily11[daily1MT + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// Grid export
    let daily1NF = 41975
    // MIN(MM6,IF(OR(KS6=0,KD6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)))+MIN(MZ6,IF(OR(KS6=0,KD6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NF + i] =
        min(
          daily11[daily1MM + i],
          iff(
            or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
            (daily11[daily1GB + i]
              + (daily16[daily1HX + i] - daily11[daily1GB + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              + ((daily11[daily1GC + i]
                + (daily11[daily1HY + i] - daily11[daily1GC + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1GB + i]
                  + (daily16[daily1HX + i] - daily11[daily1GB + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1KS + i] - Overall_harmonious_min_perc)))
        + min(
          daily17[daily1MZ + i],
          iff(
            or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
            daily15[daily1GD + i] + (daily16[daily1HZ + i] - daily15[daily1GD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let daily1NG = 42340
    // MY6+ML6
    for i in 0..<365 { daily17[daily1NG + i] = daily11[daily1MY + i] + daily11[daily1ML + i] }

    /// Outside harmonious operation period hours
    let daily1NH = 42705
    // IF(KD6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NH + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1C + i]
          + (daily11[daily1T + i] - daily11[daily1C + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let daily1NI = 43070
    // IF(KD6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NI + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1D + i]
          + (daily11[daily1U + i] - daily11[daily1D + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let daily1NJ = 43435
    // IF(KD6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NJ + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1E + i]
          + (daily11[daily1V + i] - daily11[daily1E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let daily1NK = 43800
    // MAX(0,-MM6)+MAX(0,-MS6)+MAX(0,-MZ6)+MAX(0,-ND6)
    for i in 0..<365 {
      daily17[daily1NK + i] =
        max(0, -daily11[daily1MM + i]) + max(0, -daily17[daily1MS + i]) + max(0, -daily17[daily1MZ + i])
        + max(0, -daily11[daily1ND + i])
    }
    return daily17
  }
}