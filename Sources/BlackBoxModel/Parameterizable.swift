//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/**
 The `Parameterizable` protocol serves as a blueprint for types that need to handle and parameterize associated Codable types.
 It includes an associated type `Parameter` that must conform to the `Codable` protocol. 
 Additionally, the protocol defines a static property `parameter` of type `Parameter` that can be accessed and modified,
 and a static function `parameterize(_:)` to set the value of the associated parameter.
*/
protocol Parameterizable {
  /// The associated type representing the Codable parameter.
  associatedtype Parameter: Codable
  
  /// The static property to hold the associated parameter value.
  static var parameter: Parameter { get set }

  /// Sets the associated parameter value.
  ///
  /// - Parameter parameter: The new parameter value to be set.
  static func parameterize(_ parameter: Parameter)
}

extension Parameterizable {
  /// Decodes and parameterizes the associated Codable type from the given data.
  ///
  /// - Parameter data: The data to be decoded into the associated parameter type.
  static func decode(_ data: Data) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601   
    do {
      try parameterize(decoder.decode(Parameter.self, from: data))
    } catch {
      print(error.localizedDescription)
    }
  }

  /// Sets the associated parameter value to the provided parameter.
  ///
  /// - Parameter parameter: The new parameter value to be set.
  static func parameterize(_ parameter: Parameter) {
    self.parameter = parameter
  }
}
