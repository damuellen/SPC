//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

public protocol ComponentParameter {}
public protocol WorkingConditions {}

public protocol Component {
  associatedtype Parameter: ComponentParameter
  associatedtype Data: WorkingConditions
  static var parameter: Parameter { get set }
  static var status: Data { get }
  static func update(parameter: Parameter)
}

extension Component {
  public static func update(parameter: Parameter) {
    self.parameter = parameter
  }
}

protocol HeatTransfer {
  var massFlow: MassFlow { get }
  var temperature: (inlet: Temperature, outlet: Temperature) { get }
}
