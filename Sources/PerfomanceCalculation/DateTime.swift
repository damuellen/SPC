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

public struct DateTime: Codable, CustomStringConvertible {
  public let month: Int
  public let day: Int
  public let hour: Int
  public let minute: Int
  
  public var description: String {
    return "\(hour):\(minute) on \(day).\(month)"
  }
  
  static var zero: DateTime {
    return DateTime.init(month: 0, day: 0, hour: 0, minute: 0)
  }
}

extension DateTime {
  
  init?(dateComponents: DateComponents) {
    guard let month = dateComponents.month,
      let day = dateComponents.day,
      let hour = dateComponents.hour,
      let minute = dateComponents.minute
      else { return nil }
    self.month = month
    self.day = day
    self.hour = hour
    self.minute = minute
  }
}
