extension TunOl {
  func d1(_ d1: inout [Double], case j: Int, hour2: [Double], hour3: [Double]) {
    let BX = 26280
    let CC = 70080
    let CS = 26280
    let CQ = 8760
    let dayCS: [[Int]] = hour3[CS + 1..<(CS + 8760)].indices.chunked(by: { hour3[$0] == hour3[$1] }).map { $0.map { $0 - CS } }

    let CQ_CScountZero = hour3.countOf(dayCS, condition: CQ, predicate: { $0 <= 0 })
    let CQ_CScountNonZero = hour3.countOf(dayCS, condition: CQ, predicate: { $0 > 0 })

    /// Nr of hours outside of harm op period after min night prep
    let C = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    for i in 0..<365 { d1[C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let D = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d1[D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let E = 730
    let opHours = hour2.countOf(dayCS, condition1: BX, predicate1: { $0 > 0 }, condition2: CC, predicate2: { $0 > 0 })
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 { d1[E + i] = opHours[i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let L = 3285
    /// Surplus RawMeth storage cap after max night op prep
    let M = 3650
    /// Surplus CO2 storage cap after min night op prep
    let N = 4015
    /// Surplus CO2 storage cap after max night op prep
    let O = 4380
    /// Surplus H2 storage cap after min night op prep
    let P = 4745
    /// Surplus H2 storage cap after max night op prep
    let Q = 5110

    for i in 0..<365 {
      let hours = d1[C + i]
      if RawMeth_storage_cap_ud.isZero {
        (d1[L + i], d1[M + i]) = (0, 0)
      } else if hours.isZero {
        (d1[L + i], d1[M + i]) = (1, 1)
      } else {
        d1[L + i] = 1 - (RawMeth_min_cons[j] * hours / RawMeth_storage_cap_ud)
        d1[M + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud)
      }

      if CO2_storage_cap_ud.isZero {
        (d1[N + i], d1[O + i]) = (0, 0)
      } else if hours.isZero {
        (d1[N + i], d1[O + i]) = (1, 1)
      } else {
        d1[N + i] = 1 - (CO2_min_cons[j] * hours / CO2_storage_cap_ud)
        d1[O + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud)
      }

      if Hydrogen_storage_cap_ud.isZero {
        (d1[P + i], d1[Q + i]) = (0, 0)
      } else if hours.isZero {
        (d1[P + i], d1[Q + i]) = (1, 1)
      } else {
        d1[P + i] = 1 - (Hydrogen_min_cons[j] * hours / Hydrogen_storage_cap_ud)
        d1[Q + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud)
      }
    }

    /// Max Equiv harmonious night prod due to physical limits
    let R = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d1[R + i] = iff(
        or(d1[L + i] <= .zero, d1[N + i] <= .zero, d1[P + i] <= 0), .zero, min(1, ifFinite(d1[L + i] / (d1[L + i] - d1[M + i]), 1), ifFinite(d1[N + i] / (d1[N + i] - d1[O + i]), 1), ifFinite(d1[P + i] / (d1[P + i] - d1[Q + i]), 1)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Min RawMeth cons during night
    let F = 1095
    /// Max RawMeth cons during night
    let G = 1460
    /// Min CO2 cons during night
    let H = 1825
    /// Max CO2 cons during night
    let I = 2190
    /// Min H2 cons during night
    let J = 2555
    /// Max H2 cons during night
    let K = 2920

    // A_RawMeth_min_cons*C6
    for i in 0..<365 {
      if d1[R + i].isZero {
        d1[F + i] = .zero
        d1[G + i] = .zero
        d1[H + i] = .zero
        d1[I + i] = .zero
        d1[J + i] = .zero
        d1[K + i] = .zero
      } else {
        d1[F + i] = RawMeth_min_cons[j] * d1[C + i]
        // A_RawMeth_max_cons*C6
        d1[G + i] = RawMeth_max_cons[j] * d1[C + i]
        // A_CO2_min_cons*C6
        d1[H + i] = CO2_min_cons[j] * d1[C + i]
        // A_CO2_max_cons*C6
        d1[I + i] = CO2_max_cons[j] * d1[C + i]
        // A_Hydrogen_min_cons*C6
        d1[J + i] = Hydrogen_min_cons[j] * d1[C + i]
        // A_Hydrogen_max_cons*C6
        d1[K + i] = Hydrogen_max_cons[j] * d1[C + i]
      }
    }
  }

  func night(case j: Int, d1: inout [Double], hour3: [Double], hour4: [Double]) {
    let (D, F, H, J, L, N, P, EH, EX) = (365, 1095, 1825, 2555, 3285, 4015, 4745, 105120, 236520)
    let daysEZ: [[Int]] = hour4[254041..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] }).map { $0.map { $0 - 254040 } }
    //  let end = daysEZ.removeLast()
    // daysEZ[0].append(contentsOf: end)
    let EX_EZcountZero = hour4.countOf(daysEZ, condition: EX, predicate: { $0 <= 0 })
    /// Nr of hours outside of harm op period after max night prep
    let T = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { d1[T + i] = EX_EZcountZero[i] }

    let EX_EZcountNonZero = hour4.countOf(daysEZ, condition: EX, predicate: { $0 > 0 })
    /// Nr of harm op period hours after max night prep
    let U = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d1[U + i] = EX_EZcountNonZero[i] }

    let EH_EZcountNonZero = hour4.countOf(daysEZ, condition: EH, predicate: { $0 > 0 })
    /// Nr of PB op hours after max night prep
    let V = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { d1[V + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let W = 6935
    /// Max CO2 cons during night
    let X = 7300
    /// Max H2 cons during night
    let Y = 7665

    /// Surplus RawMeth storage cap after max night op prep
    let AJ = 11680
    /// Surplus CO2 storage cap after max night op prep
    let AK = 12045
    /// Surplus H2 storage cap after max night op prep
    let AL = 12410

    for i in 0..<365 {
      // =1-IF(OR(T3=0,RawMeth_storage_cap_ud=0),0,A_RawMeth_max_cons*T3/RawMeth_storage_cap_ud)
      d1[AJ + i] = 1 - iff(or(d1[T + i].isZero, RawMeth_storage_cap_ud.isZero), .zero, RawMeth_max_cons[j] * d1[T + i] / RawMeth_storage_cap_ud)
      // =1-IF(OR(T3=0,CO2_storage_cap_ud=0),0,A_CO2_max_cons*T3/CO2_storage_cap_ud)
      d1[AK + i] = 1 - iff(or(d1[T + i].isZero, CO2_storage_cap_ud.isZero), .zero, CO2_max_cons[j] * d1[T + i] / CO2_storage_cap_ud)
      // =1-IF(OR(T3=0,Hydrogen_storage_cap_ud=0),0,A_Hydrogen_max_cons*T3/Hydrogen_storage_cap_ud)
      d1[AL + i] = 1 - iff(or(d1[T + i].isZero, Hydrogen_storage_cap_ud.isZero), .zero, Hydrogen_max_cons[j] * d1[T + i] / Hydrogen_storage_cap_ud)
    }

    /// Max Equiv harmonious night prod due to physical limits
    let AM = 12775
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-AJ6),1),IFERROR(N6/(N6-AK6),1),IFERROR(P6/(P6-AL6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d1[AM + i] = iff(
        or(d1[L + i] <= .zero, d1[N + i] <= .zero, d1[P + i] <= 0), .zero, min(1, ifFinite(d1[L + i] / (d1[L + i] - d1[AJ + i]), 1), ifFinite(d1[N + i] / (d1[N + i] - d1[AK + i]), 1), ifFinite(d1[P + i] / (d1[P + i] - d1[AL + i]), 1)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    for i in 0..<365 {
      if d1[AM + i].isZero {
        d1[W + i] = .zero
        d1[X + i] = .zero
        d1[Y + i] = .zero
      } else {
        // A_RawMeth_max_cons*T6
        d1[W + i] = RawMeth_max_cons[j] * d1[T + i]
        // A_CO2_max_cons*T6
        d1[X + i] = CO2_max_cons[j] * d1[T + i]
        // A_Hydrogen_max_cons*T6
        d1[Y + i] = Hydrogen_max_cons[j] * d1[T + i]
      }
    }

    /// Min el cons during day for night op prep
    let Z = 8030
    // IF(AND(J3=0;F3=0);0;(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+D3*EY_fix_cons)+IF(AND(H3=0;F3=0);0;(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+D3*CCU_fix_cons)+IF(F3=0;0;F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+D3*MethSynt_fix_cons)
    for i in 0..<365 {
      d1[Z + i] =
        iff(and(d1[J + i].isZero, d1[F + i].isZero), .zero, (d1[J + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + d1[D + i] * EY_fix_cons)
        + iff(and(d1[H + i].isZero, d1[F + i].isZero), .zero, (d1[H + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + d1[D + i] * CCU_fix_cons)
        + iff(d1[F + i].isZero, .zero, d1[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + d1[D + i] * MethSynt_fix_cons)
    }

    /// Max el cons during day for night op prep
    let AA = 8395
    // IF(AND(Y3=0;W3=0);0;(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+U3*EY_fix_cons)+IF(AND(W3=0;X3=0);0;(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+U3*CCU_fix_cons)+IF(W3=0;0;W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+U3
    for i in 0..<365 {
      d1[AA + i] =
        iff(and(d1[Y + i].isZero, d1[W + i].isZero), .zero, (d1[Y + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + d1[U + i] * EY_fix_cons)
        + iff(and(d1[X + i].isZero, d1[W + i].isZero), .zero, (d1[X + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + d1[U + i] * CCU_fix_cons)
        + iff(d1[W + i].isZero, .zero, d1[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + d1[U + i] * MethSynt_fix_cons)
    }

    /// Min heat cons during day for night op prep
    let AB = 8760
    // IF(AND(J3=0;F3=0);0;(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+D3*EY_heat_fix_cons)+IF(AND(H3=0;F3=0);0;(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+D3*CCU_heat_fix_cons)-IF(F3=0;0;F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+D3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      d1[AB + i] =
        iff(and(d1[J + i].isZero, d1[F + i].isZero), .zero, (d1[J + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + d1[D + i] * EY_heat_fix_cons)
        + iff(and(d1[H + i].isZero, d1[F + i].isZero), .zero, (d1[H + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons + d1[D + i] * CCU_fix_heat_cons)
        - iff(d1[F + i].isZero, .zero, d1[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + d1[D + i] * MethSynt_heat_fix_prod)
    }

    /// Max heat cons during day for prep of night
    let AC = 9125
    // IF(AND(Y3=0;W3=0);0;(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+U3*EY_heat_fix_cons)+IF(AND(X3=0;W3=0);0;(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+U3*CCU_heat_fix_cons)-IF(W3=0;0;W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+U3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      d1[AC + i] =
        iff(and(d1[Y + i].isZero, d1[W + i].isZero), .zero, (d1[Y + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + d1[U + i] * EY_heat_fix_cons)
        + iff(and(d1[X + i].isZero, d1[W + i].isZero), .zero, (d1[X + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons + d1[U + i] * CCU_fix_heat_cons)
        - iff(d1[W + i].isZero, .zero, d1[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + d1[U + i] * MethSynt_heat_fix_prod)
    }

    /// Min Rawmeth prod during day for night op prep
    let AD = 9490
    /// Max Rawmeth prod during day for night op prep
    let AE = 9855
    /// Min CO2 prod during day for night op prep
    let AF = 10220
    /// Max CO2 prod during day for night op prep
    let AG = 10585
    /// Min H2 prod during day for night op prep
    let AH = 10950
    /// Max H2 prod during day for night op prep
    let AI = 11315
    for i in 0..<365 {
      // F6
      d1[AD + i] = d1[F + i]
      // W6
      d1[AE + i] = d1[W + i]
      // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      d1[AF + i] = d1[H + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      d1[AG + i] = d1[X + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      d1[AH + i] = d1[J + i] + d1[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
      // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      d1[AI + i] = d1[Y + i] + d1[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }
  }
}
