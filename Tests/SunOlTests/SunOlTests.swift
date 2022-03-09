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
    XCTAssertEqual(hour0[9113], 0.28, accuracy: 0.1, "H357")
    XCTAssertEqual(hour0[17873], 0.95, accuracy: 0.1, "I357")
    XCTAssertEqual(hour0[26633], 36.00, accuracy: 0.1, "J357")
    XCTAssertEqual(hour0[35393], 244.09, accuracy: 0.1, "K357")
    XCTAssertEqual(hour0[44153], 232.51, accuracy: 0.1, "L357")
    XCTAssertEqual(hour0[52913], 0.00, accuracy: 0.1, "M357")
    XCTAssertEqual(hour0[61673], 2.28, accuracy: 0.1, "O357")
    XCTAssertEqual(hour0[70433], 230.23, accuracy: 0.1, "P357")
    XCTAssertEqual(hour0[79193], 0.00, accuracy: 0.1, "Q357")
    XCTAssertEqual(hour0[87953], 116.52, accuracy: 0.1, "R357")
    XCTAssertEqual(hour0[96713], 116.52, accuracy: 0.1, "S357")
    XCTAssertEqual(hour0[105473], 49.21, accuracy: 0.1, "T357")
    XCTAssertEqual(hour0[114233], 15.00, accuracy: 0.1, "U357")
    XCTAssertEqual(hour0[122993], 100.36, accuracy: 0.1, "V357")
    XCTAssertEqual(hour0[131753], 0.00, accuracy: 0.1, "W357")
    XCTAssertEqual(hour0[140513], 0.00, accuracy: 0.1, "X357")
    XCTAssertEqual(hour0[149273], 50.00, accuracy: 0.1, "Y357")
    XCTAssertEqual(hour0[158033], 13.34, accuracy: 0.1, "Z357")
    XCTAssertEqual(hour0[166793], 86.66, accuracy: 0.1, "AA357")
    XCTAssertEqual(hour0[175553], 34.37, accuracy: 0.1, "AB357")
    XCTAssertEqual(hour0[184313], 11.26, accuracy: 0.1, "AC357")
    XCTAssertEqual(hour0[193073], 6.29, accuracy: 0.1, "AD357")
    XCTAssertEqual(hour0[201833], 65.00, accuracy: 0.1, "AE357")
    XCTAssertEqual(hour0[210593], 50.00, accuracy: 0.1, "AF357")
    XCTAssertEqual(hour0[219353], 205.66, accuracy: 0.1, "AG357")
    XCTAssertEqual(hour0[228113], 205.66, accuracy: 0.1, "AH357")
    XCTAssertEqual(hour0[236873], 87.36, accuracy: 0.1, "AI357")
    XCTAssertEqual(hour0[245633], 0.00, accuracy: 0.1, "AJ357")
    XCTAssertEqual(hour0[254393], 0.00, accuracy: 0.1, "AK357")
    XCTAssertEqual(hour0[263153], 27.31, accuracy: 0.1, "AL357")
    XCTAssertEqual(hour0[271913], 22.69, accuracy: 0.1, "AM357")
    XCTAssertEqual(hour0[280673], 51.88, accuracy: 0.1, "AN357")
    XCTAssertEqual(hour0[289433], 48.12, accuracy: 0.1, "AO357")
    XCTAssertEqual(hour0[298193], 21.56, accuracy: 0.1, "AP357")
    XCTAssertEqual(hour0[306953], 0.00, accuracy: 0.1, "AQ357")
    XCTAssertEqual(hour0[315713], 4.74, accuracy: 0.1, "AR357")
    XCTAssertEqual(hour0[324473], 0.00, accuracy: 0.1, "AS357")
    XCTAssertEqual(hour0[333233], 0.00, accuracy: 0.1, "AT357")
    let hour1 = model.hour1(hour0: hour0)

    XCTAssertEqual(hour1[353], 0.36, accuracy: 0.1, "AV357")
    XCTAssertEqual(hour1[9113], 232.15, accuracy: 0.1, "AW357")
    XCTAssertEqual(hour1[17873], 0.00, accuracy: 0.1, "AX357")
    XCTAssertEqual(hour1[26633], 0.00, accuracy: 0.1, "AY357")
    XCTAssertEqual(hour1[35393], 1739.03, accuracy: 0.1, "AZ357")
    XCTAssertEqual(hour1[44153], 0.00, accuracy: 0.1, "BA357")
    XCTAssertEqual(hour1[52913], 0.00, accuracy: 0.1, "BB357")
    XCTAssertEqual(hour1[61673], 0.00, accuracy: 0.1, "BC357")
    XCTAssertEqual(hour1[70433], 0.00, accuracy: 0.1, "BD357")
    XCTAssertEqual(hour1[79193], 0.00, accuracy: 0.1, "BE357")
    XCTAssertEqual(hour1[87953], 0.00, accuracy: 0.1, "BF357")
    XCTAssertEqual(hour1[96713], 0.00, accuracy: 0.1, "BG357")
    XCTAssertEqual(hour1[105473], 0.00, accuracy: 0.1, "BH357")
    XCTAssertEqual(hour1[114233], 232.15, accuracy: 0.1, "BI357")
    XCTAssertEqual(hour1[122993], 36.00, accuracy: 0.1, "BJ357")
    XCTAssertEqual(hour1[131753], 0.00, accuracy: 0.1, "BK357")
    XCTAssertEqual(hour1[140513], 116.52, accuracy: 0.1, "BL357")
    XCTAssertEqual(hour1[149273], 116.52, accuracy: 0.1, "BM357")
    XCTAssertEqual(hour1[158033], 49.21, accuracy: 0.1, "BN357")
    XCTAssertEqual(hour1[166793], 15.00, accuracy: 0.1, "BO357")
    XCTAssertEqual(hour1[175553], 102.29, accuracy: 0.1, "BP357")
    XCTAssertEqual(hour1[184313], 0.00, accuracy: 0.1, "BQ357")

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
      if j == 0 {
        XCTAssertEqual(hour2[353], 0.00, accuracy: 0.1, "BU357")
        XCTAssertEqual(hour2[9113], 0.00, accuracy: 0.1, "BV357")
        XCTAssertEqual(hour2[17873], 0.00, accuracy: 0.1, "BW357")
        XCTAssertEqual(hour2[26633], 0.00, accuracy: 0.1, "BX357")
        XCTAssertEqual(hour2[35393], 0.00, accuracy: 0.1, "BY357")
        XCTAssertEqual(hour2[44153], 161.25, accuracy: 0.1, "BZ357")
        XCTAssertEqual(hour2[52913], 0.00, accuracy: 0.1, "CA357")
        XCTAssertEqual(hour2[61673], 0.00, accuracy: 0.1, "CB357")
        XCTAssertEqual(hour2[70433], 1414.47, accuracy: 0.1, "CC357")
        XCTAssertEqual(hour2[79193], 324.56, accuracy: 0.1, "CD357")
        XCTAssertEqual(hour2[87953], 0.00, accuracy: 0.1, "CE357")
        XCTAssertEqual(hour2[96713], 0.00, accuracy: 0.1, "CF357")
        XCTAssertEqual(hour2[105473], 0.00, accuracy: 0.1, "CG357")
        XCTAssertEqual(hour2[114233], 0.00, accuracy: 0.1, "CH357")
        XCTAssertEqual(hour2[122993], 0.00, accuracy: 0.1, "CI357")
        XCTAssertEqual(hour2[131753], 0.00, accuracy: 0.1, "CJ357")
        XCTAssertEqual(hour2[140513], 232.51, accuracy: 0.1, "CK357")
        XCTAssertEqual(hour2[149273], 36.00, accuracy: 0.1, "CL357")
        XCTAssertEqual(hour2[158033], 5.59, accuracy: 0.1, "CM357")
        XCTAssertEqual(hour2[166793], 0.00, accuracy: 0.1, "CN357")
      }
      let hour3 = model.hour3(j: j, hour0: hour0, hour1: hour1, hour2: hour2)
      if j == 0 {
        XCTAssertEqual(hour3[353], 116.52, accuracy: 0.1, "CP357")
        XCTAssertEqual(hour3[9113], 116.52, accuracy: 0.1, "CQ357")
        XCTAssertEqual(hour3[17873], 49.21, accuracy: 0.1, "CR357")
        XCTAssertEqual(hour3[353], 116.52, accuracy: 0.1, "CP357")
        XCTAssertEqual(hour3[35393], 0.00, accuracy: 0.1, "CT357")
        XCTAssertEqual(hour3[44153], 0.00, accuracy: 0.1, "CU357")
        XCTAssertEqual(hour3[52913], 97.06, accuracy: 0.1, "CV357")
        XCTAssertEqual(hour3[61673], 0.00, accuracy: 0.1, "CW357")
        XCTAssertEqual(hour3[70433], 0.00, accuracy: 0.1, "CX357")
        XCTAssertEqual(hour3[79193], 50.00, accuracy: 0.1, "CY357")
        XCTAssertEqual(hour3[87953], 13.34, accuracy: 0.1, "CZ357")
        XCTAssertEqual(hour3[96713], 86.66, accuracy: 0.1, "DA357")
        XCTAssertEqual(hour3[105473], 34.37, accuracy: 0.1, "DB357")
        XCTAssertEqual(hour3[114233], 11.26, accuracy: 0.1, "DC357")
        XCTAssertEqual(hour3[122993], 6.29, accuracy: 0.1, "DD357")
        XCTAssertEqual(hour3[131753], 65.00, accuracy: 0.1, "DE357")
        XCTAssertEqual(hour3[140513], 50.00, accuracy: 0.1, "DF357")
        XCTAssertEqual(hour3[149273], 205.66, accuracy: 0.1, "DG357")
        XCTAssertEqual(hour3[158033], 205.66, accuracy: 0.1, "DH357")
        XCTAssertEqual(hour3[166793], 87.36, accuracy: 0.1, "DI357")
        XCTAssertEqual(hour3[175553], 0.00, accuracy: 0.1, "DJ357")
        XCTAssertEqual(hour3[184313], 0.00, accuracy: 0.1, "DK357")
        XCTAssertEqual(hour3[193073], 30.62, accuracy: 0.1, "DL357")
        XCTAssertEqual(hour3[201833], 19.38, accuracy: 0.1, "DM357")
        XCTAssertEqual(hour3[210593], 51.88, accuracy: 0.1, "DN357")
        XCTAssertEqual(hour3[219353], 48.12, accuracy: 0.1, "DO357")
        XCTAssertEqual(hour3[228113], 21.56, accuracy: 0.1, "DP357")
        XCTAssertEqual(hour3[236873], 0.00, accuracy: 0.1, "DQ357")
        XCTAssertEqual(hour3[245633], 4.74, accuracy: 0.1, "DR357")
        XCTAssertEqual(hour3[254393], 0.00, accuracy: 0.1, "DS357")
        XCTAssertEqual(hour3[263153], 0.00, accuracy: 0.1, "DT357")
      }
      
      var day1 = model.day(case: j, hour2: hour2, hour3: hour3)
      if j == 0 {
        XCTAssertEqual(day1[330], 15.00, accuracy: 0.1, "C333")
        XCTAssertEqual(day1[695], 9.00, accuracy: 0.1, "D333")
        XCTAssertEqual(day1[1060], 14.00, accuracy: 0.1, "E333")
        XCTAssertEqual(day1[1425], 234.40, accuracy: 0.1, "F333")
        XCTAssertEqual(day1[1790], 468.80, accuracy: 0.1, "G333")
        XCTAssertEqual(day1[3615], 0.22, accuracy: 0.1, "L333")
        XCTAssertEqual(day1[3980], -0.56, accuracy: 0.1, "M333")
        XCTAssertEqual(day1[4345], 1.00, accuracy: 0.1, "N333")
        XCTAssertEqual(day1[4710], 1.00, accuracy: 0.1, "O333")
        XCTAssertEqual(day1[5075], 1.00, accuracy: 0.1, "P333")
        XCTAssertEqual(day1[5440], 1.00, accuracy: 0.1, "Q333")
        XCTAssertEqual(day1[5805], 0.70, accuracy: 0.1, "R333")
      }
      let hour4 = model.hour4(j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
      model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
      if j == 0 {
        XCTAssertEqual(day1[6170], 15.00, accuracy: 0.1, "T333")
        XCTAssertEqual(day1[6535], 9.00, accuracy: 0.1, "U333")
        XCTAssertEqual(day1[6900], 14.00, accuracy: 0.1, "V333")
        XCTAssertEqual(day1[7265], 468.80, accuracy: 0.1, "W333")
        XCTAssertEqual(day1[7630], 0.00, accuracy: 0.1, "X333")
        XCTAssertEqual(day1[7995], 0.00, accuracy: 0.1, "Y333")
        XCTAssertEqual(day1[8360], 1673.42, accuracy: 0.1, "Z333")
        XCTAssertEqual(day1[8725], 3291.09, accuracy: 0.1, "AA333")
        XCTAssertEqual(day1[9090], 497.36, accuracy: 0.1, "AB333")
        XCTAssertEqual(day1[9455], 985.02, accuracy: 0.1, "AC333")
        XCTAssertEqual(day1[9820], 234.40, accuracy: 0.1, "AD333")
        XCTAssertEqual(day1[10185], 468.80, accuracy: 0.1, "AE333")
        XCTAssertEqual(day1[10550], 206.06, accuracy: 0.1, "AF333")
        XCTAssertEqual(day1[10915], 412.12, accuracy: 0.1, "AG333")
        XCTAssertEqual(day1[11280], 28.34, accuracy: 0.1, "AH333")
        XCTAssertEqual(day1[11645], 56.68, accuracy: 0.1, "AI333")
        XCTAssertEqual(day1[12010], -0.56, accuracy: 0.1, "AJ333")
        XCTAssertEqual(day1[12375], 1.00, accuracy: 0.1, "AK333")
        XCTAssertEqual(day1[12740], 1.00, accuracy: 0.1, "AL333")
        XCTAssertEqual(day1[13105], 0.70, accuracy: 0.1, "AM333")
      }
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

    var year = [Int]()
    for d in 0..<365 {
      // let valuesDay = day.indices.map { i in day[i][d] }
      // let best = valuesDay.indices.filter { valuesDay[$0] > 0 }.sorted { valuesDay[$0] > valuesDay[$1] }
      // year.append(best[0])
    }

    let costs = Costs(
    )
  
  }
}

