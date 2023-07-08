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

    init?(url: URL) {
      if let valid = FileExtension(rawValue: url.pathExtension.uppercased()) {
        self = valid
      } else {
        return nil
      }
    }
  }

  static func loadConfiguration(atPath path: String) throws -> URL? {
    let url = URL(fileURLWithPath: path)
    var urls = [URL]()
    let fm = FileManager.default

    // Check if the given path is a directory
    if url.hasDirectoryPath {
      // Get the list of files in the directory
      let fileList = try fm.contentsOfDirectory(atPath: path)
      // Create an array of URLs for each file in the directory
      urls = fileList.map { file in url.appendingPathComponent(file) }
    } else if url.pathExtension.lowercased().contains("pdd") {
      // If the path is a file with a .pdd extension
      // Read the file and extract the paths
      let file = try TextConfigFile(url: url)
      let paths = file.lines.drop(while: \.isEmpty)
      let separated = paths.map { $0.split(separator: "\\").map(String.init) }
      let folder = url.deletingLastPathComponent()
      var list = try fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
      list = list.filter(\.hasDirectoryPath)
      if list.isEmpty { list.append(folder) }
      // Iterate through the directories and check if the paths match
      for dir in list {
        if urls.isEmpty == false { break }
        for components in separated {
          var fileURL = dir
          let search = fileURL.lastPathComponent
          if let pos = components.firstIndex(of: search) {
            for component in components.dropFirst(pos + 1) {
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

    // Iterate through the URLs and process each file
    for url in urls {
    // Check if the file extension is identified and not already processed
    guard let fileExtension = FileExtension(url: url),
        !identified.contains(fileExtension) else { continue }
    identified.append(fileExtension)
    let configFile = try TextConfigFile(url: url)
    // Process the file based on its extension
    switch fileExtension {
      case .FOS: break
      case .OPR: break
      case .DEM: GridDemand.current = try .init(file: configFile)
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
