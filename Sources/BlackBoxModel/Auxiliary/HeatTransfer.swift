// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

// Extension of the HeatTransferFluid enum to calculate the heat content of a cycle.
extension HeatTransferFluid {
  /// Calculates the outlet temperature when two thermal processes are mixed.
  ///
  /// - Parameters:
  ///   - tp1: The first thermal process object to be mixed.
  ///   - tp2: The second thermal process object to be mixed.
  /// - Returns: The resulting outlet temperature after mixing.
  func calculateMixedOutletTemperature(
    from tp1: ThermalProcess, and tp2: ThermalProcess) -> Temperature 
  {
    if tp1.massFlow.rate == 0 { return tp2.temperature.outlet }
    if tp2.massFlow.rate == 0 { return tp1.temperature.outlet }
    let (t1, t2) = (tp1.outlet, tp2.outlet)
    let (mf1, mf2) = (tp1.massFlow.rate, tp2.massFlow.rate)
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
  init(file: TextConfigFile) throws {
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
protocol ThermalProcess: CustomStringConvertible {
  var name: String { get }
  var massFlow: MassFlow { get set }
  var temperature: (inlet: Temperature, outlet: Temperature) { get set }
}

/// A struct representing a heat transfer cycle with properties related to thermal processes.
struct HeatTransferCycle: ThermalProcess {
    // The name of the heat transfer cycle.
    var name: String
    // The mass flow rate in the heat transfer cycle.
    var massFlow: MassFlow
    // The temperature of the heat transfer cycle, consisting of an inlet and outlet temperature.
    var temperature: (inlet: Temperature, outlet: Temperature)
}

// Extension of Cycle struct to provide additional initializers.
extension HeatTransferCycle {
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
extension HeatTransferCycle: Comparable {
  public static func < (lhs: HeatTransferCycle, rhs: HeatTransferCycle) -> Bool {
    lhs.minTemperature < rhs.minTemperature
  }

  public static func == (lhs: HeatTransferCycle, rhs: HeatTransferCycle) -> Bool {
    lhs.minTemperature == rhs.minTemperature
  }
}

// Extension of the ThermalProcess protocol to provide computed properties and helper methods.
extension ThermalProcess {
  /// Computed property to create a Cycle from the current ThermalProcess instance.
  var cycle: HeatTransferCycle {
    HeatTransferCycle(name: name, massFlow: massFlow, temperature: temperature)
  }

  /// Computed property to calculate the average temperature of the ThermalProcess.
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

  /// Computed property to get the heat content of the ThermalProcess.
  var heat: Double {
    medium.heatContent(temperature.outlet, temperature.inlet)
  }

  /// Custom description for ThermalProcess instances.
  public var description: String {
    "  Mass flow: \(massFlow.rate) kg/s".padding(28)
      + " T in: \(temperature.inlet.celsius) degC".padding(20)
      + " T out: \(temperature.outlet.celsius) degC".padding(20)
  }

  /// Computed property to get the formatted values for the ThermalProcess instance.
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

  /// Perform heat transfer from two ThermalProcess instances and set the inlet temperature accordingly.
  mutating func heatTransfer(from tp1: ThermalProcess, and tp2: ThermalProcess) {
    temperature.inlet = medium.calculateMixedOutletTemperature(from: tp1, and: tp2)
    massFlow = tp1.massFlow + tp2.massFlow
  }
  
  /// Perform heat transfer from another ThermalProcess instance and set the inlet temperature accordingly.
  mutating func heatTransfer(from process: ThermalProcess) {
    temperature.inlet = medium.calculateMixedOutletTemperature(from: self, and: process)
    massFlow += process.massFlow
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

  /// Set the inlet temperature from another outlet.
  mutating func inletTemperature(outlet other: ThermalProcess) {
    temperature.inlet = other.temperature.outlet
  }

  /// Set the inlet temperature from another inlet.
  mutating func inletTemperature(inlet other: ThermalProcess) {
    temperature.inlet = other.temperature.inlet
  }
}

// Extension of the Collection protocol where Element is ThermalProcess, to get an array of formatted values.
extension Collection where Element == ThermalProcess {
  /// Computed property to get an array of formatted values (mass flow rate, inlet temperature, outlet temperature).
  var values: [String] {
    reduce(into: []) { $0.append(contentsOf: $1.formattedValues) }
  }
}
