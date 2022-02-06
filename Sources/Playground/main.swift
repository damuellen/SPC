import Foundation
import Utilities

try! cleanUp(formulasCalculation, titlesCalculation, skip: [], name: "hourly").joined(separator: "\n\n").write(toFile: "_Calculation.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Calculation.swift"], terminationHandler: nil)
try! cleanUp(formulasDaily1, titlesDaily1, 365, skip: [], name: "daily1").joined(separator: "\n\n").write(toFile: "_Daily1.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Daily1.swift"], terminationHandler: nil)
try! cleanUp(formulasDaily2, titlesDaily2, 365, skip: [], name: "daily2").joined(separator: "\n\n").write(toFile: "_Daily2.swift", atomically: false, encoding: .utf8)
try! _ = Process.run(.init(fileURLWithPath: "/workspaces/swift-format/.build/release/swift-format"), arguments: ["-i", "_Daily2.swift"], terminationHandler: nil)

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