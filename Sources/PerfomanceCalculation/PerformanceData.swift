//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

public struct ElectricEnergy {
  var demand = 0.0, gross = 0.0, shared = 0.0, solarField = 0.0,
  powerBlock = 0.0, storage = 0.0, gasTurbine = 0.0, steamTurbineGross = 0.0,
  gasTurbineGross = 0.0, parasitics = 0.0, net = 0.0, consum = 0.0
}

public struct Components {
  var boiler = 0.0, gasTurbine = 0.0, heater = 0.0, powerBlock = 0.0,
  shared = 0.0, solarField = 0.0, storage = 0.0
}

public struct HeatFlow {
  var solar = 0.0, toSTO = 0.0, toSTOmin = 0.0, storage = 0.0,
  heater = 0.0, boiler = 0.0, wasteHeatRecovery = 0.0, heatExchanger = 0.0,
  production = 0.0, demand = 0.0, dump = 0.0, overtemp_dump = 0.0
}

public struct FuelConsumption {
  var boiler, heater, gasTurbine: Double
  
  var combined: Double {
    return boiler + heater
  }
  
  var total: Double {
    return boiler + heater + gasTurbine
  }
}

