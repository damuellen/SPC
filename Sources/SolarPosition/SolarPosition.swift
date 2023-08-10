// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import CSOLPOS
import CSPA
import DateExtensions
import Foundation
import Utilities

typealias FractionalTime = Double
typealias Algorithm = (SolarPosition.Input) -> SolarPosition.Output

/// A struct for latitude, longitude, timezone, and altitude data associated with a particular geographic location.
public struct Location: Equatable {
  /// The longitude of the location.
  public var longitude: Double
  /// The latitude of the location.
  public var latitude: Double
  /// The elevation of the location.
  public var elevation: Double
  /// The timezone of the location.
  public var timezone: Int
  /// A tuple containing longitude, latitude, and elevation.
  public var coordinates:
    (longitude: Double, latitude: Double, elevation: Double)
  { return (longitude, latitude, elevation) }
}

extension Location {
  /// Initialize a Location object with the given coordinates and timezone.
  ///
  /// - Parameters:
  ///   - coords: A tuple containing longitude, latitude, and elevation.
  ///   - tz: The timezone of the location.
  public init(
    _ coords: (longitude: Double, latitude: Double, elevation: Double), tz: Int
  ) {
    self.longitude = coords.longitude
    self.latitude = coords.latitude
    self.elevation = coords.elevation
    self.timezone = tz
  }
}

/// A struct containing solar position values where the sun is above the horizon.
///
/// You can look up values using a date-based subscript, which returns the associated output for that date. If the date is not found, it returns nil.
public struct SolarPosition {
  /// The array of calculated solar position values.
  public private(set) var calculatedValues = [Output]()
  /// A dictionary used for fast date-based lookups to find corresponding indices in calculatedValues array.
  internal var lookupDates = [Date: Int]()

  /// A struct representing the input parameters for the solar position calculations.
  public struct Input {
    var year, month, day, hour, minute, second: Int
    var timezone: Double
    var delta_t: Double
    var longitude, latitude, elevation: Double
    var pressure, temperature: Double
    var slope: Double
    var azm_rotation: Double
    var atmos_refract: Double
  }

  // A struct representing the output values of the solar position calculations.
  public struct Output: Equatable {
    public var zenith, azimuth, elevation: Double
    public var hourAngle: Double
    public var declination: Double
    public var incidence: Double
    public var cosIncidence: Double
    var sunrise: FractionalTime
    var sunset: FractionalTime
  }
  /// The year for the solar position calculations.
  public var year: Int
  /// The geographic location for the solar position calculations.
  public var location: Location
  // The time interval for the solar position calculations.
  public var frequence: DateSeries.Frequence

  /// Creates a struct with precalculated sun positions for the given location and year at the predetermined times.
  ///
  /// - Parameters:
  ///   - coords: A tuple containing longitude, latitude, and elevation.
  ///   - tz: The timezone of the location.
  ///   - year: The 4-digit year.
  ///   - frequence: The time interval for the calculations.
  public init(
    coords: (Double, Double, Double), tz: Int, year: Int,
    frequence: DateSeries.Frequence
  ) {
    // Set the estimatedDelta_T value based on the given year
    SolarPosition.estimatedDelta_T = SolarPosition.estimateDelta_T(year: year)
    // Set the frequence value
    SolarPosition.frequence = frequence
    // Create a Location object with the given coordinates and timezone
    let location = Location(coords, tz: tz)

    // Set the year, frequence, and location properties
    self.year = year
    self.frequence = frequence
    self.location = location

    // Calculate the sun hours period for the given location and year
    let sunHours = SolarPosition.sunHoursPeriod(location: location, year: year)
    // Align the sun hours period to the specified frequence
    let sunHoursPeriod = sunHours.map {
      $0.aligned(to: SolarPosition.frequence)
    }
    // Create a DateSeries for each sun hours period
    let dates = sunHoursPeriod.flatMap {
      DateSeries(range: $0, interval: SolarPosition.frequence)
    }
    // Create a lookup dictionary with dates as keys and corresponding values as indices
    lookupDates = Dictionary(uniqueKeysWithValues: zip(dates, 0...))
    // Calculate the solar position for each date in parallel
    let offset = 0.0  //frequence.interval / 2
    calculatedValues = dates.concurrentMap { date in
      SolarPosition.compute(date: date + offset, location: location)
    }
  }

  /// Accesses the values associated with the given date.
  ///
  /// - Parameter date: The date for which solar position values are retrieved.
  public subscript(date: Date) -> Output? {
    guard let i = lookupDates[date] else { return nil }
    return calculatedValues[i]
  }

  /// Compute the solar position values for the given date and location.
  ///
  /// - Parameters:
  ///   - date: The date for which solar position values are computed.
  ///   - location: The geographic location for which solar position values are computed.
  ///   - algorithm: The algorithm function used for solar position calculations (default is `SolarPosition.solpos`).
  /// - Returns: The computed solar position values.
  private static func compute(
    date: Date, location: Location,
    with algorithm: Algorithm = SolarPosition.solpos
  ) -> Output {
    let ΔT = SolarPosition.estimatedDelta_T

    let dt = DateTime(date)

    return algorithm(
      Input(
        year: dt.year, month: dt.month, day: dt.day, hour: dt.hour,
        minute: dt.minute, second: 0, timezone: Double(location.timezone),
        delta_t: ΔT, longitude: location.longitude,
        latitude: location.latitude, elevation: location.elevation,
        pressure: 1023, temperature: 15, slope: 0, azm_rotation: 0,
        atmos_refract: 0.5667))
  }

  /// Compute the sun hours period for the given location and year.
  ///
  /// - Parameters:
  ///   - location: The geographic location for which the sun hours period is calculated.
  ///   - year: The year for which the sun hours period is calculated.
  /// - Returns: An array of DateInterval representing the sun hours period for each day in the year.
  private static func sunHoursPeriod(location: Location, year: Int)
    -> [DateInterval]
  {

    var components = DateComponents()
    components.timeZone = Greenwich.timeZone
    components.year = year
    components.hour = 12 + location.timezone

    let isLeapYear = year % 4 == 0 && year % 100 != 0 || year % 400 == 0

    return (1...(isLeapYear ? 366 : 365))
      .map { day in

        components.day = day
        let date = Greenwich.date(from: components)!
        let output = SolarPosition.compute(
          date: date, location: location, with: SolarPosition.spa)
        assert(
          output.sunrise < output.sunset,
          "sunset before sunrise check location and time zone")

        if let sunrise = date.set(time: output.sunrise),
          let sunset = date.set(time: output.sunset)
        {
          return DateInterval(start: sunrise, end: sunset)
        }
        fatalError("No sun hours. Day: \(day)")
      }
  }
  /// Estimate the value of ΔT (delta_t) for the given year.
  ///
  /// - Parameter year: The 4-digit year for which ΔT is estimated.
  /// - Returns: The estimated value of ΔT for the given year.
  private static func estimateDelta_T(year: Int) -> Double {
    var ΔT = 62.92 + 0.32217 * (Double(year) - 2000)
    ΔT += 0.005589 * pow((Double(year) - 2000), 2)
    return ΔT
  }
  /// The estimated value of ΔT (delta_t) used for solar position calculations.
  private static var estimatedDelta_T: Double = 0
  /// The time interval used for solar position calculations.
  private static var frequence: DateSeries.Frequence = .hour

  /// Compute solar position values using the SPA (Solar Position Algorithm) algorithm.
  ///
  /// - Parameter input: The input parameters for the solar position calculations.
  /// - Returns: The computed solar position values.
  static func spa(input: Input) -> Output {

    enum Output: Int32 { case ZA, ZA_INC, ZA_RTS, ALL }

    var data = spa_data()
    data.year = Int32(input.year)
    data.month = Int32(input.month)
    data.day = Int32(input.day)
    data.hour = Int32(input.hour)
    data.minute = Int32(input.minute)
    data.second = Int32(input.second)
    data.timezone = input.timezone
    data.delta_t = input.delta_t
    data.longitude = input.longitude
    data.latitude = input.latitude
    data.elevation = input.elevation
    data.pressure = input.pressure
    data.temperature = input.temperature
    data.slope = input.slope
    data.azm_rotation = input.azm_rotation
    data.atmos_refract = input.atmos_refract
    data.function = Output.ALL.rawValue

    let _ = spa_calculate(&data)
    return SolarPosition.Output(
      zenith: data.zenith, azimuth: data.azimuth, elevation: data.e,
      hourAngle: Double(data.h_prime), declination: data.delta,
      incidence: data.incidence, cosIncidence: cos(data.incidence * .pi / 180),
      sunrise: data.sunrise, sunset: data.sunset)
  }
  /// Compute solar position values using the SOLPOS algorithm.
  ///
  /// - Parameter input: The input parameters for the solar position calculations.
  /// - Returns: The computed solar position values.
  static func solpos(input: Input) -> Output {

    var data = posdata()
    data.day = Int32(input.day)  // Day of month (May 27 = 27, etc.)
    data.hour = Int32(input.hour)  // Hour of day, 0 - 23
    data.minute = Int32(input.minute)  // Minute of hour, 0 - 59
    data.month = Int32(input.month)  // Month number (Jan = 1, Feb = 2, etc.)
    data.second = Int32(input.second)  // Second of minute, 0 - 59
    data.year = Int32(input.year)  // 4-digit year
    data.daynum = 1
    data.interval = 0  // iTantaneous measurement interval
    data.aspect = 180.0  // Azimuth of panel surface (direction it  faces) N=0, E=90, S=180, W=270
    data.latitude = Float(input.latitude)  // Latitude, degrees north (south negative)
    data.longitude = Float(input.longitude)  // Longitude, degrees east (west negative)
    data.press = Float(input.pressure)  // Surface pressure, millibars
    data.solcon = 1367.0  // Solar coTant, 1367 W/sq m
    data.temp = 15.0  // Ambient dry-bulb temperature, degrees C
    data.tilt = 0.0  // Degrees tilt from horizontal of panel
    data.timezone = Float(input.timezone)  // Time zone, east (west negative).
    data.sbwid = 7.6  // Eppley shadow band width
    data.sbrad = 31.7  // Eppley shadow band radius
    data.sbsky = 0.04  // Drummond factor for partly cloudy skies
    data.function = S_ALL  // compute all parameters

    let _ = S_solpos(&data)
    return Output(
      zenith: Double(data.zenref), azimuth: Double(data.azim),
      elevation: Double(data.elevref), hourAngle: Double(data.hrang),
      declination: Double(data.declin),
      incidence: acos(Double(data.cosinc)) * 180 / .pi,
      cosIncidence: Double(data.cosinc), sunrise: Double(data.sretr),
      sunset: Double(data.ssetr))
  }
}

extension SolarPosition.Output: CustomStringConvertible {
  /// A textual representation of the `SolarPosition.Output`
  public var description: String {
    String(
      format: "%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.2f", zenith, azimuth, elevation,
      hourAngle, declination, incidence, cosIncidence)
  }
  public var values: [Double] {
    [
      zenith, azimuth, elevation, hourAngle, declination, incidence,
      cosIncidence,
    ]
  }
  public static var labels: String {
    [
      "zenith", "azimuth", "elevation", "hourAngle", "declination",
      "incidence", "cosIncidence",
    ]
    .joined(separator: ",")
  }
}

extension SolarPosition: CustomStringConvertible {
  /// A textual representation of the `SolarPosition`
  public var description: String {
    var description = ""
    print(
      "month", "day", "hour", "minute", SolarPosition.Output.labels,
      separator: ",", to: &description)
    for date in DateSeries(year: year, interval: frequence) {
      let time = DateTime(date)
      if let pos = self[date] {
        print(
          time.month, time.day, time.hour, time.minute, pos, separator: ",",
          to: &description)
      } else {
        print(
          time.month, time.day, time.hour, time.minute, 0, 0, 0, 0, 0, 0, 0,
          separator: ",", to: &description)
      }
    }
    return description
  }
}
