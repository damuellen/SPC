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

public enum ConfigFormat {
  case json, text
}

extension JSONConfig {

  static func load(_ url: URL) throws {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    try decoder.decode(ParameterSet.self, from: data)()
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
    case .SF: SolarField.decode(data)
    case .COL: Collector.decode(data)
    case .STO: break
    case .HR: Heater.decode(data)
    case .HTF: break
     // htf = try decoder.decode(HeatTransferFluid.self, from: data)
    case .HX: HeatExchanger.decode(data)
    case .BO: Boiler.decode(data)
    case .WHR: WasteHeatRecovery.decode(data)
    case .GT: GasTurbine.decode(data)
    case .TB: SteamTurbine.decode(data)
    case .PB: PowerBlock.decode(data)
    case .PFC:
      break
    case .STF: break
    //  salt = try decoder.decode(HeatTransferFluid.self, from: data)
    }
  }

  public static func saveConfiguration(toPath path: String) throws {
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
    let json = try generate()
    let url = URL(fileURLWithPath: "Parameter.json",
                  isDirectory: false, relativeTo: directoryURL)
    try json.write(to: url)
  }

  public static func saveConfigurations(toPath path: String) throws {
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
    let cases = JSONConfig.Name.allCases
    let json = try cases.map(generate)

    for (key, value) in zip(cases, json) {
      let url = URL(fileURLWithPath: key.rawValue + ".json",
                    isDirectory: false, relativeTo: directoryURL)
      try value.write(to: url)
    }
  }

  public static func generate() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(ParameterSet())
  }

  public static func generate(type: JSONConfig.Name) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
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
    case .STO: break //return try encoder.encode(Storage.parameter)
    case .HR: return try encoder.encode(Heater.parameter)
    case .HTF: return try encoder.encode(HeatTransferFluid.parameter)
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
    var memory = [FileExtension]()
    for url in urls {
      guard let e = FileExtension(rawValue: url.pathExtension.uppercased()),
        memory.contains(e), let configFile = TextConfigFile(url: url)
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
      case .HTF: break
      //  htf = try HeatTransferFluid(file: configFile, includesEnthalpy: true)
      case .HX: HeatExchanger.parameterize(try .init(file: configFile))
      case .BO: Boiler.parameterize(try .init(file: configFile))
      case .WHR: WasteHeatRecovery.parameterize(try .init(file: configFile))
      case .GT: GasTurbine.parameterize(try .init(file: configFile))
      case .TB: SteamTurbine.parameterize(try .init(file: configFile))
      case .PB: PowerBlock.parameterize(try .init(file: configFile))
      case .PFC:
        break
      case .STF: break
      //  salt = try HeatTransferFluid(file: configFile, includesEnthalpy: false)
      }
      memory.append(e)
    }
  }
}
