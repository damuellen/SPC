extension TunOl {
  mutating func daily1(hourly0: [Double]) {
    let daysA: [[Int]] = hourly0[0..<(8760)].indices.chunked(by: { hourly0[$0] == hourly0[$1] }).map { $0.map { $0 } }
    let daysU: [[Int]] = hourly0[113880..<(113880 + 8760)].indices.chunked(by: { hourly0[$0] == hourly0[$1] })
      .map { $0.map { $0 - 113880 } }
    let hourlyD = 0
    let hourlyH = 8760
    let hourlyI = 17520
    let hourlyJ = 26280
    let hourlyK = 35040
    let hourlyL = 43800
    let hourlyM = 52560
    let hourlyO = 61320
    let hourlyP = 70080
    let hourlyQ = 78840
    let hourlyR = 87600
    let hourlyS = 96360
    let hourlyT = 105120
    let hourlyU = 113880
    let hourlyV = 122640
    let hourlyW = 131400
    let hourlyX = 140160
    let hourlyY = 148920
    let hourlyZ = 157680
    let hourlyAA = 166440
    let hourlyAB = 175200
    let hourlyAC = 183960
    let hourlyAD = 192720
    let hourlyAE = 201480
    let hourlyAF = 210240
    let hourlyAG = 219000
    let hourlyAH = 227760
    let hourlyAI = 236520
    let hourlyAJ = 245280
    let hourlyAK = 254040
    let hourlyAL = 262800
    let hourlyAM = 271560
    let hourlyAN = 280320
    let hourlyAO = 289080
    let hourlyAP = 297840
    let hourlyAQ = 306600
    let hourlyAR = 315360
    let hourlyAS = 324120
    let hourlyAT = 332880
    let S_UcountZero = hourly0.countOf(hourlyU, days: daysA, condition: hourlyS, predicate: { $0 <= 0 })
    let S_UcountNonZero = hourly0.countOf(hourlyU, days: daysA, condition: hourlyS, predicate: { $0 > 0 })
    let U_S_Psum = hourly0.sumOf(hourlyP, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_T_Jsum = hourly0.sumOf(hourlyJ, days: daysU, condition: hourlyT, predicate: { $0 > 0 })
    let U_S_AFsum = hourly0.sumOf(hourlyAF, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_S_ATsum = hourly0.sumOf(hourlyAT, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_S_Xsum = hourly0.sumOf(hourlyX, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_ALsum = hourly0.sumOf(hourlyAL, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_Vsum = hourly0.sumOf(hourlyV, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_AJsum = hourly0.sumOf(hourlyAJ, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_Wsum = hourly0.sumOf(hourlyW, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_AKsum = hourly0.sumOf(hourlyAK, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_Ysum = hourly0.sumOf(hourlyY, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_AMsum = hourly0.sumOf(hourlyAM, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_AEsum = hourly0.sumOf(hourlyAE, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_ASsum = hourly0.sumOf(hourlyAS, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_AEsumZero = hourly0.sumOf(hourlyAE, days: daysU, condition: hourlyS, predicate: { $0.isZero })
    let U_S_Zsum = hourly0.sumOf(hourlyZ, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_S_ANsum = hourly0.sumOf(hourlyAN, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_S_AAsum = hourly0.sumOf(hourlyAA, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_AOsum = hourly0.sumOf(hourlyAO, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_ABsum = hourly0.sumOf(hourlyAB, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_APsum = hourly0.sumOf(hourlyAP, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_ACsum = hourly0.sumOf(hourlyAC, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_AQsum = hourly0.sumOf(hourlyAQ, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })
    let U_S_ADsum = hourly0.sumOf(hourlyAD, days: daysU, condition: hourlyS, predicate: { $0 > 0 })
    let U_AH_ARsum = hourly0.sumOf(hourlyAR, days: daysU, condition: hourlyAH, predicate: { $0 > 0 })

    let Psum = hourly0.sum(days: daysU, range: hourlyP)
    let Jsum = hourly0.sum(days: daysU, range: hourlyJ)
    let Ssum = hourly0.sum(days: daysU, range: hourlyS)
    let Tsum = hourly0.sum(days: daysU, range: hourlyT)
    let AIsum = hourly0.sum(days: daysU, range: hourlyAI)
    let AFsum = hourly0.sum(days: daysU, range: hourlyAF)
    let Xsum = hourly0.sum(days: daysU, range: hourlyX)
    let Ysum = hourly0.sum(days: daysU, range: hourlyY)
    let Vsum = hourly0.sum(days: daysU, range: hourlyV)
    let Wsum = hourly0.sum(days: daysU, range: hourlyW)

    let AAsum = hourly0.sum(days: daysU, range: hourlyAA)
    let ABsum = hourly0.sum(days: daysU, range: hourlyAB)
    let ACsum = hourly0.sum(days: daysU, range: hourlyAC)
    let ADsum = hourly0.sum(days: daysU, range: hourlyAD)
    let AHsum = hourly0.sum(days: daysU, range: hourlyAH)
    var daily20 = [Double](repeating: 0, count: 1_095)
    /// Day
    let daily2A = 0
    // A5+1
    for i in 0..<365 { daily20[daily2A + i] = daily20[daily2A + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    let daily2B = 365
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,"<=0")
    for i in 0..<365 { daily20[daily2B + i] = S_UcountZero[i] }

    /// Nr of hours where min harmonious is possible considering grid support
    let daily2C = 730
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily20[daily2C + i] = S_UcountNonZero[i] }

    var daily21 = [Double](repeating: 0, count: 9_855)
    let j = 0
    /// Min el cons during night
    let daily2E = 0
    // (A_overall_var_min_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      daily21[daily2E + i] = (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * daily20[daily2B + i] + overall_stup_cons[j]
    }

    /// Max el cons during night
    let daily2F = 365
    // (A_overall_var_max_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      daily21[daily2F + i] = (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * daily20[daily2B + i] + overall_stup_cons[j]
    }

    /// Min heat cons during night
    let daily2G = 730
    // (A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      daily21[daily2G + i] =
        (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * daily20[daily2B + i] + overall_heat_stup_cons[j]
    }

    /// Max heat cons during night
    let daily2H = 1095
    // (A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      daily21[daily2H + i] =
        (overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]) * daily20[daily2B + i] + overall_heat_stup_cons[j]
    }

    /// Min RawMeth cons during night
    let daily2I = 1460
    // A_RawMeth_min_cons*B6
    for i in 0..<365 { daily21[daily2I + i] = RawMeth_min_cons[j] * daily20[daily2B + i] }

    /// Max RawMeth cons during night
    let daily2J = 1825
    // A_RawMeth_max_cons*B6
    for i in 0..<365 { daily21[daily2J + i] = RawMeth_max_cons[j] * daily20[daily2B + i] }

    /// Min CO2 cons during night
    let daily2K = 2190
    // A_CO2_min_cons*B6
    for i in 0..<365 { daily21[daily2K + i] = C_O_2_min_cons[j] * daily20[daily2B + i] }

    /// Max CO2 cons during night
    let daily2L = 2555
    // A_CO2_max_cons*B6
    for i in 0..<365 { daily21[daily2L + i] = C_O_2_max_cons[j] * daily20[daily2B + i] }

    /// Min H2 cons during night
    let daily2M = 2920
    // A_Hydrogen_min_cons*B6
    for i in 0..<365 { daily21[daily2M + i] = Hydrogen_min_cons[j] * daily20[daily2B + i] }

    /// Max H2 cons during night
    let daily2N = 3285
    // A_Hydrogen_max_cons*B6
    for i in 0..<365 { daily21[daily2N + i] = Hydrogen_max_cons[j] * daily20[daily2B + i] }

    /// Min el cons during day for night op prep
    let daily2O = 3650
    // (M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+I6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily21[daily2O + i] =
        (daily21[daily2M + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily21[daily2K + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily21[daily2I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily2P = 4015
    // (N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+J6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily21[daily2P + i] =
        (daily21[daily2N + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily21[daily2L + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily21[daily2J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily2Q = 4380
    // (M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-I6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily21[daily2Q + i] =
        (daily21[daily2M + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily21[daily2K + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily21[daily2I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - daily20[daily2C + i]
        * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily2R = 4745
    // (N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-J6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily21[daily2R + i] =
        (daily21[daily2N + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily21[daily2L + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily21[daily2J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - daily20[daily2C + i]
        * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily2S = 5110
    // I6
    for i in 0..<365 { daily21[daily2S + i] = daily21[daily2I + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily2T = 5475
    // J6
    for i in 0..<365 { daily21[daily2T + i] = daily21[daily2J + i] }

    /// Min CO2 prod during day for night op prep
    let daily2U = 5840
    // K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily21[daily2U + i] =
        daily21[daily2K + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily2V = 6205
    // L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily21[daily2V + i] =
        daily21[daily2L + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily2W = 6570
    // M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily21[daily2W + i] =
        daily21[daily2M + i] + daily21[daily2I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily2X = 6935
    // N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily21[daily2X + i] =
        daily21[daily2N + i] + daily21[daily2J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily2Y = 7300
    // 1-I6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily21[daily2Y + i] = 1 - daily21[daily2I + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily2Z = 7665
    // 1-J6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily21[daily2Z + i] = 1 - daily21[daily2J + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily2AA = 8030
    // 1-K6/CO2_storage_cap_ud
    for i in 0..<365 { daily21[daily2AA + i] = 1 - daily21[daily2K + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily2AB = 8395
    // 1-L6/CO2_storage_cap_ud
    for i in 0..<365 { daily21[daily2AB + i] = 1 - daily21[daily2L + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily2AC = 8760
    // 1-M6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily21[daily2AC + i] = 1 - daily21[daily2M + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily2AD = 9125
    // 1-N6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily21[daily2AD + i] = 1 - daily21[daily2N + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let daily2AE = 9490
    // IF(OR(Y6<=0,AA6<=0,AC6<=0),0,MIN(1,IFERROR(Y6/(Y6-Z6),1),IFERROR(AA6/(AA6-AB6),1),IFERROR(AC6/(AC6-AD6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily21[daily2AE + i] = iff(
        or(daily21[daily2Y + i] <= 0, daily21[daily2AA + i] <= 0, daily21[daily2AC + i] <= 0), 0,
        min(
          1, ifFinite(daily21[daily2Y + i] / (daily21[daily2Y + i] - daily21[daily2Z + i]), 1),
          ifFinite(daily21[daily2AA + i] / (daily21[daily2AA + i] - daily21[daily2AB + i]), 1),
          ifFinite(daily21[daily2AC + i] / (daily21[daily2AC + i] - daily21[daily2AD + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    /*
    var daily22 = [Double]()

    /// Min el cons during night
    let daily2AG = 0
    // (B_overall_var_min_cons+B_overall_fix_stby_cons)*B6+B_overall_stup_cons
    for i in 0..<365 {
      daily22[daily2AG + i] =
        (B_overall_var_min_cons + B_overall_fix_stby_cons) * daily20[daily2B + i]
        + B_overall_stup_cons
    }

    /// Max el cons during night
    let daily2AH = 365
    // (B_overall_var_max_cons+B_overall_fix_stby_cons)*B6+B_overall_stup_cons
    for i in 0..<365 {
      daily22[daily2AH + i] =
        (B_overall_var_max_cons + B_overall_fix_stby_cons) * daily20[daily2B + i]
        + B_overall_stup_cons
    }

    /// Min heat cons during night
    let daily2AI = 730
    // (B_overall_var_heat_min_cons+B_overall_heat_fix_stby_cons)*B6+B_overall_heat_stup_cons
    for i in 0..<365 {
      daily22[daily2AI + i] =
        (B_overall_var_heat_min_cons + B_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + B_overall_heat_stup_cons
    }

    /// Max heat cons during night
    let daily2AJ = 1095
    // (B_overall_var_heat_max_cons+B_overall_heat_fix_stby_cons)*B6+B_overall_heat_stup_cons
    for i in 0..<365 {
      daily22[daily2AJ + i] =
        (B_overall_var_heat_max_cons + B_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + B_overall_heat_stup_cons
    }

    /// Min RawMeth cons during night
    let daily2AK = 1460
    // B_RawMeth_min_cons*B6
    for i in 0..<365 { daily22[daily2AK + i] = B_RawMeth_min_cons * daily20[daily2B + i] }

    /// Max RawMeth cons during night
    let daily2AL = 1825
    // B_RawMeth_max_cons*B6
    for i in 0..<365 { daily22[daily2AL + i] = B_RawMeth_max_cons * daily20[daily2B + i] }

    /// Min CO2 cons during night
    let daily2AM = 2190
    // B_CO2_min_cons*B6
    for i in 0..<365 { daily22[daily2AM + i] = B_C_O_2_min_cons * daily20[daily2B + i] }

    /// Max CO2 cons during night
    let daily2AN = 2555
    // B_CO2_max_cons*B6
    for i in 0..<365 { daily22[daily2AN + i] = B_C_O_2_max_cons * daily20[daily2B + i] }

    /// Min H2 cons during night
    let daily2AO = 2920
    // B_Hydrogen_min_cons*B6
    for i in 0..<365 { daily22[daily2AO + i] = B_Hydrogen_min_cons * daily20[daily2B + i] }

    /// Max H2 cons during night
    let daily2AP = 3285
    // B_Hydrogen_max_cons*B6
    for i in 0..<365 { daily22[daily2AP + i] = B_Hydrogen_max_cons * daily20[daily2B + i] }

    /// Min el cons during day for night op prep
    let daily2AQ = 3650
    // (AO6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(AM6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+AK6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily22[daily2AQ + i] =
        (daily22[daily2AO + i] + daily22[daily2AK + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily22[daily2AM + i] + daily22[daily2AK + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily22[daily2AK + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily2AR = 4015
    // (AP6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(AN6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+AL6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily22[daily2AR + i] =
        (daily22[daily2AP + i] + daily22[daily2AL + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily20[daily2AN + i] + daily22[daily2AL + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily22[daily2AL + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily2AS = 4380
    // (AO6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(AM6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-AK6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily22[daily2AS + i] =
        (daily22[daily2AO + i] + daily22[daily2AK + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily22[daily2AM + i] + daily22[daily2AK + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily22[daily2AK + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily2AT = 4745
    // (AP6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(AN6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-AL6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily22[daily2AT + i] =
        (daily22[daily2AP + i] + daily22[daily2AL + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily20[daily2AN + i] + daily22[daily2AL + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily22[daily2AL + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily2AU = 5110
    // AK6
    for i in 0..<365 { daily22[daily2AU + i] = daily22[daily2AK + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily2AV = 5475
    // AL6
    for i in 0..<365 { daily22[daily2AV + i] = daily22[daily2AL + i] }

    /// Min CO2 prod during day for night op prep
    let daily2AW = 5840
    // AM6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily22[daily2AW + i] =
        daily22[daily2AM + i] + daily22[daily2AK + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily2AX = 6205
    // AN6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily22[daily2AX + i] =
        daily20[daily2AN + i] + daily22[daily2AL + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily2AY = 6570
    // AO6+AK6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily22[daily2AY + i] =
        daily22[daily2AO + i] + daily22[daily2AK + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily2AZ = 6935
    // AP6+AL6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily22[daily2AZ + i] =
        daily22[daily2AP + i] + daily22[daily2AL + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily2BA = 7300
    // 1-AK6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily22[daily2BA + i] = 1 - daily22[daily2AK + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily2BB = 7665
    // 1-AL6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily22[daily2BB + i] = 1 - daily22[daily2AL + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily2BC = 8030
    // 1-AM6/CO2_storage_cap_ud
    for i in 0..<365 { daily22[daily2BC + i] = 1 - daily22[daily2AM + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily2BD = 8395
    // 1-AN6/CO2_storage_cap_ud
    for i in 0..<365 { daily22[daily2BD + i] = 1 - daily20[daily2AN + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily2BE = 8760
    // 1-AO6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily22[daily2BE + i] = 1 - daily22[daily2AO + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily2BF = 9125
    // 1-AP6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily22[daily2BF + i] = 1 - daily22[daily2AP + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily2BG = 9490
    // IF(OR(BA6<=0,BC6<=0,BE6<=0),0,MIN(1,IFERROR(BA6/(BA6-BB6),1),IFERROR(BC6/(BC6-BD6),1),IFERROR(BE6/(BE6-BF6),1))*(B_equiv_harmonious_max_perc-B_equiv_harmonious_min_perc)+B_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily22[daily2BG + i] = iff(
        or(daily20[daily2BA + i] <= 0, daily22[daily2BC + i] <= 0, daily22[daily2BE + i] <= 0), 0,
        min(
          1, ifFinite(daily20[daily2BA + i] / (daily20[daily2BA + i] - daily22[daily2BB + i]), 1),
          ifFinite(daily22[daily2BC + i] / (daily22[daily2BC + i] - daily22[daily2BD + i]), 1),
          ifFinite(daily22[daily2BE + i] / (daily22[daily2BE + i] - daily22[daily2BF + i]), 1))
          * (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc)
          + B_equiv_harmonious_min_perc)
    }

    var daily23 = [Double]()

    /// Min el cons during night
    let daily2BI = 0
    // (C_overall_var_min_cons+C_overall_fix_stby_cons)*B6+C_overall_stup_cons
    for i in 0..<365 {
      daily23[daily2BI + i] =
        (C_overall_var_min_cons + C_overall_fix_stby_cons) * daily20[daily2B + i]
        + C_overall_stup_cons
    }

    /// Max el cons during night
    let daily2BJ = 365
    // (C_overall_var_max_cons+C_overall_fix_stby_cons)*B6+C_overall_stup_cons
    for i in 0..<365 {
      daily23[daily2BJ + i] =
        (C_overall_var_max_cons + C_overall_fix_stby_cons) * daily20[daily2B + i]
        + C_overall_stup_cons
    }

    /// Min heat cons during night
    let daily2BK = 730
    // (C_overall_var_heat_min_cons+C_overall_heat_fix_stby_cons)*B6+C_overall_heat_stup_cons
    for i in 0..<365 {
      daily23[daily2BK + i] =
        (C_overall_var_heat_min_cons + C_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + C_overall_heat_stup_cons
    }

    /// Max heat cons during night
    let daily2BL = 1095
    // (C_overall_var_heat_max_cons+C_overall_heat_fix_stby_cons)*B6+C_overall_heat_stup_cons
    for i in 0..<365 {
      daily23[daily2BL + i] =
        (C_overall_var_heat_max_cons + C_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + C_overall_heat_stup_cons
    }

    /// Min RawMeth cons during night
    let daily2BM = 1460
    // C_RawMeth_min_cons*B6
    for i in 0..<365 { daily23[daily2BM + i] = C_RawMeth_min_cons * daily20[daily2B + i] }

    /// Max RawMeth cons during night
    let daily2BN = 1825
    // C_RawMeth_max_cons*B6
    for i in 0..<365 { daily23[daily2BN + i] = C_RawMeth_max_cons * daily20[daily2B + i] }

    /// Min CO2 cons during night
    let daily2BO = 2190
    // C_CO2_min_cons*B6
    for i in 0..<365 { daily23[daily2BO + i] = C_C_O_2_min_cons * daily20[daily2B + i] }

    /// Max CO2 cons during night
    let daily2BP = 2555
    // C_CO2_max_cons*B6
    for i in 0..<365 { daily23[daily2BP + i] = C_C_O_2_max_cons * daily20[daily2B + i] }

    /// Min H2 cons during night
    let daily2BQ = 2920
    // C_Hydrogen_min_cons*B6
    for i in 0..<365 { daily23[daily2BQ + i] = C_Hydrogen_min_cons * daily20[daily2B + i] }

    /// Max H2 cons during night
    let daily2BR = 3285
    // C_Hydrogen_max_cons*B6
    for i in 0..<365 { daily23[daily2BR + i] = C_Hydrogen_max_cons * daily20[daily2B + i] }

    /// Min el cons during day for night op prep
    let daily2BS = 3650
    // (BQ6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(BO6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+BM6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily23[daily2BS + i] =
        (daily23[daily2BQ + i] + daily20[daily2BM + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily23[daily2BO + i] + daily20[daily2BM + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily20[daily2BM + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily2BT = 4015
    // (BR6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(BP6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+BN6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily23[daily2BT + i] =
        (daily23[daily2BR + i] + daily23[daily2BN + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily23[daily2BP + i] + daily23[daily2BN + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily23[daily2BN + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily2BU = 4380
    // (BQ6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(BO6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-BM6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily23[daily2BU + i] =
        (daily23[daily2BQ + i] + daily20[daily2BM + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily23[daily2BO + i] + daily20[daily2BM + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily20[daily2BM + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily2BV = 4745
    // (BR6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(BP6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-BN6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily23[daily2BV + i] =
        (daily23[daily2BR + i] + daily23[daily2BN + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily23[daily2BP + i] + daily23[daily2BN + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily23[daily2BN + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily2BW = 5110
    // BM6
    for i in 0..<365 { daily23[daily2BW + i] = daily20[daily2BM + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily2BX = 5475
    // BN6
    for i in 0..<365 { daily23[daily2BX + i] = daily23[daily2BN + i] }

    /// Min CO2 prod during day for night op prep
    let daily2BY = 5840
    // BO6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily23[daily2BY + i] =
        daily23[daily2BO + i] + daily20[daily2BM + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily2BZ = 6205
    // BP6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily23[daily2BZ + i] =
        daily23[daily2BP + i] + daily23[daily2BN + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily2CA = 6570
    // BQ6+BM6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily23[daily2CA + i] =
        daily23[daily2BQ + i] + daily20[daily2BM + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily2CB = 6935
    // BR6+BN6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily23[daily2CB + i] =
        daily23[daily2BR + i] + daily23[daily2BN + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily2CC = 7300
    // 1-BM6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily23[daily2CC + i] = 1 - daily20[daily2BM + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily2CD = 7665
    // 1-BN6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily23[daily2CD + i] = 1 - daily23[daily2BN + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily2CE = 8030
    // 1-BO6/CO2_storage_cap_ud
    for i in 0..<365 { daily23[daily2CE + i] = 1 - daily23[daily2BO + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily2CF = 8395
    // 1-BP6/CO2_storage_cap_ud
    for i in 0..<365 { daily23[daily2CF + i] = 1 - daily23[daily2BP + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily2CG = 8760
    // 1-BQ6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily23[daily2CG + i] = 1 - daily23[daily2BQ + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily2CH = 9125
    // 1-BR6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily23[daily2CH + i] = 1 - daily23[daily2BR + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily2CI = 9490
    // IF(OR(CC6<=0,CE6<=0,CG6<=0),0,MIN(1,IFERROR(CC6/(CC6-CD6),1),IFERROR(CE6/(CE6-CF6),1),IFERROR(CG6/(CG6-CH6),1))*(C_equiv_harmonious_max_perc-C_equiv_harmonious_min_perc)+C_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily23[daily2CI + i] = iff(
        or(daily20[daily2CC + i] <= 0, daily20[daily2CE + i] <= 0, daily20[daily2CG + i] <= 0), 0,
        min(
          1, ifFinite(daily20[daily2CC + i] / (daily20[daily2CC + i] - daily20[daily2CD + i]), 1),
          ifFinite(daily20[daily2CE + i] / (daily20[daily2CE + i] - daily20[daily2CF + i]), 1),
          ifFinite(daily20[daily2CG + i] / (daily20[daily2CG + i] - daily20[daily2CH + i]), 1))
          * (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc)
          + C_equiv_harmonious_min_perc)
    }

    var daily24 = [Double]()

    /// Min el cons during night
    let daily2CK = 0
    // (D_overall_var_min_cons+D_overall_fix_stby_cons)*B6+D_overall_stup_cons
    for i in 0..<365 {
      daily24[daily2CK + i] =
        (D_overall_var_min_cons + D_overall_fix_stby_cons) * daily20[daily2B + i]
        + D_overall_stup_cons
    }

    /// Max el cons during night
    let daily2CL = 365
    // (D_overall_var_max_cons+D_overall_fix_stby_cons)*B6+D_overall_stup_cons
    for i in 0..<365 {
      daily24[daily2CL + i] =
        (D_overall_var_max_cons + D_overall_fix_stby_cons) * daily20[daily2B + i]
        + D_overall_stup_cons
    }

    /// Min heat cons during night
    let daily2CM = 730
    // (D_overall_var_heat_min_cons+D_overall_heat_fix_stby_cons)*B6+D_overall_heat_stup_cons
    for i in 0..<365 {
      daily24[daily2CM + i] =
        (D_overall_var_heat_min_cons + D_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + D_overall_heat_stup_cons
    }

    /// Max heat cons during night
    let daily2CN = 1095
    // (D_overall_var_heat_max_cons+D_overall_heat_fix_stby_cons)*B6+D_overall_heat_stup_cons
    for i in 0..<365 {
      daily24[daily2CN + i] =
        (D_overall_var_heat_max_cons + D_overall_heat_fix_stby_cons) * daily20[daily2B + i]
        + D_overall_heat_stup_cons
    }

    /// Min RawMeth cons during night
    let daily2CO = 1460
    // D_RawMeth_min_cons*B6
    for i in 0..<365 { daily24[daily2CO + i] = D_RawMeth_min_cons * daily20[daily2B + i] }

    /// Max RawMeth cons during night
    let daily2CP = 1825
    // D_RawMeth_max_cons*B6
    for i in 0..<365 { daily24[daily2CP + i] = D_RawMeth_max_cons * daily20[daily2B + i] }

    /// Min CO2 cons during night
    let daily2CQ = 2190
    // D_CO2_min_cons*B6
    for i in 0..<365 { daily24[daily2CQ + i] = D_C_O_2_min_cons * daily20[daily2B + i] }

    /// Max CO2 cons during night
    let daily2CR = 2555
    // D_CO2_max_cons*B6
    for i in 0..<365 { daily24[daily2CR + i] = D_C_O_2_max_cons * daily20[daily2B + i] }

    /// Min H2 cons during night
    let daily2CS = 2920
    // D_Hydrogen_min_cons*B6
    for i in 0..<365 { daily24[daily2CS + i] = D_Hydrogen_min_cons * daily20[daily2B + i] }

    /// Max H2 cons during night
    let daily2CT = 3285
    // D_Hydrogen_max_cons*B6
    for i in 0..<365 { daily24[daily2CT + i] = D_Hydrogen_max_cons * daily20[daily2B + i] }

    /// Min el cons during day for night op prep
    let daily2CU = 3650
    // (CS6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(CQ6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+CO6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily24[daily2CU + i] =
        (daily24[daily2CS + i] + daily20[daily2CO + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily20[daily2CQ + i] + daily20[daily2CO + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily20[daily2CO + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily2CV = 4015
    // (CT6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(CR6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+CP6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      daily24[daily2CV + i] =
        (daily20[daily2CT + i] + daily20[daily2CP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily20[daily2C + i] * EY_fix_cons
        + (daily20[daily2CR + i] + daily20[daily2CP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily20[daily2C + i] * CCU_fix_cons
        + daily20[daily2CP + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily20[daily2C + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily2CW = 4380
    // (CS6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(CQ6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-CO6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily24[daily2CW + i] =
        (daily24[daily2CS + i] + daily20[daily2CO + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily20[daily2CQ + i] + daily20[daily2CO + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily20[daily2CO + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily2CX = 4745
    // (CT6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(CR6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-CP6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily24[daily2CX + i] =
        (daily20[daily2CT + i] + daily20[daily2CP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily20[daily2C + i] * EY_heat_fix_cons
        + (daily20[daily2CR + i] + daily20[daily2CP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily20[daily2C + i] * CCU_fix_heat_cons
        - daily20[daily2CP + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily20[daily2C + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily2CY = 5110
    // CO6
    for i in 0..<365 { daily24[daily2CY + i] = daily20[daily2CO + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily2CZ = 5475
    // CP6
    for i in 0..<365 { daily24[daily2CZ + i] = daily20[daily2CP + i] }

    /// Min CO2 prod during day for night op prep
    let daily2DA = 5840
    // CQ6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily24[daily2DA + i] =
        daily20[daily2CQ + i] + daily20[daily2CO + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily2DB = 6205
    // CR6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily24[daily2DB + i] =
        daily20[daily2CR + i] + daily20[daily2CP + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily2DC = 6570
    // CS6+CO6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily24[daily2DC + i] =
        daily24[daily2CS + i] + daily20[daily2CO + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily2DD = 6935
    // CT6+CP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily24[daily2DD + i] =
        daily20[daily2CT + i] + daily20[daily2CP + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily2DE = 7300
    // 1-CO6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily24[daily2DE + i] = 1 - daily20[daily2CO + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily2DF = 7665
    // 1-CP6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily24[daily2DF + i] = 1 - daily20[daily2CP + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily2DG = 8030
    // 1-CQ6/CO2_storage_cap_ud
    for i in 0..<365 { daily24[daily2DG + i] = 1 - daily20[daily2CQ + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily2DH = 8395
    // 1-CR6/CO2_storage_cap_ud
    for i in 0..<365 { daily24[daily2DH + i] = 1 - daily20[daily2CR + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily2DI = 8760
    // 1-CS6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily24[daily2DI + i] = 1 - daily24[daily2CS + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily2DJ = 9125
    // 1-CT6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily24[daily2DJ + i] = 1 - daily20[daily2CT + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily2DK = 9490
    // IF(OR(DE6<=0,DG6<=0,DI6<=0),0,MIN(1,IFERROR(DE6/(DE6-DF6),1),IFERROR(DG6/(DG6-DH6),1),IFERROR(DI6/(DI6-DJ6),1))*(D_equiv_harmonious_max_perc-D_equiv_harmonious_min_perc)+D_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily24[daily2DK + i] = iff(
        or(daily24[daily2DE + i] <= 0, daily24[daily2DG + i] <= 0, daily24[daily2DI + i] <= 0), 0,
        min(
          1, ifFinite(daily24[daily2DE + i] / (daily24[daily2DE + i] - daily24[daily2DF + i]), 1),
          ifFinite(daily24[daily2DG + i] / (daily24[daily2DG + i] - daily24[daily2DH + i]), 1),
          ifFinite(daily24[daily2DI + i] / (daily24[daily2DI + i] - daily24[daily2DJ + i]), 1))
          * (D_equiv_harmonious_max_perc - D_equiv_harmonious_min_perc)
          + D_equiv_harmonious_min_perc)
    }
*/
    var daily25 = [Double]()

    /// Available day op PV elec after CSP, PB stby aux
    let daily2DM = 0
    // SUMIFS(CalculationP5:P8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily25[daily2DM + i] = U_S_Psum[i] }

    /// Available night op PV elec after CSP, PB stby aux
    let daily2DN = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationP5:P8763)-DM6
    for i in 0..<365 { daily25[daily2DN + i] = Psum[i] - daily25[daily2DM + i] }

    /// Available day op  CSP heat
    let daily2DO = 730
    // SUMIFS(CalculationJ5:J8763,CalculationU5:U8763,"="A6,CalculationT5:T8763,">0")
    for i in 0..<365 { daily25[daily2DO + i] = U_T_Jsum[i] }

    /// Available night op  CSP heat
    let daily2DP = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationJ5:J8763)-DO6
    for i in 0..<365 { daily25[daily2DP + i] = Jsum[i] - daily25[daily2DO + i] }

    var daily26 = [Double]()

    /// El cons considering min harm op during harm op period
    let daily2DR = 0
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    for i in 0..<365 { daily26[daily2DR + i] = Ssum[i] }

    /// El cons considering max harm op during harm op period
    let daily2DS = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    for i in 0..<365 { daily26[daily2DS + i] = AHsum[i] }

    /// Heat cons considering min harm op during harm op period
    let daily2DT = 730
    // SUMIF(CalculationU5:U8763,"="A6,CalculationT5:T8763)
    for i in 0..<365 { daily26[daily2DT + i] = Tsum[i] }

    /// Heat cons considering max harm op during harm op period
    let daily2DU = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAI5:AI8763)
    for i in 0..<365 { daily26[daily2DU + i] = AIsum[i] }

    /// Max grid export after min harm op during harm op period
    let daily2DV = 1460
    // SUMIFS(CalculationAF5:AF8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2DV + i] = U_S_AFsum[i] }

    /// Max grid export after max harm op during harm op period
    let daily2DW = 1825
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2DW + i] = U_S_ATsum[i] }

    /// Max grid export after min/max harm op outside of harm op period
    let daily2DX = 2190
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    for i in 0..<365 { daily26[daily2DX + i] = AFsum[i] - daily26[daily2DV + i] }

    /// Grid cons considering min harm op during harm op period
    let daily2DY = 2555
    // SUMIFS(CalculationX5:X8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2DY + i] = U_S_Xsum[i] }

    /// Grid cons considering max harm op during harm op period
    let daily2DZ = 2920
    // SUMIFS(CalculationAL5:AL8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2DZ + i] = U_AH_ALsum[i] }

    /// Grid cons considering min/max harm op outside harm op period
    let daily2EA = 3285
    // SUMIF(CalculationU5:U8763,"="A6,CalculationX5:X8763)-DY6
    for i in 0..<365 { daily26[daily2EA + i] = Xsum[i] - daily26[daily2DY + i] }

    /// Remaining PV el after min harm during harm op period
    let daily2EB = 3650
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EB + i] = U_S_Vsum[i] }

    /// Remaining PV el after max harm during harm op period
    let daily2EC = 4015
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EC + i] = U_AH_AJsum[i] }

    /// Remaining PV el after min harm outside harm op period
    let daily2ED = 4380
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    for i in 0..<365 { daily26[daily2ED + i] = Vsum[i] - daily26[daily2EB + i] }

    /// Remaining CSP heat after min harm during harm op period
    let daily2EE = 4745
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EE + i] = U_S_Wsum[i] }

    /// Remaining CSP heat after max harm during harm op period
    let daily2EF = 5110
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EF + i] = U_AH_AKsum[i] }

    /// Remaining CSP heat after min harm outside harm op period
    let daily2EG = 5475
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    for i in 0..<365 { daily26[daily2EG + i] = Wsum[i] - daily26[daily2EE + i] }

    /// Remaining grid import cap after min harm during harm op period
    let daily2EH = 5840
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EH + i] = U_S_Ysum[i] }

    /// Remaining grid import cap after max harm during harm op period
    let daily2EI = 6205
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EI + i] = U_AH_AMsum[i] }

    /// Remaining grid import cap after min harm outside harm op period
    let daily2EJ = 6570
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    for i in 0..<365 { daily26[daily2EJ + i] = Ysum[i] - daily21[daily2EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let daily2EK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily26[daily2EK + i] = min(U_S_AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let daily2EL = 7300
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily26[daily2EL + i] = min(U_AH_ASsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
    let daily2EM = 7665
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily26[daily2EM + i] = min(U_S_AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// El boiler op for min harm during harm op period
    let daily2EN = 8030
    // SUMIFS(CalculationZ5:Z8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EN + i] = U_S_Zsum[i] }

    /// El boiler op for max harm during harm op period
    let daily2EO = 8395
    // SUMIFS(CalculationAN5:AN8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EO + i] = U_S_ANsum[i] }

    /// Remaining El boiler cap after min harm during harm op period
    let daily2EP = 8760
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EP + i] = U_S_AAsum[i] }

    /// Remaining El boiler cap after max harm during harm op period
    let daily2EQ = 9125
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EQ + i] = U_AH_AOsum[i] }

    /// Remaining El boiler cap after min harm outside harm op period
    let daily2ER = 9490
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    for i in 0..<365 { daily26[daily2ER + i] = AAsum[i] - daily26[daily2EP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    let daily2ES = 9855
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2ES + i] = U_S_ABsum[i] }

    /// Remaining MethSynt cap after max harm during harm op period
    let daily2ET = 10220
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2ET + i] = U_AH_APsum[i] }

    /// Remaining MethSynt cap after min harm outside of harm op period
    let daily2EU = 10585
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    for i in 0..<365 { daily26[daily2EU + i] = ABsum[i] - daily26[daily2ES + i] }

    /// Remaining CCU cap after min harm during harm op period
    let daily2EV = 10950
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EV + i] = U_S_ACsum[i] }

    /// Remaining CCU cap after max harm during harm op period
    let daily2EW = 11315
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EW + i] = U_AH_AQsum[i] }

    /// Remaining CCU cap after min harm outside of harm op period
    let daily2EX = 11680
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    for i in 0..<365 { daily26[daily2EX + i] = ACsum[i] - daily26[daily2EV + i] }

    /// Remaining EY cap after min harm during harm op period
    let daily2EY = 12045
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { daily26[daily2EY + i] = U_S_ADsum[i] }

    /// Remaining EY cap after max harm during harm op period
    let daily2EZ = 12410
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { daily26[daily2EZ + i] = U_AH_ARsum[i] }

    /// Remaining EY cap after min harm outside of harm op period
    let daily2FA = 12775
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    for i in 0..<365 { daily26[daily2FA + i] = ADsum[i] - daily26[daily2EY + i] }

    var daily27 = [Double]()

    /// Surplus harm op period el after min day harm op and min night op prep
    let daily2FC = 0
    // EB6+EH6-O6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FC + i] =
        daily26[daily2EB + i] + daily21[daily2EH + i] - daily21[daily2O + i]
        - min(
          daily26[daily2EK + i],
          (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i] / El_boiler_eff) / BESS_chrg_eff) - max(
          0, daily21[daily2Q + i] - daily26[daily2EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let daily2FD = 365
    // EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FD + i] =
        daily26[daily2EB + i] + daily21[daily2EH + i]
        - (daily21[daily2O + i]
          + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
        - min(
          daily26[daily2EK + i],
          (daily26[daily2EA + i]
            + (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
            + (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff)
            / BESS_chrg_eff) - max(
          0,
          (daily21[daily2Q + i]
            + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
            - daily26[daily2EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let daily2FE = 730
    // EC6+EI6-O6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FE + i] =
        daily26[daily2EC + i] + daily26[daily2EI + i] - daily21[daily2O + i]
        - min(
          daily26[daily2EL + i],
          (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i] / El_boiler_eff) / BESS_chrg_eff) - max(
          0, daily21[daily2Q + i] - daily26[daily2EF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2FF = 1095
    // (EK6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FF + i] =
        (daily26[daily2EK + i] + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i] - daily21[daily2E + i]
        - daily21[daily2G + i] / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2FG = 1460
    // (EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FG + i] =
        (daily26[daily2EK + i] + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i]
        - (daily21[daily2E + i]
          + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
        - (daily21[daily2G + i]
          + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
        / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2FH = 1825
    // (EL6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FH + i] =
        (daily26[daily2EL + i] + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i] - daily21[daily2E + i]
        - daily21[daily2G + i] / El_boiler_eff
    }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2FI = 2190
    // EE6+(EB6+EH6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      daily27[daily2FI + i] =
        daily26[daily2EE + i]
        + (daily26[daily2EB + i] + daily21[daily2EH + i]
          - min(
            daily26[daily2EK + i],
            (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i] / El_boiler_eff) / BESS_chrg_eff)
          - daily21[daily2O + i]) * El_boiler_eff - daily21[daily2Q + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2FJ = 2555
    // EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2FJ + i] =
        daily26[daily2EE + i]
        + (daily26[daily2EB + i] + daily21[daily2EH + i]
          - min(
            daily26[daily2EK + i],
            (daily26[daily2EA + i]
              + (daily21[daily2E + i]
                + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
              + (daily21[daily2G + i]
                + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
                / El_boiler_eff)
              / BESS_chrg_eff)
          - (daily21[daily2O + i]
            + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])))
        * El_boiler_eff
        - (daily21[daily2Q + i]
          + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2FK = 2920
    // EF6+(EC6+EI6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      daily27[daily2FK + i] =
        daily26[daily2EF + i]
        + (daily26[daily2EC + i] + daily26[daily2EI + i]
          - min(
            daily26[daily2EL + i],
            (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i] / El_boiler_eff) / BESS_chrg_eff)
          - daily21[daily2O + i]) * El_boiler_eff - daily21[daily2Q + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let daily2FL = 3285
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 {
      daily27[daily2FL + i] = daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff - daily21[daily2G + i]
    }

    /// Surplus outside harm op heat after min day harm and max night op prep
    let daily2FM = 3650
    // EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2FM + i] =
        daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff
        - (daily21[daily2G + i]
          + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus outside harm op heat after max day harm and min night op prep
    let daily2FN = 4015
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 {
      daily27[daily2FN + i] = daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff - daily21[daily2G + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let daily2FO = 4380
    // EP6-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FO + i] = daily26[daily2EP + i] - max(0, daily21[daily2Q + i] - daily26[daily2EE + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let daily2FP = 4745
    // EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FP + i] =
        daily26[daily2EP + i] - max(
          0,
          (daily21[daily2Q + i]
            + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
            - daily26[daily2EE + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let daily2FQ = 5110
    // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FQ + i] = daily26[daily2EQ + i] - max(0, daily21[daily2Q + i] - daily26[daily2EF + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let daily2FR = 5475
    // ER6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FR + i] = daily26[daily2ER + i] - max(0, daily21[daily2G + i] - daily26[daily2EG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let daily2FS = 5840
    // ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FS + i] =
        daily26[daily2ER + i] - max(
          0,
          (daily21[daily2G + i]
            + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
            - daily26[daily2EG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let daily2FT = 6205
    // ER6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 {
      daily27[daily2FT + i] = daily26[daily2ER + i] - max(0, daily21[daily2G + i] - daily26[daily2EG + i]) / El_boiler_eff
    }

    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let daily2FU = 6570
    // ES6-S6
    for i in 0..<365 { daily27[daily2FU + i] = daily26[daily2ES + i] - daily21[daily2S + i] }

    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let daily2FV = 6935
    // ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2FV + i] =
        daily26[daily2ES + i]
        - (daily21[daily2S + i]
          + (daily21[daily2T + i] - daily21[daily2S + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let daily2FW = 7300
    // ET6-S6
    for i in 0..<365 { daily27[daily2FW + i] = daily26[daily2ET + i] - daily21[daily2S + i] }

    /// Surplus CO2 prod cap after min day harm and min night op prep
    let daily2FX = 7665
    // EV6-U6
    for i in 0..<365 { daily27[daily2FX + i] = daily26[daily2EV + i] - daily21[daily2U + i] }

    /// Surplus CO2 prod cap after min day harm and max night op prep
    let daily2FY = 8030
    // EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2FY + i] =
        daily26[daily2EV + i]
        - (daily21[daily2U + i]
          + (daily21[daily2V + i] - daily21[daily2U + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max day harm and min night op prep
    let daily2FZ = 8395
    // EW6-U6
    for i in 0..<365 { daily27[daily2FZ + i] = daily26[daily2EW + i] - daily21[daily2U + i] }

    /// Surplus H2 prod cap after min day harm and min night op prep
    let daily2GA = 8760
    // EY6-W6
    for i in 0..<365 { daily27[daily2GA + i] = daily26[daily2EY + i] - daily21[daily2W + i] }

    /// Surplus H2 prod cap after min day harm and max night op prep
    let daily2GB = 9125
    // EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2GB + i] =
        daily26[daily2EY + i]
        - (daily21[daily2W + i]
          + (daily21[daily2X + i] - daily21[daily2W + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max day harm and min night op prep
    let daily2GC = 9490
    // EZ6-W6
    for i in 0..<365 { daily27[daily2GC + i] = daily26[daily2EZ + i] - daily21[daily2W + i] }

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let daily2GE = 9855
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FE6),1),IFERROR(FF6/(FF6-FH6),1),IFERROR(FI6/(FI6-FK6),1),IFERROR(FL6/(FL6-FN6),1),IFERROR(FO6/(FO6-FQ6),1),IFERROR(FR6/(FR6-FT6),1),IFERROR(FU6/(FU6-FW6),1),IFERROR(FX6/(FX6-FZ6),1),IFERROR(GA6/(GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      daily27[daily2GE + i] = iff(
        or(
          daily27[daily2FC + i] < 0, daily27[daily2FF + i] < 0, daily27[daily2FI + i] < 0, daily27[daily2FL + i] < 0,
          daily27[daily2FO + i] < 0, daily27[daily2FR + i] < 0, daily21[daily2FU + i] < 0, daily27[daily2FX + i] < 0,
          daily27[daily2GA + i] < 0), 0,
        min(
          1, ifFinite(daily27[daily2FC + i] / (daily27[daily2FC + i] - daily27[daily2FE + i]), 1),
          ifFinite(daily27[daily2FF + i] / (daily27[daily2FF + i] - daily27[daily2FH + i]), 1),
          ifFinite(daily27[daily2FI + i] / (daily27[daily2FI + i] - daily27[daily2FK + i]), 1),
          ifFinite(daily27[daily2FL + i] / (daily27[daily2FL + i] - daily27[daily2FN + i]), 1),
          ifFinite(daily27[daily2FO + i] / (daily27[daily2FO + i] - daily27[daily2FQ + i]), 1),
          ifFinite(daily27[daily2FR + i] / (daily27[daily2FR + i] - daily27[daily2FT + i]), 1),
          ifFinite(daily21[daily2FU + i] / (daily21[daily2FU + i] - daily27[daily2FW + i]), 1),
          ifFinite(daily27[daily2FX + i] / (daily27[daily2FX + i] - daily27[daily2FZ + i]), 1),
          ifFinite(daily27[daily2GA + i] / (daily27[daily2GA + i] - daily27[daily2GC + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let daily2GF = 10220
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    // for i in 0..<365 {
    //   daily27[daily2GF + i] = iff(
    //     daily27[daily2GE + i].isZero, 0,
    //     round(
    //       (daily26[daily2EB + i]
    //         + (daily26[daily2EC + i] - daily26[daily2EB + i])
    //           / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //           * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         + (daily21[daily2EH + i]
    //           + (daily26[daily2EI + i] - daily21[daily2EH + i])
    //             / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //             * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         - daily21[daily2O + i]
    //         - min(
    //           daily26[daily2EK + i]
    //             + (daily26[daily2EL + i] - daily26[daily2EK + i])
    //               / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //               * (daily21[daily2VK + i] - Overall_harmonious_min_perc),
    //           (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i] / El_boiler_eff)
    //             / BESS_chrg_eff) - max(
    //           0,
    //           daily21[daily2Q + i]
    //             - (daily26[daily2EE + i]
    //               + (daily26[daily2EF + i] - daily26[daily2EE + i])
    //                 / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //                 * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         ) / El_boiler_eff, 5))
    // }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let daily2GG = 10585
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    // for i in 0..<365 {
    //   daily27[daily2GG + i] = iff(
    //     daily27[daily2GE + i].isZero, 0,
    //     round(
    //       (daily26[daily2EB + i]
    //         + (daily26[daily2EC + i] - daily26[daily2EB + i])
    //           / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //           * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         + (daily21[daily2EH + i]
    //           + (daily26[daily2EI + i] - daily21[daily2EH + i])
    //             / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //             * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         - (daily21[daily2O + i]
    //           + (daily21[daily2P + i] - daily21[daily2O + i])
    //             / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //             * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //         - min(
    //           daily26[daily2EK + i]
    //             + (daily26[daily2EL + i] - daily26[daily2EK + i])
    //               / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //               * (daily21[daily2VK + i] - Overall_harmonious_min_perc),
    //           (daily26[daily2EA + i]
    //             + (daily21[daily2E + i]
    //               + (daily21[daily2F + i] - daily21[daily2E + i])
    //                 / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //                 * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //             + (daily21[daily2G + i]
    //               + (daily21[daily2H + i] - daily21[daily2G + i])
    //                 / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //                 * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //               / El_boiler_eff)
    //             / BESS_chrg_eff) - max(
    //           0,
    //           (daily21[daily2Q + i]
    //             + (daily21[daily2R + i] - daily21[daily2Q + i])
    //               / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //               * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //             - (daily26[daily2EE + i]
    //               + (daily26[daily2EF + i] - daily26[daily2EE + i])
    //                 / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //                 * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         ) / El_boiler_eff, 5))
    // }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2GH = 10950
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GH + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          ((daily26[daily2EK + i]
            + (daily26[daily2EL + i] - daily26[daily2EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i] - daily21[daily2E + i] - daily21[daily2G + i]
            / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2GI = 11315
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GI + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          ((daily26[daily2EK + i]
            + (daily26[daily2EL + i] - daily26[daily2EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i]
            - (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2GJ = 11680
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6,5))
    // for i in 0..<365 {
    //   daily27[daily2GJ + i] = iff(
    //     daily27[daily2GE + i].isZero, 0,
    //     round(
    //       (daily26[daily2EE + i]
    //         + (daily26[daily2EF + i] - daily26[daily2EE + i])
    //           / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //           * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         + ((daily26[daily2EB + i]
    //           + (daily26[daily2EC + i] - daily26[daily2EB + i])
    //             / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //             * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //           + (daily21[daily2EH + i]
    //             + (daily26[daily2EI + i] - daily21[daily2EH + i])
    //               / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //               * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //           - min(
    //             daily26[daily2EK + i]
    //               + (daily26[daily2EL + i] - daily26[daily2EK + i])
    //                 / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //                 * (daily21[daily2VK + i] - Overall_harmonious_min_perc),
    //             (daily26[daily2EA + i] + daily21[daily2E + i] + daily21[daily2G + i]
    //               / El_boiler_eff) / BESS_chrg_eff) - daily21[daily2O + i]) * El_boiler_eff
    //         - daily21[daily2Q + i], 5))
    // }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2GK = 12045
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    // for i in 0..<365 {
    //   daily27[daily2GK + i] = iff(
    //     daily27[daily2GE + i].isZero, 0,
    //     round(
    //       (daily26[daily2EE + i]
    //         + (daily26[daily2EF + i] - daily26[daily2EE + i])
    //           / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //           * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //         + ((daily26[daily2EB + i]
    //           + (daily26[daily2EC + i] - daily26[daily2EB + i])
    //             / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //             * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //           + (daily21[daily2EH + i]
    //             + (daily26[daily2EI + i] - daily21[daily2EH + i])
    //               / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //               * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    //           - min(
    //             daily26[daily2EK + i]
    //               + (daily26[daily2EL + i] - daily26[daily2EK + i])
    //                 / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
    //                 * (daily21[daily2VK + i] - Overall_harmonious_min_perc),
    //             (daily26[daily2EA + i]
    //               + (daily21[daily2E + i]
    //                 + (daily21[daily2F + i] - daily21[daily2E + i])
    //                   / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //                   * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //               + (daily21[daily2G + i]
    //                 + (daily21[daily2H + i] - daily21[daily2G + i])
    //                   / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //                   * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
    //                 / El_boiler_eff)
    //               / BESS_chrg_eff)
    //           - (daily21[daily2O + i]
    //             + (daily21[daily2P + i] - daily21[daily2O + i])
    //               / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //               * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])))
    //         * El_boiler_eff
    //         - (daily21[daily2Q + i]
    //           + (daily21[daily2R + i] - daily21[daily2Q + i])
    //             / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
    //             * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])),
    //       5))
    // }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let daily2GL = 12410
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-G6,5))
    for i in 0..<365 {
      daily27[daily2GL + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff - daily21[daily2G + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let daily2GM = 12775
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2GM + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let daily2GN = 13140
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GN + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EP + i]
            + (daily26[daily2EQ + i] - daily26[daily2EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - max(
              0,
              daily21[daily2Q + i]
                - (daily26[daily2EE + i]
                  + (daily26[daily2EF + i] - daily26[daily2EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let daily2GO = 13505
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GO + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EP + i]
            + (daily26[daily2EQ + i] - daily26[daily2EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - max(
              0,
              (daily21[daily2Q + i]
                + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
                - (daily26[daily2EE + i]
                  + (daily26[daily2EF + i] - daily26[daily2EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let daily2GP = 13870
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GP + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(daily26[daily2ER + i] - max(0, daily21[daily2G + i] - daily26[daily2EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let daily2GQ = 14235
    // IF(GE6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2GQ + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          daily26[daily2ER + i] - max(
            0,
            (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]))
              - daily26[daily2EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let daily2GR = 14600
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 {
      daily27[daily2GR + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2ES + i]
            + (daily26[daily2ET + i] - daily26[daily2ES + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - daily21[daily2S + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let daily2GS = 14965
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2GS + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2ES + i]
            + (daily26[daily2ET + i] - daily26[daily2ES + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - (daily21[daily2S + i]
              + (daily21[daily2T + i] - daily21[daily2S + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let daily2GT = 15330
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 {
      daily27[daily2GT + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EV + i]
            + (daily26[daily2EW + i] - daily26[daily2EV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - daily21[daily2U + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let daily2GU = 15695
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2GU + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EV + i]
            + (daily26[daily2EW + i] - daily26[daily2EV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - (daily21[daily2U + i]
              + (daily21[daily2V + i] - daily21[daily2U + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let daily2GV = 16060
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 {
      daily27[daily2GV + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EY + i]
            + (daily26[daily2EZ + i] - daily26[daily2EY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - daily21[daily2W + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let daily2GW = 16425
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2GW + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        round(
          (daily26[daily2EY + i]
            + (daily26[daily2EZ + i] - daily26[daily2EY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            - (daily21[daily2W + i]
              + (daily21[daily2X + i] - daily21[daily2W + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let daily2GX = 16790
    // IF(OR(GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/(GF6-GG6),1),IFERROR(GH6/(GH6-GI6),1),IFERROR(GJ6/(GJ6-GK6),1),IFERROR(GL6/(GL6-GM6),1),IFERROR(GN6/(GN6-GO6),1),IFERROR(GP6/(GP6-GQ6),1),IFERROR(GR6/(GR6-GS6),1),IFERROR(GT6/(GT6-GU6),1),IFERROR(GV6/(GV6-GW6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily27[daily2GX + i] = iff(
        or(
          daily27[daily2GE + i].isZero, daily27[daily2GF + i] < 0, daily21[daily2GH + i] < 0, daily21[daily2GJ + i] < 0,
          daily27[daily2GL + i] < 0, daily27[daily2GN + i] < 0, daily21[daily2GP + i] < 0, daily27[daily2GR + i] < 0,
          daily27[daily2GT + i] < 0, daily21[daily2GV + i] < 0), 0,
        min(
          1, ifFinite(daily27[daily2GF + i] / (daily27[daily2GF + i] - daily27[daily2GG + i]), 1),
          ifFinite(daily21[daily2GH + i] / (daily21[daily2GH + i] - daily27[daily2GI + i]), 1),
          ifFinite(daily21[daily2GJ + i] / (daily21[daily2GJ + i] - daily27[daily2GK + i]), 1),
          ifFinite(daily27[daily2GL + i] / (daily27[daily2GL + i] - daily27[daily2GM + i]), 1),
          ifFinite(daily27[daily2GN + i] / (daily27[daily2GN + i] - daily27[daily2GO + i]), 1),
          ifFinite(daily21[daily2GP + i] / (daily21[daily2GP + i] - daily21[daily2GQ + i]), 1),
          ifFinite(daily27[daily2GR + i] / (daily27[daily2GR + i] - daily27[daily2GS + i]), 1),
          ifFinite(daily27[daily2GT + i] / (daily27[daily2GT + i] - daily27[daily2GU + i]), 1),
          ifFinite(daily21[daily2GV + i] / (daily21[daily2GV + i] - daily27[daily2GW + i]), 1))
          * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let daily2GZ = 17155
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FD6),1),IFERROR(FF6/(FF6-FG6),1),IFERROR(FI6/(FI6-FJ6),1),IFERROR(FL6/(FL6-FM6),1),IFERROR(FO6/(FO6-FP6),1),IFERROR(FR6/(FR6-FS6),1),IFERROR(FU6/(FU6-FV6),1),IFERROR(FX6/(FX6-FY6),1),IFERROR(GA6/(GA6-GB6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily27[daily2GZ + i] = iff(
        or(
          daily27[daily2FC + i] < 0, daily27[daily2FF + i] < 0, daily27[daily2FI + i] < 0, daily27[daily2FL + i] < 0,
          daily27[daily2FO + i] < 0, daily27[daily2FR + i] < 0, daily21[daily2FU + i] < 0, daily27[daily2FX + i] < 0,
          daily27[daily2GA + i] < 0), 0,
        min(
          1, ifFinite(daily27[daily2FC + i] / (daily27[daily2FC + i] - daily27[daily2FD + i]), 1),
          ifFinite(daily27[daily2FF + i] / (daily27[daily2FF + i] - daily27[daily2FG + i]), 1),
          ifFinite(daily27[daily2FI + i] / (daily27[daily2FI + i] - daily27[daily2FJ + i]), 1),
          ifFinite(daily27[daily2FL + i] / (daily27[daily2FL + i] - daily27[daily2FM + i]), 1),
          ifFinite(daily27[daily2FO + i] / (daily27[daily2FO + i] - daily27[daily2FP + i]), 1),
          ifFinite(daily27[daily2FR + i] / (daily27[daily2FR + i] - daily27[daily2FS + i]), 1),
          ifFinite(daily21[daily2FU + i] / (daily21[daily2FU + i] - daily27[daily2FV + i]), 1),
          ifFinite(daily27[daily2FX + i] / (daily27[daily2FX + i] - daily27[daily2FY + i]), 1),
          ifFinite(daily27[daily2GA + i] / (daily27[daily2GA + i] - daily27[daily2GB + i]), 1))
          * (daily21[daily2AE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let daily2HA = 17520
    // IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HA + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EB + i] + daily21[daily2EH + i]
            - (daily21[daily2O + i]
              + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              daily26[daily2EK + i],
              (daily26[daily2EA + i]
                + (daily21[daily2E + i]
                  + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                + (daily21[daily2G + i]
                  + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              0,
              (daily21[daily2Q + i]
                + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                - daily26[daily2EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after max day harm op and opt night op prep
    let daily2HB = 17885
    // IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HB + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EC + i] + daily26[daily2EI + i]
            - (daily21[daily2O + i]
              + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              daily26[daily2EL + i],
              (daily26[daily2EA + i]
                + (daily21[daily2E + i]
                  + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                + (daily21[daily2G + i]
                  + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              0,
              (daily21[daily2Q + i]
                + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                - daily26[daily2EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after min day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2HC = 18250
    // IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HC + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          (daily26[daily2EK + i] + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i]
            - (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus outside harm op period el after max day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let daily2HD = 18615
    // IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HD + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          (daily26[daily2EL + i] + daily26[daily2EM + i]) * BESS_chrg_eff + daily26[daily2EJ + i]
            - (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after min day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2HE = 18980
    // IF(GZ6=0,0,ROUND(EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HE + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EE + i]
            + (daily26[daily2EB + i] + daily21[daily2EH + i]
              - min(
                daily26[daily2EK + i],
                (daily26[daily2EA + i]
                  + (daily21[daily2E + i]
                    + (daily21[daily2F + i] - daily21[daily2E + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                  + (daily21[daily2G + i]
                    + (daily21[daily2H + i] - daily21[daily2G + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (daily21[daily2O + i]
                + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (daily21[daily2Q + i]
              + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harm op heat after max day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let daily2HF = 19345
    // IF(GZ6=0,0,ROUND(EF6+(EC6+EI6-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HF + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EF + i]
            + (daily26[daily2EC + i] + daily26[daily2EI + i]
              - min(
                daily26[daily2EL + i],
                (daily26[daily2EA + i]
                  + (daily21[daily2E + i]
                    + (daily21[daily2F + i] - daily21[daily2E + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                  + (daily21[daily2G + i]
                    + (daily21[daily2H + i] - daily21[daily2G + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (daily21[daily2O + i]
                + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (daily21[daily2Q + i]
              + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after min day harm and opt night op prep
    let daily2HG = 19710
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HG + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after max day harm and opt night op prep
    let daily2HH = 20075
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HH + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EG + i] + daily26[daily2ER + i] * El_boiler_eff
            - (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let daily2HI = 20440
    // IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HI + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EP + i] - max(
            0,
            (daily21[daily2Q + i]
              + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              - daily26[daily2EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let daily2HJ = 20805
    // IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HJ + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EQ + i] - max(
            0,
            (daily21[daily2Q + i]
              + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              - daily26[daily2EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let daily2HK = 21170
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HK + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2ER + i] - max(
            0,
            (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              - daily26[daily2EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let daily2HL = 21535
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      daily27[daily2HL + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2ER + i] - max(
            0,
            (daily21[daily2G + i]
              + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
              - daily26[daily2EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let daily2HM = 21900
    // IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HM + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2ES + i]
            - (daily21[daily2S + i]
              + (daily21[daily2T + i] - daily21[daily2S + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let daily2HN = 22265
    // IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HN + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2ET + i]
            - (daily21[daily2S + i]
              + (daily21[daily2T + i] - daily21[daily2S + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let daily2HO = 22630
    // IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HO + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EV + i]
            - (daily21[daily2U + i]
              + (daily21[daily2V + i] - daily21[daily2U + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let daily2HP = 22995
    // IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HP + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EW + i]
            - (daily21[daily2U + i]
              + (daily21[daily2V + i] - daily21[daily2U + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let daily2HQ = 23360
    // IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HQ + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EY + i]
            - (daily21[daily2W + i]
              + (daily21[daily2X + i] - daily21[daily2W + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let daily2HR = 23725
    // IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily27[daily2HR + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        round(
          daily26[daily2EZ + i]
            - (daily21[daily2W + i]
              + (daily21[daily2X + i] - daily21[daily2W + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let daily2HS = 24090
    // IF(GZ6<=0,0,MIN(1,MIN(IFERROR(HA6/(HA6-HB6),1),IFERROR(HC6/(HC6-HD6),1),IFERROR(HE6/(HE6-HF6),1),IFERROR(HG6/(HG6-HH6),1),IFERROR(HI6/(HI6-HJ6),1),IFERROR(HK6/(HK6-HL6),1),IFERROR(HM6/(HM6-HN6),1),IFERROR(HO6/(HO6-HP6),1),IFERROR(HQ6/(HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2HS + i] = iff(
        daily27[daily2GZ + i] <= 0, 0,
        min(
          1,
          min(
            ifFinite(daily21[daily2HA + i] / (daily21[daily2HA + i] - daily21[daily2HB + i]), 1),
            ifFinite(daily27[daily2HC + i] / (daily27[daily2HC + i] - daily21[daily2HD + i]), 1),
            ifFinite(daily21[daily2HE + i] / (daily21[daily2HE + i] - daily21[daily2HF + i]), 1),
            ifFinite(daily27[daily2HG + i] / (daily27[daily2HG + i] - daily21[daily2HH + i]), 1),
            ifFinite(daily21[daily2HI + i] / (daily21[daily2HI + i] - daily27[daily2HJ + i]), 1),
            ifFinite(daily21[daily2HK + i] / (daily21[daily2HK + i] - daily21[daily2HL + i]), 1),
            ifFinite(daily21[daily2HM + i] / (daily21[daily2HM + i] - daily21[daily2HN + i]), 1),
            ifFinite(daily27[daily2HO + i] / (daily27[daily2HO + i] - daily21[daily2HP + i]), 1),
            ifFinite(daily21[daily2HQ + i] / (daily21[daily2HQ + i] - daily21[daily2HR + i]), 1))
            * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc))
    }

    /// el cons for harm op during harm op period
    let daily2HU = 24455
    // IF(GE6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2HU + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2DR + i] + (daily26[daily2DS + i] - daily26[daily2DR + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily2HV = 24820
    // IF(GX6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily27[daily2HV + i] = iff(
        daily27[daily2GX + i].isZero, 0,
        (daily21[daily2O + i]
          + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let daily2HW = 25185
    // IF(OR(GE6=0,GX6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily27[daily2HW + i] = iff(
        or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0,
        min(
          (daily26[daily2EA + i]
            + (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
            + max(
              0,
              (daily21[daily2G + i]
                + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
                - daily26[daily2EG + i]) / El_boiler_eff - daily26[daily2ED + i]) / BESS_chrg_eff,
          (daily26[daily2EK + i]
            + (daily26[daily2EL + i] - daily26[daily2EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let daily2HX = 25550
    // IF(GE6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2HX + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2EN + i] + (daily26[daily2EO + i] - daily26[daily2EN + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let daily2HY = 25915
    // IH6/El_boiler_eff
    // for i in 0..<365 { daily27[daily2HY + i] = daily21[daily2IH + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let daily2HZ = 26280
    // IF(GE6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2HZ + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2EB + i] + (daily26[daily2EC + i] - daily26[daily2EB + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let daily2IA = 26645
    // IF(GE6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2IA + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2DY + i] + (daily26[daily2DZ + i] - daily26[daily2DY + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let daily2IB = 27010
    // IF(GE6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),MAX(0,-(HZ6-HV6-HW6-HY6))))
    // for i in 0..<365 {
    //   daily27[daily2IB + i] = iff(
    //  daily27[daily2GE + i]=0,0, min(daily21[daily2EH + i] + (daily26[daily2EI + i] - daily21[daily2EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc),max(0, - (daily27[daily2HZ + i] - daily21[daily2HV + i] - daily21[daily2HW + i] - daily21[daily2HY + i]))))
    // }

    /// Balance of electricity during harm op period
    let daily2IC = 27375
    // HZ6+IB6-HV6-HW6-HY6
    for i in 0..<365 {
      daily27[daily2IC + i] =
        daily27[daily2HZ + i] + daily27[daily2IB + i] - daily21[daily2HV + i] - daily21[daily2HW + i] - daily21[daily2HY + i]
    }

    /// Heat cons for harm op during harm op period
    let daily2ID = 27740
    // IF(GE6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2ID + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2DT + i] + (daily26[daily2DU + i] - daily26[daily2DT + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let daily2IE = 28105
    // IF(GX6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily27[daily2IE + i] = iff(
        daily27[daily2GX + i].isZero, 0,
        (daily21[daily2Q + i]
          + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let daily2IF = 28470
    // IF(GE6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2IF + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        daily26[daily2EE + i] + (daily26[daily2EF + i] - daily26[daily2EE + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let daily2IG = 28835
    // IF(GE6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      daily27[daily2IG + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        (daily26[daily2EN + i]
          + (daily26[daily2EO + i] - daily26[daily2EN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
          * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let daily2IH = 29200
    // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
    for i in 0..<365 {
      daily27[daily2IH + i] = iff(
        daily27[daily2GE + i].isZero, 0,
        min(
          (daily26[daily2EP + i]
            + (daily26[daily2EQ + i] - daily26[daily2EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, daily21[daily2IE + i] - daily21[daily2IF + i])))
    }

    /// Balance of heat during harm op period
    let daily2II = 29565
    // IF6+IH6-IE6
    for i in 0..<365 { daily27[daily2II + i] = daily21[daily2IF + i] + daily21[daily2IH + i] - daily21[daily2IE + i] }

    /// el cons for harm op outside of harm op period
    let daily2IJ = 29930
    // IF(OR(GE6=0,GX6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2IJ + i] = iff(
        or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0,
        daily21[daily2E + i] + (daily21[daily2F + i] - daily21[daily2E + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let daily2IK = 30295
    // IS6/El_boiler_eff
    // for i in 0..<365 { daily27[daily2IK + i] = daily21[daily2IS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let daily2IL = 30660
    // IF(OR(GE6=0,GX6=0),0,EA6)
    for i in 0..<365 {
      daily27[daily2IL + i] = iff(or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0, daily26[daily2EA + i])
    }

    /// el from PV outside of harm op period
    let daily2IM = 31025
    // IF(OR(GE6=0,GX6=0),0,ED6)
    for i in 0..<365 {
      daily27[daily2IM + i] = iff(or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0, daily26[daily2ED + i])
    }

    /// el from BESS outside of harm op period
    let daily2IN = 31390
    // HW6*BESS_chrg_eff
    for i in 0..<365 { daily27[daily2IN + i] = daily21[daily2HW + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let daily2IO = 31755
    // IF(OR(GE6=0,GX6=0),0,MIN(EJ6+EA6,MAX(0,-(IM6+IN6-IJ6-IK6-IL6))))
    // for i in 0..<365 {
    //   daily27[daily2IO + i] = iff(
    //   or(
    //  daily27[daily2GE + i]=0,daily27[daily2GX + i]=0),0, min(daily26[daily2EJ + i] + daily26[daily2EA + i],max(0, - (daily21[daily2IM + i] + daily27[daily2IN + i] - daily21[daily2IJ + i] - daily21[daily2IK + i] - daily27[daily2IL + i]))))
    // }

    /// Balance of electricity outside of harm op period
    let daily2IP = 32120
    // IM6+IN6+IO6-IJ6-IK6-IL6
    for i in 0..<365 {
      daily27[daily2IP + i] =
        daily21[daily2IM + i] + daily27[daily2IN + i] + daily27[daily2IO + i] - daily21[daily2IJ + i] - daily21[daily2IK + i]
        - daily27[daily2IL + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily2IQ = 32485
    // IF(OR(GE6=0,GX6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2IQ + i] = iff(
        or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0,
        daily21[daily2G + i] + (daily21[daily2H + i] - daily21[daily2G + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (daily27[daily2GX + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let daily2IR = 32850
    // IF(OR(GE6=0,GX6=0),0,EG6)
    for i in 0..<365 {
      daily27[daily2IR + i] = iff(or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0, daily26[daily2EG + i])
    }

    /// heat from el boiler outside of harm op period
    let daily2IS = 33215
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 {
      daily27[daily2IS + i] = iff(
        or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0,
        min(daily26[daily2ER + i] * El_boiler_eff, max(0, daily21[daily2IQ + i] - daily21[daily2IR + i])))
    }

    /// Balance of heat outside of harm op period
    let daily2IT = 33580
    // IR6+IS6-IQ6
    for i in 0..<365 { daily27[daily2IT + i] = daily21[daily2IR + i] + daily27[daily2IS + i] - daily21[daily2IQ + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let daily2IU = 33945
    // IF(HU6<=0,0,HU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(IJ6<=0,0,(IJ6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily27[daily2IU + i] =
        iff(
          daily21[daily2HU + i] <= 0, 0,
          daily21[daily2HU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          daily21[daily2IJ + i] <= 0, 0,
          (daily21[daily2IJ + i] - overall_stup_cons[j]) / (overall_var_max_cons[j] + overall_fix_stby_cons[j])
            * MethDist_max_perc[j] * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let daily2IV = 34310
    // MIN(IC6,IF(OR(GE6=0,GX6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))+MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))
    for i in 0..<365 {
      daily27[daily2IV + i] =
        min(
          daily27[daily2IC + i],
          iff(
            or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0,
            (daily26[daily2DV + i]
              + (daily26[daily2DW + i] - daily26[daily2DV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily27[daily2GE + i] - Overall_harmonious_min_perc))
          ))
        + min(
          daily27[daily2IP + i], iff(or(daily27[daily2GE + i].isZero, daily27[daily2GX + i].isZero), 0, daily26[daily2DX + i]))
    }

    /// grid import
    let daily2IW = 34675
    // IA6+IB6+IO6
    for i in 0..<365 { daily27[daily2IW + i] = daily21[daily2IA + i] + daily27[daily2IB + i] + daily27[daily2IO + i] }

    /// Checksum
    let daily2IX = 35040
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    // for i in 0..<365 {
    //   daily27[daily2IX + i] = max(0, - daily27[daily2IC + i]) + max(0, - daily21[daily2II + i]) + max(0, - daily27[daily2IP + i]) + max(0, - daily27[daily2IT + i])
    // }

    /// el cons for harm op during harm op period
    let daily2IZ = 35405
    // IF(HS6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2IZ + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2DR + i] + (daily26[daily2DS + i] - daily26[daily2DR + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily2JA = 35770
    // IF(GZ6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily27[daily2JA + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        (daily21[daily2O + i]
          + (daily21[daily2P + i] - daily21[daily2O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let daily2JB = 36135
    // IF(OR(HS6=0,GZ6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily27[daily2JB + i] = iff(
        or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0,
        min(
          (daily26[daily2EA + i]
            + (daily21[daily2E + i]
              + (daily21[daily2F + i] - daily21[daily2E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            + max(
              0,
              (daily21[daily2G + i]
                + (daily21[daily2H + i] - daily21[daily2G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
                - daily26[daily2EG + i]) / El_boiler_eff - daily26[daily2ED + i]) / BESS_chrg_eff,
          (daily26[daily2EK + i]
            + (daily26[daily2EL + i] - daily26[daily2EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let daily2JC = 36500
    // IF(HS6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JC + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2EN + i] + (daily26[daily2EO + i] - daily26[daily2EN + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let daily2JD = 36865
    // JM6/El_boiler_eff
    // for i in 0..<365 { daily27[daily2JD + i] = daily21[daily2JM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let daily2JE = 37230
    // IF(HS6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JE + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2EB + i] + (daily26[daily2EC + i] - daily26[daily2EB + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let daily2JF = 37595
    // IF(HS6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JF + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2DY + i] + (daily26[daily2DZ + i] - daily26[daily2DY + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let daily2JG = 37960
    // IF(HS6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc),MAX(0,-(JE6-JA6-JB6-JD6))))
    // for i in 0..<365 {
    //   daily27[daily2JG + i] = iff(
    //  daily21[daily2HS + i]=0,0, min(daily21[daily2EH + i] + (daily26[daily2EI + i] - daily21[daily2EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc),max(0, - (daily27[daily2JE + i] - daily27[daily2JA + i] - daily21[daily2JB + i] - daily27[daily2JD + i]))))
    // }

    /// Balance of electricity during harm op period
    let daily2JH = 38325
    // JE6+JG6-JA6-JB6-JD6
    for i in 0..<365 {
      daily27[daily2JH + i] =
        daily27[daily2JE + i] + daily27[daily2JG + i] - daily27[daily2JA + i] - daily21[daily2JB + i] - daily27[daily2JD + i]
    }

    /// Heat cons for harm op during harm op period
    let daily2JI = 38690
    // IF(HS6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JI + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2DT + i] + (daily26[daily2DU + i] - daily26[daily2DT + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let daily2JJ = 39055
    // IF(GZ6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily27[daily2JJ + i] = iff(
        daily27[daily2GZ + i].isZero, 0,
        (daily21[daily2Q + i]
          + (daily21[daily2R + i] - daily21[daily2Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let daily2JK = 39420
    // IF(HS6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JK + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        daily26[daily2EE + i] + (daily26[daily2EF + i] - daily26[daily2EE + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let daily2JL = 39785
    // IF(HS6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      daily27[daily2JL + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        (daily26[daily2EN + i]
          + (daily26[daily2EO + i] - daily26[daily2EN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
          * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let daily2JM = 40150
    // IF(HS6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 {
      daily27[daily2JM + i] = iff(
        daily21[daily2HS + i].isZero, 0,
        min(
          (daily26[daily2EP + i]
            + (daily26[daily2EQ + i] - daily26[daily2EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, daily21[daily2JJ + i] - daily27[daily2JK + i])))
    }

    /// Balance of heat during harm op period
    let daily2JN = 40515
    // JK6+JM6-JJ6
    for i in 0..<365 { daily27[daily2JN + i] = daily27[daily2JK + i] + daily21[daily2JM + i] - daily21[daily2JJ + i] }

    /// el cons for harm op outside of harm op period
    let daily2JO = 40880
    // IF(OR(HS6=0,GZ6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JO + i] = iff(
        or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0,
        daily21[daily2E + i] + (daily21[daily2F + i] - daily21[daily2E + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let daily2JP = 41245
    // JX6/El_boiler_eff
    // for i in 0..<365 { daily27[daily2JP + i] = daily21[daily2JX + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let daily2JQ = 41610
    // IF(OR(HS6=0,GZ6=0),0,EA6)
    for i in 0..<365 {
      daily27[daily2JQ + i] = iff(or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0, daily26[daily2EA + i])
    }

    /// el from PV outside of harm op period
    let daily2JR = 41975
    // IF(OR(HS6=0,GZ6=0),0,ED6)
    for i in 0..<365 {
      daily27[daily2JR + i] = iff(or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0, daily26[daily2ED + i])
    }

    /// el from BESS outside of harm op period
    let daily2JS = 42340
    // JB6*BESS_chrg_eff
    for i in 0..<365 { daily27[daily2JS + i] = daily21[daily2JB + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let daily2JT = 42705
    // IF(OR(HS6=0,GZ6=0),0,MIN(EJ6+EA6,MAX(0,-(JR6+JS6-JO6-JP6-JQ6))))
    // for i in 0..<365 {
    //   daily27[daily2JT + i] = iff(
    //   or(
    //  daily21[daily2HS + i]=0,daily27[daily2GZ + i]=0),0, min(daily26[daily2EJ + i] + daily26[daily2EA + i],max(0, - (daily21[daily2JR + i] + daily21[daily2JS + i] - daily27[daily2JO + i] - daily21[daily2JP + i] - daily21[daily2JQ + i]))))
    // }

    /// Balance of electricity outside of harm op period
    let daily2JU = 43070
    // JR6+JS6+JT6-JO6-JP6-JQ6
    for i in 0..<365 {
      daily27[daily2JU + i] =
        daily21[daily2JR + i] + daily21[daily2JS + i] + daily27[daily2JT + i] - daily27[daily2JO + i] - daily21[daily2JP + i]
        - daily21[daily2JQ + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily2JV = 43435
    // IF(OR(HS6=0,GZ6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily27[daily2JV + i] = iff(
        or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0,
        daily21[daily2G + i] + (daily21[daily2H + i] - daily21[daily2G + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let daily2JW = 43800
    // IF(OR(HS6=0,GZ6=0),0,EG6)
    for i in 0..<365 {
      daily27[daily2JW + i] = iff(or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0, daily26[daily2EG + i])
    }

    /// heat from el boiler outside of harm op period
    let daily2JX = 44165
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 {
      daily27[daily2JX + i] = iff(
        or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0,
        min(daily26[daily2ER + i] * El_boiler_eff, max(0, daily27[daily2JV + i] - daily21[daily2JW + i])))
    }

    /// Balance of heat outside of harm op period
    let daily2JY = 44530
    // JW6+JX6-JV6
    for i in 0..<365 { daily27[daily2JY + i] = daily21[daily2JW + i] + daily27[daily2JX + i] - daily27[daily2JV + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let daily2JZ = 44895
    // IF(IZ6<=0,0,IZ6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(GZ6<=0,0,(I6+(J6-I6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/MethDist_RawMeth_nom_cons*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily27[daily2JZ + i] =
        iff(
          daily27[daily2IZ + i] <= 0, 0,
          daily27[daily2IZ + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons) * MethDist_harmonious_max_perc
            * MethDist_Meth_nom_prod_ud)
        + iff(
          daily27[daily2GZ + i] <= 0, 0,
          (daily21[daily2I + i]
            + (daily21[daily2J + i] - daily21[daily2I + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily27[daily2GZ + i] - equiv_harmonious_min_perc[j]))
            / MethDist_RawMeth_nom_cons * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let daily2KA = 45260
    // MIN(JH6,IF(OR(HS6=0,GZ6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))+MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))
    for i in 0..<365 {
      daily27[daily2KA + i] =
        min(
          daily21[daily2JH + i],
          iff(
            or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0,
            (daily26[daily2DV + i]
              + (daily26[daily2DW + i] - daily26[daily2DV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily21[daily2HS + i] - Overall_harmonious_min_perc))
          ))
        + min(
          daily21[daily2JU + i], iff(or(daily21[daily2HS + i].isZero, daily27[daily2GZ + i].isZero), 0, daily26[daily2DX + i]))
    }

    /// grid import
    let daily2KB = 45625
    // JF6+JG6+JT6
    for i in 0..<365 { daily27[daily2KB + i] = daily21[daily2JF + i] + daily27[daily2JG + i] + daily27[daily2JT + i] }

    /// Checksum
    let daily2KC = 45990
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    for i in 0..<365 {
      daily27[daily2KC + i] =
        max(0, -daily21[daily2JH + i]) + max(0, -daily27[daily2JN + i]) + max(0, -daily21[daily2JU + i])
        + max(0, -daily27[daily2JY + i])
    }
  }
}
