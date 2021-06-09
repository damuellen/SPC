import CSOLPOS
import CSPA
import DateGenerator
import Foundation

typealias FractionalTime = Double
typealias Algorithm = (SolarPosition.InputValues) -> SolarPosition.OutputValues

let calendar = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

/// A struct containing values where the sun is above the horizon.
/// Look up values using date-based subscript. Otherwise returns nil.
public struct SolarPosition {

  internal var precalculatedValues = [Date: OutputValues]()

  public struct InputValues {
    var year, month, day, hour, minute, second: Int
    var timezone: Double
    var delta_t: Double
    var longitude, latitude, elevation: Double
    var pressure, temperature: Double
    var slope: Double
    var azm_rotation: Double
    var atmos_refract: Double
  }

  public struct OutputValues: Equatable {
    public var zenith, azimuth, elevation: Double
    public var hourAngle: Double
    public var declination: Double
    public var incidence: Double
    public var cosIncidence: Double
    var sunrise: FractionalTime
    var sunset: FractionalTime
  }
  /// A struct for latitude, longitude, timezone, and altitude data associated with a particular geographic location.
  public struct Location {

    var longitude: Double
    var latitude: Double
    var elevation: Double
    public var timezone: Int

    public var coords: (longitude: Double, latitude: Double, elevation: Double) {
      return (longitude, latitude, elevation)
    }

    init(_ coords: (Double, Double, Double), tz: Int) {
      self.longitude = coords.0
      self.latitude = coords.1
      self.elevation = coords.2
      self.timezone = tz
    }
  }

  public var year: Int
  public var location: Location

  public var frequence: DateGenerator.Interval

  /// Creates a struct with precalculated sun position
  /// for the given location and year at the predetermined times.
  ///
  /// - parameter location: longitude, latitude, elevation
  /// - parameter year: 4-digit year
  /// - parameter timezone: Time zone, east (west negative)
  /// - parameter frequence: Time interval for the calculations
  public init(
    coords: (Double, Double, Double), tz: Int,
    year: Int, frequence: DateGenerator.Interval
  ) {
    SolarPosition.estimatedDelta_T = SolarPosition.estimateDelta_T(year: year)
    SolarPosition.frequence = frequence
    let location = Location(coords, tz: tz)

    self.year = year
    self.frequence = frequence
    self.location = location

    let sunHours = SolarPosition.sunHoursPeriod(
      location: location, year: year
    )
    precalculatedValues = calculateSunPositions(
      sunHours: sunHours, location: location
    )
  }

  /// Accesses the values associated with the given date.
  public subscript(date: Date) -> OutputValues? {
    return precalculatedValues[date]
  }

  private static func compute(
    date: Date, location: Location, with algorithm: Algorithm
  ) -> OutputValues {
    let ΔT = SolarPosition.estimatedDelta_T

    let dt = DateTime(date)

    return algorithm(
      InputValues(
        year: dt.year, month: dt.month, day: dt.day,
        hour: dt.hour, minute: dt.minute, second: 0,
        timezone: Double(location.timezone), delta_t: ΔT,
        longitude: location.longitude, latitude: location.latitude,
        elevation: location.elevation, pressure: 1023, temperature: 15,
        slope: 0, azm_rotation: 0, atmos_refract: 0.5667))
  }

  private func calculateSunPositions(
    sunHours: [DateInterval], location: Location
  ) -> [Date: OutputValues] {

    var result: [Date: SolarPosition.OutputValues] = [:]

    let sunHoursPeriod = sunHours.map {
      $0.align(with: SolarPosition.frequence)
    }

    let dates = sunHoursPeriod.flatMap {
      DateGenerator(range: $0, interval: SolarPosition.frequence)
    }
    let offset = 0.0 //frequence.interval / 2
    for date in dates {
      result[date] = SolarPosition.compute(
        date: date + offset, location: location, with: SolarPosition.solpos
      )
    }
    return result
  }

  private static func sunHoursPeriod(
    location: Location, year: Int
  ) -> [DateInterval] {

    var components = DateComponents()
    components.timeZone = calendar.timeZone
    components.year = year
    components.hour = 12 + location.timezone

    let isLeapYear = year % 4 == 0 && year % 100 != 0 || year % 400 == 0

    return (1...(isLeapYear ? 366 : 365)).map { day in

      components.day = day
      let date = calendar.date(from: components)!
      let output = SolarPosition.compute(
        date: date, location: location, with: SolarPosition.spa
      )
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

  private static func estimateDelta_T(year: Int) -> Double {
    var ΔT = 62.92 + 0.32217 * (Double(year) - 2000)
    ΔT += 0.005589 * pow((Double(year) - 2000), 2)
    return ΔT
  }

  private static var estimatedDelta_T: Double = 0
  private static var frequence: DateGenerator.Interval = .hourly

  static func spa(input: InputValues) -> OutputValues {

    enum Output: Int32 {
      case ZA, ZA_INC, ZA_RTS, ALL
    }

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
    return OutputValues(
      zenith: data.zenith, azimuth: data.azimuth, elevation: data.e,
      hourAngle: Double(data.h_prime), declination: data.delta,
      incidence: data.incidence, cosIncidence: cos(data.incidence * .pi / 180),
      sunrise: data.sunrise, sunset: data.sunset)
  }

  static func solpos(input: InputValues) -> OutputValues {

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
    return OutputValues(
      zenith: Double(data.zenref), azimuth: Double(data.azim),
      elevation: Double(data.elevref), hourAngle: Double(data.hrang),
      declination: Double(data.declin),
      incidence: acos(Double(data.cosinc)) * 180 / .pi,
      cosIncidence: Double(data.cosinc),
      sunrise: Double(data.sretr), sunset: Double(data.ssetr))
  }
}
