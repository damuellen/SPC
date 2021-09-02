import Foundation
import PhysicalQuantities

func evaluate(_ f: (Double)->Double, _ range: ClosedRange<Double>, numberOfSamples: Int = 100) -> [(x: Double, y: Double)] {
    let step = (range.upperBound - range.lowerBound) / Double(numberOfSamples)
    let x = Array(stride(from: range.lowerBound, through: range.upperBound, by: step))
    let y = x.map(f)
    return zip(x,y).xy
}

extension Zip2Sequence {
  var xy: [(Sequence1.Element, Sequence2.Element)] { map { ($0, $1) } }
}

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
  let places = "\(count)".count
  
  for i in 0..<count {
    print(xs.reduce(String(format: "%0\(places)d\t", i)) {
      $0 + String(format: "%3.1f\t", $1[i]).replacingOccurrences(of: "0.0", with: "0").leftpad(length: 6)
    })
  }
  print("")
}
extension String {
  public func leftpad(length: Int, character: Character = " ") -> String {
    
    var outString: String = self
    
    let extraLength = length - outString.count
    
    var i = 0
    while (i < extraLength) {
      outString.insert(character, at: outString.startIndex)
      i += 1
    }
    
    return outString
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
}
extension Array where Element == Double {
  var total: Float { Float(reduce(0.0, +)) }
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

    let firstSeparator = rawData.firstIndex(of: separator) ?? 0

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


struct Results {
  init() {
    var rows = [[String:Double]]()
    #if DEBUG
    let url = URL(fileURLWithPath: "/workspaces/SPC/output.txt")

    guard let dataFile = DataFile(url) else { fatalError() }

    for data in dataFile.data {
      var dict: [String:Double] = [:]
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

  let rows: [[String:Double]]

  subscript(key: String) -> Double {
    let i = Int(key.filter(\.isNumber))! + 1
    return rows[i][key.filter(\.isLetter)]!
  }

  func compare(_ results: [Double], with key: String) {
    var r = 4
    var isCorrect = true
    var out = "Column \(key)\n"
    var c = 0
    zip(rows, results.dropFirst()).forEach {
      let value = $0[key]!
      if abs(value - $1) > 0.2 {
        isCorrect = false      
        if c < 5 {
          print("Row \(r)", "set: ", $0[key]!.asString(), " is: ", $1.asString(), to: &out)
        } 
        c += 1
      }
      r += 1
    }
    if isCorrect {
      print("No mismatch in column \(key)")
    } else {
      if c > 5 {
        print("\(c - 5) other errors", to: &out)
      }
      print(out)
    }
  }
}


extension Polynomial {
  init(x: [Double], y: [Double], degree n: Int = 5) {
    /// degree of polynomial to fit the data
    var n: Int = n
    /// no. of data points
    let N: Int = min(x.count, y.count)

    var X: [Double] = Array(repeating: 0.0, count: 2 * n + 1)

    for i in X.indices {
      for j in 0..<N {
        // consecutive positions of the array will store N,sigma(xi),sigma(xi^2),sigma(xi^3)....sigma(xi^2n)
        X[i] += pow(x[j], Double(i))  
      }
    }
    var a: [Double] = Array(repeating: 0, count: n + 1)
    /// B is the Normal matrix(augmented) that will store the equations, 'a' is for value of the final coefficients
    var B: [[Double]] = Array(repeating: Array(repeating: 0, count: n + 2), count: n + 1)

    for i in 0...n {
      for j in 0...n {
        // Build the Normal matrix by storing the corresponding coefficients at the right positions except the last column of the matrix
        B[i][j] = X[i + j]
      }
    }

    /// Array to store the values of sigma(yi),sigma(xi*yi),sigma(xi^2*yi)...sigma(xi^n*yi)
    var Y: [Double] = Array(repeating: 0, count: n + 1)

    for i in 0..<(n + 1) {
      Y[i] = 0
      for j in 0..<N {
        // consecutive positions will store sigma(yi),sigma(xi*yi),sigma(xi^2*yi)...sigma(xi^n*yi)
        Y[i] += pow(x[j], Double(i)) * y[j]
      }
    }

    for i in 0...n {
      // load the values of Y as the last column of B(Normal Matrix but augmented)
      B[i][n + 1] = Y[i]
    }

    n += 1
    for i in 0..<n {  
      // From now Gaussian Elimination starts(can be ignored) to solve the set of linear equations (Pivotisation)
      for k in (i + 1)..<n {
        if B[i][i] < B[k][i] {
          for j in 0...n {
            let temp = B[i][j]
            B[i][j] = B[k][j]
            B[k][j] = temp
          }
        }
      }
    }

    for i in 0..<(n - 1) {  // loop to perform the gauss elimination
      for k in (i + 1)..<n {
        let t = B[k][i] / B[i][i]
        for j in 0...n {
          // make the elements below the pivot elements equal to zero or elimnate the variables
          B[k][j] -= t * B[i][j]
        }
      }
    }

    for i in (0..<(n - 1)).reversed() { // back-substitution
      // x is an array whose values correspond to the values of x,y,z..
      // make the variable to be calculated equal to the rhs of the last equation
      a[i] = B[i][n]
      for j in 0..<n {
        if j != i {
          // then subtract all the lhs values except the coefficient of the variable whose value is being calculated
          a[i] -= B[i][j] * a[j]
        }
      }
      a[i] /= B[i][i] // now finally divide the rhs by the coefficient of the variable to be calculated
    }
    a.removeLast()
    self.init(a)
  }
}
