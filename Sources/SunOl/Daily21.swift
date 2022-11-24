extension TunOl {
  func day20(_ h: inout [Double]) {
    let days: [[Int]] = h[U+1..<V].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - U } }
    // let end = days.removeLast()
    // days[0].append(contentsOf: end)
    let (A, B, C) = (96725, 97090, 97455)
    let S_UcountZero = h.countOf(days, condition: S, predicate: { $0 <= 0 })
    let S_UcountNonZero = h.countOf(days, condition: S, predicate: { $0 > Double.zero })
    /// Day
    // A5+1
    for i in 1..<365 { h[A + i] = h[A + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,"<=0")
    for i in 0..<365 { h[B + i] = S_UcountZero[i] }

    /// Nr of hours where min harmonious is possible considering grid support
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { h[C + i] = S_UcountNonZero[i] }
  }

  func d21(_ h: inout [Double], case j: Int) {
    let (A, B, C) = (96725, 97090, 97455)
      let (
    E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, AA, AB, AC,
    AD, AE
  ) = (
    97820, 98185, 98550, 98915, 99280, 99645, 100010, 100375, 100740, 101105,
    101470, 101835, 102200, 102565, 102930, 103295, 103660, 104025, 104390,
    104755, 105120, 105485, 105850, 106215, 106580, 106945, 107310
  )
    /// Surplus RawMeth storage cap after night min op  prep
        /// Surplus RawMeth storage cap after max night op prep
        /// Surplus CO2 storage cap after min night op prep
        /// Surplus CO2 storage cap after max night op prep
        /// Surplus H2 storage cap after min night op prep
        /// Surplus H2 storage cap after max night op prep
        for i in 0..<365 {
      // Y=IF(A_RawMeth_min_cons=0,1,1-IFERROR(A_RawMeth_min_cons*$B3/RawMeth_storage_cap_ud,2))
      // Z=IF(A_RawMeth_max_cons=0,1,1-IFERROR(A_RawMeth_max_cons*$B3/RawMeth_storage_cap_ud,2))
      h[Y + i] = iff(RawMeth_min_cons[j].isZero, 1, 1 - ifFinite(RawMeth_min_cons[j] * h[B + i] / RawMeth_storage_cap_ud, 2))
      h[Z + i] = iff(RawMeth_max_cons[j].isZero, 1, 1 - ifFinite(RawMeth_max_cons[j] * h[B + i] / RawMeth_storage_cap_ud, 2))

      // AA=IF(A_CO2_min_cons=0,1,1-IFERROR(A_CO2_min_cons*$B3/CO2_storage_cap_ud,2))
      // AB=IF(A_CO2_max_cons=0,1,1-IFERROR(A_CO2_max_cons*$B3/CO2_storage_cap_ud,2))
      h[AA + i] = iff(CO2_min_cons[j].isZero, 1, 1 - ifFinite(CO2_min_cons[j] * h[B + i] / CO2_storage_cap_ud, 2))
      h[AB + i] = iff(CO2_max_cons[j].isZero, 1, 1 - ifFinite(CO2_max_cons[j] * h[B + i] / CO2_storage_cap_ud, 2))

      // AC=IF(A_Hydrogen_min_cons=0,1,1-IFERROR(A_Hydrogen_min_cons*$B3/Hydrogen_storage_cap_ud,2))
      // AD=IF(A_Hydrogen_max_cons=0,1,1-IFERROR(A_Hydrogen_max_cons*$B3/Hydrogen_storage_cap_ud,2))
      h[AC + i] = iff(Hydrogen_min_cons[j].isZero, 1, 1 - ifFinite(Hydrogen_min_cons[j] * h[B + i] / Hydrogen_storage_cap_ud, 2))
      h[AD + i] = iff(Hydrogen_max_cons[j].isZero, 1, 1 - ifFinite(Hydrogen_max_cons[j] * h[B + i] / Hydrogen_storage_cap_ud, 2))
    }

    /// Max Equiv harmonious night prod due to physical limits
        // IF(OR(Y6<=0,AA6<=0,AC6<=0),0,MIN(1,IFERROR(Y6/(Y6-Z6),1),IFERROR(AA6/(AA6-AB6),1),IFERROR(AC6/(AC6-AD6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[AE + i] = iff(
        or(h[Y + i] <= Double.zero, h[AA + i] <= Double.zero, h[AC + i] <= Double.zero), Double.zero,
        min(1, ifFinite(h[Y + i] / (h[Y + i] - h[Z + i]), 1.0), ifFinite(h[AA + i] / (h[AA + i] - h[AB + i]), 1.0), ifFinite(h[AC + i] / (h[AC + i] - h[AD + i]), 1.0)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Min el cons during night
        /// Max el cons during night
        /// Min heat cons during night
        /// Max heat cons during night
        /// Min RawMeth cons during night
        /// Max RawMeth cons during night
        /// Min CO2 cons during night
        /// Max CO2 cons during night
        /// Min H2 cons during night
        /// Max H2 cons during night
        for i in 0..<365 {
      if h[AE + i].isZero {
        h[E + i] = Double.zero
        h[F + i] = Double.zero
        h[G + i] = Double.zero
        h[H + i] = Double.zero
        h[I + i] = Double.zero
        h[J + i] = Double.zero
        h[K + i] = Double.zero
        h[L + i] = Double.zero
        h[M + i] = Double.zero
        h[N + i] = Double.zero
      } else {
        // (A_overall_var_min_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
        h[E + i] = (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * h[B + i] + overall_stup_cons[j]
        // (AE3*A_overall_var_max_cons+A_overall_fix_stby_cons)*$B3+A_overall_stup_cons
        h[F + i] = (h[AE + i] * overall_var_max_cons[j] + overall_fix_stby_cons[j]) * h[B + i] + overall_stup_cons[j]
        // (A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
        h[G + i] = (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * h[B + i] + overall_heat_stup_cons[j]
        // (AE3*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons)*$B3+A_overall_heat_stup_cons
        h[H + i] = (h[AE + i] * overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]) * h[B + i] + overall_heat_stup_cons[j]
        // A_RawMeth_min_cons*B6
        h[I + i] = RawMeth_min_cons[j] * h[B + i]
        // AE3*A_RawMeth_max_cons*$B3
        h[J + i] = h[AE + i] * RawMeth_max_cons[j] * h[B + i]
        // A_CO2_min_cons*B6
        h[K + i] = CO2_min_cons[j] * h[B + i]
        // AE3*A_CO2_max_cons*$B3
        h[L + i] = h[AE + i] * CO2_max_cons[j] * h[B + i]
        // A_Hydrogen_min_cons*B6
        h[M + i] = Hydrogen_min_cons[j] * h[B + i]
        // AE3*A_Hydrogen_max_cons*$B3
        h[N + i] = h[AE + i] * Hydrogen_max_cons[j] * h[B + i]
      }
    }

    /// Min el cons during day for night op prep
        // IF(AND(M3=0,I3=0),0,(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(K3=0,I3=0),0,(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(I3=0,0,I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      h[O + i] =
        iff(and(h[M + i].isZero, h[I + i].isZero), Double.zero, (h[M + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
        + iff(and(h[K + i].isZero, h[I + i].isZero), Double.zero, (h[K + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
        + iff(h[I + i].isZero, Double.zero, h[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
    }

    /// Max el cons during day for night op prep
        // IF(AND(N3=0,J3=0),0,(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(L3=0,J3=0),0,(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(J3=0,0,J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      h[P + i] =
        iff(and(h[N + i].isZero, h[J + i].isZero), Double.zero, (h[N + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
        + iff(and(h[L + i].isZero, h[J + i].isZero), Double.zero, (h[L + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
        + iff(h[J + i].isZero, Double.zero, h[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
    }

    /// Min heat cons during day for night op prep
        // IF(AND(M3=0,I3=0),0,(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(K3=0,I3=0),0,(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(I3=0,0,I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      h[Q + i] =
        iff(and(h[M + i].isZero, h[I + i].isZero), Double.zero, (h[M + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
        + iff(and(h[K + i].isZero, h[I + i].isZero), Double.zero, (h[K + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
        - iff(h[I + i].isZero, Double.zero, h[I + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
    }

    /// Max heat cons during day for prep of night
        // IF(AND(N3=0,J3=0),0,(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(L3=0,J3=0),0,(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(J3=0,0,J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      h[R + i] =
        iff(and(h[N + i].isZero, h[J + i].isZero), Double.zero, (h[N + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
        + iff(and(h[L + i].isZero, h[J + i].isZero), Double.zero, (h[L + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
        - iff(h[J + i].isZero, Double.zero, h[J + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
    }

    /// Min Rawmeth prod during day for night op prep
        /// Max Rawmeth prod during day for night op prep
        /// Min CO2 prod during day for night op prep
        /// Max CO2 prod during day for night op prep
        /// Min H2 prod during day for night op prep
        /// Max H2 prod during day for night op prep
    
    for i in 0..<365 {
      // I6
      h[S + i] = h[I + i]
      // J6
      h[T + i] = h[J + i]
      // K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      h[U + i] = h[K + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      h[V + i] = h[L + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      h[W + i] = h[M + i] + h[I + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
      // N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      h[X + i] = h[N + i] + h[J + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }
  }
}
