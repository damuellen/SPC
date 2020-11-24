//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Storage {
  public var description: String {
      "massFlow: \(massFlows.need), min: \(massFlows.minimum), cold: \(massFlows.cold), hot: \(massFlows.hot), heat: \(heatInSalt) "
  }
}
