// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Libc
import Utilities

extension Storage.Salt: MeasurementsConvertible {
  static var measurements: [(name: String, unit: String)] {
    [
      ("Storage|MassCold", "kg"), ("Storage|MassHot", "kg"),
      ("Storage|Mass", "kg")
    ]
  }

  var values: [Double] {
    [cold.kg, hot.kg, active.kg]
  }
}

extension Storage {

  /// A struct representing the salt storage inside the main `Storage` struct.
  struct Salt { 
    /// The active mass of salt in the storage (being charged or discharged).
    var active: Mass = .zero
    /// The minimum mass of salt required for safe operation.
    var minimum: Mass
    /// The mass of cold salt in the storage.
    var cold: Mass
    /// The mass of hot salt in the storage.
    var hot: Mass
    /// The total mass of salt in the storage (cold + hot).
    var total: Mass

    /// Initializes a `Salt` struct with calculated salt masses.
    init() {
      // Extract relevant parameters
      let availability = Availability.current.value.storage.quotient
      let dischargeToTurbine = Storage.parameter.dischargeToTurbine.quotient
      let designTemperature = Storage.parameter.designTemperature
      let salt = Storage.parameter.HTF.properties
      let cold = salt.specificHeat(designTemperature.cold)
      let hot = salt.specificHeat(designTemperature.hot)
      let startLoad = Storage.parameter.startLoad
      // Ensure hot salt has higher specific heat than cold salt
      precondition(hot > cold, "No usable heat content")
      // Ensure startLoad percentages sum to 1.0
      precondition(parameter.startLoad.hot + parameter.startLoad.cold == 1)
      var mass: Double
      switch parameter.definedBy {
      case .hours:
        let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
        mass = Design.layout.storageHours * heatFlowRate * 3_600 / (hot - cold)
      case .cap:
        mass = Design.layout.storageCapacity * dischargeToTurbine * 3_600 / (hot - cold)
      case .ton:
        mass = Design.layout.storageTonnage * dischargeToTurbine
      }
      // Check if salt mass is specified for systems with storage
      if Design.hasStorage { precondition(mass > .zero, "Salt mass not specified") }

      mass *= availability
      // Calculate salt masses based on startLoad and dischargeToTurbine percentages
      self.minimum = Mass(ton: dischargeToTurbine * mass)
      self.hot = Mass(ton: (startLoad.hot + dischargeToTurbine) * mass)
      self.cold = Mass(ton: (startLoad.cold + dischargeToTurbine) * mass)
      self.total = Mass(ton: (1 + dischargeToTurbine) * mass)

      // Ensure that the sum of minimum and total masses matches the sum of cold and hot masses
      assert(self.minimum.kg + self.total.kg == self.cold.kg + self.hot.kg)
    }
  }

  /// Calculates the mass of salt needed to obtain the specified thermal output and temperature difference.
  ///
  /// - Parameters:
  ///   - cold: The inlet temperature of the salt.
  ///   - hot: The outlet temperature of the salt.
  ///   - thermal: The thermal output in kW.
  /// - Returns: A tuple containing the mass of salt and the temperature difference (hot - cold).
  fileprivate mutating func calculateMass(
    cold: Temperature, hot: Temperature, thermal: Double
  ) -> (mass: Mass, delta: Double) {
    let salt = Storage.parameter.HTF.properties
    let cold = salt.specificHeat(cold)
    let hot = salt.specificHeat(hot)
    let fraction = Simulation.time.steps.fraction
    // assert(hot > cold, "No usable heat content")
    let mass = Mass(thermal / (hot - cold) * fraction * 3_600)
    return (mass, hot - cold)
  }

  /// Calculates the thermal output if the salt minimum was undershot and updates the active salt mass.
  mutating func recalculate(_ thermal: inout Power) {
    var m: Mass = .zero
    var heat = 0.0
    if case .discharge = operationMode {
      (salt.active, heat) = calculateMass(
        cold: temperature.inlet + dT_HTFsalt.cold,
        hot: temperatureTank.hot,
        thermal: thermal.megaWatt
      )
      m = salt.hot
    }

    if case .charge = operationMode {
      (salt.active, heat) = calculateMass(
        cold: temperatureTank.cold,
        hot: temperature.inlet - dT_HTFsalt.hot,
        thermal: thermal.megaWatt
      )
      m = salt.cold
    }

    if (m - salt.active) < salt.minimum {
      salt.active.kg -= -salt.minimum.kg + salt.cold.kg
      if salt.active < 10.0 { salt.active = .zero }      
      thermal.kiloWatt =
        (salt.active.kg * heat / Simulation.time.steps.fraction / 3_600)
    }
  }

  /// Perform indirect charging for the storage system.
  ///
  /// This function calculates the state of the storage system after indirect charging.
  ///
  /// - Parameter thermal: The thermal power for charging the storage system.
  private mutating func indirectCharging(thermal: Double) {
    // Calculate the mass flow and update the salt temperature.
    (salt.active, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: temperature.inlet - dT_HTFsalt.hot,
      thermal: thermal
    )
    let cold = salt.cold
    salt.cold -= salt.active

    // Check for negative or too low mass to avoid heat losses.
    if salt.cold < salt.minimum {
      salt.active -= salt.minimum - salt.cold
      salt.cold = salt.minimum
    }

    // If the active mass is too low, reset the charging process.
    if salt.active < 100.0 {
      salt.active = .zero
      salt.cold = cold
      relativeCharge = Storage.parameter.chargeTo
    } else {
      salt.hot += salt.active
      relativeCharge = Ratio(salt.hot.kg / salt.total.kg)
    }

    // Calculate the outlet temperature of the hot tank.
    temperatureTank.hot = Temperature.mixture(
      m1: salt.active, m2: salt.hot,
      t1: temperature.inlet - dT_HTFsalt.hot,
      t2: temperatureTank.hot
    )
  }

  /// Perform direct charging for the storage system.
  ///
  /// This function calculates the state of the storage system after direct charging.
  ///
  /// - Parameter thermal: The thermal power for charging the storage system.
  func directCharging(thermal: Double) {
    // TODO: Implement direct charging logic here.
  }

  /// Perform fossil charging for the storage system.
  ///
  /// This function calculates the state of the storage system after fossil charging.
  ///
  /// - Parameter thermal: The thermal power for charging the storage system.
  private mutating func fossilCharging(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    // Calculate the mass flow and update the salt temperature.
    (salt.active, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: designT.hot,
      thermal: thermal
    )
    salt.cold -= salt.active
    salt.hot += salt.active

    // Calculate the relative charge based on the mass in the hot tank.
    relativeCharge = Ratio(salt.hot.kg / (salt.total.kg))

    // Calculate the outlet temperature of the hot tank.
    temperatureTank.hot = Temperature.mixture(
      m1: salt.active, m2: salt.hot,
      t1: designT.hot, t2: temperatureTank.hot
    )
  }

  /// Perform indirect discharging for the storage system.
  ///
  /// This function calculates the state of the storage system after indirect discharging.
  ///
  /// - Parameter thermal: The thermal power for discharging the storage system.
  /// - Returns: The remaining thermal power after discharging.
  private mutating func indirectDischarging(thermal: Double) -> Double {
    var thermalPower = thermal
    let heat: Double

    // Calculate the mass flow and heat for discharging.
    (salt.active, heat) = calculateMass(
      cold: temperature.inlet + dT_HTFsalt.cold,
      hot: temperatureTank.hot,
      thermal: -thermalPower
    )

    salt.active.kg = abs(salt.active.kg)
    let hot = salt.hot
    salt.hot -= salt.active

    // Check if the mass in the hot tank is too low.
    if salt.hot < salt.minimum {
      salt.active -= salt.minimum - salt.hot
      salt.hot = salt.minimum
      // If the active mass is too low, reset the discharging process.
      if salt.active < 100.0 {
        salt.active = .zero
        salt.hot = hot
      }
      // Recalculate the thermal power based on the remaining mass.
      thermalPower = salt.active.kg * heat / Simulation.time.steps.fraction / 3_600 / 1_000

      salt.cold += salt.active
      relativeCharge = Storage.parameter.dischargeToTurbine
    } else {
      salt.cold += salt.active
      // Calculate the relative charge based on the mass in the hot tank.
      relativeCharge = Ratio(salt.hot.kg  / salt.total.kg)
    }

    // Calculate the outlet temperature of the cold tank.
    temperatureTank.cold = Temperature.mixture(
      m1: salt.active, m2: salt.cold,
      t1: temperature.inlet + dT_HTFsalt.cold,
      t2: temperatureTank.cold
    )

    return thermalPower
  }

  /// Perform direct discharging for the storage system.
  ///
  /// This function calculates the state of the storage system after direct discharging.
  ///
  /// - Parameter thermal: The thermal power for discharging the storage system.
  /// - Returns: The remaining thermal power after discharging. (Always returns 0 as direct discharging is not implemented)
  private mutating func directDischarging(thermal: Double) -> Double {
    // TODO: Implement direct discharging logic here.
    return 0
  }

  /// Perform preheating for the storage system.
  ///
  /// This function calculates the state of the storage system after preheating.
  ///
  /// - Parameter thermal: The thermal power for preheating the storage system.
  private mutating func preheating(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    
    // Calculate the mass flow and update the salt temperature.
    (salt.active, _) = calculateMass(
      cold: designT.cold,
      hot: temperatureTank.hot,
      thermal: thermal
    )

    salt.cold += salt.active
    salt.hot -= salt.active

    // Calculate the relative charge based on the mass in the hot tank.
    relativeCharge = Ratio(salt.hot.kg / salt.total.kg)

    // Calculate the outlet temperature of the cold tank.
    temperatureTank.cold = Temperature.mixture(
      m1: salt.active, m2: salt.cold,
      t1: designT.cold, t2: temperatureTank.cold
    )
  }

  /// Perform freeze protection for the storage system.
  ///
  /// This function adjusts the storage system for freeze protection.
  ///
  /// - Parameter powerBlock: The power block in the system.
  private mutating func freezeProtection(powerBlock: PowerBlock) {
    let splitfactor = Storage.parameter.HTF == .hiXL ? 0.4 : 1

    let antiFreeze = SolarField.parameter.antiFreezeFlow.quotient
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let antiFreezeFlow = antiFreeze * maxMassFlow

    salt.active.kg = antiFreezeFlow * Simulation.time.steps.interval

    let m = salt.active * splitfactor

    // Calculate the outlet temperature of the cold tank.
    temperatureTank.cold = Temperature.mixture(
      m1: m, m2: salt.cold,
      t1: powerBlock.temperature.outlet,
      t2: temperatureTank.cold
    )

    // Calculate the outlet temperature of the hot tank for freeze protection.
    antiFreezeTemperature = splitfactor * temperatureTank.cold.kelvin
      + (1 - splitfactor) * powerBlock.outlet
  }

  /// Perform no operation for the storage system.
  ///
  /// This function adjusts the storage system for no operation.
  ///
  /// - Parameter powerBlock: The power block in the system.
  private mutating func noOperation(powerBlock: PowerBlock) {
    let parameter = Storage.parameter
    // Check if the conditions are met to start the storage system for no operation.
    if parameter.stepSizeIteration < -90,
      temperatureTank.cold < parameter.designTemperature.cold,
      powerBlock.temperature.outlet > temperatureTank.cold,
      salt.cold > .zero
    {
      // Calculate the mass flow and update the salt temperature.
      salt.active.kg = powerBlock.massFlow.rate * Simulation.time.steps.fraction

      // Calculate the outlet temperature of the cold tank.
      temperatureTank.cold = Temperature.mixture(
        m1: salt.active, m2: salt.cold,
        t1: powerBlock.temperature.outlet,
        t2: temperatureTank.cold
      )
      // Update the operation mode (optional).
      // status.operationMode = .sc
    }
  }

  /// Calculates the operation of the storage system based on the current operation mode.
  ///
  /// - Parameters:
  ///   - output: The thermal power output from the storage system (inout parameter).
  ///   - input: The thermal power input to the storage system.
  ///   - powerBlock: The power block in the system.
  mutating func calculate(output: inout Power, input: Power, powerBlock: PowerBlock) {
    // Check if the salt quantity in the tanks matches the expected value within a tolerance.
    assert(
      (salt.minimum.kg + salt.total.kg) - (salt.cold.kg + salt.hot.kg) < 0.1,
      "Salt quantity in the tanks does not match."
    )
    // Switch based on the current operation mode.
    switch operationMode {
    case .charge:
      // Check the storage type to perform the charging accordingly.
      switch Storage.parameter.type {
      case .indirect:
        // Perform indirect charging with the given input thermal power.
        indirectCharging(thermal: input.kiloWatt)
      case .direct:
        // Perform direct charging with the given input thermal power.
        directCharging(thermal: input.kiloWatt)
      }
    case .fossilCharge:
      // Perform fossil charging with the given input thermal power.
      fossilCharging(thermal: input.kiloWatt)
    case .discharge:
      // Check the storage type to perform the discharging accordingly.
      switch Storage.parameter.type {
      case .indirect:
        // Perform indirect discharging with the given output thermal power.
        return output.kiloWatt = indirectDischarging(thermal: output.kiloWatt)
      case .direct:
        // Perform direct discharging with the given output thermal power.
        return output.kiloWatt = directDischarging(thermal: output.kiloWatt)
      }
    case .preheat:
      // Perform preheating with the given output thermal power.
      preheating(thermal: output.kiloWatt)

    case .freezeProtection:
      // Perform freeze protection with the given power block.
      freezeProtection(powerBlock: powerBlock)
      // Note: There is a commented line that assigns the temperature from the power block to the storage system.
      // However, as this line is commented out, it is currently not affecting the functionality.

    case .noOperation:
      // Perform no operation with the given power block.
      noOperation(powerBlock: powerBlock)
    }
  }

  /// Calculate the tank temperature based on specific heat.
  ///
  /// - Parameter specificHeat: The specific heat of the tank.
  /// - Returns: The calculated tank temperature.
  private func tankTemperature(_ specificHeat: Double) -> Temperature {
    let hcap = Storage.parameter.HTF.properties.heatCapacity
    return Temperature(celsius: (-hcap[0] + (hcap[0] ** 2 - 4 * (hcap[1] * 0.5) * (-350.5536 - specificHeat)) ** 0.5) / (2 * hcap[1] * 0.5))
  }



  /// Calculate heat losses for the storage system over a period of time.
  ///
  /// This function calculates the temperature drop of the tanks due to heat losses.
  ///
  /// - Parameter period: The time period for calculating the heat losses.
  mutating func heatlosses(for period: Double) {
    let parameter = Storage.parameter
    let specificHeat = parameter.HTF.properties.specificHeat
    
    // Check for heat losses in the cold tank.
    if salt.cold.kg > abs(parameter.dischargeToTurbine.quotient * salt.active.kg) {
      // Calculate the enthalpy before cooling down.
      var cold = specificHeat(temperatureTank.cold)

      let coldTankHeatLoss = parameter.heatLoss.cold * (temperatureTank.cold.kelvin) / (parameter.designTemperature.cold.kelvin - 27)
      // Calculate the enthalpy after cooling down.
      cold -= coldTankHeatLoss * period / salt.cold.kg
      // Calculate the temperature after cooling down.
      temperatureTank.cold = tankTemperature(cold)
    }
    // Check for heat losses in the hot tank.
    if salt.hot > 1.0 {
      // Calculate the enthalpy before cooling down.
      var hot = specificHeat(temperatureTank.hot)

      let hotTankHeatLoss = parameter.heatLoss.hot * (temperatureTank.hot.kelvin) / (parameter.designTemperature.hot.kelvin - 27)
      // Calculate the enthalpy after cooling down.
      hot -= hotTankHeatLoss * Double(period) / salt.hot.kg
      // Calculate the temperature after cooling down.
      temperatureTank.hot = tankTemperature(hot)
    }
  }

}
