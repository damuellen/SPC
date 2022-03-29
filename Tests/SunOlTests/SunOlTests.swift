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
    let csv_ref = CSV(atPath: "/workspaces/SPC/calc.csv", separator: "\t")!
    let csv_ref2 = CSV(atPath: "/workspaces/SPC/daily1.csv", separator: "\t")!
    // let csv_ref3 = CSV(atPath: "/workspaces/SPC/daily2.csv", separator: "\t")!

    func compare(_ array: [Double], letter: String, start index: Int) {
      let index = index
      let ref = csv_ref[letter]
      var correct = true
      for i in 1..<8736 {
        if abs(ref[i - 1] - array[index + i]) > 0.1 {
          correct = false
          print(letter, i, ref[i - 1], "not equal", array[index + i])
        }
      }
      if correct { print(letter, "all equal") }
    }

    func compareDay(_ array: [Double], letter: String, start index: Int) {
      let index = index
      let ref = csv_ref2[letter]
      var correct = true
      for i in 0..<364 {
        if abs(ref[i] - array[index + i]) > 0.2 {
          correct = false
          print(letter, i, ref[i], "not equal", array[index + i])
        }
      }
      if correct { print(letter, "all equal") }
    }

    func compareDay2(_ array: [Double], letter: String, start index: Int) {
      // let index = index
      // let ref = csv_ref3[letter]
      // var correct = true
      // for i in 0..<365 {
      //   if abs(ref[i] - array[index+i]) > 0.1 {
      //     correct = false
      //     print(letter, i, ref[i], "not equal", array[index+i])
      //   }
      // }
      // if correct { print(letter, "all equal") }
    }

    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]
    let model = TunOl([])
    let costs = Costs(model)
    let hour0 = model.hour0(
      TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)

    compare(hour0, letter: "H", start: 8760)
    compare(hour0, letter: "I", start: 17520)
    compare(hour0, letter: "J", start: 26280)
    compare(hour0, letter: "K", start: 35040)
    compare(hour0, letter: "L", start: 43800)
    compare(hour0, letter: "M", start: 52560)
    compare(hour0, letter: "O", start: 61320)
    compare(hour0, letter: "P", start: 70080)
    compare(hour0, letter: "Q", start: 78840)
    compare(hour0, letter: "R", start: 87600)
    compare(hour0, letter: "S", start: 96360)
    compare(hour0, letter: "T", start: 105120)
    compare(hour0, letter: "U", start: 113880)

    compare(hour0, letter: "V", start: 122640)
    compare(hour0, letter: "W", start: 131400)
    compare(hour0, letter: "X", start: 140160)
    compare(hour0, letter: "Y", start: 148920)
    compare(hour0, letter: "Z", start: 157680)
    compare(hour0, letter: "AA", start: 166440)
    compare(hour0, letter: "AB", start: 175200)
    compare(hour0, letter: "AC", start: 183960)

    compare(hour0, letter: "AD", start: 192720)
    compare(hour0, letter: "AE", start: 201480)
    compare(hour0, letter: "AF", start: 210240)
    compare(hour0, letter: "AG", start: 219000)
    compare(hour0, letter: "AH", start: 227760)
    compare(hour0, letter: "AI", start: 236520)
    compare(hour0, letter: "AJ", start: 245280)
    compare(hour0, letter: "AK", start: 254040)

    compare(hour0, letter: "AL", start: 262800)
    compare(hour0, letter: "AM", start: 271560)
    compare(hour0, letter: "AN", start: 280320)
    compare(hour0, letter: "AO", start: 289080)
    compare(hour0, letter: "AP", start: 297840)
    compare(hour0, letter: "AQ", start: 306600)
    compare(hour0, letter: "AR", start: 315360)
    compare(hour0, letter: "AS", start: 324120)
    compare(hour0, letter: "AT", start: 332880)

    // print("Calculation")
    // Array(hour0[..<61320]).head(6, steps: 8760)
    // print("Calculation")
    // Array(hour0[61320..<113880]).head(14, steps: 8760)
    // print("Calculation")

    let hour1 = model.hour1(hour0: hour0)

    compare(hour1, letter: "AV", start: 0)
    compare(hour1, letter: "AW", start: 8760)
    compare(hour1, letter: "AX", start: 17520)
    compare(hour1, letter: "AY", start: 26280)
    compare(hour1, letter: "AZ", start: 35040)
    compare(hour1, letter: "BA", start: 43800)
    compare(hour1, letter: "BB", start: 52560)
    compare(hour1, letter: "BC", start: 61320)
    compare(hour1, letter: "BD", start: 70080)
    compare(hour1, letter: "BE", start: 78840)
    compare(hour1, letter: "BF", start: 87600)
    compare(hour1, letter: "BG", start: 96360)
    compare(hour1, letter: "BH", start: 105120)
    compare(hour1, letter: "BI", start: 113880)
    compare(hour1, letter: "BJ", start: 122640)
    compare(hour1, letter: "BK", start: 131400)
    compare(hour1, letter: "BL", start: 140160)
    compare(hour1, letter: "BM", start: 148920)
    compare(hour1, letter: "BN", start: 157680)
    compare(hour1, letter: "BO", start: 166440)
    compare(hour1, letter: "BP", start: 175200)
    compare(hour1, letter: "BQ", start: 183960)
    print("Calculation")
    // hour1.head(47, steps: 8760)

    let day6 = model.day(hour0: hour0)
    print("Daily 2")
    // Array(day6[0..<5840]).head(121, steps: 365)
    // print("Daily 2")
    // Array(day6[5840...]).head(137, steps: 365)

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
        compare(hour2, letter: "BU", start: 0)
        compare(hour2, letter: "BV", start: 8760)
        compare(hour2, letter: "BW", start: 17520)
        compare(hour2, letter: "BX", start: 26280)
        compare(hour2, letter: "BY", start: 35040)
        compare(hour2, letter: "BZ", start: 43800)
        compare(hour2, letter: "CA", start: 52560)
        compare(hour2, letter: "CB", start: 61320)
        compare(hour2, letter: "CC", start: 70080)
        compare(hour2, letter: "CD", start: 78840)
        compare(hour2, letter: "CE", start: 87600)
        compare(hour2, letter: "CF", start: 96360)
        compare(hour2, letter: "CG", start: 105120)
        compare(hour2, letter: "CH", start: 113880)
        compare(hour2, letter: "CI", start: 122640)
        compare(hour2, letter: "CJ", start: 131400)
        compare(hour2, letter: "CK", start: 140160)
        compare(hour2, letter: "CL", start: 148920)
        compare(hour2, letter: "CM", start: 157680)
        compare(hour2, letter: "CN", start: 166440)
        print("Hour Case", j)// hour2.head(72, steps: 8760)
      }
      if j == 1 {
        print("Hour Case", j)// hour2.head(184, steps: 8760)
      }
      if j == 2 {
        compare(hour2, letter: "KK", start: 0)
        compare(hour2, letter: "KL", start: 8760)
        compare(hour2, letter: "KM", start: 17520)
        compare(hour2, letter: "KN", start: 26280)
        compare(hour2, letter: "KO", start: 35040)
        compare(hour2, letter: "KP", start: 43800)
        compare(hour2, letter: "KQ", start: 52560)
        compare(hour2, letter: "KR", start: 61320)
        compare(hour2, letter: "KS", start: 70080)
        compare(hour2, letter: "KT", start: 78840)
        compare(hour2, letter: "KU", start: 87600)
        compare(hour2, letter: "KV", start: 96360)
        compare(hour2, letter: "KW", start: 105120)
        compare(hour2, letter: "KX", start: 113880)
        compare(hour2, letter: "KY", start: 122640)
        compare(hour2, letter: "KZ", start: 131400)
        compare(hour2, letter: "LA", start: 140160)
        compare(hour2, letter: "LB", start: 148920)
        compare(hour2, letter: "LC", start: 157680)
        compare(hour2, letter: "LD", start: 166440)
        print("Hour Case", j)// hour2.head(296, steps: 8760)
      }

      model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
      print("Hour Case", j)
      // hour3.head(93, steps: 8760)

      model.day1(&day1, case: j, hour2: hour2, hour3: hour3)
      if j == 0 {
        compareDay(day1, letter: "D", start: 365)
        compareDay(day1, letter: "E", start: 730)
        compareDay(day1, letter: "F", start: 1095)
        compareDay(day1, letter: "G", start: 1460)
        compareDay(day1, letter: "H", start: 1825)
        compareDay(day1, letter: "I", start: 2190)
        compareDay(day1, letter: "J", start: 2555)
        compareDay(day1, letter: "K", start: 2920)
        compareDay(day1, letter: "L", start: 3285)
      }
      if j == 2 {
        compareDay(day1, letter: "CB", start: 365)
        compareDay(day1, letter: "CC", start: 730)
        compareDay(day1, letter: "CH", start: 2555)
        compareDay(day1, letter: "CI", start: 2920)
        compareDay(day1, letter: "CJ", start: 3285)
        compareDay(day1, letter: "CK", start: 3650)
        compareDay(day1, letter: "CL", start: 4015)
        compareDay(day1, letter: "CM", start: 4380)
        compareDay(day1, letter: "CN", start: 4745)
        compareDay(day1, letter: "CO", start: 5110)
        compareDay(day1, letter: "CP", start: 5475)
      }
      model.hour4(&hour4, j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
      if j == 0 {
        compare(hour4, letter: "DV", start: 0)
        compare(hour4, letter: "DW", start: 8760)
        compare(hour4, letter: "DX", start: 17520)
        compare(hour4, letter: "DY", start: 26280)
        compare(hour4, letter: "DZ", start: 35040)
        compare(hour4, letter: "EA", start: 43800)
        compare(hour4, letter: "EB", start: 52560)
        compare(hour4, letter: "EC", start: 61320)
        compare(hour4, letter: "ED", start: 70080)
        compare(hour4, letter: "EE", start: 78840)
        compare(hour4, letter: "EF", start: 87600)
        compare(hour4, letter: "EG", start: 96360)
        compare(hour4, letter: "EH", start: 105120)
        compare(hour4, letter: "EI", start: 113880)
        compare(hour4, letter: "EJ", start: 122640)
        compare(hour4, letter: "EK", start: 131400)
        compare(hour4, letter: "EL", start: 140160)
        compare(hour4, letter: "EM", start: 148920)
        compare(hour4, letter: "EN", start: 157680)
        compare(hour4, letter: "EO", start: 166440)
        compare(hour4, letter: "EP", start: 175200)
        compare(hour4, letter: "EQ", start: 183960)
        compare(hour4, letter: "ER", start: 192720)
        compare(hour4, letter: "ES", start: 201480)
        compare(hour4, letter: "ET", start: 210240)
        compare(hour4, letter: "EU", start: 219000)
        compare(hour4, letter: "EW", start: 227760)
        compare(hour4, letter: "EX", start: 236520)
        compare(hour4, letter: "EY", start: 245280)
        compare(hour4, letter: "EZ", start: 254040)
        compare(hour4, letter: "FA", start: 262800)
        compare(hour4, letter: "FB", start: 271560)
        compare(hour4, letter: "FC", start: 280320)
        compare(hour4, letter: "FD", start: 289080)
        compare(hour4, letter: "FE", start: 297840)
        compare(hour4, letter: "FF", start: 306600)
        compare(hour4, letter: "FG", start: 315360)
        compare(hour4, letter: "FH", start: 324120)
        compare(hour4, letter: "FI", start: 332880)
        compare(hour4, letter: "FJ", start: 341640)
        compare(hour4, letter: "FK", start: 350400)
        compare(hour4, letter: "FL", start: 359160)
        compare(hour4, letter: "FM", start: 367920)
        compare(hour4, letter: "FN", start: 376680)
        compare(hour4, letter: "FO", start: 385440)
        compare(hour4, letter: "FP", start: 394200)
        compare(hour4, letter: "FQ", start: 402960)
        compare(hour4, letter: "FR", start: 411720)
        compare(hour4, letter: "FS", start: 420480)
        compare(hour4, letter: "FT", start: 429240)
        compare(hour4, letter: "FU", start: 438000)
        compare(hour4, letter: "FV", start: 446760)
        compare(hour4, letter: "FW", start: 455520)
        compare(hour4, letter: "FX", start: 464280)
        compare(hour4, letter: "FY", start: 473040)
        compare(hour4, letter: "FZ", start: 481800)
        compare(hour4, letter: "GA", start: 490560)
      }
      if j == 2 {
        compare(hour4, letter: "MM", start: 8760)
        compare(hour4, letter: "MN", start: 17520)
        compare(hour4, letter: "MO", start: 26280)
        compare(hour4, letter: "MP", start: 35040)
        compare(hour4, letter: "MQ", start: 43800)
        compare(hour4, letter: "MR", start: 52560)
        compare(hour4, letter: "MS", start: 61320)
        compare(hour4, letter: "MT", start: 70080)
        compare(hour4, letter: "MU", start: 78840)
        compare(hour4, letter: "MV", start: 87600)
        compare(hour4, letter: "MW", start: 96360)
        compare(hour4, letter: "MX", start: 105120)
        compare(hour4, letter: "MY", start: 113880)
        compare(hour4, letter: "MZ", start: 122640)
        compare(hour4, letter: "NA", start: 131400)
        compare(hour4, letter: "NB", start: 140160)
        compare(hour4, letter: "NC", start: 148920)
        compare(hour4, letter: "ND", start: 157680)
        compare(hour4, letter: "NE", start: 166440)
        compare(hour4, letter: "NF", start: 175200)
        compare(hour4, letter: "NG", start: 183960)
        compare(hour4, letter: "NH", start: 192720)
        compare(hour4, letter: "NI", start: 201480)
        compare(hour4, letter: "NJ", start: 210240)
        compare(hour4, letter: "NK", start: 219000)
      }
      print("Hour Case", j)
      // Array(hour4[0..<227760]).head(125, steps: 8760)
      // Array(hour4[227760...]).head(152, steps: 8760)

      model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
      print("Daily Case", j)
      // Array(day1[0..<5840]).head(2, steps: 365)
      // print("Daily Case", j)
      // Array(day1[5840...]).head(19, steps: 365)

      model.day15(&day15, hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
      if j == 0 {
        compareDay(day15, letter: "EY", start: 0)
        compareDay(day15, letter: "EZ", start: 365)

        compareDay(day15, letter: "FR", start: 6935)
        compareDay(day15, letter: "FS", start: 7300)
        print("Daily Case", j)// Array(day15[0..<9125]).head(154, steps: 365)
        // print("Daily Case", j)
        // Array(day15[9125...]).head(179, steps: 365)
      }
      if j == 1 {
        print("Daily Case", j)// Array(day15[0..<9125]).head(376, steps: 365)
        // print("Daily Case", j)
        // Array(day15[9125...]).head(401, steps: 365)
      }
      if j == 2 {
        compareDay(day15, letter: "WO", start: 0)
        compareDay(day15, letter: "WP", start: 365)
        compareDay(day15, letter: "WQ", start: 730)
        compareDay(day15, letter: "WR", start: 1095)
        compareDay(day15, letter: "WS", start: 1460)
        compareDay(day15, letter: "WT", start: 1825)
        compareDay(day15, letter: "WU", start: 2190)
        compareDay(day15, letter: "WV", start: 2555)
        compareDay(day15, letter: "WW", start: 2920)
        compareDay(day15, letter: "WX", start: 3285)
        compareDay(day15, letter: "WY", start: 3650)
        compareDay(day15, letter: "WZ", start: 4015)
        compareDay(day15, letter: "XA", start: 4380)
        compareDay(day15, letter: "XB", start: 4745)
        compareDay(day15, letter: "XC", start: 5110)
        compareDay(day15, letter: "XD", start: 5475)
        compareDay(day15, letter: "XE", start: 5840)
        compareDay(day15, letter: "XF", start: 6205)
        compareDay(day15, letter: "XG", start: 6570)
        compareDay(day15, letter: "XH", start: 6935)
        compareDay(day15, letter: "XI", start: 7300)
        compareDay(day15, letter: "XJ", start: 7665)
        compareDay(day15, letter: "XK", start: 8030)
        compareDay(day15, letter: "XL", start: 8395)
        compareDay(day15, letter: "XM", start: 8760)
        compareDay(day15, letter: "XN", start: 9125)
        compareDay(day15, letter: "XO", start: 9490)
        compareDay(day15, letter: "XP", start: 9855)
        compareDay(day15, letter: "XQ", start: 10220)
        compareDay(day15, letter: "XR", start: 10585)
        compareDay(day15, letter: "XS", start: 10950)
        compareDay(day15, letter: "XT", start: 11315)
        compareDay(day15, letter: "XU", start: 11680)
        compareDay(day15, letter: "XV", start: 12045)
        compareDay(day15, letter: "XW", start: 12410)
        compareDay(day15, letter: "XX", start: 12775)
        compareDay(day15, letter: "XY", start: 13140)
        compareDay(day15, letter: "XZ", start: 13505)
        compareDay(day15, letter: "YA", start: 13870)
        compareDay(day15, letter: "YB", start: 14235)
        compareDay(day15, letter: "YC", start: 14600)
        compareDay(day15, letter: "YD", start: 14965)
        compareDay(day15, letter: "YE", start: 15330)
        compareDay(day15, letter: "YF", start: 15695)
        compareDay(day15, letter: "YG", start: 16060)
        compareDay(day15, letter: "YH", start: 16425)
        compareDay(day15, letter: "YI", start: 16790)

      }
      model.day16(&day16, hour0: hour0, hour4: hour4, day11: day1, day15: day15)
      print("Daily 1 Case", j)
      // Array(day16[..<9125]).head(202, steps: 365)
      // print("Daily 1 Case", j)
      // Array(day16[9125...]).head(227, steps: 365)

      if j == 0 {
        compareDay(day16, letter: "HO", start: 7300)
        compareDay(day16, letter: "HR", start: 8395)
      }

      if j == 2 {
        compareDay(day16, letter: "YK", start: 0)
        compareDay(day16, letter: "YL", start: 365)
        compareDay(day16, letter: "YM", start: 730)
        compareDay(day16, letter: "YN", start: 1095)
        compareDay(day16, letter: "YO", start: 1460)
        compareDay(day16, letter: "YP", start: 1825)
        compareDay(day16, letter: "YQ", start: 2190)
        compareDay(day16, letter: "YR", start: 2555)
        compareDay(day16, letter: "YS", start: 2920)
        compareDay(day16, letter: "YT", start: 3285)
        compareDay(day16, letter: "YU", start: 3650)
        compareDay(day16, letter: "YV", start: 4015)
        compareDay(day16, letter: "YW", start: 4380)
        compareDay(day16, letter: "YX", start: 4745)
        compareDay(day16, letter: "YY", start: 5110)
        compareDay(day16, letter: "YZ", start: 5475)
        compareDay(day16, letter: "ZA", start: 5840)
        compareDay(day16, letter: "ZB", start: 6205)
        compareDay(day16, letter: "ZC", start: 6570)
        compareDay(day16, letter: "ZD", start: 6935)
        compareDay(day16, letter: "ZE", start: 7300)
        compareDay(day16, letter: "ZF", start: 7665)
        compareDay(day16, letter: "ZG", start: 8030)
        compareDay(day16, letter: "ZH", start: 8395)
        compareDay(day16, letter: "ZI", start: 8760)
        compareDay(day16, letter: "ZJ", start: 9125)
        compareDay(day16, letter: "ZK", start: 9490)
        compareDay(day16, letter: "ZL", start: 9855)
        compareDay(day16, letter: "ZM", start: 10220)
        compareDay(day16, letter: "ZN", start: 10585)
        compareDay(day16, letter: "ZO", start: 10950)
        compareDay(day16, letter: "ZP", start: 11315)
        compareDay(day16, letter: "ZQ", start: 11680)
        compareDay(day16, letter: "ZR", start: 12045)
        compareDay(day16, letter: "ZS", start: 12410)
        compareDay(day16, letter: "ZT", start: 12775)
        compareDay(day16, letter: "ZU", start: 13140)
        compareDay(day16, letter: "ZV", start: 13505)
        compareDay(day16, letter: "ZW", start: 13870)
        compareDay(day16, letter: "ZX", start: 14235)
        compareDay(day16, letter: "ZY", start: 14600)
        compareDay(day16, letter: "ZZ", start: 14965)
        compareDay(day16, letter: "AAA", start: 15330)
        compareDay(day16, letter: "AAB", start: 15695)
        compareDay(day16, letter: "AAC", start: 16060)
        compareDay(day16, letter: "AAD", start: 16425)
        compareDay(day16, letter: "AAE", start: 16790)
      }

      model.day17(&day17, case: j, day1: day1, day5: day15, day6: day16)
      if j == 0 {
        compareDay(day17, letter: "IQ", start: 0)
        compareDay(day17, letter: "IR", start: 365)
        compareDay(day17, letter: "IS", start: 730)
        compareDay(day17, letter: "JP", start: 8760)
        compareDay(day17, letter: "JQ", start: 9125)
        compareDay(day17, letter: "JR", start: 9490)
        compareDay(day17, letter: "KG", start: 14965)
        compareDay(day17, letter: "KI", start: 15330)
        compareDay(day17, letter: "KJ", start: 15695)
        compareDay(day17, letter: "KK", start: 16060)
        compareDay(day17, letter: "KZ", start: 21535)
        print("Daily 1 Case", j)// Array(day17[..<7665]).head(250, steps: 365)
        // print("Daily 1 Case", j)
        // Array(day17[7665..<13505]).head(272, steps: 365)
        // print("Daily 1 Case", j)
        // Array(day17[13505..<19345]).head(289, steps: 365)
        // print("Daily 1 Case", j)
        // Array(day17[19345..<31755]).head(306, steps: 365)
        // print("Daily 1 Case", j)
        // Array(day17[31755...]).head(341, steps: 365)
      }

      if j == 0 {

      }

      if j == 1 {

      }
      if j == 2 {
        compareDay(day17, letter: "AAG", start: 0)
        compareDay(day17, letter: "AAH", start: 365)
        compareDay(day17, letter: "AAI", start: 730)
        compareDay(day17, letter: "AAJ", start: 1095)
        compareDay(day17, letter: "AAK", start: 1460)
        compareDay(day17, letter: "AAL", start: 1825)
        compareDay(day17, letter: "AAM", start: 2190)
        compareDay(day17, letter: "AAN", start: 2555)
        compareDay(day17, letter: "AAO", start: 2920)
        compareDay(day17, letter: "AAP", start: 3285)
        compareDay(day17, letter: "AAQ", start: 3650)
        compareDay(day17, letter: "AAR", start: 4015)
        compareDay(day17, letter: "AAS", start: 4380)
        compareDay(day17, letter: "AAT", start: 4745)
        compareDay(day17, letter: "AAU", start: 5110)
        compareDay(day17, letter: "AAV", start: 5475)
        compareDay(day17, letter: "AAW", start: 5840)
        compareDay(day17, letter: "AAX", start: 6205)
        compareDay(day17, letter: "AAY", start: 6570)
        compareDay(day17, letter: "AAZ", start: 6935)
        compareDay(day17, letter: "ABA", start: 7300)
        compareDay(day17, letter: "ABB", start: 7665)
        compareDay(day17, letter: "ABC", start: 8030)
        compareDay(day17, letter: "ABD", start: 8395)

        compareDay(day17, letter: "ABF", start: 8760)
        compareDay(day17, letter: "ABG", start: 9125)
        compareDay(day17, letter: "ABH", start: 9490)
        compareDay(day17, letter: "ABI", start: 9855)
        compareDay(day17, letter: "ABJ", start: 10220)
        compareDay(day17, letter: "ABK", start: 10585)
        compareDay(day17, letter: "ABL", start: 10950)
        compareDay(day17, letter: "ABM", start: 11315)
        compareDay(day17, letter: "ABN", start: 11680)
        compareDay(day17, letter: "ABO", start: 12045)
        compareDay(day17, letter: "ABP", start: 12410)
        compareDay(day17, letter: "ABQ", start: 12775)
        compareDay(day17, letter: "ABR", start: 13140)
        compareDay(day17, letter: "ABS", start: 13505)
        compareDay(day17, letter: "ABT", start: 13870)
        compareDay(day17, letter: "ABU", start: 14235)
        compareDay(day17, letter: "ABV", start: 14600)
        compareDay(day17, letter: "ABW", start: 14965)

        compareDay(day17, letter: "ABY", start: 15330)
        compareDay(day17, letter: "ABZ", start: 15695)
        compareDay(day17, letter: "ACA", start: 16060)
        compareDay(day17, letter: "ACB", start: 16425)
        compareDay(day17, letter: "ACC", start: 16790)
        compareDay(day17, letter: "ACD", start: 17155)
        compareDay(day17, letter: "ACE", start: 17520)
        compareDay(day17, letter: "ACF", start: 17885)
        compareDay(day17, letter: "ACG", start: 18250)
        compareDay(day17, letter: "ACH", start: 18615)
        compareDay(day17, letter: "ACI", start: 18980)
        compareDay(day17, letter: "ACJ", start: 19345)
        compareDay(day17, letter: "ACK", start: 19710)
        compareDay(day17, letter: "ACL", start: 20075)
        compareDay(day17, letter: "ACM", start: 20440)
        compareDay(day17, letter: "ACN", start: 20805)
        compareDay(day17, letter: "ACO", start: 21170)
        compareDay(day17, letter: "ACP", start: 21535)
      }

      if j == 3 {

      }

      day.append(Array(day17[31755..<33215]))
      day.append(Array(day17[44165..<45625]))

      let day0 = model.day0(hour0: hour0)
      model.day21(&day21, case: j, day0: day0)
      print("Daily 2 Case", j)
      // Array(day21[0..<6935]).head(0, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day21[6935...]).head(19, steps: 365)

      model.day27(&day27, case: j, day0: day0, day1: day21, day6: day6)
      if j == 0 {
        compareDay2(day27, letter: "FC", start: 0)
        compareDay2(day27, letter: "FD", start: 365)
        compareDay2(day27, letter: "FE", start: 730)
        compareDay2(day27, letter: "FF", start: 1095)
        compareDay2(day27, letter: "FG", start: 1460)
        compareDay2(day27, letter: "FH", start: 1825)
        compareDay2(day27, letter: "FI", start: 2190)
        compareDay2(day27, letter: "FJ", start: 2555)
        compareDay2(day27, letter: "FK", start: 2920)
        compareDay2(day27, letter: "FL", start: 3285)
        compareDay2(day27, letter: "FM", start: 3650)
        compareDay2(day27, letter: "FN", start: 4015)
        compareDay2(day27, letter: "FO", start: 4380)
        compareDay2(day27, letter: "FP", start: 4745)
        compareDay2(day27, letter: "FQ", start: 5110)
        compareDay2(day27, letter: "FR", start: 5475)
        compareDay2(day27, letter: "FS", start: 5840)
        compareDay2(day27, letter: "FT", start: 6205)
        compareDay2(day27, letter: "FU", start: 6570)
        compareDay2(day27, letter: "FV", start: 6935)
        compareDay2(day27, letter: "FW", start: 7300)
        compareDay2(day27, letter: "FX", start: 7665)
        compareDay2(day27, letter: "IU", start: 33945)
      }
      if j == 2 { compareDay2(day27, letter: "UD", start: 33945) }
      if j == 3 {
        compareDay2(day27, letter: "UI", start: 0)
        compareDay2(day27, letter: "UJ", start: 365)
        compareDay2(day27, letter: "UK", start: 730)
        compareDay2(day27, letter: "UL", start: 1095)
        compareDay2(day27, letter: "UM", start: 1460)
        compareDay2(day27, letter: "UN", start: 1825)
        compareDay2(day27, letter: "UO", start: 2190)
        compareDay2(day27, letter: "UP", start: 2555)
        compareDay2(day27, letter: "UQ", start: 2920)
        compareDay2(day27, letter: "UR", start: 3285)
        compareDay2(day27, letter: "US", start: 3650)
        compareDay2(day27, letter: "UT", start: 4015)
        compareDay2(day27, letter: "UU", start: 4380)
        compareDay2(day27, letter: "UV", start: 4745)
        compareDay2(day27, letter: "UW", start: 5110)
        compareDay2(day27, letter: "UX", start: 5475)
        compareDay2(day27, letter: "UY", start: 5840)
        compareDay2(day27, letter: "UZ", start: 6205)
        compareDay2(day27, letter: "VA", start: 6570)
        compareDay2(day27, letter: "VB", start: 6935)
        compareDay2(day27, letter: "VC", start: 7300)
        compareDay2(day27, letter: "VD", start: 7665)
      }
      print("Daily 2 Case", j)
      // Array(day27[..<9855]).head(121, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day27[9855..<17155]).head(148, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day27[17155..<24090]).head(168, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day27[24090..<31755]).head(188, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day27[31755..<38690]).head(206, steps: 365)
      // print("Daily 2 Case", j)
      // Array(day27[38690...]).head(242, steps: 365)

      day.append(Array(day27[33945..<35040]))
      day.append(Array(day27[44895..<45990]))
    }

    var meth_produced_MTPH_sum = Double.zero
    var elec_from_grid_sum = Double.zero
    var elec_to_grid_MTPH_sum = Double.zero

    let names = [
      "1a day prio", "1a night prio", "2a day prio", "2a night prio", "1b day prio", "1b night prio", "2b day prio", "2b night prio", "1c day prio",
      "1c night prio", "2c day prio", "2c night prio", "1d day prio", "1d night prio", "2d day prio", "2d night prio",
    ]

    for d in 0..<365 {
      let cases = day.indices.map { i in
        costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0)
      }
      let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted().first
      if let best = best {
        // print(d, names[best], cases, day[best][d])
        meth_produced_MTPH_sum += day[best][d]
        elec_from_grid_sum += day[best][d + 365 + 365]
        elec_to_grid_MTPH_sum += day[best][d + 365]
      }
    }
    let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
    print(LCOM)
  }
}
