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

public struct Tariff: Codable {
  let name: String
  let abbreviation: String
  let energyPayment, energieCost, capacityPaymentPercent, capacityPayment,
  bonusPaymentPercent, bonusPayment, asAvailableCapacity: Double
}

struct TariffSeason {
  let name: String
  let v1PfD, v1PlD, v2PfD, v2PlD: Int
  let weekday, saturday, holyday: [Int]
}
