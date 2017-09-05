//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Config

extension JsonConfigFileHandler {
  
  static func loadConfigurations(atPath path: String)throws {
    
    let configFileHandler = JsonConfigFileHandler()
    configFileHandler.findFilesInDirectory(atPath: path)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    for pathExtensions in FileName.all {
      
      guard let url = configFileHandler.searchConfig(with: pathExtensions),
        let data = JsonConfigFileHandler.readConfig(url: url)
        else {
          print("Config file \(pathExtensions.rawValue) not found.")
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
          Simulation.Parameter.self, from: data)
      case .INI:
        Simulation.initialValues = try decoder.decode(
          InitValues.self, from: data)
      case .TIM:
        Simulation.time = try decoder.decode(Time.self, from: data)
      case .DES: break
      case .AVL:
        Plant.availability = try decoder.decode(Availability.self, from: data)
      case .LAY:
        Design.layout = try decoder.decode(Layout.self, from: data)
      case .SF:
        SolarField.assign(parameter:
          try decoder.decode(SolarField.Parameter.self, from: data))
      case .COL:
        Collector.assign(parameter:
          try decoder.decode(Collector.Parameter.self, from: data))
       case .STO: break
      case .HR:
        Heater.assign(parameter:
          try decoder.decode(Heater.Parameter.self, from: data))
      case .HTF:
        htf = try decoder.decode(FluidProperties.self, from: data)
      case .HX:
        HeatExchanger.assign(parameter:
          try decoder.decode(HeatExchanger.Parameter.self, from: data))
      case .BO:
        Boiler.assign(parameter:
          try decoder.decode(Boiler.Parameter.self, from: data))
      case .WHR:
        WasteHeatRecovery.assign(parameter:
          try decoder.decode(WasteHeatRecovery.Parameter.self, from: data))
      case .GT:
        GasTurbine.assign(parameter:
          try decoder.decode(GasTurbine.Parameter.self, from: data))
      case .TB:
        SteamTurbine.assign(parameter:
          try decoder.decode(SteamTurbine.Parameter.self, from: data))
      case .PB:
        PowerBlock.assign(parameter:
          try decoder.decode(PowerBlock.Parameter.self, from: data))
      case .PFC:
        break
      case .STF:
        salt = try decoder.decode(FluidProperties.self, from: data)
      }
    }
  }
  
  static func saveConfigurations(toPath path: String) throws {
    
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
   let encoder = JSONEncoder()
    
  
   encoder.outputFormatting = .prettyPrinted
   encoder.dateEncodingStrategy = .iso8601

    for name in FileName.all {
      
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
      case .SF: try encoder.encode(SolarField.parameter).write(to: url)
      case .COL: try encoder.encode(Collector.parameter).write(to: url)
      case .STO: break
      case .HR: try encoder.encode(Heater.parameter).write(to: url)
      case .HTF: try encoder.encode(htf).write(to: url)
      case .HX: try encoder.encode(HeatExchanger.parameter).write(to: url)
      case .BO: try encoder.encode(Boiler.parameter).write(to: url)
      case .WHR: try encoder.encode(WasteHeatRecovery.parameter).write(to: url)
      case .GT: try encoder.encode(GasTurbine.parameter).write(to: url)
      case .TB: try encoder.encode(SteamTurbine.parameter).write(to: url)
      case .PB: try encoder.encode(PowerBlock.parameter).write(to: url)
      case .PFC: break
      case .STF: try encoder.encode(salt).write(to: url)
        
      }
    }
  }
}

extension TextConfigFileHandler {
  
  static func loadConfigurations(atPath path: String)throws {
    
    let configFileHandler = TextConfigFileHandler()
    configFileHandler.findFilesInDirectory(atPath: path)
    
    for pathExtensions in ValidPathExtensions.all {
      
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
      case .SIM: Simulation.parameter = try .init(file: configFile)
      case .INI: Simulation.initialValues = try .init(file: configFile)
      case .TIM: Simulation.time = try .init(file: configFile)
      case .DES: break
      case .AVL: break
      case .LAY: Design.layout = try .init(file: configFile)
      case .SF: SolarField.assign(parameter: try .init(file: configFile))
      case .COL: Collector.assign(parameter: try .init(file: configFile))
      case .STO: break
      case .HR: Heater.assign(parameter: try .init(file: configFile))
      case .HTF:
        htf = try FluidProperties(file: configFile, includesEnthalpy: true)
      case .HX: HeatExchanger.assign(parameter: try .init(file: configFile))
      case .BO: Boiler.assign(parameter: try .init(file: configFile))
      case .WHR: WasteHeatRecovery.assign(parameter: try .init(file: configFile))
      case .GT: GasTurbine.assign(parameter: try .init(file: configFile))
      case .TB: SteamTurbine.assign(parameter: try .init(file: configFile))
      case .PB: PowerBlock.assign(parameter: try .init(file: configFile))
      case .PFC:
        break
      case .STF:
        salt = try FluidProperties(file: configFile, includesEnthalpy: false)
      }
    }
  }
}

