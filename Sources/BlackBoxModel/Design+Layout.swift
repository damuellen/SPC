//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

public enum Design {
  public static var layout: Layout = Layout()

  static let hasSolarField = layout.solarField > 0
  static let hasHeater = layout.heater < 0
  static let hasHeatExchanger = layout.heatExchanger > 0
  static let hasBoiler = layout.boiler > 0
  static let hasGasTurbine = layout.gasTurbine > 0
  static let hasPowerBlock = layout.powerBlock > 0
  static let hasStorage = layout.storage > 0
}

public struct Layout: Codable {
  public var solarField = 100.0
  var heater = -10.0
  var heatExchanger = 75.0
  var boiler = 0.0
  var gasTurbine = 0.0
  var powerBlock = 80.0
  var storage = 20.0
  var storage_cap = 200.0
  var storage_ton = 0.0
}

extension Layout: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let values: [String] = file.values.filter { !$0.isEmpty }
    let first = values.compactMap { $0.split(separator: " ").first }
    let trimmed = first.map {
      String($0).trimmingCharacters(in: .whitespaces)
    }

    for (count, value) in zip(1..., trimmed) {
      if count == 9, let definition = Storage.Definition(rawValue: value) {
        Storage.parameter.definedBy = definition
      }
      guard let value = Double(value)
      else { continue }
      switch count {
      case 1: self.solarField = value
      case 2: self.storage = value
      case 3: self.heater = value
      case 4: self.boiler = value
      case 5: self.gasTurbine = value
      case 6: self.powerBlock = value
      case 7: self.heatExchanger = value
      case 8: break // NDI
      case 10: self.storage_cap = value
      case 11: self.storage_ton = value
      case 12: break // Through
      default: throw TextConfigFile.ReadError.unexpectedValueCount
      }
    }
  }
}
