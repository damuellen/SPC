import Utilities

extension TunOl {

  mutating func hourly(
    _ Q_Sol_MW_thLoop: [Double],
    _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double],
    _ Reference_PV_MV_power_at_transformer_outlet: [Double]
  ) {
    let Day = (0..<365).flatMap { Array(repeating: Double($0), count: 24) }
    let Heater_eff = 0.99
    let El_boiler_eff = 0.99
    let Ratio_CSP_vs_Heater = 1.315007
    let range = 0..<8760
    let zeroes = Array(repeating: 0.0, count: range.count)
    let indices = Reference_PV_MV_power_at_transformer_outlet.indices
    let CSP = Q_Sol_MW_thLoop.map { $0 * CSP_loop_nr_ud }
    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    let Inverter_power_fraction =
      Reference_PV_MV_power_at_transformer_outlet.map { max(0, $0 / maximum) }
    let Inverter_eff = indices.map {
      return iff(
        Reference_PV_MV_power_at_transformer_outlet[$0] < maximum,
        max(Reference_PV_MV_power_at_transformer_outlet[$0], 0)
          / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0)
    }
    let inverter = zip(Inverter_power_fraction, Inverter_eff)
      .filter { $0.0 > 0 && $0.0 < 1 }.sorted(by: { $0.0 < $1.0 })
    let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
    let eff1 = chunks.map { bin in
      bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count)
    }
    let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1)
      .map { PV_AC_cap_ud * $0.0 / $0.1 / PV_DC_cap_ud }
    let LL = Polynomial.fit(
      x: Array(eff2[...20]), y: Array(eff1[...20]), order: 6)!
    let ML = Polynomial.fit(
      x: Array(eff2[8...22]), y: Array(eff1[8...22]), order: 3)!
    let HL = Polynomial.fit(
      x: Array(eff2[20...]), y: Array(eff1[20...]), order: 4)!
    let E_PV_total_Scaled_DC =
      Reference_PV_plant_power_at_inverter_inlet_DC.map {
        $0 * PV_DC_cap_ud / PV_Ref_DC_cap
      }
    let PV_MV_power_at_transformer_outlet: [Double] = indices.map {
      let load = E_PV_total_Scaled_DC[$0] / PV_DC_cap_ud
      let value: Double
      if load > 0.2 {
        value = E_PV_total_Scaled_DC[$0] * HL(load)
      } else if load > 0.1 {
        value = E_PV_total_Scaled_DC[$0] * ML(load)
      } else if load > 0 {
        value = E_PV_total_Scaled_DC[$0] * LL(load)
      } else {
        value =
          Reference_PV_MV_power_at_transformer_outlet[$0] / PV_Ref_AC_cap
          * PV_AC_cap_ud
      }
      return min(PV_AC_cap_ud, value)
    }
    let auxElecForPBStby_CSPSFAndPVPlantMWel: [Double] = indices.map {
      i -> Double in
      iff(CSP[i] > 0, CSP[i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons)
        + max(0, -PV_MV_power_at_transformer_outlet[i]) + PB_stby_aux_cons
    }
    let availablePVPowerMWel: [Double] = indices.map { i -> Double in
      max(
        0,
        PV_MV_power_at_transformer_outlet[i]
          - auxElecForPBStby_CSPSFAndPVPlantMWel[i])
    }
    let pvDayRanges = Array(
      E_PV_total_Scaled_DC.indices.chunked(by:) {
        !(E_PV_total_Scaled_DC[$0] == 0.0 && E_PV_total_Scaled_DC[$1] > 0.0)
      })
    let day =
      [0]
      + pvDayRanges.indices.flatMap { i in
        Array(repeating: i, count: pvDayRanges[i].count)
      }
    let pvDays = pvDayRanges.map { r in
      Array(PV_MV_power_at_transformer_outlet[r])
    }
    let pvDayStats: [(Double, Double, Double)] = pvDays.map { day in
      let n = day.reduce(into: 0) { counter, value in
        if value > 0 { counter += 1 }
      }
      return (sum(day[0...]), Double(n), Double(day.count) - Double(n))
    }
  }
}

extension TunOl {
  var L: [Double] { [0] }
  var M: [Double] { [0] }
  var CSP: [Double] { [0] }
  
}

func POLY(_ value: Double, _ coeffs: [Double]) -> Double { 
  coeffs.reversed().reduce(into: 0.0) { result, coefficient in
    result = coefficient.addingProduct(result, value)
  }
}