import Foundation
import Utilities
let skipCalc = ["FT",	"FU",	"FV",	"FW",	"FX",	"FY",	"FZ",	"GA",	"GB",	"GC",	"GD",	"GE",	"GF",	"GG",	"GH",	"GI",	"GJ",	"GK",	"GL",	"GM",	"GN",	"GO",	"GP",	"GQ",	"GR",	"GS",	"GT",	"GU",	"GV",	"GW",	"GX",	"GY",	"GZ",	"HA",	"HB",	"HC",	"HD",	"HE",	"HF",	"HG",	"HH",	"HI",	"HJ",	"HK",	"HL",	"HM",	"HN",	"HO",	"HP",	"HQ",	"HR",	"HS",	"HT",	"HU",	"HV",	"HW",	"HX",	"HY",	"HZ",	"IA",	"IB",	"IC",	"ID",	"IE",	"IF",	"IG",	"IH",	"II",	"IJ",	"IK",	"IL",	"IM",	"IN",	"IO",	"IP",	"IQ",	"IR",	"IS",	"IT",	"IU",	"IV",	"IW",	"IX",	"IY",	"IZ",	"JA",	"JB",	"JC",	"JD",	"JE",	"JF",	"JG",	"JH",	"JI",	"JJ",	"JK",	"JL",	"JM",	"JN",	"JO",	"JP",	"JQ",	"JR",	"JS",	"JT",	"JU",	"JV",	"JW",	"JX",	"JY",	"JZ",	"KA",	"KB",	"KC",	"KD",	"KE",	"KF",	"KG",	"KH",	"KI",	"KJ",	"KK",	"KL",	"KM",	"KN",	"KO",	"KP",	"KQ",	"KR",	"KS",	"KT",	"KU",	"KV",	"KW",	"KX",	"KY",	"KZ",	"LA",	"LB",	"LC",	"LD",	"LE",	"LF",	"LG",	"LH",	"LI",	"LJ",	"LK",	"LL",	"LM",	"LN",	"LO",	"LP",	"LQ",	"LR",	"LS",	"LT",	"LU",	"LV",	"LW",	"LX",	"LY",	"LZ",	"MA",	"MB",	"MC",	"MD",	"ME",	"MF",	"MG",	"MH",	"MI",	"MJ",	"MK",	"ML",	"MM",	"MN",	"MO",	"MP",	"MQ",	"MR",	"MS",	"MT",	"MU",	"MV",	"MW",	"MX",	"MY",	"MZ",	"NA",	"NB",	"NC",	"ND",	"NE",	"NF",	"NG",	"NH",	"NI",	"NJ",	"NK",	"NL",	"NM",	"NN",	"NO",	"NP",	"NQ",	"NR",	"NS",	"NT",	"NU",	"NV",	"NW",	"NX",	"NY",	"NZ",	"OA",	"OB",	"OC",	"OD",	"OE",	"OF",	"OG",	"OH",	"OI",	"OJ",	"OK",	"OL",	"OM",	"ON",	"OO",	"OP",	"OQ",	"OR",	"OS",	"OT",	"OU",	"OV",	"OW",	"OX",	"OY",	"OZ",	"PA",	"PB",	"PC",	"PD",	"PE",	"PF",	"PG",	"PH",	"PI",	"PJ",	"PK",	"PL",	"PM",	"PN",	"PO",	"PP",	"PQ",	"PR",	"PS",	"PT",	"PU",	"PV",	"PW",	"PX",	"PY",	"PZ",	"QA",	"QB",	"QC",	"QD",	"QE",	"QF",	"QG",	"QH",	"QI",	"QJ",	"QK",	"QL",	"QM",	"QN",	"QO",	"QP",	"QQ",	"QR",	"QS",	"QT",	"QU",	"QV",	"QW",	"QX",	"QY",	"QZ",	"RA",	"RB",	"RC",	"RD",	"RE",	"RF",	"RG",	"RH",	"RI",	"RJ",	"RK",	"RL",	"RM",	"RN",	"RO",	"RP",	"RQ",	"RR",	"RS",	"RT",	"RU",	"RV",	"RW",
]
let skipDaily2 = ["AA",	"AB",	"AC",	"AD",	"AE",	"AF",	"AG",	"AH",	"AI",	"AJ",	"AK",	"AL",	"AM",	"AN",	"AO",	"AP",	"AQ",	"AR",	"AS",	"AT",	"AU",	"AV",	"AW",	"AX",	"AY",	"AZ",	"BA",	"BB",	"BC",	"BD",	"BE",	"BF",	"BG",	"BH",	"BI",	"BJ",	"BK",	"BL",	"BM",	"BN",	"BO",	"BP",	"BQ",	"BR",	"BS",	"BT",	"BU",	"BV",	"BW",	"BX",	"BY",	"BZ",	"CA",	"CB",	"CC",	"CD",	"CE",	"CF",	"CG",	"CH",	"CI",	"CJ",	"CK",	"CL",	"CM",
]

try! cleanUp(formulasCalculation, titlesCalculation, skip: []).joined(separator: "\n\n").write(toFile: "Calculation.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "Calculation.swift"], terminationHandler: nil)
try! cleanUp(formulasDaily1, titlesDaily1, 365, skip: []).joined(separator: "\n\n").write(toFile: "Daily1.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "Daily1.swift"], terminationHandler: nil)
try! cleanUp(formulasDaily2, titlesDaily2, 365, skip: []).joined(separator: "\n\n").write(toFile: "Daily2.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "Daily2.swift"], terminationHandler: nil)

func inputOutput() {

  let workbook = try! XML(atPath: "/workspaces/SPC/xl/workbook.xml")
  let definedNamesRef: [(Int, String)] = workbook.children[5].children
    .map {
      let ref = $0.value.replacingOccurrences(of: "Input_Output_Summary!", with: "")
        .replacingOccurrences(of: "$", with: "")
      return (Int(String(ref.dropFirst()))!, ref)
    }

  let definedNames = workbook.children[5].children.map { $0.attributes["name"]! }

  let xml1 = try! XML(atPath: "/workspaces/SPC/xl/worksheets/sheet1.xml")
  let sheetData1 = xml1.children.first(where: { $0.name == "sheetData" })!
  let rows1 = sheetData1.children

  let design = definedNamesRef.indices.compactMap { i -> (String, String)? in
    let ref = definedNamesRef[i]
    let name = definedNames[i]
    if let formula = rows1.first(where: { $0.attributes["r"]! == String(ref.0) })?.children
      .first(where: { $0.attributes["r"]! == ref.1 })?
      .children.first(where: { att in att.name == "f" })?
      .value
    {
      return (name, formula)
    } else if let value = rows1.first(where: { $0.attributes["r"]! == String(ref.0) })?.children
      .first(where: { $0.attributes["r"]! == ref.1 })?
      .children.first(where: { att in att.name == "v" })?
      .value
    {
      return (name, value)
    }
    return nil
  }
  let declaration = design.map { "let \($0.0): Double" }.joined(separator: "\n")
  let assign = design.map { "self.\($0.0) = \($0.1)" }.joined(separator: "\n")
    .replacingOccurrences(of: "MAX(", with: "max(").replacingOccurrences(of: "MIN(", with: "min(")
    .replacingOccurrences(of: "IFERROR(", with: "ifFinite(\n ")
    .replacingOccurrences(of: "IF(", with: "iff(\n ")
    .replacingOccurrences(of: "AND(", with: "and(\n ")
    .replacingOccurrences(of: "OR(", with: "or(\n ").replacingOccurrences(of: ",", with: ",\n ")
    .replacingOccurrences(of: ":", with: ",").replacingOccurrences(of: "^", with: "**")
    .replacingOccurrences(of: "\"", with: "")

  let sharedStrings = try! XML(atPath: "/workspaces/SPC/xl/sharedStrings.xml")
  let strings = sharedStrings.children.compactMap { $0.children.first?.value }
}
/*
var cleanFormulas = [String:String]()
for formula in calculationFormulas {
  var expression = formula.value.dropFirst()
    .replacingOccurrences(of: "MAX(", with: "max(")
    .replacingOccurrences(of: "MIN(", with: "min(")
    .replacingOccurrences(of: "IFERROR(", with: "ifFinite(\n ")
    .replacingOccurrences(of: "IF(", with: "iff(\n ")
    .replacingOccurrences(of: "AND(", with: "and(\n ")
    .replacingOccurrences(of: "OR(", with: "or(\n ")
    .replacingOccurrences(of: "COUNT", with: "count")
  expression = expression.replacingOccurrences(of: "=", with: "==")
    .replacingOccurrences(of: "#", with: "_")
    .replacingOccurrences(of: "$", with: "")
    .replacingOccurrences(of: "&", with: "")
    .replacingOccurrences(of: "!", with: "_")
    .replacingOccurrences(of: ":", with: "...")
    .replacingOccurrences(of: "^", with: "**")
    .replacingOccurrences(of: "\"", with: "")
  columns.reversed().forEach {
    expression = expression.replacingOccurrences(of: "\($0)3", with: "xy[\($0) + i]")
  }
  cleanFormulas[formula.key] = expression
}
var i = 0
let text: [String] = columns.compactMap { 
  if i == 440 {
    print(i)
  }
  guard let formula = cleanFormulas[$0] else { return nil }
  i += 1
  return """
  let \($0) = \((i-1)*8760+cleanFormulas.keys.count*365)
  let \($0)0 = \((i-1)*365)
  for i in 1..<8760 {
    xy[\($0)+i] = \(formula)
    xy[\($0)0 + day[i]] += xy[\($0) + i]
    c[\($0)0 + day[i]] += xy[\($0) + i] > 0 ? 1 : 0
  }
  """
}
print(text.joined(separator: "\n"))
*/