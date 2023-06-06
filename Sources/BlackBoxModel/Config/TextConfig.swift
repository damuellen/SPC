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
    case FOS, OPR, DEM, TAR, SIM, INI, TIM, DES, AVL, LAY, SF,
      COL, STO, HR, HTF, STF, HX, BO, WHR, GT, TB, PB, PFC

    static func isValid(url: URL) -> Bool {
      if let _ = FileExtension(rawValue: url.pathExtension.uppercased()) {
        return true
      } else {
        return false
      }
    }
  }

  static func loadConfigurations(atPath path: String) throws -> URL? {
    var urls = [URL]()
    let pathUrl = URL(fileURLWithPath: path)
    let fm = FileManager.default

    if pathUrl.hasDirectoryPath {
      let fileList = try fm.contentsOfDirectory(atPath: path)
      urls = fileList.map { file in pathUrl.appendingPathComponent(file) }
    } else {
      let fileContent = try String(contentsOf: pathUrl, encoding: .utf8)
      let filePaths = fileContent.split(whereSeparator: \.isWhitespace)
      let separated = filePaths.map { $0.split(separator: "\\").map(String.init) }
      let folder = pathUrl.deletingLastPathComponent()
      var list = try fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
      list.append(folder)
      for dir in list.filter(\.hasDirectoryPath) {
        if urls.isEmpty == false { break }
        for components in separated {
          var fileURL = dir
          let search = fileURL.lastPathComponent
          if let pos = components.firstIndex(of: search) {
            for component in component.dropFirst(pos + 1) {
              fileURL.appendPathComponent(component)  
            }
            urls.append(fileURL)
          }
        }
      }
    }
    
    var htf: HeatTransferFluid?
    let mto = urls.first(where: { $0.pathExtension.lowercased() == "mto" })
    var identified = [FileExtension]()

    for url in urls {
      guard let configFile = TextConfigFile(url: url),
        let fileExtension = FileExtension(rawValue: configFile.url.pathExtension),
        !identified.contains(fileExtension)
      else { continue }
      identified.append(fileExtension)
      switch fileExtension {
      case .FOS: break
      case .OPR: break
      case .DEM: break
      case .TAR: break  // Simulation.tariff = try .init(file: configFile)
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
      case .PFC: break
      case .STF: break
      //  salt = try HeatTransferFluid(file: configFile)
      }
    }
    if let _ = htf {}  // { SolarField.parameter.HTF = htf }
    return mto
  }
}
