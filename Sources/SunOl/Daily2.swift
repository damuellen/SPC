extension TunOl {
  mutating func daily20(j: Int, hourly0: [Double]) -> [Double] {
    let daysA: [[Int]] = hourly0[0..<(8760)].indices.chunked(by: { hourly0[$0] == hourly0[$1] }).map { $0.map { $0 } }
    let daysU: [[Int]] = hourly0[113880..<(113880 + 8760)].indices.chunked(by: { hourly0[$0] == hourly0[$1] })
      .map { $0.map { $0 - 113880 } }

    let hourlyS = 96360

    let hourlyU = 113880

    let S_UcountZero = hourly0.countOf(hourlyU, days: daysA, condition: hourlyS, predicate: { $0 <= 0 })
    let S_UcountNonZero = hourly0.countOf(hourlyU, days: daysA, condition: hourlyS, predicate: { $0 > 0 })
  
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
    return daily21
  }  
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
