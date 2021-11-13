import Foundation
import Utilities

extension Range where Bound == Int {
  func split(in parts: Int) -> [Self] {
    let size = count / parts + (count % parts > 0 ? 1 : 0)
    return stride(from: 0, to: count, by: size).map { cursor in 
      cursor ..< Swift.min(cursor.advanced(by: size), endIndex)
    }
  }
}

extension Double { @inline(__always) func asString(precision: Int = 2) -> String { String(format: "%.\(precision)f", self) } }

func write(_ xs: [Double]..., maxLength: Int = Int.max) {
  let count = min(xs.reduce(0) { max($0, $1.count) }, maxLength)
  let places = "\(count)".count
  for i in 0..<count { print(xs.reduce(String(format: "%0\(places)d\t", i)) { $0 + String(format: "%3.1f\t", $1[i]).replacingOccurrences(of: "0.0", with: "0").leftpad(length: 6) }) }

}
extension String {
  public func leftpad(length: Int, character: Character = " ") -> String {
    var outString: String = self
    let extraLength = length - outString.count
    var i = 0
    while i < extraLength {
      outString.insert(character, at: outString.startIndex)
      i += 1
    }
    return outString
  }
}
extension Sequence where Element == Double {
  func write(_ count: Int? = nil) { if let count = count { zip(0..., self.prefix(count)).forEach { Swift.print($0, $1.asString()) } } else { zip(0..., self).forEach { Swift.print($0, $1.asString()) } } }

  func quotient(_ divisor: Double) -> [Double] { self.map { $0 / divisor } }

  func product(_ factor: Double) -> [Double] { self.map { $0 * factor } }
}

extension Array where Element == Double {
  mutating func shift(half: Double) {
    var offset = ((first! + last!) / 2) - half
    if first! - offset < 0 { offset = first! }
    self = map { $0 - offset }
  }
}

extension Double { var formatted: String { String(format: "%G", self) } }

extension Array where Element == Double {
  var total: Float { Float(reduce(0.0, +)) }
  var nonZeroCount: Int { reduce(into: 0) { counter, value in if value > 0 { counter += 1 } } }

  var readable: [String] { map(\.formatted) }
}

func average(_ values: ArraySlice<Double>) -> Double {
  let sum = values.reduce(into: 0.0) { sum, value in sum += value }
  return sum / Double(values.count)
}

/// Kahan-Babuška-Neumaier Sum
func sum(_ values: ArraySlice<Double>) -> Double {
  let (s, w) = values.reduce((s: Double.zero, w: Double.zero)) { accum, aᵢ in 
    let (sᵢ₋₁, wᵢ₋₁) = accum
    let sᵢ = sᵢ₋₁ + aᵢ
    let Δ = abs(aᵢ) <= abs(sᵢ₋₁) ? (sᵢ₋₁ - sᵢ) + aᵢ : (aᵢ - sᵢ) + sᵢ₋₁
    let wᵢ = wᵢ₋₁ + Δ
    return (s: sᵢ, w: wᵢ)
  }
  return s + w
}

func countiff(_ values: ArraySlice<Double>, _ predicat: (Double) -> Bool) -> Double {
  let count = values.reduce(into: 0) { counter, value in if predicat(value) { counter += 1 } }
  return Double(count)
}

func iff(_ expression: Bool, _ yes: Double, _ no: Double) -> Double { expression ? yes : no }

extension Double {
  public var multiBar: String {
    let (bar_chunks, remainder) = Int(self * 80).quotientAndRemainder(dividingBy: 8)
    let full = UnicodeScalar("█").value
    let fractionalPart = remainder > 0 ? String(UnicodeScalar(full + UInt32(8 - remainder))!) : ""
    return String(repeating: "█", count: bar_chunks) + fractionalPart + String(repeating: " ", count: 10 - bar_chunks) + String(format: "%G", self)
  }
}

struct Results {
  init() {
    var rows = [[String: Double]]()
    #if DEBUGA
    let url = URL(fileURLWithPath: "/workspaces/SPC/output.txt")

    guard let dataFile = CSV(url: url) else { fatalError() }

    for data in dataFile.dataRows {
      var dict: [String: Double] = [:]
      var i = 0
       dict["G"] = Double(data[i]);i += 1 
      dict["H"] = Double(data[i]);i += 1 
      dict["I"] = Double(data[i]);i += 1 
      dict["J"] = Double(data[i]);i += 1 
      dict["K"] = Double(data[i]);i += 1 
      dict["L"] = Double(data[i]);i += 1 
      dict["M"] = Double(data[i]);i += 1 
      dict["N"] = Double(data[i]);i += 1 
      dict["O"] = Double(data[i]);i += 1 
      dict["P"] = Double(data[i]);i += 1 
      dict["Q"] = Double(data[i]);i += 1 
      dict["R"] = Double(data[i]);i += 1 
      dict["S"] = Double(data[i]);i += 1 
      dict["T"] = Double(data[i]);i += 1 
      dict["U"] = Double(data[i]);i += 1 
      dict["V"] = Double(data[i]);i += 1 
      dict["W"] = Double(data[i]);i += 1 
      dict["X"] = Double(data[i]);i += 1 
      dict["Y"] = Double(data[i]);i += 1 
      dict["Z"] = Double(data[i]);i += 1 
      dict["AA"] = Double(data[i]);i += 1 
      dict["AB"] = Double(data[i]);i += 1 
      dict["AC"] = Double(data[i]);i += 1 
      dict["AD"] = Double(data[i]);i += 1 
      dict["AE"] = Double(data[i]);i += 1 
      dict["AF"] = Double(data[i]);i += 1 
      dict["AG"] = Double(data[i]);i += 1 
      dict["AH"] = Double(data[i]);i += 1 
      dict["AI"] = Double(data[i]);i += 1 
      dict["AJ"] = Double(data[i]);i += 1 
      dict["AK"] = Double(data[i]);i += 1 
      dict["AL"] = Double(data[i]);i += 1 
      dict["AM"] = Double(data[i]);i += 1 
      dict["AN"] = Double(data[i]);i += 1 
      dict["AO"] = Double(data[i]);i += 1 
      dict["AP"] = Double(data[i]);i += 1 
      dict["AQ"] = Double(data[i]);i += 1 
      dict["AR"] = Double(data[i]);i += 1 
      dict["AS"] = Double(data[i]);i += 1 
      dict["AT"] = Double(data[i]);i += 1 
      dict["AU"] = Double(data[i]);i += 1 
      dict["AV"] = Double(data[i]);i += 1 
      dict["AW"] = Double(data[i]);i += 1 
      dict["AX"] = Double(data[i]);i += 1 
      dict["AY"] = Double(data[i]);i += 1 
      dict["AZ"] = Double(data[i]);i += 1 
      dict["BA"] = Double(data[i]);i += 1 
      dict["BB"] = Double(data[i]);i += 1 
      dict["BC"] = Double(data[i]);i += 1 
      dict["BD"] = Double(data[i]);i += 1 
      dict["BE"] = Double(data[i]);i += 1 
      dict["BF"] = Double(data[i]);i += 1 
      dict["BG"] = Double(data[i]);i += 1 
      dict["BH"] = Double(data[i]);i += 1 
      dict["BI"] = Double(data[i]);i += 1 
      dict["BJ"] = Double(data[i]);i += 1 
      dict["BK"] = Double(data[i]);i += 1 
      dict["BL"] = Double(data[i]);i += 1 
      dict["BM"] = Double(data[i]);i += 1 
      dict["BN"] = Double(data[i]);i += 1 
      dict["BO"] = Double(data[i]);i += 1 
      dict["BP"] = Double(data[i]);i += 1 
      dict["BQ"] = Double(data[i]);i += 1 
      dict["BR"] = Double(data[i]);i += 1 
      dict["BS"] = Double(data[i]);i += 1 
      dict["BT"] = Double(data[i]);i += 1 
      dict["BU"] = Double(data[i]);i += 1 
      dict["BV"] = Double(data[i]);i += 1 
      dict["BW"] = Double(data[i]);i += 1 
      dict["BX"] = Double(data[i]);i += 1 
      dict["BY"] = Double(data[i]);i += 1 
      dict["BZ"] = Double(data[i]);i += 1 
      dict["CA"] = Double(data[i]);i += 1 
      dict["CB"] = Double(data[i]);i += 1 
      dict["CC"] = Double(data[i]);i += 1 
      dict["CD"] = Double(data[i]);i += 1 
      dict["CE"] = Double(data[i]);i += 1 
      dict["CF"] = Double(data[i]);i += 1 
      dict["CG"] = Double(data[i]);i += 1 
      dict["CH"] = Double(data[i]);i += 1 
      dict["CI"] = Double(data[i]);i += 1 
      dict["CJ"] = Double(data[i]);i += 1 
      dict["CK"] = Double(data[i]);i += 1 
      dict["CL"] = Double(data[i]);i += 1 
      dict["CM"] = Double(data[i]);i += 1 
      dict["CN"] = Double(data[i]);i += 1 
      dict["CO"] = Double(data[i]);i += 1 
      dict["CP"] = Double(data[i]);i += 1 
      dict["CQ"] = Double(data[i]);i += 1 
      dict["CR"] = Double(data[i]);i += 1 
      dict["CS"] = Double(data[i]);i += 1 
      dict["CT"] = Double(data[i]);i += 1 
      dict["CU"] = Double(data[i]);i += 1 
      dict["CV"] = Double(data[i]);i += 1 
      dict["CW"] = Double(data[i]);i += 1 
      dict["CX"] = Double(data[i]);i += 1 
      dict["CY"] = Double(data[i]);i += 1 
      dict["CZ"] = Double(data[i]);i += 1 
      dict["DA"] = Double(data[i]);i += 1 
      dict["DB"] = Double(data[i]);i += 1 
      dict["DC"] = Double(data[i]);i += 1 
      dict["DD"] = Double(data[i]);i += 1 
      dict["DE"] = Double(data[i]);i += 1 
      dict["DF"] = Double(data[i]);i += 1 
      dict["DG"] = Double(data[i]);i += 1 
      dict["DH"] = Double(data[i]);i += 1 
      dict["DI"] = Double(data[i]);i += 1 
      dict["DJ"] = Double(data[i]);i += 1 
      dict["DK"] = Double(data[i]);i += 1 
      dict["DL"] = Double(data[i]);i += 1 
      dict["DM"] = Double(data[i])
      rows.append(dict)
    }
    #endif
    self.rows = rows
  }

  let rows: [[String: Double]]

  subscript(key: String) -> Double {
    let i = Int(key.filter(\.isNumber))! + 1
    return rows[i][key.filter(\.isLetter)]!
  }

  func compare(_ results: [Double], with key: String) {
    #if DEBUGA
    var r = 4
    var isCorrect = true
    var out = "Column \(key)\n"
    var c = 0
    zip(rows, results.dropFirst())
      .forEach {
        let value = $0[key]!
        if abs(value - $1) > 0.2 {
          isCorrect = false
          if c < 5 { print("Row \(r)", "set: ", $0[key]!.asString(), " is: ", $1.asString(), to: &out) }
          c += 1
        }
        r += 1
      }
    if isCorrect {
      print("No mismatch in column \(key)")
    } else {
      if c > 5 { print("\(c - 5) other errors", to: &out) }
      print(out)
    }
    #endif
  }
}


struct Link: Codable {
  let color: String
  let source: String
  let target: String
  let type: String
  let value: Double
}

struct Node: Codable {
  let id: String
  let title: String
}

struct Sankey: Codable {
  let links: [Link]
  let nodes: [Node]
}

func sankey(values: [Double]) -> Sankey {
  Sankey(
    links: [
      Link(color: "rgb(178, 42, 42)", source: "PV", target: "za", type: "y", value: 0.5), Link(color: "rgb(178, 42, 42)", source: "PV", target: "y", type: "y", value: 0.5),
      Link(color: "rgb(0, 111, 222)", source: "G", target: "EL", type: "y", value: 0.5), Link(color: "rgb(98, 230, 31)", source: "G", target: "H2", type: "y", value: 0.5),
      Link(color: "rgb(98, 230, 31)", source: "ST", target: "G", type: "y", value: 1), Link(color: "rgb(244, 230, 31)", source: "H2", target: "M", type: "y", value: 3),
      Link(color: "rgb(0, 111, 222)", source: "CSP", target: "H2", type: "M", value: 1.5), Link(color: "rgb(178, 42, 42)", source: "PV", target: "EL", type: "M", value: 2.5),
      Link(color: "rgb(178, 42, 42)", source: "PV", target: "H", type: "M", value: 1.5), Link(color: "rgb(244, 230, 31)", source: "H", target: "TES", type: "M", value: 1.5),
      Link(color: "rgb(0, 111, 222)", source: "CSP", target: "HX", type: "z", value: 1.5), Link(color: "rgb(0, 111, 222)", source: "HX", target: "TES", type: "z", value: 1.5),
      Link(color: "rgb(244, 230, 31)", source: "TES", target: "ST", type: "z", value: 2.8), Link(color: "rgb(244, 230, 31)", source: "TES", target: "zb", type: "z", value: 0.2),
      Link(color: "rgb(98, 230, 31)", source: "EL", target: "H2", type: "z", value: 2), Link(color: "rgb(98, 230, 31)", source: "ST", target: "C", type: "z", value: 1.6),
      Link(color: "rgb(244, 230, 31)", source: "ST", target: "H2", type: "z", value: 0.2), Link(color: "rgb(0, 111, 222)", source: "EL", target: "z", type: "z", value: 1),
    ],
    nodes: [
      Node(id: "PVDC", title: "PV"), Node(id: "PV", title: "PV"), Node(id: "CSP", title: "Heat"), Node(id: "TES", title: "TES"), Node(id: "H2", title: "H2"), Node(id: "C", title: "Condenser"), Node(id: "G", title: "Generator"),
      Node(id: "EL", title: "Electrolyser"), Node(id: "HX", title: "Heatexchanger"), Node(id: "H", title: "Heater"), Node(id: "ST", title: "Turbine"), Node(id: "M", title: "Methanol"), Node(id: "y", title: "Grid"), Node(id: "z", title: "Losses"),
      Node(id: "za", title: "Loss"), Node(id: "zb", title: "Loss"),
    ]
  )
}

func labeled(values: [Double]) -> String {
  zip(CostModel.labels, values).map { l, v in
    "\(ASCIIColor.red.rawValue)\(l) \(ASCIIColor.green.rawValue)\(String(format: "%.1f", v))"
  }.joined(separator: " ")
}

enum ASCIIColor: String {
  case black = "\u{1B}[0;30m"
  case red = "\u{1B}[0;31m"
  case green = "\u{1B}[0;32m"
  case yellow = "\u{1B}[0;33m"
  case blue = "\u{1B}[0;34m"
  case magenta = "\u{1B}[0;35m"
  case cyan = "\u{1B}[0;36m"
  case white = "\u{1B}[0;37m"
  case `default` = "\u{1B}[0;0m"
}

protocol Labeled { var labels: [String] { get } }
extension Labeled { var labels: [String] { Mirror(reflecting: self).children.compactMap(\.label) } }
