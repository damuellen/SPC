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
      case .SIM: Simulation.parameter = try .init(file: configFile)
      case .INI: Simulation.initialValues = try .init(file: configFile)
      case .TIM: Simulation.time = try .init(file: configFile)
      case .DES: break
      case .AVL: Availability.current = try .init(file: configFile)
      case .LAY: Design.layout = try .init(file: configFile)
      case .SF: SolarField.parameterize(try .init(file: configFile))
      case .COL: Collector.parameterize(try .init(file: configFile))
      case .STO: Storage.parameterize(try .init(file: configFile))
      case .HR: Heater.parameterize(try .init(file: configFile))
      case .HTF: htf = try HeatTransferFluid(file: configFile)
      case .HX: HeatExchanger.parameterize(try .init(file: configFile))
      case .BO: Boiler.parameterize(try .init(file: configFile))
      case .WHR: WasteHeatRecovery.parameterize(try .init(file: configFile))
      case .GT: GasTurbine.parameterize(try .init(file: configFile))
      case .TB: SteamTurbine.parameterize(try .init(file: configFile))
      case .PB: PowerBlock.parameterize(try .init(file: configFile))
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
