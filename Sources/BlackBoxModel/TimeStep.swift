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

struct TimeStep: Codable, CustomStringConvertible {
  var yearDay: Int = 0
  var month: Int = 0
  var day: Int = 0
  var hour: Int = 0
  var minute: Int = 0

  public var description: String {
    return "\(self.hour - 1):\(self.minute - 1) \(self.day).\(self.month)."
  }

  static var current = TimeStep()

  fileprivate static var cfCalendar: CFCalendar = {
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
    self = TimeStep(yearDay: yearDay, month: month, day: day, hour: hour, minute: minute)
    Log.debugMessage("\n\(date)")
  }
}
