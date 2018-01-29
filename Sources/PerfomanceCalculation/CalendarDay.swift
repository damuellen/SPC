//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import CoreFoundation

struct CalendarDay: Codable, CustomStringConvertible {
  
  let month: Int
  let day: Int
  let hour: Int
  let minute: Int
  
  public var description: String {
    return "\(day).\(month)"
  }
  
  static var zero: CalendarDay {
    return CalendarDay(month: 0, day: 0, hour: 0, minute: 0)
  }
  
  static var cfCalendar: CFCalendar = {
    let c = CFCalendarCreateWithIdentifier(
      kCFAllocatorDefault, CFCalendarIdentifier.gregorianCalendar)
    let tz = CFTimeZoneCreateWithTimeIntervalFromGMT(
      kCFAllocatorDefault, 0)
    CFCalendarSetTimeZone(c, tz)
    return c!
  }()
  
  mutating func set(_ date: Date) {
    let minute = CFCalendarGetOrdinalityOfUnit(
      CalendarDay.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.minute.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.hour.rawValue),
      date.timeIntervalSinceReferenceDate)
    let hour = CFCalendarGetOrdinalityOfUnit(
      CalendarDay.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.hour.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.day.rawValue),
      date.timeIntervalSinceReferenceDate)
    let day = CFCalendarGetOrdinalityOfUnit(
      CalendarDay.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.day.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.month.rawValue),
      date.timeIntervalSinceReferenceDate)
    let month = CFCalendarGetOrdinalityOfUnit(
      CalendarDay.cfCalendar,
      CFCalendarUnit(rawValue: CFCalendarUnit.month.rawValue),
      CFCalendarUnit(rawValue: CFCalendarUnit.year.rawValue),
      date.timeIntervalSinceReferenceDate)
    self = CalendarDay(month: month, day: day, hour: hour, minute: minute)
    Log.debugMessage("\n\(date)")
  }
}
