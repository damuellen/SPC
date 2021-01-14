//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Energy: Codable {

  public var joule: Double

  public var megaWattHour: Double {
    get { joule / 3_600 / 1_000_000 }
    set {
      joule = newValue * 3_600 * 1_000_000
    }
  }

  public init() {
    self.joule = 0
  }
}
