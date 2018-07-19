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
import Meteo
import DateGenerator
import SolarPosition
import Config
import Willow

let backgroundQueue = DispatchQueue(label: "serial.queue", qos: .utility)
let Log = Logger(logLevels: [.info, .error], writers: [ConsoleWriter()],
                 executionMethod: .asynchronous(queue: backgroundQueue))

let hourFraction = PerformanceCalculator.interval.fraction
let Fuelmode = ""

var dniDay = 0.0

let fm = FileManager.default

public enum PerformanceCalculator {

  static var progress = Progress(totalUnitCount: 1)
  
  public static var interval: DateGenerator.Interval = .every5minutes
  
  static let year = 2019 // meteoDataSource.year ?? 2017
  static let timeZone = meteoDataSource.timeZone ?? 0

  public static var meteoFilePath = fm.currentDirectoryPath
  
  static var meteoDataSource: MeteoDataSource = {
    do {
      if let url = URL(string: meteoFilePath), url.isFileURL {
        return try MeteoDataFileHandler(forReadingAtPath: meteoFilePath)
          .makeDataSource()
      } else if let path = try fm.subpathsOfDirectory(atPath: meteoFilePath)
        .first { $0.hasSuffix(".mto") } {
        Log.infoMessage("Meteo file found in current working directory.")
        return try MeteoDataFileHandler(forReadingAtPath: path)
          .makeDataSource()
      } else {
        Log.errorMessage("Meteo file not found in current working directory.")
        fatalError("Meteo file is mandatory for calculation.")
      }
    } catch {
      print(error)
      fatalError("Meteo file is mandatory for calculation.")
    }
  }()
  
  static var solarPosition = SolarPosition(
    location: meteoDataSource.location.doubles,
    year: year, timezone: timeZone, valuesPerHour: interval)

  public static func runModel(_ count: Int = 1) {

    Plant.location = meteoDataSource.location
    
    let meteoDataGenerator = MeteoDataGenerator(
      from: meteoDataSource, interval: interval)
        
    let dates: DateGenerator
    if let start = Simulation.time.firstDateOfOperation,
      let end = Simulation.time.lastDateOfOperation {
      let range = DateInterval(start: start, end: end)
        .align(with: interval)
      meteoDataGenerator.setRange(range)
      dates = DateGenerator(range: range, interval: interval)
    } else {
      dates = DateGenerator(year: year, interval: interval)
    }

    var demand: Ratio = 1.0
    var availableFuel = Double.greatestFiniteMagnitude
    Maintenance.atDefaultTimeRange(for: year)

    let results = PerformanceDataLogger(
      fileNameSuffix: "Run_\(count)", mode: .brief)
    results.dateFormatter = DateFormatter()

    defer {
      try! Report.description.write(
        toFile: "Report_Run\(count).txt",
        atomically: true, encoding: .utf8)
    }
    
    let runProgress = Progress(
      totalUnitCount: 12, parent: progress, pendingUnitCount: 1)
    runProgress.becomeCurrent(withPendingUnitCount: 12)
    Log.infoMessage("\nThe calculation run \(count) started.\n")
    
    defer {
      runProgress.resignCurrent()
      Log.infoMessage("\nThe calculations have been completed.\n")
    }

    Plant.configure()
    var timeStep: TimeStep = .zero
    var status = Plant.initialState
    Storage.prepare(storage: &status.storage)
    
    for (meteo, date) in zip(meteoDataGenerator, dates) {
      timeStep = .init(date)
      var meteo = meteo
      Plant.availability.set(calendar: timeStep)
      runProgress.tracking(of: timeStep.month)
      dniDay = meteoDataGenerator.sumDNI(ofDay: timeStep.day)
      
      //let isOperating = !Maintenance.isScheduled(at: date)
      
      if let altitude = solarPosition[date] {
        status.collector = Collector.tracking(sun: altitude)
        Collector.update(&status.collector, meteo: meteo)
      } else {
        meteo.noInsolation()
      }

      var timeRemain = 600.0
      SolarField.update(&status, demand: demand, timeRemain: timeRemain, meteo: meteo)
      timeRemain -= 600

      Plant.update(&status, at: timeStep, demand: 1,//demand.ratio,
                   availableFuel: &availableFuel, meteo: meteo)
      //debug(date, meteo, status)
      let (electricEnergy, electricalParasitics, thermal, fuelConsumption) =
        (Plant.electricEnergy, Plant.electricalParasitics, Plant.thermal, Plant.fuel)

      backgroundQueue.async {
        [date, meteo, status, electricEnergy, electricalParasitics, thermal, fuelConsumption] in
        results.append(
          date: date, meteo: meteo, electricEnergy: electricEnergy,
          electricalParasitics: electricalParasitics, thermal: thermal,
          fuelConsumption: fuelConsumption, status: status)
      }
      // 2.loop inside Perf. Loop: Time changes
      /* var nexttic = TimeToNTic(time)  // [s] define time to next calculation step
       var CalcTime = min(timeRemain, nexttic)   // -^-the only call -
       if date.day != Ltime.Day { checkForScheduleMaintenace(date: Date) }
       switch Control.whichOptimization { // set demand and fuel depending on calc. Mode
       case .solarOnly:
       availableFuel = 0  // Fuel for freeze protection only
       demand = 1  // Set demand to 100% nom. plant-capacity
       case .baseLoad:
       availableFuel = .greatestFiniteMagnitude
       demand = 1
       case .demand:
       availableFuel = .greatestFiniteMagnitude
       demand = Demand(time.WEHoli, month, date.hour)
       case .demand_fuel: // Dem & FuelRes
       
       // demand is defined in .DEM, Available fuel in .OPR month/tariff 12xNTariffs
       
       // predefined fuel consumption in *.pfc-file
       if Fuelmode ==  "predefined" {
       if time.minutes == 0 {
       if date.hour == 0 {
       if date.day == 1 {
       availableFuel = FuelConsumption(time.Day, date.hour, time.minutes)
       } else {
       availableFuel = FuelConsumption(time.Day - 1, 23, 50)
       }
       } else {
       availableFuel = FuelConsumption(time.Day, date.hour - 1, 50)
       }
       } else if time.minutes == 5 {
       
       if date.hour == 0 {
       
       if date.day == 1 {
       availableFuel = FuelConsumption(time.Day, date.hour, time.minutes - 5)
       } else {
       availableFuel = FuelConsumption(time.Day - 1, 23, 50)
       }
       
       } else {
       availableFuel = FuelConsumption(time.Day, date.hour - 1, 50)
       }
       } else if time.minutes == 15 || time.minutes == 25
       || time.minutes == 35 || time.minutes == 45 || time.minutes == 55 {
       availableFuel = FuelConsumption(time.Day, date.hour, time.minutes - 5 - 10)
       } else {
       availableFuel = FuelConsumption(time.Day, date.hour, time.minutes - 10)
       }
       } else {
       availableFuel = OperationRestriction(month, time.Tariff)
       }
       demand = Demand(time.WEHoli, month, date.hour)
       case .fuel:
       availableFuel = OperationRestriction(Date.Month, time.Tariff) // added, check
       }*/        // if Ctl.WhichOptim = 4 { OpRestr(month, time.Tariff) = availableFuel // Dem+Fuel
        
        //WriteOpRep(ShowOP%, StopExec%, availableFuel)
        
        // Ltime = time     // - Increase time by CalcTime% - seconds -
        //YearEnd% = Not IncrTime%(time, CalcTime%)
        
        //  if Timec.ReportBase != "Y" && CalcTime% = nexttic% { WritePCR("D") { // Timec.RepBase
        
        // timeRemain = timeRemain - CalcTime  // Decrease the remaining time and the
        // imet.period = imet.period - CalcTime%  // validity period of the meteodata
    }
    backgroundQueue.sync {
      print("\nAnnually results:\n")
      print(results.annuallyResults)
    }
  }
 
  public static func loadConfigurations(atPath path: String,
                                        format: Config.Formats) {
    do {
      switch format {
      case .json:
        try JsonConfigFileHandler.loadConfigurations(atPath: path)
      case .text:
        try TextConfigFileHandler.loadConfigurations(atPath: path)
      }
    } catch {
      print(error)
    }
  }
  
  public static func saveConfigurations(toPath path: String) {
    do {
      try JsonConfigFileHandler.saveConfigurations(toPath: path)
    } catch {
      print(error)
    }
  }
}

// Distance for HTF pipelength:   Check if allright!
//

// Imbalance = 0.05
// ImbalanceDesign = 0
// Imbalance = 0.06
// ImbalanceDesign = 0.06
/*
 //formerly INITSTARLVALS:
 PipeTemperature.SF = InitVals.TofHTFinPipes
 PipeTemperature.PB = PipeTemperature.SF
 llast = 0
 Lnow = 1
 nearLoop.now.temperature.inlet = InitVals.TofHTFinHCE
 nearLoop.now.temperature.outlet  = nearLoop.now.temperature.inlet
 avgLoop.now = nearLoop.now
 farLoop.now = nearLoop.now
 nearLoop(llast) = nearLoop.now
 avgLoop(llast) = avgLoop.now
 farLoop(llast) = farLoop.now
 designLoop.now = nearLoop.now
 designLoop(llast) = designLoop.now
 
 PowerBlock.status.temperature.inlet = PipeTemperature.PB
 PowerBlock.status.temperature.outlet  = PipeTemperature.SF
 HeatExchanger.status.temperature.inlet = PipeTemperature.PB
 HeatExchanger.status.temperature.outlet  = PipeTemperature.PB
 Storage.status.temperature.inlet = PipeTemperature.PB
 Storage.status.temperature.outlet  = PipeTemperature.PB
 TPowerBlock.status = PipeTemperature.PB
 NewData% = False: */

func dni(lat: Double, day: Int, hour: Double) -> Double {
  
  func Declination(c: Int) -> Double {
    return 23.45 * sin((360 / 365 * (Double(c) - 81)).toRadian)
  }
  
  func AM(hour: Double, day: Int, lat: Double) -> Double {
    let dec = Declination(c: day).toRadian
    let HRA = (15 * (hour - 12)).toRadian
    let elevation = asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(HRA))
    let declination = 90.toRadian - elevation
    return 1 / (1E-4 + cos(declination))
  }
  
  let dec = Declination(c: day).toRadian
  let lat = lat.toRadian
  var x = -(sin(lat) * sin(dec))
  x = x / (cos(lat) * cos(dec))
  if x > 1.0 { x = 1.0 }
  if x < -1.0 { x = -1.0 }
  let f = acos(x)
  let H = (f * 1 / 15.0).toDegree
  
  let sunrise = 12.0 - H
  let sunset = 12.0 + H
  
  var Stot = 0.0;
  if (hour > sunrise && hour < sunset) {
    let am = AM(hour: hour, day: day, lat: lat)
    let x1 = pow(0.7, am)
    Stot = Stot + 1.353 * pow(x1, 0.678)
  } else { Stot = 0 }
  if Stot > 1.1 { Stot = 0 }
  return Stot
}
