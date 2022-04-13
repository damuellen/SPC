import Foundation
import Utilities

public func fitness(values: [Double]) -> [Double] {
  guard let model = TunOl(values) else { return [Double.infinity] + values }
  let costs = Costs(model)
  //dump(costs)
  //TunOl.Grid_import_yes_no_BESS_strategy = 0
  //TunOl.Grid_import_yes_no_PB_strategy = 0
  //dump(model)
  let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
  let hour1 = model.hour1(hour0: hour0)
  let day0 = model.day0(hour0: hour0)
  let day6 = model.day26(hour0: hour0)
  var day = [[Double]]()

  var hour2 = [Double](repeating: .zero, count: 183_960)
  var hour3 = [Double](repeating: .zero, count: 271_560)
  var hour4 = [Double](repeating: .zero, count: 490560 + 8760)
  var day1 = [Double](repeating: .zero, count: 13_140)
  var day15 = [Double](repeating: .zero, count: 17_155)
  var day16 = [Double](repeating: .zero, count: 17_155)
  var day17 = [Double](repeating: .zero, count: 46_720)
  var day27 = [Double](repeating: .zero, count: 47_815)
  var day21 = [Double](repeating: .zero, count: 9_855)

  for j in 0..<4 {
    model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
    model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    model.day1(&day1, case: j, hour2: hour2, hour3: hour3)
    model.hour4(&hour4, j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
    model.day15(&day15, hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
    model.day16(&day16, hour0: hour0, hour4: hour4, day11: day1, day15: day15)
    model.day17(&day17, case: j, day1: day1, day5: day15, day6: day16)

    day.append(Array(day17[31755..<32850]))
    day.append(Array(day17[44165..<45625]))

    model.day21(&day21, case: j, day0: day0)
    model.day27(&day27, case: j, day0: day0, day1: day21, day6: day6)

    day.append(Array(day27[33945..<35040]))
    day.append(Array(day27[44895..<45990]))
  }

  var meth_produced_MTPH_sum = Double.zero
  var elec_from_grid_sum = Double.zero
  var elec_to_grid_MTPH_sum = Double.zero
  var counter = 365
  for d in 0..<365 {
    let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
    let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted { cases[$0] < cases[$1] }.first
    if let best = best {
      counter -= 1
      meth_produced_MTPH_sum += day[best][d]
      elec_from_grid_sum += day[best][d + 365 + 365]
      elec_to_grid_MTPH_sum += day[best][d + 365]
    }
  }
  let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
  if counter > 100 || LCOM < 666 || LCOM.isInfinite || meth_produced_MTPH_sum.isZero { return [Double.infinity] + values }
  return [LCOM] + values
}
