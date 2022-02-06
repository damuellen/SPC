extension TunOl {
  func daily1(r0: inout [Double]) {

    /// Day
    let A = 0
    // A5+1
    for i in 0..<365 { r0[A + i] = r0[A + i - 1] + 1 }

  }
}
extension TunOl {
  func daily1(r1: inout [Double]) {
    /// Nr of hours outside of harm op period after min night prep
    let C = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    for i in 0..<365 { r1[C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let D = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r1[D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let E = 730
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 {
      r1[E + i] = countIFS(
        Calculation[(CS + i)...].prefix(), "=" r1[A + i], Calculation[(BX + i)...].prefix(),
        { !$0.isZero }, Calculation[(CC + i)...].prefix(), { !$0.isZero })
    }

    /// Min RawMeth cons during night
    let F = 1095
    // A_RawMeth_min_cons*C6
    for i in 0..<365 { r1[F + i] = RawMeth_min_cons[j] * r1[C + i] }

    /// Max RawMeth cons during night
    let G = 1460
    // A_RawMeth_max_cons*C6
    for i in 0..<365 { r1[G + i] = RawMeth_max_cons[j] * r1[C + i] }

    /// Min CO2 cons during night
    let H = 1825
    // A_CO2_min_cons*C6
    for i in 0..<365 { r1[H + i] = C_O_2_min_cons[j] * r1[C + i] }

    /// Max CO2 cons during night
    let I = 2190
    // A_CO2_max_cons*C6
    for i in 0..<365 { r1[I + i] = C_O_2_max_cons[j] * r1[C + i] }

    /// Min H2 cons during night
    let J = 2555
    // A_Hydrogen_min_cons*C6
    for i in 0..<365 { r1[J + i] = Hydrogen_min_cons[j] * r1[C + i] }

    /// Max H2 cons during night
    let K = 2920
    // A_Hydrogen_max_cons*C6
    for i in 0..<365 { r1[K + i] = Hydrogen_max_cons[j] * r1[C + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let L = 3285
    // 1-F6/RawMeth_storage_cap_ud
    for i in 0..<365 { r1[L + i] = 1 - r1[F + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let M = 3650
    // 1-G6/RawMeth_storage_cap_ud
    for i in 0..<365 { r1[M + i] = 1 - r1[G + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let N = 4015
    // 1-H6/CO2_storage_cap_ud
    for i in 0..<365 { r1[N + i] = 1 - r1[H + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let O = 4380
    // 1-I6/CO2_storage_cap_ud
    for i in 0..<365 { r1[O + i] = 1 - r1[I + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let P = 4745
    // 1-J6/Hydrogen_storage_cap_ud
    for i in 0..<365 { r1[P + i] = 1 - r1[J + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let Q = 5110
    // 1-K6/Hydrogen_storage_cap_ud
    for i in 0..<365 { r1[Q + i] = 1 - r1[K + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let R = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r1[R + i] = iff(
        or(r1[L + i] <= 0, r1[N + i] <= 0, r1[P + i] <= 0), 0,
        min(
          1, ifFinite(r1[L + i] / (r1[L + i] - r1[M + i]), 1),
          ifFinite(r1[N + i] / (r1[N + i] - r1[O + i]), 1),
          ifFinite(r1[P + i] / (r1[P + i] - r1[Q + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }
  }
}
extension TunOl {
  func daily1(r1: [Double], r2: inout [Double]) {
    let D = 365
    let F = 1095
    let N = 4015
    let P = 4745
    /// Nr of hours outside of harm op period after max night prep
    let T = 0
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { r2[T + i] = EX_EZcountZero[i] }

    /// Nr of harm op period hours after max night prep
    let U = 365
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r2[U + i] = EX_EZcountNonZero[i] }

    /// Nr of PB op hours after max night prep
    let V = 730
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { r2[V + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let W = 1095
    // A_RawMeth_max_cons*T6
    for i in 0..<365 { r2[W + i] = RawMeth_max_cons[j] * r2[T + i] }

    /// Max CO2 cons during night
    let X = 1460
    // A_CO2_max_cons*T6
    for i in 0..<365 { r2[X + i] = C_O_2_max_cons[j] * r2[T + i] }

    /// Max H2 cons during night
    let Y = 1825
    // A_Hydrogen_max_cons*T6
    for i in 0..<365 { r2[Y + i] = Hydrogen_max_cons[j] * r2[T + i] }

    /// Min el cons during day for night op prep
    let Z = 2190
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+D6*EY_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+D6*CCU_fix_cons+F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+D6*MethSynt_fix_cons
    for i in 0..<365 {
      r2[Z + i] =
        (r2[J + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + r1[D + i]
        * EY_fix_cons
        + (r2[H + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + r1[D + i]
        * CCU_fix_cons + r1[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + r1[D + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let AA = 2555
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+U6*EY_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+U6*CCU_fix_cons+W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+U6*MethSynt_fix_cons
    for i in 0..<365 {
      r2[AA + i] =
        (r2[Y + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + r2[U + i]
        * EY_fix_cons
        + (r2[X + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + r2[U + i]
        * CCU_fix_cons + r2[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + r2[U + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let AB = 2920
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+D6*EY_heat_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+D6*CCU_fix_heat_cons-F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-D6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      r2[AB + i] =
        (r2[J + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + r1[D + i]
        * EY_heat_fix_cons
        + (r2[H + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + r1[D + i]
        * CCU_fix_heat_cons - r1[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - r1[D + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let AC = 3285
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+U6*EY_heat_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+U6*CCU_fix_heat_cons-W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-U6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      r2[AC + i] =
        (r2[Y + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + r2[U + i]
        * EY_heat_fix_cons
        + (r2[X + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + r2[U + i]
        * CCU_fix_heat_cons - r2[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - r2[U + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let AD = 3650
    // F6
    for i in 0..<365 { r2[AD + i] = r1[F + i] }

    /// Max Rawmeth prod during day for night op prep
    let AE = 4015
    // W6
    for i in 0..<365 { r2[AE + i] = r2[W + i] }

    /// Min CO2 prod during day for night op prep
    let AF = 4380
    // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      r2[AF + i] =
        r2[H + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let AG = 4745
    // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      r2[AG + i] =
        r2[X + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let AH = 5110
    // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      r2[AH + i] =
        r2[J + i] + r1[F + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let AI = 5475
    // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      r2[AI + i] =
        r2[Y + i] + r2[W + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let AJ = 5840
    // 1-W6/RawMeth_storage_cap_ud
    for i in 0..<365 { r2[AJ + i] = 1 - r2[W + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let AK = 6205
    // 1-X6/CO2_storage_cap_ud
    for i in 0..<365 { r2[AK + i] = 1 - r2[X + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let AL = 6570
    // 1-Y6/Hydrogen_storage_cap_ud
    for i in 0..<365 { r2[AL + i] = 1 - r2[Y + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let AM = 6935
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-AJ6),1),IFERROR(N6/(N6-AK6),1),IFERROR(P6/(P6-AL6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r2[AM + i] = iff(
        or(r2[L + i] <= 0, r1[N + i] <= 0, r1[P + i] <= 0), 0,
        min(
          1, ifFinite(r2[L + i] / (r2[L + i] - r2[AJ + i]), 1),
          ifFinite(r1[N + i] / (r1[N + i] - r2[AK + i]), 1),
          ifFinite(r1[P + i] / (r1[P + i] - r2[AL + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

  }
}

extension TunOl {
  func daily1(r9: inout [Double]) {

    /// Available elec after TES chrg during harm op period
    let EY = 0
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 {
      r9[EY + i] = /* CS CQ */ Lsum[i] + /* CC CS */ BXsum[i] - /* CS CQ */ CIsum[i]
    }

    /// Available elec after TES chrg outside harm op period
    let EZ = 365
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 {
      r9[EZ + i] = /* CS CQ */ Lsum[i] + /* CC CS */ BXsum[i] - /* CS CQ */ CIsum[i]
    }

    /// Available heat after TES chrg during harm op period
    let FA = 730
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 {
      r9[FA + i] = /* CS CQ */
        Jsum[i] + /* CC CS */ CBsum[i] / PB_Ratio_Heat_input_vs_output - /* CS CQ */ CJsum[i]
    }

    /// Available heat after TES chrg outside of harm op period
    let FB = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 {
      r9[FB + i] = /* CS CQ */
        Jsum[i] + /* CC CS */ CBsum[i] / PB_Ratio_Heat_input_vs_output - /* CS CQ */ CJsum[i]
    }

    /// Harm el cons considering min harm op during harm op period
    let FC = 1460
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FC + i] = CQsum[i] + /* CS CQ */ CTsum[i] }

    /// Harm el cons considering max harm op during harm op period
    let FD = 1825
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FD + i] = DHsum[i] + /* CS DH */ CTsum[i] }

    /// Harm el cons outside of harm op period
    let FE = 2190
    // SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { r9[FE + i] = /* CS CQ */ CTsum[i] }

    /// Harm heat cons considering min harm op during harm op period
    let FF = 2555
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FF + i] = CRsum[i] + /* CS CQ */ CUsum[i] }

    /// Harm heat cons considering max harm op during harm op period
    let FG = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FG + i] = DIsum[i] + /* CS DH */ CUsum[i] }

    /// Harm heat cons outside of harm op period
    let FH = 3285
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { r9[FH + i] = /* CS CQ */ CUsum[i] }

    /// Grid import considering min harm op during harm op period
    let FI = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FI + i] = /* CS CQ */ CXsum[i] }

    /// Grid import considering max harm op during harm op period
    let FJ = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FJ + i] = /* CS DH */ DLsum[i] }

    /// Grid import  outside of harm op period
    let FK = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { r9[FK + i] = CXsum[i] - r9[FI + i] }

    /// El boiler op considering min harm op during harm op period
    let FL = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FL + i] = /* CS CQ */ CZsum[i] }

    /// El boiler op considering max harm op during harm op period
    let FM = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FM + i] = /* CS DH */ DNsum[i] }

    /// El boiler op outside harm op period
    let FN = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { r9[FN + i] = CZsum[i] - r9[FL + i] }

    /// Total aux cons during harm op period
    let FO = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FO + i] = /* CS CQ */ CMsum[i] }

    /// Total aux cons outside of harm op period
    let FP = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { r9[FP + i] = CMsum[i] - r9[FO + i] }

    /// El cons not covered during harm op period
    let FQ = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FQ + i] = /* CS CQ */ CNsum[i] }

    /// El cons not covered outside of harm op period
    let FR = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { r9[FR + i] = CNsum[i] - r9[FQ + i] }

    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let FS = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FS + i] = /* CS CQ */ CVsum[i] }

    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let FT = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FT + i] = /* CS DH */ DJsum[i] }

    /// Remaining PV el outside of harm op period
    let FU = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { r9[FU + i] = CVsum[i] - r9[FS + i] }

    /// Remaining CSP heat after min harm during harm op period
    let FV = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[FV + i] = /* CS CQ */ CWsum[i] }

    /// Remaining CSP heat after max harm op during harm op period
    let FW = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[FW + i] = /* CS DH */ DKsum[i] }

    /// Remaining CSP heat outside of harm op period
    let FX = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { r9[FX + i] = CWsum[i] - r9[FV + i] }

    /// Max BESS night prep after min harm cons during harm op period
    let FY = 9490
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r9[FY + i] = min( /* CS CQ */DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let FZ = 9855
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r9[FZ + i] = min( /* CS DH */DSsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let GA = 10220
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r9[GA + i] = min( /* CS CQ */DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max grid export after min harm cons during harm op period
    let GB = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GB + i] = /* CS CQ */ DFsum[i] }

    /// Max grid export after max harm cons during harm op period
    let GC = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GC + i] = /* CS DH */ DTsum[i] }

    /// Max grid export outside of harm op period
    let GD = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { r9[GD + i] = DFsum[i] - r9[GB + i] }

    /// Remaining grid import during harm op period after min harm
    let GE = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GE + i] = /* CS CQ */ CYsum[i] }

    /// Remaining grid import during harm op period after max harm
    let GF = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GF + i] = /* CS DH */ DMsum[i] }

    /// Remaining grid import outside of harm op period
    let GG = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { r9[GG + i] = CYsum[i] - r9[GE + i] }

    /// Remaining El boiler cap during harm op period after min harm
    let GH = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GH + i] = /* CS CQ */ DAsum[i] }

    /// Remaining El boiler cap during harm op period after max harm
    let GI = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GI + i] = /* CS DH */ DOsum[i] }

    /// Remaining El boiler cap outside of harm op period
    let GJ = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { r9[GJ + i] = DAsum[i] - r9[GH + i] }

    /// Remaining MethSynt cap during harm op after min harm op
    let GK = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GK + i] = /* CS CQ */ DBsum[i] }

    /// Remaining MethSynt cap during harm op period after max harm op
    let GL = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GL + i] = /* CS DH */ DPsum[i] }

    /// Remaining MethSynt cap outside of harm op period
    let GM = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { r9[GM + i] = DBsum[i] - r9[GK + i] }

    /// Remaining CCU cap during harm op after min harm
    let GN = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GN + i] = /* CS CQ */ DCsum[i] }

    /// Remaining CCU cap during harm op after max harm
    let GO = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GO + i] = /* CS DH */ DQsum[i] }

    /// Remaining CCU cap outside of harm op after min harm
    let GP = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { r9[GP + i] = DCsum[i] - r9[GN + i] }

    /// Remaining EY cap during harm op after min harm
    let GQ = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { r9[GQ + i] = /* CS CQ */ DDsum[i] }

    /// Remaining EY cap during harm op period after max harm
    let GR = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { r9[GR + i] = /* CS DH */ DRsum[i] }

    /// Remaining EY cap outside of harm op period
    let GS = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { r9[GS + i] = DDsum[i] - r9[GQ + i] }

  }
}
extension TunOl {
  func daily1(r10: inout [Double]) {

    /// Available elec after TES chrg during harm op period
    let GU = 0
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 {
      r10[GU + i] = /* EZ EX */ Lsum[i] + /* EZ EX */ EHsum[i] - /* EZ EX */ EPsum[i]
    }

    /// Available elec after TES chrg outside harm op period
    let GV = 365
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 {
      r10[GV + i] = /* EZ EX */ Lsum[i] + /* EZ EX */ EHsum[i] - /* EZ EX */ EPsum[i]
    }

    /// Available heat after TES chrg during harm op period
    let GW = 730
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 {
      r10[GW + i] = /* EZ EX */
        Jsum[i] + /* EZ EX */ EIsum[i] / PB_Ratio_Heat_input_vs_output - /* EZ EX */ EQsum[i]
    }

    /// Available heat after TES chrg outside of harm op period
    let GX = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 {
      r10[GX + i] = /* EZ EX */
        Jsum[i] + /* EZ EX */ EIsum[i] / PB_Ratio_Heat_input_vs_output - /* EZ EX */ EQsum[i]
    }

    /// Harm el cons considering min harm op during harm op period
    let GY = 1460
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[GY + i] = EXsum[i] + /* EZ EX */ FAsum[i] }

    /// Harm el cons considering max harm op during harm op period
    let GZ = 1825
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[GZ + i] = FOsum[i] + /* EZ FO */ FAsum[i] }

    /// Harm el cons outside of harm op period
    let HA = 2190
    // SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { r10[HA + i] = /* EZ EX */ FAsum[i] }

    /// Harm heat cons considering min harm op during harm op period
    let HB = 2555
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HB + i] = EYsum[i] + /* EZ EX */ FBsum[i] }

    /// Harm heat cons considering max harm op during harm op period
    let HC = 2920
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HC + i] = FPsum[i] + /* EZ FO */ FBsum[i] }

    /// Harm heat cons outside of harm op period
    let HD = 3285
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { r10[HD + i] = /* EZ EX */ FBsum[i] }

    /// Grid import considering min harm op during harm op period
    let HE = 3650
    // SUMIFS(CalculationFE5:FE8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HE + i] = /* EZ EX */ FEsum[i] }

    /// Grid import considering max harm op during harm op period
    let HF = 4015
    // SUMIFS(CalculationFS5:FS8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HF + i] = /* EZ FO */ FSsum[i] }

    /// Grid import  outside of harm op period
    let HG = 4380
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFE5:FE8763)-HE6
    for i in 0..<365 { r10[HG + i] = FEsum[i] - r10[HE + i] }

    /// El boiler op considering min harm op during harm op period
    let HH = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HH + i] = /* EZ EX */ FGsum[i] }

    /// El boiler op considering max harm op during harm op period
    let HI = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HI + i] = /* EZ FO */ FUsum[i] }

    /// El boiler op outside harm op period
    let HJ = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    for i in 0..<365 { r10[HJ + i] = FGsum[i] - r10[HH + i] }

    /// Total aux cons during harm op period
    let HK = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HK + i] = /* EZ EX */ ETsum[i] }

    /// Total aux cons outside of harm op period
    let HL = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    for i in 0..<365 { r10[HL + i] = ETsum[i] - r10[HK + i] }

    /// El cons not covered during harm op period
    let HM = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HM + i] = /* EZ EX */ EUsum[i] }

    /// El cons not covered outside of harm op period
    let HN = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    for i in 0..<365 { r10[HN + i] = EUsum[i] - r10[HM + i] }

    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let HO = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HO + i] = /* EZ EX */ FCsum[i] }

    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let HP = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HP + i] = /* EZ FO */ FQsum[i] }

    /// Remaining PV el outside of harm op period
    let HQ = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    for i in 0..<365 { r10[HQ + i] = FCsum[i] - r10[HO + i] }

    /// Remaining CSP heat after min harm during harm op period
    let HR = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HR + i] = /* EZ EX */ FDsum[i] }

    /// Remaining CSP heat after max harm op during harm op period
    let HS = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HS + i] = /* EZ FO */ FRsum[i] }

    /// Remaining CSP heat outside of harm op period
    let HT = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    for i in 0..<365 { r10[HT + i] = FDsum[i] - r10[HR + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let HU = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r10[HU + i] = min( /* EZ EX */FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after max harm op during harm op period
    let HV = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r10[HV + i] = min( /* EZ FO */FZsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep outside of harm op period
    let HW = 10220
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r10[HW + i] = min( /* EZ EX */FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max grid export after min harm cons during harm op period
    let HX = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[HX + i] = /* EZ EX */ FMsum[i] }

    /// Max grid export after max harm cons during harm op period
    let HY = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[HY + i] = /* EZ FO */ GAsum[i] }

    /// Max grid export outside of harm op period
    let HZ = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    for i in 0..<365 { r10[HZ + i] = FMsum[i] - r10[HX + i] }

    /// Remaining grid import during harm op period after min harm
    let IA = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[IA + i] = /* EZ EX */ FFsum[i] }

    /// Remaining grid import during harm op period after max harm
    let IB = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[IB + i] = /* EZ FO */ FTsum[i] }

    /// Remaining grid import outside of harm op period
    let IC = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    for i in 0..<365 { r10[IC + i] = FFsum[i] - r10[IA + i] }

    /// Remaining El boiler cap during harm op period after min harm
    let ID = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[ID + i] = /* EZ EX */ FHsum[i] }

    /// Remaining El boiler cap during harm op period after max harm
    let IE = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[IE + i] = /* EZ FO */ FVsum[i] }

    /// Remaining El boiler cap outside of harm op period
    let IF = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    for i in 0..<365 { r10[IF + i] = FHsum[i] - r10[ID + i] }

    /// Remaining MethSynt cap during harm op after min harm op
    let IG = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[IG + i] = /* EZ EX */ FIsum[i] }

    /// Remaining MethSynt cap during harm op period after max harm op
    let IH = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[IH + i] = /* EZ FO */ FWsum[i] }

    /// Remaining MethSynt cap outside of harm op period
    let II = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    for i in 0..<365 { r10[II + i] = FIsum[i] - r10[IG + i] }

    /// Remaining CCU cap during harm op after min harm
    let IJ = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[IJ + i] = /* EZ EX */ FJsum[i] }

    /// Remaining CCU cap during harm op after max harm
    let IK = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[IK + i] = /* EZ FO */ FXsum[i] }

    /// Remaining CCU cap outside of harm op after min harm
    let IL = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    for i in 0..<365 { r10[IL + i] = FJsum[i] - r10[IJ + i] }

    /// Remaining EY cap during harm op after min harm
    let IM = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { r10[IM + i] = /* EZ EX */ FKsum[i] }

    /// Remaining EY cap during harm op period after max harm
    let IN = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { r10[IN + i] = /* EZ FO */ FYsum[i] }

    /// Remaining EY cap outside of harm op period
    let IO = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    for i in 0..<365 { r10[IO + i] = FKsum[i] - r10[IM + i] }

  }
}
extension TunOl {
  func daily1(r11: inout [Double]) {

    /// Surplus harm op period electricity after min harm op and min night op prep
    let IQ = 0
    // FS6+GE6-Z6-MAX(0,AB6-FV6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      r11[IQ + i] =
        r11[FS + i] + r11[GE + i] - r11[Z + i] - max(0, r11[AB + i] - r11[FV + i]) / El_boiler_eff
        - r11[FR + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after min harm op and max night op prep
    let IR = 365
    // HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-HN6/BESS_chrg_eff
    for i in 0..<365 {
      r11[IR + i] =
        r11[HO + i] + r11[IA + i]
        - (r11[Z + i]
          + (r11[AA + i] - r11[Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
        - max(
          0,
          (r11[AB + i]
            + (r11[AC + i] - r11[AB + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r11[AM + i] - equiv_harmonious_min_perc[j]))
            - r11[HR + i]) / El_boiler_eff - r11[HN + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let IS = 730
    // FT6+GF6-Z6-MAX(0,AB6-FW6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      r11[IS + i] =
        r11[FT + i] + r11[GF + i] - r11[Z + i] - max(0, r11[AB + i] - r11[FW + i]) / El_boiler_eff
        - r11[FR + i] / BESS_chrg_eff
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let IT = 1095
    // FV6+MAX(0,FS6+GE6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      r11[IT + i] =
        r11[FV + i] + max(0, r11[FS + i] + r11[GE + i] - r11[Z + i] - r11[FR + i] / BESS_chrg_eff)
        * El_boiler_eff - r11[AB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let IU = 1460
    // HR6+MAX(0,HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[IU + i] =
        r11[HR + i] + max(
          0,
          r11[HO + i] + r11[IA + i]
            - (r11[Z + i]
              + (r11[AA + i] - r11[Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r11[AM + i] - equiv_harmonious_min_perc[j]))
            - r11[HN + i] / BESS_chrg_eff) * El_boiler_eff
        - (r11[AB + i]
          + (r11[AC + i] - r11[AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let IV = 1825
    // FW6+MAX(0,FT6+GF6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      r11[IV + i] =
        r11[FW + i] + max(0, r11[FT + i] + r11[GF + i] - r11[Z + i] - r11[FR + i] / BESS_chrg_eff)
        * El_boiler_eff - r11[AB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let IW = 2190
    // GH6-(AB6-FV6)/El_boiler_eff
    for i in 0..<365 { r11[IW + i] = r11[GH + i] - (r11[AB + i] - r11[FV + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep
    let IX = 2555
    // ID6-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 {
      r11[IX + i] =
        r11[ID + i]
        - ((r11[AB + i]
          + (r11[AC + i] - r11[AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
          - r11[HR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let IY = 2920
    // GI6-(AB6-FW6)/El_boiler_eff
    for i in 0..<365 { r11[IY + i] = r11[GI + i] - (r11[AB + i] - r11[FW + i]) / El_boiler_eff }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let IZ = 3285
    // FY6-FR6/BESS_chrg_eff
    for i in 0..<365 { r11[IZ + i] = r11[FY + i] - r11[FR + i] / BESS_chrg_eff }

    /// Surplus BESS chrg cap after min harm op and max night op prep
    let JA = 3650
    // HU6-HN6/BESS_chrg_eff
    for i in 0..<365 { r11[JA + i] = r11[HU + i] - r11[HN + i] / BESS_chrg_eff }

    /// Surplus BESS chrg cap after max harm op and min night op prep
    let JB = 4015
    // FZ6-FR6/BESS_chrg_eff
    for i in 0..<365 { r11[JB + i] = r11[FZ + i] - r11[FR + i] / BESS_chrg_eff }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let JC = 4380
    // GK6-AD6
    for i in 0..<365 { r11[JC + i] = r11[GK + i] - r11[AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let JD = 4745
    // IG6-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[JD + i] =
        r11[IG + i]
        - (r11[AD + i]
          + (r11[AE + i] - r11[AD + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let JE = 5110
    // GL6-AD6
    for i in 0..<365 { r11[JE + i] = r11[GL + i] - r11[AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let JF = 5475
    // GN6-AF6
    for i in 0..<365 { r11[JF + i] = r11[GN + i] - r11[AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let JG = 5840
    // IJ6-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[JG + i] =
        r11[IJ + i]
        - (r11[AF + i]
          + (r11[AG + i] - r11[AF + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let JH = 6205
    // GO6-AF6
    for i in 0..<365 { r11[JH + i] = r11[GO + i] - r11[AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let JI = 6570
    // GQ6-AH6
    for i in 0..<365 { r11[JI + i] = r11[GQ + i] - r11[AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let JJ = 6935
    // IM6-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[JJ + i] =
        r11[IM + i]
        - (r11[AH + i]
          + (r11[AI + i] - r11[AH + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let JK = 7300
    // GR6-AH6
    for i in 0..<365 { r11[JK + i] = r11[GR + i] - r11[AH + i] }

  }
}
extension TunOl {
  func daily1(r12: inout [Double]) {

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let JM = 0
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IS6),1),IFERROR(IT6/(IT6-IV6),1),IFERROR(IW6/(IW6-IY6),1),IFERROR(IZ6/(IZ6-JB6),1),IFERROR(JC6/(JC6-JE6),1),IFERROR(JF6/(JF6-JH6),1),IFERROR(JI6/(JI6-JK6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      r12[JM + i] = iff(
        or(
          r12[IQ + i] < 0, r12[IT + i] < 0, r12[IW + i] < 0, r12[IZ + i] < 0, r12[JC + i] < 0,
          r12[JF + i] < 0, r12[JI + i] < 0), 0,
        min(
          1, ifFinite(r12[IQ + i] / (r12[IQ + i] - r12[IS + i]), 1),
          ifFinite(r12[IT + i] / (r12[IT + i] - r12[IV + i]), 1),
          ifFinite(r12[IW + i] / (r12[IW + i] - r12[IY + i]), 1),
          ifFinite(r12[IZ + i] / (r12[IZ + i] - r12[JB + i]), 1),
          ifFinite(r12[JC + i] / (r12[JC + i] - r12[JE + i]), 1),
          ifFinite(r12[JF + i] / (r12[JF + i] - r12[JH + i]), 1),
          ifFinite(r12[JI + i] / (r12[JI + i] - r12[JK + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let JN = 365
    // IF(JM6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-MAX(0,AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      r12[JN + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[FS + i]
            + (r12[FT + i] - r12[FS + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            + (r12[GE + i]
              + (r12[GF + i] - r12[GE + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[Z + i] - max(
              0,
              r12[AB + i]
                - (r12[FV + i]
                  + (r12[FW + i] - r12[FV + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r12[JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - r12[FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let JO = 730
    // IF(JM6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      r12[JO + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[HO + i]
            + (r12[HP + i] - r12[HO + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            + (r12[IA + i]
              + (r12[IB + i] - r12[IA + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r12[JM + i] - Overall_harmonious_min_perc))
            - (r12[Z + i]
              + (r12[AA + i] - r12[Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (r12[AB + i]
                + (r12[AC + i] - r12[AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r12[AM + i] - equiv_harmonious_min_perc[j]))
                - (r12[HR + i]
                  + (r12[HS + i] - r12[HR + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r12[JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - r12[HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let JP = 1095
    // IF(JM6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6,5))
    for i in 0..<365 {
      r12[JP + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[FV + i]
            + (r12[FW + i] - r12[FV + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (r12[FS + i]
                + (r12[FT + i] - r12[FS + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r12[JM + i] - Overall_harmonious_min_perc))
                + (r12[GE + i]
                  + (r12[GF + i] - r12[GE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r12[JM + i] - Overall_harmonious_min_perc))
                - r12[Z + i] - r12[FR + i] / BESS_chrg_eff) * El_boiler_eff - r12[AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let JQ = 1460
    // IF(JM6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r12[JQ + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[HR + i]
            + (r12[HS + i] - r12[HR + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (r12[HO + i]
                + (r12[HP + i] - r12[HO + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r12[JM + i] - Overall_harmonious_min_perc))
                + (r12[IA + i]
                  + (r12[IB + i] - r12[IA + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r12[JM + i] - Overall_harmonious_min_perc))
                - (r12[Z + i]
                  + (r12[AA + i] - r12[Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r12[AM + i] - equiv_harmonious_min_perc[j]))
                - r12[HN + i] / BESS_chrg_eff) * El_boiler_eff
            - (r12[AB + i]
              + (r12[AC + i] - r12[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let JR = 1825
    // IF(JM6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r12[JR + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[GH + i]
            + (r12[GI + i] - r12[GH + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - (r12[AB + i]
              - (r12[FV + i]
                + (r12[FW + i] - r12[FV + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r12[JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let JS = 2190
    // IF(JM6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r12[JS + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[ID + i]
            + (r12[IE + i] - r12[ID + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - ((r12[AB + i]
              + (r12[AC + i] - r12[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j]))
              - (r12[HR + i]
                + (r12[HS + i] - r12[HR + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r12[JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let JT = 2555
    // IF(JM6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      r12[JT + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[FY + i]
            + (r12[FZ + i] - r12[FY + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let JU = 2920
    // IF(JM6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      r12[JU + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[HU + i]
            + (r12[HV + i] - r12[HU + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let JV = 3285
    // IF(JM6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AD6,5))
    for i in 0..<365 {
      r12[JV + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[GK + i]
            + (r12[GL + i] - r12[GK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[AD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let JW = 3650
    // IF(JM6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r12[JW + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          r12[GK + i] + (r12[GL + i] - r12[GK + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (r12[JM + i] - Overall_harmonious_min_perc)
            - (r12[AD + i]
              + (r12[AE + i] - r12[AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let JX = 4015
    // IF(JM6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AF6,5))
    for i in 0..<365 {
      r12[JX + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[GN + i]
            + (r12[GO + i] - r12[GN + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[AF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let JY = 4380
    // IF(JM6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r12[JY + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          r12[GN + i] + (r12[GO + i] - r12[GN + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (r12[JM + i] - Overall_harmonious_min_perc)
            - (r12[AF + i]
              + (r12[AG + i] - r12[AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let JZ = 4745
    // IF(JM6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AH6,5))
    for i in 0..<365 {
      r12[JZ + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          (r12[GQ + i]
            + (r12[GR + i] - r12[GQ + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r12[JM + i] - Overall_harmonious_min_perc))
            - r12[AH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let KA = 5110
    // IF(JM6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r12[KA + i] = iff(
        r12[JM + i] = 0, 0,
        round(
          r12[GQ + i] + (r12[GR + i] - r12[GQ + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (r12[JM + i] - Overall_harmonious_min_perc)
            - (r12[AH + i]
              + (r12[AI + i] - r12[AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r12[AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt night prep during day prio operation
    let KB = 5475
    // IF(OR(JM6=0,JN6<0,JP6<0,JR6<0,JT6<0,JV6<0,JX6<0,JZ6<0),0,MIN(1,IFERROR(JN6/(JN6-JO6),1),IFERROR(JP6/(JP6-JQ6),1),IFERROR(JR6/(JR6-JS6),1),IFERROR(JT6/(JT6-JU6),1),IFERROR(JV6/(JV6-JW6),1),IFERROR(JX6/(JX6-JY6),1),IFERROR(JZ6/(JZ6-KA6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r12[KB + i] = iff(
        or(
          r12[JM + i] = 0, r12[JN + i] < 0, r12[JP + i] < 0, r12[JR + i] < 0, r12[JT + i] < 0,
          r12[JV + i] < 0, r12[JX + i] < 0, r12[JZ + i] < 0), 0,
        min(
          1, ifFinite(r12[JN + i] / (r12[JN + i] - r12[JO + i]), 1),
          ifFinite(r12[JP + i] / (r12[JP + i] - r12[JQ + i]), 1),
          ifFinite(r12[JR + i] / (r12[JR + i] - r12[JS + i]), 1),
          ifFinite(r12[JT + i] / (r12[JT + i] - r12[JU + i]), 1),
          ifFinite(r12[JV + i] / (r12[JV + i] - r12[JW + i]), 1),
          ifFinite(r12[JX + i] / (r12[JX + i] - r12[JY + i]), 1),
          ifFinite(r12[JZ + i] / (r12[JZ + i] - r12[KA + i]), 1))
          * (r12[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

  }
}
extension TunOl {
  func daily1(r13: inout [Double]) {

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let KD = 0
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IR6),1),IFERROR(IT6/(IT6-IU6),1),IFERROR(IW6/(IW6-IX6),1),IFERROR(IZ6/(IZ6-JA6),1),IFERROR(JC6/(JC6-JD6),1),IFERROR(JF6/(JF6-JG6),1),IFERROR(JI6/(JI6-JJ6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r13[KD + i] = iff(
        or(
          r13[IQ + i] < 0, r13[IT + i] < 0, r13[IW + i] < 0, r13[IZ + i] < 0, r13[JC + i] < 0,
          r13[JF + i] < 0, r13[JI + i] < 0), 0,
        min(
          1, ifFinite(r13[IQ + i] / (r13[IQ + i] - r13[IR + i]), 1),
          ifFinite(r13[IT + i] / (r13[IT + i] - r13[IU + i]), 1),
          ifFinite(r13[IW + i] / (r13[IW + i] - r13[IX + i]), 1),
          ifFinite(r13[IZ + i] / (r13[IZ + i] - r13[JA + i]), 1),
          ifFinite(r13[JC + i] / (r13[JC + i] - r13[JD + i]), 1),
          ifFinite(r13[JF + i] / (r13[JF + i] - r13[JG + i]), 1),
          ifFinite(r13[JI + i] / (r13[JI + i] - r13[JJ + i]), 1))
          * (r13[AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let KE = 365
    // IF(KD6=0,0,ROUND((FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      r13[KE + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FS + i]
            + (r13[HO + i] - r13[FS + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            + (r13[GE + i]
              + (r13[IA + i] - r13[GE + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[Z + i]
              + (r13[AA + i] - r13[Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (r13[AB + i]
                + (r13[AC + i] - r13[AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - (r13[FV + i]
                  + (r13[HR + i] - r13[FV + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (r13[FR + i]
              + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let KF = 730
    // IF(KD6=0,0,ROUND((FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      r13[KF + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FT + i]
            + (r13[HP + i] - r13[FT + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            + (r13[GF + i]
              + (r13[IB + i] - r13[GF + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[Z + i]
              + (r13[AA + i] - r13[Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (r13[AB + i]
                + (r13[AC + i] - r13[AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - (r13[FW + i]
                  + (r13[HS + i] - r13[FW + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (r13[FR + i]
              + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let KG = 1095
    // IF(KD6=0,0,ROUND((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KG + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FV + i]
            + (r13[HR + i] - r13[FV + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (r13[FS + i]
                + (r13[HO + i] - r13[FS + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                + (r13[GE + i]
                  + (r13[IA + i] - r13[GE + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - (r13[Z + i]
                  + (r13[AA + i] - r13[Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - ((r13[FR + i]
                  + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (r13[AB + i]
              + (r13[AC + i] - r13[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let KH = 1460
    // IF(KD6=0,0,ROUND((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KH + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FW + i]
            + (r13[HS + i] - r13[FW + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (r13[FT + i]
                + (r13[HP + i] - r13[FT + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                + (r13[GF + i]
                  + (r13[IB + i] - r13[GF + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - (r13[Z + i]
                  + (r13[AA + i] - r13[Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                - ((r13[FR + i]
                  + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                    * (r13[KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (r13[AB + i]
              + (r13[AC + i] - r13[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let KI = 1825
    // IF(KD6=0,0,ROUND((GH6+(ID6-GH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r13[KI + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GH + i]
            + (r13[ID + i] - r13[GH + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - ((r13[AB + i]
              + (r13[AC + i] - r13[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              - (r13[FV + i]
                + (r13[HR + i] - r13[FV + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let KJ = 2190
    // IF(KD6=0,0,ROUND((GI6+(IE6-GI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r13[KJ + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GI + i]
            + (r13[IE + i] - r13[GI + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - ((r13[AB + i]
              + (r13[AC + i] - r13[AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              - (r13[FW + i]
                + (r13[HS + i] - r13[FW + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                  * (r13[KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let KK = 2555
    // IF(KD6=0,0,ROUND((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      r13[KK + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FY + i]
            + (r13[HU + i] - r13[FY + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[FR + i]
              + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let KL = 2920
    // IF(KD6=0,0,ROUND((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      r13[KL + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[FZ + i]
            + (r13[HV + i] - r13[FZ + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[FR + i]
              + (r13[HN + i] - r13[FR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let KM = 3285
    // IF(KD6=0,0,ROUND((GK6+(IG6-GK6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KM + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GK + i]
            + (r13[IG + i] - r13[GK + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AD + i]
              + (r13[AE + i] - r13[AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let KN = 3650
    // IF(KD6=0,0,ROUND((GL6+(IH6-GL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KN + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GL + i]
            + (r13[IH + i] - r13[GL + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AD + i]
              + (r13[AE + i] - r13[AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let KO = 4015
    // IF(KD6=0,0,ROUND((GN6+(IJ6-GN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KO + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GN + i]
            + (r13[IJ + i] - r13[GN + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AF + i]
              + (r13[AG + i] - r13[AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let KP = 4380
    // IF(KD6=0,0,ROUND((GO6+(IK6-GO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KP + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GO + i]
            + (r13[IK + i] - r13[GO + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AF + i]
              + (r13[AG + i] - r13[AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let KQ = 4745
    // IF(KD6=0,0,ROUND((GQ6+(IM6-GQ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KQ + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GQ + i]
            + (r13[IM + i] - r13[GQ + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AH + i]
              + (r13[AI + i] - r13[AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let KR = 5110
    // IF(KD6=0,0,ROUND((GR6+(IN6-GR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r13[KR + i] = iff(
        r13[KD + i] = 0, 0,
        round(
          (r13[GR + i]
            + (r13[IN + i] - r13[GR + i]) / (r13[AM + i] - equiv_harmonious_min_perc[j])
              * (r13[KD + i] - equiv_harmonious_min_perc[j]))
            - (r13[AH + i]
              + (r13[AI + i] - r13[AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r13[KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let KS = 5475
    // IF(KD6<=0,0,MIN(1,IFERROR(KE6/(KE6-KF6),1),IFERROR(KG6/(KG6-KH6),1),IFERROR(KI6/(KI6-KJ6),1),IFERROR(KK6/(KK6-KL6),1),IFERROR(KM6/(KM6-KN6),1),IFERROR(KO6/(KO6-KP6),1),IFERROR(KQ6/(KQ6-KR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      r13[KS + i] = iff(
        r13[KD + i] <= 0, 0,
        min(
          1, ifFinite(r13[KE + i] / (r13[KE + i] - r13[KF + i]), 1),
          ifFinite(r13[KG + i] / (r13[KG + i] - r13[KH + i]), 1),
          ifFinite(r13[KI + i] / (r13[KI + i] - r13[KJ + i]), 1),
          ifFinite(r13[KK + i] / (r13[KK + i] - r13[KL + i]), 1),
          ifFinite(r13[KM + i] / (r13[KM + i] - r13[KN + i]), 1),
          ifFinite(r13[KO + i] / (r13[KO + i] - r13[KP + i]), 1),
          ifFinite(r13[KQ + i] / (r13[KQ + i] - r13[KR + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }

  }
}
extension TunOl {
  func daily1(r14: inout [Double]) {

    /// el cons for harm op during harm op period
    let KU = 0
    // IF(OR(JM6=0,KB6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r14[KU + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[FC + i]
          + (r14[GY + i] - r14[FC + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
          + ((r14[FD + i]
            + (r14[GZ + i] - r14[FD + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            - (r14[FC + i]
              + (r14[GY + i] - r14[FC + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r14[JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let KV = 365
    // IF(OR(JM6=0,KB6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[KV + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[Z + i]
          + (r14[AA + i] - r14[Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let KW = 730
    // IF(OR(JM6=0,KB6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[KW + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FO + i] + (r14[HK + i] - r14[FO + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let KX = 1095
    // IF(OR(JM6=0,KB6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      r14[KX + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        min(
          ((r14[FY + i]
            + (r14[HU + i] - r14[FY + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            + ((r14[FZ + i]
              + (r14[HV + i] - r14[FZ + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j]))
              - (r14[FY + i]
                + (r14[HU + i] - r14[FY + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                  * (r14[KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r14[JM + i] - Overall_harmonious_min_perc)),
          (r14[FR + i]
            + (r14[HN + i] - r14[FR + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let KY = 1460
    // IF(OR(JM6=0,KB6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r14[KY + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[FL + i]
          + (r14[HH + i] - r14[FL + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
          + ((r14[FM + i]
            + (r14[HI + i] - r14[FM + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            - (r14[FL + i]
              + (r14[HH + i] - r14[FL + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r14[JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let KZ = 1825
    // LH6/El_boiler_eff
    for i in 0..<365 { r14[KZ + i] = r14[LH + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let LA = 2190
    // IF(OR(JM6=0,KB6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LA + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[EY + i] + (r14[GU + i] - r14[EY + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let LB = 2555
    // IF(OR(JM6=0,KB6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r14[LB + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[FI + i]
          + (r14[HE + i] - r14[FI + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
          + ((r14[FJ + i]
            + (r14[HF + i] - r14[FJ + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            - (r14[FI + i]
              + (r14[HE + i] - r14[FI + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r14[JM + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let LC = 2920
    // IF(OR(JM6=0,KB6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc),MAX(0,-(LA6+LB6-KU6-KV6-KW6-KX6-KY6-KZ6))))
    for i in 0..<365 {
      r14[LC + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        min(
          (r14[GE + i]
            + (r14[IA + i] - r14[GE + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            + ((r14[GF + i]
              + (r14[IB + i] - r14[GF + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j]))
              - (r14[GE + i]
                + (r14[IA + i] - r14[GE + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                  * (r14[KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r14[JM + i] - Overall_harmonious_min_perc),
          max(
            0,
            -(r14[LA + i] + r14[LB + i] - r14[KU + i] - r14[KV + i] - r14[KW + i] - r14[KX + i]
              - r14[KY + i] - r14[KZ + i]))))
    }

    /// Balance of electricity during harm op period
    let LD = 3285
    // LA6+LB6+LC6-KU6-KV6-KW6-KX6-KY6-KZ6
    for i in 0..<365 {
      r14[LD + i] =
        r14[LA + i] + r14[LB + i] + r14[LC + i] - r14[KU + i] - r14[KV + i] - r14[KW + i]
        - r14[KX + i] - r14[KY + i] - r14[KZ + i]
    }

    /// heat cons for harm op during harm op period
    let LE = 3650
    // IF(OR(JM6=0,KB6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r14[LE + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[FF + i]
          + (r14[HB + i] - r14[FF + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
          + ((r14[FG + i]
            + (r14[HC + i] - r14[FG + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]))
            - (r14[FF + i]
              + (r14[HB + i] - r14[FF + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r14[JM + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let LF = 4015
    // IF(OR(JM6=0,KB6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[LF + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        (r14[AB + i]
          + (r14[AC + i] - r14[AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let LG = 4380
    // IF(OR(JM6=0,KB6=0),0,KY6*El_boiler_eff)
    for i in 0..<365 {
      r14[LG + i] = iff(or(r14[JM + i] = 0, r14[KB + i] = 0), 0, r14[KY + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let LH = 4745
    // IF(OR(JM6=0,KB6=0),0,MAX(0,LF6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      r14[LH + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        max(
          0,
          r14[LF + i]
            - ((r14[FV + i]
              + (r14[HR + i] - r14[FV + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j]))
              + ((r14[FW + i]
                + (r14[HS + i] - r14[FW + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                  * (r14[KB + i] - equiv_harmonious_min_perc[j]))
                - (r14[FV + i]
                  + (r14[HR + i] - r14[FV + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                    * (r14[KB + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r14[JM + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let LI = 5110
    // IF(OR(JM6=0,KB6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LI + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FA + i] + (r14[GW + i] - r14[FA + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let LJ = 5475
    // LG6+LH6+LI6-LE6-LF6
    for i in 0..<365 {
      r14[LJ + i] = r14[LG + i] + r14[LH + i] + r14[LI + i] - r14[LE + i] - r14[LF + i]
    }

    /// el cons for harm op outside of harm op period
    let LK = 5840
    // IF(OR(JM6=0,KB6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LK + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FE + i] + (r14[HA + i] - r14[FE + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let LL = 6205
    // IF(OR(JM6=0,KB6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LL + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FP + i] + (r14[HL + i] - r14[FP + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let LM = 6570
    // IF(OR(JM6=0,KB6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LM + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FN + i] + (r14[HJ + i] - r14[FN + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let LN = 6935
    // KX6*BESS_chrg_eff
    for i in 0..<365 { r14[LN + i] = r14[KX + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let LO = 7300
    // IF(OR(JM6=0,KB6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LO + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[EZ + i] + (r14[GV + i] - r14[EZ + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let LP = 7665
    // IF(OR(JM6=0,KB6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc),MAX(0,-(LN6+LO6-LK6-LL6-LM6))))
    for i in 0..<365 {
      r14[LP + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        min(
          r14[GG + i]
            + (r14[IC + i] - r14[GG + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j]),
          max(0, -(r14[LN + i] + r14[LO + i] - r14[LK + i] - r14[LL + i] - r14[LM + i]))))
    }

    /// Balance of electricity outside of harm op period
    let LQ = 8030
    // LN6+LO6+LP6-LK6-LL6-LM6
    for i in 0..<365 {
      r14[LQ + i] =
        r14[LN + i] + r14[LO + i] + r14[LP + i] - r14[LK + i] - r14[LL + i] - r14[LM + i]
    }

    /// heat cons for harm op outside of harm op period
    let LR = 8395
    // IF(OR(JM6=0,KB6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LR + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FH + i] + (r14[HD + i] - r14[FH + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let LS = 8760
    // IF(OR(JM6=0,KB6=0),0,LM6*El_boiler_eff)
    for i in 0..<365 {
      r14[LS + i] = iff(or(r14[JM + i] = 0, r14[KB + i] = 0), 0, r14[LM + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let LT = 9125
    // IF(OR(JM6=0,KB6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r14[LT + i] = iff(
        or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
        r14[FB + i] + (r14[GX + i] - r14[FB + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
          * (r14[KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let LU = 9490
    // LS6+LT6-LR6
    for i in 0..<365 { r14[LU + i] = r14[LS + i] + r14[LT + i] - r14[LR + i] }

    /// Pure Methanol prod with day priority and resp night op
    let LV = 9855
    // IF(KU6<=0,0,KU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(LK6<=0,0,(LK6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      r14[LV + i] =
        iff(
          r14[KU + i] <= 0, 0,
          r14[KU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          r14[LK + i] <= 0, 0,
          (r14[LK + i] - overall_stup_cons[j])
            / (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * MethDist_max_perc[j]
            * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let LW = 10220
    // MIN(LD6,IF(OR(JM6=0,KB6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))+MIN(LQ6,IF(OR(JM6=0,KB6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[LW + i] =
        min(
          r14[LD + i],
          iff(
            or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
            (r14[GB + i]
              + (r14[HX + i] - r14[GB + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                * (r14[KB + i] - equiv_harmonious_min_perc[j]))
              + ((r14[GC + i]
                + (r14[HY + i] - r14[GC + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                  * (r14[KB + i] - equiv_harmonious_min_perc[j]))
                - (r14[GB + i]
                  + (r14[HX + i] - r14[GB + i]) / (r14[AM + i] - equiv_harmonious_min_perc[j])
                    * (r14[KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r14[JM + i] - Overall_harmonious_min_perc)))
        + min(
          r14[LQ + i],
          iff(
            or(r14[JM + i] = 0, r14[KB + i] = 0), 0,
            r14[GD + i] + (r14[HZ + i] - r14[GD + i])
              / (r14[AM + i] - equiv_harmonious_min_perc[j])
              * (r14[KB + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let LX = 10585
    // LP6+LC6
    for i in 0..<365 { r14[LX + i] = r14[LP + i] + r14[LC + i] }

    /// Outside harmonious operation period hours
    let LY = 10950
    // IF(KB6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[LY + i] = iff(
        r14[KB + i] <= 0, 0,
        (r14[C + i]
          + (r14[T + i] - r14[C + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let LZ = 11315
    // IF(KB6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[LZ + i] = iff(
        r14[KB + i] <= 0, 0,
        (r14[D + i]
          + (r14[U + i] - r14[D + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let MA = 11680
    // IF(KB6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r14[MA + i] = iff(
        r14[KB + i] <= 0, 0,
        (r14[E + i]
          + (r14[V + i] - r14[E + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r14[KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let MB = 12045
    // MAX(0,-LD6)+MAX(0,-LJ6)+MAX(0,-LQ6)+MAX(0,-LU6)
    for i in 0..<365 {
      r14[MB + i] =
        max(0, -r14[LD + i]) + max(0, -r14[LJ + i]) + max(0, -r14[LQ + i]) + max(0, -r14[LU + i])
    }

  }
}
extension TunOl {
  func daily1(r15: inout [Double]) {

    /// el cons for harm op during harm op period
    let MD = 0
    // IF(OR(KS6=0,KD6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r15[MD + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        (r15[FC + i]
          + (r15[GY + i] - r15[FC + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
          + ((r15[FD + i]
            + (r15[GZ + i] - r15[FD + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            - (r15[FC + i]
              + (r15[GY + i] - r15[FC + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r15[KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let ME = 365
    // IF(OR(KS6=0,KD6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[ME + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        (r15[Z + i]
          + (r15[AA + i] - r15[Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let MF = 730
    // IF(OR(KS6=0,KD6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MF + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FO + i] + (r15[HK + i] - r15[FO + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let MG = 1095
    // IF(OR(KS6=0,KD6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      r15[MG + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        min(
          ((r15[FY + i]
            + (r15[HU + i] - r15[FY + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            + ((r15[FZ + i]
              + (r15[HV + i] - r15[FZ + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j]))
              - (r15[FY + i]
                + (r15[HU + i] - r15[FY + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                  * (r15[KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r15[KS + i] - Overall_harmonious_min_perc)),
          (r15[FR + i]
            + (r15[HN + i] - r15[FR + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let MH = 1460
    // IF(OR(KS6=0,KD6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r15[MH + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        (r15[FL + i]
          + (r15[HH + i] - r15[FL + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
          + ((r15[FM + i]
            + (r15[HI + i] - r15[FM + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            - (r15[FL + i]
              + (r15[HH + i] - r15[FL + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r15[KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let MI = 1825
    // MQ6/El_boiler_eff
    for i in 0..<365 { r15[MI + i] = r15[MQ + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let MJ = 2190
    // IF(OR(KS6=0,KD6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MJ + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[EY + i] + (r15[GU + i] - r15[EY + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let MK = 2555
    // IF(OR(KD6=0,KS6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r15[MK + i] = iff(
        or(r15[KD + i] = 0, r15[KS + i] = 0), 0,
        (r15[FI + i]
          + (r15[HE + i] - r15[FI + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
          + ((r15[FJ + i]
            + (r15[HF + i] - r15[FJ + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            - (r15[FI + i]
              + (r15[HE + i] - r15[FI + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r15[KS + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let ML = 2920
    // IF(OR(KD6=0,KS6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc),MAX(0,-(MJ6+MK6-MD6-ME6-MF6-MG6-MH6-MI6))))
    for i in 0..<365 {
      r15[ML + i] = iff(
        or(r15[KD + i] = 0, r15[KS + i] = 0), 0,
        min(
          (r15[GE + i]
            + (r15[IA + i] - r15[GE + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            + ((r15[GF + i]
              + (r15[IB + i] - r15[GF + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j]))
              - (r15[GE + i]
                + (r15[IA + i] - r15[GE + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                  * (r15[KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r15[KS + i] - Overall_harmonious_min_perc),
          max(
            0,
            -(r15[MJ + i] + r15[MK + i] - r15[MD + i] - r15[ME + i] - r15[MF + i] - r15[MG + i]
              - r15[MH + i] - r15[MI + i]))))
    }

    /// Balance of electricity during harm op period
    let MM = 3285
    // MJ6+MK6+ML6-MD6-ME6-MF6-MG6-MH6-MI6
    for i in 0..<365 {
      r15[MM + i] =
        r15[MJ + i] + r15[MK + i] + r15[ML + i] - r15[MD + i] - r15[ME + i] - r15[MF + i]
        - r15[MG + i] - r15[MH + i] - r15[MI + i]
    }

    /// heat cons for harm op during harm op period
    let MN = 3650
    // IF(OR(KS6=0,KD6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r15[MN + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        (r15[FF + i]
          + (r15[HB + i] - r15[FF + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
          + ((r15[FG + i]
            + (r15[HC + i] - r15[FG + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]))
            - (r15[FF + i]
              + (r15[HB + i] - r15[FF + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r15[KS + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let MO = 4015
    // IF(OR(KS6=0,KD6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[MO + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        (r15[AB + i]
          + (r15[AC + i] - r15[AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let MP = 4380
    // IF(OR(KS6=0,KD6=0),0,MH6*El_boiler_eff)
    for i in 0..<365 {
      r15[MP + i] = iff(or(r15[KS + i] = 0, r15[KD + i] = 0), 0, r15[MH + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let MQ = 4745
    // IF(OR(KS6=0,KD6=0),0,MAX(0,MO6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      r15[MQ + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        max(
          0,
          r15[MO + i]
            - ((r15[FV + i]
              + (r15[HR + i] - r15[FV + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j]))
              + ((r15[FW + i]
                + (r15[HS + i] - r15[FW + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                  * (r15[KD + i] - equiv_harmonious_min_perc[j]))
                - (r15[FV + i]
                  + (r15[HR + i] - r15[FV + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                    * (r15[KD + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r15[KS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let MR = 5110
    // IF(OR(KS6=0,KD6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MR + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FA + i] + (r15[GW + i] - r15[FA + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let MS = 5475
    // MP6+MQ6+MR6-MN6-MO6
    for i in 0..<365 {
      r15[MS + i] = r15[MP + i] + r15[MQ + i] + r15[MR + i] - r15[MN + i] - r15[MO + i]
    }

    /// el cons for harm op outside of harm op period
    let MT = 5840
    // IF(OR(KS6=0,KD6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MT + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FE + i] + (r15[HA + i] - r15[FE + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let MU = 6205
    // IF(OR(KS6=0,KD6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MU + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FP + i] + (r15[HL + i] - r15[FP + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let MV = 6570
    // IF(OR(KS6=0,KD6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MV + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FN + i] + (r15[HJ + i] - r15[FN + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let MW = 6935
    // MG6*BESS_chrg_eff
    for i in 0..<365 { r15[MW + i] = r15[MG + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let MX = 7300
    // IF(OR(KS6=0,KD6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[MX + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[EZ + i] + (r15[GV + i] - r15[EZ + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let MY = 7665
    // IF(OR(KS6=0,KD6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc),MAX(0,-(MW6+MX6-MT6-MU6-MV6))))
    for i in 0..<365 {
      r15[MY + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        min(
          r15[GG + i]
            + (r15[IC + i] - r15[GG + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j]),
          max(0, -(r15[MW + i] + r15[MX + i] - r15[MT + i] - r15[MU + i] - r15[MV + i]))))
    }

    /// Balance of electricity outside of harm op period
    let MZ = 8030
    // MW6+MX6+MY6-MT6-MU6-MV6
    for i in 0..<365 {
      r15[MZ + i] =
        r15[MW + i] + r15[MX + i] + r15[MY + i] - r15[MT + i] - r15[MU + i] - r15[MV + i]
    }

    /// heat cons for harm op outside of harm op period
    let NA = 8395
    // IF(OR(KS6=0,KD6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[NA + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FH + i] + (r15[HD + i] - r15[FH + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let NB = 8760
    // IF(OR(KS6=0,KD6=0),0,MV6*El_boiler_eff)
    for i in 0..<365 {
      r15[NB + i] = iff(or(r15[KS + i] = 0, r15[KD + i] = 0), 0, r15[MV + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let NC = 9125
    // IF(OR(KS6=0,KD6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r15[NC + i] = iff(
        or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
        r15[FB + i] + (r15[GX + i] - r15[FB + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
          * (r15[KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let ND = 9490
    // NB6+NC6-NA6
    for i in 0..<365 { r15[ND + i] = r15[NB + i] + r15[NC + i] - r15[NA + i] }

    /// Pure Methanol prod with night priority and resp day op
    let NE = 9855
    // IF(MD6<=0,0,MD6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(MT6<=0,0,(MT6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      r15[NE + i] =
        iff(
          r15[MD + i] <= 0, 0,
          r15[MD + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          r15[MT + i] <= 0, 0,
          (r15[MT + i] - overall_stup_cons[j])
            / (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * MethDist_max_perc[j]
            * MethDist_Meth_nom_prod_ud)
    }

    /// Grid export
    let NF = 10220
    // MIN(MM6,IF(OR(KS6=0,KD6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)))+MIN(MZ6,IF(OR(KS6=0,KD6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[NF + i] =
        min(
          r15[MM + i],
          iff(
            or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
            (r15[GB + i]
              + (r15[HX + i] - r15[GB + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                * (r15[KD + i] - equiv_harmonious_min_perc[j]))
              + ((r15[GC + i]
                + (r15[HY + i] - r15[GC + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                  * (r15[KD + i] - equiv_harmonious_min_perc[j]))
                - (r15[GB + i]
                  + (r15[HX + i] - r15[GB + i]) / (r15[AM + i] - equiv_harmonious_min_perc[j])
                    * (r15[KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r15[KS + i] - Overall_harmonious_min_perc)))
        + min(
          r15[MZ + i],
          iff(
            or(r15[KS + i] = 0, r15[KD + i] = 0), 0,
            r15[GD + i] + (r15[HZ + i] - r15[GD + i])
              / (r15[AM + i] - equiv_harmonious_min_perc[j])
              * (r15[KD + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let NG = 10585
    // MY6+ML6
    for i in 0..<365 { r15[NG + i] = r15[MY + i] + r15[ML + i] }

    /// Outside harmonious operation period hours
    let NH = 10950
    // IF(KD6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[NH + i] = iff(
        r15[KD + i] <= 0, 0,
        (r15[C + i]
          + (r15[T + i] - r15[C + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let NI = 11315
    // IF(KD6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[NI + i] = iff(
        r15[KD + i] <= 0, 0,
        (r15[D + i]
          + (r15[U + i] - r15[D + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let NJ = 11680
    // IF(KD6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r15[NJ + i] = iff(
        r15[KD + i] <= 0, 0,
        (r15[E + i]
          + (r15[V + i] - r15[E + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r15[KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let NK = 12045
    // MAX(0,-MM6)+MAX(0,-MS6)+MAX(0,-MZ6)+MAX(0,-ND6)
    for i in 0..<365 {
      r15[NK + i] =
        max(0, -r15[MM + i]) + max(0, -r15[MS + i]) + max(0, -r15[MZ + i]) + max(0, -r15[ND + i])
    }

  }
}
