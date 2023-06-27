extension TunOl {
  /// 0-5110
  func d10(_ d10: inout [Double], hour: [Double], case j: Int) {
    let (BX, CC, CS, CQ) = (595680, 639480, 779640, 762120)
    let CT  = 788400
    let days: [[Int]] = hour[CS + 1..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > 0.00001 }
    let CQ_CScountZero = hour.countOf(days, condition: CQ, predicate: { $0 <= 0 })
    let CQ_CScountNonZero = hour.countOf(days, condition: CQ, predicate: notZero)

    let CT_CS_countNonZero = hour.countOf(days, condition: CT, predicate: { 
      $0 > 0 && $0 != Overall_stup_cons && $0 != Overall_stby_cons
    })
    /// Nr of outside harm op period op hours after min outside harm op period prep
    let C: Int = 0
    // C=MIN(COUNTIFS(Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CT$5:$CT$8764,">0",Calculation!$CT$5:$CT$8764,"<>"&INDEX(Overall_stup_cons,1),Calculation!$CT$5:$CT$8764,"<>"&INDEX(Overall_stby_cons,1)),COUNTIFS(Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"<=0"))
    for i in 0..<365 {
      d10[C + i] = min(CT_CS_countNonZero[i], CQ_CScountZero[i])
    }

    /// Nr of harm op period hours after min night prep
    let D: Int = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d10[D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let E: Int = 730
    let opHours = hour.countOf(days, condition1: BX, predicate1: notZero, condition2: CC, predicate2: notZero)
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 { d10[E + i] = opHours[i] }

    let L: Int = 3285
    let M: Int = 3650
    let N: Int = 4015
    let O: Int = 4380
    let P: Int = 4745
    let Q: Int = 5110

    // Surplus RawMeth storage cap after min outside harm op period prep
    // L=IF(AND(A_RawMeth_min_cons=0,A_RawMeth_max_cons=0),1,1-IFERROR(A_RawMeth_min_cons*C3/RawMeth_storage_cap_ud,2))
    for i in 0..<365 {
      d10[L + i] = iff(
        and(RawMeth_min_cons[j] == Double.zero, RawMeth_max_cons[j] == Double.zero), 1,
        1 - ifFinite(RawMeth_min_cons[j] * d10[C + i] / RawMeth_storage_cap_ud, 2))
    }

    // Surplus RawMeth storage cap after max outside harm op period prep
    // M=IF(AND(A_RawMeth_min_cons=0,A_RawMeth_max_cons=0),1,1-IFERROR(A_RawMeth_max_cons*C3/RawMeth_storage_cap_ud,2))
    for i in 0..<365 {
      d10[M + i] = iff(
        and(RawMeth_min_cons[j] == Double.zero, RawMeth_max_cons[j] == Double.zero), 1,
        1 - ifFinite(RawMeth_max_cons[j] * d10[C + i] / RawMeth_storage_cap_ud, 2))
    }

    // Surplus CO2 storage cap after min outside harm op period prep
    // N=IF(AND(A_CO2_min_cons=0,A_CO2_max_cons=0),1,1-IFERROR(A_CO2_min_cons*C3/CO2_storage_cap_ud,2))
    for i in 0..<365 {
      d10[N + i] = iff(
        and(CO2_min_cons[j] == Double.zero, CO2_max_cons[j] == Double.zero), 1,
        1 - ifFinite(CO2_min_cons[j] * d10[C + i] / CO2_storage_cap_ud, 2))
    }

    // Surplus CO2 storage cap after max outside harm op period prep
    // O=IF(AND(A_CO2_min_cons=0,A_CO2_max_cons=0),1,1-IFERROR(A_CO2_max_cons*C3/CO2_storage_cap_ud,2))
    for i in 0..<365 {
      d10[O + i] = iff(
        and(CO2_min_cons[j] == Double.zero, CO2_max_cons[j] == Double.zero), 1,
        1 - ifFinite(CO2_max_cons[j] * d10[C + i] / CO2_storage_cap_ud, 2))
    }

    // Surplus H2 storage cap after min outside harm op period prep
    // P=IF(AND(A_Hydrogen_min_cons=0,A_Hydrogen_max_cons=0),1,1-IFERROR(A_Hydrogen_min_cons*C3/Hydrogen_storage_cap_ud,2))
    for i in 0..<365 {
      d10[P + i] = iff(
        and(Hydrogen_min_cons[j] == Double.zero, Hydrogen_max_cons[j] == Double.zero), 1,
        1 - ifFinite(Hydrogen_min_cons[j] * d10[C + i] / Hydrogen_storage_cap_ud, 2))
    }

    // Surplus H2 storage cap after max outside harm op period prep
    // Q=IF(AND(A_Hydrogen_min_cons=0,A_Hydrogen_max_cons=0),1,1-IFERROR(A_Hydrogen_max_cons*C3/Hydrogen_storage_cap_ud,2))
    for i in 0..<365 {
      d10[Q + i] = iff(
        and(Hydrogen_min_cons[j] == Double.zero, Hydrogen_max_cons[j] == Double.zero), 1,
        1 - ifFinite(Hydrogen_max_cons[j] * d10[C + i] / Hydrogen_storage_cap_ud, 2))
    }

    let R: Int = 5475
    // Max equiv harm op outside harm op period prod due to physical limits
    // R=IF(OR(C3=0,L3<=0,N3<=0,P3<=0),0,MIN(1,IFERROR(L3/(L3-M3),1),IFERROR(N3/(N3-O3),1),IFERROR(P3/(P3-Q3),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      d10[R + i] = iff(
        or(d10[C + i] == Double.zero, d10[L + i] <= Double.zero, d10[N + i] <= Double.zero, d10[P + i] <= Double.zero), 0,
        min(
          1, ifFinite(d10[L + i] / (d10[L + i] - d10[M + i]), 1), ifFinite(d10[N + i] / (d10[N + i] - d10[O + i]), 1),
          ifFinite(d10[P + i] / (d10[P + i] - d10[Q + i]), 1)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Min RawMeth cons during night
    let F: Int = 1095
    /// Min CO2 cons during night
    let H: Int = 1825
    /// Min H2 cons during night
    let J: Int = 2555
    /// Max H2 cons during night
    let K: Int = 2920

    // A_RawMeth_min_cons*C6
    for i in 0..<365 {
      if d10[R + i].isZero {
        d10[F + i] = Double.zero
        d10[H + i] = Double.zero
        d10[J + i] = Double.zero
        d10[K + i] = Double.zero
      } else {
        d10[F + i] = RawMeth_min_cons[j] * d10[C + i]
        // A_CO2_min_cons*C6
        d10[H + i] = CO2_min_cons[j] * d10[C + i]
        // A_Hydrogen_min_cons*C6
        d10[J + i] = Hydrogen_min_cons[j] * d10[C + i]  // A_Hydrogen_max_cons*C6
        // d10[K + i] = Hydrogen_max_cons[j] * d10[C + i]
      }
    }
  }
  // 5840-11315
  func night(_ d10: inout [Double], hour4: [Double], case j: Int) {
    let (F, H, J, L, N, P, EH, EX) = (1095, 1825, 2555, 3285, 4015, 4745, 105120, 245280)
    let notZero: (Double) -> Bool = { $0 > 0.000001 }
    let days: [[Int]] = hour4[262801..<(262800 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] })
      .map { $0.map { $0 - 262800 } }

    let FA: Int = 271560
    let EX_EZcountZero = hour4.countOf(days, condition: EX, predicate: { $0 <= Double.zero })
    let FA_EZcountNonZero = hour4.countOf(days, condition: FA, predicate: notZero)

    let FA_EZ_countNonZero = hour4.countOf(days, condition: FA, predicate: { 
      $0 > 0 && $0 != Overall_stup_cons && $0 != Overall_stby_cons
    })
    /// Nr of hours outside of harm op period after max night prep
    let T: Int = 5840
    // Nr of outside harm op period op hours after max outside harm op period prep
    // T=MIN(COUNTIFS(Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$FA$5:$FA$8764,">0",Calculation!$FA$5:$FA$8764,"<>"&INDEX(A_overall_stup_cons,1),Calculation!$FA$5:$FA$8764,"<>"&INDEX(A_overall_fix_stby_cons,1)),COUNTIFS(Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"<=0"))
    for i in 0..<365 {
      d10[T + i] = min(FA_EZ_countNonZero[i], EX_EZcountZero[i])
    }

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
    /// Heat consumption outside harm op period in case no op outside harm op period. After column V
    let I: Int = 2190
    /// Electricity consumption outside harm op period in case no op outside harm op period. After column V
    let G: Int = 1460
    let EX_EZbelowZero = hour4.countOf(days, condition: EX, predicate: { $0 <= 0 })
    for i in 0..<365 {
      // G=(A_overall_var_min_cons+A_overall_fix_stby_cons)*IF(T3>0,T3,COUNTIFS(Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"<=0"))+A_overall_stup_cons
      d10[G + i] = (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * iff(d10[T + i] > Double.zero,d10[T + i], EX_EZbelowZero[i]) + overall_stup_cons[j]
      // I=(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*IF(T3>0,T3,COUNTIFS(Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"<=0"))+A_overall_heat_stup_cons
      d10[I + i] = (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * iff(d10[T + i] > Double.zero,d10[T + i], EX_EZbelowZero[i]) + overall_heat_stup_cons[j]
    }
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
        d10[AJ + i] = RawMeth_max_cons[j].isZero ? 1.0 : Double.zero
      } else if hours.isZero {
        d10[AJ + i] = 1
      } else {
        d10[AJ + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud)
      }

      if CO2_storage_cap_ud.isZero {
        d10[AK + i] = CO2_max_cons[j].isZero ? 1.0 : Double.zero
      } else if hours.isZero {
        d10[AK + i] = 1
      } else {
        d10[AK + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud)
      }

      if Hydrogen_storage_cap_ud.isZero {
        d10[AL + i] = Hydrogen_max_cons[j].isZero ? 1.0 : Double.zero
      } else if hours.isZero {
        d10[AL + i] = 1
      } else {
        d10[AL + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud)
      }
    }

    // Surplus RawMeth storage cap after max outside harm op period prep
    // AJ=IF(AND(A_RawMeth_min_cons=0,A_RawMeth_max_cons=0),1,1-IFERROR(A_RawMeth_max_cons*T3/RawMeth_storage_cap_ud,2))
    for i in 0..<365 {
      d10[AJ + i] = iff(
        and(RawMeth_min_cons[j] == Double.zero, RawMeth_max_cons[j] == Double.zero), 1,
        1 - ifFinite(RawMeth_max_cons[j] * d10[T + i] / RawMeth_storage_cap_ud, 2))
    }

    // Surplus CO2 storage cap after max outside harm op period prep
    // AK=IF(AND(A_CO2_min_cons=0,A_CO2_max_cons=0),1,1-IFERROR(A_CO2_max_cons*T3/CO2_storage_cap_ud,2))
    for i in 0..<365 {
      d10[AK + i] = iff(
        and(CO2_min_cons[j] == Double.zero, CO2_max_cons[j] == Double.zero), 1,
        1 - ifFinite(CO2_max_cons[j] * d10[T + i] / CO2_storage_cap_ud, 2))
    }

    // Surplus H2 storage cap after max outside harm op period prep
    // AL=IF(AND(A_Hydrogen_min_cons=0,A_Hydrogen_max_cons=0),1,1-IFERROR(A_Hydrogen_max_cons*T3/Hydrogen_storage_cap_ud,2))
    for i in 0..<365 {
      d10[AL + i] = iff(
        and(Hydrogen_min_cons[j] == Double.zero, Hydrogen_max_cons[j] == Double.zero), 1,
        1 - ifFinite(Hydrogen_max_cons[j] * d10[T + i] / Hydrogen_storage_cap_ud, 2))
    }

    let EJ: Int = 122640
    /// Max Equiv harmonious night prod due to physical limits
    let AM: Int = 12775
    // MIN(S3,IF(OR(L3<=0,N3<=0,P3<=0),0,MIN(1,IFERROR(L3/(L3-AJ3),1),IFERROR(N3/(N3-AK3),1),IFERROR(P3/(P3-AL3),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      d10[AM + i] = min(
        hour4[days[i][0] + EJ],
        iff(
          or(d10[L + i] <= Double.zero, d10[N + i] <= Double.zero, d10[P + i] <= Double.zero), Double.zero,
          min(
            1, ifFinite(d10[L + i] / (d10[L + i] - d10[AJ + i]), 1.0), ifFinite(d10[N + i] / (d10[N + i] - d10[AK + i]), 1.0),
            ifFinite(d10[P + i] / (d10[P + i] - d10[AL + i]), 1.0))
            * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j]))
    }

    // Max RawMeth cons during outside harm op period
    // W=IF(AM3=0,0,((AM3-A_equiv_harmonious_min_perc)*(A_RawMeth_max_cons-A_RawMeth_min_cons)+A_RawMeth_min_cons)*T3)
    for i in 0..<365 {
      d10[W + i] = iff(
        d10[AM + i] == Double.zero, 0,
        ((d10[AM + i] - equiv_harmonious_min_perc[j]) * (RawMeth_max_cons[j] - RawMeth_min_cons[j]) + RawMeth_min_cons[j])
          * d10[T + i])
    }

    // Max CO2 cons during outside harm op period
    // X=IF(AM3=0,0,((AM3-A_equiv_harmonious_min_perc)*(A_CO2_max_cons-A_CO2_min_cons)+A_CO2_min_cons)*T3)
    for i in 0..<365 {
      d10[X + i] = iff(
        d10[AM + i] == Double.zero, 0,
        ((d10[AM + i] - equiv_harmonious_min_perc[j]) * (CO2_max_cons[j] - CO2_min_cons[j]) + CO2_min_cons[j]) * d10[T + i])
    }

    // Max H2 cons during outside harm op period
    // Y=IF(AM3=0,0,((AM3-A_equiv_harmonious_min_perc)*(A_Hydrogen_max_cons-A_Hydrogen_min_cons)+A_Hydrogen_min_cons)*T3)
    for i in 0..<365 {
      d10[Y + i] = iff(
        d10[AM + i] == Double.zero, 0,
        ((d10[AM + i] - equiv_harmonious_min_perc[j]) * (Hydrogen_max_cons[j] - Hydrogen_min_cons[j]) + Hydrogen_min_cons[j])
          * d10[T + i])
    }

    /// Min el cons during day for night op prep
    let Z: Int = 8030
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      if d10[AM + i].isZero {
        d10[Z + i] = 0
      } else {
        d10[Z + i] =
          iff(and(d10[J + i].isZero, d10[F + i].isZero), Double.zero, (d10[J + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
          + iff(and(d10[H + i].isZero, d10[F + i].isZero), Double.zero, (d10[H + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
          + iff(d10[F + i].isZero, Double.zero, d10[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
      }
    }

    /// Max el cons during day for night op prep
    let AA: Int = 8395
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      d10[AA + i] =
        iff(and(d10[Y + i].isZero, d10[W + i].isZero), Double.zero, (d10[Y + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
        + iff(and(d10[X + i].isZero, d10[W + i].isZero), Double.zero, (d10[X + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
        + iff(d10[W + i].isZero, Double.zero, d10[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
    }

    /// Min heat cons during day for night op prep
    let AB: Int = 8760
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      if d10[AM + i].isZero {
        d10[AB + i] = 0
      } else {
        d10[AB + i] =
          iff(and(d10[J + i].isZero, d10[F + i].isZero), Double.zero, (d10[J + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
          + iff(and(d10[H + i].isZero, d10[F + i].isZero), Double.zero, (d10[H + i] + d10[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
          - iff(d10[F + i].isZero, Double.zero, d10[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
      }
    }

    /// Max heat cons during day for prep of night
    let AC: Int = 9125
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      d10[AC + i] =
        iff(and(d10[Y + i].isZero, d10[W + i].isZero), Double.zero, (d10[Y + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
        + iff(and(d10[X + i].isZero, d10[W + i].isZero), Double.zero, (d10[X + i] + d10[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
        - iff(d10[W + i].isZero, Double.zero, d10[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
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
        d10[AD + i] = Double.zero
        d10[AF + i] = Double.zero
        d10[AH + i] = Double.zero
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
  /// 11680-28470
  func d11(_ d11: inout [Double], hour: [Double], case j: Int) {
    let (_, _, CQ, _, CS) = (727080, 735840, 762120, 770880, 779640)
    let (CT, _, CV, CW, CX) = (788400, 797160, 805920, 814680, 823440)
    let (CY, TH, DA, DB, DC) = (832200, 840960, 849720, 858480, 867240)
    let (DD, DE, DF, DH, _) = (876000, 884760, 893520, 911040, 919800)
    let (DJ, DK, _, DM, TI) = (928560, 937320, 946080, 954840, 963600)
    let (DO, DP, DQ, DR, DS, DT) = (972360, 981120, 989880, 998640, 1_007_400, 1_016_160)
    let days: [[Int]] = hour[(CS + 1)..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }

    let (EY, EZ, FA, FB, FC, FD, FE, _, _, _, _, _, FK, FL, FM, _, _, _, _, _, FS, FT, FU, FV, FW, FX, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI, _, GK, GL, _, GN, GO, _, GQ, GR, _) = (
      13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155, 17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805, 21170, 21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820, 25185,
      25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200, 29565, 29930
    )

    let CO: Int = 744600
    // SUMIFS(Calculation!CO5:CO8764,Calculation!CS$5:CS8764,"="&$A6,Calculation!CQ5:CQ8764,">0")
    hour.sumOf(CO, days: days, into: &d11, at: EY, condition: CQ, predicate: notZero)
    let DU: Int = 1_024_920
    // SUMIFS(Calculation!DU5:DU8764,Calculation!CS5:CS8764,"="&$A6,Calculation!DH5:DH8764,">0")
    hour.sumOf(DU, days: days, into: &d11, at: EZ, condition: DH, predicate: notZero)
    /// Grid import for min/max harm and stby outside harm op
    // SUMIF(Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CO$5:$CO$8764)-EY6
    hour.sum(days: days, range: CO, into: &d11, at: FA)
    for i in 0..<365 { d11[FA + i] -= d11[EY + i] }
    /// El cons considering min harm op during harm op period including grid import
    hour.sum(days: days, range: CQ, into: &d11, at: FB)
    hour.sumOf(CT, days: days, into: &d11, at: FC, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FC + i] += d11[FB + i] }
    /// El cons considering max harm op during harm op period including grid import
    hour.sum(days: days, range: DH, into: &d11, at: FB)

    hour.sumOf(CT, days: days, into: &d11, at: FD, condition: DH, predicate: notZero)
    for i in 0..<365 { d11[FD + i] += d11[FB + i] }
    for i in 0..<365 { d11[FB + i] = 0 }
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,    for i in 0..<365 { d11[FD + i] += d11[FB + i]; d11[FB + i] = 0 }
    /// El cons considering min/max harm op outside  harm op period including grid import (if any)
    let CC: Int = 639480
    hour.sumOf(CT, days: days, into: &d11, at: FE, condition1: CQ, predicate1: { $0.isZero }, condition2: CC, predicate2: notZero)
    // FE=MAX(0,SUMIFS(Calculation!$CT$5:$CT$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0",Calculation!$CC$5:$CC$8764,">0")-A_overall_stup_cons)
    for i in 0..<365 { d11[FE + i] = max(Double.zero, d11[FE + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    // hour.sum(days: days, range: CR, into: &d11, at: FB)
    // hour.sumOf(CU, days: days, into: &d11, at: FF, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { d11[FF + i] += d11[FB + i]; d11[FB + i] = 0 }
    /// Harm heat cons considering max harm op during harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    // hour.sum(days: days, range: DI, into: &d11, at: FB)
    // hour.sumOf(CU, days: days, into: &d11, at: FG, condition: DH, predicate: notZero)
    // for i in 0..<365 { d11[FG + i] += d11[FB + i]; d11[FB + i] = 0 }
    /// Harm heat cons outside of harm op period
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // hour.sumOf(CU, days: days, into: &d11, at: FH, condition: CQ, predicate: { $0.isZero })
    /// Electr demand not covered after min harm and stby during harm op period
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // hour.sumOf(CX, days: days, into: &d11, at: FI, condition: CQ, predicate: notZero)
    /// Electr demand not covered after max harm and stby during harm op period
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    // hour.sumOf(DL, days: days, into: &d11, at: FJ, condition: DH, predicate: notZero)
    /// Electr demand not covered after min/max harm and stby outside harm op period
    // =SUMIFS(Calculation!$CX$5:$CX$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0")
    hour.sumOf(CX, days: days, into: &d11, at: FK, condition: CQ, predicate: { $0.isZero })
    /// El boiler op considering min harm op during harm op period
    // // FL=SUMIFS(Calculation!$TH$5:$TH$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,">0")
    hour.sumOf(TH, days: days, into: &d11, at: FL, condition: CQ, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    // FM=SUMIFS(Calculation!$TI$5:$TI$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$DH$5:$DH$8764,">0")
    hour.sumOf(TI, days: days, into: &d11, at: FM, condition: DH, predicate: notZero)
    /// El boiler op outside harm op period
    // FN=SUMIFS(Calculation!$TH$5:$TH$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0")
    hour.sumOf(TH, days: days, into: &d11, at: FL, condition: CQ, predicate: { $0.isZero })
    /// Total aux cons during harm op period
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // hour.sumOfRanges(CM, days: days, into: &d11, at: FO, range1: hour, condition: CQ, predicate: notZero)
    /// Total aux cons outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    // hour.sum(days: days, range: CM, into: &d11, at: FP)
    // for i in 0..<365 { d11[FP + i] -= d11[FO + i] }
    /// El cons not covered during harm op period
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // hour.sumOfRanges(CN, days: days, into: &d11, at: FQ, range1: hour, condition: CQ, predicate: notZero)
    /// El cons not covered outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    // hour.sum(days: days, range: CN, into: &d11, at: FR)
    // for i in 0..<365 { d11[FR + i] -= d11[FQ + i] }
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CV, days: days, into: &d11, at: FS, condition: CQ, predicate: notZero)
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DJ, days: days, into: &d11, at: FT, condition: DH, predicate: notZero)
    /// Remaining PV el outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    hour.sum(days: days, range: CV, into: &d11, at: FU)
    for i in 0..<365 { d11[FU + i] -= d11[FS + i] }
    /// Remaining CSP heat after min harm during harm op period
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CW, days: days, into: &d11, at: FV, condition: CQ, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DK, days: days, into: &d11, at: FW, condition: DH, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    hour.sum(days: days, range: CW, into: &d11, at: FX)
    for i in 0..<365 { d11[FX + i] -= d11[FV + i] }
    /// Max BESS night prep after min harm cons during harm op period
    hour.sumOf(DE, days: days, into: &d11, at: FY, condition: CQ, predicate: notZero)
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FY + i] = min(d11[FY + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep after max harm cons during harm op period
    hour.sumOf(DS, days: days, into: &d11, at: FZ, condition: DH, predicate: notZero)
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FZ + i] = min(d11[FZ + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep outside of harm op period
    // =MIN(SUMIFS(Calculation!$DE$5:$DE$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0"),BESS_cap_ud/BESS_chrg_eff)
    hour.sumOf(DE, days: days, into: &d11, at: GA, condition: CQ, predicate: { $0.isZero })
    for i in 0..<365 { d11[GA + i] = min(d11[GA + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DF, days: days, into: &d11, at: GB, condition: CQ, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DT, days: days, into: &d11, at: GC, condition: DH, predicate: notZero)
    /// Max grid export outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    hour.sum(days: days, range: DF, into: &d11, at: GD)
    for i in 0..<365 { d11[GD + i] -= d11[GB + i] }
    /// Remaining grid import during harm op period after min harm
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CY, days: days, into: &d11, at: GE, condition: CQ, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DM, days: days, into: &d11, at: GF, condition: DH, predicate: notZero)
    /// Remaining grid import outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    hour.sum(days: days, range: CY, into: &d11, at: GG)
    for i in 0..<365 { d11[GG + i] -= d11[GE + i] }
    /// Remaining El boiler cap during harm op period after min harm
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DA, days: days, into: &d11, at: GH, condition: CQ, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DO, days: days, into: &d11, at: GI, condition: DH, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    //  hour.sum(days: days, range: DA, into: &d11, at: GJ)
    // for i in 0..<365 { d11[GJ + i] -= d11[GH + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DB, days: days, into: &d11, at: GK, condition: CQ, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DP, days: days, into: &d11, at: GL, condition: DH, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    // hour.sum(days: days, range: DB, into: &d11, at: GM)
    // for i in 0..<365 { d11[GM + i] -= d11[GK + i] }
    /// Remaining CCU cap during harm op after min harm
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DC, days: days, into: &d11, at: GN, condition: CQ, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DQ, days: days, into: &d11, at: GO, condition: DH, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    // hour.sum(days: days, range: DC, into: &d11, at: GP)
    // for i in 0..<365 { d11[GP + i] -= d11[GN + i] }
    /// Remaining EY cap during harm op after min harm
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DD, days: days, into: &d11, at: GQ, condition: CQ, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DR, days: days, into: &d11, at: GR, condition: DH, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    // hour.sum(days: days, range: DD, into: &d11, at: GS)
    // for i in 0..<365 { d11[GS + i] -= d11[GQ + i] }
  }

  func d12(_ d12: inout [Double], hourFinal: [Double], case j: Int) {
    let daysEZ: [[Int]] = hourFinal[262801..<(262800 + 8760)].indices.chunked(by: { hourFinal[$0] == hourFinal[$1] }).map { $0.map { $0 - 262800 } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }
    let (ET, EU, EX, EY, FA) = (210240, 219000, 245280, 254040, 271560)
    let (FB, FC, FD, FE, FF) = (280320, 289080, 297840, 306600, 315360)
    let (TJ, FH, FI, FJ, FK) = (324120, 332880, 341640, 350400, 359160)
    let (FL, FM, FO, FP, FQ) = (367920, 376680, 394200, 402960, 411720)
    let (FR, FS, FT, TK, FV) = (420480, 429240, 438000, 446760, 455520)
    let (FW, FX, FY, FZ, GA) = (464280, 473040, 481800, 490560, 499320)
    let (GU, GV, GW, GX, GY, GZ, HA, HB, HC, HD, HE, HF, HG, HH, HI, HJ, HK, HL, HM, HN, HO, HP, HQ, HR, HS, HT, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE, IF, IG, IH, II, IJ, IK, IL, IM, IN, IO) = (
      30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580, 33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230, 37595, 37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610, 41975, 42340, 42705,
      43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625, 45990, 46355, 46720, 47085, 47450
    )

    let TB: Int = 508080
    /// Available elec after TES chrg during harm op period
    // SUMIFS(Calculation!$TB$5:$TB$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(TB, days: daysEZ, into: &d12, at: GU, condition: EX, predicate: notZero)
    let TC: Int = 499320
    // SUMIFS(Calculation!$TC$5:$TC$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(TC, days: daysEZ, into: &d12, at: GV, condition: FO, predicate: notZero)
    /// Available heat after TES chrg during harm op period
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$TB$5:$TB$8764)-GU6
    hourFinal.sum(days: daysEZ, range: TB, into: &d12, at: GW)
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    // for i in 0..<365 { d12[GX + i] = EZ_EX_Jsum[i - 1] + EZ_EX_EIsum[i - 1] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i - 1] }
    /// Harm el cons considering min harm op during harm op period
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GY, condition: EX, predicate: notZero)
    // SUMIF(Calculation!EZ$5:EZ8764,"="A6,Calculation!$EX$5:$EX$8764)+SUMIFS(Calculation!FA5:FA8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sum(days: daysEZ, range: EX, into: &d12, at: GY)
    /// Harm el cons considering max harm op during harm op period
    hourFinal.sum(days: daysEZ, range: FO, into: &d12, at: GX)
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GZ, condition: FO, predicate: notZero)
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764)+SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    for i in 0..<365 { d12[GZ + i] += d12[GX + i] }
    /// Harm el cons outside of harm op period
    let EJ: Int = 122640
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: HA, condition1: EX, predicate1: { $0.isZero }, condition2: EJ, predicate2: notZero)
    // HA=MAX(0,SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"=0",Calculation!$EJ$5:$EJ$8764,">0")-A_overall_stup_cons)
    for i in 0..<365 { d12[HA + i] = max(Double.zero, d12[HA + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    hourFinal.sum(days: daysEZ, range: EY, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HB, condition: EX, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d12[HB + i] += d12[GX + i] }
    /// Harm heat cons considering max harm op during harm op period
    hourFinal.sum(days: daysEZ, range: FP, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HC, condition: FO, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d12[HC + i] += d12[GX + i] }

    for i in 0..<365 { d12[GX + i] = 0 }
    /// Harm heat cons outside of harm op period
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HD, condition: EX, predicate: { $0.isZero })
    /// Grid import considering min harm op during harm op period
    // SUMIFS(Calculation!$FE$5:$FE$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(FE, days: daysEZ, into: &d12, at: HE, condition: EX, predicate: notZero)
    /// Grid import considering max harm op during harm op period
    // SUMIFS(Calculation!$FS$5:$FS$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(FS, days: daysEZ, into: &d12, at: HF, condition: FO, predicate: notZero)
    /// Grid import  outside of harm op period
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FE$5:$FE$8764)-HE6
    hourFinal.sum(days: daysEZ, range: FE, into: &d12, at: HG)
    for i in 0..<365 { d12[HG + i] -= d12[HE + i] }
    /// El boiler op considering min harm op during harm op period
    // HH=SUMIFS(Calculation!$TJ$5:$TJ$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(TJ, days: daysEZ, into: &d12, at: HH, condition: EX, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    // HI=SUMIFS(Calculation!$TK$5:$TK$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(TK, days: daysEZ, into: &d12, at: HI, condition: FO, predicate: notZero)
    /// El boiler op outside harm op period
    // HJ=SUMIFS(Calculation!$TJ$5:$TJ$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"=0")
    hourFinal.sumOf(TJ, days: daysEZ, into: &d12, at: HJ, condition: EX, predicate: { $0.isZero })
    /// Total aux cons during harm op period
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(ET, days: daysEZ, into: &d12, at: HK, condition: EX, predicate: notZero)
    /// Total aux cons outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    hourFinal.sum(days: daysEZ, range: ET, into: &d12, at: HL)
    for i in 0..<365 { d12[HL + i] -= d12[HK + i] }
    /// El cons not covered during harm op period
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(EU, days: daysEZ, into: &d12, at: HM, condition: EX, predicate: notZero)
    /// El cons not covered outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    hourFinal.sum(days: daysEZ, range: EU, into: &d12, at: HN)
    for i in 0..<365 { d12[HN + i] -= d12[HM + i] }
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FC, days: daysEZ, into: &d12, at: HO, condition: EX, predicate: notZero)
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FQ, days: daysEZ, into: &d12, at: HP, condition: FO, predicate: notZero)
    /// Remaining PV el outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    hourFinal.sum(days: daysEZ, range: FC, into: &d12, at: HQ)
    for i in 0..<365 { d12[HQ + i] -= d12[HO + i] }
    /// Remaining CSP heat after min harm during harm op period
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FD, days: daysEZ, into: &d12, at: HR, condition: EX, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FR, days: daysEZ, into: &d12, at: HS, condition: FO, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    hourFinal.sum(days: daysEZ, range: FD, into: &d12, at: HT)
    for i in 0..<365 { d12[HT + i] -= d12[HR + i] }
    /// Max elec to BESS for night prep after min harm op during harm op period
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HU, condition: EX, predicate: notZero)
    for i in 0..<365 { d12[HU + i] = min(d12[HU + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep after max harm op during harm op period
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FZ, days: daysEZ, into: &d12, at: HV, condition: FO, predicate: notZero)
    for i in 0..<365 { d12[HV + i] = min(d12[HV + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep outside of harm op period
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HW, condition: EX, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d12[HW + i] = min(d12[HW + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FM, days: daysEZ, into: &d12, at: HX, condition: EX, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(GA, days: daysEZ, into: &d12, at: HY, condition: FO, predicate: notZero)
    /// Max grid export outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    hourFinal.sum(days: daysEZ, range: FM, into: &d12, at: HZ)
    for i in 0..<365 { d12[HZ + i] -= d12[HX + i] }
    /// Remaining grid import during harm op period after min harm
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FF, days: daysEZ, into: &d12, at: IA, condition: EX, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FT, days: daysEZ, into: &d12, at: IB, condition: FO, predicate: notZero)
    /// Remaining grid import outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    hourFinal.sum(days: daysEZ, range: FF, into: &d12, at: IC)
    for i in 0..<365 { d12[IC + i] -= d12[IA + i] }
    /// Remaining El boiler cap during harm op period after min harm
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FH, days: daysEZ, into: &d12, at: ID, condition: EX, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FV, days: daysEZ, into: &d12, at: IE, condition: FO, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    hourFinal.sum(days: daysEZ, range: FH, into: &d12, at: IF)
    for i in 0..<365 { d12[IF + i] -= d12[ID + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FI, days: daysEZ, into: &d12, at: IG, condition: EX, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FW, days: daysEZ, into: &d12, at: IH, condition: FO, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    hourFinal.sum(days: daysEZ, range: FI, into: &d12, at: II)
    for i in 0..<365 { d12[II + i] -= d12[IG + i] }
    /// Remaining CCU cap during harm op after min harm
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FJ, days: daysEZ, into: &d12, at: IJ, condition: EX, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FX, days: daysEZ, into: &d12, at: IK, condition: FO, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    hourFinal.sum(days: daysEZ, range: FJ, into: &d12, at: IL)
    for i in 0..<365 { d12[IL + i] -= d12[IJ + i] }
    /// Remaining EY cap during harm op after min harm
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FK, days: daysEZ, into: &d12, at: IM, condition: EX, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FY, days: daysEZ, into: &d12, at: IN, condition: FO, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    hourFinal.sum(days: daysEZ, range: FK, into: &d12, at: IO)
    for i in 0..<365 { d12[IO + i] -= d12[IM + i] }
  }
}
