//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import Meteo
import Utilities

// Define a public enumeration named DryCooling
public enum DryCooling {
  
  // Define a static function named perform which takes steamTurbineLoad and temperature as input parameters
  static func perform(steamTurbineLoad: Ratio, temperature: Temperature)
    -> (DCFactor: Ratio, maxDCLoad: Ratio)
  {
    // Extract the quotient value from steamTurbineLoad
    let load = steamTurbineLoad.quotient
    
    // Define a Polynomial type representing the coefficients for Heat Rate Function
    let coefficientHR: Polynomial = [92.13, 28.73, 18.62, -15.42]
    
    // Define constants for minimum and maximum condenser pressures
    let pressureCondMin = 0.179, pressureCondMax = 0.421 // [bar]
    
    // Define constants for minimum and maximum Heat Rate Factors
    let HRFmin = 98.0, HRFmax = 106.8 // [%] of design
    
    // Define the minimum ambient temperature in Celsius
    let TambMin = 42.2 // [°C]
    
    // Define the temperature difference between inlet and ambient in Celsius
    let inTempDiff = 32.778 // [°C] (=59°F)
    
    // Convert the temperature to Kelvin
    let Tamb = temperature.kelvin
    
    // Calculate the condenser temperature based on the load and inlet temperature difference
    let TCond = Temperature(load ** 0.91 * inTempDiff + Tamb)
    
    // Define a local function to calculate the saturation pressure based on temperature
    func saturationPressure(_ temperature: Temperature) -> Pressure {
      // Coefficients for calculating saturation pressure in MPa
      let coefficients = [
        10.4592, -0.00404897, -0.000041752,
        3.6851e-07, -1.0152e-09, 8.6531e-13,
        9.03668e-16, -1.9969e-18, 7.79287e-22,
        1.91482e-25, -3968.06, 39.5735,
      ]
      
      // Calculate the saturation pressure using polynomial fit
      var fit = 0.0
      for i in 0 ... 9 {
        fit += coefficients[i] * temperature.kelvin ** Double(i)
      }
      let logpsat = fit + coefficients[10] / (temperature.kelvin - coefficients[11])
      return exp(logpsat)
    }
    
    // Calculate the back pressure using the saturation pressure at the condenser temperature
    let backPressure = saturationPressure(TCond) * 10
    
    // Initialize variables to store the calculated Dry Cooling Factor (dcFactor) and maximum load (maxDCLoad)
    var dcFactor = 0.0
    var maxDCLoad = 0.0
    
    // Determine the Dry Cooling Factor (dcFactor) based on the back pressure
    if backPressure <= pressureCondMin {
      dcFactor = HRFmin / 100
    } else if backPressure >= pressureCondMax {
      dcFactor = HRFmax / 100
    } else {
      // Use the Heat Rate Function coefficients to calculate the dcFactor for intermediate back pressures
      dcFactor = coefficientHR(backPressure) / 100
    }
    
    // Determine the maximum load (maxDCLoad) based on the ambient temperature (Tamb)
    if Tamb < TambMin {
      maxDCLoad = 1.0
    } else {
      // Calculate the maximum load using the linear equation aLoad + cLoad * Tamb
      let aLoad = 2.25, cLoad = -0.03
      maxDCLoad = aLoad + cLoad * Tamb
    }
    
    // Return the calculated Dry Cooling Factor (dcFactor) and maximum load (maxDCLoad) as a tuple
    return (Ratio(dcFactor), Ratio(maxDCLoad))
  }
}
