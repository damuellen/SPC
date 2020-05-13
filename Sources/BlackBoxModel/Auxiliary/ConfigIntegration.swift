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

extension JSONConfig {

  static func loadConfigurations(_ urls: [URL]) throws {
    for url in urls {
      if let data = FileManager.default.contents(atPath: url.absoluteString) {
        try loadConfiguration(.INI, data: data)      
      } else {
      //  print("Config file \(name.rawValue) not found.")
        continue
      }
    }
  }

  public static func loadConfiguration(_ type: JSONConfig.Name, data: Data) throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    switch type {
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
      Availability.current = try decoder.decode(Availability.self, from: data)
    case .LAY:
      Design.layout = try decoder.decode(Layout.self, from: data)
    case .SF:
      SolarField.update(parameter:
        try decoder.decode(SolarField.Parameter.self, from: data))
    case .COL:
      Collector.update(parameter:
        try decoder.decode(Collector.Parameter.self, from: data))
      SolarField.parameter.collector = Collector.parameter
    case .STO: break
    case .HR:
      Heater.update(parameter:
        try decoder.decode(Heater.Parameter.self, from: data))
    case .HTF: break
     // htf = try decoder.decode(HeatTransferFluid.self, from: data)
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
    case .STF: break
    //  salt = try decoder.decode(HeatTransferFluid.self, from: data)
    }
  }

  static func saveConfigurations(toPath path: String) throws {
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
    let cases = JSONConfig.Name.allCases
    let json = try cases.map(generateJSON)

    for (key, value) in zip(cases, json) {
      let url = URL(fileURLWithPath: key.rawValue + ".json",
                    isDirectory: false, relativeTo: directoryURL)
      try value.write(to: url)
    }
  }

  public static func generateJSON(type: JSONConfig.Name) throws -> Data {
    let encoder = JSONEncoder()

    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .iso8601

    switch type {
    case .FOS: break
    case .OPR: break
    case .DEM: break
    case .TAR: return try encoder.encode(Simulation.tariff)
    case .SIM: return try encoder.encode(Simulation.parameter)
    case .INI: return try encoder.encode(Simulation.initialValues)
    case .TIM: return try encoder.encode(Simulation.time)
    case .DES: break
    case .AVL: return try encoder.encode(Availability.current)
    case .LAY: return try encoder.encode(Design.layout)
    case .SF: return try encoder.encode(SolarField.parameter)
    case .COL: return try encoder.encode(Collector.parameter)
    case .STO: break
    case .HR: return try encoder.encode(Heater.parameter)
    case .HTF: break // try encoder.encode(htf)
    case .HX: return try encoder.encode(HeatExchanger.parameter)
    case .BO: return try encoder.encode(Boiler.parameter)
    case .WHR: return try encoder.encode(WasteHeatRecovery.parameter)
    case .GT: return try encoder.encode(GasTurbine.parameter)
    case .TB: return try encoder.encode(SteamTurbine.parameter)
    case .PB: return try encoder.encode(PowerBlock.parameter)
    case .PFC: break
    case .STF: break // try encoder.encode(salt).write(to: url)
    }
  
    return Data()
  }
}

extension TextConfig {
  static func loadConfigurations(atPath path: String) throws {
    let urls = TextConfig.fileSearch(atPath: path)

    for url in urls {
      guard let e = Extension(rawValue: url.pathExtension.uppercased()),
        let configFile = TextConfig.read(url: url)
      else { continue }
      switch e {
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
      case .HTF: break
      //  htf = try HeatTransferFluid(file: configFile, includesEnthalpy: true)
      case .HX: HeatExchanger.update(parameter: try .init(file: configFile))
      case .BO: Boiler.update(parameter: try .init(file: configFile))
      case .WHR: WasteHeatRecovery.update(parameter: try .init(file: configFile))
      case .GT: GasTurbine.update(parameter: try .init(file: configFile))
      case .TB: SteamTurbine.update(parameter: try .init(file: configFile))
      case .PB: PowerBlock.update(parameter: try .init(file: configFile))
      case .PFC:
        break
      case .STF: break
      //  salt = try HeatTransferFluid(file: configFile, includesEnthalpy: false)
      }
    }
  }
}

extension JSONConfig.Name {
  public var description: String {
    switch self {
    case .FOS: break
    case .OPR: break
    case .DEM: break
    case .TAR:
      return ""//Simulation.tariff.description
    case .SIM:
      return Simulation.parameter.description
    case .INI:
      return ""//Simulation.initialValues.description
    case .TIM: break
    case .DES: break
    case .AVL:
      return ""//Availability.current.description
    case .LAY:
      return Design.layout.description
    case .SF:
      return SolarField.parameter.description
    case .COL:
      return Collector.parameter.description
    case .STO: break
    case .HR:
      return Heater.parameter.description
    case .HTF: break
    case .HX:
      return HeatExchanger.parameter.description
    case .BO:
      return Boiler.parameter.description
    case .WHR:
      return WasteHeatRecovery.parameter.description
    case .GT:
      return GasTurbine.parameter.description
    case .TB:
      return SteamTurbine.parameter.description
    case .PB:
      return PowerBlock.parameter.description
    case .PFC:
      break
    case .STF: break
    }
    return ""
  }
}