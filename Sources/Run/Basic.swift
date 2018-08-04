//
//  Basic.swift
//  Command
//
//  Created by Daniel Müllenborn on 17.04.18.
//

import BlackBoxModel
import Config
import DateGenerator
import Foundation
import Meteo
import SolarPosition

func foo() {
  let dg = DateGenerator(year: 2018, interval: .every15minutes)
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "GMT")!

  let path = try! FileManager.default.subpathsOfDirectory(
    atPath: FileManager.default.currentDirectoryPath
  )
  .first { $0.hasSuffix(".mto") }!

  let data = try! MeteoDataFileHandler(forReadingAtPath: path).makeDataSource()
  // let mg = MeteoDataGenerator(from: data, interval: .every15minutes)
  var sumDNI: [Int: Double] = [:]

  let solarPosition = SolarPosition(location: (-4.73, 32.68, 1500), year: 2018, timezone: 0, valuesPerHour: .every15minutes)

  for date in dg {
    let c = calendar.dateComponents([.month, .hour, .minute], from: date)
    let v = (month: c.month!, hour: c.hour!, minute: c.minute!)
    let day = calendar.ordinality(of: .day, in: .year, for: date)!

    // sumDNI[day, default: 0] += Double(meteo.dni)
    switch v {
    case (1, 8 ..< 17, _), (1, 7, 30...):
      print("200, 0.85,")
    case (1, 17 ..< 22, _):
      print("185, 1,")
    case (2, 7 ..< 17, _), (2, 17, 0):
      print("200, 0.85,")
    case (2, 18 ..< 22, _), (2, 17, 30...):
      print("185, 1,")
    case (3, 7 ..< 18, _), (3, 6, 30...):
      print("200, 0.85,")
    case (3, 18 ..< 23, _):
      print("185, 1,")
    case (4, 6 ..< 18, _), (4, 18, 0):
      print("200, 0.85,")
    case (4, 19 ... 23, _), (4, 18, 30...):
      print("185, 1,")
    case (5, 6 ..< 19, _):
      print("200, 0.85,")
    case (5, 19 ..< 24, _):
      print("185, 1,")
    case (6, 6 ..< 19, _), (6, 5, 30...):
      print("200, 0.85,")
    case (6, 19 ..< 24, _):
      print("185, 1,")
    case (7, 6 ..< 19, _), (7, 5, 30...):
      print("200, 0.85,")
    case (7, 19 ..< 24, _):
      print("185, 1,")
    case (8, 6 ..< 17, _), (8, 17, 0):
      print("200, 0.85,")
    case (8, 18 ... 23, _), (8, 17, 30...):
      print("185, 1,")
    case (9, 6 ..< 18, _):
      print("200, 0.85,")
    case (9, 18 ..< 23, _):
      print("185, 1,")
    case (10, 7 ..< 17, _), (10, 6, 30...):
      print("200, 0.85,")
    case (10, 17 ..< 22, _):
      print("185, 1,")
    case (11, 7 ..< 17, _):
      print("200, 0.85,")
    case (11, 15 ..< 22, _):
      print("185, 1,")
    case (12, 8 ..< 17, _), (12, 7, 30...):
      print("200, 0.85,")
    case (12, 17 ..< 22, _):
      print("185, 1,")
    default:
      print("0, 0,")
  } }
}
