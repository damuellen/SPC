//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Storage.Salt {
  public var description: String {
      return "massFlow: \(massFlow.calculated), min: \(massFlow.minimum), cold: \(massFlow.cold), hot: \(massFlow.hot), heat: \(heat.available) "
  }
}
