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

public class TextConfigFileHandler {
  /// List of path extension for needed config files.
  public enum ValidPathExtensions: String {
    case FOS, OPR, DEM, TAR, SIM, INI, TIM, DES, AVL,
    LAY, SF, COL, STO, HR, HTF, STF, HX, BO, WHR, GT, TB, PB, PFC
    
    public static var all: [ValidPathExtensions] = [
      .FOS, .OPR, .DEM, .TAR, .SIM, .INI, .TIM, .DES, .AVL, .LAY, .SF,
      .COL, .STO, .HR, .HTF, .STF, .HX, .BO, .WHR, .GT, .TB, .PB, .PFC,
      ]
  }
  var urlsWithValidExtension: [URL] = []
  
  public init() {}
  
  public func findFilesInDirectory(atPath path: String) {
    do {
      guard let pathUrl = URL(string: path)
        else { preconditionFailure("Invalid string for path") }
      
      let files = try FileManager.default.subpathsOfDirectory(atPath: path)
      let urls = files.map { file in pathUrl.appendingPathComponent(file) }
      
      urlsWithValidExtension = urls.filter {
        ValidPathExtensions(rawValue: $0.pathExtension.uppercased()) != nil
      }
    } catch let error {
      print(error)
    }
  }
  
  // Returns an array of URLs, each of which is the path of a config file with the given path extension.
  public func searchConfig(with pathExtension: ValidPathExtensions) -> URL? {
    return urlsWithValidExtension.lazy
      .first(where: { $0.pathExtension.uppercased() == pathExtension.rawValue })
  }
  
  // Returns a String, which contains the content of needed config file.
  public static func readConfig(url: URL) -> TextConfigFile? {
    let path = url.absoluteString
    guard let data = FileManager.default.contents(atPath: path),
      let content = String(data: data, encoding: .ascii) else { return nil }
    return TextConfigFile(content: content, path: path)
  }
}
