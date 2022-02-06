extension TunOl {
  func daily2(r0: inout [Double]) {

    /// Day
    let A = 0
    // A5+1
    for i in 0..<365 { r0[A + i] = r0[A + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    let B = 365
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,"<=0")
    for i in 0..<365 { r0[B + i] = S_UcountZero[i] }

    /// Nr of hours where min harmonious is possible considering grid support
    let C = 730
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r0[C + i] = S_UcountNonZero[i] }

  }
}

extension TunOl {
  func daily2(r0: [Double], r1: inout [Double]) {
    let B = 365
    let C = 730
    /// Min el cons during night
    let E = 0
    // (A_overall_var_min_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      r1[E + i] =
        (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * r0[B + i] + overall_stup_cons[j]
    }

    /// Max el cons during night
    let F = 365
    // (A_overall_var_max_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      r1[F + i] =
        (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * r0[B + i] + overall_stup_cons[j]
    }

    /// Min heat cons during night
    let G = 730
    // (A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      r1[G + i] =
        (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * r0[B + i]
        + overall_heat_stup_cons[j]
    }

    /// Max heat cons during night
    let H = 1095
    // (A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      r1[H + i] =
        (overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]) * r0[B + i]
        + overall_heat_stup_cons[j]
    }

    /// Min RawMeth cons during night
    let I = 1460
    // A_RawMeth_min_cons*B6
    for i in 0..<365 { r1[I + i] = RawMeth_min_cons[j] * r0[B + i] }

    /// Max RawMeth cons during night
    let J = 1825
    // A_RawMeth_max_cons*B6
    for i in 0..<365 { r1[J + i] = RawMeth_max_cons[j] * r0[B + i] }

    /// Min CO2 cons during night
    let K = 2190
    // A_CO2_min_cons*B6
    for i in 0..<365 { r1[K + i] = C_O_2_min_cons[j] * r0[B + i] }

    /// Max CO2 cons during night
    let L = 2555
    // A_CO2_max_cons*B6
    for i in 0..<365 { r1[L + i] = C_O_2_max_cons[j] * r0[B + i] }

    /// Min H2 cons during night
    let M = 2920
    // A_Hydrogen_min_cons*B6
    for i in 0..<365 { r1[M + i] = Hydrogen_min_cons[j] * r0[B + i] }

    /// Max H2 cons during night
    let N = 3285
    // A_Hydrogen_max_cons*B6
    for i in 0..<365 { r1[N + i] = Hydrogen_max_cons[j] * r0[B + i] }

    /// Min el cons during day for night op prep
    let O = 3650
    // (M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+I6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      r1[O + i] =
        (r1[M + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + r0[C + i]
        * EY_fix_cons
        + (r1[K + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + r0[C + i]
        * CCU_fix_cons + r1[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + r0[C + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let P = 4015
    // (N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+C6*EY_fix_cons+(L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+C6*CCU_fix_cons+J6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+C6*MethSynt_fix_cons
    for i in 0..<365 {
      r1[P + i] =
        (r1[N + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + r0[C + i]
        * EY_fix_cons
        + (r1[L + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + r0[C + i]
        * CCU_fix_cons + r1[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + r0[C + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let Q = 4380
    // (M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-I6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      r1[Q + i] =
        (r1[M + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + r0[C + i]
        * EY_heat_fix_cons
        + (r1[K + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + r0[C + i]
        * CCU_fix_heat_cons - r1[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - r0[C + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let R = 4745
    // (N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+C6*EY_heat_fix_cons+(L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+C6*CCU_fix_heat_cons-J6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-C6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      r1[R + i] =
        (r1[N + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + r0[C + i]
        * EY_heat_fix_cons
        + (r1[L + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + r0[C + i]
        * CCU_fix_heat_cons - r1[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - r0[C + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let S = 5110
    // I6
    for i in 0..<365 { r1[S + i] = r1[I + i] }

    /// Max Rawmeth prod during day for night op prep
    let T = 5475
    // J6
    for i in 0..<365 { r1[T + i] = r1[J + i] }

    /// Min CO2 prod during day for night op prep
    let U = 5840
    // K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      r1[U + i] =
        r1[K + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let V = 6205
    // L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      r1[V + i] =
        r1[L + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let W = 6570
    // M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      r1[W + i] =
        r1[M + i] + r1[I + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let X = 6935
    // N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      r1[X + i] =
        r1[N + i] + r1[J + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let Y = 7300
    // 1-I6/RawMeth_storage_cap_ud
    for i in 0..<365 { r1[Y + i] = 1 - r1[I + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let Z = 7665
    // 1-J6/RawMeth_storage_cap_ud
    for i in 0..<365 { r1[Z + i] = 1 - r1[J + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let AA = 8030
    // 1-K6/CO2_storage_cap_ud
    for i in 0..<365 { r1[AA + i] = 1 - r1[K + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let AB = 8395
    // 1-L6/CO2_storage_cap_ud
    for i in 0..<365 { r1[AB + i] = 1 - r1[L + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let AC = 8760
    // 1-M6/Hydrogen_storage_cap_ud
    for i in 0..<365 { r1[AC + i] = 1 - r1[M + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let AD = 9125
    // 1-N6/Hydrogen_storage_cap_ud
    for i in 0..<365 { r1[AD + i] = 1 - r1[N + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let AE = 9490
    // IF(OR(Y6<=0,AA6<=0,AC6<=0),0,MIN(1,IFERROR(Y6/(Y6-Z6),1),IFERROR(AA6/(AA6-AB6),1),IFERROR(AC6/(AC6-AD6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r1[AE + i] = iff(
        or(r1[Y + i] <= 0, r1[AA + i] <= 0, r1[AC + i] <= 0), 0,
        min(
          1, ifFinite(r1[Y + i] / (r1[Y + i] - r1[Z + i]), 1),
          ifFinite(r1[AA + i] / (r1[AA + i] - r1[AB + i]), 1),
          ifFinite(r1[AC + i] / (r1[AC + i] - r1[AD + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

  }
}

extension TunOl {
  func daily2(r5: inout [Double]) {

    /// Available day op PV elec after CSP, PB stby aux
    let DM = 0
    // SUMIFS(CalculationP5:P8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r5[DM + i] = /* U S */ Psum[i] }

    /// Available night op PV elec after CSP, PB stby aux
    let DN = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationP5:P8763)-DM6
    for i in 0..<365 { r5[DN + i] = sum[i] - r5[DM + i] }

    /// Available day op  CSP heat
    let DO = 730
    // SUMIFS(CalculationJ5:J8763,CalculationU5:U8763,"="A6,CalculationT5:T8763,">0")
    for i in 0..<365 { r5[DO + i] = /* U T */ Jsum[i] }

    /// Available night op  CSP heat
    let DP = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationJ5:J8763)-DO6
    for i in 0..<365 { r5[DP + i] = sum[i] - r5[DO + i] }

  }
}

extension TunOl {
  func daily2(r6: inout [Double]) {

    /// El cons considering min harm op during harm op period
    let DR = 0
    // SUMIF(CalculationU5:U8763,"="A6,CalculationS5:S8763)
    for i in 0..<365 { r6[DR + i] = sum[i] }

    /// El cons considering max harm op during harm op period
    let DS = 365
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAH5:AH8763)
    for i in 0..<365 { r6[DS + i] = AHsum[i] }

    /// Heat cons considering min harm op during harm op period
    let DT = 730
    // SUMIF(CalculationU5:U8763,"="A6,CalculationT5:T8763)
    for i in 0..<365 { r6[DT + i] = sum[i] }

    /// Heat cons considering max harm op during harm op period
    let DU = 1095
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAI5:AI8763)
    for i in 0..<365 { r6[DU + i] = AIsum[i] }

    /// Max grid export after min harm op during harm op period
    let DV = 1460
    // SUMIFS(CalculationAF5:AF8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[DV + i] = /* U S */ AFsum[i] }

    /// Max grid export after max harm op during harm op period
    let DW = 1825
    // SUMIFS(CalculationAT5:AT8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[DW + i] = /* U S */ ATsum[i] }

    /// Max grid export after min/max harm op outside of harm op period
    let DX = 2190
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAF5:AF8763)-DV6
    for i in 0..<365 { r6[DX + i] = AFsum[i] - r6[DV + i] }

    /// Grid cons considering min harm op during harm op period
    let DY = 2555
    // SUMIFS(CalculationX5:X8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[DY + i] = /* U S */ Xsum[i] }

    /// Grid cons considering max harm op during harm op period
    let DZ = 2920
    // SUMIFS(CalculationAL5:AL8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[DZ + i] = /* U AH */ ALsum[i] }

    /// Grid cons considering min/max harm op outside harm op period
    let EA = 3285
    // SUMIF(CalculationU5:U8763,"="A6,CalculationX5:X8763)-DY6
    for i in 0..<365 { r6[EA + i] = sum[i] - r6[DY + i] }

    /// Remaining PV el after min harm during harm op period
    let EB = 3650
    // SUMIFS(CalculationV5:V8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EB + i] = /* U S */ Vsum[i] }

    /// Remaining PV el after max harm during harm op period
    let EC = 4015
    // SUMIFS(CalculationAJ5:AJ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EC + i] = /* U AH */ AJsum[i] }

    /// Remaining PV el after min harm outside harm op period
    let ED = 4380
    // SUMIF(CalculationU5:U8763,"="A6,CalculationV5:V8763)-EB6
    for i in 0..<365 { r6[ED + i] = sum[i] - r6[EB + i] }

    /// Remaining CSP heat after min harm during harm op period
    let EE = 4745
    // SUMIFS(CalculationW5:W8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EE + i] = /* U S */ Wsum[i] }

    /// Remaining CSP heat after max harm during harm op period
    let EF = 5110
    // SUMIFS(CalculationAK5:AK8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EF + i] = /* U AH */ AKsum[i] }

    /// Remaining CSP heat after min harm outside harm op period
    let EG = 5475
    // SUMIF(CalculationU5:U8763,"="A6,CalculationW5:W8763)-EE6
    for i in 0..<365 { r6[EG + i] = sum[i] - r6[EE + i] }

    /// Remaining grid import cap after min harm during harm op period
    let EH = 5840
    // SUMIFS(CalculationY5:Y8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EH + i] = /* U S */ Ysum[i] }

    /// Remaining grid import cap after max harm during harm op period
    let EI = 6205
    // SUMIFS(CalculationAM5:AM8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EI + i] = /* U AH */ AMsum[i] }

    /// Remaining grid import cap after min harm outside harm op period
    let EJ = 6570
    // SUMIF(CalculationU5:U8763,"="A6,CalculationY5:Y8763)-EH6
    for i in 0..<365 { r6[EJ + i] = sum[i] - r6[EH + i] }

    /// Max elec to BESS for night prep after min harm op during harm op period
    let EK = 6935
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r6[EK + i] = min( /* U S */AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep after max harm cons during harm op period
    let EL = 7300
    // MIN(SUMIFS(CalculationAS5:AS8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r6[EL + i] = min( /* U AH */ASsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max elec to BESS for night prep after min harm op outside harm op period
    let EM = 7665
    // MIN(SUMIFS(CalculationAE5:AE8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { r6[EM + i] = min( /* U S */AEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// El boiler op for min harm during harm op period
    let EN = 8030
    // SUMIFS(CalculationZ5:Z8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EN + i] = /* U S */ Zsum[i] }

    /// El boiler op for max harm during harm op period
    let EO = 8395
    // SUMIFS(CalculationAN5:AN8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EO + i] = /* U S */ ANsum[i] }

    /// Remaining El boiler cap after min harm during harm op period
    let EP = 8760
    // SUMIFS(CalculationAA5:AA8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EP + i] = /* U S */ AAsum[i] }

    /// Remaining El boiler cap after max harm during harm op period
    let EQ = 9125
    // SUMIFS(CalculationAO5:AO8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EQ + i] = /* U AH */ AOsum[i] }

    /// Remaining El boiler cap after min harm outside harm op period
    let ER = 9490
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAA5:AA8763)-EP6
    for i in 0..<365 { r6[ER + i] = AAsum[i] - r6[EP + i] }

    /// Remaining MethSynt cap after min harm during harm op period
    let ES = 9855
    // SUMIFS(CalculationAB5:AB8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[ES + i] = /* U S */ ABsum[i] }

    /// Remaining MethSynt cap after max harm during harm op period
    let ET = 10220
    // SUMIFS(CalculationAP5:AP8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[ET + i] = /* U AH */ APsum[i] }

    /// Remaining MethSynt cap after min harm outside of harm op period
    let EU = 10585
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAB5:AB8763)-ES6
    for i in 0..<365 { r6[EU + i] = ABsum[i] - r6[ES + i] }

    /// Remaining CCU cap after min harm during harm op period
    let EV = 10950
    // SUMIFS(CalculationAC5:AC8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EV + i] = /* U S */ ACsum[i] }

    /// Remaining CCU cap after max harm during harm op period
    let EW = 11315
    // SUMIFS(CalculationAQ5:AQ8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EW + i] = /* U AH */ AQsum[i] }

    /// Remaining CCU cap after min harm outside of harm op period
    let EX = 11680
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAC5:AC8763)-EV6
    for i in 0..<365 { r6[EX + i] = ACsum[i] - r6[EV + i] }

    /// Remaining EY cap after min harm during harm op period
    let EY = 12045
    // SUMIFS(CalculationAD5:AD8763,CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { r6[EY + i] = /* U S */ ADsum[i] }

    /// Remaining EY cap after max harm during harm op period
    let EZ = 12410
    // SUMIFS(CalculationAR5:AR8763,CalculationU5:U8763,"="A6,CalculationAH5:AH8763,">0")
    for i in 0..<365 { r6[EZ + i] = /* U AH */ ARsum[i] }

    /// Remaining EY cap after min harm outside of harm op period
    let FA = 12775
    // SUMIF(CalculationU5:U8763,"="A6,CalculationAD5:AD8763)-EY6
    for i in 0..<365 { r6[FA + i] = ADsum[i] - r6[EY + i] }

  }
}

extension TunOl {
  func daily2(r7: inout [Double]) {

    /// Surplus harm op period el after min day harm op and min night op prep
    let FC = 0
    // EB6+EH6-O6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 {
      r7[FC + i] =
        r7[EB + i] + r7[EH + i] - r7[O + i]
        - min(r7[EK + i], (r7[EA + i] + r7[E + i] + r7[G + i] / El_boiler_eff) / BESS_chrg_eff)
        - max(0, r7[Q + i] - r7[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let FD = 365
    // EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      r7[FD + i] =
        r7[EB + i] + r7[EH + i]
        - (r7[O + i]
          + (r7[P + i] - r7[O + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
        - min(
          r7[EK + i],
          (r7[EA + i]
            + (r7[E + i]
              + (r7[F + i] - r7[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r7[AE + i] - equiv_harmonious_min_perc[j]))
            + (r7[G + i]
              + (r7[H + i] - r7[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r7[AE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff)
            / BESS_chrg_eff) - max(
          0,
          (r7[Q + i]
            + (r7[R + i] - r7[Q + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r7[AE + i] - equiv_harmonious_min_perc[j]))
            - r7[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let FE = 730
    // EC6+EI6-O6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 {
      r7[FE + i] =
        r7[EC + i] + r7[EI + i] - r7[O + i]
        - min(r7[EL + i], (r7[EA + i] + r7[E + i] + r7[G + i] / El_boiler_eff) / BESS_chrg_eff)
        - max(0, r7[Q + i] - r7[EF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FF = 1095
    // (EK6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      r7[FF + i] =
        (r7[EK + i] + r7[EM + i]) * BESS_chrg_eff + r7[EJ + i] - r7[E + i] - r7[G + i]
        / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FG = 1460
    // (EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff
    for i in 0..<365 {
      r7[FG + i] =
        (r7[EK + i] + r7[EM + i]) * BESS_chrg_eff + r7[EJ + i]
        - (r7[E + i]
          + (r7[F + i] - r7[E + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
        - (r7[G + i]
          + (r7[H + i] - r7[G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
        / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let FH = 1825
    // (EL6+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff
    for i in 0..<365 {
      r7[FH + i] =
        (r7[EL + i] + r7[EM + i]) * BESS_chrg_eff + r7[EJ + i] - r7[E + i] - r7[G + i]
        / El_boiler_eff
    }

    /// Surplus harm op heat after min day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FI = 2190
    // EE6+(EB6+EH6-MIN(EK6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      r7[FI + i] =
        r7[EE + i]
        + (r7[EB + i] + r7[EH + i]
          - min(r7[EK + i], (r7[EA + i] + r7[E + i] + r7[G + i] / El_boiler_eff) / BESS_chrg_eff)
          - r7[O + i]) * El_boiler_eff - r7[Q + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FJ = 2555
    // EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r7[FJ + i] =
        r7[EE + i]
        + (r7[EB + i] + r7[EH + i]
          - min(
            r7[EK + i],
            (r7[EA + i]
              + (r7[E + i]
                + (r7[F + i] - r7[E + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r7[AE + i] - equiv_harmonious_min_perc[j]))
              + (r7[G + i]
                + (r7[H + i] - r7[G + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r7[AE + i] - equiv_harmonious_min_perc[j]))
                / El_boiler_eff)
              / BESS_chrg_eff)
          - (r7[O + i]
            + (r7[P + i] - r7[O + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r7[AE + i] - equiv_harmonious_min_perc[j])))
        * El_boiler_eff
        - (r7[Q + i]
          + (r7[R + i] - r7[Q + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat after max day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let FK = 2920
    // EF6+(EC6+EI6-MIN(EL6,(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6
    for i in 0..<365 {
      r7[FK + i] =
        r7[EF + i]
        + (r7[EC + i] + r7[EI + i]
          - min(r7[EL + i], (r7[EA + i] + r7[E + i] + r7[G + i] / El_boiler_eff) / BESS_chrg_eff)
          - r7[O + i]) * El_boiler_eff - r7[Q + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let FL = 3285
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 { r7[FL + i] = r7[EG + i] + r7[ER + i] * El_boiler_eff - r7[G + i] }

    /// Surplus outside harm op heat after min day harm and max night op prep
    let FM = 3650
    // EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r7[FM + i] =
        r7[EG + i] + r7[ER + i] * El_boiler_eff
        - (r7[G + i]
          + (r7[H + i] - r7[G + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus outside harm op heat after max day harm and min night op prep
    let FN = 4015
    // EG6+ER6*El_boiler_eff-G6
    for i in 0..<365 { r7[FN + i] = r7[EG + i] + r7[ER + i] * El_boiler_eff - r7[G + i] }

    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let FO = 4380
    // EP6-MAX(0,Q6-EE6)/El_boiler_eff
    for i in 0..<365 { r7[FO + i] = r7[EP + i] - max(0, r7[Q + i] - r7[EE + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let FP = 4745
    // EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff
    for i in 0..<365 {
      r7[FP + i] =
        r7[EP + i] - max(
          0,
          (r7[Q + i]
            + (r7[R + i] - r7[Q + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r7[AE + i] - equiv_harmonious_min_perc[j]))
            - r7[EE + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let FQ = 5110
    // EQ6-MAX(0,Q6-EF6)/El_boiler_eff
    for i in 0..<365 { r7[FQ + i] = r7[EQ + i] - max(0, r7[Q + i] - r7[EF + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let FR = 5475
    // ER6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 { r7[FR + i] = r7[ER + i] - max(0, r7[G + i] - r7[EG + i]) / El_boiler_eff }

    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let FS = 5840
    // ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff
    for i in 0..<365 {
      r7[FS + i] =
        r7[ER + i] - max(
          0,
          (r7[G + i]
            + (r7[H + i] - r7[G + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r7[AE + i] - equiv_harmonious_min_perc[j]))
            - r7[EG + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let FT = 6205
    // ER6-MAX(0,G6-EG6)/El_boiler_eff
    for i in 0..<365 { r7[FT + i] = r7[ER + i] - max(0, r7[G + i] - r7[EG + i]) / El_boiler_eff }

    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let FU = 6570
    // ES6-S6
    for i in 0..<365 { r7[FU + i] = r7[ES + i] - r7[S + i] }

    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let FV = 6935
    // ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r7[FV + i] =
        r7[ES + i]
        - (r7[S + i]
          + (r7[T + i] - r7[S + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let FW = 7300
    // ET6-S6
    for i in 0..<365 { r7[FW + i] = r7[ET + i] - r7[S + i] }

    /// Surplus CO2 prod cap after min day harm and min night op prep
    let FX = 7665
    // EV6-U6
    for i in 0..<365 { r7[FX + i] = r7[EV + i] - r7[U + i] }

    /// Surplus CO2 prod cap after min day harm and max night op prep
    let FY = 8030
    // EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r7[FY + i] =
        r7[EV + i]
        - (r7[U + i]
          + (r7[V + i] - r7[U + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max day harm and min night op prep
    let FZ = 8395
    // EW6-U6
    for i in 0..<365 { r7[FZ + i] = r7[EW + i] - r7[U + i] }

    /// Surplus H2 prod cap after min day harm and min night op prep
    let GA = 8760
    // EY6-W6
    for i in 0..<365 { r7[GA + i] = r7[EY + i] - r7[W + i] }

    /// Surplus H2 prod cap after min day harm and max night op prep
    let GB = 9125
    // EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r7[GB + i] =
        r7[EY + i]
        - (r7[W + i]
          + (r7[X + i] - r7[W + i]) / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r7[AE + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max day harm and min night op prep
    let GC = 9490
    // EZ6-W6
    for i in 0..<365 { r7[GC + i] = r7[EZ + i] - r7[W + i] }

  }
}


extension TunOl {
  func daily2(r8: inout [Double]) {

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let GE = 0
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FE6),1),IFERROR(FF6/(FF6-FH6),1),IFERROR(FI6/(FI6-FK6),1),IFERROR(FL6/(FL6-FN6),1),IFERROR(FO6/(FO6-FQ6),1),IFERROR(FR6/(FR6-FT6),1),IFERROR(FU6/(FU6-FW6),1),IFERROR(FX6/(FX6-FZ6),1),IFERROR(GA6/(GA6-GC6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      r8[GE + i] = iff(
        or(
          r8[FC + i] < 0, r8[FF + i] < 0, r8[FI + i] < 0, r8[FL + i] < 0, r8[FO + i] < 0,
          r8[FR + i] < 0, r8[FU + i] < 0, r8[FX + i] < 0, r8[GA + i] < 0), 0,
        min(
          1, ifFinite(r8[FC + i] / (r8[FC + i] - r8[FE + i]), 1),
          ifFinite(r8[FF + i] / (r8[FF + i] - r8[FH + i]), 1),
          ifFinite(r8[FI + i] / (r8[FI + i] - r8[FK + i]), 1),
          ifFinite(r8[FL + i] / (r8[FL + i] - r8[FN + i]), 1),
          ifFinite(r8[FO + i] / (r8[FO + i] - r8[FQ + i]), 1),
          ifFinite(r8[FR + i] / (r8[FR + i] - r8[FT + i]), 1),
          ifFinite(r8[FU + i] / (r8[FU + i] - r8[FW + i]), 1),
          ifFinite(r8[FX + i] / (r8[FX + i] - r8[FZ + i]), 1),
          ifFinite(r8[GA + i] / (r8[GA + i] - r8[GC + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let GF = 365
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-O6-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GF + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EB + i]
            + (r8[EC + i] - r8[EB + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + (r8[EH + i]
              + (r8[EI + i] - r8[EH + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r8[GE + i] - Overall_harmonious_min_perc))
            - r8[O + i]
            - min(
              r8[EK + i]
                + (r8[EL + i] - r8[EK + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r8[VK + i] - Overall_harmonious_min_perc),
              (r8[EA + i] + r8[E + i] + r8[G + i] / El_boiler_eff) / BESS_chrg_eff) - max(
              0,
              r8[Q + i]
                - (r8[EE + i]
                  + (r8[EF + i] - r8[EE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let GG = 730
    // IF(GE6=0,0,ROUND((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GG + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EB + i]
            + (r8[EC + i] - r8[EB + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + (r8[EH + i]
              + (r8[EI + i] - r8[EH + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r8[GE + i] - Overall_harmonious_min_perc))
            - (r8[O + i]
              + (r8[P + i] - r8[O + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j]))
            - min(
              r8[EK + i]
                + (r8[EL + i] - r8[EK + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r8[VK + i] - Overall_harmonious_min_perc),
              (r8[EA + i]
                + (r8[E + i]
                  + (r8[F + i] - r8[E + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                + (r8[G + i]
                  + (r8[H + i] - r8[G + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              0,
              (r8[Q + i]
                + (r8[R + i] - r8[Q + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                - (r8[EE + i]
                  + (r8[EF + i] - r8[EE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GH = 1095
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-E6-G6/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GH + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          ((r8[EK + i]
            + (r8[EL + i] - r8[EK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + r8[EM + i]) * BESS_chrg_eff + r8[EJ + i] - r8[E + i] - r8[G + i] / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GI = 1460
    // IF(GE6=0,0,ROUND(((EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GI + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          ((r8[EK + i]
            + (r8[EL + i] - r8[EK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + r8[EM + i]) * BESS_chrg_eff + r8[EJ + i]
            - (r8[E + i]
              + (r8[F + i] - r8[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j]))
            - (r8[G + i]
              + (r8[H + i] - r8[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GJ = 1825
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+E6+G6/El_boiler_eff)/BESS_chrg_eff)-O6)*El_boiler_eff-Q6,5))
    for i in 0..<365 {
      r8[GJ + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EE + i]
            + (r8[EF + i] - r8[EE + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + ((r8[EB + i]
              + (r8[EC + i] - r8[EB + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r8[GE + i] - Overall_harmonious_min_perc))
              + (r8[EH + i]
                + (r8[EI + i] - r8[EH + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r8[GE + i] - Overall_harmonious_min_perc))
              - min(
                r8[EK + i]
                  + (r8[EL + i] - r8[EK + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[VK + i] - Overall_harmonious_min_perc),
                (r8[EA + i] + r8[E + i] + r8[G + i] / El_boiler_eff) / BESS_chrg_eff) - r8[O + i])
            * El_boiler_eff - r8[Q + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GK = 2190
    // IF(GE6=0,0,ROUND((EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+((EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))+(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MIN(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(VK6-Overall_harmonious_min_perc),(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r8[GK + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EE + i]
            + (r8[EF + i] - r8[EE + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            + ((r8[EB + i]
              + (r8[EC + i] - r8[EB + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r8[GE + i] - Overall_harmonious_min_perc))
              + (r8[EH + i]
                + (r8[EI + i] - r8[EH + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (r8[GE + i] - Overall_harmonious_min_perc))
              - min(
                r8[EK + i]
                  + (r8[EL + i] - r8[EK + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[VK + i] - Overall_harmonious_min_perc),
                (r8[EA + i]
                  + (r8[E + i]
                    + (r8[F + i] - r8[E + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                  + (r8[G + i]
                    + (r8[H + i] - r8[G + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (r8[O + i]
                + (r8[P + i] - r8[O + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r8[AE + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (r8[Q + i]
              + (r8[R + i] - r8[Q + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let GL = 2555
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-G6,5))
    for i in 0..<365 {
      r8[GL + i] = iff(
        r8[GE + i] = 0, 0, round(r8[EG + i] + r8[ER + i] * El_boiler_eff - r8[G + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let GM = 2920
    // IF(GE6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r8[GM + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          r8[EG + i] + r8[ER + i] * El_boiler_eff
            - (r8[G + i]
              + (r8[H + i] - r8[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let GN = 3285
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,Q6-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GN + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EP + i]
            + (r8[EQ + i] - r8[EP + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - max(
              0,
              r8[Q + i]
                - (r8[EE + i]
                  + (r8[EF + i] - r8[EE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let GO = 3650
    // IF(GE6=0,0,ROUND((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-(EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GO + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EP + i]
            + (r8[EQ + i] - r8[EP + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - max(
              0,
              (r8[Q + i]
                + (r8[R + i] - r8[Q + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r8[AE + i] - equiv_harmonious_min_perc[j]))
                - (r8[EE + i]
                  + (r8[EF + i] - r8[EE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (r8[GE + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let GP = 4015
    // IF(GE6=0,0,ROUND(ER6-MAX(0,G6-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GP + i] = iff(
        r8[GE + i] = 0, 0, round(r8[ER + i] - max(0, r8[G + i] - r8[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let GQ = 4380
    // IF(GE6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      r8[GQ + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          r8[ER + i] - max(
            0,
            (r8[G + i]
              + (r8[H + i] - r8[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j]))
              - r8[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let GR = 4745
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-S6,5))
    for i in 0..<365 {
      r8[GR + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[ES + i]
            + (r8[ET + i] - r8[ES + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - r8[S + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let GS = 5110
    // IF(GE6=0,0,ROUND((ES6+(ET6-ES6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r8[GS + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[ES + i]
            + (r8[ET + i] - r8[ES + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - (r8[S + i]
              + (r8[T + i] - r8[S + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let GT = 5475
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-U6,5))
    for i in 0..<365 {
      r8[GT + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EV + i]
            + (r8[EW + i] - r8[EV + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - r8[U + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let GU = 5840
    // IF(GE6=0,0,ROUND((EV6+(EW6-EV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r8[GU + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EV + i]
            + (r8[EW + i] - r8[EV + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - (r8[U + i]
              + (r8[V + i] - r8[U + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let GV = 6205
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-W6,5))
    for i in 0..<365 {
      r8[GV + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EY + i]
            + (r8[EZ + i] - r8[EY + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - r8[W + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let GW = 6570
    // IF(GE6=0,0,ROUND((EY6+(EZ6-EY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AE6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r8[GW + i] = iff(
        r8[GE + i] = 0, 0,
        round(
          (r8[EY + i]
            + (r8[EZ + i] - r8[EY + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r8[GE + i] - Overall_harmonious_min_perc))
            - (r8[W + i]
              + (r8[X + i] - r8[W + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r8[AE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let GX = 6935
    // IF(OR(GE6=0,GF6<0,GH6<0,GJ6<0,GL6<0,GN6<0,GP6<0,GR6<0,GT6<0,GV6<0),0,MIN(1,IFERROR(GF6/(GF6-GG6),1),IFERROR(GH6/(GH6-GI6),1),IFERROR(GJ6/(GJ6-GK6),1),IFERROR(GL6/(GL6-GM6),1),IFERROR(GN6/(GN6-GO6),1),IFERROR(GP6/(GP6-GQ6),1),IFERROR(GR6/(GR6-GS6),1),IFERROR(GT6/(GT6-GU6),1),IFERROR(GV6/(GV6-GW6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r8[GX + i] = iff(
        or(
          r8[GE + i] = 0, r8[GF + i] < 0, r8[GH + i] < 0, r8[GJ + i] < 0, r8[GL + i] < 0,
          r8[GN + i] < 0, r8[GP + i] < 0, r8[GR + i] < 0, r8[GT + i] < 0, r8[GV + i] < 0), 0,
        min(
          1, ifFinite(r8[GF + i] / (r8[GF + i] - r8[GG + i]), 1),
          ifFinite(r8[GH + i] / (r8[GH + i] - r8[GI + i]), 1),
          ifFinite(r8[GJ + i] / (r8[GJ + i] - r8[GK + i]), 1),
          ifFinite(r8[GL + i] / (r8[GL + i] - r8[GM + i]), 1),
          ifFinite(r8[GN + i] / (r8[GN + i] - r8[GO + i]), 1),
          ifFinite(r8[GP + i] / (r8[GP + i] - r8[GQ + i]), 1),
          ifFinite(r8[GR + i] / (r8[GR + i] - r8[GS + i]), 1),
          ifFinite(r8[GT + i] / (r8[GT + i] - r8[GU + i]), 1),
          ifFinite(r8[GV + i] / (r8[GV + i] - r8[GW + i]), 1))
          * (r8[AE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

  }
}
extension TunOl {
  func daily2(r9: inout [Double]) {

    /// Max Equiv harmonious night prod due to prod cap limits
    let GZ = 0
    // IF(OR(FC6<0,FF6<0,FI6<0,FL6<0,FO6<0,FR6<0,FU6<0,FX6<0,GA6<0),0,MIN(1,IFERROR(FC6/(FC6-FD6),1),IFERROR(FF6/(FF6-FG6),1),IFERROR(FI6/(FI6-FJ6),1),IFERROR(FL6/(FL6-FM6),1),IFERROR(FO6/(FO6-FP6),1),IFERROR(FR6/(FR6-FS6),1),IFERROR(FU6/(FU6-FV6),1),IFERROR(FX6/(FX6-FY6),1),IFERROR(GA6/(GA6-GB6),1))*(AE6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      r9[GZ + i] = iff(
        or(
          r9[FC + i] < 0, r9[FF + i] < 0, r9[FI + i] < 0, r9[FL + i] < 0, r9[FO + i] < 0,
          r9[FR + i] < 0, r9[FU + i] < 0, r9[FX + i] < 0, r9[GA + i] < 0), 0,
        min(
          1, ifFinite(r9[FC + i] / (r9[FC + i] - r9[FD + i]), 1),
          ifFinite(r9[FF + i] / (r9[FF + i] - r9[FG + i]), 1),
          ifFinite(r9[FI + i] / (r9[FI + i] - r9[FJ + i]), 1),
          ifFinite(r9[FL + i] / (r9[FL + i] - r9[FM + i]), 1),
          ifFinite(r9[FO + i] / (r9[FO + i] - r9[FP + i]), 1),
          ifFinite(r9[FR + i] / (r9[FR + i] - r9[FS + i]), 1),
          ifFinite(r9[FU + i] / (r9[FU + i] - r9[FV + i]), 1),
          ifFinite(r9[FX + i] / (r9[FX + i] - r9[FY + i]), 1),
          ifFinite(r9[GA + i] / (r9[GA + i] - r9[GB + i]), 1))
          * (r9[AE + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let HA = 365
    // IF(GZ6=0,0,ROUND(EB6+EH6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HA + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EB + i] + r9[EH + i]
            - (r9[O + i]
              + (r9[P + i] - r9[O + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              r9[EK + i],
              (r9[EA + i]
                + (r9[E + i]
                  + (r9[F + i] - r9[E + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                + (r9[G + i]
                  + (r9[H + i] - r9[G + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              0,
              (r9[Q + i]
                + (r9[R + i] - r9[Q + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                - r9[EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after max day harm op and opt night op prep
    let HB = 730
    // IF(GZ6=0,0,ROUND(EC6+EI6-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HB + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EC + i] + r9[EI + i]
            - (r9[O + i]
              + (r9[P + i] - r9[O + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
            - min(
              r9[EL + i],
              (r9[EA + i]
                + (r9[E + i]
                  + (r9[F + i] - r9[E + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                + (r9[G + i]
                  + (r9[H + i] - r9[G + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                  / El_boiler_eff)
                / BESS_chrg_eff) - max(
              0,
              (r9[Q + i]
                + (r9[R + i] - r9[Q + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                - r9[EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after min day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let HC = 1095
    // IF(GZ6=0,0,ROUND((EK6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HC + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          (r9[EK + i] + r9[EM + i]) * BESS_chrg_eff + r9[EJ + i]
            - (r9[E + i]
              + (r9[F + i] - r9[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
            - (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus outside harm op period el after max day harm and opt night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let HD = 1460
    // IF(GZ6=0,0,ROUND((EL6+EM6)*BESS_chrg_eff+EJ6-(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HD + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          (r9[EL + i] + r9[EM + i]) * BESS_chrg_eff + r9[EJ + i]
            - (r9[E + i]
              + (r9[F + i] - r9[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
            - (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              / El_boiler_eff,
          5))
    }

    /// Surplus harm op heat after min day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let HE = 1825
    // IF(GZ6=0,0,ROUND(EE6+(EB6+EH6-MIN(EK6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HE + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EE + i]
            + (r9[EB + i] + r9[EH + i]
              - min(
                r9[EK + i],
                (r9[EA + i]
                  + (r9[E + i]
                    + (r9[F + i] - r9[E + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                  + (r9[G + i]
                    + (r9[H + i] - r9[G + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (r9[O + i]
                + (r9[P + i] - r9[O + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r9[GZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (r9[Q + i]
              + (r9[R + i] - r9[Q + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harm op heat after max day harm and opt night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let HF = 2190
    // IF(GZ6=0,0,ROUND(EF6+(EC6+EI6-MIN(EL6,(EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/El_boiler_eff)/BESS_chrg_eff)-(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))*El_boiler_eff-(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HF + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EF + i]
            + (r9[EC + i] + r9[EI + i]
              - min(
                r9[EL + i],
                (r9[EA + i]
                  + (r9[E + i]
                    + (r9[F + i] - r9[E + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                  + (r9[G + i]
                    + (r9[H + i] - r9[G + i])
                      / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                      * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
                    / El_boiler_eff)
                  / BESS_chrg_eff)
              - (r9[O + i]
                + (r9[P + i] - r9[O + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r9[GZ + i] - equiv_harmonious_min_perc[j])))
            * El_boiler_eff
            - (r9[Q + i]
              + (r9[R + i] - r9[Q + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after min day harm and opt night op prep
    let HG = 2555
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HG + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EG + i] + r9[ER + i] * El_boiler_eff
            - (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after max day harm and opt night op prep
    let HH = 2920
    // IF(GZ6=0,0,ROUND(EG6+ER6*El_boiler_eff-(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HH + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EG + i] + r9[ER + i] * El_boiler_eff
            - (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let HI = 3285
    // IF(GZ6=0,0,ROUND(EP6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EE6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HI + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EP + i] - max(
            0,
            (r9[Q + i]
              + (r9[R + i] - r9[Q + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              - r9[EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let HJ = 3650
    // IF(GZ6=0,0,ROUND(EQ6-MAX(0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EF6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HJ + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EQ + i] - max(
            0,
            (r9[Q + i]
              + (r9[R + i] - r9[Q + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              - r9[EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let HK = 4015
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HK + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[ER + i] - max(
            0,
            (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              - r9[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let HL = 4380
    // IF(GZ6=0,0,ROUND(ER6-MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff,5))
    for i in 0..<365 {
      r9[HL + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[ER + i] - max(
            0,
            (r9[G + i]
              + (r9[H + i] - r9[G + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j]))
              - r9[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let HM = 4745
    // IF(GZ6=0,0,ROUND(ES6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HM + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[ES + i]
            - (r9[S + i]
              + (r9[T + i] - r9[S + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let HN = 5110
    // IF(GZ6=0,0,ROUND(ET6-(S6+(T6-S6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HN + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[ET + i]
            - (r9[S + i]
              + (r9[T + i] - r9[S + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let HO = 5475
    // IF(GZ6=0,0,ROUND(EV6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HO + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EV + i]
            - (r9[U + i]
              + (r9[V + i] - r9[U + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let HP = 5840
    // IF(GZ6=0,0,ROUND(EW6-(U6+(V6-U6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HP + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EW + i]
            - (r9[U + i]
              + (r9[V + i] - r9[U + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HQ = 6205
    // IF(GZ6=0,0,ROUND(EY6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HQ + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EY + i]
            - (r9[W + i]
              + (r9[X + i] - r9[W + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HR = 6570
    // IF(GZ6=0,0,ROUND(EZ6-(W6+(X6-W6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      r9[HR + i] = iff(
        r9[GZ + i] = 0, 0,
        round(
          r9[EZ + i]
            - (r9[W + i]
              + (r9[X + i] - r9[W + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r9[GZ + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let HS = 6935
    // IF(GZ6<=0,0,MIN(1,MIN(IFERROR(HA6/(HA6-HB6),1),IFERROR(HC6/(HC6-HD6),1),IFERROR(HE6/(HE6-HF6),1),IFERROR(HG6/(HG6-HH6),1),IFERROR(HI6/(HI6-HJ6),1),IFERROR(HK6/(HK6-HL6),1),IFERROR(HM6/(HM6-HN6),1),IFERROR(HO6/(HO6-HP6),1),IFERROR(HQ6/(HQ6-HR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc))
    for i in 0..<365 {
      r9[HS + i] = iff(
        r9[GZ + i] <= 0, 0,
        min(
          1,
          min(
            ifFinite(r9[HA + i] / (r9[HA + i] - r9[HB + i]), 1),
            ifFinite(r9[HC + i] / (r9[HC + i] - r9[HD + i]), 1),
            ifFinite(r9[HE + i] / (r9[HE + i] - r9[HF + i]), 1),
            ifFinite(r9[HG + i] / (r9[HG + i] - r9[HH + i]), 1),
            ifFinite(r9[HI + i] / (r9[HI + i] - r9[HJ + i]), 1),
            ifFinite(r9[HK + i] / (r9[HK + i] - r9[HL + i]), 1),
            ifFinite(r9[HM + i] / (r9[HM + i] - r9[HN + i]), 1),
            ifFinite(r9[HO + i] / (r9[HO + i] - r9[HP + i]), 1),
            ifFinite(r9[HQ + i] / (r9[HQ + i] - r9[HR + i]), 1))
            * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            + Overall_harmonious_min_perc))
    }

  }
}

extension TunOl {
  func daily2(r10: inout [Double]) {

    /// el cons for harm op during harm op period
    let HU = 0
    // IF(GE6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[HU + i] = iff(
        r10[GE + i] = 0, 0,
        r10[DR + i] + (r10[DS + i] - r10[DR + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let HV = 365
    // IF(GX6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r10[HV + i] = iff(
        r10[GX + i] = 0, 0,
        (r10[O + i]
          + (r10[P + i] - r10[O + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r10[GX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let HW = 730
    // IF(OR(GE6=0,GX6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      r10[HW + i] = iff(
        or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
        min(
          (r10[EA + i]
            + (r10[E + i]
              + (r10[F + i] - r10[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r10[GX + i] - equiv_harmonious_min_perc[j]))
            + max(
              0,
              (r10[G + i]
                + (r10[H + i] - r10[G + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r10[GX + i] - equiv_harmonious_min_perc[j]))
                - r10[EG + i]) / El_boiler_eff - r10[ED + i]) / BESS_chrg_eff,
          (r10[EK + i]
            + (r10[EL + i] - r10[EK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r10[GE + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let HX = 1095
    // IF(GE6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[HX + i] = iff(
        r10[GE + i] = 0, 0,
        r10[EN + i] + (r10[EO + i] - r10[EN + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let HY = 1460
    // IH6/El_boiler_eff
    for i in 0..<365 { r10[HY + i] = r10[IH + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let HZ = 1825
    // IF(GE6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[HZ + i] = iff(
        r10[GE + i] = 0, 0,
        r10[EB + i] + (r10[EC + i] - r10[EB + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let IA = 2190
    // IF(GE6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[IA + i] = iff(
        r10[GE + i] = 0, 0,
        r10[DY + i] + (r10[DZ + i] - r10[DY + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let IB = 2555
    // IF(GE6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc),MAX(0,-(HZ6-HV6-HW6-HY6))))
    for i in 0..<365 {
      r10[IB + i] = iff(
        r10[GE + i] = 0, 0,
        min(
          r10[EH + i]
            + (r10[EI + i] - r10[EH + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r10[GE + i] - Overall_harmonious_min_perc),
          max(0, -(r10[HZ + i] - r10[HV + i] - r10[HW + i] - r10[HY + i]))))
    }

    /// Balance of electricity during harm op period
    let IC = 2920
    // HZ6+IB6-(HV6+HW6+HY6)
    for i in 0..<365 {
      r10[IC + i] = r10[HZ + i] + r10[IB + i] - (r10[HV + i] + r10[HW + i] + r10[HY + i])
    }

    /// Heat cons for harm op during harm op period
    let ID = 3285
    // IF(GE6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[ID + i] = iff(
        r10[GE + i] = 0, 0,
        r10[DT + i] + (r10[DU + i] - r10[DT + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let IE = 3650
    // IF(GX6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r10[IE + i] = iff(
        r10[GX + i] = 0, 0,
        (r10[Q + i]
          + (r10[R + i] - r10[Q + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r10[GX + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let IF = 4015
    // IF(GE6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r10[IF + i] = iff(
        r10[GE + i] = 0, 0,
        r10[EE + i] + (r10[EF + i] - r10[EE + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r10[GE + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let IG = 4380
    // IF(GE6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      r10[IG + i] = iff(
        r10[GE + i] = 0, 0,
        (r10[EN + i]
          + (r10[EO + i] - r10[EN + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (r10[GE + i] - Overall_harmonious_min_perc))
          * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let IH = 4745
    // IF(GE6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE6-IF6)))
    for i in 0..<365 {
      r10[IH + i] = iff(
        r10[GE + i] = 0, 0,
        min(
          (r10[EP + i]
            + (r10[EQ + i] - r10[EP + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r10[GE + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, r10[IE + i] - r10[IF + i])))
    }

    /// Balance of heat during harm op period
    let II = 5110
    // IF6+IH6-IE6
    for i in 0..<365 { r10[II + i] = r10[IF + i] + r10[IH + i] - r10[IE + i] }

    /// el cons for harm op outside of harm op period
    let IJ = 5475
    // IF(OR(GE6=0,GX6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r10[IJ + i] = iff(
        or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
        r10[E + i] + (r10[F + i] - r10[E + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (r10[GX + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let IK = 5840
    // IS6/El_boiler_eff
    for i in 0..<365 { r10[IK + i] = r10[IS + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let IL = 6205
    // IF(OR(GE6=0,GX6=0),0,EA6)
    for i in 0..<365 { r10[IL + i] = iff(or(r10[GE + i] = 0, r10[GX + i] = 0), 0, r10[EA + i]) }

    /// el from PV outside of harm op period
    let IM = 6570
    // IF(OR(GE6=0,GX6=0),0,ED6)
    for i in 0..<365 { r10[IM + i] = iff(or(r10[GE + i] = 0, r10[GX + i] = 0), 0, r10[ED + i]) }

    /// el from BESS outside of harm op period
    let IN = 6935
    // HW6*BESS_chrg_eff
    for i in 0..<365 { r10[IN + i] = r10[HW + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let IO = 7300
    // IF(OR(GE6=0,GX6=0),0,MIN(EJ6+EA6,MAX(0,-((IM6+IN6)-(IJ6+IK6+IL6)))))
    for i in 0..<365 {
      r10[IO + i] = iff(
        or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
        min(
          r10[EJ + i] + r10[EA + i],
          max(0, -((r10[IM + i] + r10[IN + i]) - (r10[IJ + i] + r10[IK + i] + r10[IL + i])))))
    }

    /// Balance of electricity outside of harm op period
    let IP = 7665
    // (IM6+IN6+IO6)-(IJ6+IK6+IL6)
    for i in 0..<365 {
      r10[IP + i] =
        (r10[IM + i] + r10[IN + i] + r10[IO + i]) - (r10[IJ + i] + r10[IK + i] + r10[IL + i])
    }

    /// heat cons for harm op outside of harm op period
    let IQ = 8030
    // IF(OR(GE6=0,GX6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GX6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r10[IQ + i] = iff(
        or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
        r10[G + i] + (r10[H + i] - r10[G + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (r10[GX + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let IR = 8395
    // IF(OR(GE6=0,GX6=0),0,EG6)
    for i in 0..<365 { r10[IR + i] = iff(or(r10[GE + i] = 0, r10[GX + i] = 0), 0, r10[EG + i]) }

    /// heat from el boiler outside of harm op period
    let IS = 8760
    // IF(OR(GE6=0,GX6=0),0,MIN(ER6*El_boiler_eff,MAX(0,IQ6-IR6)))
    for i in 0..<365 {
      r10[IS + i] = iff(
        or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
        min(r10[ER + i] * El_boiler_eff, max(0, r10[IQ + i] - r10[IR + i])))
    }

    /// Balance of heat outside of harm op period
    let IT = 9125
    // (IR6+IS6)-IQ6
    for i in 0..<365 { r10[IT + i] = (r10[IR + i] + r10[IS + i]) - r10[IQ + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let IU = 9490
    // IF(HU6<=0,0,HU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(IJ6<=0,0,(IJ6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      r10[IU + i] =
        iff(
          r10[HU + i] <= 0, 0,
          r10[HU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          r10[IJ + i] <= 0, 0,
          (r10[IJ + i] - overall_stup_cons[j])
            / (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * MethDist_max_perc[j]
            * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let IV = 9855
    // MIN(IC6,IF(OR(GE6=0,GX6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GE6-Overall_harmonious_min_perc))))+MIN(IP6,IF(OR(GE6=0,GX6=0),0,DX6))
    for i in 0..<365 {
      r10[IV + i] =
        min(
          r10[IC + i],
          iff(
            or(r10[GE + i] = 0, r10[GX + i] = 0), 0,
            (r10[DV + i]
              + (r10[DW + i] - r10[DV + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r10[GE + i] - Overall_harmonious_min_perc))
          )) + min(r10[IP + i], iff(or(r10[GE + i] = 0, r10[GX + i] = 0), 0, r10[DX + i]))
    }

    /// grid import
    let IW = 10220
    // IA6+IB6+IO6
    for i in 0..<365 { r10[IW + i] = r10[IA + i] + r10[IB + i] + r10[IO + i] }

    /// Checksum
    let IX = 10585
    // MAX(0,-IC6)+MAX(0,-II6)+MAX(0,-IP6)+MAX(0,-IT6)
    for i in 0..<365 {
      r10[IX + i] =
        max(0, -r10[IC + i]) + max(0, -r10[II + i]) + max(0, -r10[IP + i]) + max(0, -r10[IT + i])
    }

  }
}
extension TunOl {
  func daily2(r11: inout [Double]) {

    /// el cons for harm op during harm op period
    let IZ = 0
    // IF(HS6=0,0,DR6+(DS6-DR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[IZ + i] = iff(
        r11[HS + i] = 0, 0,
        r11[DR + i] + (r11[DS + i] - r11[DR + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let JA = 365
    // IF(GZ6=0,0,(O6+(P6-O6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r11[JA + i] = iff(
        r11[GZ + i] = 0, 0,
        (r11[O + i]
          + (r11[P + i] - r11[O + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    let JB = 730
    // IF(OR(HS6=0,GZ6=0),0,MIN((EA6+(E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))+MAX(0,(G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))-EG6)/El_boiler_eff-ED6)/BESS_chrg_eff,(EK6+(EL6-EK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      r11[JB + i] = iff(
        or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
        min(
          (r11[EA + i]
            + (r11[E + i]
              + (r11[F + i] - r11[E + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
            + max(
              0,
              (r11[G + i]
                + (r11[H + i] - r11[G + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
                - r11[EG + i]) / El_boiler_eff - r11[ED + i]) / BESS_chrg_eff,
          (r11[EK + i]
            + (r11[EL + i] - r11[EK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r11[HS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// el cons of el boiler for harm op during harm op period
    let JC = 1095
    // IF(HS6=0,0,EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[JC + i] = iff(
        r11[HS + i] = 0, 0,
        r11[EN + i] + (r11[EO + i] - r11[EN + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// el cons of el boiler for night prep during harm op period
    let JD = 1460
    // JM6/El_boiler_eff
    for i in 0..<365 { r11[JD + i] = r11[JM + i] / El_boiler_eff }

    /// PV available after harm op during harm op period
    let JE = 1825
    // IF(HS6=0,0,EB6+(EC6-EB6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[JE + i] = iff(
        r11[HS + i] = 0, 0,
        r11[EB + i] + (r11[EC + i] - r11[EB + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op during harm op period
    let JF = 2190
    // IF(HS6=0,0,DY6+(DZ6-DY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[JF + i] = iff(
        r11[HS + i] = 0, 0,
        r11[DY + i] + (r11[DZ + i] - r11[DY + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    let JG = 2555
    // IF(HS6=0,0,MIN(EH6+(EI6-EH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc),MAX(0,-(JE6-JA6-JB6-JD6))))
    for i in 0..<365 {
      r11[JG + i] = iff(
        r11[HS + i] = 0, 0,
        min(
          r11[EH + i]
            + (r11[EI + i] - r11[EH + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r11[HS + i] - Overall_harmonious_min_perc),
          max(0, -(r11[JE + i] - r11[JA + i] - r11[JB + i] - r11[JD + i]))))
    }

    /// Balance of electricity during harm op period
    let JH = 2920
    // JE6+JG6-(JA6+JB6+JD6)
    for i in 0..<365 {
      r11[JH + i] = r11[JE + i] + r11[JG + i] - (r11[JA + i] + r11[JB + i] + r11[JD + i])
    }

    /// Heat cons for harm op during harm op period
    let JI = 3285
    // IF(HS6=0,0,DT6+(DU6-DT6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[JI + i] = iff(
        r11[HS + i] = 0, 0,
        r11[DT + i] + (r11[DU + i] - r11[DT + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// Heat cons for night prep during harm op period
    let JJ = 3650
    // IF(GZ6=0,0,(Q6+(R6-Q6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      r11[JJ + i] = iff(
        r11[GZ + i] = 0, 0,
        (r11[Q + i]
          + (r11[R + i] - r11[Q + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    let JK = 4015
    // IF(HS6=0,0,EE6+(EF6-EE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      r11[JK + i] = iff(
        r11[HS + i] = 0, 0,
        r11[EE + i] + (r11[EF + i] - r11[EE + i])
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (r11[HS + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for harm op during harm op period
    let JL = 4380
    // IF(HS6=0,0,(EN6+(EO6-EN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff)
    for i in 0..<365 {
      r11[JL + i] = iff(
        r11[HS + i] = 0, 0,
        (r11[EN + i]
          + (r11[EO + i] - r11[EN + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (r11[HS + i] - Overall_harmonious_min_perc))
          * El_boiler_eff)
    }

    /// El boiler heat prod for night prep during harm op period
    let JM = 4745
    // IF(HS6=0,0,MIN((EP6+(EQ6-EP6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JJ6-JK6)))
    for i in 0..<365 {
      r11[JM + i] = iff(
        r11[HS + i] = 0, 0,
        min(
          (r11[EP + i]
            + (r11[EQ + i] - r11[EP + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (r11[HS + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, r11[JJ + i] - r11[JK + i])))
    }

    /// Balance of heat during harm op period
    let JN = 5110
    // JK6+JM6-JJ6
    for i in 0..<365 { r11[JN + i] = r11[JK + i] + r11[JM + i] - r11[JJ + i] }

    /// el cons for harm op outside of harm op period
    let JO = 5475
    // IF(OR(HS6=0,GZ6=0),0,E6+(F6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[JO + i] = iff(
        or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
        r11[E + i] + (r11[F + i] - r11[E + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons by el boiler outside of harm op period
    let JP = 5840
    // JX6/El_boiler_eff
    for i in 0..<365 { r11[JP + i] = r11[JX + i] / El_boiler_eff }

    /// el cons for aux cons outside of harm op period
    let JQ = 6205
    // IF(OR(HS6=0,GZ6=0),0,EA6)
    for i in 0..<365 { r11[JQ + i] = iff(or(r11[HS + i] = 0, r11[GZ + i] = 0), 0, r11[EA + i]) }

    /// el from PV outside of harm op period
    let JR = 6570
    // IF(OR(HS6=0,GZ6=0),0,ED6)
    for i in 0..<365 { r11[JR + i] = iff(or(r11[HS + i] = 0, r11[GZ + i] = 0), 0, r11[ED + i]) }

    /// el from BESS outside of harm op period
    let JS = 6935
    // JB6*BESS_chrg_eff
    for i in 0..<365 { r11[JS + i] = r11[JB + i] * BESS_chrg_eff }

    /// grid input outside of harm op period
    let JT = 7300
    // IF(OR(HS6=0,GZ6=0),0,MIN(EJ6+EA6,MAX(0,-((JR6+JS6)-(JO6+JP6+JQ6)))))
    for i in 0..<365 {
      r11[JT + i] = iff(
        or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
        min(
          r11[EJ + i] + r11[EA + i],
          max(0, -((r11[JR + i] + r11[JS + i]) - (r11[JO + i] + r11[JP + i] + r11[JQ + i])))))
    }

    /// Balance of electricity outside of harm op period
    let JU = 7665
    // (JR6+JS6+JT6)-(JO6+JP6+JQ6)
    for i in 0..<365 {
      r11[JU + i] =
        (r11[JR + i] + r11[JS + i] + r11[JT + i]) - (r11[JO + i] + r11[JP + i] + r11[JQ + i])
    }

    /// heat cons for harm op outside of harm op period
    let JV = 8030
    // IF(OR(HS6=0,GZ6=0),0,G6+(H6-G6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      r11[JV + i] = iff(
        or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
        r11[G + i] + (r11[H + i] - r11[G + i])
          / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    let JW = 8395
    // IF(OR(HS6=0,GZ6=0),0,EG6)
    for i in 0..<365 { r11[JW + i] = iff(or(r11[HS + i] = 0, r11[GZ + i] = 0), 0, r11[EG + i]) }

    /// heat from el boiler outside of harm op period
    let JX = 8760
    // IF(OR(HS6=0,GZ6=0),0,MIN(ER6*El_boiler_eff,MAX(0,JV6-JW6)))
    for i in 0..<365 {
      r11[JX + i] = iff(
        or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
        min(r11[ER + i] * El_boiler_eff, max(0, r11[JV + i] - r11[JW + i])))
    }

    /// Balance of heat outside of harm op period
    let JY = 9125
    // (JW6+JX6)-JV6
    for i in 0..<365 { r11[JY + i] = (r11[JW + i] + r11[JX + i]) - r11[JV + i] }

    /// Pure Methanol prod with min night prep and resp day op
    let JZ = 9490
    // IF(IZ6<=0,0,IZ6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(GZ6<=0,0,(I6+(J6-I6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(GZ6-A_equiv_harmonious_min_perc))/MethDist_RawMeth_nom_cons*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      r11[JZ + i] =
        iff(
          r11[IZ + i] <= 0, 0,
          r11[IZ + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          r11[GZ + i] <= 0, 0,
          (r11[I + i]
            + (r11[J + i] - r11[I + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (r11[GZ + i] - equiv_harmonious_min_perc[j]))
            / MethDist_RawMeth_nom_cons * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let KA = 9855
    // MIN(JH6,IF(OR(HS6=0,GZ6=0),0,(DV6+(DW6-DV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HS6-Overall_harmonious_min_perc))))+MIN(JU6,IF(OR(HS6=0,GZ6=0),0,DX6))
    for i in 0..<365 {
      r11[KA + i] =
        min(
          r11[JH + i],
          iff(
            or(r11[HS + i] = 0, r11[GZ + i] = 0), 0,
            (r11[DV + i]
              + (r11[DW + i] - r11[DV + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (r11[HS + i] - Overall_harmonious_min_perc))
          )) + min(r11[JU + i], iff(or(r11[HS + i] = 0, r11[GZ + i] = 0), 0, r11[DX + i]))
    }

    /// grid import
    let KB = 10220
    // JF6+JG6+JT6
    for i in 0..<365 { r11[KB + i] = r11[JF + i] + r11[JG + i] + r11[JT + i] }

    /// Checksum
    let KC = 10585
    // MAX(0,-JH6)+MAX(0,-JN6)+MAX(0,-JU6)+MAX(0,-JY6)
    for i in 0..<365 {
      r11[KC + i] =
        max(0, -r11[JH + i]) + max(0, -r11[JN + i]) + max(0, -r11[JU + i]) + max(0, -r11[JY + i])
    }

  }
}
