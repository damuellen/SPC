//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Meteo
import Utilities

/// A collection of static properties and settings used for simulation.
///
/// The `Simulation` enum defines a set of static properties and configurations
/// that are used for simulation purposes. It includes properties related to
/// initial values, time periods, tariffs, and various tolerances used in the
/// simulation process. The enum is used as a container for these simulation
/// settings to organize and manage them efficiently.
public enum Simulation {
  /// Sets the number of simulation steps per hour.
  ///
  /// The `steps` function allows you to configure the number of simulation steps
  /// per hour, which defines the granularity of the simulation time intervals.
  /// The more steps per hour, the finer the simulation resolution, but it may
  /// also increase computational requirements. The step size influences the
  /// precision of time-dependent calculations during the simulation.
  ///
  /// - Parameter perHour: An integer representing the number of simulation steps
  ///                      to be performed in one hour.
  public static func steps(perHour: Int) {
    time.steps = .init(rawValue: perHour) ?? .hour
  }
  /// A boolean flag indicating whether the simulation is starting or not.
  ///
  /// This property is used to track the start of the simulation and control
  /// certain behaviors based on whether the simulation is in the initial
  /// state or has already started running.
  static var isStart = true

  /// Initial values used in the simulation.
  ///
  /// The `initialValues` property represents the initial values used in the
  /// simulation process. It includes properties such as the initial
  /// temperature of the heat transfer fluid (HTF) in pipes, the temperature
  /// of the HTF in the heat collector element (HCE), and the initial mass
  /// flow rate in the solar field.
  static var startTemperature =
   (Simulation.initialValues.temperatureOfHTFinPipes,
    Simulation.initialValues.temperatureOfHTFinPipes)

  static var initialValues = InitValues(
    temperatureOfHTFinPipes: Temperature(celsius: 300.0),
    temperatureOfHTFinHCE: Temperature(celsius: 250.0),
    massFlowInSolarField: 0.0
  )

  /// The tariff plan for energy pricing during the simulation.
  ///
  /// The `tariff` property represents the tariff plan used to determine the
  /// pricing and rates for different energy consumption scenarios during
  /// the simulation. It includes information about various tariff structures
  /// and seasons applicable for different time periods.
  static var tariff = Tariff(name: "", tariff: [], season: [])

  /// Time-related parameters for the simulation.
  ///
  /// The `time` property defines various time-related parameters used in the
  /// simulation. It includes information about leap years, date intervals,
  /// holidays, and time steps used to model the simulation over time.
  static var time = Period(
    isLeapYear: false,
    dateInterval: nil,
    holidays: [],
    steps: .fiveMinutes
  )

  /// Parameters and tolerances used in the simulation.
  ///
  /// The `parameter` property represents various parameters and tolerances
  /// used during the simulation process. It includes values for parameters
  /// such as temperature, mass, insolation, and electrical tolerances,
  /// which are used to control and fine-tune the simulation behavior.
  static var parameter = Simulation.Parameter(
    deltaFreezeTemperaturePump: 151.0,
    deltaFreezeTemperatureHeat: 40.0,
    minTemperatureRaiseStartUp: 1.0,
    tempTolerance: 1.0,
    minInsolationRaiseStartUp: 1.0,
    heatTolerance: 4,
    timeTolerance: 1.0,
    massTolerance: 0.5,
    minInsolation: 150,
    maxToPowerBlock: 0,
    minInsolationForBoiler: 0,
    electricalTolerance: 0.5,
    electricalParasitics: 8.5 / 100,
    heatlossTempTolerance: 0.5,
    adjustmentFactor: adjustmentFactor
  )

  /// Adjustment factors used in the simulation.
  ///
  /// The `adjustmentFactor` property contains various adjustment factors
  /// used to modify and fine-tune the simulation model. These factors
  /// influence the efficiency and heat loss parameters of the simulation
  /// components, allowing for realistic and adjustable simulation results.
  static var adjustmentFactor = Simulation.AdjustmentFactors(
    efficiencySolarField: 1.0,
    efficiencyTurbine: 1.0,
    efficiencyHeater: 1.0,
    efficiencyBoiler: 1.0,
    heatLossHCE: 1.0, heatLossHTF: 1.0, heatLossH2O: 1.0,
    electricalParasitics: 1.0
  )
}

/// A data structure representing initial values used in the simulation.
///
/// The `InitValues` struct defines the initial values for the simulation
/// process. It includes properties representing the initial temperature of
/// the heat transfer fluid (HTF) in pipes, the temperature of the HTF in the
/// heat collector element (HCE), and the initial mass flow rate in the solar
/// field.
struct InitValues: Codable {
  let temperatureOfHTFinPipes,
    temperatureOfHTFinHCE: Temperature
  let massFlowInSolarField: MassFlow
   
}

extension InitValues {
  /// Initializes an `InitValues` instance from a text configuration file.
  ///
  /// - Parameter file: The `TextConfigFile` containing the data to initialize
  ///   the `InitValues` instance.
  /// - Throws: An error if there is an issue reading or parsing the data
  ///   from the text configuration file.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self.temperatureOfHTFinPipes = try Temperature(celsius: ln(7))
    self.temperatureOfHTFinHCE = try Temperature(celsius: ln(10))
    self.massFlowInSolarField = try MassFlow(ln(13))
  }
}

extension InitValues: CustomStringConvertible {
  /// A textual representation of the `InitValues` instance.
  ///
  /// This property provides a custom textual representation of the
  /// `InitValues` instance, presenting the initial temperatures and mass
  /// flow rate as a formatted string with their respective descriptions.
  public var description: String {
    "HTF Temperature in Header [°C]:"
    * String(format: "%.1f", temperatureOfHTFinPipes.celsius)
    + "HTF Temperature in Collector [°C]:"
    * String(format: "%.1f", temperatureOfHTFinHCE.celsius)
    + "Mass Flow in Solar Field [kg/s]:"
    * String(format: "%.1f", massFlowInSolarField.rate)
  }
}