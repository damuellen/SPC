// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Units

/// A struct that represents the demand ratio for electricity from the grid over different time intervals
struct GridDemand: Codable {

  /// A static instance of `GridDemand`, used as a singleton to access the current demand data.
  public static var current = GridDemand()

  /// An array of `Ratio` instances representing the demand ratio for electricity in different time intervals.
  /// Each element of the array corresponds to a specific hour-month combination in a year (12 months * 24 hours = 288 elements).
  private var data: [Ratio]

  /// Initializes the `GridDemand` with the given demand ratio data array.
  /// This initializer is used to create the `current` instance with custom demand data.
  ///
  /// - Parameter data: An array of `Ratio` representing demand ratio for different time intervals.
  init(_ data: [Ratio]) { self.data = data }

  /// Initializes a default `GridDemand` instance with a demand ratio of 1 (i.e., no variation in demand).
  private init() { data = Array(repeatElement(Ratio(1), count: 12 * 24)) }

  /// A computed property that calculates and returns the demand ratio for the current time interval.
  /// The current time interval is determined based on the index of the current hour and month in the `DateTime` module.
  /// The `ratio` is obtained from the `data` array using the calculated index.
  var ratio: Double { self.data[index].quotient }

  /// Private helper property that calculates the index for the current hour and month in the demand data array.
  /// The index is calculated as `(DateTime.indexHour * 12 + DateTime.indexMonth)`.
  private var index: Int { (DateTime.indexHour * 12 + DateTime.indexMonth) }
}

extension GridDemand {
  /// An extension initializer that allows initializing the `GridDemand` instance from a text configuration file (`TextConfigFile`).
  /// The initializer extracts the demand ratio data from the file and creates the `GridDemand` instance.
  ///
  /// - Parameter file: The `TextConfigFile` containing demand ratio data.
  /// - Throws: An error if there is an issue reading or parsing the demand ratio data from the file.
  init(file: TextConfigFile) throws {
    // Extract demand ratio data from the file and store it in a 2D array
    let table = file.lines[5..<29]
      .map { $0.split(separator: ",").map(\.trimmed) }
    var data = [Ratio]()
    for row in table {
      // Convert strings to Double and create Ratio instances
      data.append(
        contentsOf: row.compactMap(Double.init).map(Ratio.init(percent:)))
    }
    // Initialize the GridDemand instance with the extracted data
    self.init(data)
  }
}

// MARK: - Other Unused Struct

struct Demand {}
