
import Foundation
import Utilities
import xlsxwriter

// let c = CSV(atPath: "/workspaces/SPC/Saudian.csv")!
// let dni = c["DNI"]
// let ss = dni.chunks(ofCount: 24)
// var count = 1
// var result = [Double]()

// for day in ss {
//   let y1 = Array(day)
//   let x1 = [Double](stride(from: 0, to: Double(y1.count), by: 1))
//   let x2 = [Double](stride(from: 0, to: Double(y1.count), by: 1 / 12))
//   let d = CubicSpline(x: x1, y: y1)
//   let y2 = x2.map(d.callAsFunction(x:)).map { max(0, $0) }
//   let factor = y1.reduce(0, +) / (y2.reduce(0, +) / 12)
//   let y3 = y2.map { factor * $0 }
//   // try! Gnuplot(xs: x1, x2, x2, ys: y1, y2, y3)(.pngLarge(path: "dni_\(count).png"))
//   count += 1
//   result.append(contentsOf: y3)
// }

// try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
//   .plot(multi: true, index: 0, x: 0, y: 1)
//   .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test1.png"))
// try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
//   .plot(multi: true, index: 0, x: 0, y: 1)
//   .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test2.png"))
// // dni.map { $0 < 5 ? 0 : $0 }.forEach { print($0) }

func foo() {

let workbook = try! XML(atPath: "/workspaces/SPC/xl/workbook.xml")
let definedNamesRef: [(Int, String)] = workbook.children[5].children.map {
  let ref = $0.value.replacingOccurrences(of: "Input_Output_Summary!", with: "").replacingOccurrences(of: "$", with: "") 
  return (Int(String(ref.dropFirst()))!, ref)
}

let definedNames = workbook.children[5].children.map { $0.attributes["name"]! }

let xml1 = try! XML(atPath: "/workspaces/SPC/xl/worksheets/sheet1.xml")
let sheetData1 = xml1.children.first(where: {$0.name == "sheetData"})!
let rows1 = sheetData1.children

let design = definedNamesRef.indices.compactMap { i -> (String, String)? in 
  let ref = definedNamesRef[i]
  let name = definedNames[i]
  if let formula = rows1.first(where: { $0.attributes["r"]! == String(ref.0)})?
  .children.first(where: { $0.attributes["r"]! == ref.1})?
  .children.first(where: { att in att.name == "f" })?
  .value {
    return (name, formula)
  } else if let value = rows1.first(where: { $0.attributes["r"]! == String(ref.0)})?
  .children.first(where: { $0.attributes["r"]! == ref.1})?
  .children.first(where: { att in att.name == "v" })?
  .value {
    return (name, value)
  }
  return nil
}.map { "let \($0.0): Double" }
print(design.joined(separator: "\n"))
 /*
print(design.joined(separator: "\n").replacingOccurrences(of: "MAX(", with: "max(")
    .replacingOccurrences(of: "MIN(", with: "min(")
    .replacingOccurrences(of: "IFERROR(", with: "ifFinite(\n ")
    .replacingOccurrences(of: "IF(", with: "iff(\n ")
    .replacingOccurrences(of: "AND(", with: "and(\n ")
    .replacingOccurrences(of: "OR(", with: "or(\n ")
    .replacingOccurrences(of: ",", with: ",\n ")
    .replacingOccurrences(of: ":", with: ",")
    .replacingOccurrences(of: "^", with: "**")
    .replacingOccurrences(of: "\"", with: ""))


 
let sharedStrings = try! XML(atPath: "/workspaces/SPC/xl/sharedStrings.xml")
let strings = sharedStrings.children.compactMap { $0.children.first?.value }

do {
let xml = try! XML(atPath: "/workspaces/SPC/xl/worksheets/sheet7.xml")
let start = 1


let sheetData = xml.children.first(where: {$0.name == "sheetData"})!
let rows = Array(sheetData.children.prefix(100))
let indices = rows.first!.children.indices
let header = Dictionary(uniqueKeysWithValues: indices.compactMap { i -> (String, String)? in 
if let key = rows[3].children[i].attributes["r"], let value = 
rows[3].children[i].children.first(where: { att in att.name == "v" })?.value {
  return ("\(key.filter(\.isLetter))", strings[Int(value)!])
} else {
  return nil
}
})
let dict = Dictionary(uniqueKeysWithValues: indices.compactMap { i -> (String, String)? in 
  if let index = rows.firstIndex(where: { node in 
    if node.children.endIndex <= i { return false }
    return !(node.children[i].children.first(where: { att in att.name == "f" })?.value.isEmpty ?? true) }
  ), let key = rows[index].children[i].attributes["r"] {
    if key == "IP" { return nil }
    let letters = "\(key.filter(\.isLetter))"
    var formula = rows[index].children[i].children.first(where: { att in att.name == "f" })!.value
    formula = formula.replacingOccurrences(of: "8763", with: "_end")
    .replacingOccurrences(of: "\(index+1)", with: "_[i]")
    .replacingOccurrences(of: "\(index)", with: "_[i-1]")
    .replacingOccurrences(of: "\(index+1)", with: "_[i+1]")
    formula = formula.replacingOccurrences(of: "$", with: "")
    .replacingOccurrences(of: "=", with: "==")
    .replacingOccurrences(of: "MAX(", with: "max(")
    .replacingOccurrences(of: "MIN(", with: "min(")
    .replacingOccurrences(of: "IFERROR(", with: "ifFinite(\n ")
    .replacingOccurrences(of: "IF(", with: "iff(\n ")
    .replacingOccurrences(of: "AND(", with: "and(\n ")
    .replacingOccurrences(of: "OR(", with: "or(\n ")
    .replacingOccurrences(of: "COUNT", with: "count")
    formula = formula.replacingOccurrences(of: ",", with: ",\n ")
    .replacingOccurrences(of: ":", with: ",")
    .replacingOccurrences(of: "^", with: "**")
    .replacingOccurrences(of: "\"", with: "")
    return (letters, formula)
 
  } else {
    return nil
  }
})

let A = UnicodeScalar("A").value
let count = dict.keys.count
precondition(count < 676)

let columns = (0..<count).map { n -> (Int,String) in
  let i = n.quotientAndRemainder(dividingBy: 26)
  let q = i.quotient > 0 ? String(UnicodeScalar(A + UInt32(i.quotient-1))!) : ""
  return (n, q + String(UnicodeScalar(A + UInt32(i.remainder))!))
}



for key in columns {
  guard var formula = dict[key.1] else { continue }
  for key2 in columns.reversed() {
    formula = formula.replacingOccurrences(of: key2.1 + "_[", with: "xy[\(key2.1)+")
  }
  print("""
  /// \(header[key.1] ?? "")
  let \(key.1) = \((key.0+4)*8760)
  let \(key.1)0 = \((key.0-4)*365)
  for i in 1..<8760 {
    xy[\(key.1)+i] = \(formula)
    xy[\(key.1)0 + day[i]] += xy[\(key.1) + i]
    c[\(key.1)0 + day[i]] += xy[\(key.1) + i] > 0 ? 1 : 0
  }

  """)
}

}
*/
}

foo()
