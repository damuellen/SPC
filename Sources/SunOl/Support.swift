import Foundation
import Utilities

func POLY(_ value: Double, _ coeffs: [Double]) -> Double {
  coeffs.reversed()
    .reduce(into: Double.zero) { result, coefficient in
      result = coefficient.addingProduct(result, value)
    }
}

extension Array where Element == Double {
  func sumif(_ range: Int, days: [[Int]], into array: inout [Double], at: Int) {
    for (i, day) in days.enumerated() {
      array[i + at] = 0.0
      day.forEach { d in array[i + at] += self[(d + range)] }
    }
  }

  func sumifs(
      _ range: Int, days: [[Int]], into array: inout [Double], at: Int,
      range range1: Int, criteria: (Double) -> Bool
    ) {
      for (i, day) in days.enumerated() {
        array[i + at] = 0.0
        day.forEach { d in
          if criteria(self[(d + range1)]) { array[i + at] += self[(d + range)] }
        }
      }
    }

  func sumifs(
    _ range: Int, days: [[Int]], into array: inout [Double], at: Int,
    range1: Int, criteria1: (Double) -> Bool, range2: Int,
    criteria2: (Double) -> Bool
  ) {
    for (i, day) in days.enumerated() {
      array[i + at] = 0.0
      day.forEach { d in
        if criteria1(self[(d + range1)]), criteria2(self[(d + range2)]) {
          array[i + at] += self[(d + range)]
        }
      }
    }
  }

  func sumif(_ range: Int, criteria: (Double) -> Bool = {_ in true}, hours: [[Int]])
    -> [Double]
  {
    Array(
      hours.map { day -> [Double] in var sum = 0.0
        day.forEach { d in let value = self[(d + range)]
          if criteria(value) { sum += value }
        }
        return [Double](repeating: sum, count: day.count)
      }
      .joined())
  }

  func countif(_ range: Int, criteria: (Double) -> Bool, days: [[Int]])
    -> [Double]
  {
    days.map { day in var count = 0
      day.forEach { 
        if criteria(self[($0 + range)]) { count += 1 }
      }
      return Double(count)
    }
  }

  func countif(range1: Int, criteria1: (Double) -> Bool,
    range2: Int, criteria2: (Double) -> Bool, days: [[Int]]
  ) -> [Double] {
    days.map { day in var count = 0
      day.forEach { 
        if criteria1(self[($0 + range1)]), criteria2(self[($0 + range2)]) {
          count += 1
        }
      }
      return Double(count)
    }
  }

  func countif(_ range: Int, criteria: (Double) -> Bool, hours: [[Int]])
    -> [Double]
  {
    Array(
      hours.map { day -> [Double] in var count = 0
        day.forEach { 
          if criteria(self[($0 + range)]) { count += 1 }
        }
        return [Double](repeating: Double(count), count: day.count)
      }
      .joined())
  }
}

@available(macOS 10.12, *) enum Hours {
  public static let Jan = Int(
    DateInterval.Jan.start.timeIntervalSinceReferenceDate / 3600)
  public static let Feb = Int(
    DateInterval.Feb.start.timeIntervalSinceReferenceDate / 3600)
  public static let Mar = Int(
    DateInterval.Mar.start.timeIntervalSinceReferenceDate / 3600)
  public static let Apr = Int(
    DateInterval.Apr.start.timeIntervalSinceReferenceDate / 3600)
  public static let May = Int(
    DateInterval.May.start.timeIntervalSinceReferenceDate / 3600)
  public static let Jun = Int(
    DateInterval.Jun.start.timeIntervalSinceReferenceDate / 3600)
  public static let Jul = Int(
    DateInterval.Jul.start.timeIntervalSinceReferenceDate / 3600)
  public static let Aug = Int(
    DateInterval.Aug.start.timeIntervalSinceReferenceDate / 3600)
  public static let Sep = Int(
    DateInterval.Sep.start.timeIntervalSinceReferenceDate / 3600)
  public static let Oct = Int(
    DateInterval.Oct.start.timeIntervalSinceReferenceDate / 3600)
  public static let Nov = Int(
    DateInterval.Nov.start.timeIntervalSinceReferenceDate / 3600)
  public static let Dec = Int(
    DateInterval.Dec.start.timeIntervalSinceReferenceDate / 3600)
}

@available(macOS 10.12, *) enum Days {
  public static let Jan = Int(
    DateInterval.Jan.start.timeIntervalSinceReferenceDate / 86400)
  public static let Feb = Int(
    DateInterval.Feb.start.timeIntervalSinceReferenceDate / 86400)
  public static let Mar = Int(
    DateInterval.Mar.start.timeIntervalSinceReferenceDate / 86400)
  public static let Apr = Int(
    DateInterval.Apr.start.timeIntervalSinceReferenceDate / 86400)
  public static let May = Int(
    DateInterval.May.start.timeIntervalSinceReferenceDate / 86400)
  public static let Jun = Int(
    DateInterval.Jun.start.timeIntervalSinceReferenceDate / 86400)
  public static let Jul = Int(
    DateInterval.Jul.start.timeIntervalSinceReferenceDate / 86400)
  public static let Aug = Int(
    DateInterval.Aug.start.timeIntervalSinceReferenceDate / 86400)
  public static let Sep = Int(
    DateInterval.Sep.start.timeIntervalSinceReferenceDate / 86400)
  public static let Oct = Int(
    DateInterval.Oct.start.timeIntervalSinceReferenceDate / 86400)
  public static let Nov = Int(
    DateInterval.Nov.start.timeIntervalSinceReferenceDate / 86400)
  public static let Dec = Int(
    DateInterval.Dec.start.timeIntervalSinceReferenceDate / 86400)
}

extension Double {
  var formatted: String { String(format: "%G", self) }
  static var one: Double { Double(1.0) }
}

extension Array where Element == Double {
  var total: Float { Float(reduce(0.0, +)) }
  var nonZeroCount: Int {
    reduce(into: 0) { counter, value in if value > 0 { counter += 1 } }
  }

  var readable: [String] { map(\.formatted) }
}

func round(_ value: Double, _ digits: Double) -> Double {
  (pow(10, digits) * value).rounded() / pow(10, digits)
}
func roundDown(_ value: Double, _ digits: Double = 2) -> Double {
  (pow(10, digits) * value).rounded(.down) / pow(10, digits)
}
func roundUp(_ value: Double, _ digits: Double = 2) -> Double {
  (pow(10, digits) * value).rounded(.up) / pow(10, digits)
}

func average(_ values: ArraySlice<Double>) -> Double {
  let sum = values.reduce(into: Double.zero) { sum, value in sum += value }
  return sum / Double(values.count)
}

func sumDay(_ i: Int, _ array: [Double], _ offset: Int) -> Double {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let sum = slice.reduce(into: 0) { sum, value in sum += value }
  return sum
}

func countDay(
  _ i: Int, _ array: [Double], _ offset: Int, _ predicat: (Double) -> Bool
) -> Double {
  let offset = offset + i.quotientAndRemainder(dividingBy: 24).quotient
  let slice = array[offset...].prefix(24)
  let count = slice.reduce(into: 0) { counter, value in
    if predicat(value) { counter += 1 }
  }
  return Double(count)
}

func countiff(_ values: ArraySlice<Double>, _ predicat: (Double) -> Bool)
  -> Double
{
  let count = values.reduce(into: 0) { counter, value in
    if predicat(value) { counter += 1 }
  }
  return Double(count)
}

func iff(_ expression: Bool, _ yes: Double, _ no: Double = Double.zero)
  -> Double
{ expression ? yes : no }

func ifFinite(_ check: Double, _ subs: Double = 0) -> Double {
  check.isFinite ? check : subs
}

func and(_ conditions: Bool...) -> Bool { conditions.allSatisfy { $0 } }

func or(_ conditions: Bool...) -> Bool { conditions.contains(true) }

protocol Labeled { var labels: [String] { get } }
extension Labeled {
  var labels: [String] {
    Mirror(reflecting: self).children.compactMap(\.label)
  }
}

public let tunol = """
████████╗██╗   ██╗███╗   ██╗ ██████╗ ██╗
╚══██╔══╝██║   ██║████╗  ██║██╔═══██╗██║
   ██║   ██║   ██║██╔██╗ ██║██║   ██║██║
   ██║   ██║   ██║██║╚██╗██║██║   ██║██║
   ██║   ╚██████╔╝██║ ╚████║╚██████╔╝███████╗
   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
""".colored()
