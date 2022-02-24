import Foundation
import Utilities

func POLY(_ value: Double, _ coeffs: [Double]) -> Double { 
  coeffs.reversed().reduce(into: 0.0) { result, coefficient in
    result = coefficient.addingProduct(result, value)
  }
}

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


extension Array where Element == Double {
  func sum(days: [[Int]], range: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in let value = self[(d + range)]
        if predicate(value) { sum += value }
      }
      return sum
    }
  }

  func sum(days: [[Int]], range: Int) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in let value = self[(d + range)]
        sum += value 
      }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in 
        if predicate(self[(d + condition)]) { sum += self[(d + range)] }
      }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition1: Int, predicate1: (Double) -> Bool, range2: [Double], condition2: Int, predicate2: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in 
        if predicate1(self[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] }
      }
      return sum
    }
  }

  func sum(hours: [[Int]], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    Array(
      hours.map { day -> [Double] in var sum = 0.0
        day.forEach { d in let value = self[(d + condition)]
          if predicate(value) { sum += value }
        }
        return [Double](repeating: sum, count: day.count)
      }
      .joined())
  }

  func sum(hours: [[Int]], condition: Int) -> [Double] {
    Array(
      hours.map { day -> [Double] in var sum = 0.0
        day.forEach { d in let value = self[(d + condition)]
          sum += value
        }
        return [Double](repeating: sum, count: day.count)
      }
      .joined())
  }


  func countOf(_ days: [[Int]], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var count = 0.0
      day.forEach { d in let value = self[(d + condition)]
        if predicate(value) { count += 1 }
      }
      return count
    }
  }

  func countOf(_ days: [[Int]], condition1: Int, predicate1: (Double) -> Bool, condition2: Int, predicate2: (Double) -> Bool) -> [Double] {
    days.map { day in var count = 0.0
      day.forEach { d in 
        if  predicate1(self[(d + condition1)]), predicate2(self[(d + condition2)]) { count += 1 }
      }
      return count
    }
  }

  func count(hours: [[Int]], range: Int, predicate: (Double) -> Bool) -> [Double] {
    Array(
      hours.map { day -> [Double] in var count = 0.0
        day.forEach { d in let value = self[(d + range)]
          if predicate(value) { count += 1 }
        }
        return [Double](repeating: count, count: day.count)
      }
      .joined())
  }
}

extension Double { var formatted: String { String(format: "%G", self) } }

extension Array where Element == Double {
  var total: Float { Float(reduce(0.0, +)) }
  var nonZeroCount: Int { reduce(into: 0) { counter, value in if value > 0 { counter += 1 } } }

  var readable: [String] { map(\.formatted) }
}

func round(_ value: Double, _ digits: Double) -> Double { value.rounded() }

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


func sumDay( _ i: Int, _ array: Array<Double>, _ offset: Int) -> Double {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let sum = slice.reduce(into: 0) { sum, value in sum += value }
  return sum
}


func countDay( _ i: Int, _ array: Array<Double>, _ offset: Int, _ predicat: (Double) -> Bool) -> Double {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let count = slice.reduce(into: 0) { counter, value in if predicat(value) { counter += 1 } }
  return Double(count)
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
    let color = ANSIColor(rawValue: Int.random(in: 31...36))!
		return ansi(.text(color: color))
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

let tunol = """
████████╗██╗   ██╗███╗   ██╗ ██████╗ ██╗         
╚══██╔══╝██║   ██║████╗  ██║██╔═══██╗██║         
   ██║   ██║   ██║██╔██╗ ██║██║   ██║██║         
   ██║   ██║   ██║██║╚██╗██║██║   ██║██║         
   ██║   ╚██████╔╝██║ ╚████║╚██████╔╝███████╗    
   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝    
""".randomColor()


extension Array where Element==Double {
  public func write(_ rows: Int) {
    let html = """
    <html><head><style>
    table {
      font-family: sans-serif;
      font-size: small;
      border-collapse: collapse;
      table-layout: auto;
    }
    td, th {
      border: 1px solid #ddd;
      padding: 4px;
      text-align: right;
      overflow: hidden;
      text-overflow: ellipsis;
      max-width: 10%;
    }
    tr:nth-child(even) { background-color: #f2f2f2; }
    tr:hover { background-color: #ddd; }
    th {
      padding-top: 6px;
      padding-bottom: 6px;
      text-align: center;
      background-color: Teal;
      color: white;
    }
    </style></head><body>
    """
    var table = "\n<table>\n"
    for i in 0..<rows {
      let s = stride(from: i, to: endIndex, by: rows)
      table += "\t<tr>" + s.map { "<td>" + String(format: "%1.2f", self[$0]) + "</td>" }.joined() + "</tr>\n"
    }
    table += "</table>\n"
    try? (html + table + "</body>\n</html>\n").write(toFile: "Array.html", atomically: false, encoding: .utf8)
  }
}

extension Array where Element==Double {
  public func head(_ column: Int, steps: Int) {    
    let A = UnicodeScalar("A").value
    let columns = (column..<(column+(count / steps))).map { n -> String in 
      var nn = n
      var x = ""
      if n > 701 {
        nn -= 676
        x = "A"
      }
      let i = nn.quotientAndRemainder(dividingBy: 26)
      let q = i.quotient > 0 ? String(UnicodeScalar(A + UInt32(i.quotient - 1))!) : ""
      return x + q + String(UnicodeScalar(A + UInt32(i.remainder))!)
    }
    print(columns.joined(separator: "\t"))
    for i in 0..<100 {
      let s = stride(from: i, to: endIndex, by: steps)
      print(s.map { String(format: "%.1f", self[$0]) }.joined(separator: "\t"))
    }
    print()
  }
}