//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Foundation
import SolarPosition

// /// A type that provides meteorological data for one year.
// public class MeteoDataProvider: Sequence {
//   public let name: String
//   public let year: Int?
//   public let location: Location

//   let data: [MeteoData]
//   let hourFraction: Double

//   private let valuesPerDay: Int
//   private(set) var frequence: DateSequence.Interval
//   private(set) var dateInterval: DateInterval?

//   public init(
//     name: String, data: [MeteoData],
//     _ meta: (year: Int, location: Location)
//   ) {
//     self.data = data
//     self.location = meta.location
//     self.year = meta.year
//     self.name = name
//     self.hourFraction = 8760 / Double(data.count)
//     self.valuesPerDay = Int(24 / hourFraction)
//     self.frequence = .init(rawValue: Int(1 / hourFraction)) ?? .hour
//     self.range = data.startIndex..<data.endIndex
//     self.statisticsOfDays.reserveCapacity(365)

//     for day in 1...365 { statistics(ofDay: day) }
//   }

//   public func setInterval(_ frequence: DateSequence.Interval) {
//     self.frequence = frequence
//   }

//   public func range(for dateInterval: DateInterval) -> Range<Int> {
//     self.dateInterval = dateInterval.align(with: self.frequence)

//     let start = self.dateInterval!.start
//     let end = self.dateInterval!.end
//     let fraction = Int(1 / hourFraction)

//     let startHour = Greenwich.ordinality(of: .hour, in: .year, for: start)
//     let startIndex = (startHour - 1) * fraction

//     let startMinute = Greenwich.ordinality(of: .minute, in: .hour, for: start)
//     firstStep += startMinute / (60 / frequence.rawValue) / fraction

//     let endHour = Greenwich.ordinality(of: .hour, in: .year, for: end)
//     let lastIndex = (endHour - 1) * fraction

//     return startIndex..<lastIndex

//     //let endMinute = Greenwich.ordinality(of: .minute, in: .hour, for: end)
//     //lastStep = endMinute / (60 / frequence.rawValue) / fraction
//   }


//   private func statistics(ofDay day: Int) {
//     let end = (day * valuesPerDay)
//     let start = end - valuesPerDay

//     let day = data[]

//     let statistics = analyse(day: start..<end)

//     statisticsOfDays.append(statistics)
//   }

// }
