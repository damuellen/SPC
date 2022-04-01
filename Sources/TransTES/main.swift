
import Foundation
import Helpers

extension Date {
  var excel: TimeInterval {
    (self.timeIntervalSince1970 / 86400) + 25569
  }
}

func readTariffs() -> [Tariffs] {
  guard let csv = CSVReader(atPath: "Tariffs.txt") else { return [] }

  let cal = Calendar(identifier: .gregorian)

  let year = 2019

  let startOfYear = 
    DateComponents(calendar: cal, year: year, month: 1, day: 1).date!

  var currentDate = startOfYear

  let tariffs = csv.dataRows.map { values -> Tariffs in
    defer { currentDate.addTimeInterval(3600) }
    return Tariffs(date: currentDate, values: values)
  }

  return tariffs
}

func splitIntoYears(tariffs: [Tariffs]) -> [Year] {
  let days: [Day] = tariffs
    .chunks(ofCount: 24)
    .map(Day.init(tariffs:))

  var endIndex = 0

  let years = (2019...2050).map { i -> Year in
    var year = Year(year: i)
    let count = year.isLeapYear ? 366 : 365
    endIndex += count
    let startIndex = endIndex - count
    year.days = Array(days[startIndex..<endIndex])
    return year
  }

  precondition(days.endIndex == endIndex)
  return years
}

struct Price {
  var euro: Double
}

extension Price {
  init(_ value: Double) {
    self.euro = value
  }
}

extension Price: CustomStringConvertible {
  public var description: String {
    String(format: "%.2f Euro", euro)
  }
}

extension Price: Comparable {
  static func < (lhs: Price, rhs: Price) -> Bool {
    lhs.euro < rhs.euro
  }
  static func == (lhs: Price, rhs: Price) -> Bool {
    lhs.euro == rhs.euro
  }
}

struct Tariffs {
  var date: Date
  var electricity: Price
  var naturalGas: Price
  var markup: Price
  
  var cleanGas: Price {
    Price(euro: naturalGas.euro / 0.9 + 0.202 * markup.euro)
  }

  var isElectricityCheaper: Bool {
    electricity.euro < cleanGas.euro
  }
}

extension Tariffs {
  init(date: Date, values: [Double]) {
    precondition(values.count == 3, "Value missing")
    self.date = date
    self.electricity = Price(values[0])
    self.naturalGas = Price(values[1])
    self.markup = Price(values[2])
  }
}

extension Tariffs: Comparable {
  static func < (lhs: Tariffs, rhs: Tariffs) -> Bool {
    lhs.electricity < rhs.electricity
  }
  static func == (lhs: Tariffs, rhs: Tariffs) -> Bool {
    lhs.electricity == rhs.electricity
  }
}

extension Tariffs: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(date)
  } 
}

extension Tariffs: CustomStringConvertible {
  static var captions: [String] {
    ["Electricity", "Clean gas"]
  }

  var values: [Double] {
    [electricity.euro, naturalGas.euro, markup.euro, cleanGas.euro]
  }

  var formattedValues: [String] {
    [electricity.description, cleanGas.description]
  }

  public var description: String {
    formattedValues.reduce("\(date.excel),") { $0 + "\($1)," }
  }
}

struct Year {
  let year: Int
  var days: [Day] = []

  var isLeapYear: Bool {
    ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
  }

  var tariffs: [Tariffs] {
    days.flatMap(\.tariffs)
  }
}

enum Storage {
  case charge(Int), discharge(Int), empty, full, standby(Int)

  var isChargeable: Bool {
    if load == 10 { return false }
    return true
  }

  var isDischargeable: Bool {
    if load == 0 { return false }
    return true
  }

  var load: Int {
    switch self {
      case .empty: return 0
      case .full: return 10
      case .charge(let load): return load
      case .discharge(let load): return load
      case .standby(let load): return load
    }
  }
}

extension Storage: CustomStringConvertible {
  public var description: String {
    switch self {
      case .charge(let load): return "Charge \(load)"
      case .discharge(let load): return "Discharge \(load)"
      case .full: return "Full"
      case .empty: return "No load"
      case .standby(let load): return "Stand by \(load)"
    }
  }
}

struct Day {
  let tariffs: [Tariffs]

  init(tariffs: ArraySlice<Tariffs>) {
    let array = Array(tariffs)
    self.tariffs = array
    self.rankings = zip(array.indices, array)
     .sorted {$0.1 < $1.1 }
     .map { $0.0 + 1 }
  }

  let rankings: [Int]

  var average: Price {
    Price(euro: 
      tariffs
        .map(\.electricity.euro)
        .reduce(0, +) / 24
    )
  }
}

extension Day {
  func storage(status: Storage) -> [Storage] {
    var status = status
    var remaining = Array(rankings.reversed())

    return rankings.map { rank -> Storage in
      remaining.removeLast()
      
      if status.isChargeable, rank < 8
      {
        let load = status.load + 2
        if load > Storage.full.load {
          status = .full
        } else {
          status = .charge(load)
        }
        return status 
      } 

      let timeleft = remaining.count - status.load
      let charge = remaining.contains(where: { $0 > rank })

      if status.isDischargeable, !charge || timeleft < 0
      {
        status = .discharge(status.load - 1)
        return status
      }
      
      status = status.isDischargeable ? .standby(status.load) : .empty
      return status
    }
  }
}

func main() {
  let tariffs = readTariffs()
  let years = splitIntoYears(tariffs: tariffs)

  // let cheaperPerDay = years.map { year in
  //   year.days.map { day in
  //     day.tariffs
  //       .filter(\.isElectricityCheaper)
  //       .count
  //   } 
  // }

  // let cheaperHours = years.map { year in
  //   year.tariffs
  //     .filter(\.isElectricityCheaper)
  //     .count 
  // } 

  // let cheaperDays = cheaperPerDay.map { days in 
  //   days.filter({ $0 > 0 }).count
  // }

  //print(cheaperDays)
  //print(cheaperHours)

  var status = Storage.empty

  years.dropFirst(3).forEach { year in 
    year.days.forEach { day in
      let s = day.storage(status: status)
      status = s.last!
      zip(day.tariffs, s).forEach {
        print($0.0.description, $0.1.description)
      }
    }
  }
}

main()
