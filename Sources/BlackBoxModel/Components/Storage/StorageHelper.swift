//
//  StorageModes.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

import DateGenerator

extension Storage {
  
  private static var sumMinute = 0
  private static var oldMinute = 0
  /// Calculates the parasitics of the TES
  static func parasitics(_ status: inout Storage) -> Double {
    
    var parasitics = 0.0
    
    let solarField = SolarField.parameter
    
    let heatExchanger = HeatExchanger.parameter
        
    let time = DateTime.current
    
    if parameter.auxConsumptionCurve == false {
      // old model:
      assert(status.averageTemperature.celsius > 50, "Temperature too low.")

      let rohMean = solarField.HTF.density(status.averageTemperature)
      let avgTempHX = Temperature.average(
        heatExchanger.temperature.htf.inlet.max,
        heatExchanger.temperature.htf.outlet.max
      )

      assert(avgTempHX.celsius > 50, "Temperature too low.")

      let rohDP = solarField.HTF.density(avgTempHX)

      let pressureLoss = parameter.pressureLoss * rohDP / rohMean
        * status.massFlow.share(of: parameter.designMassFlow).quotient ** 2
      
      parasitics = pressureLoss * status.massFlow.rate / rohMean
        / parameter.pumpEfficiency / 10e6
      
      if case .discharge = status.operationMode {
        // added as user input, by no input stoc.dischargeParasitcsFactor = 2
        parasitics = parasitics * parameter.dischargeParasitcsFactor
        sumMinute = 0
        
      } else if case .noOperation = status.operationMode {
        
        if time.minute != oldMinute { // formula changed
          if time.minute == 0 { // new hour
            sumMinute += 60 + time.minute - oldMinute
            // timeminutessum + 5
          } else {
            sumMinute += time.minute - oldMinute
          }
        }
        
        let ht = zip(parameter.heatTracingTime, parameter.heatTracingPower)
        for (time, power) in ht {
          if Double(sumMinute) > time * 60 {
            parasitics += power / 1_000
          }
        }
      } else {
        // parasitics = parasitics // Indien 1.5
        sumMinute = 0
      }
      oldMinute = time.minute
      return parasitics
    } else { // new model
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
        return parasitics
      }
      
      let specificHeat = parameter.HTF.properties.specificHeat
      // calculate design salt massflows:
      let cold = specificHeat(parameter.designTemperature.cold)
      let hot = specificHeat(parameter.designTemperature.hot)
      
      if case .discharge = status.operationMode {
        
        let load = parameter.fixedDischargeLoad.isZero
          ? 0.97 : parameter.fixedDischargeLoad.quotient
        
        let htf = SolarField.parameter.HTF
        
        let designDischarge = (((
          (solarField.maxMassFlow - parameter.designMassFlow).rate * load)
          / parameter.heatExchangerEfficiency) * htf.deltaHeat(
            parameter.designTemperature.hot - status.dT_HTFsalt.hot,
            parameter.designTemperature.cold - status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency // design charging power
        
        let massFlowDischarging = designDischarge
          / (hot - cold) * Simulation.time.steps.fraction * 1_000
        
        let saltFlowRatio = status.salt.active.kg
          / massFlowDischarging
        
        parasitics = ((1 - lowDc) * designAuxEX
          * saltFlowRatio ** expn + lowDc * designAuxEX)
          * ((1 - level) + level * status.charge.quotient)
          * ((1 - level2) + level2 * saltFlowRatio)
        
      } else if case .charging = status.operationMode {
        
        let htf = SolarField.parameter.HTF
        
        let designCharge = (parameter.designMassFlow.rate * htf.deltaHeat(
          parameter.designTemperature.hot + status.dT_HTFsalt.hot,
          parameter.designTemperature.cold + status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency
        
        let massFlowCharging = designCharge
          / (hot - cold) * Simulation.time.steps.fraction * 1_000
        
        let saltFlowRatio = status.salt.active.kg
          / massFlowCharging
        
        parasitics = ((1 - lowCh) * designAuxIN
          * saltFlowRatio ** expn + lowCh * designAuxIN)
          * ((1 - level) + level * status.charge.quotient)
          * ((1 - level2) + level2 * saltFlowRatio)
      }
      
      sumMinute = 0
      
      oldMinute = time.minute
      return parasitics
    }
  }
    
  static func defindedByTonnage(_ storage: inout Storage)
  {
    let salt = parameter.HTF.properties
    let cold = salt.specificHeat(
      parameter.designTemperature.cold
    )
    
    let hot = salt.specificHeat(
      parameter.designTemperature.hot
    )

    let t = parameter.designTemperature
    let designDeltaT = (t.hot - t.cold).kelvin
    
    storage.storedHeat = storage.charge.quotient
      * Design.layout.storage_ton * (hot - cold)
      * designDeltaT / 3_600
  }
  
  static func dischargeLoad(
    _ storage: inout Storage,
    _ nightHour: Double) -> Ratio
  {
    // calculate discharge rate only once per day, directly after sunset
    var dischargeLoad = Ratio(0.5)
    
    let steamTurbine = SteamTurbine.parameter
    
    if DateTime.isDaytime && parameter.isVariable
    {
      switch parameter.definedBy {
      case .hours:
        storage.storedHeat = storage.charge.quotient
          * Design.layout.storage * steamTurbine.power.max
          / steamTurbine.efficiencyNominal
      case .cap:
        storage.storedHeat = storage.charge.quotient * Design.layout.storage_cap
      case .ton:
        defindedByTonnage(&storage) // updates storedHeat
      }
      let load = storage.storedHeat / nightHour
        / (steamTurbine.power.max / steamTurbine.efficiencyNominal)
      
      dischargeLoad = load > 1.0 
        ? parameter.fixedDischargeLoad
        : Ratio(load)
    }
    // if no previous calculation has been done and TES must be discharged
    if dischargeLoad.isZero && parameter.isVariable {
      switch parameter.definedBy {
      case .hours:
        storage.storedHeat = storage.charge.quotient
          * Design.layout.storage * steamTurbine.power.max
          / steamTurbine.efficiencyNominal
      case .cap:
        storage.storedHeat = storage.charge.quotient * Design.layout.storage_cap
      case .ton:
        defindedByTonnage(&storage)
      }
      let load = storage.storedHeat / nightHour
        / (steamTurbine.power.max / steamTurbine.efficiencyNominal)
      dischargeLoad = load > 1.0 ? 1.0 : Ratio(load)
    }
    dischargeLoad = max(dischargeLoad, parameter.minDischargeLoad)
    
    return dischargeLoad
  }
  
  static func isFossilChargingAllowed(at time: DateTime) -> Bool {
    return time.isWithin(start: parameter.startFossilCharging,
                         stop: parameter.stopFossilCharging)
        || time.isWithin(start: parameter.startFossilCharging2,
                         stop: parameter.stopFossilCharging2)
  }
}



extension Storage {
  init(operationMode: Storage.OperationMode,
       temperature: (inlet: Temperature, outlet: Temperature),
       temperatureTanks: (cold: Temperature, hot: Temperature)
  ) {
    self.temperature = temperature
    self.operationMode = operationMode
    self.temperatureTank =
      .init(cold: temperatureTanks.cold, hot: temperatureTanks.hot)
    self.charge = .zero
//  self.dischargeLoad = Ratio(0)
    self.heat = 0
    
//  self.tempertureColdOut = tempertureColdOut

//  self.heatLossStorage = heatLossStorage
    self.heatProductionLoad = .zero
    
   //self.massFlow.rate = 0

    self.heatProductionLoad = Ratio(0)

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
  
  static func tankTemperature(_ specificHeat: Double) -> Temperature {
    let hcap = Storage.parameter.HTF.properties.heatCapacity
    return Temperature(celsius: (-hcap[0] + (hcap[0] ** 2 - 4 * (hcap[1] * 0.5)
        * (-350.5536 - specificHeat)) ** 0.5) / (2 * hcap[1] * 0.5))
  }
}
