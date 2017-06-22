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

public protocol ModelParameter {}

public protocol Model {
  associatedtype Parameter: ModelParameter

  static var parameter: Parameter { get set }

  static func assign(parameter: Parameter)
}

extension Model {
  public static func assign(parameter: Parameter) {
    self.parameter = parameter
  }
}

protocol TextConfigInitializable {
  init(file: TextConfigFile)throws
}

protocol MassFlow {
  var massFlow: Double { get }
  var temperature: (inlet: Double, outlet: Double) { get }
}
