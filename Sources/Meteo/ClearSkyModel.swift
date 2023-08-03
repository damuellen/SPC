// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Libc
import SolarPosition
import DateExtensions

/// An extension on `MeteoData` that generates synthetic meteorological data based on solar position and clear sky models.
extension MeteoData {
  
  /// Generates synthetic meteorological data for a full year based on solar position, clear sky model, and cloud conditions.
  ///
  /// - Parameters:
  ///   - sun: The `SolarPosition` object representing the sun's position throughout the year.
  ///   - model: The `ClearSkyModel` to be used for calculating direct normal irradiance (DNI).
  ///   - clouds: A flag indicating whether to introduce cloudy conditions (randomly) in the synthetic data.
  ///
  /// - Returns: An array of `MeteoData` representing the synthetic meteorological data for the whole year.
  public static func using(
    _ sun: SolarPosition, model: ClearSkyModel = .constant, clouds: Bool = false
    ) -> [MeteoData]
  {
    // Calculate the number of steps per day based on the solar position frequency.
    let steps = sun.frequence.rawValue * 24
    var step = 0
    var day = 1
    var isCloudy = false

    // Initialize an array to hold the synthetic meteorological data.
    var data = [MeteoData]()
    // Reserve capacity to improve performance when appending data.
    data.reserveCapacity(steps * 365)

    // Create a random number generator using Linear Congruential Algorithm.
    var rng = LinearCongruentialGenerator()

    // Loop through the date series to generate synthetic meteorological data for the whole year.
    for d in DateSeries(year: sun.year, interval: sun.frequence) {
      step += 1
      if step == steps {
        day += 1
        step = 0
      }
      // Check if the sun's zenith angle is below 90 degrees (sun is visible).
      if let pos = sun[d], pos.zenith < 90 {
        // Check if clouds are enabled and generate random cloud condition for the current step.
        isCloudy = clouds && (rng.random() < (isCloudy ? 0.5 : 0.1))
        // Calculate direct normal irradiance (DNI) for the current step using the given clear sky model.
        let dni = calculate(zenith: pos.zenith, day: day, model: model)
          * (isCloudy ? rng.random() : 1)
        // Create a `MeteoData` object with the calculated DNI and a constant temperature of 20 degrees Celsius.
        data.append(MeteoData(dni: dni, temperature: 20))
      } else {
        // If the sun is not visible (nighttime), create a `MeteoData` object with a constant temperature of 10 degrees Celsius.
        data.append(MeteoData(temperature: 10))
      }
    }

    return data
  }
}

/// An enumeration representing different clear sky models for calculating direct normal irradiance (DNI).
public enum ClearSkyModel { case meinel, hottel, constant, special }

/// Private function to calculate direct normal irradiance (DNI) based on zenith angle, day of the year, and the clear sky model.
fileprivate func calculate(zenith: Double, day: Int, model: ClearSkyModel) -> Double {
  // Calculate solar constant (S0) based on the day of the year.
  let S0 = 1.353 * (1 + 0.0335 * cos(2 * .pi * (Double(day) + 10) / 365))
  let B = 2.0 * .pi * Double(day) / 365.0
  // Calculate Earth-Sun distance factor (roverR0sqrd) based on the day of the year.
  let roverR0sqrd = 1.00011
    + 0.034221 * cos(B) + 0.00128 * sin(B)
    + 0.000719 * cos(2 * B) + 0.000077 * sin(2 * B)

  // Calculate the desired DNI on a clear sky day.
  let dni_des = 1130.0 * roverR0sqrd

  // Calculate the cosine of zenith angle (cz) and the aerosol scale height (al).
  let cz = cos(zenith * .pi / 180)
  let al = 0.1 / 1000.0

  // Variable to store the calculated DNI.
  var dni: Double

  // Choose the clear sky model and calculate DNI based on the model.
  switch model {
  case .meinel:
    dni = (1 - 0.14 * al) * exp(-0.357 / pow(cz, 0.678)) + 0.14 * al
  case .hottel:
    dni = 
      0.4237 - 0.00821 * pow(6.0 - al, 2)
      + (0.5055 + 0.00595 * pow(6.5 - al, 2))
      * exp(-(0.2711 + 0.01858 * pow(2.5 - al, 2)) / (cz + 0.00001))
  case .constant:
    dni = dni_des / S0
  case .special:
    dni = (0.5 * ((1 - 0.14 * al) * exp(-0.357 / pow(cz, 0.678)) + 0.14 * al) + 
      (0.4237 - 0.00821 * pow(6.0 - al, 2) + (0.5055 + 0.00595 * pow(6.5 - al, 2))
      * exp(-(0.2711 + 0.01858 * pow(2.5 - al, 2)) / (cz + 0.00001)))) / 1.45
  }
  // Return the calculated DNI multiplied by solar constant (S0) and desired DNI on a clear sky day.
  return dni * S0 * dni_des
}

/// Private struct representing a Linear Congruential Generator (LCG) for generating random numbers.
fileprivate struct LinearCongruentialGenerator {
  var lastRandom = 95.0  // random seed
  let m = 139968.0
  let a = 3877.0
  let c = 29573.0

  /// Generates a random number between 0 and 1 using the Linear Congruential Algorithm.
  mutating func random() -> Double {
    lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
    return lastRandom / m
  }
}
