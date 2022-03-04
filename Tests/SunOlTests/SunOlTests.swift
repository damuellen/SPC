import XCTest
import xlsxwriter
@testable import SunOl
import Utilities

class SunOlTests: XCTestCase {
  func testsCalculation() {
    let path = "/workspaces/SPC/input.txt"
    guard let csv = CSV(atPath: path) else { print("No input."); return }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

  let model = TunOl([])
  let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
  // hour0.head(8, steps: 8760)
  let hour1 = model.hour1(hour0: hour0)
  // hour1.head(48, steps: 8760)
  let day6 = model.day(hour0: hour0)
  var day = [[Double]]()

  let dayLVstart = 29200
  let dayMBend = 31390 + 365
  let dayNEstart = 41610
  let dayNKend = 43800 + 365

  let dayIPstart = 32120
  let dayIXend = 35040 + 365
  let dayJUstart = 43070
  let dayKCend = 45990 + 365

  for j in 0..<4 {
    let hour2 = model.hour2(j: j, hour0: hour0, hour1: hour1)
    let hour3 = model.hour3(j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    var day1 = model.day(case: j, hour2: hour2, hour3: hour3)
    let hour4 = model.hour4(j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
    let day15 = model.day(hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
    let day16 = model.day(hour0: hour0, hour4: hour4, day11: day1, day15: day15)
    let day17 = model.day(case: j, day1: day1, day5: day15, day6: day16)

    day.append(Array(day17[dayLVstart..<dayMBend]))
    day.append(Array(day17[dayNEstart..<dayNKend]))

    let day21 = model.day(case: j, hour0: hour0)     
    let day27 = model.day(case: j, day1: day21, day6: day6)

    day.append(Array(day27[dayIPstart..<dayIXend]))
    day.append(Array(day27[dayJUstart..<dayKCend]))
  }
  }
}

