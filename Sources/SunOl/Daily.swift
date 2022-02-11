/*
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
*/