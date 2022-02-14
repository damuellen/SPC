extension TunOl {
  mutating func daily2(hourly3: [Double], hourly4: [Double]) -> [Double] {
    let daysA = [[Int]]()

    var daily10 = [Double]()

    let hourlyEH = 105120
    let hourlyEX = 236520
    let hourlyEZ = 254040

    /// Day
    let daily1A = 0
    // A5+1
    for i in 0..<365 { daily10[daily1A + i] = daily10[daily1A + i - 1] + 1 }

    // let CQ_CScountZero = hourly3.countOf(hourlyCS, days: daysA, condition: hourlyCQ, predicate: {$0<=0})
    // let CQ_CScountNonZero = hourly3.countOf(hourlyCS, days: daysA, condition: hourlyCQ, predicate: {$0>0})

    var daily11 = [Double](repeating: 0, count: 13_140)
    /// Nr of hours outside of harm op period after min night prep
    let daily1C = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    // for i in 0..<365 { daily11[daily1C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let daily1D = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { daily11[daily1D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let daily1E = 730
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 {
      // daily11[daily1E + i] =  countIFS(Calculationdaily1_[(CS+i)...].prefix(),"="daily10[daily1A + i],Calculationdaily1_[(BX+i)...].prefix(),{!$0.isZero},Calculationdaily1_[(CC+i)...].prefix(),{!$0.isZero})
    }
    let j = 0
    /// Min RawMeth cons during night
    let daily1F = 1095
    // A_RawMeth_min_cons*C6
    for i in 0..<365 { daily11[daily1F + i] = RawMeth_min_cons[j] * daily11[daily1C + i] }

    /// Max RawMeth cons during night
    let daily1G = 1460
    // A_RawMeth_max_cons*C6
    for i in 0..<365 { daily11[daily1G + i] = RawMeth_max_cons[j] * daily11[daily1C + i] }

    /// Min CO2 cons during night
    let daily1H = 1825
    // A_CO2_min_cons*C6
    for i in 0..<365 { daily11[daily1H + i] = C_O_2_min_cons[j] * daily11[daily1C + i] }

    /// Max CO2 cons during night
    let daily1I = 2190
    // A_CO2_max_cons*C6
    for i in 0..<365 { daily11[daily1I + i] = C_O_2_max_cons[j] * daily11[daily1C + i] }

    /// Min H2 cons during night
    let daily1J = 2555
    // A_Hydrogen_min_cons*C6
    for i in 0..<365 { daily11[daily1J + i] = Hydrogen_min_cons[j] * daily11[daily1C + i] }

    /// Max H2 cons during night
    let daily1K = 2920
    // A_Hydrogen_max_cons*C6
    for i in 0..<365 { daily11[daily1K + i] = Hydrogen_max_cons[j] * daily11[daily1C + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily1L = 3285
    // 1-F6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1L + i] = 1 - daily11[daily1F + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1M = 3650
    // 1-G6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1M + i] = 1 - daily11[daily1G + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily1N = 4015
    // 1-H6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1N + i] = 1 - daily11[daily1H + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1O = 4380
    // 1-I6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1O + i] = 1 - daily11[daily1I + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily1P = 4745
    // 1-J6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1P + i] = 1 - daily11[daily1J + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1Q = 5110
    // 1-K6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1Q + i] = 1 - daily11[daily1K + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1R = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily11[daily1R + i] = iff(
        or(daily11[daily1L + i] <= 0, daily11[daily1N + i] <= 0, daily11[daily1P + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1L + i] / (daily11[daily1L + i] - daily11[daily1M + i]), 1),
          ifFinite(daily11[daily1N + i] / (daily11[daily1N + i] - daily11[daily1O + i]), 1),
          ifFinite(daily11[daily1P + i] / (daily11[daily1P + i] - daily11[daily1Q + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    let EX_EZcountZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEX, predicate: {$0<=0})
    /// Nr of hours outside of harm op period after max night prep
    let daily1T = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { daily11[daily1T + i] = EX_EZcountZero[i] }

    let EX_EZcountNonZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEX, predicate: {$0>0})
    /// Nr of harm op period hours after max night prep
    let daily1U = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily11[daily1U + i] = EX_EZcountNonZero[i] }

    let EH_EZcountNonZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEH, predicate: {$0>0})
    /// Nr of PB op hours after max night prep
    let daily1V = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { daily11[daily1V + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let daily1W = 6935
    // A_RawMeth_max_cons*T6
    for i in 0..<365 { daily11[daily1W + i] = RawMeth_max_cons[j] * daily11[daily1T + i] }

    /// Max CO2 cons during night
    let daily1X = 7300
    // A_CO2_max_cons*T6
    for i in 0..<365 { daily11[daily1X + i] = C_O_2_max_cons[j] * daily11[daily1T + i] }

    /// Max H2 cons during night
    let daily1Y = 7665
    // A_Hydrogen_max_cons*T6
    for i in 0..<365 { daily11[daily1Y + i] = Hydrogen_max_cons[j] * daily11[daily1T + i] }

    /// Min el cons during day for night op prep
    let daily1Z = 8030
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+D6*EY_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+D6*CCU_fix_cons+F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+D6*MethSynt_fix_cons
    for i in 0..<365 {
      daily11[daily1Z + i] =
        (daily11[daily1J + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1D + i] * EY_fix_cons
        + (daily11[daily1H + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1D + i] * CCU_fix_cons
        + daily11[daily1F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + daily11[daily1D + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily1AA = 8395
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+U6*EY_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+U6*CCU_fix_cons+W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+U6*MethSynt_fix_cons
    for i in 0..<365 {
      daily11[daily1AA + i] =
        (daily11[daily1Y + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1U + i] * EY_fix_cons
        + (daily11[daily1X + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1U + i] * CCU_fix_cons
        + daily11[daily1W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + daily11[daily1U + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily1AB = 8760
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+D6*EY_heat_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+D6*CCU_fix_heat_cons-F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-D6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily11[daily1AB + i] =
        (daily11[daily1J + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1D + i] * EY_heat_fix_cons
        + (daily11[daily1H + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1D + i] * CCU_fix_heat_cons
        - daily11[daily1F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - daily11[daily1D + i]
        * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily1AC = 9125
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+U6*EY_heat_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+U6*CCU_fix_heat_cons-W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-U6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily11[daily1AC + i] =
        (daily11[daily1Y + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1U + i] * EY_heat_fix_cons
        + (daily11[daily1X + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1U + i] * CCU_fix_heat_cons
        - daily11[daily1W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - daily11[daily1U + i]
        * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily1AD = 9490
    // F6
    for i in 0..<365 { daily11[daily1AD + i] = daily11[daily1F + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily1AE = 9855
    // W6
    for i in 0..<365 { daily11[daily1AE + i] = daily11[daily1W + i] }

    /// Min CO2 prod during day for night op prep
    let daily1AF = 10220
    // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily11[daily1AF + i] =
        daily11[daily1H + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily1AG = 10585
    // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily11[daily1AG + i] =
        daily11[daily1X + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily1AH = 10950
    // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily11[daily1AH + i] =
        daily11[daily1J + i] + daily11[daily1F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily1AI = 11315
    // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily11[daily1AI + i] =
        daily11[daily1Y + i] + daily11[daily1W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1AJ = 11680
    // 1-W6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1AJ + i] = 1 - daily11[daily1W + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1AK = 12045
    // 1-X6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1AK + i] = 1 - daily11[daily1X + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1AL = 12410
    // 1-Y6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1AL + i] = 1 - daily11[daily1Y + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1AM = 12775
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-AJ6),1),IFERROR(N6/(N6-AK6),1),IFERROR(P6/(P6-AL6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily11[daily1AM + i] = iff(
        or(daily11[daily1L + i] <= 0, daily11[daily1N + i] <= 0, daily11[daily1P + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1L + i] / (daily11[daily1L + i] - daily11[daily1AJ + i]), 1),
          ifFinite(daily11[daily1N + i] / (daily11[daily1N + i] - daily10[daily1AK + i]), 1),
          ifFinite(daily11[daily1P + i] / (daily11[daily1P + i] - daily11[daily1AL + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    return daily11
  }
}
