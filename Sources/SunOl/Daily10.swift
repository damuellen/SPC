extension TunOl {
  /// 0-5110
  func d10(_ h: UnsafeMutableBufferPointer<Double>, case j: Int) {
    let days: [[Int]] = h[(CS + 1)..<CT].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }
    let CQ_CScountZero = h.countOf(days, condition: CQ, predicate: { $0 <= 0 })
    let CQ_CScountNonZero = h.countOf(days, condition: CQ, predicate: notZero)

    /// Nr of hours outside of harm op period after min night prep
    let C: Int = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    for i in 0..<365 { h[C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let D: Int = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { h[D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let E: Int = 730
    let opHours = h.countOf(days, condition1: BX, predicate1: { $0 > Double.zero }, condition2: CC, predicate2: { $0 > Double.zero })
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 { h[E + i] = opHours[i] }

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
      let hours = h[C + i]
      if RawMeth_storage_cap_ud.isZero {
        h[L + i] = RawMeth_min_cons[j].isZero ? 1.0 : Double.zero
        h[M + i] = RawMeth_max_cons[j].isZero ? 1.0 : Double.zero
      } else if hours.isZero {
        (h[L + i], h[M + i]) = (1.0, 1.0)
      } else {
        h[L + i] = 1 - (RawMeth_min_cons[j] * hours / RawMeth_storage_cap_ud)
        h[M + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud)
      }

      if CO2_storage_cap_ud.isZero {
        (h[N + i], h[O + i]) = (CO2_min_cons[j].isZero ? 1.0 : Double.zero, CO2_max_cons[j].isZero ? 1.0 : Double.zero)
      } else if hours.isZero {
        (h[N + i], h[O + i]) = (1, 1.0)
      } else {
        h[N + i] = 1 - (CO2_min_cons[j] * hours / CO2_storage_cap_ud)
        h[O + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud)
      }

      if Hydrogen_storage_cap_ud.isZero {
        (h[P + i], h[Q + i]) = (Hydrogen_min_cons[j].isZero ? 1.0 : Double.zero, Hydrogen_max_cons[j].isZero ? 1.0 : Double.zero)
      } else if hours.isZero {
        (h[P + i], h[Q + i]) = (1, 1.0)
      } else {
        h[P + i] = 1 - (Hydrogen_min_cons[j] * hours / Hydrogen_storage_cap_ud)
        h[Q + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud)
      }
    }

    /// Max Equiv harmonious night prod due to physical limits
    let R: Int = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[R + i] = iff(
        or(h[L + i] <= Double.zero, h[N + i] <= Double.zero, h[P + i] <= 0), Double.zero,
        min(1, ifFinite(h[L + i] / (h[L + i] - h[M + i]), 1.0), ifFinite(h[N + i] / (h[N + i] - h[O + i]), 1.0), ifFinite(h[P + i] / (h[P + i] - h[Q + i]), 1.0)) * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
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
      if h[R + i].isZero {
        h[F + i] = Double.zero
        h[G + i] = Double.zero
        h[H + i] = Double.zero
        h[I + i] = Double.zero
        h[J + i] = Double.zero
        h[K + i] = Double.zero
      } else {
        h[F + i] = RawMeth_min_cons[j] * h[C + i]
        // A_RawMeth_max_cons*C6
        // h[G + i] = RawMeth_max_cons[j] * h[C + i]
        // A_CO2_min_cons*C6
        h[H + i] = CO2_min_cons[j] * h[C + i]
        // A_CO2_max_cons*C6
        // h[I + i] = CO2_max_cons[j] * h[C + i]
        // A_Hydrogen_min_cons*C6
        h[J + i] = Hydrogen_min_cons[j] * h[C + i]
        // A_Hydrogen_max_cons*C6
        // h[K + i] = Hydrogen_max_cons[j] * h[C + i]
      }
    }
  }
  // 5840-11315
  func night(_ h: UnsafeMutableBufferPointer<Double>, case j: Int) {
    let notZero: (Double) -> Bool = { $0 > Double.zero }
    let days: [[Int]] = h[(EZ + 1)..<FA].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - EZ } }
    //  let end = days.removeLast()
    // days[0].append(contentsOf: end)
    let EX_EZcountZero = h.countOf(days, condition: EX, predicate: { $0 <= Double.zero })
    /// Nr of hours outside of harm op period after max night prep
    let T: Int = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    for i in 0..<365 { h[T + i] = EX_EZcountZero[i] }

    let EX_EZcountNonZero = h.countOf(days, condition: EX, predicate: notZero)
    /// Nr of harm op period hours after max night prep
    let U: Int = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { h[U + i] = EX_EZcountNonZero[i] }
    let EH_EZcountNonZero = h.countOf(days, condition: EH, predicate: notZero)
    /// Nr of PB op hours after max night prep
    let V: Int = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    for i in 0..<365 { h[V + i] = EH_EZcountNonZero[i] }

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
      let hours = h[T + i]
      if RawMeth_storage_cap_ud.isZero { h[AJ + i] = RawMeth_max_cons[j].isZero ? 1.0 : Double.zero } else if hours.isZero { h[AJ + i] = 1 } else { h[AJ + i] = 1 - (RawMeth_max_cons[j] * hours / RawMeth_storage_cap_ud) }

      if CO2_storage_cap_ud.isZero { h[AK + i] = CO2_max_cons[j].isZero ? 1.0 : Double.zero } else if hours.isZero { h[AK + i] = 1 } else { h[AK + i] = 1 - (CO2_max_cons[j] * hours / CO2_storage_cap_ud) }

      if Hydrogen_storage_cap_ud.isZero { h[AL + i] = Hydrogen_max_cons[j].isZero ? 1.0 : Double.zero } else if hours.isZero { h[AL + i] = 1 } else { h[AL + i] = 1 - (Hydrogen_max_cons[j] * hours / Hydrogen_storage_cap_ud) }
    }
    let EJ: Int = 122640
    /// Max Equiv harmonious night prod due to physical limits
    let AM: Int = 12775
    // MIN(S3,IF(OR(L3<=0,N3<=0,P3<=0),0,MIN(1,IFERROR(L3/(L3-AJ3),1),IFERROR(N3/(N3-AK3),1),IFERROR(P3/(P3-AL3),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[AM + i] = min(
        h[days[i][0] + EJ],
        iff(
          or(h[L + i] <= Double.zero, h[N + i] <= Double.zero, h[P + i] <= 0), Double.zero,
          min(1, ifFinite(h[L + i] / (h[L + i] - h[AJ + i]), 1.0), ifFinite(h[N + i] / (h[N + i] - h[AK + i]), 1.0), ifFinite(h[P + i] / (h[P + i] - h[AL + i]), 1.0))
            * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j]))
    }

    for i in 0..<365 {
      if h[AM + i].isZero {
        h[W + i] = Double.zero
        h[X + i] = Double.zero
        h[Y + i] = Double.zero
      } else {
        // A_RawMeth_max_cons*T6
        h[W + i] = RawMeth_max_cons[j] * h[T + i] * h[AM + i]
        // A_CO2_max_cons*T6
        h[X + i] = CO2_max_cons[j] * h[T + i] * h[AM + i]
        // A_Hydrogen_max_cons*T6
        h[Y + i] = Hydrogen_max_cons[j] * h[T + i] * h[AM + i]
      }
    }

    /// Min el cons during day for night op prep
    let Z: Int = 8030
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      if h[AM + i].isZero {
        h[Z + i] = 0
      } else {
        h[Z + i] =
          iff(and(h[J + i].isZero, h[F + i].isZero), Double.zero, (h[J + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
          + iff(and(h[H + i].isZero, h[F + i].isZero), Double.zero, (h[H + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
          + iff(h[F + i].isZero, Double.zero, h[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
      }
    }

    /// Max el cons during day for night op prep
    let AA: Int = 8395
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons)+IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons)
    for i in 0..<365 {
      h[AA + i] =
        iff(and(h[Y + i].isZero, h[W + i].isZero), Double.zero, (h[Y + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons)
        + iff(and(h[X + i].isZero, h[W + i].isZero), Double.zero, (h[X + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons)
        + iff(h[W + i].isZero, Double.zero, h[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons)
    }

    /// Min heat cons during day for night op prep
    let AB: Int = 8760
    // IF(AND(J3=0,F3=0),0,(J3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(H3=0,F3=0),0,(H3+F3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(F3=0,0,F3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      if h[AM + i].isZero {
        h[AB + i] = 0
      } else {
        h[AB + i] =
          iff(and(h[J + i].isZero, h[F + i].isZero), Double.zero, (h[J + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
          + iff(and(h[H + i].isZero, h[F + i].isZero), Double.zero, (h[H + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
          - iff(h[F + i].isZero, Double.zero, h[F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
      }
    }

    /// Max heat cons during day for prep of night
    let AC: Int = 9125
    // IF(AND(Y3=0,W3=0),0,(Y3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons)+IF(AND(X3=0,W3=0),0,(X3+W3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons)-IF(W3=0,0,W3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod)
    for i in 0..<365 {
      h[AC + i] =
        iff(and(h[Y + i].isZero, h[W + i].isZero), Double.zero, (h[Y + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons)
        + iff(and(h[X + i].isZero, h[W + i].isZero), Double.zero, (h[X + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons)
        - iff(h[W + i].isZero, Double.zero, h[W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod)
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
      if h[AM + i].isZero {
        h[AD + i] = Double.zero
        h[AF + i] = Double.zero
        h[AH + i] = Double.zero
      } else {
        h[AD + i] = h[F + i]
        // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
        h[AF + i] = h[H + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
        // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
        h[AH + i] = h[J + i] + h[F + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
      }
      // W6
      h[AE + i] = h[W + i]
      // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
      h[AG + i] = h[X + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_CO2_nom_cons
      // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
      h[AI + i] = h[Y + i] + h[W + i] / (MethSynt_CO2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }
  }
  /// 11680-28470
  func d11(_ h: UnsafeMutableBufferPointer<Double>, case j: Int) {
    let days: [[Int]] = h[(CS + 1)..<CT].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }

    let (EY, EZ, FA, FB, FC, FD, FE, _, _, _, _, _, FK, FL, FM, _, _, _, _, _, FS, FT, FU, FV, FW, FX, FY, FZ, GA, GB, GC, GD, GE, GF, GG, GH, GI, _, GK, GL, _, GN, GO, _, GQ, GR, _) = (
      13140, 13505, 13870, 14235, 14600, 14965, 15330, 15695, 16060, 16425, 16790, 17155, 17520, 17885, 18250, 18615, 18980, 19345, 19710, 20075, 20440, 20805, 21170, 21535, 21900, 22265, 22630, 22995, 23360, 23725, 24090, 24455, 24820, 25185,
      25550, 25915, 26280, 26645, 27010, 27375, 27740, 28105, 28470, 28835, 29200, 29565, 29930
    )

    // SUMIFS(Calculation!CO5:CO8764,Calculation!CS$5:CS8764,"="&$A6,Calculation!CQ5:CQ8764,">0")
    h.sumOf(CO, days: days, at: EY, condition: CQ, predicate: notZero)

    // SUMIFS(Calculation!DU5:DU8764,Calculation!CS5:CS8764,"="&$A6,Calculation!DH5:DH8764,">0")
    h.sumOf(DU, days: days, at: EZ, condition: DH, predicate: notZero)
    /// Grid import for min/max harm and stby outside harm op
    // SUMIF(Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CO$5:$CO$8764)-EY6
    h.sum(days: days, range: CO, at: FA)
    for i in 0..<365 { h[FA + i] -= h[EY + i] }
    /// El cons considering min harm op during harm op period including grid import
    h.sum(days: days, range: CQ, at: FB)
    h.sumOf(CT, days: days, at: FC, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { h[FC + i] += h[FB + i] }
    /// El cons considering max harm op during harm op period including grid import
    h.sum(days: days, range: DH, at: FB)
    h.sumOf(CT, days: days, at: FD, condition: DH, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { h[FD + i] += h[FB + i]; h[FB + i] = 0 }
    /// El cons considering min/max harm op outside  harm op period including grid import (if any)
    let CC: Int = 639480
    h.sumOf(CT, days: days, at: FE, condition1: CQ, predicate1: { $0.isZero }, condition2: CC, predicate2: notZero)
    // FE=MAX(0,SUMIFS(Calculation!$CT$5:$CT$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0",Calculation!$CC$5:$CC$8764,">0")-A_overall_stup_cons)
    for i in 0..<365 { h[FE + i] = max(Double.zero, h[FE + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    // h.sum(days: days, range: CR, at: FB)
    // h.sumOf(CU, days: days, at: FF, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { h[FF + i] += h[FB + i]; h[FB + i] = 0 }
    /// Harm heat cons considering max harm op during harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    // h.sum(days: days, range: DI, at: FB)
    // h.sumOf(CU, days: days, at: FG, condition: DH, predicate: notZero)
    // for i in 0..<365 { h[FG + i] += h[FB + i]; h[FB + i] = 0 }
    /// Harm heat cons outside of harm op period
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // h.sumOf(CU, days: days, at: FH, condition: CQ, predicate: { $0.isZero })
    /// Electr demand not covered after min harm and stby during harm op period
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // h.sumOf(CX, days: days, at: FI, condition: CQ, predicate: notZero)
    /// Electr demand not covered after max harm and stby during harm op period
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    // h.sumOf(DL, days: days, at: FJ, condition: DH, predicate: notZero)
    /// Electr demand not covered after min/max harm and stby outside harm op period
    // =SUMIFS(Calculation!$CX$5:$CX$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0")
    h.sumOf(CX, days: days, at: FK, condition: CQ, predicate: { $0.isZero })
    /// El boiler op considering min harm op during harm op period
    // // FL=SUMIFS(Calculation!$TH$5:$TH$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,">0")
    h.sumOf(TH, days: days, at: FL, condition: CQ, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    // FM=SUMIFS(Calculation!$TI$5:$TI$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$DH$5:$DH$8764,">0")
    h.sumOf(TI, days: days, at: FM, condition: DH, predicate: notZero)
    /// El boiler op outside harm op period
    // FN=SUMIFS(Calculation!$TH$5:$TH$8764,Calculation!$CS$5:$CS$8764,"="&$A3,Calculation!$CQ$5:$CQ$8764,"=0")
    h.sumOf(TH, days: days, at: FL, condition: CQ, predicate: { $0.isZero })
    /// Total aux cons during harm op period
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // h.sumOfRanges(CM, days: days, at: FO, range1: hour, condition: CQ, predicate: notZero)
    /// Total aux cons outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    // h.sum(days: days, range: CM, at: FP)
    // for i in 0..<365 { h[FP + i] -= h[FO + i] }
    /// El cons not covered during harm op period
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // h.sumOfRanges(CN, days: days, at: FQ, range1: hour, condition: CQ, predicate: notZero)
    /// El cons not covered outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    // h.sum(days: days, range: CN, at: FR)
    // for i in 0..<365 { h[FR + i] -= h[FQ + i] }
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(CV, days: days, at: FS, condition: CQ, predicate: notZero)
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DJ, days: days, at: FT, condition: DH, predicate: notZero)
    /// Remaining PV el outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    h.sum(days: days, range: CV, at: FU)
    for i in 0..<365 { h[FU + i] -= h[FS + i] }
    /// Remaining CSP heat after min harm during harm op period
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(CW, days: days, at: FV, condition: CQ, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DK, days: days, at: FW, condition: DH, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    h.sum(days: days, range: CW, at: FX)
    for i in 0..<365 { h[FX + i] -= h[FV + i] }
    /// Max BESS night prep after min harm cons during harm op period
    h.sumOf(DE, days: days, at: FY, condition: CQ, predicate: notZero)
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { h[FY + i] = min(h[FY + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep after max harm cons during harm op period
    h.sumOf(DS, days: days, at: FZ, condition: DH, predicate: notZero)
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { h[FZ + i] = min(h[FZ + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep outside of harm op period
    // =MIN(SUMIFS(Calculation!$DE$5:$DE$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0"),BESS_cap_ud/BESS_chrg_eff)
    h.sumOf(DE, days: days, at: GA, condition: CQ, predicate: { $0.isZero })
    for i in 0..<365 { h[GA + i] = min(h[GA + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(DF, days: days, at: GB, condition: CQ, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DT, days: days, at: GC, condition: DH, predicate: notZero)
    /// Max grid export outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    h.sum(days: days, range: DF, at: GD)
    for i in 0..<365 { h[GD + i] -= h[GB + i] }
    /// Remaining grid import during harm op period after min harm
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(CY, days: days, at: GE, condition: CQ, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DM, days: days, at: GF, condition: DH, predicate: notZero)
    /// Remaining grid import outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    h.sum(days: days, range: CY, at: GG)
    for i in 0..<365 { h[GG + i] -= h[GE + i] }
    /// Remaining El boiler cap during harm op period after min harm
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(DA, days: days, at: GH, condition: CQ, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DO, days: days, at: GI, condition: DH, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    //  h.sum(days: days, range: DA, at: GJ)
    // for i in 0..<365 { h[GJ + i] -= h[GH + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(DB, days: days, at: GK, condition: CQ, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DP, days: days, at: GL, condition: DH, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    // h.sum(days: days, range: DB, at: GM)
    // for i in 0..<365 { h[GM + i] -= h[GK + i] }
    /// Remaining CCU cap during harm op after min harm
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(DC, days: days, at: GN, condition: CQ, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DQ, days: days, at: GO, condition: DH, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    // h.sum(days: days, range: DC, at: GP)
    // for i in 0..<365 { h[GP + i] -= h[GN + i] }
    /// Remaining EY cap during harm op after min harm
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    h.sumOf(DD, days: days, at: GQ, condition: CQ, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    h.sumOf(DR, days: days, at: GR, condition: DH, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    // h.sum(days: days, range: DD, at: GS)
    // for i in 0..<365 { h[GS + i] -= h[GQ + i] }
  }

  func d12(_ h: UnsafeMutableBufferPointer<Double>, case j: Int) {
    let daysEZ: [[Int]] = h[(EZ + 1)..<FA].indices.chunked(by: { h[$0] == h[$1] }).map { $0.map { $0 - EZ } }
    let notZero: (Double) -> Bool = { $0 > Double.zero }
    let (GU, GV, GW, GX, GY, GZ, HA, HB, HC, HD, HE, HF, HG, HH, HI, HJ, HK, HL, HM, HN, HO, HP, HQ, HR, HS, HT, HU, HV, HW, HX, HY, HZ, IA, IB, IC, ID, IE, IF, IG, IH, II, IJ, IK, IL, IM, IN, IO) = (
      30660, 31025, 31390, 31755, 32120, 32485, 32850, 33215, 33580, 33945, 34310, 34675, 35040, 35405, 35770, 36135, 36500, 36865, 37230, 37595, 37960, 38325, 38690, 39055, 39420, 39785, 40150, 40515, 40880, 41245, 41610, 41975, 42340, 42705,
      43070, 43435, 43800, 44165, 44530, 44895, 45260, 45625, 45990, 46355, 46720, 47085, 47450
    )

    /// Available elec after TES chrg during harm op period
    // SUMIFS(Calculation!$TB$5:$TB$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    h.sumOf(TB, days: daysEZ, at: GU, condition: EX, predicate: notZero)
    // SUMIFS(Calculation!$TC$5:$TC$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    h.sumOf(TC, days: daysEZ, at: GV, condition: FO, predicate: notZero)
    /// Available heat after TES chrg during harm op period
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$TB$5:$TB$8764)-GU6
    h.sum(days: daysEZ, range: TB, at: GW)
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    // for i in 0..<365 { h[GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }
    /// Harm el cons considering min harm op during harm op period
    h.sumOf(FA, days: daysEZ, at: GY, condition: EX, predicate: notZero)
    // SUMIF(Calculation!EZ$5:EZ8764,"="A6,Calculation!$EX$5:$EX$8764)+SUMIFS(Calculation!FA5:FA8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    h.sum(days: daysEZ, range: EX, at: GY)
    /// Harm el cons considering max harm op during harm op period
    h.sum(days: daysEZ, range: FO, at: GX)
    h.sumOf(FA, days: daysEZ, at: GZ, condition: FO, predicate: notZero)
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764)+SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    for i in 0..<365 { h[GZ + i] += h[GX + i] }
    /// Harm el cons outside of harm op period
    let EJ: Int = 122640
    h.sumOf(FA, days: daysEZ, at: HA, condition1: EX, predicate1: { $0.isZero }, condition2: EJ, predicate2: notZero)
    // HA=MAX(0,SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"=0",Calculation!$EJ$5:$EJ$8764,">0")-A_overall_stup_cons)
    for i in 0..<365 { h[HA + i] = max(Double.zero, h[HA + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    h.sum(days: daysEZ, range: EY, at: GX)
    h.sumOf(FB, days: daysEZ, at: HB, condition: EX, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { h[HB + i] += h[GX + i] }
    /// Harm heat cons considering max harm op during harm op period
    h.sum(days: daysEZ, range: FP, at: GX)
    h.sumOf(FB, days: daysEZ, at: HC, condition: FO, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { h[HC + i] += h[GX + i] }
    /// Harm heat cons outside of harm op period
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    h.sumOf(FB, days: daysEZ, at: HD, condition: EX, predicate: { $0.isZero })
    /// Grid import considering min harm op during harm op period
    // SUMIFS(Calculation!$FE$5:$FE$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    h.sumOf(FE, days: daysEZ, at: HE, condition: EX, predicate: notZero)
    /// Grid import considering max harm op during harm op period
    // SUMIFS(Calculation!$FS$5:$FS$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    h.sumOf(FS, days: daysEZ, at: HF, condition: FO, predicate: notZero)
    /// Grid import  outside of harm op period
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FE$5:$FE$8764)-HE6
    h.sum(days: daysEZ, range: FE, at: HG)
    for i in 0..<365 { h[HG + i] -= h[HE + i] }
    /// El boiler op considering min harm op during harm op period
    // HH=SUMIFS(Calculation!$TJ$5:$TJ$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,">0")
    h.sumOf(TJ, days: daysEZ, at: HH, condition: EX, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    // HI=SUMIFS(Calculation!$TK$5:$TK$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$FO$5:$FO$8764,">0")
    h.sumOf(TK, days: daysEZ, at: HI, condition: FO, predicate: notZero)
    /// El boiler op outside harm op period
    // HJ=SUMIFS(Calculation!$TJ$5:$TJ$8764,Calculation!$EZ$5:$EZ$8764,"="&$A3,Calculation!$EX$5:$EX$8764,"=0")
    h.sumOf(TJ, days: daysEZ, at: HJ, condition: EX, predicate: { $0.isZero })
    /// Total aux cons during harm op period
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(ET, days: daysEZ, at: HK, condition: EX, predicate: notZero)
    /// Total aux cons outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    h.sum(days: daysEZ, range: ET, at: HL)
    for i in 0..<365 { h[HL + i] -= h[HK + i] }
    /// El cons not covered during harm op period
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(EU, days: daysEZ, at: HM, condition: EX, predicate: notZero)
    /// El cons not covered outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    h.sum(days: daysEZ, range: EU, at: HN)
    for i in 0..<365 { h[HN + i] -= h[HM + i] }
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FC, days: daysEZ, at: HO, condition: EX, predicate: notZero)
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FQ, days: daysEZ, at: HP, condition: FO, predicate: notZero)
    /// Remaining PV el outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    h.sum(days: daysEZ, range: FC, at: HQ)
    for i in 0..<365 { h[HQ + i] -= h[HO + i] }
    /// Remaining CSP heat after min harm during harm op period
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FD, days: daysEZ, at: HR, condition: EX, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FR, days: daysEZ, at: HS, condition: FO, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    h.sum(days: daysEZ, range: FD, at: HT)
    for i in 0..<365 { h[HT + i] -= h[HR + i] }
    /// Max elec to BESS for night prep after min harm op during harm op period
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    h.sumOf(FL, days: daysEZ, at: HU, condition: EX, predicate: notZero)
    for i in 0..<365 { h[HU + i] = min(h[HU + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep after max harm op during harm op period
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    h.sumOf(FZ, days: daysEZ, at: HV, condition: FO, predicate: notZero)
    for i in 0..<365 { h[HV + i] = min(h[HV + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep outside of harm op period
    h.sumOf(FL, days: daysEZ, at: HW, condition: EX, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { h[HW + i] = min(h[HW + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FM, days: daysEZ, at: HX, condition: EX, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(GA, days: daysEZ, at: HY, condition: FO, predicate: notZero)
    /// Max grid export outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    h.sum(days: daysEZ, range: FM, at: HZ)
    for i in 0..<365 { h[HZ + i] -= h[HX + i] }
    /// Remaining grid import during harm op period after min harm
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FF, days: daysEZ, at: IA, condition: EX, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FT, days: daysEZ, at: IB, condition: FO, predicate: notZero)
    /// Remaining grid import outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    h.sum(days: daysEZ, range: FF, at: IC)
    for i in 0..<365 { h[IC + i] -= h[IA + i] }
    /// Remaining El boiler cap during harm op period after min harm
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FH, days: daysEZ, at: ID, condition: EX, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FV, days: daysEZ, at: IE, condition: FO, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    h.sum(days: daysEZ, range: FH, at: IF)
    for i in 0..<365 { h[IF + i] -= h[ID + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FI, days: daysEZ, at: IG, condition: EX, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FW, days: daysEZ, at: IH, condition: FO, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    h.sum(days: daysEZ, range: FI, at: II)
    for i in 0..<365 { h[II + i] -= h[IG + i] }
    /// Remaining CCU cap during harm op after min harm
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FJ, days: daysEZ, at: IJ, condition: EX, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FX, days: daysEZ, at: IK, condition: FO, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    h.sum(days: daysEZ, range: FJ, at: IL)
    for i in 0..<365 { h[IL + i] -= h[IJ + i] }
    /// Remaining EY cap during harm op after min harm
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    h.sumOf(FK, days: daysEZ, at: IM, condition: EX, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    h.sumOf(FY, days: daysEZ, at: IN, condition: FO, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    h.sum(days: daysEZ, range: FK, at: IO)
    for i in 0..<365 { h[IO + i] -= h[IM + i] }
  }
}
