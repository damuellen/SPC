// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import Utilities

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

    init?(url: URL) {
      let file = url.deletingPathExtension().lastPathComponent
      for name in Name.allCases {
        if file.contains(name.rawValue) { 
          self = name
          return
        }
      }
      return nil
    }

    public static func detectFile(name: String) -> Bool {
      allCases.reduce(false) { $0 || name.contains($1.rawValue) } 
    }
  }

  public static func read(urls: [URL]) throws {
    for url in urls {
      if let type = JSONConfig.Name(url: url) {
        try decodeConfiguration(of: type, url)
      } else {
        do { try decodeConfiguration(url) } catch { }
      }
    }
  }
  
  static func decodeConfiguration(_ url: URL) throws {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    try decoder.decode(Parameters.self, from: data)()
  }

  static func decodeConfiguration(of type: JSONConfig.Name, _ url: URL) throws {
    let data = try Data(contentsOf: url)
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
    case .STO: Storage.decode(data)
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

  public static func write(toPath path: String, split: Bool) throws {
    if split { try saveConfigurations(toPath: path) }
    else { try saveConfiguration(toPath: path) }
  }

  static func saveConfiguration(toPath path: String) throws {
    var url = URL(fileURLWithPath: path)
    if url.hasDirectoryPath {
      let now = Date().timeIntervalSinceReferenceDate
      let id = String(Int(now), radix: 36, uppercase: true).suffix(6)
      url = URL(fileURLWithPath: "CFG_\(id).json",
                isDirectory: false, relativeTo: url)
    } else {
      url.deletePathExtension()
      url.appendPathExtension("json")
    }
    try encode().write(to: url)
  }

  static func saveConfigurations(toPath path: String) throws {
    var directoryURL = URL(fileURLWithPath: path)
    if !directoryURL.hasDirectoryPath { directoryURL.deleteLastPathComponent() }
    let cases = JSONConfig.Name.allCases
    let json = try cases.map(encode)

    for (key, value) in zip(cases, json) {
      let url = URL(fileURLWithPath: key.rawValue + ".json",
                    isDirectory: false, relativeTo: directoryURL)
      try value.write(to: url)
    }
  }

  public static func encode() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    // encoder.keyEncodingStrategy = .convertToSnakeCase
    return try encoder.encode(Parameters())
  }

  public static func encode(type: JSONConfig.Name) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    // encoder.keyEncodingStrategy = .convertToSnakeCase

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
    case .STO: return try encoder.encode(Storage.parameter)
    case .HR: return try encoder.encode(Heater.parameter)
    case .HTF: return try encoder.encode(HeatTransferFluid.VP1)
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
