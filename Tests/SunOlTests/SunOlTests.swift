import Utilities
import XCTest
import xlsxwriter

@testable import SunOl

class SunOlTests: XCTestCase {
  func testsCalculation() {
    let path = "/workspaces/SPC/input2.txt"
    guard let csv = CSV(atPath: path) else {
      print("No input.")
      return
    }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]
    let model = TunOl([])
    let hour0 = model.hour0(
      TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
    print("Calculation")
    Array(hour0[..<61320]).head(6, steps: 8760)
    print("Calculation")
    Array(hour0[61320..<113880]).head(14, steps: 8760)
    print("Calculation")

    let hour1 = model.hour1(hour0: hour0)
    print("Calculation")
    hour1.head(47, steps: 8760)

    let day6 = model.day(hour0: hour0)
    print("Daily 2")
    Array(day6[0..<5840]).head(121, steps: 365)
    print("Daily 2")
    Array(day6[5840...]).head(137, steps: 365)

    var day = [[Double]]()

    var hour2 = [Double](repeating: Double.zero, count: 166440 + 8760)
    var hour3 = [Double](repeating: Double.zero, count: 271_560)
    var hour4 = [Double](repeating: Double.zero, count: 490560 + 8760)
    var day1 = [Double](repeating: Double.zero, count: 13_140)
    var day15 = [Double](repeating: Double.zero, count: 17_155)
    var day16 = [Double](repeating: Double.zero, count: 17_155)
    var day17 = [Double](repeating: Double.zero, count: 46_720)
    var day27 = [Double](repeating: Double.zero, count: 45990 + 365)
    var day21 = [Double](repeating: Double.zero, count: 9_855)

    for j in 0..<4 {

      model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
      if j == 0 {
        print("Hour Case", j)
        hour2.head(72, steps: 8760)
      }
      if j == 1 {
        print("Hour Case", j)
        hour2.head(184, steps: 8760)
      }
      if j == 2 {
        print("Hour Case", j)
        hour2.head(296, steps: 8760)
      }

      model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
      print("Hour Case", j)
      hour3.head(93, steps: 8760)

      model.day1(&day1, case: j, hour2: hour2, hour3: hour3)

      model.hour4(&hour4, j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
      print("Hour Case", j)
      Array(hour4[0..<227760]).head(125, steps: 8760)
      Array(hour4[227760...]).head(152, steps: 8760)

      model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
      print("Daily Case", j)
      Array(day1[0..<5840]).head(2, steps: 365)
      print("Daily Case", j)
      Array(day1[5840...]).head(19, steps: 365)

      model.day15(&day15, hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
      if j == 0 {
        print("Daily Case", j)
        Array(day15[0..<9125]).head(154, steps: 365)
        print("Daily Case", j)
        Array(day15[9125...]).head(179, steps: 365)
      }
      if j == 1 {
        print("Daily Case", j)
        Array(day15[0..<9125]).head(376, steps: 365)
        print("Daily Case", j)
        Array(day15[9125...]).head(401, steps: 365)
      }

      model.day16(&day16, hour0: hour0, hour4: hour4, day11: day1, day15: day15)
      print("Daily 1 Case", j)
      Array(day16[..<9125]).head(202, steps: 365)
      print("Daily 1 Case", j)
      Array(day16[9125...]).head(227, steps: 365)

      if j == 0 {

      }

      model.day17(&day17, case: j, day1: day1, day5: day15, day6: day16)
      if j == 0 {
        print("Daily 1 Case", j)
        Array(day17[..<7665]).head(250, steps: 365)
        print("Daily 1 Case", j)
        Array(day17[7665..<13505]).head(272, steps: 365)
        print("Daily 1 Case", j)
        Array(day17[13505..<19345]).head(289, steps: 365)
        print("Daily 1 Case", j)
        Array(day17[19345..<31755]).head(306, steps: 365)
        print("Daily 1 Case", j)
        Array(day17[31755...]).head(341, steps: 365)
      }

      if j == 0 {

      }

      if j == 1 {

      }
      if j == 2 {

      }

      if j == 3 {

      }

      day.append(Array(day17[31755..<33215]))
      day.append(Array(day17[44165..<45625]))

      let day0 = model.day0(hour0: hour0)
      model.day21(&day21, case: j, day0: day0)
      print("Daily 2 Case", j)
      Array(day21[0..<6935]).head(0, steps: 365)
      print("Daily 2 Case", j)
      Array(day21[6935...]).head(19, steps: 365)

      model.day27(&day27, case: j, day0: day0, day1: day21, day6: day6)
      print("Daily 2 Case", j)
      Array(day27[..<9855]).head(121, steps: 365)
      print("Daily 2 Case", j)
      Array(day27[9855..<17155]).head(148, steps: 365)
      print("Daily 2 Case", j)
      Array(day27[17155..<24090]).head(168, steps: 365)
      print("Daily 2 Case", j)
      Array(day27[24090..<31755]).head(188, steps: 365)
      print("Daily 2 Case", j)
      Array(day27[31755..<38690]).head(206, steps: 365)
      print("Daily 2 Case", j)
      Array(day27[38690...]).head(242, steps: 365)

      day.append(Array(day27[33945..<35040]))
      day.append(Array(day27[44895..<45990]))
    }

    let costs = Costs(model)
    var meth_produced_MTPH_sum = Double.zero
    var elec_from_grid_sum = Double.zero
    var elec_to_grid_MTPH_sum = Double.zero

    for d in 0..<365 {
      let cases = day.indices.map { i in
        costs.LCOM(meth_produced_MTPH: day[i][d], elec_from_grid: day[i][d + 365], elec_to_grid: day[i][d + 365 + 365])
      }
      print(cases)
      let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted().first
      if let best = best {
        meth_produced_MTPH_sum += day[best][d]
        elec_from_grid_sum += day[best][d + 365]
        elec_to_grid_MTPH_sum += day[best][d + 365 + 365]
      }
    }
    let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
    print(LCOM)
  }
}
