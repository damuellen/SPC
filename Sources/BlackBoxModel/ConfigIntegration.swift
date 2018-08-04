//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import Foundation

extension JsonConfigFileHandler {
  static func loadConfigurations(atPath path: String) throws {
    let configFileHandler = JsonConfigFileHandler()
    configFileHandler.findFilesInDirectory(atPath: path)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    for pathExtensions in FileName.allCases {
      guard let url = configFileHandler.searchConfig(with: pathExtensions),
        let data = JsonConfigFileHandler.readConfig(url: url)
      else {
        Log.errorMessage("Config file \(pathExtensions.rawValue) not found.")
        continue
      }

      switch pathExtensions {
      case .FOS: break
      case .OPR: break
      case .DEM: break
      case .TAR:
        Simulation.tariff = try decoder.decode(Tariff.self, from: data)
      case .SIM:
        Simulation.parameter = try decoder.decode(
          Simulation.Parameter.self, from: data
        )
      case .INI:
        Simulation.initialValues = try decoder.decode(
          InitValues.self, from: data
        )
      case .TIM: break
      //    Simulation.time = try decoder.decode(Time.self, from: data)
      case .DES: break
      case .AVL:
        Plant.availability = try decoder.decode(Availability.self, from: data)
      case .LAY:
        Design.layout = try decoder.decode(Layout.self, from: data)
      case .SF:
        SolarField.update(parameter:
          try decoder.decode(SolarField.Parameter.self, from: data))
      case .COL:
        Collector.update(parameter:
          try decoder.decode(Collector.Parameter.self, from: data))
      case .STO: break
      case .HR:
        Heater.update(parameter:
          try decoder.decode(Heater.Parameter.self, from: data))
      case .HTF:
        htf = try decoder.decode(HeatTransferFluid.self, from: data)
      case .HX:
        HeatExchanger.update(parameter:
          try decoder.decode(HeatExchanger.Parameter.self, from: data))
      case .BO:
        Boiler.update(parameter:
          try decoder.decode(Boiler.Parameter.self, from: data))
      case .WHR:
        WasteHeatRecovery.update(parameter:
          try decoder.decode(WasteHeatRecovery.Parameter.self, from: data))
      case .GT:
        GasTurbine.update(parameter:
          try decoder.decode(GasTurbine.Parameter.self, from: data))
      case .TB:
        SteamTurbine.update(parameter:
          try decoder.decode(SteamTurbine.Parameter.self, from: data))
      case .PB:
        PowerBlock.update(parameter:
          try decoder.decode(PowerBlock.Parameter.self, from: data))
      case .PFC:
        break
      case .STF:
        salt = try decoder.decode(HeatTransferFluid.self, from: data)
      }
    }
  }

  static func saveConfigurations(toPath path: String) throws {
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
    let encoder = JSONEncoder()

    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .iso8601

    for name in FileName.allCases {
      let url = URL(fileURLWithPath: name.rawValue + ".json",
                    isDirectory: false, relativeTo: directoryURL)

      switch name {
      case .FOS: break
      case .OPR: break
      case .DEM: break
      case .TAR: try encoder.encode(Simulation.tariff).write(to: url)
      case .SIM: try encoder.encode(Simulation.parameter).write(to: url)
      case .INI: try encoder.encode(Simulation.initialValues).write(to: url)
      case .TIM: try encoder.encode(Simulation.time).write(to: url)
      case .DES: break
      case .AVL: try encoder.encode(Plant.availability).write(to: url)
      case .LAY: try encoder.encode(Design.layout).write(to: url)
      case .SF: try encoder.encode(solarField).write(to: url)
      case .COL: try encoder.encode(collector).write(to: url)
      case .STO: break
      case .HR: try encoder.encode(Heater.parameter).write(to: url)
      case .HTF: try encoder.encode(htf).write(to: url)
      case .HX: try encoder.encode(heatExchanger).write(to: url)
      case .BO: try encoder.encode(Boiler.parameter).write(to: url)
      case .WHR: try encoder.encode(WasteHeatRecovery.parameter).write(to: url)
      case .GT: try encoder.encode(gasTurbine).write(to: url)
      case .TB: try encoder.encode(steamTurbine).write(to: url)
      case .PB: try encoder.encode(PowerBlock.parameter).write(to: url)
      case .PFC: break
      case .STF: try encoder.encode(salt).write(to: url)
      }
    }
  }
}

extension TextConfigFileHandler {
  static func loadConfigurations(atPath path: String) throws {
    let configFileHandler = TextConfigFileHandler()
    configFileHandler.findFilesInDirectory(atPath: path)

    for pathExtensions in ValidPathExtensions.allCases {
      guard let url = configFileHandler.searchConfig(with: pathExtensions),
        let configFile = TextConfigFileHandler.readConfig(url: url)
      else {
        print("Missing config file with extension .\(pathExtensions.rawValue)")
        continue
      }
      switch pathExtensions {
      case .FOS: break
      case .OPR: break
      case .DEM: break
      case .TAR: break // Simulation.tariff = try .init(file: configFile)
      case .SIM: break // Simulation.parameter = try .init(file: configFile)
      case .INI: break // Simulation.initialValues = try .init(file: configFile)
      case .TIM: Simulation.time = try .init(file: configFile)
      case .DES: break
      case .AVL: break
      case .LAY: Design.layout = try .init(file: configFile)
      case .SF: SolarField.update(parameter: try .init(file: configFile))
      case .COL: Collector.update(parameter: try .init(file: configFile))
      case .STO: break
      case .HR: Heater.update(parameter: try .init(file: configFile))
      case .HTF:
        htf = try HeatTransferFluid(file: configFile, includesEnthalpy: true)
      case .HX: HeatExchanger.update(parameter: try .init(file: configFile))
      case .BO: Boiler.update(parameter: try .init(file: configFile))
      case .WHR: WasteHeatRecovery.update(parameter: try .init(file: configFile))
      case .GT: GasTurbine.update(parameter: try .init(file: configFile))
      case .TB: SteamTurbine.update(parameter: try .init(file: configFile))
      case .PB: PowerBlock.update(parameter: try .init(file: configFile))
      case .PFC:
        break
      case .STF:
        salt = try HeatTransferFluid(file: configFile, includesEnthalpy: false)
      }
    }
  }
}
