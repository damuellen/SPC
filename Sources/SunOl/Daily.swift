struct Production {

  let storage_cap = (RawMeth: 300.0, CO2: 275.0, H2: 50.0)

  let overall_var_min_cons: SIMD4<Double> = [0.9, 0, 0, 0]  // A_EY_Min_perc*(EY_var_net_nom_cons+EY_var_aux_nom_cons)+A_MethSynt_Min_perc*MethSynt_var_aux_nom_cons+A_MethDist_Min_perc*MethDist_var_aux_nom_cons+A_CCU_Min_perc*CCU_var_aux_nom_cons
  let overall_var_max_cons: SIMD4<Double> = [1.8, 0, 0, 0]  // =L57*(EY_var_net_nom_cons+EY_var_aux_nom_cons)+L55*MethSynt_var_aux_nom_cons+L54*MethDist_var_aux_nom_cons+L56*CCU_var_aux_nom_cons
  let overall_var_heat_min_cons: SIMD4<Double> = [14.0, 0, 0, 0]
  let overall_var_heat_max_cons: SIMD4<Double> = [28.0, 0, 0, 0]
  let RawMeth_min_cons: SIMD4<Double> = [15.6, 0, 0, 0]
  let RawMeth_max_cons: SIMD4<Double> = [31.3, 0, 0, 0]
  let CO2_min_cons: SIMD4<Double> = [0.0, 0, 0, 0]
  let CO2_max_cons: SIMD4<Double> = [0.0, 0, 0, 0]
  let H2_min_cons: SIMD4<Double> = [0.0, 0, 0, 0]
  let H2_max_cons: SIMD4<Double> = [0.0, 0, 0, 0]
  let equiv_harmonious_max_perc: SIMD4<Double> = [1.0, 0, 0, 0]
  let equiv_harmonious_min_perc: SIMD4<Double> = [0.5, 0, 0, 0]

  let MethSynt_CO2_nom_cons = SIMD4<Double>(repeating: 44.0)
  let MethSynt_H2_nom_cons = SIMD4<Double>(repeating: 6.0)
  let EY_H2_nom_prod = SIMD4<Double>(repeating: 5.64)
  let EY_var_gross_nom_cons = SIMD4<Double>(repeating: 3.147)
  let EY_var_heat_nom_cons = SIMD4<Double>(repeating: 69)
  let EY_fix_aux_elec = SIMD4<Double>(repeating: 0)
  let CCU_CO2_nom_prod = SIMD4<Double>(repeating: 30)
  let CCU_var_aux_nom_cons = SIMD4<Double>(repeating: 2.7)
  let CCU_var_heat_nom_cons = SIMD4<Double>(repeating: 2.7)  //
  let CCU_fix_aux_cons = SIMD4<Double>(repeating: 0)
  let MethSynt_RawMeth_nom_prod = SIMD4<Double>(repeating: 50)
  let MethSynt_var_aux_nom_cons = SIMD4<Double>(repeating: 2.2)
  let MethSynt_fix_aux_cons = SIMD4<Double>(repeating: 0)
  let MethSynt_var_heat_nom_prod = SIMD4<Double>(repeating: 0)

  func dailyCalc() -> [SIMD4<Double>] {
    let result = (11...18)
      .map { r -> SIMD4<Double> in let h = SIMD4<Double>(repeating: Double(r))
        let RawMeth_min = RawMeth_min_cons * h  // K 4
        let RawMeth_max = RawMeth_max_cons * h  // L 5
        let CO2_min = CO2_min_cons * h  // M 6
        let CO2_max = CO2_max_cons * h  // N 7
        let H2_min = H2_min_cons * h  // O 8
        let H2_max = H2_max_cons * h
        let x0 = (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons
        let x1 = EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec
        let x2 = CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons
        let x3 = MethSynt_RawMeth_nom_prod * MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons
        let x4 = EY_H2_nom_prod * EY_var_heat_nom_cons
        let x5 = MethSynt_RawMeth_nom_prod * MethSynt_var_heat_nom_prod
        let x6 = CCU_CO2_nom_prod * CCU_var_heat_nom_cons

        var minElConsDuringDayForPrepOfNight = (H2_min + RawMeth_min / x0) / x1
        minElConsDuringDayForPrepOfNight += (CO2_min + RawMeth_min / x0) / x2
        minElConsDuringDayForPrepOfNight += RawMeth_min / x3

        var maxElConsDuringDayForPrepOfNight = (H2_max + RawMeth_max / x0) / x1
        maxElConsDuringDayForPrepOfNight += (CO2_max + RawMeth_max / x0) / x2
        maxElConsDuringDayForPrepOfNight += RawMeth_max / x3

        var minHeatConsDuringDayForPrepOfNight = (H2_min + RawMeth_min / x0) / x4
        let a1 = CO2_min + RawMeth_min / x0
        let b1 = x6 - RawMeth_min / x5
        minHeatConsDuringDayForPrepOfNight += a1 / b1

        var maxHeatConsDuringDayForPrepOfNight = (H2_max + RawMeth_max / x0) / x4
        let a2 = CO2_max + RawMeth_max / x0
        let b2 = x6 - RawMeth_max / x5
        maxHeatConsDuringDayForPrepOfNight += a2 / b2

        let RawMeth_cap = SIMD4<Double>(repeating: storage_cap.RawMeth)
        let CO2_cap = SIMD4<Double>(repeating: storage_cap.CO2)
        let H2_cap = SIMD4<Double>(repeating: storage_cap.H2)

        let one = SIMD4<Double>(repeating: 1.0)
        let perc: [SIMD4<Double>] = [one - RawMeth_min / RawMeth_cap, one - RawMeth_max / RawMeth_cap, one - CO2_min / CO2_cap, one - CO2_max / CO2_cap, one - H2_min / H2_cap, one - H2_max / H2_cap]

        var RawMeth = one / (perc[0] - perc[1]) * perc[0]
        var CO2 = one / (perc[2] - perc[3]) * perc[2]
        var H2 = one / (perc[4] - perc[5]) * perc[4]

        let bounds = SIMD4<Double>(repeating: 0)
        RawMeth.replace(with: 0, where: perc[0] .<= bounds)
        RawMeth.replace(with: 1, where: perc[1] .>= bounds)
        CO2.replace(with: 0, where: perc[2] .<= bounds)
        CO2.replace(with: 1, where: perc[3] .>= bounds)
        H2.replace(with: 0, where: perc[4] .<= bounds)
        H2.replace(with: 1, where: perc[5] .>= bounds)

        var result: SIMD4<Double> = [min(RawMeth[0], CO2[0], H2[0]), min(RawMeth[1], CO2[1], H2[1]), min(RawMeth[2], CO2[2], H2[2]), min(RawMeth[3], CO2[3], H2[3])]

        result *= equiv_harmonious_max_perc - equiv_harmonious_min_perc
        result += equiv_harmonious_min_perc
        return result
      }
    return result
  }
}

extension SunOl2 {

  mutating func calc() {
    var xy = [Double](repeating: 0.0, count: 117895 + 365)
    /// Day
    let A = 0
    for i in 1..<365 { xy[A + i] = xy[A + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    let B = 365
    for i in 1..<365 { xy[B + i] = countIFS(CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, <=0) }

    /// Nr of hours where min harmonious is possible considering grid support
    let C = 730
    for i in 1..<365 { xy[C + i] = countIFS(CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Min el cons during night
    let E = 1460
    for i in 1..<365 { xy[E + i] = A_overall_var_min_cons * xy[B + i] }

    /// Max el cons during night
    let F = 1825
    for i in 1..<365 { xy[F + i] = A_overall_var_max_cons * xy[B + i] }

    /// Min heat cons during night
    let G = 2190
    for i in 1..<365 { xy[G + i] = A_overall_var_heat_min_cons * xy[B + i] }

    /// Max heat cons during night
    let H = 2555
    for i in 1..<365 { xy[H + i] = A_overall_var_heat_max_cons * xy[B + i] }

    /// Min RawMeth cons during night
    let I = 2920
    for i in 1..<365 { xy[I + i] = A_RawMeth_min_cons * xy[B + i] }

    /// Max RawMeth cons during night
    let J = 3285
    for i in 1..<365 { xy[J + i] = A_RawMeth_max_cons * xy[B + i] }

    /// Min CO2 cons during night
    let K = 3650
    for i in 1..<365 { xy[K + i] = A_CO2_min_cons * xy[B + i] }

    /// Max CO2 cons during night
    let L = 4015
    for i in 1..<365 { xy[L + i] = A_CO2_max_cons * xy[B + i] }

    /// Min H2 cons during night
    let M = 4380
    for i in 1..<365 { xy[M + i] = A_H2_min_cons * xy[B + i] }

    /// Max H2 cons during night
    let N = 4745
    for i in 1..<365 { xy[N + i] = A_H2_max_cons * xy[B + i] }

    /// Min el cons during day for night op prep
    let O = 5110
    for i in 1..<365 {
      xy[O + i] =
        (xy[M + i] + xy[I + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[K + i] + xy[I + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[I + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let P = 5475
    for i in 1..<365 {
      xy[P + i] =
        (xy[N + i] + xy[J + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[L + i] + xy[J + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[J + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let Q = 5840
    for i in 1..<365 {
      xy[Q + i] =
        (xy[M + i] + xy[I + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[K + i] + xy[I + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[I + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Max heat cons during day for prep of night
    let R = 6205
    for i in 1..<365 {
      xy[R + i] =
        (xy[N + i] + xy[J + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[L + i] + xy[J + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[J + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let S = 6570
    for i in 1..<365 { xy[S + i] = 1 - xy[I + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let T = 6935
    for i in 1..<365 { xy[T + i] = 1 - xy[J + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let U = 7300
    for i in 1..<365 { xy[U + i] = 1 - xy[K + i] / CO2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let V = 7665
    for i in 1..<365 { xy[V + i] = 1 - xy[L + i] / CO2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let W = 8030
    for i in 1..<365 { xy[W + i] = 1 - xy[M + i] / H2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let X = 8395
    for i in 1..<365 { xy[X + i] = 1 - xy[N + i] / H2_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let Y = 8760
    for i in 1..<365 {
      xy[Y + i] =
        min(
          iff(xy[S + i] <= 0, 0, iff(xy[T + i] >= 0, 1, 1 / (xy[S + i] - xy[T + i]) * xy[S + i])),
          iff(xy[U + i] <= 0, 0, iff(xy[V + i] >= 0, 1, 1 / (xy[U + i] - xy[V + i]) * xy[U + i])),
          iff(xy[W + i] <= 0, 0, iff(xy[X + i] >= 0, 1, 1 / (xy[W + i] - xy[X + i]) * xy[W + i]))
        ) * (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) + A_equiv_harmonious_min_perc
    }

    /// Min el cons during night
    let AA = 9490
    for i in 1..<365 { xy[AA + i] = B_overall_var_min_cons * xy[B + i] }

    /// Max el cons during night
    let AB = 9855
    for i in 1..<365 { xy[AB + i] = B_overall_var_max_cons * xy[B + i] }

    /// Min heat cons during night
    let AC = 10220
    for i in 1..<365 { xy[AC + i] = B_overall_var_heat_min_cons * xy[B + i] }

    /// Max heat cons during night
    let AD = 10585
    for i in 1..<365 { xy[AD + i] = B_overall_var_heat_max_cons * xy[B + i] }

    /// Min RawMeth cons during night
    let AE = 10950
    for i in 1..<365 { xy[AE + i] = B_RawMeth_min_cons * xy[B + i] }

    /// Max RawMeth cons during night
    let AF = 11315
    for i in 1..<365 { xy[AF + i] = B_RawMeth_max_cons * xy[B + i] }

    /// Min CO2 cons during night
    let AG = 11680
    for i in 1..<365 { xy[AG + i] = B_CO2_min_cons * xy[B + i] }

    /// Max CO2 cons during night
    let AH = 12045
    for i in 1..<365 { xy[AH + i] = B_CO2_max_cons * xy[B + i] }

    /// Min H2 cons during night
    let AI = 12410
    for i in 1..<365 { xy[AI + i] = B_H2_min_cons * xy[B + i] }

    /// Max H2 cons during night
    let AJ = 12775
    for i in 1..<365 { xy[AJ + i] = B_H2_max_cons * xy[B + i] }

    /// Min el cons during day for night op prep
    let AK = 13140
    for i in 1..<365 {
      xy[AK + i] =
        (xy[AI + i] + xy[AE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[AG + i] + xy[AE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[AE + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let AL = 13505
    for i in 1..<365 {
      xy[AL + i] =
        (xy[AJ + i] + xy[AF + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[AH + i] + xy[AF + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[AF + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let AM = 13870
    for i in 1..<365 {
      xy[AM + i] =
        (xy[AI + i] + xy[AE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[AG + i] + xy[AE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[AE + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Max heat cons during day for prep of night
    let AN = 14235
    for i in 1..<365 {
      xy[AN + i] =
        (xy[AJ + i] + xy[AF + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[AH + i] + xy[AF + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[AF + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let AO = 14600
    for i in 1..<365 { xy[AO + i] = 1 - xy[AE + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let AP = 14965
    for i in 1..<365 { xy[AP + i] = 1 - xy[AF + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let AQ = 15330
    for i in 1..<365 { xy[AQ + i] = 1 - xy[AG + i] / CO2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let AR = 15695
    for i in 1..<365 { xy[AR + i] = 1 - xy[AH + i] / CO2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let AS = 16060
    for i in 1..<365 { xy[AS + i] = 1 - xy[AI + i] / H2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let AT = 16425
    for i in 1..<365 { xy[AT + i] = 1 - xy[AJ + i] / H2_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let AU = 16790
    for i in 1..<365 {
      xy[AU + i] =
        min(
          iff(xy[AO + i] <= 0, 0, iff(xy[AP + i] >= 0, 1, 1 / (xy[AO + i] - xy[AP + i]) * xy[AO + i])),
          iff(xy[AQ + i] <= 0, 0, iff(xy[AR + i] >= 0, 1, 1 / (xy[AQ + i] - xy[AR + i]) * xy[AQ + i])),
          iff(xy[AS + i] <= 0, 0, iff(xy[AT + i] >= 0, 1, 1 / (xy[AS + i] - xy[AT + i]) * xy[AS + i]))
        ) * (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) + B_equiv_harmonious_min_perc
    }

    /// Min el cons during night
    let AW = 17520
    for i in 1..<365 { xy[AW + i] = C_overall_var_min_cons * xy[B + i] }

    /// Max el cons during night
    let AX = 17885
    for i in 1..<365 { xy[AX + i] = C_overall_var_max_cons * xy[B + i] }

    /// Min heat cons during night
    let AY = 18250
    for i in 1..<365 { xy[AY + i] = C_overall_var_heat_min_cons * xy[B + i] }

    /// Max heat cons during night
    let AZ = 18615
    for i in 1..<365 { xy[AZ + i] = C_overall_var_heat_max_cons * xy[B + i] }

    /// Min RawMeth cons during night
    let BA = 18980
    for i in 1..<365 { xy[BA + i] = C_RawMeth_min_cons * xy[B + i] }

    /// Max RawMeth cons during night
    let BB = 19345
    for i in 1..<365 { xy[BB + i] = C_RawMeth_max_cons * xy[B + i] }

    /// Min CO2 cons during night
    let BC = 19710
    for i in 1..<365 { xy[BC + i] = C_CO2_min_cons * xy[B + i] }

    /// Max CO2 cons during night
    let BD = 20075
    for i in 1..<365 { xy[BD + i] = C_CO2_max_cons * xy[B + i] }

    /// Min H2 cons during night
    let BE = 20440
    for i in 1..<365 { xy[BE + i] = C_H2_min_cons * xy[B + i] }

    /// Max H2 cons during night
    let BF = 20805
    for i in 1..<365 { xy[BF + i] = C_H2_max_cons * xy[B + i] }

    /// Min el cons during day for night op prep
    let BG = 21170
    for i in 1..<365 {
      xy[BG + i] =
        (xy[BE + i] + xy[BA + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[BC + i] + xy[BA + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[BA + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let BH = 21535
    for i in 1..<365 {
      xy[BH + i] =
        (xy[BF + i] + xy[BB + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[BD + i] + xy[BB + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[BB + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let BI = 21900
    for i in 1..<365 {
      xy[BI + i] =
        (xy[BE + i] + xy[BA + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[BC + i] + xy[BA + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[BA + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Max heat cons during day for prep of night
    let BJ = 22265
    for i in 1..<365 {
      xy[BJ + i] =
        (xy[BF + i] + xy[BB + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[BD + i] + xy[BB + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[BB + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let BK = 22630
    for i in 1..<365 { xy[BK + i] = 1 - xy[BA + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let BL = 22995
    for i in 1..<365 { xy[BL + i] = 1 - xy[BB + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let BM = 23360
    for i in 1..<365 { xy[BM + i] = 1 - xy[BC + i] / CO2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let BN = 23725
    for i in 1..<365 { xy[BN + i] = 1 - xy[BD + i] / CO2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let BO = 24090
    for i in 1..<365 { xy[BO + i] = 1 - xy[BE + i] / H2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let BP = 24455
    for i in 1..<365 { xy[BP + i] = 1 - xy[BF + i] / H2_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let BQ = 24820
    for i in 1..<365 {
      xy[BQ + i] =
        min(
          iff(xy[BK + i] <= 0, 0, iff(xy[BL + i] >= 0, 1, 1 / (xy[BK + i] - xy[BL + i]) * xy[BK + i])),
          iff(xy[BM + i] <= 0, 0, iff(xy[BN + i] >= 0, 1, 1 / (xy[BM + i] - xy[BN + i]) * xy[BM + i])),
          iff(xy[BO + i] <= 0, 0, iff(xy[BP + i] >= 0, 1, 1 / (xy[BO + i] - xy[BP + i]) * xy[BO + i]))
        ) * (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) + C_equiv_harmonious_min_perc
    }

    /// Min el cons during night
    let BS = 25550
    for i in 1..<365 { xy[BS + i] = D_overall_var_min_cons * xy[B + i] }

    /// Max el cons during night
    let BT = 25915
    for i in 1..<365 { xy[BT + i] = D_overall_var_max_cons * xy[B + i] }

    /// Min heat cons during night
    let BU = 26280
    for i in 1..<365 { xy[BU + i] = D_overall_var_heat_min_cons * xy[B + i] }

    /// Max heat cons during night
    let BV = 26645
    for i in 1..<365 { xy[BV + i] = D_overall_var_heat_max_cons * xy[B + i] }

    /// Min RawMeth cons during night
    let BW = 27010
    for i in 1..<365 { xy[BW + i] = D_RawMeth_min_cons * xy[B + i] }

    /// Max RawMeth cons during night
    let BX = 27375
    for i in 1..<365 { xy[BX + i] = D_RawMeth_max_cons * xy[B + i] }

    /// Min CO2 cons during night
    let BY = 27740
    for i in 1..<365 { xy[BY + i] = D_CO2_min_cons * xy[B + i] }

    /// Max CO2 cons during night
    let BZ = 28105
    for i in 1..<365 { xy[BZ + i] = D_CO2_max_cons * xy[B + i] }

    /// Min H2 cons during night
    let CA = 28470
    for i in 1..<365 { xy[CA + i] = D_H2_min_cons * xy[B + i] }

    /// Max H2 cons during night
    let CB = 28835
    for i in 1..<365 { xy[CB + i] = D_H2_max_cons * xy[B + i] }

    /// Min el cons during day for night op prep
    let CC = 29200
    for i in 1..<365 {
      xy[CC + i] =
        (xy[CA + i] + xy[BW + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[BY + i] + xy[BW + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[BW + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let CD = 29565
    for i in 1..<365 {
      xy[CD + i] =
        (xy[CB + i] + xy[BX + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_cons
        + (xy[BZ + i] + xy[BX + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_nom_cons + CCU_fix_cons + xy[BX + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_nom_cons + MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let CE = 29930
    for i in 1..<365 {
      xy[CE + i] =
        (xy[CA + i] + xy[BW + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[BY + i] + xy[BW + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[BW + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Max heat cons during day for prep of night
    let CF = 30295
    for i in 1..<365 {
      xy[CF + i] =
        (xy[CB + i] + xy[BX + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
        + (xy[BZ + i] + xy[BX + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons) * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod_ud * CCU_var_heat_nom_cons - xy[BX + i] / MethSynt_RawMeth_nom_prod_ud
        * MethSynt_var_heat_nom_prod
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let CG = 30660
    for i in 1..<365 { xy[CG + i] = 1 - xy[BW + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let CH = 31025
    for i in 1..<365 { xy[CH + i] = 1 - xy[BX + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let CI = 31390
    for i in 1..<365 { xy[CI + i] = 1 - xy[BY + i] / CO2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let CJ = 31755
    for i in 1..<365 { xy[CJ + i] = 1 - xy[BZ + i] / CO2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let CK = 32120
    for i in 1..<365 { xy[CK + i] = 1 - xy[CA + i] / H2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let CL = 32485
    for i in 1..<365 { xy[CL + i] = 1 - xy[CB + i] / H2_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let CM = 32850
    for i in 1..<365 {
      xy[CM + i] =
        min(
          iff(xy[CG + i] <= 0, 0, iff(xy[CH + i] >= 0, 1, 1 / (xy[CG + i] - xy[CH + i]) * xy[CG + i])),
          iff(xy[CI + i] <= 0, 0, iff(xy[CJ + i] >= 0, 1, 1 / (xy[CI + i] - xy[CJ + i]) * xy[CI + i])),
          iff(xy[CK + i] <= 0, 0, iff(xy[CL + i] >= 0, 1, 1 / (xy[CK + i] - xy[CL + i]) * xy[CK + i]))
        ) * (D_equiv_harmonious_max_perc - D_equiv_harmonious_min_perc) + D_equiv_harmonious_min_perc
    }

    /// Available day op PV elec after CSP, PB stby aux
    let CO = 33580
    for i in 1..<365 { xy[CO + i] = SUMIFS(CalculationN5, N_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Available night op PV elec after CSP, PB stby aux
    let CP = 33945
    for i in 1..<365 { xy[CP + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationN5, N_end) - xy[CO + i] }

    /// Available day op  CSP heat
    let CQ = 34310
    for i in 1..<365 { xy[CQ + i] = SUMIFS(CalculationJ5, J_end, CalculationS5, S_end, ==&xy[A + i], CalculationR5, R_end, >0) }

    /// Available night op  CSP heat
    let CR = 34675
    for i in 1..<365 { xy[CR + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationJ5, J_end) - xy[CQ + i] }

    /// El cons considering min harmonious op during daytime
    let CT = 35405
    for i in 1..<365 { xy[CT + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end) }

    /// Heat cons considering min harmonious op during daytime
    let CU = 35770
    for i in 1..<365 { xy[CU + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationR5, R_end) }

    /// Grid cons considering min harmonious op during harmonious op period
    let CV = 36135
    for i in 1..<365 { xy[CV + i] = SUMIFS(CalculationV5, V_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Grid cons considering min harmonious op outside of harmonious op period
    let CW = 36500
    for i in 1..<365 { xy[CW + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationV5, V_end) - xy[CV + i] }

    /// Remaining PV el after min harmonious during harmonious op period
    let CX = 36865
    for i in 1..<365 { xy[CX + i] = SUMIFS(CalculationT5, T_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining PV el after min harmonious outside of harmonious op period
    let CY = 37230
    for i in 1..<365 { xy[CY + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationT5, T_end) - xy[CX + i] }

    /// Remaining CSP heat after min harmonious during harmonious op period
    let CZ = 37595
    for i in 1..<365 { xy[CZ + i] = SUMIFS(CalculationU5, U_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining CSP heat after min harmonious outside of harmonious op period
    let DA = 37960
    for i in 1..<365 { xy[DA + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationU5, U_end) - xy[CZ + i] }

    /// Remaining grid import cap during harmonious op period after min harmonious
    let DB = 38325
    for i in 1..<365 { xy[DB + i] = SUMIFS(CalculationW5, W_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining grid import cap outside of harmonious op period after min harmonious
    let DC = 38690
    for i in 1..<365 { xy[DC + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationW5, W_end) - xy[DB + i] }

    /// Max BESS night prep after min harmonious cons during harm op period
    let DD = 39055
    for i in 1..<365 { xy[DD + i] = min(SUMIFS(CalculationAB5, AB_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) * BESS_chrg_eff, BESS_cap_ud) }

    /// Max BESS night prep after min harmonious cons outside of harm op period
    let DE = 39420
    for i in 1..<365 { xy[DE + i] = min(SUMIFS(CalculationAB5, AB_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, ==0) * BESS_chrg_eff, BESS_cap_ud) }

    /// Remaining El boiler cap during harmonious op period after min harmonious
    let DF = 39785
    for i in 1..<365 { xy[DF + i] = SUMIFS(CalculationX5, X_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining El boiler cap outside of harmonious op period after min harmonious
    let DG = 40150
    for i in 1..<365 { xy[DG + i] = min(SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationX5, X_end) - xy[DF + i], (xy[DE + i] + xy[DD + i] + xy[DC + i]) * El_boiler_eff) }

    /// Remaining MethSynt cap during harmonious op after min harmonious
    let DH = 40515
    for i in 1..<365 { xy[DH + i] = SUMIFS(CalculationY5, Y_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining MethSynt cap outside of harmonious op after min harmonious
    let DI = 40880
    for i in 1..<365 { xy[DI + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationY5, Y_end) - xy[DH + i] }

    /// Remaining CCU cap during harmonious op after min harmonious
    let DJ = 41245
    for i in 1..<365 { xy[DJ + i] = SUMIFS(CalculationZ5, Z_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining CCU cap outside of harmonious op after min harmonious
    let DK = 41610
    for i in 1..<365 { xy[DK + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationZ5, Z_end) - xy[DJ + i] }

    /// Remaining EY cap during harmonious op after min harmonious
    let DL = 41975
    for i in 1..<365 { xy[DL + i] = SUMIFS(CalculationAA5, AA_end, CalculationS5, S_end, ==&xy[A + i], CalculationQ5, Q_end, >0) }

    /// Remaining EY cap outside of harmonious op after min harmonious
    let DM = 42340
    for i in 1..<365 { xy[DM + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAA5, AA_end) - xy[DL + i] }

    /// El cons considering max harmonious op during daytime
    let DO = 43070
    for i in 1..<365 { xy[DO + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end) }

    /// Heat cons considering max harmonious op during daytime
    let DP = 43435
    for i in 1..<365 { xy[DP + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAE5, AE_end) }

    /// Grid cons considering max harmonious op during daytime
    let DQ = 43800
    for i in 1..<365 { xy[DQ + i] = SUMIFS(CalculationAH5, AH_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Grid cons considering min harmonious op outside of harmonious op period
    let DR = 44165
    for i in 1..<365 { xy[DR + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAH5, AH_end) - xy[DQ + i] }

    /// Remaining PV el after max harmoniousduring harmonious op period
    let DS = 44530
    for i in 1..<365 { xy[DS + i] = SUMIFS(CalculationAF5, AF_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining PV el after max harmonious outside of harmonious op period
    let DT = 44895
    for i in 1..<365 { xy[DT + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAF5, AF_end) - xy[DS + i] }

    /// Remaining CSP heat after max harmonious during harmonious op period
    let DU = 45260
    for i in 1..<365 { xy[DU + i] = SUMIFS(CalculationAG5, AG_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining CSP heat after max harmonious outside of harmonious op period
    let DV = 45625
    for i in 1..<365 { xy[DV + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAG5, AG_end) - xy[DU + i] }

    /// Remaining grid import cap during harmonious op period after max harmonious
    let DW = 45990
    for i in 1..<365 { xy[DW + i] = SUMIFS(CalculationAI5, AI_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining grid import cap after harmonious op period after max harmonious
    let DX = 46355
    for i in 1..<365 { xy[DX + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAI5, AI_end) - xy[DW + i] }

    /// Max BESS night prep after max harmonious cons during harm op period
    let DY = 46720
    for i in 1..<365 { xy[DY + i] = min(SUMIFS(CalculationAN5, AN_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) * BESS_chrg_eff, BESS_cap_ud) }

    /// Max BESS night prep after max harmonious cons outside of harm op period
    let DZ = 47085
    for i in 1..<365 { xy[DZ + i] = min(SUMIFS(CalculationAN5, AN_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, ==0) * BESS_chrg_eff, BESS_cap_ud) }

    /// Remaining El boiler cap during harmonious op period after max harmonious
    let EA = 47450
    for i in 1..<365 { xy[EA + i] = SUMIFS(CalculationAJ5, AJ_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining El boiler cap outside of harmonious op period after max harmonious
    let EB = 47815
    for i in 1..<365 { xy[EB + i] = min(SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAJ5, AJ_end) - xy[EA + i], (xy[DZ + i] + xy[DY + i] + xy[DX + i]) * El_boiler_eff) }

    /// Remaining MethSynt cap during harmonious op period after max harmonious
    let EC = 48180
    for i in 1..<365 { xy[EC + i] = SUMIFS(CalculationAK5, AK_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining MethSynt cap outside of harmonious op period after max harmonious
    let ED = 48545
    for i in 1..<365 { xy[ED + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAK5, AK_end) - xy[EC + i] }

    /// Remaining CCU cap during harmonious op after max harmonious
    let EE = 48910
    for i in 1..<365 { xy[EE + i] = SUMIFS(CalculationAL5, AL_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining CCU cap outside of harmonious op after max harmonious
    let EF = 49275
    for i in 1..<365 { xy[EF + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAL5, AL_end) - xy[EE + i] }

    /// Remaining EY cap during harmonious op period after max harmonious
    let EG = 49640
    for i in 1..<365 { xy[EG + i] = SUMIFS(CalculationAM5, AM_end, CalculationS5, S_end, ==&xy[A + i], CalculationAD5, AD_end, >0) }

    /// Remaining EY cap outside of harmonious op period after max harmonious
    let EH = 50005
    for i in 1..<365 { xy[EH + i] = SUMiff(CalculationS5, S_end, ==&xy[A + i], CalculationAM5, AM_end) - xy[EG + i] }

    /// Surplus harm op period electricity after min day harmonious and min night op prep
    let EJ = 50735
    for i in 1..<365 {
      xy[EJ + i] = xy[CX + i] + xy[DB + i] - xy[O + i] - min(xy[CW + i] + xy[E + i] + xy[G + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - min(xy[DF + i], max(0, xy[Q + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus harm op period electricity after min day harmonious and max night op prep
    let EK = 51100
    for i in 1..<365 {
      xy[EK + i] =
        xy[CX + i] + xy[DB + i] - xy[P + i] * xy[Y + i] - min(xy[CW + i] + (xy[F + i] + xy[H + i] / El_boiler_eff) * xy[Y + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
        - min(xy[DG + i], max(0, xy[R + i] * xy[Y + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus outside harm op period electricity after min day harmonious and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let EL = 51465
    for i in 1..<365 { xy[EL + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - xy[E + i] - xy[G + i] / El_boiler_eff }

    /// Surplus outside harm op period electricity after min day harmonious and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let EM = 51830
    for i in 1..<365 { xy[EM + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - (xy[F + i] + xy[H + i] / El_boiler_eff) * xy[Y + i] }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let EN = 52195
    for i in 1..<365 {
      xy[EN + i] = xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + xy[E + i] + xy[G + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[O + i]) * El_boiler_eff - xy[Q + i]
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let EO = 52560
    for i in 1..<365 {
      xy[EO + i] =
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[F + i] + xy[H + i] / El_boiler_eff) * xy[Y + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[P + i] * xy[Y + i]) * El_boiler_eff
        - xy[R + i] * xy[Y + i]
    }

    /// Surplus outside harm op steam prod cap after min day harmonious and min night op prep
    let EP = 52925
    for i in 1..<365 { xy[EP + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[G + i] }

    /// Surplus outside harm op steam prod cap after min day harmonious and max night op prep
    let EQ = 53290
    for i in 1..<365 { xy[EQ + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[H + i] * xy[Y + i] }

    /// Surplus RawMeth prod cap after min day harmonious and min night op prep
    let ER = 53655
    for i in 1..<365 { xy[ER + i] = xy[DH + i] - xy[I + i] }

    /// Surplus RawMeth prod cap after min day harmonious and max night op prep
    let ES = 54020
    for i in 1..<365 { xy[ES + i] = xy[DH + i] - xy[J + i] * xy[Y + i] }

    /// Surplus CO2 prod cap after min day harmonious and min night op prep
    let ET = 54385
    for i in 1..<365 { xy[ET + i] = xy[DJ + i] - xy[K + i] }

    /// Surplus CO2 prod cap after min day harmonious and max night op prep
    let EU = 54750
    for i in 1..<365 { xy[EU + i] = xy[DJ + i] - xy[L + i] * xy[Y + i] }

    /// Surplus H2 prod cap after min day harmonious and min night op prep
    let EV = 55115
    for i in 1..<365 { xy[EV + i] = xy[DL + i] - xy[M + i] }

    /// Surplus H2 prod cap after min day harmonious and max night op prep
    let EW = 55480
    for i in 1..<365 { xy[EW + i] = xy[DL + i] - xy[N + i] * xy[Y + i] }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let EX = 55845
    for i in 1..<365 {
      xy[EX + i] = iff(
        or(xy[EJ + i] < 0, xy[EL + i] < 0, xy[EN + i] < 0, xy[EP + i] < 0, xy[ER + i] < 0, xy[ET + i] < 0, xy[EV + i] < 0),
        0,
        iff(
          min(
            1,
            (xy[CT + i] + min(
              xy[EJ + i] / (xy[DO + i] - xy[CT + i]),
              xy[EN + i] / (xy[DP + i] - xy[CU + i]),
              xy[ER + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[ET + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[EV + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            (xy[CT + i] + min(
              xy[EJ + i] / (xy[DO + i] - xy[CT + i]),
              xy[EN + i] / (xy[DP + i] - xy[CU + i]),
              xy[ER + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[ET + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[EV + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          )
        )
      )
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let EY = 56210
    for i in 1..<365 {
      xy[EY + i] = iff(
        or(xy[EJ + i] < 0, xy[EL + i] < 0, xy[EN + i] < 0, xy[EP + i] < 0, xy[ER + i] < 0, xy[ET + i] < 0, xy[EV + i] < 0),
        0,
        min(
          iff(xy[EK + i] >= 0, 1, 1 / (xy[EJ + i] - xy[EK + i]) * xy[EJ + i]),
          iff(xy[EM + i] >= 0, 1, 1 / (xy[EL + i] - xy[EM + i]) * xy[EL + i]),
          iff(xy[EO + i] >= 0, 1, 1 / (xy[EN + i] - xy[EO + i]) * xy[EN + i]),
          iff(xy[EQ + i] >= 0, 1, 1 / (xy[EP + i] - xy[EQ + i]) * xy[EP + i]),
          iff(xy[ES + i] >= 0, 1, 1 / (xy[ER + i] - xy[ES + i]) * xy[ER + i]),
          iff(xy[EU + i] >= 0, 1, 1 / (xy[ET + i] - xy[EU + i]) * xy[ET + i]),
          iff(xy[EW + i] >= 0, 1, 1 / (xy[EV + i] - xy[EW + i]) * xy[EV + i])
        ) * (A_equiv_harmonious_max_perc * xy[Y + i] - A_equiv_harmonious_min_perc) + A_equiv_harmonious_min_perc
      )
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let EZ = 56575
    for i in 1..<365 {
      xy[EZ + i] = iff(
        xy[EY + i] == 0,
        0,
        xy[CX + i] + xy[DB + i] - xy[P + i] * xy[EY + i] - min(xy[CW + i] + (xy[F + i] + xy[H + i] / El_boiler_eff) * xy[EY + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
          - min(xy[DG + i], max(0, xy[R + i] * xy[EY + i] - xy[CZ + i]) / El_boiler_eff)
      )
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let FA = 56940
    for i in 1..<365 {
      xy[FA + i] = iff(
        xy[EY + i] == 0,
        0,
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[F + i] + xy[H + i] / El_boiler_eff) * xy[EY + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[P + i] * xy[EY + i]) * El_boiler_eff
          - xy[R + i] * xy[EY + i]
      )
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let FB = 57305
    for i in 1..<365 { xy[FB + i] = iff(xy[EY + i] == 0, 0, xy[ER + i] - (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[J + i] - xy[I + i])) }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let FC = 57670
    for i in 1..<365 { xy[FC + i] = iff(xy[EY + i] == 0, 0, xy[ET + i] - (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[L + i] - xy[K + i])) }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let FD = 58035
    for i in 1..<365 { xy[FD + i] = iff(xy[EY + i] == 0, 0, xy[EV + i] - (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[N + i] - xy[M + i])) }

    /// Max harmonious day prod after max night prep due to prod cap limits
    let FE = 58400
    for i in 1..<365 {
      xy[FE + i] = iff(
        xy[EY + i] <= 0,
        0,
        iff(
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[EZ + i] / (xy[DO + i] - xy[CT + i]),
                xy[FA + i] / (xy[DP + i] - xy[CU + i]),
                xy[FB + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[FC + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[FD + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[EZ + i] / (xy[DO + i] - xy[CT + i]),
                xy[FA + i] / (xy[DP + i] - xy[CU + i]),
                xy[FB + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[FC + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[FD + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          )
        )
      )
    }

    /// el cons for harmonious op during harm op period
    let FG = 59130
    for i in 1..<365 { xy[FG + i] = iff(xy[EX + i] == 0, 0, xy[CT + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let FH = 59495
    for i in 1..<365 { xy[FH + i] = iff(xy[EX + i] == 0, 0, xy[O + i]) }

    /// el cons for BESS charging during harm op period
    let FI = 59860
    for i in 1..<365 {
      xy[FI + i] = iff(
        xy[EX + i] == 0,
        0,
        min(
          xy[CW + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[E + i] + max(0, xy[G + i] - xy[CR + i]) / El_boiler_eff,
          xy[DD + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let FJ = 60225
    for i in 1..<365 { xy[FJ + i] = iff(xy[EX + i] == 0, 0, xy[CU + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let FK = 60590
    for i in 1..<365 { xy[FK + i] = iff(xy[EX + i] == 0, 0, xy[Q + i]) }

    /// CSP heat available during harm op period after all consumption
    let FL = 60955
    for i in 1..<365 { xy[FL + i] = iff(xy[EX + i] == 0, 0, max(0, xy[CQ + i] - xy[FJ + i] - xy[FK + i])) }

    /// heat demand not covered by CSP during harm op period
    let FM = 61320
    for i in 1..<365 { xy[FM + i] = iff(xy[EX + i] == 0, 0, max(0, -xy[CQ + i] + xy[FJ + i] + xy[FK + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let FN = 61685
    for i in 1..<365 { xy[FN + i] = iff(xy[EX + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[FM + i])) }

    /// el cons from el boiler during harm op period
    let FO = 62050
    for i in 1..<365 { xy[FO + i] = iff(xy[EX + i] == 0, 0, xy[FN + i] / El_boiler_eff) }

    /// heat demand outside of harm op period not covered by CSP
    let FP = 62415
    for i in 1..<365 { xy[FP + i] = iff(xy[EX + i] == 0, 0, max(0, xy[G + i] - xy[CR + i])) }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let FQ = 62780
    for i in 1..<365 { xy[FQ + i] = iff(xy[EX + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[FP + i])) }

    /// el cons from el boiler outside of harm op period
    let FR = 63145
    for i in 1..<365 { xy[FR + i] = xy[FQ + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let FS = 63510
    for i in 1..<365 { xy[FS + i] = iff(xy[EX + i] == 0, 0, xy[CO + i] - xy[FG + i] - xy[FH + i] - xy[FI + i] - xy[FO + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let FT = 63875
    for i in 1..<365 {
      xy[FT + i] = iff(
        xy[EX + i] == 0,
        0,
        xy[E + i] + xy[CW + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[FR + i] - xy[FI + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let FU = 64240
    for i in 1..<365 {
      xy[FU + i] = iff(xy[EX + i] == 0, 0, max(0, -xy[FS + i]) + xy[CV + i] + (xy[EX + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let FV = 64605
    for i in 1..<365 { xy[FV + i] = iff(xy[EX + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[FT + i])) }

    /// Pure Methanol prod with min night prep and resp day op
    let FW = 64970
    for i in 1..<365 {
      xy[FW + i] = iff(xy[FG + i] <= 0, 0, (xy[FG + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * A_RawMeth_min_cons / MethDist_RawMeth_nom_cons) * MethDist_Meth_nom_prod_ud)
    }

    /// el cons for harmonious op during harm op period
    let FY = 65700
    for i in 1..<365 { xy[FY + i] = iff(xy[FE + i] == 0, 0, xy[CT + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let FZ = 66065
    for i in 1..<365 { xy[FZ + i] = iff(xy[EY + i] == 0, 0, xy[O + i] + (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[P + i] - xy[O + i])) }

    /// el cons for BESS charging during harm op period
    let GA = 66430
    for i in 1..<365 {
      xy[GA + i] = iff(
        or(xy[EY + i] == 0, xy[FE + i] == 0),
        0,
        min(
          xy[CW + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[E + i] + (xy[EY + i] - A_equiv_harmonious_min_perc)
            / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[F + i] - xy[E + i]) + max(
              0,
              xy[G + i] + (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[H + i] - xy[G + i]) - xy[CR + i]
            ) / El_boiler_eff,
          xy[DD + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let GB = 66795
    for i in 1..<365 { xy[GB + i] = iff(xy[FE + i] == 0, 0, xy[CU + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let GC = 67160
    for i in 1..<365 { xy[GC + i] = iff(xy[EY + i] == 0, 0, xy[Q + i] + (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[R + i] - xy[Q + i])) }

    /// CSP heat available during harm op period after all consumption
    let GD = 67525
    for i in 1..<365 { xy[GD + i] = iff(xy[FE + i] == 0, 0, max(0, xy[CQ + i] - xy[GB + i] - xy[GC + i])) }

    /// heat demand not covered by CSP during harm op period
    let GE = 67890
    for i in 1..<365 { xy[GE + i] = iff(xy[FE + i] == 0, 0, max(0, -xy[CQ + i] + xy[GB + i] + xy[GC + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let GF = 68255
    for i in 1..<365 { xy[GF + i] = iff(xy[FE + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[GE + i])) }

    /// el cons from el boiler during harm op period
    let GG = 68620
    for i in 1..<365 { xy[GG + i] = xy[GF + i] / El_boiler_eff }

    /// heat demand outside of harm op period not covered by CSP
    let GH = 68985
    for i in 1..<365 {
      xy[GH + i] = iff(xy[EY + i] == 0, 0, max(0, xy[G + i] + (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[H + i] - xy[G + i]) - xy[CR + i]))
    }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let GI = 69350
    for i in 1..<365 { xy[GI + i] = iff(xy[EY + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[GH + i])) }

    /// el cons from el boiler outside of harm op period
    let GJ = 69715
    for i in 1..<365 { xy[GJ + i] = xy[GI + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let GK = 70080
    for i in 1..<365 { xy[GK + i] = iff(xy[FE + i] == 0, 0, xy[CO + i] - xy[FY + i] - xy[FZ + i] - xy[GA + i] - xy[GG + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let GL = 70445
    for i in 1..<365 {
      xy[GL + i] = iff(
        or(xy[EY + i] == 0, xy[FE + i] == 0),
        0,
        xy[E + i] + (xy[EY + i] - A_equiv_harmonious_min_perc) / (A_equiv_harmonious_max_perc - A_equiv_harmonious_min_perc) * (xy[F + i] - xy[E + i]) + xy[CW + i] + (xy[FE + i] - Overall_harmonious_min_perc)
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[GJ + i] - xy[GA + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let GM = 70810
    for i in 1..<365 {
      xy[GM + i] = iff(xy[FE + i] == 0, 0, max(0, -xy[GK + i]) + xy[CV + i] + (xy[FE + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let GN = 71175
    for i in 1..<365 { xy[GN + i] = iff(xy[EY + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[GL + i])) }

    /// Pure Methanol prod with min night prep and resp day op
    let GO = 71540
    for i in 1..<365 {
      xy[GO + i] = iff(
        xy[FY + i] <= 0,
        0,
        xy[FY + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud + xy[B + i] * xy[EY + i] * A_RawMeth_max_cons / MethDist_RawMeth_nom_cons * MethDist_Meth_nom_prod_ud
      )
    }

    /// PV elec available after min night prep
    let GQ = 72270
    for i in 1..<365 {
      xy[GQ + i] = iff(xy[FG + i] <= 0, 0, (xy[CT + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * A_RawMeth_min_cons / MethDist_RawMeth_nom_cons) * MethDist_Meth_nom_prod_ud)
    }

    /// Surplus RawMeth abs after min op
    let GR = 72635
    for i in 1..<365 { xy[GR + i] = iff(xy[FG + i] <= 0, 0, xy[ER + i]) }

    /// Surplus CO2 after abs min op
    let GS = 73000
    for i in 1..<365 { xy[GS + i] = iff(xy[FG + i] <= 0, 0, xy[ET + i]) }

    /// Surplus H2 after abs min op
    let GT = 73365
    for i in 1..<365 { xy[GT + i] = iff(xy[FG + i] <= 0, 0, xy[EV + i]) }

    /// Surplus harm op period electricity after min day harmonious and min night op prep
    let GV = 74095
    for i in 1..<365 {
      xy[GV + i] =
        xy[CX + i] + xy[DB + i] - xy[AK + i] - min(xy[CW + i] + xy[AA + i] + xy[AC + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - min(xy[DF + i], max(0, xy[AM + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus harm op period electricity after min day harmonious and max night op prep
    let GW = 74460
    for i in 1..<365 {
      xy[GW + i] =
        xy[CX + i] + xy[DB + i] - xy[AL + i] * xy[AU + i] - min(xy[CW + i] + (xy[AB + i] + xy[AD + i] / El_boiler_eff) * xy[AU + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
        - min(xy[DG + i], max(0, xy[AN + i] * xy[AU + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus outside harm op period electricity after min day harmonious and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GX = 74825
    for i in 1..<365 { xy[GX + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - xy[AA + i] - xy[AC + i] / El_boiler_eff }

    /// Surplus outside harm op period electricity after min day harmonious and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let GY = 75190
    for i in 1..<365 { xy[GY + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - (xy[AB + i] + xy[AD + i] / El_boiler_eff) * xy[AU + i] }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let GZ = 75555
    for i in 1..<365 {
      xy[GZ + i] = xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + xy[AA + i] + xy[AC + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[AK + i]) * El_boiler_eff - xy[AM + i]
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let HA = 75920
    for i in 1..<365 {
      xy[HA + i] =
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[AB + i] + xy[AD + i] / El_boiler_eff) * xy[AU + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[AL + i] * xy[AU + i]) * El_boiler_eff
        - xy[AN + i] * xy[AU + i]
    }

    /// Surplus outside harm op steam prod cap after min day harmonious and min night op prep
    let HB = 76285
    for i in 1..<365 { xy[HB + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[AC + i] }

    /// Surplus outside harm op steam prod cap after min day harmonious and max night op prep
    let HC = 76650
    for i in 1..<365 { xy[HC + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[AD + i] * xy[AU + i] }

    /// Surplus RawMeth prod cap after min day harmonious and min night op prep
    let HD = 77015
    for i in 1..<365 { xy[HD + i] = xy[DH + i] - xy[AE + i] }

    /// Surplus RawMeth prod cap after min day harmonious and max night op prep
    let HE = 77380
    for i in 1..<365 { xy[HE + i] = xy[DH + i] - xy[AF + i] * xy[AU + i] }

    /// Surplus CO2 prod cap after min day harmonious and min night op prep
    let HF = 77745
    for i in 1..<365 { xy[HF + i] = xy[DJ + i] - xy[AG + i] }

    /// Surplus CO2 prod cap after min day harmonious and max night op prep
    let HG = 78110
    for i in 1..<365 { xy[HG + i] = xy[DJ + i] - xy[AH + i] * xy[AU + i] }

    /// Surplus H2 prod cap after min day harmonious and min night op prep
    let HH = 78475
    for i in 1..<365 { xy[HH + i] = xy[DL + i] - xy[AI + i] }

    /// Surplus H2 prod cap after min day harmonious and max night op prep
    let HI = 78840
    for i in 1..<365 { xy[HI + i] = xy[DL + i] - xy[AJ + i] * xy[AU + i] }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let HJ = 79205
    for i in 1..<365 {
      xy[HJ + i] = iff(
        or(xy[GV + i] < 0, xy[GX + i] < 0, xy[GZ + i] < 0, xy[HB + i] < 0, xy[HD + i] < 0, xy[HF + i] < 0, xy[HH + i] < 0),
        0,
        iff(
          min(
            1,
            (xy[CT + i] + min(
              xy[GV + i] / (xy[DO + i] - xy[CT + i]),
              xy[GZ + i] / (xy[DP + i] - xy[CU + i]),
              xy[HD + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[HF + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[HH + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            (xy[CT + i] + min(
              xy[GV + i] / (xy[DO + i] - xy[CT + i]),
              xy[GZ + i] / (xy[DP + i] - xy[CU + i]),
              xy[HD + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[HF + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[HH + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          )
        )
      )
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let HK = 79570
    for i in 1..<365 {
      xy[HK + i] = iff(
        or(xy[GV + i] < 0, xy[GX + i] < 0, xy[GZ + i] < 0, xy[HB + i] < 0, xy[HD + i] < 0, xy[HF + i] < 0, xy[HH + i] < 0),
        0,
        min(
          iff(xy[GW + i] >= 0, 1, 1 / (xy[GV + i] - xy[GW + i]) * xy[GV + i]),
          iff(xy[GY + i] >= 0, 1, 1 / (xy[GX + i] - xy[GY + i]) * xy[GX + i]),
          iff(xy[HA + i] >= 0, 1, 1 / (xy[GZ + i] - xy[HA + i]) * xy[GZ + i]),
          iff(xy[HC + i] >= 0, 1, 1 / (xy[HB + i] - xy[HC + i]) * xy[HB + i]),
          iff(xy[HE + i] >= 0, 1, 1 / (xy[HD + i] - xy[HE + i]) * xy[HD + i]),
          iff(xy[HG + i] >= 0, 1, 1 / (xy[HF + i] - xy[HG + i]) * xy[HF + i]),
          iff(xy[HI + i] >= 0, 1, 1 / (xy[HH + i] - xy[HI + i]) * xy[HH + i])
        ) * (B_equiv_harmonious_max_perc * xy[AU + i] - B_equiv_harmonious_min_perc) + B_equiv_harmonious_min_perc
      )
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let HL = 79935
    for i in 1..<365 {
      xy[HL + i] = iff(
        xy[HK + i] == 0,
        0,
        xy[CX + i] + xy[DB + i] - xy[AL + i] * xy[HK + i] - min(xy[CW + i] + (xy[AB + i] + xy[AD + i] / El_boiler_eff) * xy[HK + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
          - min(xy[DG + i], max(0, xy[AN + i] * xy[HK + i] - xy[CZ + i]) / El_boiler_eff)
      )
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let HM = 80300
    for i in 1..<365 {
      xy[HM + i] = iff(
        xy[HK + i] == 0,
        0,
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[AB + i] + xy[AD + i] / El_boiler_eff) * xy[HK + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[AL + i] * xy[HK + i]) * El_boiler_eff
          - xy[AN + i] * xy[HK + i]
      )
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let HN = 80665
    for i in 1..<365 { xy[HN + i] = iff(xy[HK + i] == 0, 0, xy[HD + i] - (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AF + i] - xy[AE + i])) }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let HO = 81030
    for i in 1..<365 { xy[HO + i] = iff(xy[HK + i] == 0, 0, xy[HF + i] - (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AH + i] - xy[AG + i])) }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let HP = 81395
    for i in 1..<365 { xy[HP + i] = iff(xy[HK + i] == 0, 0, xy[HH + i] - (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AJ + i] - xy[AI + i])) }

    /// Max harmonious day prod after max night prep due to prod cap limits
    let HQ = 81760
    for i in 1..<365 {
      xy[HQ + i] = iff(
        xy[HK + i] <= 0,
        0,
        iff(
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[HL + i] / (xy[DO + i] - xy[CT + i]),
                xy[HM + i] / (xy[DP + i] - xy[CU + i]),
                xy[HN + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[HO + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[HP + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[HL + i] / (xy[DO + i] - xy[CT + i]),
                xy[HM + i] / (xy[DP + i] - xy[CU + i]),
                xy[HN + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[HO + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[HP + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          )
        )
      )
    }

    /// el cons for harmonious op during harm op period
    let HS = 82490
    for i in 1..<365 { xy[HS + i] = iff(xy[HJ + i] == 0, 0, xy[CT + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let HT = 82855
    for i in 1..<365 { xy[HT + i] = iff(xy[HJ + i] == 0, 0, xy[AK + i]) }

    /// el cons for BESS charging during harm op period
    let HU = 83220
    for i in 1..<365 {
      xy[HU + i] = iff(
        xy[HJ + i] == 0,
        0,
        min(
          xy[CW + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[AA + i] + max(0, xy[AC + i] - xy[CR + i]) / El_boiler_eff,
          xy[DD + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let HV = 83585
    for i in 1..<365 { xy[HV + i] = iff(xy[HJ + i] == 0, 0, xy[CU + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let HW = 83950
    for i in 1..<365 { xy[HW + i] = iff(xy[HJ + i] == 0, 0, xy[AM + i]) }

    /// CSP heat available during harm op period after all consumption
    let HX = 84315
    for i in 1..<365 { xy[HX + i] = iff(xy[HJ + i] == 0, 0, max(0, xy[CQ + i] - xy[HV + i] - xy[HW + i])) }

    /// heat demand not covered by CSP during harm op period
    let HY = 84680
    for i in 1..<365 { xy[HY + i] = iff(xy[HJ + i] == 0, 0, max(0, -xy[CQ + i] + xy[HV + i] + xy[HW + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let HZ = 85045
    for i in 1..<365 { xy[HZ + i] = iff(xy[HJ + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[HY + i])) }

    /// el cons from el boiler during harm op period
    let IA = 85410
    for i in 1..<365 { xy[IA + i] = iff(xy[HJ + i] == 0, 0, xy[HZ + i] / El_boiler_eff) }

    /// heat demand outside of harm op period not covered by CSP
    let IB = 85775
    for i in 1..<365 { xy[IB + i] = iff(xy[HJ + i] == 0, 0, max(0, xy[AC + i] - xy[CR + i])) }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let IC = 86140
    for i in 1..<365 { xy[IC + i] = iff(xy[HJ + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[IB + i])) }

    /// el cons from el boiler outside of harm op period
    let ID = 86505
    for i in 1..<365 { xy[ID + i] = xy[IC + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let IE = 86870
    for i in 1..<365 { xy[IE + i] = iff(xy[HJ + i] == 0, 0, xy[CO + i] - xy[HS + i] - xy[HT + i] - xy[HU + i] - xy[IA + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let IF = 87235
    for i in 1..<365 {
      xy[IF + i] = iff(
        xy[HJ + i] == 0,
        0,
        xy[AA + i] + xy[CW + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[ID + i] - xy[HU + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let IG = 87600
    for i in 1..<365 {
      xy[IG + i] = iff(xy[HJ + i] == 0, 0, max(0, -xy[IE + i]) + xy[CV + i] + (xy[HJ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let IH = 87965
    for i in 1..<365 { xy[IH + i] = iff(xy[HJ + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[IF + i])) }

    /// Pure Methanol prod with min night prep and resp day op
    let II = 88330
    for i in 1..<365 {
      xy[II + i] = iff(xy[HS + i] <= 0, 0, (xy[HS + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * B_equiv_harmonious_min_perc * B_MethDist_max_perc) * MethDist_Meth_nom_prod_ud)
    }

    /// el cons for harmonious op during harm op period
    let IK = 89060
    for i in 1..<365 { xy[IK + i] = iff(xy[HQ + i] == 0, 0, xy[CT + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let IL = 89425
    for i in 1..<365 { xy[IL + i] = iff(xy[HK + i] == 0, 0, xy[AK + i] + (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AL + i] - xy[AK + i])) }

    /// el cons for BESS charging during harm op period
    let IM = 89790
    for i in 1..<365 {
      xy[IM + i] = iff(
        or(xy[HK + i] == 0, xy[HQ + i] == 0),
        0,
        min(
          xy[CW + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[AA + i] + (xy[HK + i] - B_equiv_harmonious_min_perc)
            / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AB + i] - xy[AA + i]) + max(
              0,
              xy[AC + i] + (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AD + i] - xy[AC + i]) - xy[CR + i]
            ) / El_boiler_eff,
          xy[DD + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let IN = 90155
    for i in 1..<365 { xy[IN + i] = iff(xy[HQ + i] == 0, 0, xy[CU + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let IO = 90520
    for i in 1..<365 { xy[IO + i] = iff(xy[HK + i] == 0, 0, xy[AM + i] + (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AN + i] - xy[AM + i])) }

    /// CSP heat available during harm op period after all consumption
    let IP = 90885
    for i in 1..<365 { xy[IP + i] = iff(xy[HQ + i] == 0, 0, max(0, xy[CQ + i] - xy[IN + i] - xy[IO + i])) }

    /// heat demand not covered by CSP during harm op period
    let IQ = 91250
    for i in 1..<365 { xy[IQ + i] = iff(xy[HQ + i] == 0, 0, max(0, -xy[CQ + i] + xy[IN + i] + xy[IO + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let IR = 91615
    for i in 1..<365 { xy[IR + i] = iff(xy[HQ + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[IQ + i])) }

    /// el cons from el boiler during harm op period
    let IS = 91980
    for i in 1..<365 { xy[IS + i] = xy[IR + i] / El_boiler_eff }

    /// heat demand outside of harm op period not covered by CSP
    let IT = 92345
    for i in 1..<365 {
      xy[IT + i] = iff(xy[HK + i] == 0, 0, max(0, xy[AC + i] + (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AD + i] - xy[AC + i]) - xy[CR + i]))
    }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let IU = 92710
    for i in 1..<365 { xy[IU + i] = iff(xy[HK + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[IT + i])) }

    /// el cons from el boiler outside of harm op period
    let IV = 93075
    for i in 1..<365 { xy[IV + i] = xy[IU + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let IW = 93440
    for i in 1..<365 { xy[IW + i] = iff(xy[HQ + i] == 0, 0, xy[CO + i] - xy[IK + i] - xy[IL + i] - xy[IM + i] - xy[IS + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let IX = 93805
    for i in 1..<365 {
      xy[IX + i] = iff(
        or(xy[HK + i] == 0, xy[HQ + i] == 0),
        0,
        xy[AA + i] + (xy[HK + i] - B_equiv_harmonious_min_perc) / (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc) * (xy[AB + i] - xy[AA + i]) + xy[CW + i] + (xy[HQ + i] - Overall_harmonious_min_perc)
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[IV + i] - xy[IM + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let IY = 94170
    for i in 1..<365 {
      xy[IY + i] = iff(xy[HQ + i] == 0, 0, max(0, -xy[IW + i]) + xy[CV + i] + (xy[HQ + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let IZ = 94535
    for i in 1..<365 { xy[IZ + i] = iff(xy[HK + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[IX + i])) }

    /// Pure Methanol prod with min night prep and resp day op
    let JA = 94900
    for i in 1..<365 { xy[JA + i] = iff(xy[IK + i] <= 0, 0, (xy[IK + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * xy[HK + i] * B_MethDist_max_perc) * MethDist_Meth_nom_prod_ud) }

    /// PV elec available after min night prep
    let JC = 95630
    for i in 1..<365 {
      xy[JC + i] = iff(xy[HS + i] <= 0, 0, (xy[CT + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * B_equiv_harmonious_min_perc * B_MethDist_max_perc) * MethDist_Meth_nom_prod_ud)
    }

    /// Surplus RawMeth abs after min op
    let JD = 95995
    for i in 1..<365 { xy[JD + i] = iff(xy[HS + i] <= 0, 0, xy[HD + i]) }

    /// Surplus CO2 after abs min op
    let JE = 96360
    for i in 1..<365 { xy[JE + i] = iff(xy[HS + i] <= 0, 0, xy[HF + i]) }

    /// Surplus H2 after abs min op
    let JF = 96725
    for i in 1..<365 { xy[JF + i] = iff(xy[HS + i] <= 0, 0, xy[HH + i]) }

    /// Surplus harm op period electricity after min day harmonious and min night op prep
    let JH = 97455
    for i in 1..<365 {
      xy[JH + i] =
        xy[CX + i] + xy[DB + i] - xy[BG + i] - min(xy[CW + i] + xy[AW + i] + xy[AY + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - min(xy[DF + i], max(0, xy[BI + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus harm op period electricity after min day harmonious and max night op prep
    let JI = 97820
    for i in 1..<365 {
      xy[JI + i] =
        xy[CX + i] + xy[DB + i] - xy[BH + i] * xy[BQ + i] - min(xy[CW + i] + (xy[AX + i] + xy[AZ + i] / El_boiler_eff) * xy[BQ + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
        - min(xy[DG + i], max(0, xy[BJ + i] * xy[BQ + i] - xy[CZ + i]) / El_boiler_eff)
    }

    /// Surplus outside harm op period electricity after min day harmonious and min night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let JJ = 98185
    for i in 1..<365 { xy[JJ + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - xy[AW + i] - xy[AY + i] / El_boiler_eff }

    /// Surplus outside harm op period electricity after min day harmonious and max night op prep; comment: it is assumed that PV during off-harmonious period is not well distributed and must therefore be channelled during the BESS to be used
    let JK = 98550
    for i in 1..<365 { xy[JK + i] = xy[DD + i] + xy[DC + i] + xy[DE + i] - (xy[AX + i] + xy[AZ + i] / El_boiler_eff) * xy[BQ + i] }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and min night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let JL = 98915
    for i in 1..<365 {
      xy[JL + i] = xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + xy[AW + i] + xy[AY + i] / El_boiler_eff, xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[BG + i]) * El_boiler_eff - xy[BI + i]
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and max night op prep; Comment: it is assumed that PV electricity from outside harmonious period is used to charge BESS
    let JM = 99280
    for i in 1..<365 {
      xy[JM + i] =
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[AX + i] + xy[AZ + i] / El_boiler_eff) * xy[BQ + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[BH + i] * xy[BQ + i]) * El_boiler_eff
        - xy[BJ + i] * xy[BQ + i]
    }

    /// Surplus outside harm op steam prod cap after min day harmonious and min night op prep
    let JN = 99645
    for i in 1..<365 { xy[JN + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[AY + i] }

    /// Surplus outside harm op steam prod cap after min day harmonious and max night op prep
    let JO = 100010
    for i in 1..<365 { xy[JO + i] = xy[DA + i] + xy[DG + i] * El_boiler_eff - xy[AZ + i] * xy[BQ + i] }

    /// Surplus RawMeth prod cap after min day harmonious and min night op prep
    let JP = 100375
    for i in 1..<365 { xy[JP + i] = xy[DH + i] - xy[BA + i] }

    /// Surplus RawMeth prod cap after min day harmonious and max night op prep
    let JQ = 100740
    for i in 1..<365 { xy[JQ + i] = xy[DH + i] - xy[BB + i] * xy[BQ + i] }

    /// Surplus CO2 prod cap after min day harmonious and min night op prep
    let JR = 101105
    for i in 1..<365 { xy[JR + i] = xy[DJ + i] - xy[BC + i] }

    /// Surplus CO2 prod cap after min day harmonious and max night op prep
    let JS = 101470
    for i in 1..<365 { xy[JS + i] = xy[DJ + i] - xy[BD + i] * xy[BQ + i] }

    /// Surplus H2 prod cap after min day harmonious and min night op prep
    let JT = 101835
    for i in 1..<365 { xy[JT + i] = xy[DL + i] - xy[BE + i] }

    /// Surplus H2 prod cap after min day harmonious and max night op prep
    let JU = 102200
    for i in 1..<365 { xy[JU + i] = xy[DL + i] - xy[BF + i] * xy[BQ + i] }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let JV = 102565
    for i in 1..<365 {
      xy[JV + i] = iff(
        or(xy[JH + i] < 0, xy[JJ + i] < 0, xy[JL + i] < 0, xy[JN + i] < 0, xy[JP + i] < 0, xy[JR + i] < 0, xy[JT + i] < 0),
        0,
        iff(
          min(
            1,
            (xy[CT + i] + min(
              xy[JH + i] / (xy[DO + i] - xy[CT + i]),
              xy[JL + i] / (xy[DP + i] - xy[CU + i]),
              xy[JP + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[JR + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[JT + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            (xy[CT + i] + min(
              xy[JH + i] / (xy[DO + i] - xy[CT + i]),
              xy[JL + i] / (xy[DP + i] - xy[CU + i]),
              xy[JP + i] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod_ud,
              xy[JR + i] / CCU_harmonious_max_perc / CCU_CO2_nom_prod_ud,
              xy[JT + i] / EY_harmonious_max_perc / EY_H2_nom_prod
            ) * Overall_harmonious_var_max_cons) / xy[DO + i]
          )
        )
      )
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let JW = 102930
    for i in 1..<365 {
      xy[JW + i] = iff(
        or(xy[JH + i] < 0, xy[JJ + i] < 0, xy[JL + i] < 0, xy[JN + i] < 0, xy[JP + i] < 0, xy[JR + i] < 0, xy[JT + i] < 0),
        0,
        min(
          iff(xy[JI + i] >= 0, 1, 1 / (xy[JH + i] - xy[JI + i]) * xy[JH + i]),
          iff(xy[JK + i] >= 0, 1, 1 / (xy[JJ + i] - xy[JK + i]) * xy[JJ + i]),
          iff(xy[JM + i] >= 0, 1, 1 / (xy[JL + i] - xy[JM + i]) * xy[JL + i]),
          iff(xy[JO + i] >= 0, 1, 1 / (xy[JN + i] - xy[JO + i]) * xy[JN + i]),
          iff(xy[JQ + i] >= 0, 1, 1 / (xy[JP + i] - xy[JQ + i]) * xy[JP + i]),
          iff(xy[JS + i] >= 0, 1, 1 / (xy[JR + i] - xy[JS + i]) * xy[JR + i]),
          iff(xy[JU + i] >= 0, 1, 1 / (xy[JT + i] - xy[JU + i]) * xy[JT + i])
        ) * (C_equiv_harmonious_max_perc * xy[BQ + i] - C_equiv_harmonious_min_perc) + C_equiv_harmonious_min_perc
      )
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let JX = 103295
    for i in 1..<365 {
      xy[JX + i] = iff(
        xy[JW + i] == 0,
        0,
        xy[CX + i] + xy[DB + i] - xy[BH + i] * xy[JW + i] - min(xy[CW + i] + (xy[AX + i] + xy[AZ + i] / El_boiler_eff) * xy[JW + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff
          - min(xy[DG + i], max(0, xy[BJ + i] * xy[JW + i] - xy[CZ + i]) / El_boiler_eff)
      )
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let JY = 103660
    for i in 1..<365 {
      xy[JY + i] = iff(
        xy[JW + i] == 0,
        0,
        xy[CZ + i] + min(xy[DF + i], xy[CX + i] + xy[DB + i] - min(xy[CW + i] + (xy[AX + i] + xy[AZ + i] / El_boiler_eff) * xy[JW + i], xy[DD + i] - xy[DE + i]) / BESS_chrg_eff - xy[BH + i] * xy[JW + i]) * El_boiler_eff
          - xy[BJ + i] * xy[JW + i]
      )
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let JZ = 104025
    for i in 1..<365 { xy[JZ + i] = iff(xy[JW + i] == 0, 0, xy[JP + i] - (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[BB + i] - xy[BA + i])) }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let KA = 104390
    for i in 1..<365 { xy[KA + i] = iff(xy[JW + i] == 0, 0, xy[JR + i] - (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[BD + i] - xy[BC + i])) }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let KB = 104755
    for i in 1..<365 { xy[KB + i] = iff(xy[JW + i] == 0, 0, xy[JT + i] - (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[BF + i] - xy[BE + i])) }

    /// Max harmonious day prod after max night prep due to prod cap limits
    let KC = 105120
    for i in 1..<365 {
      xy[KC + i] = iff(
        xy[JW + i] <= 0,
        0,
        iff(
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[JX + i] / (xy[DO + i] - xy[CT + i]),
                xy[JY + i] / (xy[DP + i] - xy[CU + i]),
                xy[JZ + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[KA + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[KB + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          ) < Overall_harmonious_min_perc,
          0,
          min(
            1,
            Overall_harmonious_min_perc
              + (min(
                xy[JX + i] / (xy[DO + i] - xy[CT + i]),
                xy[JY + i] / (xy[DP + i] - xy[CU + i]),
                xy[JZ + i] / (MethSynt_harmonious_max_perc - MethSynt_harmonious_min_perc) / MethSynt_RawMeth_nom_prod_ud,
                xy[KA + i] / (CCU_harmonious_max_perc - CCU_harmonious_min_perc) / CCU_CO2_nom_prod_ud,
                xy[KB + i] / (EY_harmonious_max_perc - EY_harmonious_min_perc) / EY_H2_nom_prod
              ) * (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)) / (xy[DO + i] - xy[CT + i])
          )
        )
      )
    }

    /// el cons for harmonious op during harm op period
    let KE = 105850
    for i in 1..<365 { xy[KE + i] = iff(xy[JV + i] == 0, 0, xy[CT + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let KF = 106215
    for i in 1..<365 { xy[KF + i] = iff(xy[JV + i] == 0, 0, xy[BG + i]) }

    /// el cons for BESS charging during harm op period
    let KG = 106580
    for i in 1..<365 {
      xy[KG + i] = iff(
        xy[JV + i] == 0,
        0,
        min(
          xy[CW + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[AW + i] + max(0, xy[AY + i] - xy[CR + i]) / El_boiler_eff,
          xy[DD + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let KH = 106945
    for i in 1..<365 { xy[KH + i] = iff(xy[JV + i] == 0, 0, xy[CU + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let KI = 107310
    for i in 1..<365 { xy[KI + i] = iff(xy[JV + i] == 0, 0, xy[BI + i]) }

    /// CSP heat available during harm op period after all consumption
    let KJ = 107675
    for i in 1..<365 { xy[KJ + i] = iff(xy[JV + i] == 0, 0, max(0, xy[CQ + i] - xy[KH + i] - xy[KI + i])) }

    /// heat demand not covered by CSP during harm op period
    let KK = 108040
    for i in 1..<365 { xy[KK + i] = iff(xy[JV + i] == 0, 0, max(0, -xy[CQ + i] + xy[KH + i] + xy[KI + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let KL = 108405
    for i in 1..<365 { xy[KL + i] = iff(xy[JV + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[KK + i])) }

    /// el cons from el boiler during harm op period
    let KM = 108770
    for i in 1..<365 { xy[KM + i] = iff(xy[JV + i] == 0, 0, xy[KL + i] / El_boiler_eff) }

    /// heat demand outside of harm op period not covered by CSP
    let KN = 109135
    for i in 1..<365 { xy[KN + i] = iff(xy[JV + i] == 0, 0, max(0, xy[AY + i] - xy[CR + i])) }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let KO = 109500
    for i in 1..<365 { xy[KO + i] = iff(xy[JV + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[KN + i])) }

    /// el cons from el boiler outside of harm op period
    let KP = 109865
    for i in 1..<365 { xy[KP + i] = xy[KO + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let KQ = 110230
    for i in 1..<365 { xy[KQ + i] = iff(xy[JV + i] == 0, 0, xy[CO + i] - xy[KE + i] - xy[KF + i] - xy[KG + i] - xy[KM + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let KR = 110595
    for i in 1..<365 {
      xy[KR + i] = iff(
        xy[JV + i] == 0,
        0,
        xy[AW + i] + xy[CW + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[KP + i] - xy[KG + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let KS = 110960
    for i in 1..<365 {
      xy[KS + i] = iff(xy[JV + i] == 0, 0, max(0, -xy[KQ + i]) + xy[CV + i] + (xy[JV + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let KT = 111325
    for i in 1..<365 { xy[KT + i] = iff(xy[JV + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[KR + i])) }

    /// Pure Methanol prod with min night prep and resp day op
    let KU = 111690
    for i in 1..<365 {
      xy[KU + i] = iff(xy[KE + i] <= 0, 0, (xy[KE + i] / Overall_harmonious_var_max_cons * MethDist_harmonious_max_perc + xy[B + i] * C_equiv_harmonious_min_perc * C_MethDist_max_perc) * MethDist_Meth_nom_prod_ud)
    }

    /// el cons for harmonious op during harm op period
    let KW = 112420
    for i in 1..<365 { xy[KW + i] = iff(xy[KC + i] == 0, 0, xy[CT + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DO + i] - xy[CT + i])) }

    /// el cons for night prep during harm op period
    let KX = 112785
    for i in 1..<365 { xy[KX + i] = iff(xy[JW + i] == 0, 0, xy[BG + i] + (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[BH + i] - xy[BG + i])) }

    /// el cons for BESS charging during harm op period
    let KY = 113150
    for i in 1..<365 {
      xy[KY + i] = iff(
        or(xy[JW + i] == 0, xy[KC + i] == 0),
        0,
        min(
          xy[CW + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[AW + i] + (xy[JW + i] - C_equiv_harmonious_min_perc)
            / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[AX + i] - xy[AW + i]) + max(
              0,
              xy[AY + i] + (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[AZ + i] - xy[AY + i]) - xy[CR + i]
            ) / El_boiler_eff,
          xy[DD + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DY + i] - xy[DD + i])
            - (xy[DE + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
        ) / BESS_chrg_eff
      )
    }

    /// CSP heat cons for harmonious op during harm op period
    let KZ = 113515
    for i in 1..<365 { xy[KZ + i] = iff(xy[KC + i] == 0, 0, xy[CU + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DP + i] - xy[CU + i])) }

    /// CSP heat cons for night prep during harm op period
    let LA = 113880
    for i in 1..<365 { xy[LA + i] = iff(xy[JW + i] == 0, 0, xy[BI + i] + (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[BJ + i] - xy[BI + i])) }

    /// CSP heat available during harm op period after all consumption
    let LB = 114245
    for i in 1..<365 { xy[LB + i] = iff(xy[KC + i] == 0, 0, max(0, xy[CQ + i] - xy[KZ + i] - xy[LA + i])) }

    /// heat demand not covered by CSP during harm op period
    let LC = 114610
    for i in 1..<365 { xy[LC + i] = iff(xy[KC + i] == 0, 0, max(0, -xy[CQ + i] + xy[KZ + i] + xy[LA + i])) }

    /// heat demand above CSP covered by el boiler during harm op period
    let LD = 114975
    for i in 1..<365 { xy[LD + i] = iff(xy[KC + i] == 0, 0, min(xy[C + i] * El_boiler_cap_ud * El_boiler_eff, xy[LC + i])) }

    /// el cons from el boiler during harm op period
    let LE = 115340
    for i in 1..<365 { xy[LE + i] = xy[LD + i] / El_boiler_eff }

    /// heat demand outside of harm op period not covered by CSP
    let LF = 115705
    for i in 1..<365 {
      xy[LF + i] = iff(xy[JW + i] == 0, 0, max(0, xy[AY + i] + (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[AZ + i] - xy[AY + i]) - xy[CR + i]))
    }

    /// heat demand above CSP covered by el boiler outside of harm op period
    let LG = 116070
    for i in 1..<365 { xy[LG + i] = iff(xy[JW + i] == 0, 0, min(xy[B + i] * El_boiler_cap_ud * El_boiler_eff, xy[LF + i])) }

    /// el cons from el boiler outside of harm op period
    let LH = 116435
    for i in 1..<365 { xy[LH + i] = xy[LG + i] / El_boiler_eff }

    /// PV available during harm op period after all consumption
    let LI = 116800
    for i in 1..<365 { xy[LI + i] = iff(xy[KC + i] == 0, 0, xy[CO + i] - xy[KW + i] - xy[KX + i] - xy[KY + i] - xy[LE + i]) }

    /// el cons outside of harm op period not covered by PV and BESS
    let LJ = 117165
    for i in 1..<365 {
      xy[LJ + i] = iff(
        or(xy[JW + i] == 0, xy[KC + i] == 0),
        0,
        xy[AW + i] + (xy[JW + i] - C_equiv_harmonious_min_perc) / (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc) * (xy[AX + i] - xy[AW + i]) + xy[CW + i] + (xy[KC + i] - Overall_harmonious_min_perc)
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DR + i] - xy[CW + i]) + xy[LH + i] - xy[KY + i] * BESS_chrg_eff
          - (xy[DE + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DZ + i] - xy[DE + i]))
      )
    }

    /// grid input during harm op period
    let LK = 117530
    for i in 1..<365 {
      xy[LK + i] = iff(xy[KC + i] == 0, 0, max(0, -xy[LI + i]) + xy[CV + i] + (xy[KC + i] - Overall_harmonious_min_perc) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (xy[DQ + i] - xy[CV + i]))
    }

    /// grid input outside of harm op period
    let LL = 117895
    for i in 1..<365 { xy[LL + i] = iff(xy[JW + i] == 0, 0, min(xy[B + i] * Grid_import_max_ud, xy[LJ + i])) }

  }
}
