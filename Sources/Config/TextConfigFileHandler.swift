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
  var urlsWithValidExtension: [URL] = [URL]()
  
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
