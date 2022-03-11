import Foundation
import Utilities

public let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
public let semaphore = DispatchSemaphore(value: 0)

public func fitness(values: [Double]) -> [Double] {
  let model = TunOl(values)
  let costs = Costs(model)
  //dump(costs)
  //TunOl.Grid_import_yes_no_BESS_strategy = 0
  //TunOl.Grid_import_yes_no_PB_strategy = 0
  //dump(model)
  let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
  // hour0.head(8, steps: 8760)
  let hour1 = model.hour1(hour0: hour0)
  // hour1.head(48, steps: 8760)
  let day6 = model.day(hour0: hour0)
  var day = [[Double]]()

  for j in 0..<4 {
    let hour2 = model.hour2(j: j, hour0: hour0, hour1: hour1)
    let hour3 = model.hour3(j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    var day1 = model.day(case: j, hour2: hour2, hour3: hour3)
    let hour4 = model.hour4(j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
    let day15 = model.day(hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
    let day16 = model.day(hour0: hour0, hour4: hour4, day11: day1, day15: day15)
    let day17 = model.day(case: j, day1: day1, day5: day15, day6: day16)

    day.append(Array(day17[29200..<31390]))
    day.append(Array(day17[41610..<43800]))

    let day21 = model.day(case: j, hour0: hour0)     
    let day27 = model.day(case: j, day1: day21, day6: day6)

    day.append(Array(day27[33945..<35040]))
    day.append(Array(day27[44895..<45990]))
  }

  var year = [Double?]()
  for d in 0..<365 {
    let cases = day.indices.map { i in
      costs.LCOM(meth_produced_MTPH: day[i][d], elec_from_grid: day[i][d+365], elec_to_grid: day[i][d+365+365])
    }
    let best = cases.filter(\.isFinite).filter{$0>0}.sorted()
    if best.count > 0 { year.append(best[0]) } else { year.append(nil) } 
  }
  let i = year.compactMap {$0}
  let lcom = i.reduce(0.0,+) / Double(i.count)
  return [lcom] + values
}

public func MGOADE(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> [Double]) -> [[Double]] {
  var targetResults = Matrix(n * maxIter, bounds.count + 13)
  var targetPosition = Matrix(group ? 3 : 1, bounds.count)
  var targetFitness = Vector(group ? 3 : 1, .infinity)
  let EPSILON = 1E-14

  // Initialize the population of grasshoppers
  var grassHopperPositions = bounds.randomValues(count: n)
  var grassHopperFitness = Vector(n)
  var grassHopperTrialPositions = grassHopperPositions
  let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

  let cMax = 1.0
  let cMin = 0.00004
  let cr = 0.4
  let f = 0.9  
  let date = Date()
  let _ = fitness([])
  print(-date.timeIntervalSinceNow)
  // Calculate the fitness of initial grasshoppers
  DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
    let result = fitness(grassHopperPositions[i])
    grassHopperFitness[i] = result[0]
  }
  
  for g in groups.indices {
    // Find the best grasshopper per group (target) in the first population
    for i in groups[g].indices {
      if grassHopperFitness[i] < targetFitness[g] {
        targetFitness[g] = grassHopperFitness[i]
        targetPosition[g] = grassHopperPositions[i]
      }
    }
    TunOl.convergenceCurves[g].append([Double(0), targetFitness[g]])
  }
  print("\u{1b}[1J", terminator: "")
  print("First population:\n\(targetFitness)".text(.green))
  print(targetPosition.map(labeled(values:)).joined(separator: "\n"))

  func euclideanDistance(a: [Double], b: [Double]) -> Double {
    var distance = 0.0
    for i in a.indices { distance += pow((a[i] - b[i]), 2) }
    return sqrt(distance)
  }

  func S_func(r: Double) -> Double {
    let f = 0.5
    let l = 1.5
    return f * exp(-r / l) - exp(-r)  // Eq. (2.3) in the paper
  }

  var pos = 0
  var l = 0

  while l < maxIter && !source.isCancelled {
    l += 1
    let c = cMax - (Double(l) * ((cMax - cMin) / Double(maxIter)))  // Eq. (2.8) in the paper
    var S_i = Vector(bounds.count)
    var r_ij_vec = Vector(bounds.count)
    var s_ij = Vector(bounds.count)
    var X_new = Vector(bounds.count)
    for g in groups.indices {
      for i in groups[g].indices {
        for j in 0..<n {
          if i != j {
            // Calculate the distance between two grasshoppers
            let distance = euclideanDistance(a: grassHopperPositions[i], b: grassHopperPositions[j])
            for p in r_ij_vec.indices {
              r_ij_vec[p] = (grassHopperPositions[j][p] - grassHopperPositions[i][p]) / (distance + EPSILON)  // xj-xi/dij in Eq. (2.7)
            }
            let xj_xi = 2 + distance.remainder(dividingBy: 2)  // |xjd - xid| in Eq. (2.7)
            for p in r_ij_vec.indices {
              // The first part inside the big bracket in Eq. (2.7)
              s_ij[p] = ((bounds[p].upperBound - bounds[p].lowerBound) * c / 2) * S_func(r: xj_xi) * r_ij_vec[p]
            }
            for p in S_i.indices { S_i[p] = S_i[p] + s_ij[p] }
          }
        }

        let S_i_total = S_i
        for p in S_i.indices {
          X_new[p] = c * S_i_total[p] + targetPosition[g][p]  // Eq. (2.7) in the paper
        }
        // Update the target
        grassHopperPositions[i] = X_new
      }
    }
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      if source.isCancelled { return }
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
      grassHopperFitness[i] = result[0]
    }
    if source.isCancelled { break }

    var refresh = group
    // Multi-group strategy
    if group, l.isMultiple(of: 2) {
      for g in groups.indices {
        // Update the target
        for i in groups[g].indices {
          var o = [0, 1, 2]
          o.remove(at: g)
          let r1 = groups[o[0]].indices.randomElement()!
          let r2 = groups[o[1]].indices.randomElement()!
          
          for j in grassHopperPositions[i].indices {
            if Double.random(in: 0...1) < cr {
              grassHopperTrialPositions[i][j] =
                targetPosition[g][j] + f * (.random(in: 0...1) + 0.0001) * (grassHopperPositions[r1][j] - grassHopperPositions[r2][j])
              grassHopperTrialPositions[i][j].clamp(to: bounds[j])
            }
          }
        }
      }
    } else if group {
      for g in groups.indices {
        var o = [0, 1, 2]
        o.remove(at: g)
        for i in groups[g].indices {
          for p in grassHopperPositions[i].indices {
            grassHopperTrialPositions[i][p] += .random(in: 0...1) * (((targetPosition[o[0]][p] + targetPosition[o[1]][p]) / 2) - grassHopperPositions[i][p])
            grassHopperTrialPositions[i][p].clamp(to: bounds[p])
          }
        }
      }
    } else { refresh = false }

    if refresh {
      DispatchQueue.concurrentPerform(iterations: grassHopperTrialPositions.count) { i in
        if source.isCancelled { return }
        let result = fitness(grassHopperTrialPositions[i])
        if result[0] < grassHopperFitness[i] {
          grassHopperFitness[i] = result[0]
          grassHopperPositions[i] = grassHopperTrialPositions[i]
          targetResults[pos + i].replaceSubrange(0..<bounds.count, with: grassHopperPositions[i])
          targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
        }
      }
    }
    if source.isCancelled { break }
    pos += grassHopperPositions.count
    for g in groups.indices {
      // Update the target
      for i in groups[g].indices {
        if grassHopperFitness[i] < targetFitness[g] {
          targetFitness[g] = grassHopperFitness[i]
          targetPosition[g] = grassHopperPositions[i]
        }
      }
      TunOl.convergenceCurves[g].append([Double(l), targetFitness[g]])
    }
    print("Iterations: \(l)\n\(targetFitness)".randomColor())
    print(targetPosition.map(labeled(values:)).joined(separator: "\n"))
    if (targetFitness.reduce(0, +) / 3) - targetFitness.min()! < 0.001 { break }
  }
  targetResults.removeLast((maxIter - l) * n)
  return targetResults
}

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

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Double], condition: Int, predicate: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in 
        if predicate(range1[(d + condition)]) { sum += self[(d + range)] }
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

  func sumOfRanges(_ range: Int, days: [[Int]], range1: [Double], condition1: Int, predicate1: (Double) -> Bool, range2: [Double], condition2: Int, predicate2: (Double) -> Bool) -> [Double] {
    days.map { day in var sum = 0.0
      day.forEach { d in 
        if predicate1(range1[(d + condition1)]), predicate2(range2[(d + condition2)]) { sum += self[(d + range)] }
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
  let labels = [
    "LCOM", "BESS_cap", "CCU_C_O_2_nom_prod", "C_O_2_storage_cap", "CSP_loop_nr", "El_boiler_cap", "EY_var_net_nom_cons", "Grid_export_max",
    "Grid_import_max", "Hydrogen_storage_cap", "Heater_cap", "MethDist_Meth_nom_prod", "MethSynt_RawMeth_nom_prod", "PB_nom_gross_cap", "PV_AC_cap",
    "PV_DC_cap", "RawMeth_storage_cap", "TES_full_load_hours",
  ]

  return zip(labels, values).map { l, v in "\(l.text(.red)) \(String(format: "%.1f", v).text(.red))" }.joined(separator: " ")
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

public let tunol = """
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
    print(columns.joined(separator: " \t"))
    for i in 0..<100 {
      let s = stride(from: i, to: endIndex, by: steps)
      print(s.map { String(format: "%2.f", self[$0]) }.joined(separator: "\t"))
    }
    print()
  }
}
