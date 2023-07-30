//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Tariff: Codable {
  let name: String
  let abbreviation: String
  let energyPayment, energieCost, capacityPaymentPercent, capacityPayment,
    bonusPaymentPercent, bonusPayment, asAvailableCapacity: Double
}

struct TariffSeason: Codable {
  let name: String
  let v1PfD, v1PlD, v2PfD, v2PlD: Int
  let weekday, saturday, holyday: [Int]
}

extension Tariff: CustomStringConvertible {
  public var description: String { name }
}

public struct Tariffs: Codable {
  let name: String
  let tariff: [Tariff]
  let season: [TariffSeason]
}

extension Tariffs: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln1: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    var tariffs = [Tariff]()
    for n in 0..<8 {
      let offset = 34 * n
      try tariffs.append(Tariff(
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
