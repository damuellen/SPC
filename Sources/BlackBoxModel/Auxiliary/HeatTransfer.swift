//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

// Extension of the HeatTransferFluid enum to calculate the heat content of a cycle.
extension HeatTransferFluid {
  /// Calculates the heat content of a cycle using the outlet and inlet temperatures.
  ///
  /// - Parameter cycle: The HeatTransfer cycle.
  /// - Returns: The calculated heat content.
  func heatContent(_ cycle: HeatTransfer) -> Heat {
    heatContent(cycle.temperature.outlet, cycle.temperature.inlet)
  }

  /// Calculates the outlet temperature when two heat transfers are mixed.
  ///
  /// - Parameters:
  ///   - f1: First HeatTransfer object to be mixed.
  ///   - f2: Second HeatTransfer object to be mixed.
  /// - Returns: The resulting outlet temperature after mixing.
  func mixingOutlets(_ f1: HeatTransfer, _ f2: HeatTransfer) -> Temperature {
    if f1.massFlow.rate == 0 { return f2.temperature.outlet }
    if f2.massFlow.rate == 0 { return f1.temperature.outlet }
    let (t1, t2) = (f1.outlet, f2.outlet)
    let (mf1, mf2) = (f1.massFlow.rate, f2.massFlow.rate)
    guard mf1 + mf2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = heatCapacity[0].addingProduct(heatCapacity[1], t1)
    let cap2 = heatCapacity[0].addingProduct(heatCapacity[1], t2)
    let t = (mf1 * cap1 * t1 + mf2 * cap2 * t2) / (mf1 * cap1 + mf2 * cap2)
    precondition(t > freezeTemperature.kelvin, "Fell below freezing point.\n")
    return Temperature(t)
  }
}

// Extension of HeatTransferFluid to create an instance from a configuration file.
extension HeatTransferFluid {
  /// Initializes a HeatTransferFluid instance from a configuration file.
  ///
  /// - Parameter file: The TextConfigFile containing the configuration data.
  /// - Throws: An error if there's an issue reading the configuration file.
  public init(file: TextConfigFile) throws {
    // Helper function to read double values from the configuration file at the given line number.
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    try self.init(
      name: file.name,
      freezeTemperature: ln(10),
      heatCapacity: [ln(13), ln(16)],
      dens: [ln(19), ln(22), ln(25)],
      visco: [ln(28), ln(31), ln(34)],
      thermCon: [ln(37), ln(40), ln(43)],
      maxTemperature: ln(46),
      h_T: [], T_h: []
    )
  }
}

/// Protocol for representing a heat transfer process with a name, mass flow, and temperature.
protocol HeatTransfer: CustomStringConvertible {
  var name: String { get }
  var massFlow: MassFlow { get set }
  var temperature: (inlet: Temperature, outlet: Temperature) { get set }
}

/// A struct representing a heat transfer cycle with mass flow and temperature properties.
public struct Cycle: HeatTransfer {
  public var name: String
  public var massFlow: MassFlow
  public var temperature: (inlet: Temperature, outlet: Temperature)
}

// Extension of Cycle struct to provide additional initializers.
extension Cycle {
  /// Initializes a Cycle with a given loop name, setting mass flow and temperatures to zero.
  ///
  /// - Parameter loop: The name of the loop to create.
  init(loop: String) {
    self.name = loop
    self.massFlow = 0.0
    let inlet = Simulation.initialValues.temperatureOfHTFinPipes
    let outlet = Simulation.initialValues.temperatureOfHTFinHCE
    self.temperature = (inlet: inlet, outlet: outlet)
  }

  /// Initializes a Cycle with a given name, setting mass flow to zero, and using the initial HTF temperature.
  ///
  /// - Parameter name: The name of the cycle.
  init(name: String) {
    self.name = name
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinPipes
    self.temperature = (inlet: temperature, outlet: temperature)
  }
}

// Extension of Cycle struct to conform to Comparable, comparing cycles based on their minimum temperature.
extension Cycle: Comparable {
  public static func < (lhs: Cycle, rhs: Cycle) -> Bool {
    lhs.minTemperature < rhs.minTemperature
  }

  public static func == (lhs: Cycle, rhs: Cycle) -> Bool {
    lhs.minTemperature == rhs.minTemperature
  }
}

// Extension of the HeatTransfer protocol to provide computed properties and helper methods.
extension HeatTransfer {
  /// Computed property to create a Cycle from the current HeatTransfer instance.
  var cycle: Cycle {
    Cycle(name: name, massFlow: massFlow, temperature: temperature)
  }

  /// Computed property to calculate the average temperature of the HeatTransfer.
  var average: Temperature {
    Temperature.average(temperature.inlet, temperature.outlet)
  }

  /// Computed property to get the minimum temperature between inlet and outlet.
  var minTemperature: Double { min(inlet, outlet) }

  /// Computed property to get the temperature in Kelvin at the inlet.
  var inlet: Double { temperature.inlet.kelvin }

  /// Computed property to get the temperature in Kelvin at the outlet.
  var outlet: Double { temperature.outlet.kelvin }

  /// Computed property to get the mass flow rate.
  var flow: Double { massFlow.rate }

  /// Computed property to get the HeatTransferFluid used for the heat transfer process.
  var medium: HeatTransferFluid { SolarField.parameter.HTF }

  /// Computed property to get the heat content of the HeatTransfer.
  var heat: Double {
    medium.heatContent(temperature.outlet, temperature.inlet)
  }

  /// Custom description for HeatTransfer instances.
  public var description: String {
    "  Mass flow: \(massFlow.rate) kg/s".padding(28)
      + " T in: \(temperature.inlet.celsius) degC".padding(20)
      + " T out: \(temperature.outlet.celsius) degC".padding(20)
  }

  /// Computed property to get the formatted values for the HeatTransfer instance.
  var formattedValues: [String] {
    [
      String(format: "%3.1f", massFlow.rate),
      String(format: "%3.1f", temperature.inlet.celsius),
      String(format: "%3.1f", temperature.outlet.celsius),
    ]
  }

  /// Computed property to get the values (mass flow rate, inlet temperature, outlet temperature) as Doubles.
  var values: [Double] {
    [massFlow.rate, temperature.inlet.celsius, temperature.outlet.celsius]
  }

  /// Perform heat transfer from two HeatTransfer instances and set the inlet temperature accordingly.
  mutating func heatTransfer(from c1: HeatTransfer, and c2: HeatTransfer) {
    temperature.inlet = medium.mixingOutlets(c1, c2)
    massFlow = c1.massFlow + c2.massFlow
  }
  
  /// Perform heat transfer from another HeatTransfer instance and set the inlet temperature accordingly.
  mutating func heatTransfer(from c1: HeatTransfer) {
    temperature.inlet = medium.mixingOutlets(self, c1)
    massFlow += c1.massFlow
  }

  /// Set the outlet temperature equal to the inlet temperature.
  mutating func uniformTemperature() {
    temperature.outlet = temperature.inlet
  }

  /// Set the inlet temperature to the given temperature.
  mutating func setTemperature(inlet: Temperature) {
    temperature.inlet = inlet
  }

  /// Set the outlet temperature to the given temperature.
  mutating func setTemperature(outlet: Temperature) {
    temperature.outlet = outlet
  }

  /// Set the outlet temperature to the given value.
  mutating func outletTemperature(kelvin: Double) {
    temperature.outlet = Temperature(kelvin)
    assert(temperature.outlet > medium.freezeTemperature,
           "\(temperature) is below the freezing point of the HTF")
  }

  /// Set the mass flow and inlet temperature from another HeatTransfer instance.
  mutating func massFlow(in other: HeatTransfer) {
    massFlow = other.massFlow
    temperature.inlet = other.temperature.inlet
  }

  /// Set the mass flow and inlet temperature from another outlet.
  mutating func massFlow(from other: HeatTransfer) {
    massFlow = other.massFlow
    temperature.inlet = other.temperature.outlet
  }

  /// Set the inlet temperature from another outlet.
  mutating func inletTemperature(output other: HeatTransfer) {
    temperature.inlet = other.temperature.outlet
  }

  /// Set the inlet temperature from another inlet.
  mutating func inletTemperature(input other: HeatTransfer) {
    temperature.inlet = other.temperature.inlet
  }

  /// Set the outlet temperature from another outlet.
  mutating func outletTemperature(output other: HeatTransfer) {
    temperature.outlet = other.temperature.outlet
  }
}

// Extension of the Collection protocol where Element is HeatTransfer, to get an array of formatted values.
extension Collection where Element == HeatTransfer {
  /// Computed property to get an array of formatted values (mass flow rate, inlet temperature, outlet temperature).
  var values: [String] {
    reduce(into: []) { $0.append(contentsOf: $1.formattedValues) }
  }
}
