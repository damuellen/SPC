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
    let csv_ref = CSVReader(atPath: "COM/calc.csv"),
    let csv_ref2 = CSVReader(atPath: "COM/daily1.csv"),
    let csv_ref3 = CSVReader(atPath: "COM/daily2.csv")
    else {
      print("No input")
      return
    }

    func calculation(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref[letter], column = Array(array[index..<index + 8760])
      var correct = true, counter = 1
      for i in 1..<8700 {
        if counter > 20 { break }
        if abs(abs(ref[i - 1]) - abs(column[i])) > max(abs(ref[i - 1]) * 0.01, 0.01) {
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
        if abs(ref[i]) - abs(array[index + i]) > max(abs(ref[i]) * 0.01, 0.01) {
          counter += 1; correct = false
          print("Daily1 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
        }
      }
      if correct { print("Daily1 \(letter) is correct") } else { XCTFail("Error in Daily1 Column \(letter)") }
    }

    func daily2(_ array: [Double], _ letter: String, _ index: Int) {
      let index = index, ref = csv_ref3[letter]
      var correct = true, counter = 1
      for i in 0..<364 {
        if counter > 20 { break }
        if abs(ref[i]) - abs(array[index + i]) > max(abs(ref[i]) * 0.01, 0.01)  {
          counter += 1; correct = false
          print("Daily2 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
        }
      }
      if correct { print("Daily2 \(letter) is correct") } else { XCTFail("Error in Daily2 Column \(letter)") }
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

    let values = [0.00,0.00,0.00,599.32,803.41,180.00,0.00,0.00,1000.00,100000.00,100000.00,17.56,15.72,451.42,0.00,0.00,]
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
    let (GX, GZ, HA) = (16790, 17155, 17520)
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
      day.append(Array(d23[33945..<35040] + ArraySlice(zip(day20[365..<730], d23[GX..<GZ]).map { $1 > 0 ? $0 : 0 }) + day20[730..<1095]))
      day.append(Array(d23[44895..<45990] + ArraySlice(zip(day20[365..<730], d23[GZ..<HA]).map { $1 > 0 ? $0 : 0 }) + day20[730..<1095]))

      if j == 0 {
        print("Case A")
        // H 0
        (9..<71).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // BT 560640
        (71..<91).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // CN 735840
        (91..<124).map { column($0, offset: 7, stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // C 0
        (2..<11).map { column($0, offset: 2) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // T 5840
        (19..<35).map { column($0, offset: 3) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // DV 0
        (125..<183).map { column($0, offset: 125, stride: 8760) }.forEach { letter, offset in calculation(hourFinal, letter, offset) }
        // EY 13140
        (154..<201).map { column($0, offset: 118) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // GU 30660
        (202..<249).map { column($0, offset: 118) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // IQ 48180
        (250..<312).map { column($0, offset: 118) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // LB 71175
        (313..<348).map { column($0, offset: 118) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // MK 83950
        (348..<381).map { column($0, offset: 118) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // E 0
        (4..<30).map { column($0, offset: 4) }.forEach { letter, offset in daily2(d21, letter, offset) }
        // FC 0
        (158..<188).map { column($0, offset: 158) }.forEach { letter, offset in daily2(d23, letter, offset) }
        // GH 10950
        (189..<211).map { column($0, offset: 159) }.forEach { 
          letter, offset in daily2(d23, letter, offset) 
        }

        (212..<234).map { column($0, offset: 160) }.forEach { 
          letter, offset in daily2(d23, letter, offset) 
        }

        (235..<262).map { column($0, offset: 161) }.forEach { 
          letter, offset in daily2(d23, letter, offset) 
        }
        // JD 36865
        (263..<290).map { column($0, offset: 162) }.forEach {
          letter, offset in daily2(d23, letter, offset) 
        }
      }
      if j == 1 {
        print("Case B")
        // GC 569400
        (184..<204).map { column($0, offset: 7 - (72 - 184), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // TW 71175
        (542..<577).map { column($0, offset: 347) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // VF 83950
        (577..<610).map { column($0, offset: 347) }.forEach { letter, offset in daily1(d10, letter, offset) }
      }
      if j == 2 {
        print("Case C")
        (296..<316).map { column($0, offset: 7 - (72 - 296), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // ACR 71175
        (771..<806).map { column($0, offset: 576) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // AEA 83950
        (806..<839).map { column($0, offset: 576) }.forEach { letter, offset in daily1(d10, letter, offset) }
      }
      if j == 3 {
        print("Case D")
        (408..<428).map { column($0, offset: 7 - (72 - 408), stride: 8760) }.forEach { letter, offset in calculation(hourPre, letter, offset) }
        // ALM 71175
        (1000..<1034).map { column($0, offset: 805) }.forEach { letter, offset in daily1(d10, letter, offset) }
        // AMV 83950
        (1034..<1067).map { column($0, offset: 805) }.forEach { letter, offset in daily1(d10, letter, offset) }
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
    XCTAssertEqual(LCOM, 2290, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 7642.0, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 109375, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 57125.0, accuracy: 1, "elec_from_grid_sum")
    XCTAssertEqual(elec_to_grid_MTPH_sum, 0, accuracy: 1, "elec_to_grid_MTPH_sum")
  }

  func testsCalculation2() {
    let values = [128, 5804.06, 223.32, 544, 837.83, 200, 0, 390.6, 1000, 1000, 100000, 21.19, 54.65, 0, 0, 0]

    guard let model = TunOl(values) else {
      print("Invalid config")
      return
    }

    let costs = Costs(model)
    var hourPre = [Double](repeating: 0.0, count: 1_086_240)
    var hourFinal = [Double](repeating: 0.0, count: 516_840)
    var d10 = [Double](repeating: 0.0, count: 97_090)
    var d23 = [Double](repeating: 0.0, count: 48_545)
    var d21 = [Double](repeating: 0.0, count: 9_855)
    var day = [[Double]]()
  let (HC, HE, HF) = (18615, 18980, 19345)
  let (IX, KA) = (35405, 45260)
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
      day.append(Array(d23[IX..<IX+1095] + ArraySlice(a) + day20[730..<1095]))
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
    XCTAssertEqual(LCOM, 1535, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 7723, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 128175, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 3055, accuracy: 1, "elec_from_grid_sum")
    try? outputStream.write(toFile: "~/SPC/result_days.txt", atomically: false, encoding: .utf8)
  }

  func testsCosts1() {
    let model = TunOl([0, 0, 0, 582.23, 727.03, 200, 0, 0, 1000, 1000, 100000, 18.81, 54.37, 54.03, 0, 0])!
    let costs = Costs(model)
    XCTAssertEqual(costs.Total_CAPEX, 920289177, accuracy: 1, "Total_CAPEX")
    XCTAssertEqual(costs.Total_OPEX, 25970060, accuracy: 1, "Total_OPEX")
    var fixtures = [14424543.95, 0.0, 338158900, 35466937, 0.0, 2000000, 0.0, 430140000, 0.0, 0.0, 0.0, 0.0, 0.0, 64232732, 29716500, 6149563, 0]
      .makeIterator()
    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) {
      XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!)
    }
  }

  func testsCosts2() {
    let model = TunOl([128, 5804.06, 223.32, 544, 837.83, 200, 0, 390.6, 1000, 1000, 100000, 21.19, 54.65, 0, 0, 0])!
    let costs = Costs(model)
    XCTAssertEqual(costs.Total_CAPEX, 1500734088, accuracy: 1, "Total_CAPEX")
    XCTAssertEqual(costs.Total_OPEX, 30962640, accuracy: 1, "Total_OPEX")
    var fixtures = [19741817, 191258187, 389694609, 33820242, 83005675, 109365105, 165176736, 430140000, 0.0, 0.0, 0.0, 0.0, 0.0, 72360000, 0.0, 6171715, 0]
      .makeIterator()
    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) {
      XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!)
    }
  }
}
