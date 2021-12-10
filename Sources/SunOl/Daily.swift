
struct Production {

  let storage_cap = (RawMeth: 300.0, CO2: 275.0, H2: 50.0)

  let overall_var_min_cons: SIMD4<Double> = [0.9, 0, 0, 0] // A_EY_Min_perc*(EY_var_net_nom_cons+EY_var_aux_nom_cons)+A_MethSynt_Min_perc*MethSynt_var_aux_nom_cons+A_MethDist_Min_perc*MethDist_var_aux_nom_cons+A_CCU_Min_perc*CCU_var_aux_nom_cons
  let overall_var_max_cons: SIMD4<Double> = [1.8, 0, 0, 0] // =L57*(EY_var_net_nom_cons+EY_var_aux_nom_cons)+L55*MethSynt_var_aux_nom_cons+L54*MethDist_var_aux_nom_cons+L56*CCU_var_aux_nom_cons
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
    let result = (11...18).map { r -> SIMD4<Double>in 
      let h = SIMD4<Double>(repeating: Double(r)) 
      let RawMeth_min = RawMeth_min_cons * h// K 4
      let RawMeth_max = RawMeth_max_cons * h // L 5
      let CO2_min = CO2_min_cons * h// M 6
      let CO2_max = CO2_max_cons * h // N 7
      let H2_min = H2_min_cons * h// O 8
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
      let perc: [SIMD4<Double>] = [
        one - RawMeth_min / RawMeth_cap, one - RawMeth_max / RawMeth_cap,
        one - CO2_min / CO2_cap, one - CO2_max / CO2_cap,
        one - H2_min / H2_cap, one - H2_max / H2_cap,
      ]

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

      var result: SIMD4<Double> = [
        min(RawMeth[0], CO2[0], H2[0]), min(RawMeth[1], CO2[1], H2[1]),
        min(RawMeth[2], CO2[2], H2[2]), min(RawMeth[3], CO2[3], H2[3]),
      ]

      result *= equiv_harmonious_max_perc - equiv_harmonious_min_perc
      result += equiv_harmonious_min_perc
      return result
    }
    return result
  }
}

struct Daily {
  var vec = Array(repeating: 0.0, count: 356 * 404)

let A_overall_var_min_cons = 0.0
let A_overall_var_max_cons = 0.0
let A_overall_var_heat_min_cons = 0.0
let A_overall_var_heat_max_cons = 0.0
let A_RawMeth_min_cons = 0.0
let A_RawMeth_max_cons = 0.0
let A_CO2_min_cons = 0.0
let A_CO2_max_cons = 0.0
let A_H2_min_cons = 0.0
let A_H2_max_cons = 0.0
let MethSynt_CO2_nom_cons = 0.0
let MethSynt_H2_nom_cons = 0.0
let EY_H2_nom_prod = 0.0
let EY_var_gross_nom_cons = 0.0
let EY_fix_aux_elec = 0.0
let CCU_CO2_nom_prod = 0.0
let CCU_var_aux_nom_cons = 0.0
let CCU_fix_aux_cons = 0.0
let MethSynt_RawMeth_nom_prod = 0.0
let MethSynt_var_aux_nom_cons = 0.0
let MethSynt_fix_aux_cons = 0.0
let EY_var_heat_nom_cons = 0.0
let CCU_var_heat_nom_cons = 0.0
let MethSynt_var_heat_nom_prod = 0.0
let RawMeth_storage_cap = 0.0
let CO2_storage_cap = 0.0
let H2_storage_cap = 0.0
let A_equiv_harmonious_max_perc = 0.0
let A_equiv_harmonious_min_perc = 0.0
let B_overall_var_min_cons = 0.0
let B_overall_var_max_cons = 0.0
let B_overall_var_heat_min_cons = 0.0
let B_overall_var_heat_max_cons = 0.0
let B_RawMeth_min_cons = 0.0
let B_RawMeth_max_cons = 0.0
let B_CO2_min_cons = 0.0
let B_CO2_max_cons = 0.0
let B_H2_min_cons = 0.0
let B_H2_max_cons = 0.0
let B_equiv_harmonious_max_perc = 0.0
let B_equiv_harmonious_min_perc = 0.0
let C_overall_var_min_cons = 0.0
let C_overall_var_max_cons = 0.0
let C_overall_var_heat_min_cons = 0.0
let C_overall_var_heat_max_cons = 0.0
let C_RawMeth_min_cons = 0.0
let C_RawMeth_max_cons = 0.0
let C_CO2_min_cons = 0.0
let C_CO2_max_cons = 0.0
let C_H2_min_cons = 0.0
let C_H2_max_cons = 0.0
let C_equiv_harmonious_max_perc = 0.0
let C_equiv_harmonious_min_perc = 0.0
let D_equiv_harmonious_max_perc = 0.0
let D_equiv_harmonious_min_perc = 0.0
let E_equiv_harmonious_max_perc = 0.0
let E_equiv_harmonious_min_perc = 0.0
let El_boiler_cap = 0.0
let El_boiler_eff = 0.99
let grid_max_import = 0.0
let BESS_charging_eff = 0.0
let BESS_capacity = 0.0
let Overall_harmonious_max_var_cons = 0.0
let Overall_fix_aux_cons = 0.0
let Overall_harmonious_max_var_heat_cons = 0.0
let MethDist_Meth_nom_prod = 0.0
let MethSynt_harmonious_max_perc = 0.0
let CCU_harmonious_max_perc = 0.0
let EY_harmonious_max_perc = 0.0
let DP3 = 0.0

  mutating func calc() {
    
    for i in 0..<365 {
      let i = i * 404
      // vec[i] = A110 + 1
      // vec[i+1] = COUNTIFS(Calculation_O5:O8763, "=" & vec[i], Calculation_P5:P8763, "<=0")
      // vec[i+2] = COUNTIFS(Calculation_O5:O8763, "=" & vec[i], Calculation_P5:P8763, ">0")
      // vec[i+3]
      // vec[i+4]
      // vec[i+5]
  
      // vec[i+115]
      // vec[i+116] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_M5..<M8763)
      // vec[i+117] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_I5..<I8763)
      // vec[i+118]
      // vec[i+119] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_N5..<N8763) + vec[i+1]
      //   * PB_stby_aux_cons
      // vec[i+120] = Swift.min(
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AA5..<AA8763) * BESS_charging_eff,
      //   BESS_capacity
      // )
      vec[i+121] = Swift.min(
        vec[i+1] * El_boiler_cap * El_boiler_eff,
        (vec[i+120] + vec[i+122]) * El_boiler_eff
      )
      vec[i+122] = vec[i+1] * grid_max_import
       
      // vec[i+123]
      // vec[i+124] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_P5..<P8763)
      // vec[i+125] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_Q5..<Q8763)
      // vec[i+126] = SUMIFS(
      //   Calculation_U5..<U8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+127] = SUMIFS(
      //   Calculation_S5..<S8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+128] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_S5..<S8763) - vec[i+127]
      // vec[i+129] = SUMIFS(
      //   Calculation_T5..<T8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+130] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_T5..<T8763) - vec[i+129]
      // vec[i+131] = SUMIFS(
      //   Calculation_V5..<V8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_S5..<S8763,
      //   ">0"
      // )
      // vec[i+132] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_V5..<V8763) - vec[i+131]
      // vec[i+133] = SUMIFS(
      //   Calculation_W5..<W8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+134] = Swift.min(
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_W5..<W8763) - vec[i+133],
      //   (vec[i+141] + vec[i+132]) * El_boiler_eff
      // )
      // vec[i+135] = SUMIFS(
      //   Calculation_X5..<X8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+136] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_X5..<X8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_S5..<S8763,
      //     ">0"
      //   ) - vec[i+135]
      // )
      // vec[i+137] = SUMIFS(
      //   Calculation_Y5..<Y8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+138] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_Y5..<Y8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_S5..<S8763,
      //     ">0"
      //   ) - vec[i+137]
      // )
      // vec[i+139] = SUMIFS(
      //   Calculation_Z5..<Z8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_P5..<P8763,
      //   ">0"
      // )
      // vec[i+140] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_Z5..<Z8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_S5..<S8763,
      //     ">0"
      //   ) - vec[i+139]
      // )
      // vec[i+141] = Swift.min(
      //   SUMIFS(
      //     Calculation_AA5..<AA8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_S5..<S8763,
      //     ">0"
      //   ) * BESS_charging_eff,
      //   BESS_capacity
      // )
      // vec[i+142]
      // vec[i+143]
      // vec[i+144] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AB5..<AB8763)
      // vec[i+145] = SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AC5..<AC8763)
      // vec[i+146] = SUMIFS(
      //   Calculation_AG5..<AG8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+147] = SUMIFS(
      //   Calculation_AE5..<AE8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+148] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AE5..<AE8763) - vec[i+147]
      // vec[i+149] = SUMIFS(
      //   Calculation_AF5..<AF8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+150] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AF5..<AF8763) - vec[i+149]
      // vec[i+151] = SUMIFS(
      //   Calculation_AH5..<AH8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+152] =
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AH5..<AH8763) - vec[i+151]
      // vec[i+153] = SUMIFS(
      //   Calculation_AI5..<AI8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+154] = Swift.min(
      //   SUMiff(Calculation_O5..<O8763, "=" & vec[i+0], Calculation_AI5..<AI8763) - vec[i+153],
      //   (vec[i+161] + vec[i+152]) * El_boiler_eff
      // )
      // vec[i+155] = SUMIFS(
      //   Calculation_AJ5..<AJ8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+156] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_AJ5..<AJ8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_AE5..<AE8763,
      //     ">0"
      //   ) - vec[i+155]
      // )
      // vec[i+157] = SUMIFS(
      //   Calculation_AK5..<AK8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+158] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_AK5..<AK8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_AE5..<AE8763,
      //     ">0"
      //   ) - vec[i+157]
      // )
      // vec[i+159] = SUMIFS(
      //   Calculation_AL5..<AL8763,
      //   Calculation_O5..<O8763,
      //   "=" & vec[i+0],
      //   Calculation_AB5..<AB8763,
      //   ">0"
      // )
      // vec[i+160] = Swift.max(
      //   0,
      //   SUMIFS(
      //     Calculation_AL5..<AL8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_AE5..<AE8763,
      //     ">0"
      //   ) - vec[i+159]
      // )
      // vec[i+161] = Swift.min(
      //   SUMIFS(
      //     Calculation_AM5..<AM8763,
      //     Calculation_O5..<O8763,
      //     "=" & vec[i+0],
      //     Calculation_S5..<S8763,
      //     ">0"
      //   ) * BESS_charging_eff,
      //   BESS_capacity
      // )
      // vec[i+162]
      // vec[i+163]
      vec[i+164] =
        vec[i+141] + vec[i+132] + vec[i+128] - vec[i+6] - vec[i+8] / El_boiler_eff - DP3
      vec[i+165] =
        vec[i+141] + vec[i+132] + vec[i+128] - (vec[i+7] + vec[i+9] / El_boiler_eff)
        * vec[i+0] - vec[i+119]
      vec[i+166] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+18]
      vec[i+167] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+19] * vec[i+0]
      vec[i+168] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+8]
      vec[i+169] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+9] * vec[i+0]
      vec[i+170] = vec[i+135] - vec[i+10]
      vec[i+171] = vec[i+135] - vec[i+11] * vec[i+0]
      vec[i+172] = vec[i+137] - vec[i+12]
      vec[i+173] = vec[i+137] - vec[i+13] * vec[i+0]
      vec[i+174] = vec[i+139] - vec[i+14]
      vec[i+175] = vec[i+139] - vec[i+15] * vec[i+0]
      vec[i+176] = iff(
        or(
          vec[i+164] < 0,
          vec[i+166] < 0,
          vec[i+168] < 0,
          vec[i+170] < 0,
          vec[i+172] < 0,
          vec[i+174] < 0
        ),
        0,
        Swift.min(
          iff(
            vec[i+164] <= 0,
            0,
            iff(vec[i+165] >= 0, 1, 1.0 / (vec[i+164] - vec[i+165]) * vec[i+164])
          ),
          iff(
            vec[i+166] <= 0,
            0,
            iff(vec[i+167] >= 0, 1, 1.0 / (vec[i+166] - vec[i+167]) * vec[i+166])
          ),
          iff(
            vec[i+168] <= 0,
            0,
            iff(vec[i+169] >= 0, 1, 1.0 / (vec[i+168] - vec[i+169]) * vec[i+168])
          ),
          iff(
            vec[i+170] <= 0,
            0,
            iff(vec[i+171] >= 0, 1, 1.0 / (vec[i+170] - vec[i+171]) * vec[i+170])
          ),
          iff(
            vec[i+172] <= 0,
            0,
            iff(vec[i+173] >= 0, 1, 1.0 / (vec[i+172] - vec[i+173]) * vec[i+172])
          ),
          iff(
            vec[i+174] <= 0,
            0,
            iff(vec[i+175] >= 0, 1, 1.0 / (vec[i+174] - vec[i+175]) * vec[i+174])
          )
        ) * (A_equiv_harmonious_max_perc * vec[i+0] - A_equiv_harmonious_min_perc)
          + A_equiv_harmonious_min_perc
      )
      vec[i+177] = iff(
        vec[i+176] <= 0,
        0,
        Swift.min(
          1,
          (vec[i+124] + Swift.min(
            vec[i+170] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod,
            vec[i+172] / CCU_harmonious_max_perc / CCU_CO2_nom_prod,
            vec[i+174] / EY_harmonious_max_perc / EY_H2_nom_prod
          ) * Overall_harmonious_max_var_cons) / vec[i+144]
        )
      )
      // vec[i+178]
      vec[i+179] = iff(
        vec[i+176] == 0,
        0,
        vec[i+116] - vec[i+16] - Swift.min(
          BESS_capacity,
          (vec[i+6] + vec[i+8] / El_boiler_eff + vec[i+119])
        ) / BESS_charging_eff
      )
      vec[i+180] = iff(
        vec[i+176] == 0,
        0,
        vec[i+116] - vec[i+17] * vec[i+176] - Swift.min(
          BESS_capacity,
          (vec[i+7] + vec[i+9] / El_boiler_eff) * vec[i+176] + vec[i+119]
        ) / BESS_charging_eff
      )
      vec[i+181] = iff(vec[i+176] == 0, 0, vec[i+117] - vec[i+18])
      vec[i+182] = iff(vec[i+176] == 0, 0, vec[i+117] - vec[i+19] * vec[i+176])
      vec[i+183] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+181]) / El_boiler_eff
      vec[i+184] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+182]) / El_boiler_eff
      vec[i+185] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+179])
          + Swift.max(0, -vec[i+181] - vec[i+179] * El_boiler_eff)) / El_boiler_eff
      vec[i+186] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+180])
          + Swift.max(0, -vec[i+182] - vec[i+180] * El_boiler_eff)) / El_boiler_eff
      vec[i+187] = iff(
        or(vec[i+176] == 0, vec[i+185] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+177],
            vec[i+124]
              + (vec[i+144] * vec[i+177] - vec[i+124])
                * (Swift.max(0, vec[i+179]) + vec[i+185] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+181])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+177] - vec[i+124])
                  + (vec[i+145] * vec[i+177] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+181]) + Swift.min(
                vec[i+183],
                vec[i+179] - vec[i+124] + vec[i+185]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+181]) + Swift.min(
                vec[i+183],
                vec[i+179] - vec[i+124] + vec[i+185]
              ) * El_boiler_eff) / vec[i+125] * vec[i+124]
            )
          )
        )
      )
 
      vec[i+188] = iff(
        or(vec[i+176] == 0, vec[i+186] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+177],
            vec[i+124]
              + (vec[i+144] * vec[i+177] - vec[i+124])
                * (Swift.max(0, vec[i+180]) + vec[i+186] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+182])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+177] - vec[i+124])
                  + (vec[i+145] * vec[i+177] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+182]) + Swift.min(
                vec[i+184],
                vec[i+180] - vec[i+144] * vec[i+177] + vec[i+186]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+182]) + Swift.min(
                vec[i+184],
                vec[i+180] - vec[i+144] * vec[i+177] + vec[i+186]
              ) * El_boiler_eff) / (vec[i+145] * vec[i+177]) * vec[i+144] * vec[i+177]
            )
          )
        )
      )
      vec[i+189] =
        vec[i+187] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+190] =
        vec[i+188] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+191] = iff(
        vec[i+176] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+16] - Swift.min(
            BESS_capacity,
            vec[i+6] + vec[i+8] / El_boiler_eff + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+187] + Swift.max(0, -vec[i+181] + vec[i+189]) / El_boiler_eff)
      )
      vec[i+192] = iff(
        vec[i+176] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+17] * vec[i+176] - Swift.min(
            BESS_capacity,
            (vec[i+7] + vec[i+9] / El_boiler_eff) * vec[i+176] + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+188] + (Swift.max(0, -vec[i+182] + vec[i+190])) / El_boiler_eff)
      )
      vec[i+193] = Swift.max(0, vec[i+181] - vec[i+189])
      vec[i+194] = Swift.max(0, vec[i+182] - vec[i+190])
      vec[i+195] = iff(
        vec[i+187] <= 0,
        0,
        (vec[i+187] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(0, vec[i+6] + vec[i+8] / El_boiler_eff + vec[i+119] - BESS_capacity)
          + Swift.max(0, -vec[i+191])
      )
      vec[i+196] = iff(
        vec[i+188] <= 0,
        0,
        (vec[i+188] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            (vec[i+7] + vec[i+9] / El_boiler_eff) * vec[i+176] + vec[i+119]
              - BESS_capacity
          ) + Swift.max(0, -vec[i+192])
      )
      vec[i+197] = iff(
        vec[i+187] <= 0,
        0,
        vec[i+187] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * A_equiv_harmonious_min_perc * MethDist_Meth_nom_prod
      )
      vec[i+198] = iff(
        vec[i+188] <= 0,
        0,
        vec[i+188] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * A_equiv_harmonious_max_perc * vec[i+176] * MethDist_Meth_nom_prod
      )
      vec[i+199] =
        vec[i+170]
        - Swift.max(
          0,
          (vec[i+187] - vec[i+124]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+200] =
        vec[i+171]
        - Swift.max(
          0,
          (vec[i+188] - vec[i+144] * vec[i+177]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+201] =
        vec[i+172]
        - Swift.max(
          0,
          (vec[i+187] - vec[i+124]) / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
            * CCU_CO2_nom_prod
        )
      vec[i+202] =
        vec[i+173]
        - Swift.max(
          0,
          (vec[i+188] - vec[i+144] * vec[i+177]) / Overall_harmonious_max_var_cons
            * CCU_harmonious_max_perc * CCU_CO2_nom_prod
        )
      vec[i+203] =
        vec[i+174]
        - Swift.max(
          0,
          (vec[i+187] - vec[i+124]) / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
            * EY_H2_nom_prod
        )
      vec[i+204] =
        vec[i+175]
        - Swift.max(
          0,
          (vec[i+188] - vec[i+144] * vec[i+177]) / Overall_harmonious_max_var_cons
            * EY_harmonious_max_perc * EY_H2_nom_prod
        )
      // vec[i+205]
      vec[i+206] =
        vec[i+141] + vec[i+132] + vec[i+128] - vec[i+28] - vec[i+30] / El_boiler_eff
        - DP3
      vec[i+207] =
        vec[i+141] + vec[i+132] + vec[i+128] - (vec[i+29] + vec[i+31] / El_boiler_eff)
        * vec[i+48] - vec[i+119]
      vec[i+208] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+40]
      vec[i+209] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+41] * vec[i+48]
      vec[i+210] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+30]
      vec[i+211] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+31] * vec[i+48]
      vec[i+212] = vec[i+135] - vec[i+32]
      vec[i+213] = vec[i+135] - vec[i+33] * vec[i+48]
      vec[i+214] = vec[i+137] - vec[i+34]
      vec[i+215] = vec[i+137] - vec[i+35] * vec[i+48]
      vec[i+216] = vec[i+139] - vec[i+36]
      vec[i+217] = vec[i+139] - vec[i+37] * vec[i+48]
      vec[i+218] = iff(
        or(
          vec[i+206] < 0,
          vec[i+208] < 0,
          vec[i+210] < 0,
          vec[i+212] < 0,
          vec[i+214] < 0,
          vec[i+216] < 0
        ),
        0,
        Swift.min(
          iff(
            vec[i+206] <= 0,
            0,
            iff(vec[i+207] >= 0, 1, 1.0 / (vec[i+206] - vec[i+207]) * vec[i+206])
          ),
          iff(
            vec[i+208] <= 0,
            0,
            iff(vec[i+209] >= 0, 1, 1.0 / (vec[i+208] - vec[i+209]) * vec[i+208])
          ),
          iff(
            vec[i+210] <= 0,
            0,
            iff(vec[i+211] >= 0, 1, 1.0 / (vec[i+210] - vec[i+211]) * vec[i+210])
          ),
          iff(
            vec[i+212] <= 0,
            0,
            iff(vec[i+213] >= 0, 1, 1.0 / (vec[i+212] - vec[i+213]) * vec[i+212])
          ),
          iff(
            vec[i+214] <= 0,
            0,
            iff(vec[i+215] >= 0, 1, 1.0 / (vec[i+214] - vec[i+215]) * vec[i+214])
          ),
          iff(
            vec[i+216] <= 0,
            0,
            iff(vec[i+217] >= 0, 1, 1.0 / (vec[i+216] - vec[i+217]) * vec[i+216])
          )
        ) * (B_equiv_harmonious_max_perc * vec[i+48] - B_equiv_harmonious_min_perc)
          + B_equiv_harmonious_min_perc
      )
      vec[i+219] = iff(
        vec[i+218] <= 0,
        0,
        Swift.min(
          1,
          (vec[i+124] + Swift.min(
            vec[i+212] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod,
            vec[i+214] / CCU_harmonious_max_perc / CCU_CO2_nom_prod,
            vec[i+216] / EY_harmonious_max_perc / EY_H2_nom_prod
          ) * Overall_harmonious_max_var_cons) / vec[i+144]
        )
      )
  
      // vec[i+220]
      vec[i+221] = iff(
        vec[i+218] == 0,
        0,
        vec[i+116] - vec[i+38] - Swift.min(
          BESS_capacity,
          (vec[i+28] + vec[i+30] / El_boiler_eff + vec[i+119])
        ) / BESS_charging_eff
      )
      vec[i+222] = iff(
        vec[i+218] == 0,
        0,
        vec[i+116] - vec[i+39] * vec[i+218] - Swift.min(
          BESS_capacity,
          (vec[i+29] + vec[i+31] / El_boiler_eff) * vec[i+218] + vec[i+119]
        ) / BESS_charging_eff
      )
      vec[i+223] = iff(vec[i+218] == 0, 0, vec[i+117] - vec[i+40])
      vec[i+224] = iff(vec[i+218] == 0, 0, vec[i+117] - vec[i+41] * vec[i+218])
      vec[i+225] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+223]) / El_boiler_eff
      vec[i+226] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+224]) / El_boiler_eff
      vec[i+227] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+221])
          + Swift.max(0, -vec[i+223] - vec[i+221] * El_boiler_eff)) / El_boiler_eff
      vec[i+228] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+222])
          + Swift.max(0, -vec[i+224] - vec[i+222] * El_boiler_eff)) / El_boiler_eff
      /*
      vec[i+229] = iff(
        or(vec[i+218] == 0, vec[i+227] < 0),
        0.0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+219],
            vec[i+124]
              + (vec[i+144] * vec[i+219] - vec[i+124])
                * (Swift.max(0, vec[i+221]) + vec[i+227] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+223])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+219] - vec[i+124])
                  + (vec[i+145] * vec[i+219] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+223]) + Swift.min(
                vec[i+225],
                vec[i+221] - vec[i+124] + vec[i+227]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+223]) + Swift.min(
                vec[i+225],
                vec[i+221] - vec[i+124] + vec[i+227]
              ) * El_boiler_eff) / vec[i+125] * vec[i+124]
            )
          )
        )
      )
      vec[i+230] = iff(
        or(vec[i+218] == 0, vec[i+228] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+219],
            vec[i+124]
              + (vec[i+144] * vec[i+219] - vec[i+124])
                * (Swift.max(0, vec[i+222]) + vec[i+228] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+224])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+219] - vec[i+124])
                  + (vec[i+145] * vec[i+219] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+224]) + Swift.min(
                vec[i+226],
                vec[i+222] - vec[i+144] * vec[i+219] + vec[i+228]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+224]) + Swift.min(
                vec[i+226],
                vec[i+222] - vec[i+144] * vec[i+219] + vec[i+228]
              ) * El_boiler_eff) / (vec[i+145] * vec[i+219]) * vec[i+144] * vec[i+219]
            )
          )
        )
      )
       

      vec[i+231] =
        vec[i+229] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+232] =
        vec[i+230] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+233] = iff(
        vec[i+218] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+38] - Swift.min(
            BESS_capacity,
            vec[i+28] + vec[i+30] / El_boiler_eff + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+229] + (Swift.max(0, -vec[i+223] + vec[i+231])) / El_boiler_eff)
      )
      vec[i+234] = iff(
        vec[i+218] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+39] * vec[i+218] - Swift.min(
            BESS_capacity,
            (vec[i+29] + vec[i+31] / El_boiler_eff) * vec[i+218] + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+230] + (Swift.max(0, -vec[i+224] + vec[i+232])) / El_boiler_eff)
      )
      vec[i+235] = Swift.max(0, vec[i+223] - vec[i+231])
      vec[i+236] = Swift.max(0, vec[i+224] - vec[i+232])
      vec[i+237] = iff(
        vec[i+229] <= 0,
        0,
        (vec[i+229] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            vec[i+28] + vec[i+30] / El_boiler_eff + vec[i+119] - BESS_capacity
          ) + Swift.max(0, -vec[i+233])
      )
      vec[i+238] = iff(
        vec[i+230] <= 0,
        0,
        (vec[i+230] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            (vec[i+29] + vec[i+31] / El_boiler_eff) * vec[i+218] + vec[i+119]
              - BESS_capacity
          ) + Swift.max(0, -vec[i+234])
      )
      vec[i+239] = iff(
        vec[i+229] <= 0,
        0,
        vec[i+229] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * B_equiv_harmonious_min_perc * MethDist_Meth_nom_prod
      )
      vec[i+240] = iff(
        vec[i+230] <= 0,
        0,
        vec[i+230] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * B_equiv_harmonious_max_perc * vec[i+218] * MethDist_Meth_nom_prod
      )
      vec[i+241] =
        vec[i+212]
        - Swift.max(
          0,
          (vec[i+229] - vec[i+124]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+242] =
        vec[i+213]
        - Swift.max(
          0,
          (vec[i+230] - vec[i+144] * vec[i+219]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
       
      vec[i+243] =
        vec[i+214]
        - Swift.max(
          0,
          (vec[i+229] - vec[i+124]) / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
            * CCU_CO2_nom_prod
        )
      vec[i+244] =
        vec[i+215]
        - Swift.max(
          0,
          (vec[i+230] - vec[i+144] * vec[i+219]) / Overall_harmonious_max_var_cons
            * CCU_harmonious_max_perc * CCU_CO2_nom_prod
        )
      vec[i+245] =
        vec[i+216]
        - Swift.max(
          0,
          (vec[i+229] - vec[i+124]) / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
            * EY_H2_nom_prod
        )
      vec[i+246] =
        vec[i+217]
        - Swift.max(
          0,
          (vec[i+230] - vec[i+144] * vec[i+219]) / Overall_harmonious_max_var_cons
            * EY_harmonious_max_perc * EY_H2_nom_prod
        )
      // vec[i+247]
      vec[i+248] =
        vec[i+141] + vec[i+132] + vec[i+128] - vec[i+50] - vec[i+52] / El_boiler_eff
        - DP3
      vec[i+249] =
        vec[i+141] + vec[i+132] + vec[i+128] - (vec[i+51] + vec[i+53] / El_boiler_eff)
        * vec[i+70] - vec[i+119]
      vec[i+250] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+62]
      vec[i+251] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+63] * vec[i+70]
      vec[i+252] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+52]
      vec[i+253] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+53] * vec[i+70]
      vec[i+254] = vec[i+135] - vec[i+54]
      vec[i+255] = vec[i+135] - vec[i+55] * vec[i+70]
      vec[i+256] = vec[i+137] - vec[i+56]
      vec[i+257] = vec[i+137] - vec[i+57] * vec[i+70]
      vec[i+258] = vec[i+139] - vec[i+58]
      vec[i+259] = vec[i+139] - vec[i+59] * vec[i+70]
      vec[i+260] = iff(
        or(
          vec[i+248] < 0,
          vec[i+250] < 0,
          vec[i+252] < 0,
          vec[i+254] < 0,
          vec[i+256] < 0,
          vec[i+258] < 0
        ),
        0,
        Swift.min(
          iff(
            vec[i+248] <= 0,
            0,
            iff(vec[i+249] >= 0, 1, 1.0 / (vec[i+248] - vec[i+249]) * vec[i+248])
          ),
          iff(
            vec[i+250] <= 0,
            0,
            iff(vec[i+251] >= 0, 1, 1.0 / (vec[i+250] - vec[i+251]) * vec[i+250])
          ),
          iff(
            vec[i+252] <= 0,
            0,
            iff(vec[i+253] >= 0, 1, 1.0 / (vec[i+252] - vec[i+253]) * vec[i+252])
          ),
          iff(
            vec[i+254] <= 0,
            0,
            iff(vec[i+255] >= 0, 1, 1.0 / (vec[i+254] - vec[i+255]) * vec[i+254])
          ),
          iff(
            vec[i+256] <= 0,
            0,
            iff(vec[i+257] >= 0, 1, 1.0 / (vec[i+256] - vec[i+257]) * vec[i+256])
          ),
          iff(
            vec[i+258] <= 0,
            0,
            iff(vec[i+259] >= 0, 1, 1.0 / (vec[i+258] - vec[i+259]) * vec[i+258])
          )
        ) * (C_equiv_harmonious_max_perc * vec[i+70] - C_equiv_harmonious_min_perc)
          + C_equiv_harmonious_min_perc
      )
      vec[i+261] = iff(
        vec[i+260] <= 0,
        0,
        Swift.min(
          1,
          (vec[i+124] + Swift.min(
            vec[i+254] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod,
            vec[i+256] / CCU_harmonious_max_perc / CCU_CO2_nom_prod,
            vec[i+258] / EY_harmonious_max_perc / EY_H2_nom_prod
          ) * Overall_harmonious_max_var_cons) / vec[i+144]
        )
      )
      // vec[i+262]
      vec[i+263] = iff(
        vec[i+260] == 0,
        0,
        vec[i+116] - vec[i+60] - Swift.min(
          BESS_capacity,
          (vec[i+50] + vec[i+52] / El_boiler_eff + vec[i+119])
        ) / BESS_charging_eff
      )
      vec[i+264] = iff(
        vec[i+260] == 0,
        0,
        vec[i+116] - vec[i+61] * vec[i+260] - Swift.min(
          BESS_capacity,
          (vec[i+51] + vec[i+53] / El_boiler_eff) * vec[i+260] + vec[i+119]
        ) / BESS_charging_eff
      )
      vec[i+265] = iff(vec[i+260] == 0, 0, vec[i+117] - vec[i+62])
      vec[i+266] = iff(vec[i+260] == 0, 0, vec[i+117] - vec[i+63] * vec[i+260])
      vec[i+267] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+265]) / El_boiler_eff
      vec[i+268] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+266]) / El_boiler_eff
      vec[i+269] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+263])
          + Swift.max(0, -vec[i+265] - vec[i+263] * El_boiler_eff)) / El_boiler_eff
      vec[i+270] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+264])
          + Swift.max(0, -vec[i+266] - vec[i+264] * El_boiler_eff)) / El_boiler_eff
      vec[i+271] = iff(
        or(vec[i+260] == 0, vec[i+269] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+261],
            vec[i+124]
              + (vec[i+144] * vec[i+261] - vec[i+124])
                * (Swift.max(0, vec[i+263]) + vec[i+269] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+265])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+261] - vec[i+124])
                  + (vec[i+145] * vec[i+261] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+265]) + Swift.min(
                vec[i+267],
                vec[i+263] - vec[i+124] + vec[i+269]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+265]) + Swift.min(
                vec[i+267],
                vec[i+263] - vec[i+124] + vec[i+269]
              ) * El_boiler_eff) / vec[i+125] * vec[i+124]
            )
          )
        )
      )
      vec[i+272] = iff(
        or(vec[i+260] == 0, vec[i+270] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+261],
            vec[i+124]
              + (vec[i+144] * vec[i+261] - vec[i+124])
                * (Swift.max(0, vec[i+264]) + vec[i+270] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+266])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+261] - vec[i+124])
                  + (vec[i+145] * vec[i+261] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+266]) + Swift.min(
                vec[i+268],
                vec[i+264] - vec[i+144] * vec[i+261] + vec[i+270]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+266]) + Swift.min(
                vec[i+268],
                vec[i+264] - vec[i+144] * vec[i+261] + vec[i+270]
              ) * El_boiler_eff) / (vec[i+145] * vec[i+261]) * vec[i+144] * vec[i+261]
            )
          )
        )
      )
      vec[i+273] =
        vec[i+271] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+274] =
        vec[i+272] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+275] = iff(
        vec[i+260] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+60] - Swift.min(
            BESS_capacity,
            vec[i+50] + vec[i+52] / El_boiler_eff + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+271] + (Swift.max(0, -vec[i+265] + vec[i+273])) / El_boiler_eff)
      )
      vec[i+276] = iff(
        vec[i+260] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+61] * vec[i+260] - Swift.min(
            BESS_capacity,
            (vec[i+51] + vec[i+53] / El_boiler_eff) * vec[i+260] + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+272] + (Swift.max(0, -vec[i+266] + vec[i+274])) / El_boiler_eff)
      )
      vec[i+277] = Swift.max(0, vec[i+265] - vec[i+273])
      vec[i+278] = Swift.max(0, vec[i+266] - vec[i+274])
      vec[i+279] = iff(
        vec[i+271] <= 0,
        0,
        (vec[i+271] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            vec[i+50] + vec[i+52] / El_boiler_eff + vec[i+119] - BESS_capacity
          ) + Swift.max(0, -vec[i+275])
      )
      vec[i+280] = iff(
        vec[i+272] <= 0,
        0,
        (vec[i+272] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            (vec[i+51] + vec[i+53] / El_boiler_eff) * vec[i+260] + vec[i+119]
              - BESS_capacity
          ) + Swift.max(0, -vec[i+276])
      )
      vec[i+281] = iff(
        vec[i+271] <= 0,
        0,
        vec[i+271] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * C_equiv_harmonious_min_perc * MethDist_Meth_nom_prod
      )
      vec[i+282] = iff(
        vec[i+272] <= 0,
        0,
        vec[i+272] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * C_equiv_harmonious_max_perc * vec[i+260] * MethDist_Meth_nom_prod
      )
      vec[i+283] =
        vec[i+254]
        - Swift.max(
          0,
          (vec[i+271] - vec[i+124]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+284] =
        vec[i+255]
        - Swift.max(
          0,
          (vec[i+272] - vec[i+144] * vec[i+261]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+285] =
        vec[i+256]
        - Swift.max(
          0,
          (vec[i+271] - vec[i+124]) / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
            * CCU_CO2_nom_prod
        )
      vec[i+286] =
        vec[i+257]
        - Swift.max(
          0,
          (vec[i+272] - vec[i+144] * vec[i+261]) / Overall_harmonious_max_var_cons
            * CCU_harmonious_max_perc * CCU_CO2_nom_prod
        )
      vec[i+287] =
        vec[i+258]
        - Swift.max(
          0,
          (vec[i+271] - vec[i+124]) / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
            * EY_H2_nom_prod
        )
      vec[i+288] =
        vec[i+259]
        - Swift.max(
          0,
          (vec[i+272] - vec[i+144] * vec[i+261]) / Overall_harmonious_max_var_cons
            * EY_harmonious_max_perc * EY_H2_nom_prod
        )
      // vec[i+289]
      vec[i+290] =
        vec[i+141] + vec[i+132] + vec[i+128] - vec[i+72] - vec[i+74] / El_boiler_eff
        - DP3
      vec[i+291] =
        vec[i+141] + vec[i+132] + vec[i+128] - (vec[i+73] + vec[i+75] / El_boiler_eff)
        * vec[i+92] - vec[i+119]
      vec[i+292] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+84]
      vec[i+293] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+85] * vec[i+92]
      vec[i+294] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+74]
      vec[i+295] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+75] * vec[i+92]
      vec[i+296] = vec[i+135] - vec[i+76]
      vec[i+297] = vec[i+135] - vec[i+77] * vec[i+92]
      vec[i+298] = vec[i+137] - vec[i+78]
      vec[i+299] = vec[i+137] - vec[i+79] * vec[i+92]
      vec[i+300] = vec[i+139] - vec[i+80]
      vec[i+301] = vec[i+139] - vec[i+81] * vec[i+92]
      vec[i+302] = iff(
        or(
          vec[i+290] < 0,
          vec[i+292] < 0,
          vec[i+294] < 0,
          vec[i+296] < 0,
          vec[i+298] < 0,
          vec[i+300] < 0
        ),
        0,
        Swift.min(
          iff(
            vec[i+290] <= 0,
            0,
            iff(vec[i+291] >= 0, 1, 1.0 / (vec[i+290] - vec[i+291]) * vec[i+290])
          ),
          iff(
            vec[i+292] <= 0,
            0,
            iff(vec[i+293] >= 0, 1, 1.0 / (vec[i+292] - vec[i+293]) * vec[i+292])
          ),
          iff(
            vec[i+294] <= 0,
            0,
            iff(vec[i+295] >= 0, 1, 1.0 / (vec[i+294] - vec[i+295]) * vec[i+294])
          ),
          iff(
            vec[i+296] <= 0,
            0,
            iff(vec[i+297] >= 0, 1, 1.0 / (vec[i+296] - vec[i+297]) * vec[i+296])
          ),
          iff(
            vec[i+298] <= 0,
            0,
            iff(vec[i+299] >= 0, 1, 1.0 / (vec[i+298] - vec[i+299]) * vec[i+298])
          ),
          iff(
            vec[i+300] <= 0,
            0,
            iff(vec[i+301] >= 0, 1, 1.0 / (vec[i+300] - vec[i+301]) * vec[i+300])
          )
        ) * (D_equiv_harmonious_max_perc * vec[i+92] - D_equiv_harmonious_min_perc)
          + D_equiv_harmonious_min_perc
      )
      vec[i+303] = iff(
        vec[i+302] <= 0,
        0,
        Swift.min(
          1,
          (vec[i+124] + Swift.min(
            vec[i+296] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod,
            vec[i+298] / CCU_harmonious_max_perc / CCU_CO2_nom_prod,
            vec[i+300] / EY_harmonious_max_perc / EY_H2_nom_prod
          ) * Overall_harmonious_max_var_cons) / vec[i+144]
        )
      )
      // vec[i+304]
      vec[i+305] = iff(
        vec[i+302] == 0,
        0,
        vec[i+116] - vec[i+82] - Swift.min(
          BESS_capacity,
          (vec[i+72] + vec[i+74] / El_boiler_eff + vec[i+119])
        ) / BESS_charging_eff
      )
      vec[i+306] = iff(
        vec[i+302] == 0,
        0,
        vec[i+116] - vec[i+83] * vec[i+302] - Swift.min(
          BESS_capacity,
          (vec[i+73] + vec[i+75] / El_boiler_eff) * vec[i+302] + vec[i+119]
        ) / BESS_charging_eff
      )
      vec[i+307] = iff(vec[i+302] == 0, 0, vec[i+117] - vec[i+84])
      vec[i+308] = iff(vec[i+302] == 0, 0, vec[i+117] - vec[i+85] * vec[i+302])
      vec[i+309] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+307]) / El_boiler_eff
      vec[i+310] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+308]) / El_boiler_eff
      vec[i+311] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+305])
          + Swift.max(0, -vec[i+307] - vec[i+305] * El_boiler_eff)) / El_boiler_eff
      vec[i+312] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+306])
          + Swift.max(0, -vec[i+308] - vec[i+306] * El_boiler_eff)) / El_boiler_eff
      vec[i+313] = iff(
        or(vec[i+302] == 0, vec[i+311] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+303],
            vec[i+124]
              + (vec[i+144] * vec[i+303] - vec[i+124])
                * (Swift.max(0, vec[i+305]) + vec[i+311] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+307])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+303] - vec[i+124])
                  + (vec[i+145] * vec[i+303] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+307]) + Swift.min(
                vec[i+309],
                vec[i+305] - vec[i+124] + vec[i+311]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+307]) + Swift.min(
                vec[i+309],
                vec[i+305] - vec[i+124] + vec[i+311]
              ) * El_boiler_eff) / vec[i+125] * vec[i+124]
            )
          )
        )
      )
      vec[i+314] = iff(
        or(vec[i+302] == 0, vec[i+312] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+303],
            vec[i+124]
              + (vec[i+144] * vec[i+303] - vec[i+124])
                * (Swift.max(0, vec[i+306]) + vec[i+312] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+308])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+303] - vec[i+124])
                  + (vec[i+145] * vec[i+303] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+308]) + Swift.min(
                vec[i+310],
                vec[i+306] - vec[i+144] * vec[i+303] + vec[i+312]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+308]) + Swift.min(
                vec[i+310],
                vec[i+306] - vec[i+144] * vec[i+303] + vec[i+312]
              ) * El_boiler_eff) / (vec[i+145] * vec[i+303]) * vec[i+144] * vec[i+303]
            )
          )
        )
      )
      vec[i+315] =
        vec[i+313] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+316] =
        vec[i+314] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+317] = iff(
        vec[i+302] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+82] - Swift.min(
            BESS_capacity,
            vec[i+72] + vec[i+74] / El_boiler_eff + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+313] + (Swift.max(0, -vec[i+307] + vec[i+315])) / El_boiler_eff)
      )
      vec[i+318] = iff(
        vec[i+302] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+83] * vec[i+302] - Swift.min(
            BESS_capacity,
            (vec[i+73] + vec[i+75] / El_boiler_eff) * vec[i+302] + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+314] + (Swift.max(0, -vec[i+308] + vec[i+316])) / El_boiler_eff)
      )
      vec[i+319] = Swift.max(0, vec[i+307] - vec[i+315])
      vec[i+320] = Swift.max(0, vec[i+308] - vec[i+316])
      vec[i+321] = iff(
        vec[i+313] <= 0,
        0,
        (vec[i+313] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            vec[i+72] + vec[i+74] / El_boiler_eff + vec[i+119] - BESS_capacity
          ) + Swift.max(0, -vec[i+317])
      )
      vec[i+322] = iff(
        vec[i+314] <= 0,
        0,
        (vec[i+314] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            (vec[i+73] + vec[i+75] / El_boiler_eff) * vec[i+302] + vec[i+119]
              - BESS_capacity
          ) + Swift.max(0, -vec[i+318])
      )
      vec[i+323] = iff(
        vec[i+313] <= 0,
        0,
        vec[i+313] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * E_equiv_harmonious_min_perc * MethDist_Meth_nom_prod
      )
      vec[i+324] = iff(
        vec[i+314] <= 0,
        0,
        vec[i+314] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * E_equiv_harmonious_max_perc * vec[i+302] * MethDist_Meth_nom_prod
      )
      vec[i+325] =
        vec[i+296]
        - Swift.max(
          0,
          (vec[i+313] - vec[i+124]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+326] =
        vec[i+297]
        - Swift.max(
          0,
          (vec[i+314] - vec[i+144] * vec[i+303]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+327] =
        vec[i+298]
        - Swift.max(
          0,
          (vec[i+313] - vec[i+124]) / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
            * CCU_CO2_nom_prod
        )
      vec[i+328] =
        vec[i+299]
        - Swift.max(
          0,
          (vec[i+314] - vec[i+144] * vec[i+303]) / Overall_harmonious_max_var_cons
            * CCU_harmonious_max_perc * CCU_CO2_nom_prod
        )
      vec[i+329] =
        vec[i+300]
        - Swift.max(
          0,
          (vec[i+313] - vec[i+124]) / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
            * EY_H2_nom_prod
        )
      vec[i+330] =
        vec[i+301]
        - Swift.max(
          0,
          (vec[i+314] - vec[i+144] * vec[i+303]) / Overall_harmonious_max_var_cons
            * EY_harmonious_max_perc * EY_H2_nom_prod
        )
      
      // vec[i+331]
      vec[i+332] =
        vec[i+141] + vec[i+132] + vec[i+128] - vec[i+94] - vec[i+96] / El_boiler_eff
        - DP3
      vec[i+333] =
        vec[i+141] + vec[i+132] + vec[i+128] - (vec[i+95] + vec[i+97] / El_boiler_eff)
        * vec[i+114] - vec[i+119]
      vec[i+334] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+106]
      vec[i+335] = vec[i+129] + vec[i+133] * El_boiler_eff - vec[i+107] * vec[i+114]
      vec[i+336] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+96]
      vec[i+337] = vec[i+130] + vec[i+134] * El_boiler_eff - vec[i+97] * vec[i+114]
      vec[i+338] = vec[i+135] - vec[i+98]
      vec[i+339] = vec[i+135] - vec[i+99] * vec[i+114]
      vec[i+340] = vec[i+137] - vec[i+100]
      vec[i+341] = vec[i+137] - vec[i+101] * vec[i+114]
      vec[i+342] = vec[i+139] - vec[i+102]
      vec[i+343] = vec[i+139] - vec[i+103] * vec[i+114]
      vec[i+344] = iff(
        or(
          vec[i+332] < 0,
          vec[i+334] < 0,
          vec[i+336] < 0,
          vec[i+338] < 0,
          vec[i+340] < 0,
          vec[i+342] < 0
        ),
        0,
        Swift.min(
          iff(
            vec[i+332] <= 0,
            0,
            iff(vec[i+333] >= 0, 1, 1.0 / (vec[i+332] - vec[i+333]) * vec[i+332])
          ),
          iff(
            vec[i+334] <= 0,
            0,
            iff(vec[i+335] >= 0, 1, 1.0 / (vec[i+334] - vec[i+335]) * vec[i+334])
          ),
          iff(
            vec[i+336] <= 0,
            0,
            iff(vec[i+337] >= 0, 1, 1.0 / (vec[i+336] - vec[i+337]) * vec[i+336])
          ),
          iff(
            vec[i+338] <= 0,
            0,
            iff(vec[i+339] >= 0, 1, 1.0 / (vec[i+338] - vec[i+339]) * vec[i+338])
          ),
          iff(
            vec[i+340] <= 0,
            0,
            iff(vec[i+341] >= 0, 1, 1.0 / (vec[i+340] - vec[i+341]) * vec[i+340])
          ),
          iff(
            vec[i+342] <= 0,
            0,
            iff(vec[i+343] >= 0, 1, 1.0 / (vec[i+342] - vec[i+343]) * vec[i+342])
          )
        ) * (E_equiv_harmonious_max_perc * vec[i+114] - E_equiv_harmonious_min_perc)
          + E_equiv_harmonious_min_perc
      )
      vec[i+345] = iff(
        vec[i+344] <= 0,
        0,
        Swift.min(
          1,
          (vec[i+124] + Swift.min(
            vec[i+338] / MethSynt_harmonious_max_perc / MethSynt_RawMeth_nom_prod,
            vec[i+340] / CCU_harmonious_max_perc / CCU_CO2_nom_prod,
            vec[i+342] / EY_harmonious_max_perc / EY_H2_nom_prod
          ) * Overall_harmonious_max_var_cons) / vec[i+144]
        )
      )
      // vec[i+346]
      vec[i+347] = iff(
        vec[i+344] == 0,
        0,
        vec[i+116] - vec[i+104] - Swift.min(
          BESS_capacity,
          (vec[i+94] + vec[i+96] / El_boiler_eff + vec[i+119])
        ) / BESS_charging_eff
      )
      vec[i+348] = iff(
        vec[i+344] == 0,
        0,
        vec[i+116] - vec[i+105] * vec[i+344] - Swift.min(
          BESS_capacity,
          (vec[i+95] + vec[i+97] / El_boiler_eff) * vec[i+344] + vec[i+119]
        ) / BESS_charging_eff
      )
      vec[i+349] = iff(vec[i+344] == 0, 0, vec[i+117] - vec[i+106])
      vec[i+350] = iff(vec[i+344] == 0, 0, vec[i+117] - vec[i+107] * vec[i+344])
      vec[i+351] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+349]) / El_boiler_eff
      vec[i+352] = vec[i+2] * El_boiler_cap - Swift.max(0, -vec[i+350]) / El_boiler_eff
      vec[i+353] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+347])
          + Swift.max(0, -vec[i+349] - vec[i+347] * El_boiler_eff)) / El_boiler_eff
      vec[i+354] =
        vec[i+2] * grid_max_import
        - (Swift.max(0, -vec[i+348])
          + Swift.max(0, -vec[i+350] - vec[i+348] * El_boiler_eff)) / El_boiler_eff
      vec[i+355] = iff(
        or(vec[i+344] == 0, vec[i+353] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+345],
            vec[i+124]
              + (vec[i+144] * vec[i+345] - vec[i+124])
                * (Swift.max(0, vec[i+347]) + vec[i+353] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+349])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+345] - vec[i+124])
                  + (vec[i+145] * vec[i+345] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+349]) + Swift.min(
                vec[i+351],
                vec[i+347] - vec[i+124] + vec[i+353]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+349]) + Swift.min(
                vec[i+351],
                vec[i+347] - vec[i+124] + vec[i+353]
              ) * El_boiler_eff) / vec[i+125] * vec[i+124]
            )
          )
        )
      )
      vec[i+356] = iff(
        or(vec[i+344] == 0, vec[i+354] < 0),
        0,
        Swift.max(
          vec[i+124],
          Swift.min(
            vec[i+144] * vec[i+345],
            vec[i+124]
              + (vec[i+144] * vec[i+345] - vec[i+124])
                * (Swift.max(0, vec[i+348]) + vec[i+354] - vec[i+124]
                  - (vec[i+125] - Swift.max(0, vec[i+350])) / El_boiler_eff)
                / ((vec[i+144] * vec[i+345] - vec[i+124])
                  + (vec[i+145] * vec[i+345] - vec[i+125]) / El_boiler_eff),
            iff(
              Swift.max(0, vec[i+350]) + Swift.min(
                vec[i+352],
                vec[i+348] - vec[i+144] * vec[i+345] + vec[i+354]
              ) * El_boiler_eff < 0,
              0,
              (Swift.max(0, vec[i+350]) + Swift.min(
                vec[i+352],
                vec[i+348] - vec[i+144] * vec[i+345] + vec[i+354]
              ) * El_boiler_eff) / (vec[i+145] * vec[i+345]) * vec[i+144] * vec[i+345]
            )
          )
        )
      )
      vec[i+357] =
        vec[i+355] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+358] =
        vec[i+356] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        * Overall_harmonious_max_var_heat_cons
      vec[i+359] = iff(
        vec[i+344] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+104] - Swift.min(
            BESS_capacity,
            vec[i+94] + vec[i+96] / El_boiler_eff + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+355] + (Swift.max(0, -vec[i+349] + vec[i+357])) / El_boiler_eff)
      )
      vec[i+360] = iff(
        vec[i+344] == 0,
        0,
        Swift.max(
          0,
          vec[i+116] - vec[i+105] * vec[i+344] - Swift.min(
            BESS_capacity,
            (vec[i+95] + vec[i+97] / El_boiler_eff) * vec[i+344] + vec[i+119]
          ) / BESS_charging_eff
        ) - (vec[i+356] + (Swift.max(0, -vec[i+350] + vec[i+358])) / El_boiler_eff)
      )
      vec[i+361] = Swift.max(0, vec[i+349] - vec[i+357])
      vec[i+362] = Swift.max(0, vec[i+350] - vec[i+358])
      vec[i+363] = iff(
        vec[i+355] <= 0,
        0,
        (vec[i+355] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            vec[i+94] + vec[i+96] / El_boiler_eff + vec[i+119] - BESS_capacity
          ) + Swift.max(0, -vec[i+359])
      )
      vec[i+364] = iff(
        vec[i+356] <= 0,
        0,
        (vec[i+356] - vec[i+124]) / (vec[i+144] - vec[i+124]) * (vec[i+146] - vec[i+126])
          + vec[i+126]
          + Swift.max(
            0,
            (vec[i+95] + vec[i+97] / El_boiler_eff) * vec[i+344] + vec[i+119]
              - BESS_capacity
          ) + Swift.max(0, -vec[i+360])
      )
      vec[i+365] = iff(
        vec[i+355] <= 0,
        0,
        vec[i+355] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * C_equiv_harmonious_min_perc * MethDist_Meth_nom_prod
      )
      vec[i+366] = iff(
        vec[i+356] <= 0,
        0,
        vec[i+356] / Overall_harmonious_max_var_cons * MethDist_Meth_nom_prod + vec[i+1]
          * C_equiv_harmonious_max_perc * vec[i+344] * MethDist_Meth_nom_prod
      )
      vec[i+367] =
        vec[i+338]
        - Swift.max(
          0,
          (vec[i+355] - vec[i+124]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+368] =
        vec[i+339]
        - Swift.max(
          0,
          (vec[i+356] - vec[i+144] * vec[i+345]) / Overall_harmonious_max_var_cons
            * MethSynt_harmonious_max_perc * MethSynt_RawMeth_nom_prod
        )
      vec[i+369] =
        vec[i+340]
        - Swift.max(
          0,
          (vec[i+355] - vec[i+124]) / Overall_harmonious_max_var_cons * CCU_harmonious_max_perc
            * CCU_CO2_nom_prod
        )
      vec[i+370] =
        vec[i+341]
        - Swift.max(
          0,
          (vec[i+356] - vec[i+144] * vec[i+345]) / Overall_harmonious_max_var_cons
            * CCU_harmonious_max_perc * CCU_CO2_nom_prod
        )
      vec[i+371] =
        vec[i+342]
        - Swift.max(
          0,
          (vec[i+355] - vec[i+124]) / Overall_harmonious_max_var_cons * EY_harmonious_max_perc
            * EY_H2_nom_prod
        )
      vec[i+372] =
        vec[i+343]
        - Swift.max(
          0,
          (vec[i+356] - vec[i+144] * vec[i+345]) / Overall_harmonious_max_var_cons
            * EY_harmonious_max_perc * EY_H2_nom_prod
        )
        */
      // vec[i+373]
      vec[i+374] = vec[i+197]
    let Specific_Cost_P5 = 0.0
    let Specific_Cost_P7 = 0.0
let Specific_Cost_P8 = 0.0
let LEC_Calc_AZ3 = 0.0
let LEC_Calc_BA3 = 0.0
var grid_max_export = 70.0

      vec[i+375] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+191]) * Specific_Cost_P8 - vec[i+195]
        * Specific_Cost_P7
      vec[i+376] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+375] * 1000) / vec[i+374],
        0
      )
      vec[i+377] = vec[i+198]
      vec[i+378] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+192]) * Specific_Cost_P8 - vec[i+196]
        * Specific_Cost_P7
      vec[i+379] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+378] * 1000) / vec[i+377],
        0
      )
      vec[i+380] = vec[i+239]
      vec[i+381] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+233]) * Specific_Cost_P8 - vec[i+237]
        * Specific_Cost_P7
      vec[i+382] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+381] * 1000) / vec[i+380],
        0
      )
      vec[i+383] = vec[i+240]
      vec[i+384] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+234]) * Specific_Cost_P8 - vec[i+238]
        * Specific_Cost_P7
      vec[i+385] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+384] * 1000) / vec[i+383],
        0
      )
      vec[i+386] = vec[i+281]
      vec[i+387] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+275]) * Specific_Cost_P8 - vec[i+279]
        * Specific_Cost_P7
      vec[i+388] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+387] * 1000) / vec[i+386],
        0
      )
      vec[i+389] = vec[i+282]
      vec[i+390] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+276]) * Specific_Cost_P8 - vec[i+280]
        * Specific_Cost_P7
      vec[i+391] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+390] * 1000) / vec[i+389],
        0
      )
      vec[i+392] = vec[i+323]
      vec[i+393] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+317]) * Specific_Cost_P8 - vec[i+321]
        * Specific_Cost_P7
      vec[i+394] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+393] * 1000) / vec[i+392],
        0
      )
      vec[i+395] = vec[i+324]
      vec[i+396] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+318]) * Specific_Cost_P8 - vec[i+322]
        * Specific_Cost_P7
      vec[i+397] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+396] * 1000) / vec[i+395],
        0
      )
      vec[i+398] = vec[i+365]
      vec[i+399] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+359]) * Specific_Cost_P8 - vec[i+363]
        * Specific_Cost_P7
      vec[i+400] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+399] * 1000) / vec[i+398],
        0
      )
      vec[i+401] = vec[i+366]
      vec[i+402] =
        Swift.min(vec[i+2] * grid_max_export, vec[i+360]) * Specific_Cost_P8 - vec[i+364]
        * Specific_Cost_P7
      vec[i+403] = ifFinite(
        ((Specific_Cost_P5 * LEC_Calc_AZ3 + LEC_Calc_BA3) / 365 - vec[i+402] * 1000) / vec[i+401],
        0
      )
        
    }
  }
}

