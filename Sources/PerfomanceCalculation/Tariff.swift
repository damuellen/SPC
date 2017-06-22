//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
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

