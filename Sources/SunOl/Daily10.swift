extension TunOl {
  func d10(_ d10: inout [Double], hour: [Double], case j: Int) {
    let (BX, CC, CS, CQ) = (595680, 639480, 779640, 762120)

    let days: [[Int]] = hour[CS + 1..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let CQ_CScountZero = hour.countOf(days, condition: CQ, predicate: { $0 <= 0 })
    let CQ_CScountNonZero = hour.countOf(days, condition: CQ, predicate: notZero)

    /// Nr of hours outside of harm op period after min night prep
    let C: Int = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    for i in 0..<365 { d10[C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let D: Int = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d10[D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let E: Int = 730
    let opHours = hour.countOf(days, condition1: BX, predicate1: { $0 > 0.0 }, condition2: CC, predicate2: { $0 > 0.0 })
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 { d10[E + i] = opHours[i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let L: Int = 3285
    /// Surplus RawMeth storage cap after max night op prep
    let M: Int = 3650
    /// Surplus CO2 storage cap after min night op prep
    let N: Int = 4015
    /// Surplus CO2 storage cap after max night op prep
    let O: Int = 4380
    /// Surplus H2 storage cap after min night op prep
    let P: Int = 4745
    /// Surplus H2 storage cap after max night op prep
    let Q: Int = 5110

    for i in 0..<365 {
      let hours = d10[C + i]
      if RawMeth_storage_cap_ud.isZero {
        d10[L + i] = RawMeth_min_cons[j].isZero ? 1 : 0
        d10[M + i] = RawMeth_max_cons[j].isZero ? 1 : 0
      } else if hours.isZero {
        (d10[L + i], d10[M + i]) = (1, 1)
      } else {
        d10[L + i] = 1 - (RawMeth_min_cons[j] * hours / RawMeth_storage_cap_ud)
        d10[M + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud)
      }

      if CO2_storage_cap_ud.isZero {
        (d10[N + i], d10[O + i]) = (CO2_min_cons[j].isZero ? 1 : 0, CO2_max_cons[j].isZero ? 1 : 0)
      } else if hours.isZero {
        (d10[N + i], d10[O + i]) = (1, 1)
      } else {
        d10[N + i] = 1 - (CO2_min_cons[j] * hours / CO2_storage_cap_ud)
        d10[O + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud)
      }

      if Hydrogen_storage_cap_ud.isZero {
        (d10[P + i], d10[Q + i]) = (Hydrogen_min_cons[j].isZero ? 1 : 0, Hydrogen_max_cons[j].isZero ? 1 : 0)
      } else if hours.isZero {
        (d10[P + i], d10[Q + i]) = (1, 1)
      } else {
        d10[P + i] = 1 - (Hydrogen_min_cons[j] * hours / Hydrogen_storage_cap_ud)
        d10[Q + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud)
      }
    }

    /// Max Equiv harmonious night prod due to physical limits
    let R: Int = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d10[R + i] = iff(
        or(d10[L + i] <= 0.0, d10[N + i] <= 0.0, d10[P + i] <= 0), 0.0,
        min(1, ifFinite(d10[L + i] / (d10[L + i] - d10[M + i]), 1), ifFinite(d10[N + i] / (d10[N + i] - d10[O + i]), 1), ifFinite(d10[P + i] / (d10[P + i] - d10[Q + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Min RawMeth cons during night
    let F: Int = 1095
    /// Max RawMeth cons during night
    let G: Int = 1460
    /// Min CO2 cons during night
    let H: Int = 1825
    /// Max CO2 cons during night
    let I: Int = 2190
    /// Min H2 cons during night
    let J: Int = 2555
    /// Max H2 cons during night
    let K: Int = 2920

    // A_RawMeth_min_cons*C6
    for i in 0..<365 {
      if d10[R + i].isZero {
        d10[F + i] = 0.0
        d10[G + i] = 0.0
        d10[H + i] = 0.0
        d10[I + i] = 0.0
        d10[J + i] = 0.0
        d10[K + i] = 0.0
      } else {
        d10[F + i] = RawMeth_min_cons[j] * d10[C + i]
        // A_RawMeth_max_cons*C6
        d10[G + i] = RawMeth_max_cons[j] * d10[C + i]
        // A_CO2_min_cons*C6
        d10[H + i] = CO2_min_cons[j] * d10[C + i]
        // A_CO2_max_cons*C6
        d10[I + i] = CO2_max_cons[j] * d10[C + i]
        // A_Hydrogen_min_cons*C6
        d10[J + i] = Hydrogen_min_cons[j] * d10[C + i]
        // A_Hydrogen_max_cons*C6
        d10[K + i] = Hydrogen_max_cons[j] * d10[C + i]
      }
    }
  }

  func night(_ d10: inout [Double], hour4: [Double], case j: Int) {
    let (F, H, J, L, N, P, EH, EX) = (1095, 1825, 2555, 3285, 4015, 4745, 105120, 236520)
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let days: [[Int]] = hour4[254041..<(254040 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] }).map { $0.map { $0 - 254040 } }
    //  let end = days.removeLast()
    // days[0].append(contentsOf: end)
    let EX_EZcountZero = hour4.countOf(days, condition: EX, predicate: { $0 <= 0 })
    /// Nr of hours outside of harm op period after max night prep
    let T: Int = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { d10[T + i] = EX_EZcountZero[i] }

    let EX_EZcountNonZero = hour4.countOf(days, condition: EX, predicate: notZero)
    /// Nr of harm op period hours after max night prep
    let U: Int = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d10[U + i] = EX_EZcountNonZero[i] }

    let EH_EZcountNonZero = hour4.countOf(days, condition: EH, predicate: notZero)
    /// Nr of PB op hours after max night prep
    let V: Int = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { d10[V + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let W: Int = 6935
    /// Max CO2 cons during night
    let X: Int = 7300
    /// Max H2 cons during night
    let Y: Int = 7665

    /// Surplus RawMeth storage cap after max night op prep
    let AJ: Int = 11680
    /// Surplus CO2 storage cap after max night op prep
    let AK: Int = 12045
    /// Surplus H2 storage cap after max night op prep
    let AL: Int = 12410

    for i in 0..<365 {
      let hours = d10[T + i]
      if RawMeth_storage_cap_ud.isZero {
        d10[AJ + i] = RawMeth_max_cons[j].isZero ? 1 : 0
      } else if hours.isZero {
        d10[AJ + i] = 1
      } else {
        d10[AJ + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud)
      }

      if CO2_storage_cap_ud.isZero {
        d10[AK + i] = CO2_max_cons[j].isZero ? 1 : 0
      } else if hours.isZero {
        d10[AK + i] = 1
      } else {
        d10[AK + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud)
      }

      if Hydrogen_storage_cap_ud.isZero {
        d10[AL + i] = Hydrogen_max_cons[j].isZero ? 1 : 0
      } else if hours.isZero {
        d10[AL + i] = 1
      } else {
        d10[AL + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud)
      }
    }
    let EJ: Int = 122640
    /// Max Equiv harmonious night prod due to physical limits
    let AM: Int = 12775
    // MIN(S3,IF(OR(L3<=0,N3<=0,P3<=0),0,MIN(1,IFERROR(L3/(L3-AJ3),1),IFERROR(N3/(N3-AK3),1),IFERROR(P3/(P3-AL3),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d10[AM + i] = min(
        hour4[days[i][0] + EJ],
        iff(
          or(d10[L + i] <= 0.0, d10[N + i] <= 0.0, d10[P + i] <= 0), 0.0,
          min(1, ifFinite(d10[L + i] / (d10[L + i] - d10[AJ + i]), 1), ifFinite(d10[N + i] / (d10[N + i] - d10[AK + i]), 1), ifFinite(d10[P + i] / (d10[P + i] - d10[AL + i]), 1))
            * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j]))
    }

    for i in 0..<365 {
      if d10[AM + i].isZero {
        d10[W + i] = 0.0
        d10[X + i] = 0.0
        d10[Y + i] = 0.0
      } else {
        // A_RawMeth_max_cons*T6
        d10[W + i] = RawMeth_max_cons[j] * d10[T + i] * d10[AM + i]
        // A_CO2_max_cons*T6
        d10[X + i] = CO2_max_cons[j] * d10[T + i] * d10[AM + i]
        // A_Hydrogen_max_cons*T6
        d10[Y + i] = Hydrogen_max_cons[j] * d10[T + i] * d10[AM + i]
      }
    }

    /// Min el cons during day for night op prep
    let Z: Int = 8030
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      if d10[AM + i].isZero {
        d10[Z + i] = 0
      } else {
        d10[Z + i] =
          iff(
            and(d10[J + i].isZero, d10[F + i].isZero), 0.0,
            (d10[J + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
          + iff(
            and(d10[H + i].isZero, d10[F + i].isZero), 0.0,
            (d10[H + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
          + iff(d10[F + i].isZero, 0.0, d10[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
      }
    }

    /// Max el cons during day for night op prep
    let AA: Int = 8395
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      d10[AA + i] =
        iff(
          and(d10[Y + i].isZero, d10[W + i].isZero), 0.0,
          (d10[Y + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
        + iff(
          and(d10[X + i].isZero, d10[W + i].isZero), 0.0,
          (d10[X + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
        + iff(d10[W + i].isZero, 0.0, d10[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
    }

    /// Min heat cons during day for night op prep
    let AB: Int = 8760
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      if d10[AM + i].isZero {
        d10[AB + i] = 0
      } else {
        d10[AB + i] =
          iff(
            and(d10[J + i].isZero, d10[F + i].isZero), 0.0,
            (d10[J + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
          + iff(
            and(d10[H + i].isZero, d10[F + i].isZero), 0.0,
            (d10[H + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
          - iff(d10[F + i].isZero, 0.0, d10[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
      }
    }

    /// Max heat cons during day for prep of night
    let AC: Int = 9125
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      d10[AC + i] =
        iff(
          and(d10[Y + i].isZero, d10[W + i].isZero), 0.0,
          (d10[Y + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
        + iff(
          and(d10[X + i].isZero, d10[W + i].isZero), 0.0,
          (d10[X + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
        - iff(d10[W + i].isZero, 0.0, d10[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
    }

    /// Min Rawmeth prod during day for night op prep
    let AD: Int = 9490
    /// Max Rawmeth prod during day for night op prep
    let AE: Int = 9855
    /// Min CO2 prod during day for night op prep
    let AF: Int = 10220
    /// Max CO2 prod during day for night op prep
    let AG: Int = 10585
    /// Min H2 prod during day for night op prep
    let AH: Int = 10950
    /// Max H2 prod during day for night op prep
    let AI: Int = 11315
    for i in 0..<365 {
      // F6
      if d10[AM + i].isZero {
        d10[AD + i] = 0
        d10[AF + i] = 0
        d10[AH + i] = 0
      } else {
        d10[AD + i] = d10[F + i]
        // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
        d10[AF + i] = d10[H + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
        // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
        d10[AH + i] = d10[J + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
      }
      // W6
      d10[AE + i] = d10[W + i]
      // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      d10[AG + i] = d10[X + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      d10[AI + i] = d10[Y + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }
  }
}
