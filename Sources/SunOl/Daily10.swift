extension TunOl {
  /// 0-5110
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
  // 5840-11315
  func night(_ d10: inout [Double], hour4: [Double], case j: Int) {
    let (F, H, J, L, N, P, EH, EX) = (1095, 1825, 2555, 3285, 4015, 4745, 105120, 245280)
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let days: [[Int]] = hour4[262801..<(262800 + 8760)].indices.chunked(by: { hour4[$0] == hour4[$1] }).map { $0.map { $0 - 262800 } }
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
  /// 11680-28470
  func d11(_ d11: inout [Double], hour: [Double], case j: Int) {
    let (CM, CN, CQ, CR, CS) = (727080, 735840, 762120, 770880, 779640)
    let (CT, CU, CV, CW, CX) = (788400, 797160, 805920, 814680, 823440)
    let (CY, CZ, DA, DB, DC) = (832200, 840960, 849720, 858480, 867240)
    let (DD, DE, DF, DH, DI) = (876000, 884760, 893520, 911040, 919800)
    let (DJ, DK, DL, DM, DN) = (928560, 937320, 946080, 954840, 963600)
    let (DO, DP, DQ, DR, DS, DT) = (972360, 981120, 989880, 998640, 1_007_400, 1_016_160)
    let days: [[Int]] = hour[(CS + 1)..<(CS + 8760)].indices.chunked(by: { hour[$0] == hour[$1] }).map { $0.map { $0 - CS } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    /// Grid import for min harm and stby during  harm op
    let EY: Int = 11680
    /// Grid import for max harm and stby during  harm opC
    let CO: Int = 271560
    // SUMIFS(Calculation!CO5:CO8764,Calculation!CS$5:CS8764,"="&$A6,Calculation!CQ5:CQ8764,">0")
    hour.sumOf(CO, days: days, into: &d11, at: EY, condition: CQ, predicate: notZero)
    let EZ: Int = 12045
    let DU: Int = 280320
    // SUMIFS(Calculation!DU5:DU8764,Calculation!CS5:CS8764,"="&$A6,Calculation!DH5:DH8764,">0")
    hour.sumOf(DU, days: days, into: &d11, at: EZ, condition: DH, predicate: notZero)
    /// Grid import for min/max harm and stby outside harm op
    let FA: Int = 12410
    let FB: Int = 12775
    // SUMIF(Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CO$5:$CO$8764)-EY6
    hour.sum(days: days, range: CO, into: &d11, at: FA)
    for i in 0..<365 { d11[FA + i] -= d11[EY + i] }
    /// El cons considering min harm op during harm op period including grid import
    let FC: Int = 13140
    hour.sum(days: days, range: CQ, into: &d11, at: FB)
    hour.sumOf(CT, days: days, into: &d11, at: FC, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FC + i] += d11[FB + i] }
    /// El cons considering max harm op during harm op period including grid import
    let FD: Int = 13505
    hour.sum(days: days, range: DH, into: &d11, at: FB)
    hour.sumOf(CT, days: days, into: &d11, at: FD, condition: DH, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { d11[FD + i] += d11[FB + i] }
    /// El cons considering min/max harm op outside  harm op period including grid import (if any)
    let FE: Int = 13870
    hour.sumOf(CT, days: days, into: &d11, at: FE, condition: CQ, predicate: { $0.isZero })
    // =MAX(0,SUMIFS(Calculation!$CT$5:$CT$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d11[FE + i] = max(0, d11[FE + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    let FF: Int = 14235
    hour.sum(days: days, range: CR, into: &d11, at: FB)
    hour.sumOf(CU, days: days, into: &d11, at: FF, condition: CQ, predicate: notZero)
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { d11[FF + i] += d11[FB + i] }
    /// Harm heat cons considering max harm op during harm op period
    let FG: Int = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sum(days: days, range: DI, into: &d11, at: FB)
    hour.sumOf(CU, days: days, into: &d11, at: FG, condition: DH, predicate: notZero)
    for i in 0..<365 { d11[FG + i] += d11[FB + i] }
    /// Harm heat cons outside of harm op period
    let FH: Int = 14965
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    hour.sumOf(CU, days: days, into: &d11, at: FH, condition: CQ, predicate: { $0.isZero })
    /// Electr demand not covered after min harm and stby during harm op period
    let FI: Int = 15330
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CX, days: days, into: &d11, at: FI, condition: CQ, predicate: notZero)
    /// Electr demand not covered after max harm and stby during harm op period
    let FJ: Int = 15695
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DL, days: days, into: &d11, at: FJ, condition: DH, predicate: notZero)
    /// Electr demand not covered after min/max harm and stby outside harm op period
    let FK: Int = 16060
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    hour.sum(days: days, range: CX, into: &d11, at: FK)
    for i in 0..<365 { d11[FK + i] -= d11[FI + i] }
    /// El boiler op considering min harm op during harm op period
    let FL: Int = 16425
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CZ, days: days, into: &d11, at: FL, condition: CQ, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    let FM: Int = 16790
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DN, days: days, into: &d11, at: FM, condition: DH, predicate: notZero)
    /// El boiler op outside harm op period
    let FN: Int = 17155
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    hour.sum(days: days, range: CZ, into: &d11, at: FN)
    for i in 0..<365 { d11[FN + i] -= d11[FL + i] }
    /// Total aux cons during harm op period
    let FO: Int = 17520
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOfRanges(CM, days: days, into: &d11, at: FO, range1: hour, condition: CQ, predicate: notZero)
    /// Total aux cons outside of harm op period
    let FP: Int = 17885
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    hour.sum(days: days, range: CM, into: &d11, at: FP)
    for i in 0..<365 { d11[FP + i] -= d11[FO + i] }
    /// El cons not covered during harm op period
    let FQ: Int = 18250
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOfRanges(CN, days: days, into: &d11, at: FQ, range1: hour, condition: CQ, predicate: notZero)
    /// El cons not covered outside of harm op period
    let FR: Int = 18615
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    hour.sum(days: days, range: CN, into: &d11, at: FR)
    for i in 0..<365 { d11[FR + i] -= d11[FQ + i] }
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let FS: Int = 18980
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CV, days: days, into: &d11, at: FS, condition: CQ, predicate: notZero)
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let FT: Int = 19345
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DJ, days: days, into: &d11, at: FT, condition: DH, predicate: notZero)
    /// Remaining PV el outside of harm op period
    let FU: Int = 19710
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    hour.sum(days: days, range: CV, into: &d11, at: FU)
    for i in 0..<365 { d11[FU + i] -= d11[FS + i] }
    /// Remaining CSP heat after min harm during harm op period
    let FV: Int = 20075
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CW, days: days, into: &d11, at: FV, condition: CQ, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    let FW: Int = 20440
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DK, days: days, into: &d11, at: FW, condition: DH, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    let FX: Int = 20805
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    hour.sum(days: days, range: CW, into: &d11, at: FX)
    for i in 0..<365 { d11[FX + i] -= d11[FV + i] }
    /// Max BESS night prep after min harm cons during harm op period
    let FY: Int = 21170
    hour.sumOf(DE, days: days, into: &d11, at: FY, condition: CQ, predicate: notZero)
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FY + i] = min(d11[FY + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep after max harm cons during harm op period
    let FZ: Int = 21535
    hour.sumOf(DS, days: days, into: &d11, at: FZ, condition: DH, predicate: notZero)
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d11[FZ + i] = min(d11[FZ + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max BESS night prep outside of harm op period
    let GA: Int = 21900
    // =MIN(SUMIFS(Calculation!$DE$5:$DE$8764,Calculation!$CS$5:$CS$8764,"="&$A6,Calculation!$CQ$5:$CQ$8764,"=0"),BESS_cap_ud/BESS_chrg_eff)
    hour.sumOf(DE, days: days, into: &d11, at: GA, condition: CQ, predicate: { $0.isZero })
    for i in 0..<365 { d11[GA + i] = min(d11[GA + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    let GB: Int = 22265
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DF, days: days, into: &d11, at: GB, condition: CQ, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    let GC: Int = 22630
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DT, days: days, into: &d11, at: GC, condition: DH, predicate: notZero)
    /// Max grid export outside of harm op period
    let GD: Int = 22995
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    hour.sum(days: days, range: DF, into: &d11, at: GD)
    for i in 0..<365 { d11[GD + i] -= d11[GB + i] }
    /// Remaining grid import during harm op period after min harm
    let GE: Int = 23360
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(CY, days: days, into: &d11, at: GE, condition: CQ, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    let GF: Int = 23725
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DM, days: days, into: &d11, at: GF, condition: DH, predicate: notZero)
    /// Remaining grid import outside of harm op period
    let GG: Int = 24090
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    hour.sum(days: days, range: CY, into: &d11, at: GG)
    for i in 0..<365 { d11[GG + i] -= d11[GE + i] }
    /// Remaining El boiler cap during harm op period after min harm
    let GH: Int = 24455
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DA, days: days, into: &d11, at: GH, condition: CQ, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    let GI: Int = 24820
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DO, days: days, into: &d11, at: GI, condition: DH, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    let GJ: Int = 25185
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    hour.sum(days: days, range: DA, into: &d11, at: GJ)
    for i in 0..<365 { d11[GJ + i] -= d11[GH + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    let GK: Int = 25550
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DB, days: days, into: &d11, at: GK, condition: CQ, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    let GL: Int = 25915
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DP, days: days, into: &d11, at: GL, condition: DH, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    let GM: Int = 26280
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    hour.sum(days: days, range: DB, into: &d11, at: GM)
    for i in 0..<365 { d11[GM + i] -= d11[GK + i] }
    /// Remaining CCU cap during harm op after min harm
    let GN: Int = 26645
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DC, days: days, into: &d11, at: GN, condition: CQ, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    let GO: Int = 27010
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DQ, days: days, into: &d11, at: GO, condition: DH, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    let GP: Int = 27375
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    hour.sum(days: days, range: DC, into: &d11, at: GP)
    for i in 0..<365 { d11[GP + i] -= d11[GN + i] }
    /// Remaining EY cap during harm op after min harm
    let GQ: Int = 27740
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    hour.sumOf(DD, days: days, into: &d11, at: GQ, condition: CQ, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    let GR: Int = 28105
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    hour.sumOf(DR, days: days, into: &d11, at: GR, condition: DH, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    let GS: Int = 28470
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    hour.sum(days: days, range: DD, into: &d11, at: GS)
    for i in 0..<365 { d11[GS + i] -= d11[GQ + i] }
  }

  func d12(_ d12: inout [Double], hourFinal: [Double] , case j: Int) {
    let daysEZ: [[Int]] = hourFinal[262801..<(262800 + 8760)].indices.chunked(by: { hourFinal[$0] == hourFinal[$1] }).map { $0.map { $0 - 262800 } }
    let notZero: (Double) -> Bool = { $0 > 0.0 }
    let (ET, EU, EX, EY, FA) = (210240, 219000, 245280, 254040, 271560)
    let (FB, FC, FD, FE, FF) = (280320, 289080, 297840, 306600, 315360)
    let (FG, FH, FI, FJ, FK) = (324120, 332880, 341640, 350400, 359160)
    let (FL, FM, FO, FP, FQ) = (367920, 376680, 394200, 402960, 411720)
    let (FR, FS, FT, FU, FV) = (420480, 429240, 438000, 446760, 455520)
    let (FW, FX, FY, FZ, GA) = (464280, 473040, 481800, 490560, 499320)
    let GU: Int = 28835
    /// Available elec after TES chrg outside harm op period
    let GV: Int = 29200
    let TB: Int = 508080
    /// Available elec after TES chrg during harm op period
    // SUMIFS(Calculation!$TB$5:$TB$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(TB, days: daysEZ, into: &d12, at: GU, condition: EX, predicate: notZero)
    let TC: Int = 499320
    // SUMIFS(Calculation!$TC$5:$TC$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(TC, days: daysEZ, into: &d12, at: GV, condition: FO, predicate: notZero)
    /// Available heat after TES chrg during harm op period
    let GW: Int = 29565
    let GX: Int = 29930
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$TB$5:$TB$8764)-GU6
    hourFinal.sum(days: daysEZ, range: TB, into: &d12, at: GW)
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    // for i in 0..<365 { d12[GX + i] = EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i] }
    /// Harm el cons considering min harm op during harm op period
    let GY: Int = 30295
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GY, condition: EX, predicate: notZero)
    // SUMIF(Calculation!EZ$5:EZ8764,"="A6,Calculation!$EX$5:$EX$8764)+SUMIFS(Calculation!FA5:FA8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sum(days: daysEZ, range: EX, into: &d12, at: GY)
    /// Harm el cons considering max harm op during harm op period
    let GZ: Int = 30660
    hourFinal.sum(days: daysEZ, range: FO, into: &d12, at: GX)
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: GZ, condition: FO, predicate: notZero)
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764)+SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    for i in 0..<365 { d12[GZ + i] += d12[GX + i] }
    /// Harm el cons outside of harm op period
    let HA: Int = 31025
    hourFinal.sumOf(FA, days: daysEZ, into: &d12, at: HA, condition: EX, predicate: { $0.isZero })
    // MAX(0,SUMIFS(Calculation!$FA$5:$FA$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,"=0")-A_overall_stup_cons)
    for i in 0..<365 { d12[HA + i] = max(0, d12[HA + i] - overall_stup_cons[j]) }
    /// Harm heat cons considering min harm op during harm op period
    let HB: Int = 31390
    hourFinal.sum(days: daysEZ, range: EY, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HB, condition: EX, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { d12[HB + i] += d12[GX + i] }
    /// Harm heat cons considering max harm op during harm op period
    let HC: Int = 31755
    hourFinal.sum(days: daysEZ, range: FP, into: &d12, at: GX)
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HC, condition: FO, predicate: notZero)
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { d12[HC + i] += d12[GX + i] }
    /// Harm heat cons outside of harm op period
    let HD: Int = 32120
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    hourFinal.sumOf(FB, days: daysEZ, into: &d12, at: HD, condition: EX, predicate: { $0.isZero })
    /// Grid import considering min harm op during harm op period
    let HE: Int = 32485
    // SUMIFS(Calculation!$FE$5:$FE$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$EX$5:$EX$8764,">0")
    hourFinal.sumOf(FE, days: daysEZ, into: &d12, at: HE, condition: EX, predicate: notZero)
    /// Grid import considering max harm op during harm op period
    let HF: Int = 32850
    // SUMIFS(Calculation!$FS$5:$FS$8764,Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FO$5:$FO$8764,">0")
    hourFinal.sumOf(FS, days: daysEZ, into: &d12, at: HF, condition: FO, predicate: notZero)
    /// Grid import  outside of harm op period
    let HG: Int = 33215
    // SUMIF(Calculation!$EZ$5:$EZ$8764,"="A6,Calculation!$FE$5:$FE$8764)-HE6
    hourFinal.sum(days: daysEZ, range: FE, into: &d12, at: HG)
    for i in 0..<365 { d12[HG + i] -= d12[HE + i] }
    /// El boiler op considering min harm op during harm op period
    let HH: Int = 33580
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FG, days: daysEZ, into: &d12, at: HH, condition: EX, predicate: notZero)
    /// El boiler op considering max harm op during harm op period
    let HI: Int = 33945
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FU, days: daysEZ, into: &d12, at: HI, condition: FO, predicate: notZero)
    /// El boiler op outside harm op period
    let HJ: Int = 34310
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    hourFinal.sum(days: daysEZ, range: FG, into: &d12, at: HJ)
    for i in 0..<365 { d12[HJ + i] -= d12[HH + i] }
    /// Total aux cons during harm op period
    let HK: Int = 34675
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(ET, days: daysEZ, into: &d12, at: HK, condition: EX, predicate: notZero)
    /// Total aux cons outside of harm op period
    let HL: Int = 35040
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    hourFinal.sum(days: daysEZ, range: ET, into: &d12, at: HL)
    for i in 0..<365 { d12[HL + i] -= d12[HK + i] }
    /// El cons not covered during harm op period
    let HM: Int = 35405
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(EU, days: daysEZ, into: &d12, at: HM, condition: EX, predicate: notZero)
    /// El cons not covered outside of harm op period
    let HN: Int = 35770
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    hourFinal.sum(days: daysEZ, range: EU, into: &d12, at: HN)
    for i in 0..<365 { d12[HN + i] -= d12[HM + i] }
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let HO: Int = 36135
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FC, days: daysEZ, into: &d12, at: HO, condition: EX, predicate: notZero)
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let HP: Int = 36500
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FQ, days: daysEZ, into: &d12, at: HP, condition: FO, predicate: notZero)
    /// Remaining PV el outside of harm op period
    let HQ: Int = 36865
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    hourFinal.sum(days: daysEZ, range: FC, into: &d12, at: HQ)
    for i in 0..<365 { d12[HQ + i] -= d12[HO + i] }
    /// Remaining CSP heat after min harm during harm op period
    let HR: Int = 37230
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FD, days: daysEZ, into: &d12, at: HR, condition: EX, predicate: notZero)
    /// Remaining CSP heat after max harm op during harm op period
    let HS: Int = 37595
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FR, days: daysEZ, into: &d12, at: HS, condition: FO, predicate: notZero)
    /// Remaining CSP heat outside of harm op period
    let HT: Int = 37960
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    hourFinal.sum(days: daysEZ, range: FD, into: &d12, at: HT)
    for i in 0..<365 { d12[HT + i] -= d12[HR + i] }
    /// Max elec to BESS for night prep after min harm op during harm op period
    let HU: Int = 38325
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HU, condition: EX, predicate: notZero)
    for i in 0..<365 { d12[HU + i] = min(d12[HU + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep after max harm op during harm op period
    let HV: Int = 38690
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    hourFinal.sumOf(FZ, days: daysEZ, into: &d12, at: HV, condition: FO, predicate: notZero)
    for i in 0..<365 { d12[HV + i] = min(d12[HV + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max elec to BESS for night prep outside of harm op period
    let HW: Int = 39055
    hourFinal.sumOf(FL, days: daysEZ, into: &d12, at: HW, condition: EX, predicate: { $0.isZero })
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { d12[HW + i] = min(d12[HW + i], BESS_cap_ud / BESS_chrg_eff) }
    /// Max grid export after min harm cons during harm op period
    let HX: Int = 39420
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FM, days: daysEZ, into: &d12, at: HX, condition: EX, predicate: notZero)
    /// Max grid export after max harm cons during harm op period
    let HY: Int = 39785
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(GA, days: daysEZ, into: &d12, at: HY, condition: FO, predicate: notZero)
    /// Max grid export outside of harm op period
    let HZ: Int = 40150
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    hourFinal.sum(days: daysEZ, range: FM, into: &d12, at: HZ)
    for i in 0..<365 { d12[HZ + i] -= d12[HX + i] }
    /// Remaining grid import during harm op period after min harm
    let IA: Int = 40515
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FF, days: daysEZ, into: &d12, at: IA, condition: EX, predicate: notZero)
    /// Remaining grid import during harm op period after max harm
    let IB: Int = 40880
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FT, days: daysEZ, into: &d12, at: IB, condition: FO, predicate: notZero)
    /// Remaining grid import outside of harm op period
    let IC: Int = 41245
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    hourFinal.sum(days: daysEZ, range: FF, into: &d12, at: IC)
    for i in 0..<365 { d12[IC + i] -= d12[IA + i] }
    /// Remaining El boiler cap during harm op period after min harm
    let ID: Int = 41610
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FH, days: daysEZ, into: &d12, at: ID, condition: EX, predicate: notZero)
    /// Remaining El boiler cap during harm op period after max harm
    let IE: Int = 41975
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FV, days: daysEZ, into: &d12, at: IE, condition: FO, predicate: notZero)
    /// Remaining El boiler cap outside of harm op period
    let IF: Int = 42340
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    hourFinal.sum(days: daysEZ, range: FH, into: &d12, at: IF)
    for i in 0..<365 { d12[IF + i] -= d12[ID + i] }
    /// Remaining MethSynt cap during harm op after min harm op
    let IG: Int = 42705
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FI, days: daysEZ, into: &d12, at: IG, condition: EX, predicate: notZero)
    /// Remaining MethSynt cap during harm op period after max harm op
    let IH: Int = 43070
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FW, days: daysEZ, into: &d12, at: IH, condition: FO, predicate: notZero)
    /// Remaining MethSynt cap outside of harm op period
    let II: Int = 43435
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    hourFinal.sum(days: daysEZ, range: FI, into: &d12, at: II)
    for i in 0..<365 { d12[II + i] -= d12[IG + i] }
    /// Remaining CCU cap during harm op after min harm
    let IJ: Int = 43800
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FJ, days: daysEZ, into: &d12, at: IJ, condition: EX, predicate: notZero)
    /// Remaining CCU cap during harm op after max harm
    let IK: Int = 44165
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FX, days: daysEZ, into: &d12, at: IK, condition: FO, predicate: notZero)
    /// Remaining CCU cap outside of harm op after min harm
    let IL: Int = 44530
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    hourFinal.sum(days: daysEZ, range: FJ, into: &d12, at: IL)
    for i in 0..<365 { d12[IL + i] -= d12[IJ + i] }
    /// Remaining EY cap during harm op after min harm
    let IM: Int = 44895
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    hourFinal.sumOf(FK, days: daysEZ, into: &d12, at: IM, condition: EX, predicate: notZero)
    /// Remaining EY cap during harm op period after max harm
    let IN: Int = 45260
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    hourFinal.sumOf(FY, days: daysEZ, into: &d12, at: IN, condition: FO, predicate: notZero)
    /// Remaining EY cap outside of harm op period
    let IO: Int = 45625
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    hourFinal.sum(days: daysEZ, range: FK, into: &d12, at: IO)
    for i in 0..<365 { d12[IO + i] -= d12[IM + i] }
  }
}
