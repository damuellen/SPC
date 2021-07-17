import Foundation

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

extension Double {
  static func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
  }

  static func **= (lhs: inout Double, rhs: Double) {
    lhs = lhs ** rhs
  }
  @inline(__always)
  func asString(precision: Int = 2) -> String {
    String(format: "%.\(precision)f", self)
  }
}

func write(_ xs: [Double]..., maxLength: Int = Int.max) {
  let count = min(xs.reduce(0) { max($0, $1.count) }, maxLength)
  let places = "\(count)".count - 1
  print("")
  for i in 0..<count {
    print(xs.reduce(String(format: "%0\(places)d   ", i)) {
      $0 + String(format: "%3.1f\t", $1[i])
    })
  }
}

extension Sequence where Element == Double {
  func write(_ count: Int? = nil) {
    if let count = count {
      zip(0..., self.prefix(count)).forEach { Swift.print($0, $1.asString()) }
    } else {
      zip(0..., self).forEach { Swift.print($0, $1.asString()) }
    }
  }

  func quotient(_ divisor: Double) -> [Double] {
    self.map { $0 / divisor }
  }

  func product(_ factor: Double) -> [Double] {
    self.map { $0 * factor }
  }

  var sum: Double { self.reduce(into: 0.0) { sum, value in sum += value  } }
}

func average(_ values: ArraySlice<Double>) -> Double {
  let sum = values.reduce(into: 0.0) { sum, value in
    sum += value
  }
  return sum / Double(values.count)
}

func sum(_ values: ArraySlice<Double>) -> Double {
  values.reduce(into: 0.0) { sum, value in
    sum += value
  }
}

func countiff(_ values: ArraySlice<Double>, _ predicat: (Double)-> Bool) -> Double {
  let count = values.reduce(into: 0) { counter, value in
    if predicat(value) { counter += 1 }
  }
  return Double(count)
}

func iff(_ expression: Bool, _ yes: Double, _ no: Double) -> Double {
  expression ? yes : no
}

struct DataFile {
  let data: [[Float]]

  init?(_ url: URL) {
    guard let rawData = try? Data(contentsOf: url)
     else { return nil }

    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: ",")

    guard let firstNewLine = rawData.firstIndex(of: newLine)
      else { return nil }

    guard let firstSeparator = rawData.firstIndex(of: separator)
      else { return nil }
    guard firstSeparator < firstNewLine
      else { return nil }

    let hasCR = rawData[rawData.index(before: firstNewLine)] == cr

    self.data = rawData.withUnsafeBytes { content in
      content.split(separator: newLine).map { line in
        let line = hasCR ? line.dropLast() : line
        return line.split(separator: separator).map { slice in
          let buffer = UnsafeRawBufferPointer(rebasing: slice)
            .baseAddress!.assumingMemoryBound(to: Int8.self)
          return strtof(buffer, nil)
        }
      }
    }
  }
}
