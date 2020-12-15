//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Heater: CustomStringConvertible {  
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" + "\(self.cycle)"
  }
}
