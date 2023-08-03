//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

/// A data structure representing the tariff structure for an energy provider.
///
/// The `TariffStructure` struct defines the structure of tariffs offered by an
/// energy provider. It includes various components such as energy payment,
/// energy cost, capacity payment, bonus payment, and availability-based
/// capacity. These components are used to calculate the cost and pricing for
/// different energy plans.
///
/// The struct contains the following properties:
/// - `name`: The name of the tariff structure.
/// - `abbreviation`: An abbreviation or short code for the tariff structure.
/// - `energyPayment`: The payment amount for energy consumption.
/// - `energieCost`: The cost of energy per unit.
/// - `capacityPaymentPercent`: The percentage of capacity payment based on the
///   total capacity used.
/// - `capacityPayment`: The payment amount for the capacity used.
/// - `bonusPaymentPercent`: The percentage of bonus payment based on the total
///   capacity used.
/// - `bonusPayment`: The payment amount for the bonus, if applicable.
/// - `asAvailableCapacity`: The payment amount based on the available capacity.
struct TariffStructure: Codable {
  let name: String
  let abbreviation: String
  let energyPayment, energieCost: Double
  let capacityPaymentPercent, capacityPayment: Double
  let bonusPaymentPercent, bonusPayment: Double
  let asAvailableCapacity: Double
}

/// A data structure representing the tariff seasons for an energy provider.
///
/// The `TariffSeason` struct defines the seasons for which specific tariffs
/// are applicable. It includes information about peak and off-peak periods on
/// weekdays, Saturdays, and holidays. The struct is used to determine the
/// pricing and rates for different time periods and days throughout the year.
///
/// The struct contains the following properties:
/// - `name`: The name of the tariff season.
/// - `v1PfD`, `v1PlD`, `v2PfD`, `v2PlD`: Integer values representing
///   time periods for peak and off-peak rates for various tariffs.
/// - `weekday`: An array of integers representing weekdays (Sunday to
///   Saturday) when the tariff season is applicable.
/// - `saturday`: An array of integers representing Saturdays when the tariff
///   season is applicable.
/// - `holyday`: An array of integers representing holidays when the tariff
///   season is applicable.
struct TariffSeason: Codable {
  let name: String
  let v1PfD, v1PlD, v2PfD, v2PlD: Int
  let weekday, saturday, holyday: [Int]
}

extension TariffStructure: CustomStringConvertible {
  public var description: String { name }
}

/// A data structure representing an energy provider's tariff plan.
///
/// The `Tariff` struct defines an energy provider's tariff plan, which
/// includes the different tariff structures and seasons offered to consumers.
/// The tariff plan specifies various pricing and rates based on factors such
/// as energy consumption, capacity usage, and time periods.
///
/// The struct contains the following properties:
/// - `name`: The name of the tariff plan.
/// - `tariff`: An array of `TariffStructure` instances representing the
///   different tariff structures available in the plan.
/// - `season`: An array of `TariffSeason` instances representing the different
///   tariff seasons applicable in the plan.
///
/// The struct extends `TextConfigInitializable`, which means it
/// can be initialized using data read from a text configuration file.
/// The `init(file:)` initializer reads and parses the necessary data from the
/// provided `TextConfigFile`, creating an instance of `Tariff` based on the
/// file contents.
struct Tariff: Codable {
  let name: String
  let tariff: [TariffStructure]
  let season: [TariffSeason]
}

extension Tariff: TextConfigInitializable {
  init(file: TextConfigFile) throws {
    let ln1: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    var tariffs = [TariffStructure]()
    for n in 0..<8 {
      let offset = 34 * n
      try tariffs.append(TariffStructure(
        name: file.readString(lineNumber: 228), 
        abbreviation: file.readString(lineNumber: 231), 
        energyPayment: ln1(237 + offset),
        energieCost: ln1(240 + offset),
        capacityPaymentPercent: ln1(243 + offset),
        capacityPayment: ln1(246 + offset),
        bonusPaymentPercent: ln1(249 + offset),
        bonusPayment: ln1(252 + offset),
        asAvailableCapacity: ln1(255 + offset))
      )
    }

    let ln: (Int) throws -> Int = { try file.readInteger(lineNumber: $0) }
    let ln2: (Int) throws -> [Int] = { try file.readIntegers(lineNumber: $0) }
    var seasons = [TariffSeason]()
    for n in 0..<4 {
      let o = 40 * n
      try seasons.append(
        TariffSeason(
          name: file.readString(lineNumber: 68 + o),
          v1PfD: ln(77 + o), v1PlD: ln(80 + o),
          v2PfD: ln(83 + o), v2PlD: ln(86 + o),
          weekday: ln2(95 + o), saturday: ln2(100 + o), holyday: ln2(101 + o)
        )
      )
    }

    self.name = try file.readString(lineNumber: 7)
    self.tariff = tariffs
    self.season = seasons
  }
}
