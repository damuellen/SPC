extension TunOl {
  mutating func day(case j: Int, hour2: [Double], hour3: [Double]) -> [Double] {
    let hourBX = 26280
    let hourCC = 70080
    let hourCS = 26280
    let hourCQ = 8760
    let daysCS: [[Int]] =  hour3[hourCS..<(hourCS + 8760)].indices.chunked(by: { hour3[$0] == hour3[$1] })
      .map { $0.map { $0 - hourCS } }
    var day0 = [Double]()
    
    /// Day
    let dayA = 0
    // A5+1
    for i in 0..<365 { day0[dayA + i] = day0[dayA + i - 1] + 1 }

    let CQ_CScountZero = hour3.countOf(daysCS, condition: hourCQ, predicate: {$0<=0})
    let CQ_CScountNonZero = hour3.countOf(daysCS, condition: hourCQ, predicate: {$0>0})

    var day1 = [Double](repeating: 0, count: 13_140)
    /// Nr of hours outside of harm op period after min night prep
    let dayC = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    for i in 0..<365 { day1[dayC + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let dayD = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { day1[dayD + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let dayE = 730
    let opHours = hour2.countOf(daysCS, condition1: hourBX, predicate1: {$0>0}, condition2: hourCC, predicate2: {$0>0})
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 { day1[dayE + i] = opHours[i] }

    /// Min RawMeth cons during night
    let dayF = 1095
    // A_RawMeth_min_cons*C6
    for i in 0..<365 { day1[dayF + i] = RawMeth_min_cons[j] * day1[dayC + i] }

    /// Max RawMeth cons during night
    let dayG = 1460
    // A_RawMeth_max_cons*C6
    for i in 0..<365 { day1[dayG + i] = RawMeth_max_cons[j] * day1[dayC + i] }

    /// Min CO2 cons during night
    let dayH = 1825
    // A_CO2_min_cons*C6
    for i in 0..<365 { day1[dayH + i] = C_O_2_min_cons[j] * day1[dayC + i] }

    /// Max CO2 cons during night
    let dayI = 2190
    // A_CO2_max_cons*C6
    for i in 0..<365 { day1[dayI + i] = C_O_2_max_cons[j] * day1[dayC + i] }

    /// Min H2 cons during night
    let dayJ = 2555
    // A_Hydrogen_min_cons*C6
    for i in 0..<365 { day1[dayJ + i] = Hydrogen_min_cons[j] * day1[dayC + i] }

    /// Max H2 cons during night
    let dayK = 2920
    // A_Hydrogen_max_cons*C6
    for i in 0..<365 { day1[dayK + i] = Hydrogen_max_cons[j] * day1[dayC + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let dayL = 3285
    // 1-F6/RawMeth_storage_cap_ud
    for i in 0..<365 { day1[dayL + i] = 1 - day1[dayF + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let dayM = 3650
    // 1-G6/RawMeth_storage_cap_ud
    for i in 0..<365 { day1[dayM + i] = 1 - day1[dayG + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let dayN = 4015
    // 1-H6/CO2_storage_cap_ud
    for i in 0..<365 { day1[dayN + i] = 1 - day1[dayH + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let dayO = 4380
    // 1-I6/CO2_storage_cap_ud
    for i in 0..<365 { day1[dayO + i] = 1 - day1[dayI + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let dayP = 4745
    // 1-J6/Hydrogen_storage_cap_ud
    for i in 0..<365 { day1[dayP + i] = 1 - day1[dayJ + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let dayQ = 5110
    // 1-K6/Hydrogen_storage_cap_ud
    for i in 0..<365 { day1[dayQ + i] = 1 - day1[dayK + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let dayR = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day1[dayR + i] = iff(
        or(day1[dayL + i] <= 0, day1[dayN + i] <= 0, day1[dayP + i] <= 0), 0,
        min(
          1, ifFinite(day1[dayL + i] / (day1[dayL + i] - day1[dayM + i]), 1),
          ifFinite(day1[dayN + i] / (day1[dayN + i] - day1[dayO + i]), 1),
          ifFinite(day1[dayP + i] / (day1[dayP + i] - day1[dayQ + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
    return day1
  }

  mutating func night(case j: Int, day1: inout [Double], hour3: [Double], hour4: [Double]) {
    let (dayD, dayF, dayH, dayJ, dayL, dayN, dayP, hourEH, hourEX) = (
      365, 1095, 1825, 2555, 3285, 4015, 4745, 105120, 236520
    )
    let daysEZ: [[Int]] = hour4[254040..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] })
      .map { $0.map { $0 - 254040 } }

    let EX_EZcountZero = hour4.countOf(daysEZ, condition: hourEX, predicate: {$0<=0})
    /// Nr of hours outside of harm op period after max night prep
    let dayT = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { day1[dayT + i] = EX_EZcountZero[i] }

    let EX_EZcountNonZero = hour4.countOf(daysEZ, condition: hourEX, predicate: {$0>0})
    /// Nr of harm op period hours after max night prep
    let dayU = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { day1[dayU + i] = EX_EZcountNonZero[i] }

    let EH_EZcountNonZero = hour4.countOf(daysEZ, condition: hourEH, predicate: {$0>0})
    /// Nr of PB op hours after max night prep
    let dayV = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { day1[dayV + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let dayW = 6935
    // A_RawMeth_max_cons*T6
    for i in 0..<365 { day1[dayW + i] = RawMeth_max_cons[j] * day1[dayT + i] }

    /// Max CO2 cons during night
    let dayX = 7300
    // A_CO2_max_cons*T6
    for i in 0..<365 { day1[dayX + i] = C_O_2_max_cons[j] * day1[dayT + i] }

    /// Max H2 cons during night
    let dayY = 7665
    // A_Hydrogen_max_cons*T6
    for i in 0..<365 { day1[dayY + i] = Hydrogen_max_cons[j] * day1[dayT + i] }

    /// Min el cons during day for night op prep
    let dayZ = 8030
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+D6*EY_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+D6*CCU_fix_cons+F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+D6*MethSynt_fix_cons
    for i in 0..<365 {
      day1[dayZ + i] =
        (day1[dayJ + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day1[dayD + i] * EY_fix_cons
        + (day1[dayH + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + day1[dayD + i] * CCU_fix_cons
        + day1[dayF + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day1[dayD + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let dayAA = 8395
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+U6*EY_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+U6*CCU_fix_cons+W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+U6*MethSynt_fix_cons
    for i in 0..<365 {
      day1[dayAA + i] =
        (day1[dayY + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day1[dayU + i] * EY_fix_cons
        + (day1[dayX + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + day1[dayU + i] * CCU_fix_cons
        + day1[dayW + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day1[dayU + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let dayAB = 8760
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+D6*EY_heat_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+D6*CCU_fix_heat_cons-F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-D6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      day1[dayAB + i] =
        (day1[dayJ + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day1[dayD + i] * EY_heat_fix_cons
        + (day1[dayH + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + day1[dayD + i] * CCU_fix_heat_cons
        - day1[dayF + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - day1[dayD + i]
        * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let dayAC = 9125
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+U6*EY_heat_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+U6*CCU_fix_heat_cons-W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-U6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      day1[dayAC + i] =
        (day1[dayY + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day1[dayU + i] * EY_heat_fix_cons
        + (day1[dayX + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + day1[dayU + i] * CCU_fix_heat_cons
        - day1[dayW + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod - day1[dayU + i]
        * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let dayAD = 9490
    // F6
    for i in 0..<365 { day1[dayAD + i] = day1[dayF + i] }

    /// Max Rawmeth prod during day for night op prep
    let dayAE = 9855
    // W6
    for i in 0..<365 { day1[dayAE + i] = day1[dayW + i] }

    /// Min CO2 prod during day for night op prep
    let dayAF = 10220
    // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      day1[dayAF + i] =
        day1[dayH + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let dayAG = 10585
    // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      day1[dayAG + i] =
        day1[dayX + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let dayAH = 10950
    // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      day1[dayAH + i] =
        day1[dayJ + i] + day1[dayF + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let dayAI = 11315
    // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      day1[dayAI + i] =
        day1[dayY + i] + day1[dayW + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let dayAJ = 11680
    // 1-W6/RawMeth_storage_cap_ud
    for i in 0..<365 { day1[dayAJ + i] = 1 - day1[dayW + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let dayAK = 12045
    // 1-X6/CO2_storage_cap_ud
    for i in 0..<365 { day1[dayAK + i] = 1 - day1[dayX + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let dayAL = 12410
    // 1-Y6/Hydrogen_storage_cap_ud
    for i in 0..<365 { day1[dayAL + i] = 1 - day1[dayY + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let dayAM = 12775
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-AJ6),1),IFERROR(N6/(N6-AK6),1),IFERROR(P6/(P6-AL6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day1[dayAM + i] = iff(
        or(day1[dayL + i] <= 0, day1[dayN + i] <= 0, day1[dayP + i] <= 0), 0,
        min(
          1, ifFinite(day1[dayL + i] / (day1[dayL + i] - day1[dayAJ + i]), 1),
          ifFinite(day1[dayN + i] / (day1[dayN + i] - day1[dayAK + i]), 1),
          ifFinite(day1[dayP + i] / (day1[dayP + i] - day1[dayAL + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
  }
}
