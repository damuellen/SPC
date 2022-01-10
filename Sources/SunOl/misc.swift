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

func pareto_frontier(xys: [[Double]], x: Int, y: Int) -> [[Double]] {
  let sort = xys.sorted(by: { lhs, rhs in lhs[x] < rhs[x] })
  var p_front = [sort[0]]   
  for i in sort.indices[1...] {
    if sort[i][y] <= p_front.last![y] {
      p_front.append(sort[i])
    }
  }
  return p_front.map { [$0[x], $0[y]] }
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

/// Kahan-Babuška-Neumaier Sum
func sum(_ values: Array<Double>) -> Double {
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


func ifFinite(_ check: Double, _ subs: Double) -> Double {
  check.isFinite ? check : subs
}

func and(_ conditions: Bool...) -> Bool {
  conditions.allSatisfy{$0}
}

func or(_ conditions: Bool...) -> Bool {
  conditions.contains(true)
}
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
    #if DEBUGA
    guard let dataFile = CSV(atPath: "/workspaces/SPC/output.txt") else { fatalError() }
   
    let A = UnicodeScalar("A").value
    let count = dataFile.dataRows[0].count
    precondition(count < 676)
    // G == 7
    let columns = (7..<7+count).map { i -> String in
      let i = i.quotientAndRemainder(dividingBy: 26)
      let q = i.quotient > 0 ? String(UnicodeScalar(A + UInt32(i.quotient-1))!) : ""
      return q + String(UnicodeScalar(A + UInt32(i.remainder))!)
    }
    self.rows = dataFile.dataRows.map { data in 
      .init(uniqueKeysWithValues: zip(columns, data)) 
    }
    #else
    self.rows = [[String: Double]]()
    #endif
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
  zip( CostModel.labels, values).map { l, v in
    "\(l.text(.red)) \(String(format: "%.1f", v).text(.red))"
  }.joined(separator: " ")
}

protocol Labeled { var labels: [String] { get } }
extension Labeled { var labels: [String] { Mirror(reflecting: self).children.compactMap(\.label) } }

typealias Matrix<T> = [[T]]
typealias Vector<T> = [T]

extension Matrix where Element == Vector<Double> {
  init(_ x: Int, _ y: Int, _ z: Double = .zero) {
    self = Matrix(repeating: Vector(y), count: x)
  }
}

extension Vector where Element == Double {
  init(_ x: Int,  _ z: Double = .zero) {
    self = Vector(repeating: z, count: x)
  }
}

extension String {
	func ansi(_ ansi: ANSI) -> String {
    #if os(Windows)
    return self
    #else
		let reset = ANSI.style(.reset).escapeCode
		return "\(ansi.escapeCode)\(self)\(reset)"
    #endif
	}
	public func style(_ style: ANSIStyle) -> String {
		ansi(.style(style))
	}
  public func randomColor() -> String {
		ansi(.text(color: .init(rawValue: Int.random(in: 31...36))!))
	}
	public func text(_ color: ANSIColor) -> String {
		ansi(.text(color: color))
	}
	public func background(_ color: ANSIColor) -> String {
		ansi(.background(color: color))
	}
}

public enum ANSIColor: Int {
	case black = 30, red, green, yellow, blue, magenta, cyan, white
}

public enum ANSIStyle: Int {
	case reset = 0, bold, italic, underline, blink, inverse, strikethrough
}

public enum ANSI {
	case text(color: ANSIColor)
	case background(color: ANSIColor)
	case style(_ style: ANSIStyle)
	var escapeCode: String {
		var code = ANSIStyle.reset.rawValue
		switch self {
			case .text(let color):
				code = color.rawValue
			case .background(let color):
				code = color.rawValue + 10
			case .style(let style):
				code = style.rawValue
		}
		return "\u{001B}[\(code)m"
	}
}
let compute = """
 ▄▄·       • ▌ ▄ ·.  ▄▄▄·▄• ▄▌▄▄▄▄▄▄▪   ▐ ▄  ▄▄ •
▐█ ▌▪ ▄█▀▄ ·██ ▐███▪▐█ ▄██▪██▌▀•██ ▀██ •█▌▐█▐█ ▀ ▪
██ ▄▄▐█▌.▐▌▐█ ▌▐▌▐█· ██▀·█▌▐█▌  ▐█.▪▐█·▐█▐▐▌▄█ ▀█▄
▐███▌▐█▌.▐▌██ ██▌▐█▌▐█▪·•▐█▄█▌  ▐█▌·▐█▌██▐█▌▐█▄▪▐█
·▀▀▀  ▀█▄▀▪▀▀  █▪▀▀▀.▀    ▀▀▀   ▀▀▀ ▀▀▀▀▀ █▪·▀▀▀▀
""".randomColor()