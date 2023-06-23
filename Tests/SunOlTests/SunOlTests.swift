import Utilities
import XCTest
import xlsxwriter

@testable import SunOl

class SunOlTests: XCTestCase {
  override func setUp() {
    let path = "input5.txt"
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
    let csv_ref = CSVReader(atPath: "calc.csv"),
    let csv_ref2 = CSVReader(atPath: "daily1.csv"),
    let csv_ref3 = CSVReader(atPath: "daily2.csv")
    else {
      print("No input")
      return
    }

    func calculation(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref[letter], column = Array(array[index..<index + 8760])
      var correct = true, counter = 1
      for i in 1..<8700 {

        if abs(abs(ref[i - 1]) - abs(column[i])) > max(abs(ref[i - 1]) * 0.01, 0.01) {
          counter += 1; correct = false
          if counter == 2 { print("Calculation \(letter)\(i + 4) proper value: \(String(format: "%.3f", ref[i - 1])) is \(String(format: "%.3", column[i])) [\(index + i)] \(i) div: \(String(format: "%.3f", abs(ref[i - 1]) - abs(column[i])))") }
        }
      }
      if !correct { XCTFail("Calculation \(letter)\n") }
    }

    func daily1(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref2[letter]
      var correct = true, counter = 1
      for i in 0..<364 {

        if abs(abs(ref[i]) - abs(array[index + i])) > max(abs(ref[i]) * 0.01, 0.01) {
          counter += 1; correct = false
          if counter == 2 { print("Daily1 \(letter)\(i + 3) proper value: \(String(format: "%.3f", ref[i])) is \(String(format: "%.3f", array[index + i])) [\(index + i)] \(i) div: \(ref[i] - array[index + i])") }
        }
      }
      if !correct { XCTFail("Daily1 \(letter)\n") }
    }

    func daily2(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref3[letter]
      var correct = true, counter = 1
      for i in 0..<364 {
        if abs(abs(ref[i]) - abs(array[index + i])) > max(abs(ref[i]) * 0.01, 0.01)  {
          counter += 1; correct = false
          if counter == 2 { print("Daily2 \(letter)\(i + 3) proper value: \(String(format: "%.3f", ref[i])) is \(String(format: "%.3f", array[index + i])) [\(index + i)] \(i) div: \(ref[i] - array[index + i])") }
        }
      }
      if !correct { XCTFail("Daily2 \(letter)\n") }
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

    let values = [
      123.79, 5032.58, 203.6, 497.95, 773.8, 180, 0, 358.26, 1000, 10000, 100000, 17.14, 108.11, 0, 0, 0,
    ]

    guard let model = TunOl(values) else {
      print("Invalid config")
      return
    }

    var hourPre = [Double](repeating: 0.0, count: 1_086_240)
    var hourFinal = [Double](repeating: 0.0, count: 516_840)
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

      if j == 0 {
        print("Case A")
        // H 0
        (9..<71).map { column($0, offset: 7, stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // BT 560640
        (71..<91).map { column($0, offset: 7, stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // CN 735840
        (91..<124).map { column($0, offset: 7, stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // C 0
        (2..<11).map { column($0, offset: 2) }.forEach { l, n in daily1(d10, l, n) }
        // T 5840
        (19..<35).map { column($0, offset: 3) }.forEach { l, n in daily1(d10, l, n) }
        // DV 0
        (125..<183).map { column($0, offset: 125, stride: 8760) }.forEach { l, n in calculation(hourFinal, l, n) }
        // EY 13140
        (154..<201).map { column($0, offset: 118) }.forEach { l, n in daily1(d10, l, n) }
        // GU 30660
        (202..<249).map { column($0, offset: 118) }.forEach { l, n in daily1(d10, l, n) }
        // IQ 48180
        (250..<312).map { column($0, offset: 118) }.forEach { l, n in daily1(d10, l, n) }
        // LB 71175
        (313..<348).map { column($0, offset: 118) }.forEach { l, n in daily1(d10, l, n) }
        // MK 83950
        (348..<381).map { column($0, offset: 118) }.forEach { l, n in daily1(d10, l, n) }
        // E 0
        (4..<30).map { column($0, offset: 4) }.forEach { l, n in daily2(d21, l, n) }
        // FC 0
        (158..<188).map { column($0, offset: 158) }.forEach { l, n in daily2(d23, l, n) }
        // GH 10950
        (189..<211).map { column($0, offset: 159) }.forEach { l, n in daily2(d23, l, n) }
        (212..<234).map { column($0, offset: 160) }.forEach { l, n in daily2(d23, l, n) }
        (235..<262).map { column($0, offset: 161) }.forEach { l, n in daily2(d23, l, n) }
        // JD 36865
        (263..<288).map { column($0, offset: 162) }.forEach { l, n in daily2(d23, l, n) }
        daily2(d23, "JB", 36135)
        daily2(d23, "KD", 45990)
      }
      if j == 1 {
        print("Case B")
        // GC 569400
        (184..<204).map { column($0, offset: 7 - (72 - 184), stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // TW 71175
        (542..<577).map { column($0, offset: 347) }.forEach { l, n in daily1(d10, l, n) }
        // VF 83950
        (577..<610).map { column($0, offset: 347) }.forEach { l, n in daily1(d10, l, n) }
        daily2(d23, "OB", 35405)
        daily2(d23, "PD", 45260)
        daily2(d23, "OE", 36135)
        daily2(d23, "PG", 45990)
      }
      if j == 2 {
        print("Case C")
        (296..<316).map { column($0, offset: 7 - (72 - 296), stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // ACR 71175
        (771..<806).map { column($0, offset: 576) }.forEach { l, n in daily1(d10, l, n) }
        // AEA 83950
        (806..<839).map { column($0, offset: 576) }.forEach { l, n in daily1(d10, l, n) }
        daily2(d23, "TE", 35405)
        daily2(d23, "UG", 45260)
        daily2(d23, "TH", 36135)
        daily2(d23, "UJ", 45990)
      }
      if j == 3 {
        print("Case D")
        (408..<428).map { column($0, offset: 7 - (72 - 408), stride: 8760) }.forEach { l, n in calculation(hourPre, l, n) }
        // ALM 71175
        (1000..<1034).map { column($0, offset: 805) }.forEach { l, n in daily1(d10, l, n) }
        // AMV 83950
        (1034..<1067).map { column($0, offset: 805) }.forEach { l, n in daily1(d10, l, n) }
        daily2(d23, "YH", 35405)
        daily2(d23, "ZI", 45260)
        daily2(d23, "YK", 36135)
        daily2(d23, "ZM", 45990)
      }
    }
    var meth_produced_MTPH_sum = Double.zero
    var elec_from_grid_sum = Double.zero
    var elec_to_grid_MTPH_sum = Double.zero
    var hours_sum = Double.zero
    let costs = Costs(model)
    var meth = [Double]()

    for d in 0..<365 {
      let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
      let best = cases.indices.sorted { cases[$0] < cases[$1] }.first
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
    XCTAssertEqual(LCOM, 2299, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 8626, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 77267, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 57125, accuracy: 1, "elec_from_grid_sum")
    XCTAssertEqual(elec_to_grid_MTPH_sum, 491, accuracy: 1, "elec_to_grid_MTPH_sum")
  }

  func testsCalculation2() {
    _ = [0.0,0.0,0.0,605.01,791.22,200.0,0.0,198.30,1000.00,100000.0,100000.0,24.03,9.23,1010.87,0.0,0.0]
    let values = [10,535.41,10.36,365.27,400,160,0,56.36,1000,10000,100000,14.05,36.66,0,0,0]

    guard let model = TunOl(values) else {
      print("Invalid config")
      return
    }
    dump(model)
    let costs = Costs(model)
    dump(costs)
    var hourPre = [Double](repeating: 0.0, count: 1_086_240)
    var hourFinal = [Double](repeating: 0.0, count: 516_840)
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

    let name = [
      "1a day prio", "1a night prio", "2a day prio", "2a night prio", "1b day prio", "1b night prio", "2b day prio", "2b night prio", "1c day prio", "1c night prio",
      "2c day prio", "2c night prio", "1d day prio", "1d night prio", "2d day prio", "2d night prio",
    ]

    var hours_sum = 0.0
    var outputStream = ""
    for child in Mirror(reflecting: model).children.filter({ $0.label?.contains("_ud") ?? false }) { print(child.label!, child.value as! Double, to: &outputStream) }
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
        outputStream.append(contentsOf: "\(name[best]) \(from_grid)\n")
        let hours0 = day[best][d + 1095]
        let hours1 = day[best][d + 1460]
        hours_sum += hours0 + hours1
      }
    }

    let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
    dump(LCOM)
    XCTAssertEqual(LCOM, 2154, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 8663, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 100000, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 0, accuracy: 1, "elec_from_grid_sum")
    try! outputStream.write(toFile: "result_days.txt", atomically: false, encoding: .utf8)
  }

  func testsCosts1() {
    let model = TunOl([0, 0, 0, 582.23, 727.03, 200, 0, 0, 1000, 1000, 100000, 18.81, 54.37, 54.03, 0, 0])!
    let costs = Costs(model)
    XCTAssertEqual(costs.Total_CAPEX, 1131739764, accuracy: 1, "Total_CAPEX")
    XCTAssertEqual(costs.Total_OPEX, 25050342, accuracy: 1, "Total_OPEX")
    var fixtures = [0.0, 0, 583211984, 78154616, 0, 0, 0, 371680000, 0, 0, 0, 0, 0, 65443269, 27100331, 6149563, 0]
      .makeIterator()
    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) {
      XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!)
    }
  }

  func testsCosts2() {
    let model = TunOl([128, 5804.06, 223.32, 544, 837.83, 200, 0, 390.6, 1000, 1000, 100000, 21.19, 54.65, 0, 0, 0])!
    let costs = Costs(model)
    XCTAssertEqual(costs.Total_CAPEX, 2047150258, accuracy: 1, "Total_CAPEX")
    XCTAssertEqual(costs.Total_OPEX, 28964270, accuracy: 1, "Total_OPEX")
    var fixtures = [15390661, 302048254, 672093994, 73022879, 120540581, 234309102, 178169365, 371680000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 73723703, 0.0, 6171715, 0]
      .makeIterator()
    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) {
      XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!)
    }
  }
}
