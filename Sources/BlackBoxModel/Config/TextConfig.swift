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
import Utilities

public enum TextConfig {
  /// List of path extension for needed config files.
  public enum FileExtension: String, CaseIterable {
    case FOS, OPR, DEM, TAR, SIM, INI, TIM, DES, AVL,
      LAY, SF, COL, STO, HR, HTF, STF, HX, BO, WHR, GT, TB, PB, PFC

    static func isValid(url: URL) -> Bool {
      if let _ = FileExtension(rawValue: url.pathExtension.uppercased()) {
        return true
      } else {
        return false
      }
    }
  }

  public static func fileSearch(atPath path: String) -> [URL] {
    do {
      let pathUrl = URL(fileURLWithPath: path)
      let files = try FileManager.default.subpathsOfDirectory(atPath: path)
      let urls = files.map { file in pathUrl.appendingPathComponent(file) }
      return urls.filter(FileExtension.isValid)
    } catch let error {
      print("\(error)")
      return []
    }
  }

  static func loadConfigurations(atPath path: String) throws {
    let urls = TextConfig.fileSearch(atPath: path)
    var memory = [FileExtension]()
    var htf: HeatTransferFluid?
    for url in urls {
      guard let e = FileExtension(rawValue: url.pathExtension.uppercased()),
        !memory.contains(e), let configFile = TextConfigFile(url: url)
      else { continue }
      switch e {
      case .FOS: break
      case .OPR: break
      case .DEM: break
      case .TAR: break // Simulation.tariff = try .init(file: configFile)
      case .SIM: try Simulation.parameter = .init(file: configFile)
      case .INI: try Simulation.initialValues = .init(file: configFile)
      case .TIM: try Simulation.time = .init(file: configFile)
      case .DES: break
      case .AVL: try Availability.current = .init(file: configFile)
      case .LAY: try Design.layout = .init(file: configFile)
      case .SF:  try SolarField.parameter = .init(file: configFile)
      case .COL: try Collector.parameter = .init(file: configFile)
      case .STO: try Storage.parameter = .init(file: configFile)
      case .HR:  try Heater.parameter = .init(file: configFile)
      case .HTF: try htf = HeatTransferFluid(file: configFile)
      case .HX:  try HeatExchanger.parameter = .init(file: configFile)
      case .BO:  try Boiler.parameter = .init(file: configFile)
      case .WHR: try WasteHeatRecovery.parameter = .init(file: configFile)
      case .GT:  try GasTurbine.parameter = .init(file: configFile)
      case .TB:  try SteamTurbine.parameter = .init(file: configFile)
      case .PB:  try PowerBlock.parameter = .init(file: configFile)
      case .PFC:
        break
      case .STF: break
      //  salt = try HeatTransferFluid(file: configFile)
      }
      memory.append(e)
    }
    if let _ = htf {}// { SolarField.parameter.HTF = htf }
  }
}
