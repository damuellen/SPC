extension TunOl {
  func day0(hour0: [Double]) -> [Double] {
    let daysU: [[Int]] = hour0[113881..<(113880 + 8760)].indices.chunked(by: { hour0[$0] == hour0[$1] }).map { $0.map { $0 - 113880 } }
    // let end = daysU.removeLast()
    // daysU[0].append(contentsOf: end)
    let hourS = 96360

    let S_UcountZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 <= 0 })
    let S_UcountNonZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 > 0 })
    var day0 = [Double](repeating: .zero, count: 1_095)
    /// Day
    let A = 0
    // A5+1
    for i in 1..<365 { day0[A + i] = day0[A + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    let B = 365
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,"<=0")
    for i in 0..<365 { day0[B + i] = S_UcountZero[i] }

    /// Nr of hours where min harmonious is possible considering grid support
    let C = 730
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day0[C + i] = S_UcountNonZero[i] }
    return day0
  }

  func d21(_ d1: inout [Double], case j: Int, day0: [Double]) {
    let B = 365
    let C = 730

    /// Surplus RawMeth storage cap after night min op  prep
    let Y = 7300
    /// Surplus RawMeth storage cap after max night op prep
    let Z = 7665
    /// Surplus CO2 storage cap after min night op prep
    let AA = 8030
    /// Surplus CO2 storage cap after max night op prep
    let AB = 8395
    /// Surplus H2 storage cap after min night op prep
    let AC = 8760
    /// Surplus H2 storage cap after max night op prep
    let AD = 9125
    for i in 0..<365 {
      // =1-IF(OR($B3=0,RawMeth_storage_cap_ud=0),0,A_RawMeth_min_cons*$B3/RawMeth_storage_cap_ud)
      d1[Y + i] = 1 - iff(or(day0[B + i].isZero, RawMeth_storage_cap_ud.isZero), .zero, RawMeth_min_cons[j] * day0[B + i] / RawMeth_storage_cap_ud)
      // =1-IF(OR($B3=0,RawMeth_storage_cap_ud=0),0,A_RawMeth_max_cons*$B3/RawMeth_storage_cap_ud)
      d1[Z + i] = 1 - iff(or(day0[B + i].isZero, RawMeth_storage_cap_ud.isZero), .zero, RawMeth_max_cons[j] * day0[B + i] / RawMeth_storage_cap_ud)
      // =1-IF(OR($B3=0,CO2_storage_cap_ud=0),0,A_CO2_min_cons*$B3/CO2_storage_cap_ud)
      d1[AA + i] = 1 - iff(or(day0[B + i].isZero, CO2_storage_cap_ud.isZero), .zero, CO2_min_cons[j] * day0[B + i] / CO2_storage_cap_ud)
      // =1-IF(OR($B3=0,CO2_storage_cap_ud=0),0,A_CO2_max_cons*$B3/CO2_storage_cap_ud)
      d1[AB + i] = 1 - iff(or(day0[B + i].isZero, CO2_storage_cap_ud.isZero), .zero, CO2_max_cons[j] * day0[B + i] / CO2_storage_cap_ud)
      // =1-IF(OR($B3=0,Hydrogen_storage_cap_ud=0),0,A_Hydrogen_min_cons*$B3/Hydrogen_storage_cap_ud)
      d1[AC + i] = 1 - iff(or(day0[B + i].isZero, Hydrogen_storage_cap_ud.isZero), .zero, Hydrogen_min_cons[j] * day0[B + i] / Hydrogen_storage_cap_ud)
      // =1-IF(OR($B3=0,Hydrogen_storage_cap_ud=0),0,A_Hydrogen_max_cons*$B3/Hydrogen_storage_cap_ud)
      d1[AD + i] = 1 - iff(or(day0[B + i].isZero, Hydrogen_storage_cap_ud.isZero), .zero, Hydrogen_max_cons[j] * day0[B + i] / Hydrogen_storage_cap_ud)
    }

    /// Max Equiv harmonious night prod due to physical limits
    let AE = 9490
    // IF(OR(Y6<=0,AA6<=0,AC6<=0),0,MIN(1,IFERROR(Y6/(Y6-Z6),1),IFERROR(AA6/(AA6-AB6),1),IFERROR(AC6/(AC6-AD6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d1[AE + i] = iff(
        or(d1[Y + i] <= .zero, d1[AA + i] <= .zero, d1[AC + i] <= .zero), .zero,
        min(1, ifFinite(d1[Y + i] / (d1[Y + i] - d1[Z + i]), 1), ifFinite(d1[AA + i] / (d1[AA + i] - d1[AB + i]), 1), ifFinite(d1[AC + i] / (d1[AC + i] - d1[AD + i]), 1)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Min el cons during night
    let E = 0
    // (A_overall_var_min_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 { d1[E + i] = iff(d1[AE + i].isZero, .zero, (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * day0[B + i] + overall_stup_cons[j]) }

    /// Max el cons during night
    let F = 365
    // (A_overall_var_max_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 { d1[F + i] = iff(d1[AE + i].isZero, .zero, (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * day0[B + i] + overall_stup_cons[j]) }

    /// Min heat cons during night
    let G = 730
    // (A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 { d1[G + i] = iff(d1[AE + i].isZero, .zero, (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * day0[B + i] + overall_heat_stup_cons[j]) }

    /// Max heat cons during night
    let H = 1095
    // (A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 { d1[H + i] = iff(d1[AE + i].isZero, .zero, (overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]) * day0[B + i] + overall_heat_stup_cons[j]) }

    /// Min RawMeth cons during night
    let I = 1460
    /// Max RawMeth cons during night
    let J = 1825
    /// Min CO2 cons during night
    let K = 2190
    /// Max CO2 cons during night
    let L = 2555
    /// Min H2 cons during night
    let M = 2920
    /// Max H2 cons during night
    let N = 3285
    for i in 0..<365 {
      if d1[AE + i].isZero {
        d1[I + i] = .zero
        d1[J + i] = .zero
        d1[K + i] = .zero
        d1[L + i] = .zero
        d1[M + i] = .zero
        d1[N + i] = .zero
      } else {
        // A_RawMeth_min_cons*B6
        d1[I + i] = RawMeth_min_cons[j] * day0[B + i]
        // A_RawMeth_max_cons*B6
        d1[J + i] = RawMeth_max_cons[j] * day0[B + i]
        // A_CO2_min_cons*B6
        d1[K + i] = CO2_min_cons[j] * day0[B + i]
        // A_CO2_max_cons*B6
        d1[L + i] = CO2_max_cons[j] * day0[B + i]
        // A_Hydrogen_min_cons*B6
        d1[M + i] = Hydrogen_min_cons[j] * day0[B + i]
        // A_Hydrogen_max_cons*B6
        d1[N + i] = Hydrogen_max_cons[j] * day0[B + i]
      }
    }

    /// Min el cons during day for night op prep
    let O = 3650
    // IF(AND(M3=0;I3=0);0;(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+$C3*EY_fix_cons)+IF(AND(K3=0;I3=0);0;(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+$C3*CCU_fix_cons)+IF(I3=0;0;I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+$C3*MethSynt_fix_cons)
    for i in 0..<365 {
      d1[O + i] =
        iff(and(d1[M + i].isZero, d1[I + i].isZero), .zero, (d1[M + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day0[C + i] * EY_fix_cons)
        + iff(and(d1[K + i].isZero, d1[I + i].isZero), .zero, (d1[K + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + day0[C + i] * CCU_fix_cons)
        + iff(d1[I + i].isZero, .zero, d1[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day0[C + i] * MethSynt_fix_cons)
    }

    /// Max el cons during day for night op prep
    let P = 4015
    // IF(AND(N3=0;J3=0);0;(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+$C3*EY_fix_cons)+IF(AND(L3=0;J3=0);0;(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+$C3*CCU_fix_cons)+IF(J3=0;0;J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+$C3*MethSynt_fix_cons)
    for i in 0..<365 {
      d1[P + i] =
        iff(and(d1[N + i].isZero, d1[J + i].isZero), .zero, (d1[N + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day0[C + i] * EY_fix_cons)
        + iff(and(d1[L + i].isZero, d1[J + i].isZero), .zero, (d1[L + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + day0[C + i] * CCU_fix_cons)
        + iff(d1[J + i].isZero, .zero, d1[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day0[C + i] * MethSynt_fix_cons)
    }

    /// Min heat cons during day for night op prep
    let Q = 4380
    // IF(AND(M3=0;I3=0);0;(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+$C3*EY_heat_fix_cons)+IF(AND(K3=0;I3=0);0;(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+$C3*CCU_heat_fix_cons)-IF(I3=0;0;I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+$C3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      d1[Q + i] =
        iff(and(d1[M + i].isZero, d1[I + i].isZero), .zero, (d1[M + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day0[C + i] * EY_heat_fix_cons)
        + iff(and(d1[K + i].isZero, d1[I + i].isZero), .zero, (d1[K + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons + day0[C + i] * CCU_fix_heat_cons)
        - iff(d1[I + i].isZero, .zero, d1[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + day0[C + i] * MethSynt_heat_fix_prod)
    }

    /// Max heat cons during day for prep of night
    let R = 4745
    // IF(AND(N3=0;J3=0);0;(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+$C3*EY_heat_fix_cons)+IF(AND(L3=0;J3=0);0;(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+$C3*CCU_heat_fix_cons)-IF(J3=0;0;J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+$C3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      d1[R + i] =
        iff(and(d1[N + i].isZero, d1[J + i].isZero), .zero, (d1[N + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day0[C + i] * EY_heat_fix_cons)
        + iff(and(d1[L + i].isZero, d1[J + i].isZero), .zero, (d1[L + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons + day0[C + i] * CCU_fix_heat_cons)
        - iff(d1[J + i].isZero, .zero, d1[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + day0[C + i] * MethSynt_heat_fix_prod)
    }

    /// Min Rawmeth prod during day for night op prep
    let S = 5110
    /// Max Rawmeth prod during day for night op prep
    let T = 5475
    /// Min CO2 prod during day for night op prep
    let U = 5840
    /// Max CO2 prod during day for night op prep
    let V = 6205
    /// Min H2 prod during day for night op prep
    let W = 6570
    /// Max H2 prod during day for night op prep
    let X = 6935

    for i in 0..<365 {
      // I6
      d1[S + i] = d1[I + i]
      // J6
      d1[T + i] = d1[J + i]
      // K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      d1[U + i] = d1[K + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      d1[V + i] = d1[L + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      d1[W + i] = d1[M + i] + d1[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
      // N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      d1[X + i] = d1[N + i] + d1[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }
  }
}
