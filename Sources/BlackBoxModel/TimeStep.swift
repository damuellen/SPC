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
  also used in `SteamTurbine` and `Storage` routines.
*/
struct TimeStep: CustomStringConvertible {

  static var current = TimeStep()
  
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

  typealias MonthDay = (day: Int, month: Int)
  
  func isWithin(start: MonthDay, stop: MonthDay) -> Bool {
    assert(start.month <= stop.month)
    var result = false
    if start.month ... stop.month ~= month {
      // month has been checked
      if start.month == stop.month { // both days must checked
        assert(start.day < stop.day - 1)
        if start.day + 1 ..< stop.day ~= day { result = true }
      } else if month == start.month { // start day must checked
        if day > start.day { result = true }
      } else if month == stop.month { // stop day must checked
        if day < stop.day { result = true }
      } else { // No day check necessary
        result = true
      }
    }
    return result
  }
}

extension TimeStep {
  
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
  
  init(_ date: Date) {
    typealias CFCU = CFCalendarUnit
    let minutes = CFCU(rawValue: CFCU.minute.rawValue),
    hours = CFCU(rawValue: CFCU.hour.rawValue),
    days = CFCU(rawValue: CFCU.day.rawValue),
    months = CFCU(rawValue: CFCU.month.rawValue),
    year = CFCU(rawValue: CFCU.year.rawValue),
    refDate =  date.timeIntervalSinceReferenceDate
    
    let minute = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar, minutes, hours, refDate
    )
    let hour = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar, hours, days, refDate
    )
    let day = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar, days, months, refDate
    )
    let month = CFCalendarGetOrdinalityOfUnit(
      TimeStep.cfCalendar, months, year,refDate
    )
    let yearDay = 0 // CFCalendarGetOrdinalityOfUnit(
    // TimeStep.cfCalendar, days, year, refDate)

    self = TimeStep(
      isDayTime: true, yearDay: yearDay,
      month: month, day: day, hour: hour, minute: minute)
    💬.debugMessage("Current simulation time: \n\(date)")
  }
}
