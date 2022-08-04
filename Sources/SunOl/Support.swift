import Foundation
import Utilities

func POLY(_ value: Float, _ coeffs: [Float]) -> Float { coeffs.reversed().reduce(into: 0.0) { result, coefficient in result = coefficient.addingProduct(result, value) } }

extension Array where Element == Float {
  func sum(days: [[Int]], range: Int, predicate: (Float) -> Bool) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in let value = self[(d + range)]
        if predicate(value) { sum += value }
      }
      return sum
    }
  }

  func sum(days: [[Int]], range: Int) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in let value = self[(d + range)]
        sum += value
      }
      return sum
    }
  }

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Float], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in if predicate(range1[(d + condition)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in if predicate(self[(d + condition)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Float], condition1: Int, predicate1: (Float) -> Bool, range2: [Float], condition2: Int, predicate2: (Float) -> Bool) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in if predicate1(range1[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sumOf(_ range: Int, days: [[Int]], condition1: Int, predicate1: (Float) -> Bool, range2: [Float], condition2: Int, predicate2: (Float) -> Bool) -> [Float] {
    days.map { day in var sum = Float.zero
      day.forEach { d in if predicate1(self[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] } }
      return sum
    }
  }

  func sum(_ range: Int, hours: [[Int]], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    Array(
      hours.map { day -> [Float] in var sum = Float.zero
        day.forEach { d in 
          let value = self[(d + condition)]
          if predicate(value) { sum += self[(d + range)] }
        }
        return [Float](repeating: sum, count: day.count)
      }
      .joined())
  }

  func sum(_ range: Int, hours: [[Int]], range2: [Float], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    Array(
      hours.map { day -> [Float] in var sum = Float.zero
        day.forEach { d in 
          let value = range2[(d + condition)]
          if predicate(value) { sum += self[(d + range)] }
        }
        return [Float](repeating: sum, count: day.count)
      }
      .joined())
  }

  func sum(hours: [[Int]], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    Array(
      hours.map { day -> [Float] in var sum = Float.zero
        day.forEach { d in let value = self[(d + condition)]
          if predicate(value) { sum += value }
        }
        return [Float](repeating: sum, count: day.count)
      }
      .joined())
  }

  func sum(hours: [[Int]], condition: Int) -> [Float] {
    Array(
      hours.map { day -> [Float] in var sum = Float.zero
        day.forEach { d in let value = self[(d + condition)]
          sum += value
        }
        return [Float](repeating: sum, count: day.count)
      }
      .joined())
  }

  func countOf(_ days: [[Int]], condition: Int, predicate: (Float) -> Bool) -> [Float] {
    days.map { day in var count = Float.zero
      day.forEach { d in let value = self[(d + condition)]
        if predicate(value) { count += 1 }
      }
      return count
    }
  }

  func countOf(_ days: [[Int]], condition1: Int, predicate1: (Float) -> Bool, condition2: Int, predicate2: (Float) -> Bool) -> [Float] {
    days.map { day in var count = Float.zero
      day.forEach { d in if predicate1(self[(d + condition1)]), predicate2(self[(d + condition2)]) { count += 1 } }
      return count
    }
  }

  func count(hours: [[Int]], range: Int, predicate: (Float) -> Bool) -> [Float] {
    Array(
      hours.map { day -> [Float] in var count = Float.zero
        day.forEach { d in let value = self[(d + range)]
          if predicate(value) { count += 1 }
        }
        return [Float](repeating: count, count: day.count)
      }
      .joined())
  }
}

@available(macOS 10.12, *)
enum Hours {
  public static let Jan = Int(DateInterval.Jan.start.timeIntervalSinceReferenceDate / 3600)
  public static let Feb = Int(DateInterval.Feb.start.timeIntervalSinceReferenceDate / 3600)
  public static let Mar = Int(DateInterval.Mar.start.timeIntervalSinceReferenceDate / 3600)
  public static let Apr = Int(DateInterval.Apr.start.timeIntervalSinceReferenceDate / 3600)
  public static let May = Int(DateInterval.May.start.timeIntervalSinceReferenceDate / 3600)
  public static let Jun = Int(DateInterval.Jun.start.timeIntervalSinceReferenceDate / 3600)
  public static let Jul = Int(DateInterval.Jul.start.timeIntervalSinceReferenceDate / 3600)
  public static let Aug = Int(DateInterval.Aug.start.timeIntervalSinceReferenceDate / 3600)
  public static let Sep = Int(DateInterval.Sep.start.timeIntervalSinceReferenceDate / 3600)
  public static let Oct = Int(DateInterval.Oct.start.timeIntervalSinceReferenceDate / 3600)
  public static let Nov = Int(DateInterval.Nov.start.timeIntervalSinceReferenceDate / 3600)
  public static let Dec = Int(DateInterval.Dec.start.timeIntervalSinceReferenceDate / 3600)
}

@available(macOS 10.12, *)
enum Days {
  public static let Jan = Int(DateInterval.Jan.start.timeIntervalSinceReferenceDate / 86400)
  public static let Feb = Int(DateInterval.Feb.start.timeIntervalSinceReferenceDate / 86400)
  public static let Mar = Int(DateInterval.Mar.start.timeIntervalSinceReferenceDate / 86400)
  public static let Apr = Int(DateInterval.Apr.start.timeIntervalSinceReferenceDate / 86400)
  public static let May = Int(DateInterval.May.start.timeIntervalSinceReferenceDate / 86400)
  public static let Jun = Int(DateInterval.Jun.start.timeIntervalSinceReferenceDate / 86400)
  public static let Jul = Int(DateInterval.Jul.start.timeIntervalSinceReferenceDate / 86400)
  public static let Aug = Int(DateInterval.Aug.start.timeIntervalSinceReferenceDate / 86400)
  public static let Sep = Int(DateInterval.Sep.start.timeIntervalSinceReferenceDate / 86400)
  public static let Oct = Int(DateInterval.Oct.start.timeIntervalSinceReferenceDate / 86400)
  public static let Nov = Int(DateInterval.Nov.start.timeIntervalSinceReferenceDate / 86400)
  public static let Dec = Int(DateInterval.Dec.start.timeIntervalSinceReferenceDate / 86400)
}

extension Float { var formatted: String { String(format: "%G", self) } }

extension Array where Element == Float {
  var total: Float { Float(reduce(0.0, +)) }
  var nonZeroCount: Int { reduce(into: 0) { counter, value in if value > 0 { counter += 1 } } }

  var readable: [String] { map(\.formatted) }
}

func round(_ value: Float, _ digits: Float) -> Float { (pow(10, digits) * value).rounded() / pow(10, digits) }

func roundUp(_ value: Float, _ digits: Float = 2) -> Float { (pow(10, digits) * value).rounded(.up) / pow(10, digits) }

func average(_ values: ArraySlice<Float>) -> Float {
  let sum = values.reduce(into: 0.0) { sum, value in sum += value }
  return sum / Float(values.count)
}

func sumDay(_ i: Int, _ array: [Float], _ offset: Int) -> Float {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let sum = slice.reduce(into: 0) { sum, value in sum += value }
  return sum
}

func countDay(_ i: Int, _ array: [Float], _ offset: Int, _ predicat: (Float) -> Bool) -> Float {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let count = slice.reduce(into: 0) { counter, value in if predicat(value) { counter += 1 } }
  return Float(count)
}

func countiff(_ values: ArraySlice<Float>, _ predicat: (Float) -> Bool) -> Float {
  let count = values.reduce(into: 0) { counter, value in if predicat(value) { counter += 1 } }
  return Float(count)
}

func iff(_ expression: Bool, _ yes: Float, _ no: Float) -> Float { expression ? yes : no }

func ifFinite(_ check: Float, _ subs: Float) -> Float { check.isFinite ? check : subs }

func and(_ conditions: Bool...) -> Bool { conditions.allSatisfy { $0 } }

func or(_ conditions: Bool...) -> Bool { conditions.contains(true) }

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
