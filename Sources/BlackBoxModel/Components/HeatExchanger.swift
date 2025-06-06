// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

extension HeatExchanger: CustomStringConvertible {
  /// A textual representation of the HeatExchanger instance.
  public var description: String { "\(self.cycle)" }
}

/// A struct representing the state and functions for the heat exchanger.
struct HeatExchanger: Parameterizable, ThermalProcess {
  /// The name of the heat exchanger.
  private(set) var name: String = HeatExchanger.parameter.name

  /// The mass flow rate of the heat exchanger.
  var massFlow: MassFlow = .zero

  /// The temperatures of the heat exchanger (inlet and outlet).
  var temperature: (inlet: Temperature, outlet: Temperature)

  /// The amount of heat transferred out of the heat exchanger.
  var heatOut, heatToTES: Double

  /// The fixed design mass flow rate of the heat exchanger.
  static let designMassFlow = MassFlow(parameter.heatFlowHTF * 1_000 / capacity)
  
  /// The capacity of the heat exchanger.
  static let capacity = SolarField.parameter.HTF.heatContent(
    HeatExchanger.parameter.temperature.htf.inlet.max,
    HeatExchanger.parameter.temperature.htf.outlet.max)

  /// Returns the fixed initial state of the heat exchanger.
  static let initialState = HeatExchanger(
    temperature: Simulation.startTemperature,
    heatOut: 0.0, heatToTES: 0.0
  )
  
  /// The static parameters for the `HeatExchanger`.
  public static var parameter: Parameter = Parameters.hx

  /// power function based on MAN-Turbo and OHL data with pinch point tool
  static func temperatureFactor(
    temperature: Temperature, load: Ratio, max: Temperature) -> Double
  {
    median((((0.0007592419869 * (temperature.kelvin / max.kelvin)
      * 666 + 0.4943825893223) * (load.quotient ** (0.0001400823882
        * (temperature.kelvin / max.kelvin)
        * 666 - 0.0110227028559))) - 0.000151639), 0, 1.1)
        // function is based on 393°C
  }

/// Update HeatExchanger.temperature.outlet
  mutating func callAsFunction(load: Ratio, storage: Storage) -> Double {
    let loadQuotient = load.quotient
    let htf = SolarField.parameter.HTF
    let designMassFlow = HeatExchanger.designMassFlow

    if HeatExchanger.parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      updateBKOutletTemperature(loadQuotient)
    } else if HeatExchanger.parameter.useAndsolFunction {
      updateOutletWithAndsolFunction(designMassFlow: designMassFlow)
    } else {
      updateOutletWithEmpiricalModel(designMassFlow: designMassFlow)
    }

    handleStorageDischargeIfNeeded(storage, htf: htf, designMassFlow: designMassFlow)

    let heatFlowRate = massFlow.rate * heat / 1_000
    return -heatFlowRate * HeatExchanger.parameter.efficiency
  }

  private mutating func updateBKOutletTemperature(_ load: Double) {
    let kelvinValue =
      HeatExchanger.parameter.temperature.htf.outlet.max.kelvin
      - (120 - 169 * load + 49 * (load ** 2))
    outletTemperature(kelvin: kelvinValue)
    let parameter = HeatExchanger.parameter
    if temperature.outlet < parameter.temperature.htf.outlet.min {
      setTemperature(outlet: parameter.temperature.htf.outlet.min)
    }
  }

  private mutating func updateOutletWithAndsolFunction(designMassFlow: MassFlow) {
    let parameter = HeatExchanger.parameter
    let massFlowLoad = massFlow.share(of: designMassFlow)
    let factor = HeatExchanger.temperatureFactor(
      temperature: temperature.inlet, load: massFlowLoad,
      max: parameter.temperature.htf.inlet.max)
    setTemperature(outlet: parameter.temperature.htf.outlet.max.adjusted(factor))
  }

  private mutating func updateOutletWithEmpiricalModel(designMassFlow: MassFlow) {
    let parameter = HeatExchanger.parameter
    let temp = parameter.temperature
    let inletKelvin = temperature.inlet.kelvin

    switch (
      parameter.ToutMassFlow, parameter.ToutTin, parameter.ToutTinMassFlow
    ) {
    case let (ToutMassFlow?, ToutTin?, .none):
      var factor = ToutMassFlow(massFlow.share(of: designMassFlow))
      factor *= ToutTin(temperature.inlet)
      factor.clamp(to: 0...1.1)
      temperature.outlet = temp.htf.outlet.max.adjusted(factor)

    case let (ToutMassFlow?, .none, .none):
      let outlet = Temperature(
        temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
        * (inletKelvin - temp.htf.inlet.min.kelvin) / temp.range.inlet.kelvin)

      var factor = ToutMassFlow(massFlow.share(of: designMassFlow))
      factor.clamp(to: 0...1.1)
      setTemperature(outlet: outlet.adjusted(factor))

    case let (_, _, ToutTinMassFlow?):
      let share = massFlow.share(of: designMassFlow).quotient
      let inletRatio = inlet / temp.htf.inlet.max.kelvin
      var factor =
        ((ToutTinMassFlow[0] * inletRatio * 666 + ToutTinMassFlow[1])
          * (share
            ** (ToutTinMassFlow[2] * inletRatio * 666 + ToutTinMassFlow[3])))
        + ToutTinMassFlow[4]
      factor.clamp(to: 0...1.1)
      setTemperature(outlet: temp.htf.outlet.max.adjusted(factor))

    case let (_, ToutTin?, _):
      var factor = ToutTin(temperature.inlet)
      factor.clamp(to: 0...1.1)
      setTemperature(outlet: temp.htf.outlet.max.adjusted(factor))

    default:
      let outlet = Temperature(
        temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
        * (inlet - temp.htf.inlet.min.kelvin) / temp.range.inlet.kelvin)
      setTemperature(outlet: outlet)
    }
  }

  private mutating func handleStorageDischargeIfNeeded(
    _ storage: Storage, htf: HeatTransferFluid, designMassFlow: MassFlow
  ) {
    guard case .discharge = storage.operationMode,
      outlet < (261 - Temperature.absoluteZeroCelsius)
    else {
      heatOut = htf.enthalpy(temperature.outlet)
      return
    }
    let parameter = HeatExchanger.parameter
    let totalMassFlow = massFlow

    for i in 1...100 where heatToTES <= h_261 {
      massFlow.rate = totalMassFlow.rate * (1 - Double(i) / 20)
      let load = massFlow.share(of: designMassFlow)

      var factor: Double = 0

      if parameter.useAndsolFunction {
        factor = HeatExchanger.temperatureFactor(
          temperature: temperature.inlet, load: load,
          max: parameter.temperature.htf.inlet.max)
        if factor > 0 {
          temperature.outlet = parameter.temperature.htf.outlet.max.adjusted(
            factor)
        }
      } else if let ToutMassFlow = parameter.ToutMassFlow,
        let ToutTin = parameter.ToutTin
      {
        factor = ToutMassFlow(load) * ToutTin(temperature.inlet)
      } else if let ToutMassFlow = parameter.ToutMassFlow {
        factor = median(ToutMassFlow(load), 0, 1.1)
      } else if let c = parameter.ToutTinMassFlow {
        factor = ((c[0] * inlet + c[1]) * (load.quotient ** (c[2] * inlet + c[3]))) + c[4]
      }

      factor.clamp(to: 0...1.1)
      setTemperature(outlet: parameter.temperature.htf.outlet.max.adjusted(factor))

      heatOut = htf.enthalpy(temperature.outlet)
      let bypassMassFlow = totalMassFlow - massFlow
      let bypass_h = htf.enthalpy(temperature.inlet)

      heatToTES =
        (bypassMassFlow.rate * bypass_h + massFlow.rate * heatOut)
        / (bypassMassFlow + massFlow).rate
    }

    temperature.outlet = htf.temperature(heatToTES)
  }

  /// Calculates the outlet temperature of the power block
  static func temperatureOutlet(_ pb: PowerBlock, _ hx: ThermalProcess)
    -> Temperature
  {
    if parameter.useAndsolFunction {
      return outletTemperatureAndsol(pb: pb)
    } else if parameter.Tout_exp_Tin_Mfl, parameter.Tout_f_Tin == false {
      return outletTemperatureToutMassFlowOnly(pb: pb)
    } else if parameter.Tout_f_Mfl, parameter.Tout_f_Tin {
      return outletTemperatureToutMassFlowAndTin(pb: pb, hx: hx)
    } else if parameter.Tout_exp_Tin_Mfl {
      return outletTemperatureToutTinMassFlow(pb: pb)
    } else if let _ = parameter.ToutTin {
      return outletTemperatureToutTinOnly(pb, hx: hx)
    } else {
      return outletTemperatureDefault(pb: pb)
    }
  }

  private static func outletTemperatureAndsol(pb: PowerBlock) -> Temperature {
    let load = pb.massFlow.share(of: designMassFlow)
    let factor = temperatureFactor(
      temperature: pb.temperature.inlet, load: load,
      max: parameter.temperature.htf.inlet.max)
    return parameter.temperature.htf.outlet.max.adjusted(factor)
  }

  private static func outletTemperatureToutMassFlowOnly(pb: PowerBlock)
      -> Temperature
  {
    let massFlowLoad = pb.massFlow.share(of: designMassFlow)
    let factor = parameter.ToutMassFlow!(massFlowLoad)
    let temp = parameter.temperature
    return Temperature(
      temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
        * (pb.inlet - temp.htf.inlet.min.kelvin) / temp.range.inlet.kelvin
    ).adjusted(factor)
  }

  private static func outletTemperatureToutMassFlowAndTin(
    pb: PowerBlock, hx: ThermalProcess
  ) -> Temperature {
    let load = pb.massFlow.share(of: designMassFlow)
    var factor = parameter.ToutMassFlow!(load)
    factor *= parameter.ToutTin!(hx.temperature.inlet)
    factor.clamp(to: 0...1.1)
    return parameter.temperature.htf.outlet.max.adjusted(factor)
  }

  private static func outletTemperatureToutTinMassFlow(pb: PowerBlock)
    -> Temperature
  {
    let share = pb.massFlow.share(of: designMassFlow).quotient
    let max = parameter.temperature.htf.inlet.max.kelvin
    let c = parameter.ToutTinMassFlow!
    var factor = ((c[0] * (pb.inlet / max) * 666 + c[1]) 
      * (share ** (c[2] * (pb.inlet / max) * 666 + c[3]))) + c[4]
    factor.clamp(to: 0...1.1)
    return parameter.temperature.htf.outlet.max.adjusted(factor)
  }

  private static func outletTemperatureToutTinOnly(
    _: PowerBlock, hx: ThermalProcess
  ) -> Temperature {
    let factor = Ratio(parameter.ToutTin!(hx.temperature.inlet))
    return parameter.temperature.htf.outlet.max.adjusted(factor)
  }

  private static func outletTemperatureDefault(pb: PowerBlock) -> Temperature {
    let temp = parameter.temperature
    return Temperature(
      temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
        * (pb.inlet - temp.htf.inlet.min.kelvin) / temp.range.inlet.kelvin)
  }
}
