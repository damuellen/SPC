import Utilities
import XCTest
import xlsxwriter

@testable import SunOl

class SunOlTests: XCTestCase {
  override func setUp() {
    let path = "input2.txt"
    guard let csv = CSVReader(atPath: path) else {
      print("No input")
      return
    }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]
  }

  func testsCalculation() {
    guard let csv_ref = CSVReader(atPath: "calc.csv", separator: "\t"),
     let csv_ref2 = CSVReader(atPath: "daily1.csv", separator: "\t")
     // let csv_ref3 = CSVReader(atPath: "daily2.csv", separator: "\t")
      else {
      print("No input")
      return
    }

    var calc = [String]()
    func compare(_ array: [Double], letter: String, start index: Int) {
      let index = index, ref = csv_ref[letter], column = Array(array[index..<index + 8760])
      var correct = true, counter = 1
      for i in 1..<8700 {
        if counter > 20 { break }
        if abs(abs(ref[i - 1]) - abs(column[i])) > 0.02 {
          counter += 1; correct = false
          print("Calculation \(letter)\(i + 5) proper value: \(String(format: "%.2f", ref[i - 1])) [\(index + i)] \(String(format: "%.2f", column[i]))  div: \(abs(ref[i - 1]) - abs(column[i]))")
        }
      }
      if correct { calc.append(letter) } else { XCTFail("Error in Calculation Column \(letter)") }
    }

    var day1 = [String]()
    func compareDay(_ array: [Double], letter: String, start index: Int) {
      let index = index, ref = csv_ref2[letter]
      var correct = true, counter = 1
      for i in 0..<364 {
        if counter > 20 { break }
        if abs(ref[i]) - abs(array[index + i]) > 0.2 {
          counter += 1; correct = false
          print("Daily1 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
        }
      }
      if correct { day1.append(letter) } else { XCTFail("Error in Daily1 Column \(letter)") }
    }

    var day2 = [String]()
    func compare2Day(_ array: [Double], letter: String, start index: Int) {
      // let index = index, ref = csv_ref3[letter]
      // var correct = true, counter = 1
      // for i in 0..<364 {
      //   if counter > 20 { break }
      //   if abs(ref[i]) - abs(array[index + i]) > 0.2 {
      //     counter += 1; correct = false
      //     print("Daily2 \(letter)\(i + 3) proper value: \(String(format: "%.2f", ref[i])) [\(index + i)] \(String(format: "%.2f", array[index + i]))  div: \(ref[i] - array[index + i])")
      //   }
      // }
      // if correct { day1.append(letter) } else { XCTFail("Error in Daily2 Column \(letter)") }
    }

    guard let model = TunOl(
      [226.339,500.000,100.755,341.952,888.434,180.000,0.000,121.753,1000.000,100000.000,100000.000,21.707,10.540,0.000,0.000,0.000]
      ) else {
      print("Invalid config")
      return
    }

    var hour2 = [Double](repeating: .zero, count: 183_960)
    var hour3 = [Double](repeating: .zero, count: 297_840)
    var hour4 = [Double](repeating: .zero, count: 516_840)
    var d10 = [Double](repeating: .zero, count: 13_140)
    var d11 = [Double](repeating: .zero, count: 17_155)
    var d12 = [Double](repeating: .zero, count: 17_155)
    var d13 = [Double](repeating: .zero, count: 47_085)
    var d23 = [Double](repeating: .zero, count: 48_545)
    var d21 = [Double](repeating: .zero, count: 9855)

    print("Hour0")
    let hour0 = model.hour0(
      TunOl.Q_Sol_MW_thLoop, 
      TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, 
      TunOl.Reference_PV_MV_power_at_transformer_outlet
    )

    columns0.forEach { key, value in  compare(hour0, letter:key, start:value) }

    let reserve = model.Overall_harmonious_min_perc
    let hour1 = model.hour1(hour0: hour0, reserved: reserve)

    columns1.forEach { key, value in  compare(hour1, letter:key, start:value) }

    print("Daily0")
    let d0 = model.day0(hour0: hour0)

    print("Daily2")
    let d22 = model.d22(hour0: hour0)

    columns22.forEach { key, value in  compare2Day(d22, letter:key, start:value) }

    let cases = ["A","B","C","D"]
    for (j, c) in cases.enumerated() {

      print("Hour2 Case", c)
      model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
      if c == "A" { columns2A.forEach { key, value in  compare(hour2, letter:key, start:value) } }
      if c == "C" { columns2C.forEach { key, value in  compare(hour2, letter:key, start:value) } }

      print("Hour3 Case", c)
      model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
      if j == 0 { columns3A.forEach { key, value in compare(hour3, letter:key, start:value) } }

      print("Daily10 Case", c)
      model.d10(&d10, case: j, hour2: hour2, hour3: hour3)

      print("Hour4 Case", c)
      model.hour4(&hour4, j: j, d1: d10, hour0: hour0, hour1: hour1, hour2: hour2, hour3: hour3)
      if j == 0 { columns4A.forEach { key, value in compare(hour4, letter:key, start:value) } }
      if j == 2 { columns4C.forEach { key, value in compare(hour4, letter:key, start:value) } }

      print("Daily10 Case", c)
      model.night(case: j, d10: &d10, hour3: hour3, hour4: hour4)
      if j == 0 { columns10.forEach { key, value in compareDay(hour4, letter:key, start:value) } }
      if j == 2 {
        compareDay(d10, letter: "CX", start: 8030)
        compareDay(d10, letter: "CY", start: 8395)
        compareDay(d10, letter: "CZ", start: 8760)
        compareDay(d10, letter: "DA", start: 9125)
        compareDay(d10, letter: "DK", start: 12_775)
      }
      
      print("Daily11 Case", c) 
      model.d11(case: j, &d11, hour0: hour0, hour2: hour2, hour3: hour3)
      if j == 0 {
        compareDay(d11, letter: "EY", start: 0)
        compareDay(d11, letter: "EZ", start: 365)
        compareDay(d11, letter: "FA", start: 730)
        compareDay(d11, letter: "FC", start: 1460)
        compareDay(d11, letter: "FD", start: 1825)
        compareDay(d11, letter: "FE", start: 2190)
        compareDay(d11, letter: "FK", start: 4380)
        compareDay(d11, letter: "FR", start: 6935)
        compareDay(d11, letter: "FS", start: 7300)
        compareDay(d11, letter: "FV", start: 8395)
        compareDay(d11, letter: "FW", start: 8760)
        compareDay(d11, letter: "GA", start: 10_220)
        compareDay(d11, letter: "GB", start: 10_585)
        compareDay(d11, letter: "GC", start: 10_950)
        compareDay(d11, letter: "GE", start: 11_680)
        compareDay(d11, letter: "GG", start: 12_410)
      }

      if j == 2 {
        compareDay(d11, letter: "WO", start: 0)
        compareDay(d11, letter: "WP", start: 365)
        compareDay(d11, letter: "WQ", start: 730)
        // compareDay(d11, letter: "WR", start: 1095)
        compareDay(d11, letter: "WS", start: 1460)
        compareDay(d11, letter: "WT", start: 1825)
        compareDay(d11, letter: "WU", start: 2190)
        // compareDay(d11, letter: "WV", start: 2555)
        // compareDay(d11, letter: "WW", start: 2920)
        // compareDay(d11, letter: "WX", start: 3285)
        // compareDay(d11, letter: "WY", start: 3650)
        // compareDay(d11, letter: "WZ", start: 4015)
        compareDay(d11, letter: "XA", start: 4380)
        // compareDay(d11, letter: "XB", start: 4745)
        // compareDay(d11, letter: "XC", start: 5110)
        // compareDay(d11, letter: "XD", start: 5475)
        // compareDay(d11, letter: "XE", start: 5840)
        // compareDay(d11, letter: "XF", start: 6205)
        // compareDay(d11, letter: "XG", start: 6570)
        // compareDay(d11, letter: "XH", start: 6935)
        compareDay(d11, letter: "XI", start: 7300)
        compareDay(d11, letter: "XJ", start: 7665)
        compareDay(d11, letter: "XK", start: 8030)
        compareDay(d11, letter: "XL", start: 8395)
        compareDay(d11, letter: "XM", start: 8760)
        compareDay(d11, letter: "XN", start: 9125)
        compareDay(d11, letter: "XO", start: 9490)
        compareDay(d11, letter: "XP", start: 9855)
        compareDay(d11, letter: "XQ", start: 10_220)
        compareDay(d11, letter: "XR", start: 10_585)
        compareDay(d11, letter: "XS", start: 10_950)
        compareDay(d11, letter: "XT", start: 11_315)
        compareDay(d11, letter: "XU", start: 11_680)
        compareDay(d11, letter: "XV", start: 12_045)
        compareDay(d11, letter: "XW", start: 12_410)
        compareDay(d11, letter: "XX", start: 12_775)
        compareDay(d11, letter: "XY", start: 13_140)
        // compareDay(d11, letter: "XZ", start: 13505)
        compareDay(d11, letter: "YA", start: 13_870)
        compareDay(d11, letter: "YB", start: 14_235)
        // compareDay(d11, letter: "YC", start: 14600)
        compareDay(d11, letter: "YD", start: 14_965)
        compareDay(d11, letter: "YE", start: 15_330)
        // compareDay(d11, letter: "YF", start: 15695)
        compareDay(d11, letter: "YG", start: 16_060)
        compareDay(d11, letter: "YH", start: 16_425)
        // compareDay(d11, letter: "YI", start: 16790)

      }
      print("Daily12 Case", c)
      model.d12(case: j, &d12, hour0: hour0, hour4: hour4)

      if j == 0 {
        compareDay(d12, letter: "HO", start: 7300)
        compareDay(d12, letter: "HR", start: 8395)
      }
      if j == 1 {
        compareDay(d12, letter: "ON", start: 7300)
        compareDay(d12, letter: "OO", start: 7665)
        compareDay(d12, letter: "OP", start: 8030)
        compareDay(d12, letter: "OQ", start: 8395)
        compareDay(d12, letter: "OR", start: 8760)
        compareDay(d12, letter: "OS", start: 9125)
        compareDay(d12, letter: "OT", start: 9490)
        compareDay(d12, letter: "OU", start: 9855)
      }
      if j == 2 {
        compareDay(d12, letter: "YK", start: 0)
        compareDay(d12, letter: "YL", start: 365)
        compareDay(d12, letter: "YM", start: 730)
        // compareDay(d12, letter: "YN", start: 1095)
        compareDay(d12, letter: "YO", start: 1460)
        compareDay(d12, letter: "YP", start: 1825)
        compareDay(d12, letter: "YQ", start: 2190)
        // compareDay(d12, letter: "YR", start: 2555)
        // compareDay(d12, letter: "YS", start: 2920)
        // compareDay(d12, letter: "YT", start: 3285)
        // compareDay(d12, letter: "YU", start: 3650)
        // compareDay(d12, letter: "YV", start: 4015)
        compareDay(d12, letter: "YW", start: 4380)
        // compareDay(d12, letter: "YX", start: 4745)
        // compareDay(d12, letter: "YY", start: 5110)
        // compareDay(d12, letter: "YZ", start: 5475)
        // compareDay(d12, letter: "ZA", start: 5840)
        // compareDay(d12, letter: "ZB", start: 6205)
        // compareDay(d12, letter: "ZC", start: 6570)
        // compareDay(d12, letter: "ZD", start: 6935)
        compareDay(d12, letter: "ZE", start: 7300)
        compareDay(d12, letter: "ZF", start: 7665)
        compareDay(d12, letter: "ZG", start: 8030)
        compareDay(d12, letter: "ZH", start: 8395)
        compareDay(d12, letter: "ZI", start: 8760)
        compareDay(d12, letter: "ZJ", start: 9125)
        compareDay(d12, letter: "ZK", start: 9490)
        compareDay(d12, letter: "ZL", start: 9855)
        compareDay(d12, letter: "ZM", start: 10_220)
        compareDay(d12, letter: "ZN", start: 10_585)
        compareDay(d12, letter: "ZO", start: 10_950)
        compareDay(d12, letter: "ZP", start: 11_315)
        compareDay(d12, letter: "ZQ", start: 11_680)
        compareDay(d12, letter: "ZR", start: 12_045)
        compareDay(d12, letter: "ZS", start: 12_410)
        compareDay(d12, letter: "ZT", start: 12_775)
        compareDay(d12, letter: "ZU", start: 13_140)
        // compareDay(d12, letter: "ZV", start: 13505)
        compareDay(d12, letter: "ZW", start: 13_870)
        compareDay(d12, letter: "ZX", start: 14_235)
        // compareDay(d12, letter: "ZY", start: 14600)
        compareDay(d12, letter: "ZZ", start: 14_965)
        compareDay(d12, letter: "AAA", start: 15_330)
        // compareDay(d12, letter: "AAB", start: 15695)
        compareDay(d12, letter: "AAC", start: 16_060)
        compareDay(d12, letter: "AAD", start: 16_425)
        // compareDay(d12, letter: "AAE", start: 16790)
      }
      print("Daily13 Case", c)
      model.d13(&d13, case: j, d10: d10, d11: d11, d12: d12)
      print("Daily14 Case", c)
      model.d14(&d13, case: j, d10: d10, d11: d11, d12: d12)
      if j == 0 {
        compareDay(d13, letter: "IQ", start: 0)
        compareDay(d13, letter: "IR", start: 365)
        compareDay(d13, letter: "IS", start: 730)
        compareDay(d13, letter: "JP", start: 8760)
        compareDay(d13, letter: "JQ", start: 9125)
        compareDay(d13, letter: "JR", start: 9490)
        compareDay(d13, letter: "KG", start: 14_965)
        compareDay(d13, letter: "KI", start: 15_330)
        compareDay(d13, letter: "KJ", start: 15_695)
        compareDay(d13, letter: "KK", start: 16_060)
        compareDay(d13, letter: "KZ", start: 21_535)
        compareDay(d13, letter: "MK", start: 34_310)
        compareDay(d13, letter: "NA", start: 40_150)
        compareDay(d13, letter: "NO", start: 45_260)
        compareDay(d13, letter: "NP", start: 45_625)
        compareDay(d13, letter: "NL", start: 44_165)
      }

      if j == 1 {
        compareDay(d13, letter: "RL", start: 0)
        compareDay(d13, letter: "RM", start: 365)
        compareDay(d13, letter: "RN", start: 730)
        compareDay(d13, letter: "RO", start: 1095)
        compareDay(d13, letter: "RP", start: 1460)
        compareDay(d13, letter: "RQ", start: 1825)
        compareDay(d13, letter: "RR", start: 2190)
        compareDay(d13, letter: "RS", start: 2555)
        compareDay(d13, letter: "RT", start: 2920)
        compareDay(d13, letter: "RU", start: 3285)
        compareDay(d13, letter: "RV", start: 3650)
        compareDay(d13, letter: "RW", start: 4015)
        compareDay(d13, letter: "RX", start: 4380)
        compareDay(d13, letter: "RY", start: 4745)
        compareDay(d13, letter: "RZ", start: 5110)
        compareDay(d13, letter: "SA", start: 5475)
        compareDay(d13, letter: "SB", start: 5840)
        compareDay(d13, letter: "SC", start: 6205)
        compareDay(d13, letter: "SD", start: 6570)
        compareDay(d13, letter: "SE", start: 6935)
        compareDay(d13, letter: "SF", start: 7300)
        compareDay(d13, letter: "SG", start: 7665)
        compareDay(d13, letter: "SH", start: 8030)
        compareDay(d13, letter: "SI", start: 8395)

        compareDay(d13, letter: "SK", start: 8760)
        compareDay(d13, letter: "SL", start: 9125)
        compareDay(d13, letter: "SM", start: 9490)
        compareDay(d13, letter: "SN", start: 9855)
        compareDay(d13, letter: "SO", start: 10_220)
        compareDay(d13, letter: "SP", start: 10_585)
        compareDay(d13, letter: "SQ", start: 10_950)
        compareDay(d13, letter: "SR", start: 11_315)
        compareDay(d13, letter: "SS", start: 11_680)
        compareDay(d13, letter: "ST", start: 12_045)
        compareDay(d13, letter: "SU", start: 12_410)
        compareDay(d13, letter: "SV", start: 12_775)
        compareDay(d13, letter: "SW", start: 13_140)
        compareDay(d13, letter: "SX", start: 13_505)
        compareDay(d13, letter: "SY", start: 13_870)
        compareDay(d13, letter: "SZ", start: 14_235)
        compareDay(d13, letter: "TA", start: 14_600)
        compareDay(d13, letter: "TB", start: 14_965)

        compareDay(d13, letter: "TD", start: 15_330)
        compareDay(d13, letter: "TE", start: 15_695)
        compareDay(d13, letter: "TF", start: 16_060)
        compareDay(d13, letter: "TG", start: 16_425)
        compareDay(d13, letter: "TH", start: 16_790)
        compareDay(d13, letter: "TI", start: 17_155)
        compareDay(d13, letter: "TJ", start: 17_520)
        compareDay(d13, letter: "TK", start: 17_885)
        compareDay(d13, letter: "TL", start: 18_250)
        compareDay(d13, letter: "TM", start: 18_615)
        compareDay(d13, letter: "TN", start: 18_980)
        compareDay(d13, letter: "TO", start: 19_345)
        compareDay(d13, letter: "TP", start: 19_710)
        compareDay(d13, letter: "TQ", start: 20_075)
        compareDay(d13, letter: "TR", start: 20_440)
        compareDay(d13, letter: "TS", start: 20_805)
        compareDay(d13, letter: "TT", start: 21_170)
        compareDay(d13, letter: "TU", start: 21_535)
        compareDay(d13, letter: "UX", start: 31_755)
        compareDay(d13, letter: "WG", start: 44_165)
      }

      if j == 2 {
        compareDay(d13, letter: "AAG", start: 0)
        compareDay(d13, letter: "AAH", start: 365)
        compareDay(d13, letter: "AAI", start: 730)
        compareDay(d13, letter: "AAJ", start: 1095)
        compareDay(d13, letter: "AAK", start: 1460)
        compareDay(d13, letter: "AAL", start: 1825)
        compareDay(d13, letter: "AAM", start: 2190)
        compareDay(d13, letter: "AAN", start: 2555)
        compareDay(d13, letter: "AAO", start: 2920)
        compareDay(d13, letter: "AAP", start: 3285)
        compareDay(d13, letter: "AAQ", start: 3650)
        compareDay(d13, letter: "AAR", start: 4015)
        compareDay(d13, letter: "AAS", start: 4380)
        compareDay(d13, letter: "AAT", start: 4745)
        compareDay(d13, letter: "AAU", start: 5110)
        compareDay(d13, letter: "AAV", start: 5475)
        compareDay(d13, letter: "AAW", start: 5840)
        compareDay(d13, letter: "AAX", start: 6205)
        compareDay(d13, letter: "AAY", start: 6570)
        compareDay(d13, letter: "AAZ", start: 6935)
        compareDay(d13, letter: "ABA", start: 7300)
        compareDay(d13, letter: "ABB", start: 7665)
        compareDay(d13, letter: "ABC", start: 8030)
        compareDay(d13, letter: "ABD", start: 8395)

        compareDay(d13, letter: "ABF", start: 8760)
        compareDay(d13, letter: "ABG", start: 9125)
        compareDay(d13, letter: "ABH", start: 9490)
        compareDay(d13, letter: "ABI", start: 9855)
        compareDay(d13, letter: "ABJ", start: 10_220)
        compareDay(d13, letter: "ABK", start: 10_585)
        compareDay(d13, letter: "ABL", start: 10_950)
        compareDay(d13, letter: "ABM", start: 11_315)
        compareDay(d13, letter: "ABN", start: 11_680)
        compareDay(d13, letter: "ABO", start: 12_045)
        compareDay(d13, letter: "ABP", start: 12_410)
        compareDay(d13, letter: "ABQ", start: 12_775)
        compareDay(d13, letter: "ABR", start: 13_140)
        compareDay(d13, letter: "ABS", start: 13_505)
        compareDay(d13, letter: "ABT", start: 13_870)
        compareDay(d13, letter: "ABU", start: 14_235)
        compareDay(d13, letter: "ABV", start: 14_600)
        compareDay(d13, letter: "ABW", start: 14_965)

        compareDay(d13, letter: "ABY", start: 15_330)
        compareDay(d13, letter: "ABZ", start: 15_695)
        compareDay(d13, letter: "ACA", start: 16_060)
        compareDay(d13, letter: "ACB", start: 16_425)
        compareDay(d13, letter: "ACC", start: 16_790)
        compareDay(d13, letter: "ACD", start: 17_155)
        compareDay(d13, letter: "ACE", start: 17_520)
        compareDay(d13, letter: "ACF", start: 17_885)
        compareDay(d13, letter: "ACG", start: 18_250)
        compareDay(d13, letter: "ACH", start: 18_615)
        compareDay(d13, letter: "ACI", start: 18_980)
        compareDay(d13, letter: "ACJ", start: 19_345)
        compareDay(d13, letter: "ACK", start: 19_710)
        compareDay(d13, letter: "ACL", start: 20_075)
        compareDay(d13, letter: "ACM", start: 20_440)
        compareDay(d13, letter: "ACN", start: 20_805)
        compareDay(d13, letter: "ACO", start: 21_170)
        compareDay(d13, letter: "ACP", start: 21_535)
        compareDay(d13, letter: "ADS", start: 31_755)
        compareDay(d13, letter: "AFB", start: 44_165)
      }

      if j == 3 {
        compareDay(d13, letter: "AMN", start: 31_755)
        compareDay(d13, letter: "ANW", start: 44_165)
      }
      
      print("Daily21 Case", c)
      model.d21(&d21, case: j, day0: d0)

      if j == 0 {
        compare2Day(d0, letter: "B", start: 365)
        compare2Day(d0, letter: "C", start: 730)
        compare2Day(d21, letter: "E", start: 0)
        compare2Day(d21, letter: "F", start: 365)
        compare2Day(d21, letter: "G", start: 730)
        compare2Day(d21, letter: "H", start: 1095)
        compare2Day(d21, letter: "I", start: 1460)
        compare2Day(d21, letter: "J", start: 1825)
        compare2Day(d21, letter: "K", start: 2190)
        compare2Day(d21, letter: "L", start: 2555)
        compare2Day(d21, letter: "M", start: 2920)
        compare2Day(d21, letter: "N", start: 3285)
        compare2Day(d21, letter: "O", start: 3650)
        compare2Day(d21, letter: "P", start: 4015)
        compare2Day(d21, letter: "Q", start: 4380)
        compare2Day(d21, letter: "R", start: 4745)
        compare2Day(d21, letter: "S", start: 5110)
        compare2Day(d21, letter: "T", start: 5475)
        compare2Day(d21, letter: "U", start: 5840)
        compare2Day(d21, letter: "V", start: 6205)
        compare2Day(d21, letter: "W", start: 6570)
        compare2Day(d21, letter: "X", start: 6935)
        compare2Day(d21, letter: "Y", start: 7300)
        compare2Day(d21, letter: "Z", start: 7665)
        compare2Day(d21, letter: "AA", start: 8030)
        compare2Day(d21, letter: "AB", start: 8395)
        compare2Day(d21, letter: "AC", start: 8760)
        compare2Day(d21, letter: "AD", start: 9125)
        compare2Day(d21, letter: "AE", start: 9490)
      }
      if j == 1 {
        compare2Day(d21, letter: "AG", start: 0)
        compare2Day(d21, letter: "AH", start: 365)
        compare2Day(d21, letter: "AI", start: 730)
        compare2Day(d21, letter: "AJ", start: 1095)
        compare2Day(d21, letter: "AK", start: 1460)
        compare2Day(d21, letter: "AL", start: 1825)
        compare2Day(d21, letter: "AM", start: 2190)
        compare2Day(d21, letter: "AN", start: 2555)
        compare2Day(d21, letter: "AO", start: 2920)
        compare2Day(d21, letter: "AP", start: 3285)
        compare2Day(d21, letter: "AQ", start: 3650)
        compare2Day(d21, letter: "AR", start: 4015)
        compare2Day(d21, letter: "AS", start: 4380)
        compare2Day(d21, letter: "AT", start: 4745)
        compare2Day(d21, letter: "AU", start: 5110)
        compare2Day(d21, letter: "AV", start: 5475)
        compare2Day(d21, letter: "AW", start: 5840)
        compare2Day(d21, letter: "AX", start: 6205)
        compare2Day(d21, letter: "AY", start: 6570)
        compare2Day(d21, letter: "AZ", start: 6935)
        compare2Day(d21, letter: "BA", start: 7300)
        compare2Day(d21, letter: "BB", start: 7665)
        compare2Day(d21, letter: "BC", start: 8030)
        compare2Day(d21, letter: "BD", start: 8395)
        compare2Day(d21, letter: "BE", start: 8760)
        compare2Day(d21, letter: "BF", start: 9125)
        compare2Day(d21, letter: "BG", start: 9490)
      }
      if j == 2 {
        compare2Day(d21, letter: "BI", start: 0)
        compare2Day(d21, letter: "BJ", start: 365)
        compare2Day(d21, letter: "BK", start: 730)
        compare2Day(d21, letter: "BL", start: 1095)
        compare2Day(d21, letter: "BM", start: 1460)
        compare2Day(d21, letter: "BN", start: 1825)
        compare2Day(d21, letter: "BO", start: 2190)
        compare2Day(d21, letter: "BP", start: 2555)
        compare2Day(d21, letter: "BQ", start: 2920)
        compare2Day(d21, letter: "BR", start: 3285)
        compare2Day(d21, letter: "BS", start: 3650)
        compare2Day(d21, letter: "BT", start: 4015)
        compare2Day(d21, letter: "BU", start: 4380)
        compare2Day(d21, letter: "BV", start: 4745)
        compare2Day(d21, letter: "BW", start: 5110)
        compare2Day(d21, letter: "BX", start: 5475)
        compare2Day(d21, letter: "BY", start: 5840)
        compare2Day(d21, letter: "BZ", start: 6205)
        compare2Day(d21, letter: "CA", start: 6570)
        compare2Day(d21, letter: "CB", start: 6935)
        compare2Day(d21, letter: "CC", start: 7300)
        compare2Day(d21, letter: "CD", start: 7665)
        compare2Day(d21, letter: "CE", start: 8030)
        compare2Day(d21, letter: "CF", start: 8395)
        compare2Day(d21, letter: "CG", start: 8760)
        compare2Day(d21, letter: "CH", start: 9125)
        compare2Day(d21, letter: "CI", start: 9490)
      }

      print("Daily2 Case", c)
      model.d23(&d23, case: j, day0: d0, d21: d21, d22: d22)

      if j == 0 {
        compare2Day(d23, letter: "FC", start: 0)
        compare2Day(d23, letter: "FD", start: 365)
        compare2Day(d23, letter: "FE", start: 730)
        compare2Day(d23, letter: "FF", start: 1095)
        compare2Day(d23, letter: "FG", start: 1460)
        compare2Day(d23, letter: "FH", start: 1825)
        compare2Day(d23, letter: "FI", start: 2190)
        compare2Day(d23, letter: "FJ", start: 2555)
        compare2Day(d23, letter: "FK", start: 2920)
        compare2Day(d23, letter: "FL", start: 3285)
        compare2Day(d23, letter: "FM", start: 3650)
        compare2Day(d23, letter: "FN", start: 4015)
        compare2Day(d23, letter: "FO", start: 4380)
        compare2Day(d23, letter: "FP", start: 4745)
        compare2Day(d23, letter: "FQ", start: 5110)
        compare2Day(d23, letter: "FR", start: 5475)
        compare2Day(d23, letter: "FS", start: 5840)
        compare2Day(d23, letter: "FT", start: 6205)
        compare2Day(d23, letter: "FU", start: 6570)
        compare2Day(d23, letter: "FV", start: 6935)
        compare2Day(d23, letter: "FW", start: 7300)
        compare2Day(d23, letter: "FX", start: 7665)
        compare2Day(d23, letter: "FY", start: 8030)
        compare2Day(d23, letter: "FZ", start: 8395)
        compare2Day(d23, letter: "GA", start: 8760)
        compare2Day(d23, letter: "GB", start: 9125)
        compare2Day(d23, letter: "GC", start: 9490)
        compare2Day(d23, letter: "GE", start: 9855)
        compare2Day(d23, letter: "GF", start: 10_220)
        compare2Day(d23, letter: "GG", start: 10_585)
        compare2Day(d23, letter: "GH", start: 10_950)
        compare2Day(d23, letter: "GI", start: 11_315)
        compare2Day(d23, letter: "GJ", start: 11_680)
        compare2Day(d23, letter: "GK", start: 12_045)
        compare2Day(d23, letter: "GL", start: 12_410)
        compare2Day(d23, letter: "GM", start: 12_775)
        compare2Day(d23, letter: "GN", start: 13_140)
        compare2Day(d23, letter: "GO", start: 13_505)
        compare2Day(d23, letter: "GP", start: 13_870)
        compare2Day(d23, letter: "GQ", start: 14_235)
        compare2Day(d23, letter: "GR", start: 14_600)
        compare2Day(d23, letter: "GS", start: 14_965)
        compare2Day(d23, letter: "GT", start: 15_330)
        compare2Day(d23, letter: "GU", start: 15_695)
        compare2Day(d23, letter: "GV", start: 16_060)
        compare2Day(d23, letter: "GW", start: 16_425)
        compare2Day(d23, letter: "GX", start: 16_790)
        compare2Day(d23, letter: "GZ", start: 17_155)
        compare2Day(d23, letter: "HA", start: 17_520)
        compare2Day(d23, letter: "HB", start: 17_885)
        compare2Day(d23, letter: "HC", start: 18_250)
        compare2Day(d23, letter: "HD", start: 18_615)
        compare2Day(d23, letter: "HE", start: 18_980)
        compare2Day(d23, letter: "HF", start: 19_345)
        compare2Day(d23, letter: "HG", start: 19_710)
        compare2Day(d23, letter: "HH", start: 20_075)
        compare2Day(d23, letter: "HI", start: 20_440)
        compare2Day(d23, letter: "HJ", start: 20_805)
        compare2Day(d23, letter: "HK", start: 21_170)
        compare2Day(d23, letter: "HL", start: 21_535)
        compare2Day(d23, letter: "HM", start: 21_900)
        compare2Day(d23, letter: "HN", start: 22_265)
        compare2Day(d23, letter: "HO", start: 22_630)
        compare2Day(d23, letter: "HP", start: 22_995)
        compare2Day(d23, letter: "HQ", start: 23_360)
        compare2Day(d23, letter: "HR", start: 23_725)
        compare2Day(d23, letter: "HS", start: 24_090)
        compare2Day(d23, letter: "HU", start: 24_455)
        compare2Day(d23, letter: "HV", start: 24_820)
        compare2Day(d23, letter: "HW", start: 25_185)
        compare2Day(d23, letter: "HY", start: 25_915)
        compare2Day(d23, letter: "HZ", start: 26_280)
        compare2Day(d23, letter: "IA", start: 26_645)
        compare2Day(d23, letter: "IB", start: 27_010)
        compare2Day(d23, letter: "IC", start: 27_375)
        compare2Day(d23, letter: "IE", start: 28_105)
        compare2Day(d23, letter: "IF", start: 28_470)
        compare2Day(d23, letter: "IH", start: 29_200)
        compare2Day(d23, letter: "II", start: 29_565)
        compare2Day(d23, letter: "IJ", start: 29_930)
        compare2Day(d23, letter: "IK", start: 30_295)
        compare2Day(d23, letter: "IL", start: 30_660)
        compare2Day(d23, letter: "IM", start: 31_025)
        compare2Day(d23, letter: "IN", start: 31_390)
        compare2Day(d23, letter: "IO", start: 31_755)
        compare2Day(d23, letter: "IP", start: 32_120)
        compare2Day(d23, letter: "IQ", start: 32_485)
        compare2Day(d23, letter: "IR", start: 32_850)
        compare2Day(d23, letter: "IS", start: 33_215)
        compare2Day(d23, letter: "IT", start: 33_580)
        compare2Day(d23, letter: "IU", start: 33_945)
        compare2Day(d23, letter: "IV", start: 34_310)
        compare2Day(d23, letter: "IW", start: 34_675)
        compare2Day(d23, letter: "IX", start: 35_040)
        compare2Day(d23, letter: "IZ", start: 35_405)
        compare2Day(d23, letter: "JA", start: 35_770)
        compare2Day(d23, letter: "JB", start: 36_135)
        compare2Day(d23, letter: "JD", start: 36_865)
        compare2Day(d23, letter: "JE", start: 37_230)
        compare2Day(d23, letter: "JF", start: 37_595)
        compare2Day(d23, letter: "JG", start: 37_960)
        compare2Day(d23, letter: "JH", start: 38_325)
        compare2Day(d23, letter: "JJ", start: 39_055)
        compare2Day(d23, letter: "JK", start: 39_420)
        compare2Day(d23, letter: "JM", start: 40_150)
        compare2Day(d23, letter: "JN", start: 40_515)
        compare2Day(d23, letter: "JO", start: 40_880)
        compare2Day(d23, letter: "JP", start: 41_245)
        compare2Day(d23, letter: "JR", start: 47_815)
        compare2Day(d23, letter: "JS", start: 42_340)
        compare2Day(d23, letter: "JT", start: 42_705)
        compare2Day(d23, letter: "JU", start: 43_070)
        compare2Day(d23, letter: "JV", start: 43_435)
        compare2Day(d23, letter: "JX", start: 44_165)
        compare2Day(d23, letter: "JY", start: 44_530)
        compare2Day(d23, letter: "JZ", start: 44_895)
        compare2Day(d23, letter: "KA", start: 45_260)
        compare2Day(d23, letter: "KB", start: 45_625)  
      }

      if j == 1 {
        compare2Day(d23, letter: "KE", start: 0)
        compare2Day(d23, letter: "KF", start: 365)
        compare2Day(d23, letter: "KG", start: 730)
        compare2Day(d23, letter: "KH", start: 1095)
        compare2Day(d23, letter: "KI", start: 1460)
        compare2Day(d23, letter: "KJ", start: 1825)
        compare2Day(d23, letter: "KK", start: 2190)
        compare2Day(d23, letter: "KL", start: 2555)
        compare2Day(d23, letter: "KM", start: 2920)
        compare2Day(d23, letter: "KN", start: 3285)
        compare2Day(d23, letter: "KO", start: 3650)
        compare2Day(d23, letter: "KP", start: 4015)
        compare2Day(d23, letter: "KQ", start: 4380)
        compare2Day(d23, letter: "KR", start: 4745)
        compare2Day(d23, letter: "KS", start: 5110)
        compare2Day(d23, letter: "KT", start: 5475)
        compare2Day(d23, letter: "KU", start: 5840)
        compare2Day(d23, letter: "KV", start: 6205)
        compare2Day(d23, letter: "KW", start: 6570)
        compare2Day(d23, letter: "KX", start: 6935)
        compare2Day(d23, letter: "KY", start: 7300)
        compare2Day(d23, letter: "KZ", start: 7665)
        compare2Day(d23, letter: "LA", start: 8030)
        compare2Day(d23, letter: "LB", start: 8395)
        compare2Day(d23, letter: "LC", start: 8760)
        compare2Day(d23, letter: "LD", start: 9125)
        compare2Day(d23, letter: "LE", start: 9490)
        compare2Day(d23, letter: "LG", start: 9855)
        compare2Day(d23, letter: "LH", start: 10_220)
        compare2Day(d23, letter: "LI", start: 10_585)
        compare2Day(d23, letter: "LJ", start: 10_950)
        compare2Day(d23, letter: "LK", start: 11_315)
        compare2Day(d23, letter: "LL", start: 11_680)
        compare2Day(d23, letter: "LM", start: 12_045)
        compare2Day(d23, letter: "LN", start: 12_410)
        compare2Day(d23, letter: "LO", start: 12_775)
        compare2Day(d23, letter: "LP", start: 13_140)
        compare2Day(d23, letter: "LQ", start: 13_505)
        compare2Day(d23, letter: "LR", start: 13_870)
        compare2Day(d23, letter: "LS", start: 14_235)
        compare2Day(d23, letter: "LT", start: 14_600)
        compare2Day(d23, letter: "LU", start: 14_965)
        compare2Day(d23, letter: "LV", start: 15_330)
        compare2Day(d23, letter: "LW", start: 15_695)
        compare2Day(d23, letter: "LX", start: 16_060)
        compare2Day(d23, letter: "LY", start: 16_425)
        compare2Day(d23, letter: "LZ", start: 16_790)
        compare2Day(d23, letter: "MB", start: 17_155)
        compare2Day(d23, letter: "MC", start: 17_520)
        compare2Day(d23, letter: "MD", start: 17_885)
        compare2Day(d23, letter: "ME", start: 18_250)
        compare2Day(d23, letter: "MF", start: 18_615)
        compare2Day(d23, letter: "MG", start: 18_980)
        compare2Day(d23, letter: "MH", start: 19_345)
        compare2Day(d23, letter: "MI", start: 19_710)
        compare2Day(d23, letter: "MJ", start: 20_075)
        compare2Day(d23, letter: "MK", start: 20_440)
        compare2Day(d23, letter: "ML", start: 20_805)
        compare2Day(d23, letter: "MM", start: 21_170)
        compare2Day(d23, letter: "MN", start: 21_535)
        compare2Day(d23, letter: "MO", start: 21_900)
        compare2Day(d23, letter: "MP", start: 22_265)
        compare2Day(d23, letter: "MQ", start: 22_630)
        compare2Day(d23, letter: "MR", start: 22_995)
        compare2Day(d23, letter: "MS", start: 23_360)
        compare2Day(d23, letter: "MT", start: 23_725)
        compare2Day(d23, letter: "MU", start: 24_090)
        compare2Day(d23, letter: "MW", start: 24_455)
        compare2Day(d23, letter: "MX", start: 24_820)
        compare2Day(d23, letter: "MY", start: 25_185)
        compare2Day(d23, letter: "NA", start: 25_915)
        compare2Day(d23, letter: "NB", start: 26_280)
        compare2Day(d23, letter: "NC", start: 26_645)
        compare2Day(d23, letter: "ND", start: 27_010)
        compare2Day(d23, letter: "NE", start: 27_375)
        compare2Day(d23, letter: "NG", start: 28_105)
        compare2Day(d23, letter: "NH", start: 28_470)
        compare2Day(d23, letter: "NJ", start: 29_200)
        compare2Day(d23, letter: "NK", start: 29_565)
        compare2Day(d23, letter: "NL", start: 29_930)
        compare2Day(d23, letter: "NM", start: 30_295)
        compare2Day(d23, letter: "NN", start: 30_660)
        compare2Day(d23, letter: "NO", start: 31_025)
        compare2Day(d23, letter: "NP", start: 31_390)
        compare2Day(d23, letter: "NQ", start: 31_755)
        compare2Day(d23, letter: "NR", start: 32_120)
        compare2Day(d23, letter: "NS", start: 32_485)
        compare2Day(d23, letter: "NU", start: 33_215)
        compare2Day(d23, letter: "NV", start: 33_580)
        compare2Day(d23, letter: "NW", start: 33_945)
        compare2Day(d23, letter: "NX", start: 34_310)
        compare2Day(d23, letter: "NY", start: 34_675)
        compare2Day(d23, letter: "NZ", start: 35_040)
        compare2Day(d23, letter: "OB", start: 35_405)
        compare2Day(d23, letter: "OC", start: 35_770)
        compare2Day(d23, letter: "OD", start: 36_135)
        compare2Day(d23, letter: "OF", start: 36_865)
        compare2Day(d23, letter: "OG", start: 37_230)
        compare2Day(d23, letter: "OH", start: 37_595)
        compare2Day(d23, letter: "OI", start: 37_960)
        compare2Day(d23, letter: "OJ", start: 38_325)
        compare2Day(d23, letter: "OL", start: 39_055)
        compare2Day(d23, letter: "OM", start: 39_420)
        compare2Day(d23, letter: "OO", start: 40_150)
        compare2Day(d23, letter: "OP", start: 40_515)
        compare2Day(d23, letter: "OQ", start: 40_880)
        compare2Day(d23, letter: "OR", start: 41_245)
        compare2Day(d23, letter: "OT", start: 47_815)
        compare2Day(d23, letter: "OU", start: 42_340)
        compare2Day(d23, letter: "OV", start: 42_705)
        compare2Day(d23, letter: "OW", start: 43_070)
        compare2Day(d23, letter: "OX", start: 43_435)
        compare2Day(d23, letter: "OZ", start: 44_165)
        compare2Day(d23, letter: "PA", start: 44_530)
        compare2Day(d23, letter: "PB", start: 44_895)
        compare2Day(d23, letter: "PC", start: 45_260)
        compare2Day(d23, letter: "PD", start: 45_625)  
      }

      if j == 2 {
        compare2Day(d23, letter: "PG", start: 0)
        compare2Day(d23, letter: "PH", start: 365)
        compare2Day(d23, letter: "PI", start: 730)
        compare2Day(d23, letter: "PJ", start: 1095)
        compare2Day(d23, letter: "PK", start: 1460)
        compare2Day(d23, letter: "PL", start: 1825)
        compare2Day(d23, letter: "PM", start: 2190)
        compare2Day(d23, letter: "PN", start: 2555)
        compare2Day(d23, letter: "PO", start: 2920)
        compare2Day(d23, letter: "PP", start: 3285)
        compare2Day(d23, letter: "PQ", start: 3650)
        compare2Day(d23, letter: "PR", start: 4015)
        compare2Day(d23, letter: "PS", start: 4380)
        compare2Day(d23, letter: "PT", start: 4745)
        compare2Day(d23, letter: "PU", start: 5110)
        compare2Day(d23, letter: "PV", start: 5475)
        compare2Day(d23, letter: "PW", start: 5840)
        compare2Day(d23, letter: "PX", start: 6205)
        compare2Day(d23, letter: "PY", start: 6570)
        compare2Day(d23, letter: "PZ", start: 6935)
        compare2Day(d23, letter: "QA", start: 7300)
        compare2Day(d23, letter: "QB", start: 7665)
        compare2Day(d23, letter: "QC", start: 8030)
        compare2Day(d23, letter: "QD", start: 8395)
        compare2Day(d23, letter: "QE", start: 8760)
        compare2Day(d23, letter: "QF", start: 9125)
        compare2Day(d23, letter: "QG", start: 9490)
        compare2Day(d23, letter: "QI", start: 9855)
        compare2Day(d23, letter: "QJ", start: 10_220)
        compare2Day(d23, letter: "QK", start: 10_585)
        compare2Day(d23, letter: "QL", start: 10_950)
        compare2Day(d23, letter: "QM", start: 11_315)
        compare2Day(d23, letter: "QN", start: 11_680)
        compare2Day(d23, letter: "QO", start: 12_045)
        compare2Day(d23, letter: "QP", start: 12_410)
        compare2Day(d23, letter: "QQ", start: 12_775)
        compare2Day(d23, letter: "QR", start: 13_140)
        compare2Day(d23, letter: "QS", start: 13_505)
        compare2Day(d23, letter: "QT", start: 13_870)
        compare2Day(d23, letter: "QU", start: 14_235)
        compare2Day(d23, letter: "QV", start: 14_600)
        compare2Day(d23, letter: "QW", start: 14_965)
        compare2Day(d23, letter: "QX", start: 15_330)
        compare2Day(d23, letter: "QY", start: 15_695)
        compare2Day(d23, letter: "QZ", start: 16_060)
        compare2Day(d23, letter: "RA", start: 16_425)
        compare2Day(d23, letter: "RB", start: 16_790)
        compare2Day(d23, letter: "RD", start: 17_155)
        compare2Day(d23, letter: "RE", start: 17_520)
        compare2Day(d23, letter: "RF", start: 17_885)
        compare2Day(d23, letter: "RG", start: 18_250)
        compare2Day(d23, letter: "RH", start: 18_615)
        compare2Day(d23, letter: "RI", start: 18_980)
        compare2Day(d23, letter: "RJ", start: 19_345)
        compare2Day(d23, letter: "RK", start: 19_710)
        compare2Day(d23, letter: "RL", start: 20_075)
        compare2Day(d23, letter: "RM", start: 20_440)
        compare2Day(d23, letter: "RN", start: 20_805)
        compare2Day(d23, letter: "RO", start: 21_170)
        compare2Day(d23, letter: "RP", start: 21_535)
        compare2Day(d23, letter: "RQ", start: 21_900)
        compare2Day(d23, letter: "RR", start: 22_265)
        compare2Day(d23, letter: "RS", start: 22_630)
        compare2Day(d23, letter: "RT", start: 22_995)
        compare2Day(d23, letter: "RU", start: 23_360)
        compare2Day(d23, letter: "RV", start: 23_725)
        compare2Day(d23, letter: "RW", start: 24_090)
        compare2Day(d23, letter: "RY", start: 24_455)
        compare2Day(d23, letter: "RZ", start: 24_820)
        compare2Day(d23, letter: "SA", start: 25_185)
        compare2Day(d23, letter: "SC", start: 25_915)
        compare2Day(d23, letter: "SD", start: 26_280)
        compare2Day(d23, letter: "SE", start: 26_645)
        compare2Day(d23, letter: "SF", start: 27_010)
        compare2Day(d23, letter: "SG", start: 27_375)
        compare2Day(d23, letter: "SI", start: 28_105)
        compare2Day(d23, letter: "SJ", start: 28_470)
        compare2Day(d23, letter: "SL", start: 29_200)
        compare2Day(d23, letter: "SM", start: 29_565)
        compare2Day(d23, letter: "SN", start: 29_930)
        compare2Day(d23, letter: "SO", start: 30_295)
        compare2Day(d23, letter: "SP", start: 30_660)
        compare2Day(d23, letter: "SQ", start: 31_025)
        compare2Day(d23, letter: "SR", start: 31_390)
        compare2Day(d23, letter: "SS", start: 31_755)
        compare2Day(d23, letter: "ST", start: 32_120)
        compare2Day(d23, letter: "SU", start: 32_485)
        compare2Day(d23, letter: "SV", start: 32_850)
        compare2Day(d23, letter: "SW", start: 33_215)
        compare2Day(d23, letter: "SX", start: 33_580)
        compare2Day(d23, letter: "SY", start: 33_945)
        compare2Day(d23, letter: "SZ", start: 34_310)
        compare2Day(d23, letter: "TA", start: 34_675)
        compare2Day(d23, letter: "TB", start: 35_040)
        compare2Day(d23, letter: "TD", start: 35_405)
        compare2Day(d23, letter: "TE", start: 35_770)
        compare2Day(d23, letter: "TF", start: 36_135)
        compare2Day(d23, letter: "TH", start: 36_865)
        compare2Day(d23, letter: "TI", start: 37_230)
        compare2Day(d23, letter: "TJ", start: 37_595)
        compare2Day(d23, letter: "TK", start: 37_960)
        compare2Day(d23, letter: "TL", start: 38_325)
        compare2Day(d23, letter: "TN", start: 39_055)
        compare2Day(d23, letter: "TO", start: 39_420)
        compare2Day(d23, letter: "TQ", start: 40_150)
        compare2Day(d23, letter: "TR", start: 40_515)
        compare2Day(d23, letter: "TS", start: 40_880)
        compare2Day(d23, letter: "TT", start: 41_245)
        compare2Day(d23, letter: "TV", start: 47_815)
        compare2Day(d23, letter: "TW", start: 42_340)
        compare2Day(d23, letter: "TX", start: 42_705)
        compare2Day(d23, letter: "TY", start: 43_070)
        compare2Day(d23, letter: "TZ", start: 43_435)
        compare2Day(d23, letter: "UB", start: 44_165)
        compare2Day(d23, letter: "UC", start: 44_530)
        compare2Day(d23, letter: "UD", start: 44_895)
        compare2Day(d23, letter: "UE", start: 45_260)
        compare2Day(d23, letter: "UF", start: 45_625)  
      }
    }
    print("Calc", calc.joined(separator: " "))
    print("Daily1", day1.joined(separator: " "))
    print("Daily2", day2.joined(separator: " "))
  }

  func testsCalculation2() {
    guard let model = TunOl(
      [300.00,5000.00,120.00,1500.00,1700.00,200.00,0.00,500.00,1000.00,100000.00,100000.00,20.00,120.00,0.00,50.00,0.00]
      ) else {
      print("Invalid config")
      return
    }

    let costs = Costs(model)

    let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)

    let hour1 = model.hour1(hour0: hour0, reserved: model.Overall_harmonious_min_perc)
    let day0 = model.day0(hour0: hour0)
    let d22 = model.d22(hour0: hour0)
    var day = [[Double]]()

    var hour2 = [Double](repeating: .zero, count: 183_960)
    var hour3 = [Double](repeating: .zero, count: 297_840)
    var hour4 = [Double](repeating: .zero, count: 516_840)
    var d10 = [Double](repeating: .zero, count: 13_140)
    var d11 = [Double](repeating: .zero, count: 17_155)
    var d12 = [Double](repeating: .zero, count: 17_155)
    var d13 = [Double](repeating: .zero, count: 47_085)
    var d23 = [Double](repeating: .zero, count: 48_545)
    var d21 = [Double](repeating: .zero, count: 9855)

    let GX = 16790
    let GZ = 17155
    let HA = 17520

    for j in 0..<4 {
      model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
      model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
      model.d10(&d10, case: j, hour2: hour2, hour3: hour3)
      model.hour4(&hour4, j: j, d1: d10, hour0: hour0, hour1: hour1, hour2: hour2, hour3: hour3)
      model.night(case: j, d10: &d10, hour3: hour3, hour4: hour4)
      model.d11(case: j, &d11, hour0: hour0, hour2: hour2, hour3: hour3)
      model.d12(case: j, &d12, hour0: hour0, hour4: hour4)
      model.d13(&d13, case: j, d10: d10, d11: d11, d12: d12)
      model.d14(&d13, case: j, d10: d10, d11: d11, d12: d12)
      day.append(Array(d13[31755..<33945]))
      day.append(Array(d13[44165..<46355]))

      model.d21(&d21, case: j, day0: day0)
      model.d23(&d23, case: j, day0: day0, d21: d21, d22: d22)

      day.append(Array(d23[33945..<35040] + ArraySlice(zip(day0[365..<730], d23[GX..<GZ]).map { $1 > 0 ? $0 : 0}) + day0[730..<1095]))
      day.append(Array(d23[44895..<45990] + ArraySlice(zip(day0[365..<730], d23[GZ..<HA]).map { $1 > 0 ? $0 : 0}) + day0[730..<1095]))
    }

    var meth_produced_MTPH_sum = Double.zero
    var elec_from_grid_sum = Double.zero
    var elec_to_grid_MTPH_sum = Double.zero

    let name = ["1a day prio", "1a night prio", "2a day prio", "2a night prio", "1b day prio", "1b night prio", "2b day prio", "2b night prio", "1c day prio", "1c night prio", "2c day prio", "2c night prio", "1d day prio", "1d night prio", "2d day prio", "2d night prio"]
    var charts = [Int]()
    var hours_sum = 0.0
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
        print(d, name[best], day[best][d], hours0, hours1)
        hours_sum += hours0 + hours1
      }
    }

    let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
    XCTAssertEqual(LCOM, 2548, accuracy: 1, "LCOM")
    XCTAssertEqual(hours_sum, 7741, accuracy: 1, "hours_sum")
    XCTAssertEqual(meth_produced_MTPH_sum, 83515, accuracy: 1, "meth_produced_MTPH_sum")
    XCTAssertEqual(elec_from_grid_sum, 18247, accuracy: 1, "elec_from_grid_sum")
    XCTAssertEqual(elec_to_grid_MTPH_sum, 54231, accuracy: 1, "elec_to_grid_MTPH_sum")
  }

  func testsCosts() {
    guard let model = TunOl([0.00, 400.00, 5.20, 311.38, 584.47, 200.00, 1000, 100, 1221.72, 10_000, 30_000, 15.17, 10.44, 123.63, 50, 0.00]) else { return }
    //  dump(model)
    let costs = Costs(model)
    // dump(costs)
    var fixtures = [
      0.0, 0.0, 271_850_862.509_697_9, 22_885_530.347_053_397, 25_708_090.216_960_527, 12_437_574.020_599_108, 63_482_959.972_115_204, 430_140_000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24_684_376.583_671_547, 44_763_724.383_25, 1_937_238.624_602_197, 1_197_447.845_153_448_4,
    ]
    .makeIterator()

    for child in Mirror(reflecting: costs).children.filter({ $0.label?.contains("cost") ?? false }) { XCTAssertEqual(child.value as! Double, fixtures.next()!, accuracy: 1, child.label!) }
  }

  let columns0 = [
    "H": 8760, "I": 17_520, "J": 26_280, "K": 35_040, "L": 43_800, "M": 52_560, "O": 61_320, "P": 70_080, "Q": 78_840,
    "R": 87_600, "S": 96_360, "T": 105_120, "U": 113_880, "V": 122_640, "W": 131_400, "X": 140_160, "Y": 148_920,
    "Z": 157_680, "AA": 166_440, "AB": 175_200, "AC": 183_960, "AD": 192_720, "AE": 201_480, "AF": 210_240,
    "AG": 219_000, "AH": 227_760, "AI": 236_520, "AJ": 245_280, "AK": 254_040, "AL": 262_800, "AM": 271_560,
    "AN": 280_320, "AO": 289_080, "AP": 297_840, "AQ": 306_600, "AR": 315_360, "AS": 324_120, "AT": 332_880,
    "AV": 3_500_400, "AW": 3_509_160, "AX": 3_517_920,
  ]
  let columns1 = [
    "AY": 26_280, "AZ": 35_040, "BA": 43_800, "BB": 52_560, "BC": 61_320, "BD": 70_080, "BE": 78_840, "BF": 87_600,
    "BG": 96_360, "BH": 105_120, "BI": 113_880, "BJ": 122_640, "BK": 131_400, "BL": 140_160, "BM": 148_920,
    "BN": 157_680, "BO": 166_440, "BP": 175_200, "BQ": 183_960,
  ]
  let columns2A = [
    "BU": 0, "BV": 8760, "BW": 17_520, "BX": 26_280, "BY": 35_040, "BZ": 43_800, "CA": 52_560, "CB": 61_320,
    "CC": 70_080, "CD": 78_840, "CE": 87_600, "CF": 96_360, "CG": 105_120, "CH": 113_880, "CI": 122_640,
    "CJ": 131_400, "CK": 140_160, "CL": 148_920, "CM": 157_680, "BT": 175_200,
  ]
  let columns2C = [
    "KK": 0, "KL": 8760, "KM": 17_520, "KN": 26_280, "KO": 35_040, "KP": 43_800, "KQ": 52_560, "KR": 61_320,
    "KS": 70_080, "KT": 78_840, "KU": 87_600, "KV": 96_360, "KW": 105_120, "KX": 113_880, "KY": 122_640,
    "KZ": 131_400, "LA": 140_160, "LB": 148_920, "LC": 157_680, "LD": 166_440,
  ]
  let columns3A = [
    "CP": 0, "CQ": 8760, "CR": 17_520, "CN": 289_080, "CS": 26_280, "CT": 35_040, "CU": 43_800, "CV": 52_560,
    "CW": 61_320, "CX": 70_080, "CY": 78_840, "CZ": 87_600, "DG": 148_920, "DH": 157_680, "DI": 166_440,
    "DJ": 175_200, "DK": 183_960, "DL": 192_720, "DM": 201_480, "DN": 210_240, "DO": 219_000, "DP": 227_760,
    "DQ": 236_520, "DR": 245_280, "DS": 254_040, "DT": 262_800, "DU": 280_320,
  ]
  let columns4A = [
    "DV": 0, "DW": 8760, "DX": 17_520, "DY": 26_280, "DZ": 35_040, "EA": 43_800, "EB": 52_560, "EC": 61_320,
    "ED": 70_080, "EE": 78_840, "EF": 87_600, "EG": 96_360, "EH": 105_120, "EI": 113_880, "EJ": 122_640,
    "EK": 131_400, "EL": 140_160, "EM": 148_920, "EN": 157_680, "EO": 166_440, "EP": 175_200, "EQ": 183_960,
    "ER": 192_720, "ES": 201_480, "ET": 210_240, "EU": 219_000, "EW": 227_760, "EX": 236_520, "EY": 245_280,
    "EZ": 254_040, "FA": 262_800, "FB": 271_560, "FC": 280_320, "FD": 289_080, "FE": 297_840, "FF": 306_600,
    "FG": 315_360, "FH": 324_120, "FI": 332_880, "FJ": 341_640, "FK": 350_400, "FL": 359_160, "FM": 367_920,
    "FN": 376_680, "FO": 385_440, "FP": 394_200, "FQ": 402_960, "FR": 411_720, "FS": 420_480, "FT": 429_240,
    "FU": 438_000, "FV": 446_760, "FW": 455_520, "FX": 464_280, "FY": 473_040, "FZ": 481_800, "GA": 490_560,
  ]
  let columns4C = [
    "MM": 8760, "MN": 17_520, "MO": 26_280, "MP": 35_040, "MQ": 43_800, "MR": 52_560, "MS": 61_320, "MT": 70_080,
    "MU": 78_840, "MV": 87_600, "MW": 96_360, "MX": 105_120, "MY": 113_880, "MZ": 122_640, "NA": 131_400,
    "NB": 140_160, "NC": 148_920, "ND": 157_680, "NE": 166_440, "NF": 175_200, "NG": 183_960, "NH": 192_720,
    "NI": 201_480, "NJ": 210_240, "NK": 219_000,
  ]
  let columns10 = [
    "C": 0, "D": 365, "E": 730, "F": 1095, "H": 1825, "J": 2555, "L": 3285, "M": 3650, "N": 4015, "O": 4380,
    "P": 4745, "T": 5840, "W": 6935, "Z": 8030, "AA": 8395, "AB": 8760, "AC": 9125, "AJ": 11_680, "AK": 12_045,
    "AL": 12_410, "AM": 12_775,
  ]
  let columns22 = [
    "DR": 0, "DS": 365, "DT": 730, "DU": 1095, "DV": 1460, "DW": 1825, "DX": 2190, "DY": 2555, "DZ": 2920, "EA": 3285,
    "EB": 3650, "EC": 4015, "ED": 4380, "EE": 4745, "EF": 5110, "EG": 5475, "EH": 5840, "EI": 6205, "EJ": 6570,
    "EK": 6935, "EL": 7300, "EM": 7665, "EN": 8030, "EO": 8395, "EP": 8760, "EQ": 9125, "ER": 9490, "ES": 9855,
    "ET": 10_220, "EU": 10_585, "EV": 10_950, "EW": 11_315, "EX": 11_680, "EY": 12_045, "EZ": 12_410, "FA": 12_775,
    "DM": 13_140, "DN": 13_505, "DO": 13_870,
  ]
}
