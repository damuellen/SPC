import Foundation
import Utilities

// let csv = CSV(atPath: "hps2.csv")!

// let headers = [["Unix", "WindMax", "DNIMax", "WindSpeed", "DNI", "SFPS", "MASSFLOW", "DNIMAXMEASUREDCOS", 
// "DUMPINGAVERAGE", "INCIDENCEANGLE", "CURRENTSUNANGLE", "TSFSETOUT", 
// "SCA4LOCCOMMAND", "SCA4LOCACCPRESSURE", "SCA4LOCGRADIENT", "SCA4LOCTMAX", "SCA4LOCTNORM", "SCA4LOCT2_3", "SCA4LOCT2_2", "SCA4LOCT2_1", "SCA4LOCT2", "SCA4LOCT1", "SCA4LOCPOSERROR", "SCA4LOCSCAANGLE",
// "SCA3LOCCOMMAND", "SCA3LOCACCPRESSURE", "SCA3LOCGRADIENT", 
// "WINDDIRECTION", "SCA3LOCTMAX", "THOTTANK", "TCOLDTANK", "AMBIENTTEMP", "FLOW", "DUMPINGEXPECTED", "SCA3LOCTNORM",
//  "SCA3LOCT23", "SCA3LOCT22", "SCA3LOCT21", "SCA3LOCT2", "SCA3LOCT1", "SCA3LOCPOSERROR", "SCA3LOCSCAANGLE", "SCA2LOCCOMMAND",
//  "SCA2LOCACCPRESSURE", "SCA2LOCGRADIENT", "SCA2LOCTMAX", "SCA2LOCTNORM", "SCA2LOCT23", "SCA2LOCT22", "SCA2LOCT21", "SCA2LOCT2",
//  "SCA2LOCT1", "SCA2LOCPOSERROR", "SCA2LOCSCAANGLE", "SCA1LOCCOMMAND", "SCA1LOCACCPRESSURE", "SCA1LOCGRADIENT", "SCA1LOCTMAX",
//  "SCA1LOCTNORM", "SCA1LOCT23", "SCA1LOCT22", "SCA1LOCT21", "SCA1LOCT2", "SCA1LOCT1", "SCA1LOCT02", "SCA1LOCT01", "SCA1LOCT0", "SCA1LOCPOSERROR", "SCA1LOCSCAANGLE"]]

// let sca4 = [csv["SCA4LOCT2_3"], csv["SCA4LOCT2_2"], csv["SCA4LOCT2_1"], csv["SCA4LOCT2"], csv["SCA4LOCT1"]]

// let sca = sca4.map { v in stride(from: 0, to: v.count, by: 30).map { return v[$0...].prefix(30).reduce(0, +) / 30 }  }

// try! Gnuplot(ys: sca[0], sca[1], sca[2] , sca[3], sca[4], titles: "SCA4LOCT2_3", "SCA4LOCT2_2", "SCA4LOCT2_1", "SCA4LOCT2"," SCA4LOCT1" ,style: .points)(.pngLarge(path: "SCA4.png"))

// try! cleanUp(formulasCalculation, titlesCalculation, skip: ["AU", "BT", "CO", "DU", "QS"], name: "hourly").joined(separator: "\n\n").write(toFile: "_Calculation.swift", atomically: false, encoding: .utf8)
// try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Calculation.swift"], terminationHandler: nil)
// try! cleanUp(formulasDaily1, titlesDaily1, 365, skip: ["B", "AN", "BZ", "DL", "EX", "GT", "IP"], name: "daily1").joined(separator: "\n\n").write(toFile: "_Daily1.swift", atomically: false, encoding: .utf8)
// try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Daily1.swift"], terminationHandler: nil)
// try! cleanUp(formulasDaily2, titlesDaily2, 365, skip: ["D", "AF", "BH", "CJ", "DL", "DQ", "FB"], name: "daily2").joined(separator: "\n\n").write(toFile: "_Daily2.swift", atomically: false, encoding: .utf8)
// try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Daily2.swift"], terminationHandler: nil)

// inputOutput()

func inputOutput() {

  let workbook = try! XML(atPath: "/workspaces/SPC/xl/workbook.xml")
  let definedNamesRef: [(Int, String)] = workbook.children[5].children
    .compactMap { child -> (Int, String)? in
      let ref = child.value.replacingOccurrences(of: "Input_Output_Summary!", with: "").replacingOccurrences(of: "$", with: "")
      if ref.contains(":") { return nil }
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
  print(strings)
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