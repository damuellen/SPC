// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

/// A data structure representing the current status of the solar power plant.
///
/// The `Status` struct holds the current state of various components in the
/// solar power plant. It includes properties representing the status of the
/// collector, solar field, heat exchanger, power block, steam turbine, heater,
/// boiler, gas turbine, and storage. This struct provides methods to convert
/// the status to a human-readable description, extract the operating modes
/// of different components, and obtain the numerical values of relevant
/// measurements.
public struct Status: CustomStringConvertible, MeasurementsConvertible {
  // Properties representing the current status of each component in the solar power plant
  var collector = Collector.initialState
  var solarField = SolarField.initialState
  var heatExchanger = HeatExchanger.initialState
  var powerBlock = PowerBlock.initialState
  var steamTurbine = SteamTurbine.initialState
  var heater = Heater.initialState
  var boiler = Boiler.initialState
  var gasTurbine = GasTurbine.initialState
  var storage = Storage.initialState

  /// A textual representation of the `Status` instance.
  ///
  /// This property provides a human-readable description of the current
  /// status of each component in the solar power plant. It includes details
  /// about the collector, solar field, heat exchanger, power block, steam
  /// turbine, heater, boiler, gas turbine, and storage. Depending on the
  /// design configuration, it may exclude certain components that are not
  /// present in the current solar power plant setup.
  public var description: String {
    "\nCollector:\n\(collector)\n\n"
      + (Design.hasSolarField ? "Solar Field:\n\(solarField)\n\n" : "")
      + "Heat Exchanger:\n\(heatExchanger)\n\n"
      + "Power Block:\n\(powerBlock)\n\n"
      + "Steam Turbine:\n\(steamTurbine)\n\n"
      + (Design.hasHeater ? "Heater:\n\(heater)\n\n" : "")
      + (Design.hasBoiler ? "Boiler:\n\(boiler)\n\n" : "")
      + (Design.hasGasTurbine ? "Gas Turbine:\n\(gasTurbine)\n\n" : "")
      + (Design.hasStorage ? "Storage:\n\(storage)\n" : "")
  }

  static var modes: [String] {
    ["SolarField", "Storage", "Heater"]
  }

  var modes: [String] {
    [
      solarField.operationMode.description,
      storage.operationMode.description,
      heater.operationMode.rawValue
    ]
  }
  
  /// An array of numerical values for relevant measurements in the current status.
  ///
  /// The `values` property provides an array of numerical values representing
  /// various measurements relevant to the current status of the solar power plant.
  /// It includes values for mass flow rates, temperatures, and other relevant
  /// data from the collector, solar field, storage, heater, power block,
  /// heat exchanger, and other components in the solar power plant.
  ///
  /// The array is constructed by concatenating measurements from different components,
  /// extracted using the `values` property of those components conforming to the
  /// `MeasurementsConvertible` protocol. The mass flow rates for the solar field
  /// and heater are obtained separately from their conforming protocols.
  var values: [Double] {
    let values = collector.values //+ storage.salt.values
     + (storage as MeasurementsConvertible).values
     + (solarField as MeasurementsConvertible).values
    let flows = (storage as ThermalProcess).values
     + heater.values
     + powerBlock.cycle.values 
     + heatExchanger.values
     + solarField.header.values 
    let loops = solarField.loops.flatMap(\.values)
    return values + flows + loops
  }

  /// An array of measurements names and units for the current status.
  ///
  /// The `measurements` property provides an array of tuples containing the names
  /// and units of various measurements relevant to the current status of the solar
  /// power plant. It includes measurements for mass flow rates, inlet temperatures,
  /// and outlet temperatures for the collector, solar field, storage, heater, power block,
  /// heat exchanger, and different loops in the solar field (design loop, near loop,
  /// average loop, and far loop).
  ///
  /// The measurements are organized and grouped based on the component names and the
  /// specific values being measured. The names and units for each measurement are
  /// constructed by combining the component name and specific value being measured.
  static var measurements: [(name: String, unit: String)] {
    let values: [(name: String, unit: String)] =
      [("|Massflow", "kg/s"), ("|Tin", "degC"), ("|Tout", "degC")]
    return Collector.measurements //+ Storage.Salt.measurements 
      + Storage.measurements + SolarField.measurements + [
      "Storage", "Heater", "PowerBlock", "HeatExchanger", "SolarField",
      "DesignLoop", "NearLoop", "AvgLoop", "FarLoop",
    ].flatMap { name in
      values.map { value in (name + value.name, value.unit) }
    }
  }
}
