import Foundation
import Utilities

public func fitness(values: [Double]) -> [Double] {
  guard let model = TunOl(values) else { return [Double.infinity] }
  let costs = Costs(model)
  //dump(costs)
  //TunOl.Grid_import_yes_no_BESS_strategy = 0
  //TunOl.Grid_import_yes_no_PB_strategy = 0
  //dump(model)
  let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
  let hour1 = model.hour1(hour0: hour0)
  let day0 = model.day0(hour0: hour0)
  let d22 = model.d22(hour0: hour0)
  var day = [[Double]]()

  var hour2 = [Double](repeating: .zero, count: 183_960)
  var hour3 = [Double](repeating: .zero, count: 289_080)
  var hour4 = [Double](repeating: .zero, count: 516_840)
  var d10 = [Double](repeating: .zero, count: 13_140)
  var d11 = [Double](repeating: .zero, count: 17_155)
  var d12 = [Double](repeating: .zero, count: 17_155)
  var d13 = [Double](repeating: .zero, count: 47_085) 
  var d23 = [Double](repeating: .zero, count: 47_815)
  var d21 = [Double](repeating: .zero, count: 9_855)
  
  for j in 0..<4 {
    model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
    model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    model.d10(&d10, case: j, hour2: hour2, hour3: hour3)
    model.hour4(&hour4, j: j, d1: d10, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, d10: &d10, hour3: hour3, hour4: hour4)
    model.d11(&d11, hour0: hour0, hour2: hour2, hour3: hour3)
    model.d12(&d12, hour0: hour0, hour4: hour4)
    model.d13(&d13, case: j, d10: d10, d11: d11, d12: d12)
    model.d14(&d13, case: j, d10: d10, d11: d11, d12: d12)
    day.append(Array(d13[31755..<32850]))
    day.append(Array(d13[44165..<45625]))

    model.d21(&d21, case: j, day0: day0)
    model.d23(&d23, case: j, day0: day0, d21: d21, d22: d22)

    day.append(Array(d23[33945..<35040]))
    day.append(Array(d23[44895..<45990]))
  }

  var meth_produced_MTPH_sum = Double.zero
  var elec_from_grid_sum = Double.zero
  var elec_to_grid_MTPH_sum = Double.zero

  var meth = [Double]()
  for d in 0..<365 {
    let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
    let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted { cases[$0] < cases[$1] }.first
    if let best = best {
      meth.append(day[best][d])
      meth_produced_MTPH_sum += day[best][d]
      elec_from_grid_sum += day[best][d + 365 + 365]
      elec_to_grid_MTPH_sum += day[best][d + 365]
    }
  }
  
  let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
  if !meth.drop(while: { $0 < meth_produced_MTPH_sum / 100 }).isEmpty || LCOM.isInfinite || meth_produced_MTPH_sum.isZero { return [Double.infinity] }
  return [LCOM, costs.Total_CAPEX, costs.Total_OPEX, meth_produced_MTPH_sum, elec_from_grid_sum, elec_to_grid_MTPH_sum] + model.values
}
