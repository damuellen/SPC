//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Config

public enum Design {
  
  static var layout: Layout = Layout()
  
  static let hasSolarField = layout.solarField > 0
  static let hasHeater = layout.heater > 0
  static let hasHeatExchanger = layout.heatExchanger > 0
  static let hasBoiler = layout.boiler > 0
  static let hasGasTurbine = layout.gasTurbine > 0
  static let hasPowerBlock = layout.powerBlock > 0
  static let hasStorage = layout.storage > 0
}

public struct Layout: Codable {
  
  var solarField = 100.0
  var heater = 20.0
  var heatExchanger = 100.0
  var boiler = 0.0
  var gasTurbine = 0.0
  var powerBlock = 100.0
  var storage = 0.0
  var storage_cap = 0.0
  var storage_ton = 0.0
}

extension Layout: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let values = file.values.filter { !$0.isEmpty }
      .flatMap { $0.split(separator: " ").first }
      .map({String($0).trimmingCharacters(in: .whitespaces)})
    
    for (count, value) in zip(1..., values) {
      if count == 9, let definition = Storage.Definition(rawValue: value) {
        Storage.parameter.definedBy = definition
      }
      guard let value = Double(value)
        else { continue }
      switch count {
      case 1: self.solarField = value
      case 2: self.storage = value
      case 3: self.heater = value
      case 4: self.boiler = value
      case 5: self.gasTurbine = value
      case 6: self.powerBlock = value
      case 7: self.heatExchanger = value
      case 8: break // NDI
      case 10: self.storage_cap = value
      case 11: self.storage_ton = value
      case 12: break // Through
      default: throw TextConfigFile.ReadError.unexpectedValueCount
      }
    }
  }
}
