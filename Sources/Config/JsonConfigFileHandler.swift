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

public class JsonConfigFileHandler {
  /// List of path extension for needed config files.
  public enum FileName: String, CaseIterable {
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

  var paths: [URL] = [URL]()

  public init() {}

  public func fileSearch(atPath path: String) {
    do {
      guard let pathUrl = URL(string: path)
      else { preconditionFailure("Invalid path") }

      let files = try FileManager.default.subpathsOfDirectory(atPath: path)
      let urls = files.map { file in pathUrl.appendingPathComponent(file) }

      paths = urls.filter { path in
        path.lastPathComponent.hasSuffix(".json") &&
          FileName(rawValue: String(path.lastPathComponent.dropLast(5))) != nil
      }
    } catch let error {
      print(error)
    }
  }

  /// Returns a URL of a config file with the given name.
  public func searchConfig(with fileName: FileName) -> URL? {
    return self.paths.lazy
      .first { $0.lastPathComponent.hasPrefix(fileName.rawValue) }
  }

  /// Returns data, which is json encoded model parameter.
  public static func readConfig(url: URL) -> Data? {
    return FileManager.default.contents(atPath: url.absoluteString)
  }
}
