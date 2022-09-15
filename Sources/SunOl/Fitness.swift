import Foundation
import Utilities

public func fitness(values: [Double]) -> [Double] {
  guard let model = TunOl(values) else { return [Double.infinity, 0, 0, 0, 0, 0, 0, 0] + values }

  var hour = [Double](repeating: 0.0, count: 1033680)
  var hour4 = [Double](repeating: 0.0, count: 516_840)
  var d10 = [Double](repeating: 0.0, count: 13_140)
  var d11 = [Double](repeating: 0.0, count: 17_155)
  var d12 = [Double](repeating: 0.0, count: 17_155)
  var d13 = [Double](repeating: 0.0, count: 47_085)
  var d23 = [Double](repeating: 0.0, count: 48_545)
  var d21 = [Double](repeating: 0.0, count: 9_855)
  var day = [[Double]]()
  let GX = 16790
  let GZ = 17155
  let HA = 17520

  var flip = true
  model.hour(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet, hour: &hour)
  let d22 = model.d22(hour: hour)

  let step = (model.Overall_harmonious_max_perc - model.Overall_harmonious_min_perc) / 4
  var reserve = model.Overall_harmonious_min_perc

  // while reserve < model.Overall_harmonious_max_perc {
  model.hour1(&hour, reserved: reserve)
  let day0 = model.day0(hour: hour)

  for j in 0..<4 {
    model.hour2(&hour, j: j)
    model.hour3(&hour, j: j)
    model.d10(&d10, case: j, hour: hour)
    model.hour4(&hour4, j: j, d1: d10, hour: hour)
    model.night(case: j, d10: &d10, hour4: hour4)
    model.d11(case: j, &d11, hour: hour)
    model.d12(case: j, &d12, hour: hour, hour4: hour4)
    model.d13(&d13, case: j, d10: d10, d11: d11, d12: d12)
    model.d14(&d13, case: j, d10: d10, d11: d11, d12: d12)
    day.append(Array(d13[31755..<33945]))
    day.append(Array(d13[44165..<46355]))
    if flip {
      model.d21(&d21, case: j, day0: day0)
      model.d23(&d23, case: j, day0: day0, d21: d21, d22: d22)
      day.append(Array(d23[33945..<35040] + ArraySlice(zip(day0[365..<730], d23[GX..<GZ]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
      day.append(Array(d23[44895..<45990] + ArraySlice(zip(day0[365..<730], d23[GZ..<HA]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
    }
  }
  flip = false
  reserve += step
  // }

  var meth_produced_MTPH_sum = Double.zero
  var elec_from_grid_sum = Double.zero
  var elec_to_grid_MTPH_sum = Double.zero
  var hours_sum = Double.zero
  let costs = Costs(model)
  var meth = [Double]()

  for d in 0..<365 {
    let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
    let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted { cases[$0] < cases[$1] }.first
    if let best = best {
      meth.append(day[best][d])
      meth_produced_MTPH_sum += day[best][d]
      let from_grid = day[best][d + 365 + 365]
      elec_from_grid_sum += from_grid
      elec_to_grid_MTPH_sum += day[best][d + 365]
      let hours0 = day[best][d + 730 + 365]
      let hours1 = day[best][d + 730 + 730]
      hours_sum += hours0 + hours1
    }
  }

  let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
  let fitness = LCOM * (1.0 + (abs(min(hours_sum - 7000.0, 0)) / 1000.0) * 0.3) * (1.0 + (abs(min(meth_produced_MTPH_sum - 100000.0, 0.0)) / 10000.0) * 0.3)
  if !meth.drop(while: { $0 < meth_produced_MTPH_sum / 100 }).isEmpty || LCOM.isInfinite || meth_produced_MTPH_sum.isZero { return [Double.infinity] }
  return [fitness, LCOM, costs.Total_CAPEX, costs.Total_OPEX, meth_produced_MTPH_sum, elec_from_grid_sum, elec_to_grid_MTPH_sum, hours_sum] + model.values
}
