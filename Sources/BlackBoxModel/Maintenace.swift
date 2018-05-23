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


public struct Maintenance: Codable {
  
  static var ranges: [DateInterval] = []
  
  static func atDefaultTimeRange(for year: Int) {
    let components = DateComponents(
      calendar: calendar, year: year, month: 1, day: 1, hour: 0, minute: 0)
    let start = calendar.date(from: components)!
    let end = calendar.date(byAdding: .day, value: 7, to: start)!
    ranges.append(DateInterval(start: start, end: end))
  }
  @discardableResult
  static func isScheduled(at date: Date) -> Bool {
    var inMaintenance = false
    for range in ranges {
      if range.contains(date) {
        inMaintenance = true
        break
      }
    }
  /* GasTurbine.status.isMaintained = inMaintenance
    Boiler.status.isMaintained = inMaintenance
    SolarField.status.isMaintained = inMaintenance
    SteamTurbine.status.isMaintained = inMaintenance
    Heater.status.isMaintained = inMaintenance*/
    return inMaintenance
  }
}
/*
 CurrDate = month + monthDay / 100
 for i in 1 ... 6 {// 6 Different Maintenance Periods
 steamTurbine.isMaintained = (Maintnc(i).Lowlim <= CurrDate && CurrDate <= Maintnc(i).Uplim)
 }
 if !steamTurbine.isMaintained {      // Check up to 25 excluded days:
 if ExclDays(1) != 0 {
 for i in 1 ... 25 {
 steamTurbine.isMaintained = (CurrDate = ExclDays(i))
 if steamTurbine.isMaintained {
 }
 
 }  // ExclDays(1) != 0 THEN
 */
