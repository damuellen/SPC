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

protocol Parameterizable {
  associatedtype Parameter: Codable
  
  static var parameter: Parameter { get set }
}

extension Parameterizable {
  static func decode(_ data: Data) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601   
    do {
      try parameter = decoder.decode(Parameter.self, from: data)
    } catch {
      print(error.localizedDescription)
    }
  }
}
