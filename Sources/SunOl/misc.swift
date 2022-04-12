import Foundation
import Utilities

func POLY(_ value: Double, _ coeffs: [Double]) -> Double { coeffs.reversed().reduce(into: 0.0) { result, coefficient in result = coefficient.addingProduct(result, value) } }

extension Range where Bound == Int {
  func split(in parts: Int) -> [Self] {
    let size = count / parts + (count % parts > 0 ? 1 : 0)
    return stride(from: 0, to: count, by: size).map { cursor in cursor..<Swift.min(cursor.advanced(by: size), endIndex) }
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
  for i in sort.indices[1...] { if sort[i][y] <= p_front.last![y] { p_front.append(sort[i]) } }
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

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Double], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in if predicate(range1[(d + condition)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in if predicate(self[(d + condition)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Double], condition1: Int, predicate1: (Double) -> Bool, range2: [Double], condition2: Int, predicate2: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in if predicate1(range1[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition1: Int, predicate1: (Double) -> Bool, range2: [Double], condition2: Int, predicate2: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in if predicate1(self[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] } }
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
      day.forEach { d in if predicate1(self[(d + condition1)]), predicate2(self[(d + condition2)]) { count += 1 } }
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

func round(_ value: Double, _ digits: Double) -> Double { (pow(10, digits) * value).rounded() / pow(10, digits) }

func average(_ values: ArraySlice<Double>) -> Double {
  let sum = values.reduce(into: 0.0) { sum, value in sum += value }
  return sum / Double(values.count)
}

func sumDay(_ i: Int, _ array: [Double], _ offset: Int) -> Double {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let sum = slice.reduce(into: 0) { sum, value in sum += value }
  return sum
}

func countDay(_ i: Int, _ array: [Double], _ offset: Int, _ predicat: (Double) -> Bool) -> Double {
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

func ifFinite(_ check: Double, _ subs: Double) -> Double { check.isFinite ? check : subs }

func and(_ conditions: Bool...) -> Bool { conditions.allSatisfy { $0 } }

func or(_ conditions: Bool...) -> Bool { conditions.contains(true) }

func labeled(values: [Double]) -> String {
  let labels = [
    "CSP_loop_nr", "TES_full_load_hours", "PB_nom_gross_cap", "PV_AC_cap", "PV_DC_cap", "EY_var_net_nom_cons", "Hydrogen_storage_cap", "Heater_cap", "CCU_C_O_2_nom_prod", "C_O_2_storage_cap", "MethSynt_RawMeth_nom_prod", "RawMeth_storage_cap", "MethDist_Meth_nom_prod",
    "El_boiler_cap", "BESS_cap", "Grid_export_max", "Grid_import_max",
  ]

  return zip(labels, values).map { l, v in "\(l.text(.red)) \(String(format: "%.1f", v).text(.red))" }.joined(separator: " ")
}

protocol Labeled { var labels: [String] { get } }
extension Labeled { var labels: [String] { Mirror(reflecting: self).children.compactMap(\.label) } }

extension String {
  func ansi(_ ansi: ANSI) -> String {
    #if os(Windows)
    return self
    #else
    let reset = ANSI.style(.reset).escapeCode
    return "\(ansi.escapeCode)\(self)\(reset)"
    #endif
  }
  public func style(_ style: ANSIStyle) -> String { ansi(.style(style)) }
  public func randomColor() -> String {
    let color = ANSIColor(rawValue: Int.random(in: 31...36))!
    return ansi(.text(color: color))
  }
  public func text(_ color: ANSIColor) -> String { ansi(.text(color: color)) }
  public func background(_ color: ANSIColor) -> String { ansi(.background(color: color)) }
}

public enum ANSIColor: Int {
  case black = 30
  case red, green, yellow, blue, magenta, cyan, white
}

public enum ANSIStyle: Int {
  case reset = 0
  case bold, italic, underline, blink, inverse, strikethrough
}

public enum ANSI {
  case text(color: ANSIColor)
  case background(color: ANSIColor)
  case style(_ style: ANSIStyle)
  var escapeCode: String {
    var code = ANSIStyle.reset.rawValue
    switch self {
    case .text(let color): code = color.rawValue
    case .background(let color): code = color.rawValue + 10
    case .style(let style): code = style.rawValue
    }
    return "\u{001B}[\(code)m"
  }
}

public let tunol = """
  ████████╗██╗   ██╗███╗   ██╗ ██████╗ ██╗         
  ╚══██╔══╝██║   ██║████╗  ██║██╔═══██╗██║         
     ██║   ██║   ██║██╔██╗ ██║██║   ██║██║         
     ██║   ██║   ██║██║╚██╗██║██║   ██║██║         
     ██║   ╚██████╔╝██║ ╚████║╚██████╔╝███████╗    
     ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝    
  """
  .randomColor()
