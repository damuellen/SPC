// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Utilities

extension Storage {
  
  private static var sumMinute = 0
  private static var oldMinute = 0
   /// Calculates the parasitics of the TES (Thermal Energy Storage).
  static func parasitics(_ status: Storage) -> Power {
    // Initialize the parasitics variable to 0.0
    var parasitics = 0.0
    
    let solarField = SolarField.parameter
    
    let heatExchanger = HeatExchanger.parameter
        
    let time = DateTime.current
    
    if parameter.auxConsumptionCurve == false {
      // This section calculates parasitics for the old model.
      // Ensure the temperature is above 50 degrees Celsius; otherwise, trigger an assertion.
      assert(status.average.celsius > 50, "Temperature too low.")
      // Calculate density of the htf based on the average temperature of the TES.
      let rohMean = solarField.HTF.density(status.average)
      // Calculate average temperature for the heat exchanger using the maximum inlet and outlet temperatures.
      let avgTempHX = Temperature.average(
        heatExchanger.temperature.htf.inlet.max,
        heatExchanger.temperature.htf.outlet.max
      )

      let rohDP = solarField.HTF.density(avgTempHX)
      let massFlowDP = SolarField.parameter.maxMassFlow
      let pressureLoss = parameter.pressureLoss * rohDP / rohMean
        * status.massFlow.share(of: massFlowDP).quotient ** 2
      
      parasitics = pressureLoss * status.massFlow.rate / rohMean
        / parameter.pumpEfficiency / 10e6

      // Check the operation mode of the TES.
      if case .discharge = status.operationMode {
        // added as user input, by no input stoc.dischargeParasitcsFactor = 2
        parasitics = parasitics * parameter.dischargeParasitcsFactor
        sumMinute = 0
        
      } else if case .noOperation = status.operationMode {
        // Check if the minute has changed compared to the previous time.
        if time.minute != oldMinute { // formula changed
          if time.minute == 0 { // new hour
            sumMinute += 60 + time.minute - oldMinute
            // timeminutessum + 5
          } else {
            sumMinute += time.minute - oldMinute
          }
        }
        // Calculate parasitics based on heat tracing time and power for the given sumMinute.
        let ht = zip(parameter.heatTracingTime, parameter.heatTracingPower)
        for (time, power) in ht {
          if Double(sumMinute) > time * 60 {
            parasitics += power / 1_000 // Divide power by 1000 to convert it to MW (MegaWatts).
          }
        }
      } else {
        // parasitics = parasitics // Indien 1.5
        sumMinute = 0
      }
      oldMinute = time.minute
      return Power(megaWatt: parasitics)
    } else { 
      // This section is for the new model.
      // all this shall be done only one time
      // definedBy internal parameters
      /// exponent for nth order decay of aux power consumption
      let expn = 3.0
      /// accounting for different head for certain charge levels
      /// (e.g. charge mode 0% level -> 35 % less Aux. Power)
      let level = 0.35
      /// Aux. Power for low charge level and low flow ->20% less
      let level2 = 0.2
      /// min aux. power consumption for very low salt flows in charge mode
      let lowCh = 0.12
      /// min aux. power consumption for very low salt flows in discharge mode
      let lowDc = 0.25
      /// TES parasitics for design case during discharge
      let designAuxEX = 0.29
      /// TES parasitics for design case during charge
      let designAuxIN = 0.57
      
      if case .noOperation = status.operationMode {
        parasitics = 0
        
        if time.minute != oldMinute {
          if time.minute == 0 { // new hour
            sumMinute += 60 + time.minute - oldMinute // timeminutessum + 5
          } else {
            sumMinute += time.minute - oldMinute
          }
        }
        
        let ht = zip(parameter.heatTracingTime, parameter.heatTracingPower)
        for (time, power) in ht {
          if sumMinute > Int(time * 60) {
            parasitics += power / 1_000
          }
        }
        return Power(megaWatt: parasitics)
      }
      
      let specificHeat = parameter.HTF.properties.specificHeat
      let tank = parameter.designTemperature
      // calculate design salt massflows:
      let cold = specificHeat(tank.cold)
      let hot = specificHeat(tank.hot)
      let htf = SolarField.parameter.HTF
      let t = Simulation.time.steps.fraction
      let designMassFlow = MassFlow(
        (1 - Storage.parameter.massFlowShare.quotient)
          * SolarField.parameter.maxMassFlow.rate
      )
      if case .discharge = status.operationMode {
        let load = parameter.fixedDischargeLoad.isZero
          ? 0.97 : parameter.fixedDischargeLoad.quotient

        let designDischarge = (((
          (solarField.maxMassFlow - designMassFlow).rate * load)
          / parameter.heatExchangerEfficiency) * htf.heatContent(
            parameter.designTemperature.hot - status.dT_HTFsalt.hot,
            parameter.designTemperature.cold - status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency // design charging power
        
        let massFlowDischarging = designDischarge / (hot - cold) * t * 1_000
        
        let saltFlowRatio = status.salt.active.kg / massFlowDischarging
        
        parasitics = ((1 - lowDc) * designAuxEX
          * saltFlowRatio ** expn + lowDc * designAuxEX)
          * ((1 - level) + level * status.relativeCharge.quotient)
          * ((1 - level2) + level2 * saltFlowRatio)
        
      } else if case .charge = status.operationMode {
        let designCharge = (designMassFlow.rate * htf.heatContent(
          parameter.designTemperature.hot + status.dT_HTFsalt.hot,
          parameter.designTemperature.cold + status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency
        
        let massFlowCharging = designCharge / (hot - cold) * t * 1_000
        
        let saltFlowRatio = status.salt.active.kg / massFlowCharging
        
        parasitics = ((1 - lowCh) * designAuxIN
          * saltFlowRatio ** expn + lowCh * designAuxIN)
          * ((1 - level) + level * status.relativeCharge.quotient)
          * ((1 - level2) + level2 * saltFlowRatio)
      }
      
      sumMinute = 0
      
      oldMinute = time.minute
      return Power(megaWatt: parasitics)
    }
  }
  
  fileprivate func storedHeat() -> Double{
    let parameter = Storage.parameter    
    let steamTurbine = SteamTurbine.parameter
    let storedHeat: Double
    switch parameter.definedBy {
    case .hours:
      storedHeat = relativeCharge.quotient
        * Design.layout.storageHours * steamTurbine.power.max
        / steamTurbine.efficiencyNominal
    case .cap:
      storedHeat = relativeCharge.quotient * Design.layout.storageCapacity
    case .ton:
      storedHeat = defindedByTonnage()
    }
    return storedHeat
  }

  fileprivate func defindedByTonnage() -> Double {
    let salt = Storage.parameter.HTF.properties
    let t = Storage.parameter.designTemperature
    let cold = salt.specificHeat(t.cold)    
    let hot = salt.specificHeat(t.hot)
    let dT = (t.hot - t.cold).kelvin
    
    return relativeCharge.quotient
      * Design.layout.storageTonnage * (hot - cold) * dT / 3_600
  }
  
  // calculate discharge rate only once per day, directly after sunset   
  mutating func dischargeLoad(_ nightHour: Double) -> Ratio {
    let parameter = Storage.parameter    
    let steamTurbine = SteamTurbine.parameter
    var dischargeLoad = parameter.fixedDischargeLoad
    if dischargeLoad.isZero && parameter.isVariable
    {
      let load = storedHeat() / nightHour
        / (steamTurbine.power.max / steamTurbine.efficiencyNominal)
      dischargeLoad = load > 1.0 ? 1.0 : Ratio(load)
    }
    dischargeLoad = max(dischargeLoad, parameter.minDischargeLoad)
    return dischargeLoad
  }
  
  static func isFossilChargingAllowed(at time: DateTime) -> Bool {
    let set = parameter.fossilChargingTime
    return time.isWithin(start: (set[2], set[3]), stop: (set[0], set[1]))
        || time.isWithin(start: (set[6], set[7]), stop: (set[4], set[5]))
  }
}

extension Storage {
  init(operationMode: Storage.OperationMode,
       temperature: (inlet: Temperature, outlet: Temperature),
       temperatureTanks: (cold: Temperature, hot: Temperature)
  ) {
    self.relativeCharge = salt.total.kg.isZero
      ? Ratio(0)
      : Ratio(salt.hot.kg / salt.total.kg)
    self.temperature = temperature
    self.operationMode = operationMode
    self.temperatureTank =
      .init(cold: temperatureTanks.cold, hot: temperatureTanks.hot)
    
    let storage = Storage.parameter
    let solarField = SolarField.parameter
/*
    SolarField.parameter.massFlow.min = MassFlow(
      SolarField.parameter.massFlow.min.rate / 100 * SolarField.parameter.massFlow.rate
    )
  
    SolarField.parameter.antiFreezeFlow = MassFlow(
      SolarField.parameter.antiFreezeFlow.rate / 100 * SolarField.parameter.massFlow.rate
    )
    */
    if solarField.pumpParastics.isEmpty {
      let layout = Design.layout.solarField
      let maxFlow = solarField.maxMassFlow.rate
      if maxFlow < 900 {
        // calculation of solar field parasitics with empirical correlation
        // derived from solar field model
        SolarField.parameter.pumpParasticsFullLoad =
          (4.7327e-08 * layout ** 4 - 2.0044e-05 * layout ** 3
            + 0.0032862 * layout ** 2 - 0.24086 * layout + 8.2152)
          * (0.7103 * (maxFlow / 597) ** 3 - 0.8236 * (maxFlow / 597) ** 2
            + 1.464 * (maxFlow / 597) - 0.3508)
      } else {
        SolarField.parameter.pumpParasticsFullLoad =
          (5.5e-06 * maxFlow ** 2 - 0.0074 * maxFlow + 4.4)
          * (-1.656e-06 * layout ** 3 + 0.0007981 * layout ** 2
            - 0.1322 * layout + 8.428)
      }
      SolarField.parameter.HTFmass = (93300 + 11328 * layout)
        * (0.63 * (maxFlow / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // heatExchanger.temperature.htf.inlet.max = heatExchanger.HTFinTmax
    // heatExchanger.temperature.htf.inlet.min = heatExchanger.HTFinTmin
    // heatExchanger.temperature.htf.outlet.max = heatExchanger.HTFoutTmax
    // HeatExchanger.storage.HTFoutTmin = heatExchanger.HTFoutTmin never used
    self.dT_HTFsalt.cold = 7.0
    self.dT_HTFsalt.hot = 7.0

    if storage.stepSizeIteration == -99.99 {
      // FIXME
      HeatExchanger.parameter.temperature.h2o.inlet.max = storage.startTemperature.hot
      HeatExchanger.parameter.temperature.h2o.inlet.min = storage.startTemperature.cold

      if storage.temperatureCharge[1] == 0 {
      /* status.tempertureOffset.hot = Temperature(celsius: storage.temperatureCharge[0])
         status.tempertureOffset.cold = Temperature(celsius: storage.temperatureCharge[0])
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.hot.kelvin
         - storage.temperatureCharge.coefficients[0]
         // meaning is HTFTout(EX) = HotTankDes - dT
         storage.temperatureDischarge.coefficients[0] = storage.temperatureCharge.coefficients[0]
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.cold.kelvin
         - storage.temperatureCharge.coefficients[0]
         // meaning is HTFTout(IN) = ColdTankDes + dT
         storage.temperatureCharge.coefficients[0] = storage.temperatureCharge[0]*/
      }
    }
  }
}

extension HeatTransferFluid {
  func specificHeat(_ temperature: Temperature) -> Double {
    let c = heatCapacity
    let t = temperature.celsius
    let cp = c[0] * t + 0.5 * c[1] * t ** 2 - 350.5536
    return cp
  }
}

extension Storage: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(20)
    + relativeCharge.multiBar + "\n\n"
    + String(format: "  Mass flow: %3.1f kg/s", massFlow.rate).padding(28) 
    + String(format: " T in: %3.1f degC", temperature.inlet.celsius).padding(20) 
    + String(format: "T out: %3.1f degC", temperature.outlet.celsius).padding(20) 
    + "," + "  Temperature tanks".padding(28)
    + String(format: " cold: %3.1f degC", temperatureTank.cold.celsius).padding(20)
    + String(format: "  hot: %3.1f degC", temperatureTank.hot.celsius).padding(20)
    + "," + "  Salt mass".padding(28)
    + String(format: " cold: %3.0f t", salt.cold.kg / 1000).padding(20)
    + String(format: "  hot: %3.0f t", salt.hot.kg / 1000 ).padding(20)
    + ","
    + String(format: "  total: %3.0f t", salt.total.kg / 1000).padding(27)
    + String(format: "  active: %3.0f t", salt.active.kg / 1000).padding(21)
    + String(format: "  min: %3.0f t", salt.minimum.kg / 1000) .padding(20)
  }
}

extension Storage: MeasurementsConvertible {
  static var measurements: [(name: String, unit: String)] {
    [
      ("Storage|TankCold", "degC"), ("Storage|TankHot", "degC"),
      ("Storage|Charge", "percent")
    ]
  }

  var values: [Double] {
    [temperatureTank.cold.celsius, temperatureTank.hot.celsius, relativeCharge.percentage]
  }
}