// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Utilities
import Foundation
import Meteo
// import SQLite
import xlsxwriter
/// A class that records performance data.
public final class Historian {

  #if DEBUG && !os(Windows)
  /// Tracking the day (only used in DEBUG mode and not on Windows)
  private var progress: Int = 0
  #endif

  /// Number of values per hour (time steps per hour)
  private let frequency = Simulation.time.steps

  /// Specifies the output mode for the historian.
  let mode: Mode

  /// Start date of the recording, based on the simulation date interval or a predefined year.
  var startDate: Date { 
    Simulation.time.dateInterval?.start 
    ?? Greenwich.date(from: .init(year: BlackBoxModel.simulatedYear))!
  }

  /// Enumeration representing various output modes for the historian.
  public enum Mode {
    case database
    case inMemory
    case custom(valuesPerHour: Steps)
    case csv
    case excel
    
    /// Checks if the output mode supports file output.
    var hasFileOutput: Bool {
      if case .inMemory = self { return false }
      return true
    }
    
    /// Checks if the output mode supports historical data recording.
    var hasHistory: Bool {
      #if DEBUG && !os(Windows)
      return true
      #else
      if case .excel = self { return true }
      if case .database = self { return true }
      if case .inMemory = self { return true }
      return false
      #endif
    }
  }

  /// sqlite file
  // private var db: Connection? = nil

  /// Output file URL or directory path (depending on the output mode).
  private var url: URL
  
  /// OutputStream to write data to a file.
  private var fileStream: OutputStream?

  /// Workbook object for Excel output mode.
  private var xlsx: Workbook? = nil
  
  /// All past states of the plant.
  private(set) var status: [Status] = []

  /// All past performance data of the plant.
  private(set) var performance: [PlantPerformance] = []

  /// All past insolation data.
  private(set) var sun: [Insolation] = []

  /// Common prefix for output files.
  var name = "Run"

  /// Initializes the Historian.
  /// - Parameters:
  ///   - name: Name for the output files (optional).
  ///   - path: Directory path for the output files (optional).
  ///   - mode: Output mode for the Historian.
  public init(name: String? = nil, path: String? = nil, mode: Mode) {
    // Reserve capacity for the status, performance, and sun arrays based on the frequency
    status.reserveCapacity(8760 * frequency.rawValue)
    performance.reserveCapacity(8760 * frequency.rawValue)
    sun.reserveCapacity(8760 * frequency.rawValue)

    // Set the URL based on the provided path
    self.url = URL(fileURLWithPath: path ?? "")
    self.mode = mode

    // Check if the mode requires file output and if the provided path is a valid directory
    if mode.hasFileOutput, !url.hasDirectoryPath {
      print("Invalid path for results: \(url.path)\n")
      print("There will be no output files.\n")
    }

    // Set the name if provided
    if let name = name { self.name = name } 

    // Get the sequence number for the current path
    let no = sequenceNumber(atPath: url.path)

    // Check if the mode is .excel
    if case .excel = mode {
      // Append the name, sequence number, and frequency to the URL
      url = url.appendingPathComponent("\(self.name)_\(no)_\(frequency).xlsx")
      // Create a new Workbook instance with the updated URL
      self.xlsx = Workbook(name: url.path)
    }
    // if case .database = mode {
    //   let url = urlDir.appendingPathComponent("\(name)\(suffix).sqlite3")
    //   self.db = try! Connection(url.path)
    //   urls = [url]
    // }
    
    // Check if the mode is .csv
    if case .csv = mode {
      // Get the header information
      let header = headers()
      // Create a buffer with the encoded header name and unit
      let buffer = separatedLines(header.name.bytes, header.unit.bytes)
      // Append the name, sequence number, and "hourly" to the URL
      url = url.appendingPathComponent("\(self.name)_\(no)_hourly.csv")
      // Create a new OutputStream instance with the updated URL
      fileStream = OutputStream(url: url, append: false)
      fileStream?.open()
      // Write the buffer to the file stream
      _ = fileStream?.write(buffer, maxLength: buffer.count)
    }

    // Check if the mode is .custom
    if case .custom(let i) = mode {
      // Get the header information with minutes set to true
      let header = headers(minutes: true)
      // Create a string with zeros for the start time
      let startTime = repeatElement("0", count: header.count + 4)
        .joined(separator: ",")
      // Format the fraction value
      let fraction = String(format: "%.5f", i.fraction)
      // Repeat the fraction value for the header count + 4 times
      let frequence = repeatElement(fraction, count: header.count + 4)
        .joined(separator: ",")
      // Create a buffer with the encoded header name, start time, frequency, and unit
      let buffer = separatedLines(
        "wxDVFileHeaderVer.1".bytes, header.name.bytes,
        startTime.bytes, frequence.bytes, header.unit.bytes)

      // Append the name, sequence number, and custom value to the URL
      url = url.appendingPathComponent("\(self.name)_\(no)_\(i).csv")

      // Create a new OutputStream instance with the updated URL
      fileStream = OutputStream(url: url, append: false)
      fileStream?.open()
      // Write the buffer to the file stream
      _ = fileStream?.write(buffer, maxLength: buffer.count)
    }

    // Check if the mode does not have file output
    if !mode.hasFileOutput { return }
    // Print the file output information
    print("File output to:\n\(url.path)")
  }

  /// Deinitializes the Historian.
  deinit {
    fileStream?.close()
  }

  /// Clears all recorded performance data and status history.
  public func clearResults() {
    performance.removeAll(keepingCapacity: true)
    status.removeAll(keepingCapacity: true)
    sun.removeAll(keepingCapacity: true)
  }

  /// Records performance data and status history.
  /// - Parameters:
  ///   - time: DateTime struct representing the current time.
  ///   - meteo: MeteoData struct containing meteorological data.
  ///   - status: Status struct representing the current state of the plant.
  ///   - energy: PlantPerformance struct containing performance data.
  func callAsFunction(
    _ time: DateTime, meteo: MeteoData, status: Status, energy: PlantPerformance
  ) {
    self.status.append(status)
    self.performance.append(energy)
    self.sun.append(meteo.insolation)
    #if PRINT
    print(decorated(time.description), meteo, status, energy)
    ClearScreen()
    #elseif DEBUG && !os(Windows)
    if progress != time.yearDay {
      progress = time.yearDay
      print(" [\(progress)/\(365)] recording day…", terminator: "\r")
      fflush(stdout)
    }
    #endif
  }

  /// Finalizes the recording and returns a Recording containing the historical data.
  /// - Parameter open: A boolean flag indicating whether to open the file after finalization (default is false).
  public func finish(open: Bool = false) -> Recording {
    #if DEBUG && !os(Windows)
    let clearLineString = "\u{001B}[2K"
    print(clearLineString, terminator: "\r")
    fflush(stdout)
    #endif
      /// Sum of hourly values
    var accumulate = PlantPerformance()
    var insolation = Insolation()
    if case .custom(let custom) = mode {
      let f = frequency.rawValue / custom.rawValue
      var date = startDate
      for i in stride(from: 0, to: performance.count, by: f) {
        accumulate(performance[i..<i+f], timeProportion: 1 / Double(f))
        insolation = sun[i..<i+f].weightedAverage(timeProportion: 1 / Double(f))
        let time = DateTime(date)
        let buffer = commaSeparatedLine(
          time.commaSeparatedValues.bytes,
          "\(time.minute)".bytes,
          insolation.precisionTwoCommaSeparatedValues.bytes,
          accumulate.precisionTwoCommaSeparatedValues.bytes)
        date.addTimeInterval(custom.interval)
        _ = fileStream?.write(buffer, maxLength: buffer.count)
      }
    }

    if case .csv = mode {
      let f = frequency.rawValue
      var date = startDate
      for i in stride(from: 0, to: performance.count, by: f) {
        let fraction = frequency.fraction
        accumulate(performance[i..<i+f], timeProportion: fraction)
        insolation = sun[i..<i+f].weightedAverage(timeProportion: fraction)
        let buffer = commaSeparatedLine(
          DateTime(date).commaSeparatedValues.bytes,
          insolation.precisionTwoCommaSeparatedValues.bytes,
          accumulate.precisionTwoCommaSeparatedValues.bytes)
        date.addTimeInterval(Steps.hour.interval)
        _ = fileStream?.write(buffer, maxLength: buffer.count)
      }
    }

    if case .database = mode { storeInDB() }
    if case .excel = mode { writeExcel() }

    let irradiance = sun.weightedAverage(timeProportion: frequency.fraction)
    if mode.hasFileOutput, open { start(url.path) }
    fileStream?.close()
    fileStream = nil
    return Recording(
      startDate: startDate, irradiance: irradiance, 
      performanceHistory: performance,
      statusHistory: status)
  }

  /// Determine the next sequence number for a file in a given directory.
  ///
  /// It does this by finding all the files in the directory that have a prefix matching a specified name. 
  /// It then extracts the sequence number from each file name and finds the maximum value. 
  /// Finally, it increments the maximum value by 1 and returns it as a formatted string with leading zeros.
  private func sequenceNumber(atPath path: String) -> String {
    let 💾 = FileManager.default
    let contents = try? 💾.contentsOfDirectory(atPath: path)
    let results = contents?.filter { $0.hasPrefix(name) }
    let last = results?.compactMap { filename in
      let splited = filename.split(separator: "_")
      let idx = min(1,splited.endIndex - 1)
      return Int(splited[idx].filter(\.isWholeNumber))
    }.max() 
    return String(format: "%02d", (last ?? 0) + 1)
  }

  /// Writes data to an Excel file.
  private func writeExcel() {
    guard let wb = xlsx else { return }
    // Check if the xlsx object is not nil, otherwise return
    print("Excel file creation started.")
    // Print a message indicating that the Excel file creation has started
    let now = Date()
    // Get the current date and time
    let f1 = wb.addFormat().set(num_format: "hh:mm  dd.mm")
    // Create a format for displaying time and date in the Excel file
    let f0 = wb.addFormat().set(num_format: "0")
    // Create a format for displaying integers in the Excel file
    let f2 = wb.addFormat().set(num_format: "0.0")
    // Create a format for displaying numbers with one decimal place in the Excel file
    let f3 = wb.addFormat().set(num_format: "0.00")
    // Create a format for displaying numbers with two decimal places in the Excel file
    let f4 = wb.addFormat().set(num_format: 9)
    // Create a format for displaying numbers as scientific notation in the Excel file
    let statusCaptions =
      ["Time  Date"] + Insolation.measurements.map(\.0) + Status.modes
      + Status.measurements.map(\.0)
    // Create an array of captions for the status sheet in the Excel file
    let statusCount = statusCaptions.count
    // Get the number of status captions
    let modesCount = Status.modes.count
    // Get the number of modes in the status sheet
    let energyCaptions = ["Date"] + PlantPerformance.measurements.map(\.0)
    // Create an array of captions for the performance sheet in the Excel file
    let energyCount = energyCaptions.count
    // Get the number of energy captions

    let ws1 = wb.addWorksheet(name: "Status")
      .column("A:A", width: 13, format: f1)
      .column("B:D", width: 6, format: f0)
      .column("E:G", width: 17, format: f3)
      .column("H:H", width: 6, format: f0)
      .column("I:I", width: 6, format: f3)
      .column("J:J", width: 11, format: f4)
      .column([10, statusCount], width: 15, format: f2)
      .hide_columns(statusCount)
      .write(statusCaptions, row: 0)
    // Add a worksheet named "Status" to the Excel file and set the column widths and formats
    // Hide the columns with the status count
    // Write the status captions to the first row of the worksheet

    let ws2 = wb.addWorksheet(name: "Performance")
      .column("A:A", width: 13, format: f1)
      .column([1, energyCount], width: 6, format: f2)
      .hide_columns(energyCount)
      .write(energyCaptions, row: 0)
    // Add a worksheet named "Performance" to the Excel file and set the column widths and formats
    // Hide the columns with the energy count
    // Write the energy captions to the first row of the worksheet

    let interval = Simulation.time.steps.interval
    // Get the interval between simulation time steps
    var date = startDate
    // Set the initial date to the start date of the simulation

    status.indices.forEach { i in
      ws1.write(.datetime(date), [i + 1, 0])
      // Write the date and time to the specified cell in the status worksheet
      ws1.write(sun[i].values, row: i + 1, col: 1)
      // Write the sun values to the specified row and column in the status worksheet
      ws1.write(status[i].modes, row: i + 1, col: 4)
      // Write the status modes to the specified row and column in the status worksheet
      ws1.write(status[i].values, row: i + 1, col: 4 + modesCount)
      // Write the status values to the specified row and column in the status worksheet
      date.addTimeInterval(interval)
      // Increment the date by the interval between simulation time steps
    }

    date = startDate
    // Reset the date to the start date of the simulation

    performance.indices.forEach { i in
      ws2.write(.datetime(date), [i + 1, 0])
      // Write the date and time to the specified cell in the performance worksheet
      ws2.write(performance[i].values, row: i + 1, col: 1)
      // Write the performance values to the specified row and column in the performance worksheet
      date.addTimeInterval(interval)
      // Increment the date by the interval between simulation time steps
    }
    wb.close()
    // Close the Excel file
    print("Excel file creation took \(Int(-now.timeIntervalSinceNow)) seconds.")
    // Print the time taken to create the Excel file
  }


  // This section contains code for writing data to a database (SQLite).
  // However, it is commented out and not implemented in the current code.

  private func storeInDB() {
    // guard let db = db else { return }

    // func createTable(name: String, measurements: [String]) {
    //   let table = Table(name)
    //   let expressions = measurements.map { Expression<Double>($0) }
    //   try! db.run(table.create { t in expressions.forEach { t.column($0) } })
    // }

    // let status = Status.measurements.map {
    //   $0.name.replacing("|", with: "_")
    // }
    // let energy = PlantPerformance.measurements.map {
    //   $0.name.replacing("|", with: "_")
    // }
    // createTable(name: "PerformanceData", measurements: status)
    // createTable(name: "Performance", measurements: energy)

    // let p1 = repeatElement("?", count: status.count).joined(separator: ",")
    // try! db.transaction {
    //   let stmt = try! db.prepare("INSERT INTO PerformanceData VALUES (\(p1))")
    //   for entry in statusHistory { try! stmt.run(entry.values) }
    // }

    // let p2 = repeatElement("?", count: energy.count).joined(separator: ",")
    // try! db.transaction {
    //   let stmt = try! db.prepare("INSERT INTO Performance VALUES (\(p2))")
    //   for entry in performanceHistory { try! stmt.run(entry.values) }
    // }
  }

  /// Returns the headers for the data table.
  /// - Parameter minutes: A boolean flag indicating whether to include minutes in the header (default is false).
  private func headers(minutes: Bool = false) -> (name: String, unit: String, count: Int) {
    #if DEBUG
    let m = Insolation.measurements + PlantPerformance.measurements + Status.measurements
    #else
    let m = Insolation.measurements + PlantPerformance.measurements
    #endif
    let name: String = m.map(\.name).joined(separator: ",")
    let unit: String = m.map(\.unit).joined(separator: ",")
    if minutes { return ("Month,Day,Hour,Minute," + name, "_,_,_,_," + unit, m.count) }
    return ("Month,Day,Hour," + name, "_,_,_," + unit, m.count)
  }
}

// Extension to provide encoded string functionality.
extension String { fileprivate var bytes: [UInt8] { [UInt8](self.utf8) } }

// Define newline characters based on the operating system.
#if os(Windows)
fileprivate let newLineBytes: [UInt8] = [UInt8(ascii: "\r"), UInt8(ascii: "\n")] 
#else
fileprivate let newLineBytes: [UInt8] = [UInt8(ascii: "\n")] 
#endif
fileprivate let commaBytes: [UInt8] = [UInt8(ascii: ",")] 

/// Converts an array of `UInt8` arrays into a comma-separated line,
/// suitable for CSV format. Adds commas between the arrays and a newline at the end.
fileprivate func commaSeparatedLine(_ bytes: [UInt8]...) -> [UInt8] {
  return bytes.dropLast().flatMap { $0 + commaBytes } + bytes.last! + newLineBytes
}

/// Converts an array of `UInt8` arrays into lines,
/// suitable for CSV format. Adds newline between the arrays and a newline at the end.
fileprivate func separatedLines(_ bytes: [UInt8]...) -> [UInt8] {
  return bytes.flatMap { $0 + newLineBytes }
}
