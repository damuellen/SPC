import Foundation
import Utilities

public func fitness(values: [Double]) -> [Double] { fitness(values: values, penalized: false) }
public func fitnessPenalized(values: [Double]) -> [Double] { fitness(values: values, penalized: true) }
func fitness(values: [Double], penalized: Bool) -> [Double] {
  guard let model = TunOl(values) else { return [Double.infinity, 0, 0, 0, 0, 0, 0, 0] + values }

  var hourPre = [Double](repeating: 0.0, count: 1103760)
  var hourFinal = [Double](repeating: 0.0, count: 534360)
  var d10 = [Double](repeating: 0.0, count: 97_090)
  var d23 = [Double](repeating: 0.0, count: 48_545)
  var d21 = [Double](repeating: 0.0, count: 9_855)
  var day = [[Double]]()
  let (HC, HE, HF) = (18615, 18980, 19345)
  let (IY, KA) = (35405, 45260)
  let (MC, MI, NL, NR) = (81030, 83220, 93805, 95995)

  model.hour(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet, hour: &hourPre)
  let day20 = model.day20(hour: hourPre)
  let d22 = model.d22(hour: hourPre, d20: day20)

  model.hour1(&hourPre, reserved: model.Overall_harmonious_min_perc)
  
  for j in 0..<4 {
    model.hour2(&hourPre, case: j)
    model.hour3(&hourPre, case: j)
    model.d10(&d10, hour: hourPre, case: j)
    model.hourFinal(&hourFinal, d1: d10, hour: hourPre, case: j)
    model.night(&d10, hour4: hourFinal, case: j)
    model.d11(&d10, hour: hourPre, case: j)
    model.d12(&d10, hourFinal: hourFinal, case: j)
    model.d13(&d10, case: j)
    model.d14(&d10, case: j)
    day.append(Array(d10[MC..<MI]))
    day.append(Array(d10[NL..<NR]))
    model.d21(&d21, case: j, day0: day20)
    model.d23(&d23, case: j, day0: day20, d21: d21, d22: d22)
    let a = zip(day20[365..<730], d23[HC..<HE]).map { $1 > 0 ? $0 : 0 }
    day.append(Array(d23[IY..<IY+1095] + ArraySlice(a) + day20[730..<1095]))
    let b = zip(day20[365..<730], d23[HE..<HF]).map { $1 > 0 ? $0 : 0 }
    day.append(Array(d23[KA..<KA+1095] + ArraySlice(b) + day20[730..<1095]))
  }

  var meth_produced_MTPH_sum = Double.zero
  var elec_from_grid_sum = Double.zero
  var elec_to_grid_MTPH_sum = Double.zero
  var hours_sum = Double.zero
  let costs = Costs(model)

  for d in 0..<365 {
    let cases = day.map { values in 
      costs.LCOM(meth_produced_MTPH: values[d] * 365.0, elec_from_grid: values[d + 730] * 365.0, elec_to_grid: values[d + 365] * 365.0)
    }
    let ranked = cases.indices.sorted { cases[$0] < cases[$1] }
    if let best = ranked.first {
      let meth_produced_MTPH = day[best][d]
      meth_produced_MTPH_sum += meth_produced_MTPH
      let to_grid = day[best][d + 365]
      elec_to_grid_MTPH_sum += to_grid
      let from_grid = day[best][d + 730]
      elec_from_grid_sum += from_grid
      let hours0 = day[best][d + 1095]
      let hours1 = day[best][d + 1460]
      hours_sum += hours0 + hours1
    }
  }

  let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
  let fitness: Double
  if penalized {
   fitness = LCOM * (1.0 + (abs(min(hours_sum - 7000.0, 0)) / 1000.0) * 0.3) * (1.0 + (abs(min(meth_produced_MTPH_sum - 100000.0, Double.zero)) / 10000.0) * 0.3)
  } else {
   fitness = LCOM * (1.0 + (pow(meth_produced_MTPH_sum / 100000.0 - 1, 2) * 2))
  }
  if LCOM.isInfinite || meth_produced_MTPH_sum.isZero { return [Double.infinity] }
  return [fitness, LCOM, costs.Total_CAPEX, costs.Total_OPEX, meth_produced_MTPH_sum, elec_from_grid_sum, elec_to_grid_MTPH_sum, hours_sum] + model.values
}
