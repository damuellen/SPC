//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Units

public struct GridDemand: Codable {

  static var current = GridDemand()

  private var index: Int { (DateTime.indexHour * 12 + DateTime.indexMonth) }

  private let data: [Ratio]

  init(_ data: [Ratio]) { self.data = data }

  var ratio: Double { self.data[index].quotient }

  private init() { data = Array(repeatElement(Ratio(1), count: 12 * 24)) }
}

extension GridDemand {
  public init(file: TextConfigFile) throws {
    let table = file.lines[5..<29].map { $0.split(separator: ",").map(\.trimmed) }
    var data = [Ratio]()
    for row in table {
      data.append(contentsOf: row.compactMap(Double.init).map(Ratio.init(percent:)))
    }
    self.init(data)
  }
}

public struct Demand {}