//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Helpers

/// Design of the plant
public enum Design {
  public static var layout: Layout = Layout()
  /// The design has a solar field 
  static let hasSolarField = layout.solarField > 0
  /// The design has a heater
  static let hasHeater = layout.heater > 0
  /// The design has a boiler
  static let hasBoiler = layout.boiler > 0
  /// The design has a gas turbine
  static let hasGasTurbine = layout.gasTurbine > 0
  /// The design has a thermal storage
  static let hasStorage = max(layout.storage, layout.storage_cap, layout.storage_ton) > 0
}

/// Layout of the plant
public struct Layout: Codable, Equatable, Hashable, CustomStringConvertible {
  /// Number of loops in solar field 
  public var solarField = 148.0
  /// Thermal power of the heater
  public var heater = 10.0
  /// Thermal power of the heatexchanger
  public var heatExchanger = 75.0
  /// Thermal power of the boiler
  public var boiler = 0.0
  /// Thermal power of the gas turbine
  public var gasTurbine = 0.0
  /// Thermal power of the power block
  public var powerBlock = 80.0
  /// Storage capacity in hours
  public var storage = 5.0
  /// Storage capacity in energy
  public var storage_cap = 0.0
  /// Storage capacity in mass
  public var storage_ton = 0.0
  
  public var description: String {
    "Layout|SolarField " * "\(Int(solarField)) loops"
    + "Layout|Heater " * "\(Int(-heater)) MW"
    + "Layout|HeatExchanger " * "\(Int(heatExchanger)) MW"
//  + "Layout|Boiler " * "\(Int(boiler)) MW"
//  + "Layout|GasTurbine " * "\(Int(gasTurbine)) MW"
    + "Layout|PowerBlock " * "\(Int(powerBlock)) MW"
    + "Layout|Storage " * "\(Int(storage)) h"
//  + "Layout|Storage_cap " * "\(Int(storage_cap)) MWh"
//  + "Layout|Storage_ton " * "\(Int(storage_ton)) t"
  }
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
      default: throw TextConfigFile.ReadError.unexpectedEndOfFile(count,"")
      }
    }
  }
}
