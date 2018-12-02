//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import CoreFoundation
import Foundation

/**
 TimeStep is used to easily make the calendar data
 of the current time step available during a run.

  - Attention: Needed by `Availability` and `GridDemand` both use `current`,
  also used in `SteamTurbine` and `Storage`.
*/
struct TimeStep: CustomStringConvertible {

  var isDayTime: Bool = true
  var yearDay: Int = 0
  var month: Int = 0
  var day: Int = 0
  var hour: Int = 0
  var minute: Int = 0

  public var description: String {
    let hr = (hour - 1) < 10 ? " \(hour - 1)" : "\(hour - 1)"
    let min = (minute - 1) < 10 ? "0\(minute - 1)" : "\(minute - 1)"
    let d = day < 10 ? " \(day)" : "\(day)"
    let mon = month < 10 ? " \(month). " : "\(month). "
    return hr + ":" + min + "  " + d + "." + mon
  }
  
  static func setCurrent(date: Date) {
    current = .init(date)
  }

  static var current = TimeStep()

  private static var cfCalendar: CFCalendar = {
    let c = CFCalendarCreateWithIdentifier(
      kCFAllocatorDefault, CFCalendarIdentifier.gregorianCalendar
    )
    let tz = CFTimeZoneCreateWithTimeIntervalFromGMT(
      kCFAllocatorDefault, 0
    )
    CFCalendarSetTimeZone(c, tz)
    return c!
  }()
}

extension TimeStep {
  init(_ date: Date) {
    let minute = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.minute.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.hour.rawValue),
      date.timeIntervalSinceReferenceDate
    )
    let hour = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.hour.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.day.rawValue),
      date.timeIntervalSinceReferenceDate
    )
    let day = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.day.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.month.rawValue),
      date.timeIntervalSinceReferenceDate
    )
    let month = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.month.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.year.rawValue),
      date.timeIntervalSinceReferenceDate
    )
    let yearDay = 0 /* CFCalendarGetOrdinalityOfUnit(
     TimeStep.cfCalendar,
     CFCalendarUnit(rawValue: CFCalendarUnit.day.rawValue),
     CFCalendarUnit(rawValue: CFCalendarUnit.year.rawValue),
     date.timeIntervalSinceReferenceDate) */
    self = TimeStep(
      isDayTime: true, yearDay: yearDay,
      month: month, day: day, hour: hour, minute: minute)
    💬.debugMessage("Current simulation time: \n\(date)")
  }
}
