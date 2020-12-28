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
}
