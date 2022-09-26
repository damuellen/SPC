import Utilities
import XCTest
import xlsxwriter

@testable import SunOl

class SunOlTests: XCTestCase {
  override func setUp() {
    let path = "input3.txt"
    guard let csv = CSVReader(atPath: path) else {
      print("No input")
      return
    }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]
  }

  func testsCalculation() {
    guard 
    let csv_ref = CSVReader(atPath: "calc.csv", separator: "\t"),
    let csv_ref2 = CSVReader(atPath: "daily1.csv", separator: "\t")
    // let csv_ref3 = CSVReader(atPath: "daily2.csv", separator: "\t")
    else {
      print("No input")
      return
    }

    func calculation(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref[letter], column = Array(array[index..<index + 8760])
      var correct = true, counter = 1
      for i in 1..<8700 {
        if counter > 20 { break }
        if abs(abs(ref[i - 1]) - abs(column[i])) > 0.2 {
          counter += 1; correct = false
          print("Calculation \(letter)\(i + 4) proper value: \(String(format: "%.2f", ref[i - 1])) [\(index + i)] \(String(format: "%.2f", column[i]))  div: \(abs(ref[i - 1]) - abs(column[i]))")
        }
      }
      if correct { print("Calculation \(letter) is correct") } else { XCTFail("Error in Calculation Column \(letter)") }
    }

    func daily1(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref2[letter]
      var correct = true, counter = 1
      for i in 0..<364 {
        if counter > 20 { break }
        if abs(ref[i]) - abs(array[index + i]) > 0.2 {
          counter += 1; correct = false
          print("Daily1 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
        }
      }
      if correct { print("Daily1 \(letter) is correct") } else { XCTFail("Error in Daily1 Column \(letter)") }
    }

    func daily2(_ array: [Double], _ letter: String, _ index: Int) {
      // let index = index, ref = csv_ref3[letter]
      // var correct = true, counter = 1
      // for i in 0..<364 {
      //   if counter > 20 { break }
      //   if abs(ref[i]) - abs(array[index + i]) > 0.2 {
      //     counter += 1; correct = false
      //     print("Daily2 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
      //   }
      // }
      // if correct { print("Daily2 \(letter) is correct") } else { XCTFail("Error in Daily2 Column \(letter)") }
    }
    
    func column(_ i: Int, offset: Int, stride: Int = 365) -> (String, Int) {
      let A = UnicodeScalar("A").value
      let num = (i - offset) * stride
      let z = i.quotientAndRemainder(dividingBy: 676)
      let w = z.quotient > 0 ? String(UnicodeScalar(A + UInt32(z.quotient-1))!) : ""
      let i = z.remainder.quotientAndRemainder(dividingBy: 26)
      let q = i.quotient > 0 ? String(UnicodeScalar(A + UInt32(i.quotient-1))!) : ""
      let key = w + q + String(UnicodeScalar(A + UInt32(i.remainder))!)
      return (key, num)
    }

    let values = [176.00,4000.00,280.00,560.10,733.94,280.00,0.00,0.00,2000.00,200000.00,200000.00,64.96,60.00,0.00,0.00,0.00]
    guard let model = TunOl(values) else {
      print("Invalid config")
      return
    }

    var hourPre = [Double](repeating: 0.0, count: 1_033_680)
    var hourFinal = [Double](repeating: 0.0, count: 516_840)
    var d10 = [Double](repeating: 0.0, count: 94_170)
    var d23 = [Double](repeating: 0.0, count: 48_545)
    var d21 = [Double](repeating: 0.0, count: 9_855)
    var day = [[Double]]()
    let GX = 16790
    let GZ = 17155
    let HA = 17520

    var flip = true
    model.hour(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet, hour: &hourPre)
    let d22 = model.d22(hour: hourPre)

    let step = (model.Overall_harmonious_max_perc - model.Overall_harmonious_min_perc) / 4
    var reserve = model.Overall_harmonious_min_perc

    model.hour1(&hourPre, reserved: reserve)
    let day0 = model.day0(hour: hourPre)

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
      day.append(Array(d10[79205..<81395]))
      day.append(Array(d10[91980..<93805]))
      if flip {
        model.d21(&d21, case: j, day0: day0)
        model.d23(&d23, case: j, day0: day0, d21: d21, d22: d22)
        day.append(Array(d23[33945..<35040] + ArraySlice(zip(day0[365..<730], d23[GX..<GZ]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
        day.append(Array(d23[44895..<45990] + ArraySlice(zip(day0[365..<730], d23[GZ..<HA]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
      }
      if j == 0 {
        (7..<71).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        (71..<91).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        (91..<124).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        (125..<183).map { column($0, offset: 125, stride: 8760) }.forEach { letter, offset in calculation(hourFinal, letter, offset) }
        (2..<11).map { column($0, offset: 2) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (19..<35).map { column($0, offset:3) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (154..<201).map { column($0, offset:122) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (202..<249).map { column($0, offset: 123) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (250..<312).map { column($0, offset: 124) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (313..<381).map { column($0, offset: 123) }.forEach { letter, offset in daily1(d10, letter, offset) }
        (4..<30).map { column($0, offset: 4) }.forEach { letter, offset in daily2(d21, letter, offset) }        
        (158..<288).map { column($0, offset: 158) }.forEach { letter, offset in daily2(d23, letter, offset) }
      }
      if j == 1 {
        (184..<204).map { column($0, offset: 7 - (72 - 184), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
      }
      if j == 2 {
        (296..<316).map { column($0, offset: 7 - (72 - 296), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
      }
      if j == 3 {
        (408..<428).map { column($0, offset: 7 - (72 - 408), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
      }
    }
    flip = false
    reserve += step

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

  }

  func testsCalculation2() {
    let values = [178,6294,220,645,954,200,0.00,421,1000.00,100000.00,100000.00,21,12,0.00,0.00,0.00]
    guard let model = TunOl(values) else {
      print("Invalid config")
      return
    }

    let costs = Costs(model)
    var hourPre = [Double](repeating: 0.0, count: 1_033_680)
    var hourFinal = [Double](repeating: 0.0, count: 516_840)
    var d10 = [Double](repeating: 0.0, count: 82_490)
    var d23 = [Double](repeating: 0.0, count: 48_545)
    var d21 = [Double](repeating: 0.0, count: 9_855)
    var day = [[Double]]()
    let GX = 16790
    let GZ = 17155
    let HA = 17520

    var flip = true
    model.hour(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet, hour: &hourPre)
    let d22 = model.d22(hour: hourPre)

    let step = (model.Overall_harmonious_max_perc - model.Overall_harmonious_min_perc) / 4
    var reserve = model.Overall_harmonious_min_perc

    model.hour1(&hourPre, reserved: reserve)
    let day0 = model.day0(hour: hourPre)

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
      day.append(Array(d10[67525..<69715]))
      day.append(Array(d10[80300..<82490]))
      if flip {
        model.d21(&d21, case: j, day0: day0)
        model.d23(&d23, case: j, day0: day0, d21: d21, d22: d22)
        day.append(Array(d23[33945..<35040] + ArraySlice(zip(day0[365..<730], d23[GX..<GZ]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
        day.append(Array(d23[44895..<45990] + ArraySlice(zip(day0[365..<730], d23[GZ..<HA]).map { $1 > 0 ? $0 : 0 }) + day0[730..<1095]))
      }
    }
    flip = false
    reserve += step

    var meth_produced_MTPH_sum = Double.zero
    var elec_from_grid_sum = Double.zero
    var elec_to_grid_MTPH_sum = Double.zero

    let name = [
      "1a day prio", "1a night prio", "2a day prio", "2a night prio", "1b day prio", "1b night prio", "2b day prio", "2b night prio", "1c day prio", "1c night prio",
      "2c day prio", "2c night prio", "1d day prio", "1d night prio", "2d day prio", "2d night prio",
    ]
    var charts = [Int]()
    var hours_sum = 0.0
    var outputStream = ""
    for child in Mirror(reflecting: model).children.filter({ $0.label?.contains("_ud") ?? false }) { print(child.label!, child.value as! Double, to: &outputStream) }
    for d in 0..<365 {
      let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
      let ranked = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted { cases[$0] < cases[$1] }
      if let best = ranked.first {
        charts.append(best)
        meth_produced_MTPH_sum += day[best][d]
        let from_grid = day[best][d + 365 + 365]
        elec_from_grid_sum += from_grid
        elec_to_grid_MTPH_sum += day[best][d + 365]
        let hours0 = day[best][d + 730 + 365]
        let hours1 = day[best][d + 730 + 730]
        print(d, name[best], day[best][d], hours0, hours1, to: &outputStream)
        hours_sum += hours0 + hours1
      }
    }

    let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
    XCTAssertEqual(LCOM, 1598, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 7085.0, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 133784, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 53457, accuracy: 1, "elec_from_grid_sum")
    XCTAssertEqual(elec_to_grid_MTPH_sum, 5.1, accuracy: 1, "elec_to_grid_MTPH_sum")
    try? outputStream.write(toFile: "result_days.txt", atomically: false, encoding: .utf8)
  }

  func testsCosts() {
    guard let model = TunOl([178,6294,220,645,954,200,0.00,421,1000.00,100000.00,100000.00,21,12,0.00,0.00,0.00]) else { return }
    //  dump(model)
    let costs = Costs(model)
    // dump(costs)
    var fixtures = [21818877.0, 261_747_561, 443_728_031, 38_102_132, 88_937_793, 117_420_697, 163_628_857, 430_140_000, 0.0, 0.0, 0.0, 0.0, 0.0, 5_748_368, 0.0, 2_135_598, 0]
      .makeIterator()
    var outputStream = ""
    for child in Mirror(reflecting: model).children.filter({ $0.label?.contains("_ud") ?? false }) { print(child.label!, child.value as! Double, to: &outputStream) }
    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) {
      print(child.label!, child.value as! Double, to: &outputStream)
      XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!)
    }
    try? outputStream.write(toFile: "cost.txt", atomically: false, encoding: .utf8)
  }
}
