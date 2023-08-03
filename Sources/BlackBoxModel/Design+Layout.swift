// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Helpers

/// The enum contains static properties that indicate whether the plant's design includes specific components.
/// These properties are based on the `Layout` instance created in the enum.
/// The properties represent the presence or absence of a solar field, heater, boiler, gas turbine, and thermal storage in the plant's design.
public enum Design {
  /// The layout of the plant.
  static var layout: Layout = Layout()

  /// A boolean indicating whether the plant design includes a solar field.
  static let hasSolarField = layout.solarField > 0

  /// A boolean indicating whether the plant design includes a heater.
  static let hasHeater = layout.heater > 0

  /// A boolean indicating whether the plant design includes a boiler.
  static let hasBoiler = layout.boiler > 0

  /// A boolean indicating whether the plant design includes a gas turbine.
  static let hasGasTurbine = layout.gasTurbine > 0

  /// A boolean indicating whether the plant design includes thermal storage.
  static let hasStorage = max(layout.storageHours, layout.storageCapacity, layout.storageTonnage) > 0
}

/// Layout of the plant
struct Layout: Codable, Equatable, Hashable, CustomStringConvertible {
  /// Number of loops in the solar field.
  var solarField = 148.0

  /// Thermal power of the heater.
  var heater = 10.0

  /// Thermal power of the heat exchanger.
  var heatExchanger = 75.0

  /// Thermal power of the boiler.
  var boiler = 0.0

  /// Thermal power of the gas turbine.
  var gasTurbine = 0.0

  /// Thermal power of the power block.
  var powerBlock = 70.0

  /// Storage capacity in hours.
  var storageHours = 5.0

  /// Storage capacity in energy.
  var storageCapacity = 0.0

  /// Storage capacity in mass.
  var storageTonnage = 0.0

  /// A string representation of the `Layout` instance.
  public var description: String {
    "Layout|SolarField " * "\(Int(solarField)) loops"
    + "Layout|Heater " * "\(Int(-heater)) MW"
    + "Layout|HeatExchanger " * "\(Int(heatExchanger)) MW"
    + "Layout|PowerBlock " * "\(Int(powerBlock)) MW"
    + "Layout|Storage " * "\(Int(storageHours)) h"
  }
}

extension Layout: TextConfigInitializable {
  /// Initializes the `Layout` instance from a text configuration file (`TextConfigFile`).
  ///
  /// - Parameter file: The `TextConfigFile` containing layout information.
  /// - Throws: An error if there is an issue reading or parsing the layout data from the file.
  init(file: TextConfigFile) throws {
    // Extract values from the file and store them in an array
    let values: [String] = file.lines.filter { !$0.isEmpty }.map { value in
      String(value.prefix(while: {!$0.isWhitespace})) 
    }

    // Iterate through the values and assign them to the corresponding properties
    for (count, value) in zip(1..., values) {
      if count == 9, let definition = Storage.Definition(rawValue: value) {
        Storage.parameter.definedBy = definition
      }
      guard let value = Double(value)
      else { continue }
      switch count {
      case 1: self.solarField = value
      case 2: self.storageHours = value
      case 3: self.heater = value
      case 4: self.boiler = value
      case 5: self.gasTurbine = value
      case 6: self.powerBlock = value
      case 7: self.heatExchanger = value
      case 8: break // NDI
      case 9: break
      case 10: self.storageCapacity = value
      case 11: self.storageTonnage = value
      case 12: break // Through
      default: throw TextConfigFile.ReadError.unexpectedEndOfFile(count, "")
      }
    }
  }
}
