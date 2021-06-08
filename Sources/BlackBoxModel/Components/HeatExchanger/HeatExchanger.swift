//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import PhysicalQuantities

/// This struct contains the state as well as the functions for mapping the heat exchanger
public struct HeatExchanger: Parameterizable, HeatTransfer {
  
  var name: String = HeatExchanger.parameter.name

  var massFlow: MassFlow = .zero
  
  var temperature: (inlet: Temperature, outlet: Temperature)
   
  var heatOut, heatToTES: Double

  static let capacity = SolarField.parameter.HTF.heatContent(
    HeatExchanger.parameter.temperature.htf.inlet.max,
    HeatExchanger.parameter.temperature.htf.outlet.max)

  /// working conditions of the heat exchanger at start
  static let initialState = HeatExchanger(
    temperature: Simulation.startTemperature,
    heatOut: 0.0, heatToTES: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.hx

  /// power function based on MAN-Turbo and OHL data with pinch point tool
  static func temperatureFactor(
    temperature: Temperature, load: Ratio, max: Temperature) -> Double
  {
    (((0.0007592419869 * (temperature.kelvin / max.kelvin)
      * 666 + 0.4943825893223) * load.quotient ** (0.0001400823882
        * (temperature.kelvin / max.kelvin)
        * 666 - 0.0110227028559)) - 0.000151639).clamped(to: 0...1.1)
        // function is based on 393°C
  }
  
  /// Update HeatExchanger.temperature.outlet
  mutating func callAsFunction(
    load: Ratio,
    designMassFlow: MassFlow,
    storage: Storage) -> Double
  {
    let parameter = HeatExchanger.parameter
    let solarField = SolarField.parameter
    let load = load.quotient
    let htf = solarField.HTF
    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      self.outletTemperature(kelvin:
        parameter.temperature.htf.outlet.max.kelvin
          - (120 - 169 * load + 49 * load ** 2)
      )
      if self.temperature.outlet < parameter.temperature.htf.outlet.min {
        self.setTemperature(outlet: parameter.temperature.htf.outlet.min)
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = self.massFlow.share(of: designMassFlow)

        let factor = HeatExchanger.temperatureFactor(
          temperature: self.temperature.inlet, load: massFlowLoad,
          max: parameter.temperature.htf.inlet.max)

        self.setTemperature(outlet:
           parameter.temperature.htf.outlet.max.adjusted(factor)
        )
      } else {
        let p = parameter
        let temp = parameter.temperature
        switch (p.ToutMassFlow, p.ToutTin, p.ToutTinMassFlow) {
        case let (ToutMassFlow?, ToutTin?, .none):
          let massFlowLoad = self.massFlow.share(of: designMassFlow)

          var factor = ToutMassFlow(massFlowLoad)
          factor *= ToutTin(temperature.inlet)
          factor.clamp(to: 0...1.1) 
          self.temperature.outlet =
            parameter.temperature.htf.outlet.max.adjusted(factor)          
        case let (ToutMassFlow?, .none, .none):
          outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (temperature.inlet.kelvin - temp.htf.inlet.min.kelvin)
            / temp.range.inlet.kelvin)

          let massFlowLoad = massFlow.share(of: designMassFlow)

          var factor = ToutMassFlow(massFlowLoad)
          factor.clamp(to: 0...1.1)
          outletTemperature(kelvin: factor * self.outlet)
        case let (_, _, ToutTinMassFlow?):
          let share = massFlow.share(of: designMassFlow).quotient

          // power function based on MAN-Turbo and OHL data with pinch point tool
          var factor = ((ToutTinMassFlow[0]
              * (self.inlet / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[1]) * share ** (ToutTinMassFlow[2]
              * (self.inlet / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]
          factor.clamp(to: 0...1.1)
          self.setTemperature(outlet: temp.htf.outlet.max.adjusted(factor))
        case let (_, ToutTin?, _):
          var factor = ToutTin(temperature.inlet)
          factor.clamp(to: 0...1.1)
          self.setTemperature(outlet: temp.htf.outlet.max.adjusted(factor))
        default:
// CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB self
          self.outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (self.inlet - temp.htf.inlet.min.kelvin)
            / temp.range.inlet.kelvin)
        }
      }
    }

    // Update HeatExchanger.temperature.outlet and massFlow
    if case .discharge = storage.operationMode,
      outlet < (261 - Temperature.absoluteZeroCelsius) {
      // added to simulate a bypass on the PB-self if the expected
      // outlet temperture is so low that the salt to TES could freeze
      let totalMassFlow = massFlow
      for i in 1...100 where heatToTES <= h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        massFlow.rate = totalMassFlow.rate * (1 - (Double(i) / 20))
        let load = massFlow.share(of: designMassFlow)

        if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let factor = HeatExchanger.temperatureFactor(
            temperature: temperature.inlet, load: load,
            max: parameter.temperature.htf.inlet.max
          )
          if factor > 0 {
            self.temperature.outlet =
              parameter.temperature.htf.outlet.max.adjusted(factor)            
          }
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin {

          var factor = ToutMassFlow(load)
          factor *= ToutTin(temperature.inlet)
          factor.clamp(to: 0...1.1)
          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        } else if let ToutMassFlow = parameter.ToutMassFlow {
          // if Tout is dependant on massflow, recalculate Tout
          let factor = ToutMassFlow(load).clamped(to: 0...1.1)

          temperature.outlet.adjust(withFactor: factor)
        } else if let c = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          var factor = ((c[0] * inlet + c[1])
            * load.quotient ** (c[2] * inlet + c[3])) + c[4]
          factor.clamp(to: 0...1.1)
          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        }
        heatOut = htf.enthalpy(temperature.outlet)
        let bypassMassFlow = totalMassFlow - massFlow
        let bypass_h = htf.enthalpy(temperature.inlet)
        heatToTES = (
          bypassMassFlow.rate * bypass_h 
          + massFlow.rate * heatOut)
          / (bypassMassFlow + massFlow).rate
      }
      temperature.outlet = htf.temperature(heatToTES)
    }
    let heatFlowRate = massFlow.rate * heat / 1_000
    return -heatFlowRate * parameter.efficiency
  }
  /// Calculates the outlet temperature of the power block
  static var temperatureOutlet = outletTemperatureFunction()
  
  private static func outletTemperatureFunction()
    -> (PowerBlock, HeatTransfer) -> Temperature
  {
    if parameter.useAndsolFunction {
      return {
        (pb: PowerBlock, _: HeatTransfer) -> Temperature in
        let load = pb.massFlow.share(of: pb.designMassFlow)
        let factor = temperatureFactor(
          temperature: pb.temperature.inlet, load: load,
          max: parameter.temperature.htf.inlet.max)
        
        return parameter.temperature.htf.outlet.max
          .adjusted(factor)
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      parameter.Tout_f_Tin == false,
      let ToutMassFlow = parameter.ToutMassFlow
    {
      return {
        (pb: PowerBlock, _: HeatTransfer) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: pb.designMassFlow)
        
        let factor = ToutMassFlow(massFlowLoad)
        
        let temp = parameter.temperature

        return Temperature(
          (temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (pb.inlet - temp.htf.inlet.min.kelvin)
            / temp.range.inlet.kelvin) * factor
        )
      }
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin
    {
      return {
        (pb: PowerBlock, hx: HeatTransfer) -> Temperature in
        let load = pb.massFlow.share(of: pb.designMassFlow)
        var factor = ToutMassFlow(load)
        factor *= ToutTin(hx.temperature.inlet)
        factor.clamp(to: 0...1.1)
        return parameter.temperature.htf.outlet.max.adjusted(factor)
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      let c = parameter.ToutTinMassFlow
    {
      return {
        (pb: PowerBlock, _: HeatTransfer) -> Temperature in
        let share = pb.massFlow.share(of: pb.designMassFlow).quotient
        let max = parameter.temperature.htf.inlet.max.kelvin
        var factor = ((c[0] * (pb.inlet / max) * 666 + c[1])
          * share ** (c[2] * (pb.inlet / max) * 666 + c[3])) + c[4]
        factor.clamp(to: 0...1.1)
        return parameter.temperature.htf.outlet.max.adjusted(factor)
      }
    } else if let ToutTin = parameter.ToutTin {
      return { (_: PowerBlock, hx: HeatTransfer) -> Temperature in
        let factor = Ratio(ToutTin(hx.temperature.inlet))        
        return parameter.temperature.htf.outlet.max.adjusted(factor)
      }
    }
    return {
      (pb: PowerBlock, _: HeatTransfer) -> Temperature in
      let temp = parameter.temperature
      return Temperature(
        temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
          * (pb.inlet - temp.htf.inlet.min.kelvin)
          / temp.range.inlet.kelvin
      )
    }
  }
}
