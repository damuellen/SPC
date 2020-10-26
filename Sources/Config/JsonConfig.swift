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

public enum JSONConfig {

  public enum Name: String, CaseIterable {
    case FOS = "Fuel"
    case OPR = "Fuel_Operation_Strategy"
    case DEM = "Demand"
    case TAR = "Tariff"
    case SIM = "Simulation"
    case INI = "Initialize"
    case TIM = "Time"
    case DES = "Design"
    case AVL = "Availability"
    case LAY = "Layout"
    case SF = "Solar_Field"
    case COL = "Collector"
    case STO = "Storage"
    case HR = "Heater"
    case HTF
    case STF = "Salt"
    case HX = "Heat_Exchanger"
    case BO = "Boiler"
    case WHR = "Waste_Heat_Recovery"
    case GT = "Gas_Turbine"
    case TB = "Steam_Turbine"
    case PB = "PowerBlock"
    case PFC = "Predefined_Fuel_Consumption"
  }

  static func matchName(url: URL) -> Bool {
    if url.lastPathComponent.hasSuffix(".json"),
      let _ = Name(rawValue: url.deletingPathExtension().lastPathComponent)
    {
      return true
    } else {
      return false
    }
  }

  public static func fileSearch(atPath path: String) -> [URL] {
    do {
      guard let pathUrl = URL(string: path)
      else { preconditionFailure("Invalid path") }

      let files = try FileManager.default.subpathsOfDirectory(atPath: path)
      let urls = files.map { file in pathUrl.appendingPathComponent(file) }

      return urls.filter(matchName)
    } catch let error {
      print(error)
      return []
    }
  }
}
