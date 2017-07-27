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
import Meteo
import DateGenerator
import SolarPosition
import Config
var Fuelmode = ""

var DNIdaysum = 0.0

let fm = FileManager.default

public enum PerfomanceCalculator {
  
  public static var progress = Progress(totalUnitCount: 12)
  
  public static var interval: DateGenerator.Interval = .every5minutes
  
  public static var meteoFilePath = fm.currentDirectoryPath
  
  public static func loadConfigurations(atPath path: String,
                                        format: Config.Formats) {
    ParameterDefaults.assign()
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

  public static func run() {
    
    let meteoDateSource: MeteoDataSource
    do {
      if let url = URL(string: meteoFilePath), url.isFileURL {
        meteoDateSource = try MeteoDataFileHandler(
          forReadingAtPath: meteoFilePath).readContentOfFile()
      } else if let path = try fm.subpathsOfDirectory(atPath: meteoFilePath)
        .first { $0.hasSuffix(".mto") } {
        meteoDateSource = try MeteoDataFileHandler(
          forReadingAtPath: path).readContentOfFile()
        print("Meteo file found in current working directory.")
      } else {
        print("Meteo file not found in current working directory.")
        fatalError("Meteo file is mandatory for calculation.")
      }
      
    } catch {
      print(error)
      fatalError("Meteo file is mandatory for calculation.")
    }
    
    let meteoData = MeteoDataGenerator(
      from: meteoDateSource, interval: interval)
    
    let year = meteoDateSource.year ?? 2017
    let timeZone = meteoDateSource.timeZone ?? 0
    
    let dates: DateGenerator
    if let start = Simulation.time.firstDateOfOperation,
      let end = Simulation.time.lastDateOfOperation {
      let range = DateInterval(start: start, end: end).align(with: interval)
      meteoData.setRange(to: range)
      dates = DateGenerator(range: range, interval: interval)
    } else {
      dates = DateGenerator(year: year, interval: interval)
    }
    
    Plant.location = meteoDateSource.location
    let locationTuple = (Plant.location.longitude,
                         Plant.location.latitude,
                         Plant.location.elevation)
    
    let solarPosition = SolarPosition(
      location: locationTuple, year: year,
      timezone: timeZone, valuesPerHour: interval)
    
    var demand: Ratio = 1.0
    var availableFuel = Double.greatestFiniteMagnitude
    
    let outputStream = OutputStream(
      toFileAtPath: "HourlyResults.csv", append: false)!
    
    let results = PerfomanceData()
    
    results.dateFormatter = DateFormatter()
    results.outputStream = outputStream
    
    defer {
      try! Report.description.write(
        toFile: "Report.txt", atomically: true, encoding: .utf8)
      outputStream.close()
    }
    
    prepareModels()
    progress.becomeCurrent(withPendingUnitCount: 12)
    defer { progress.resignCurrent() }
    
    for (meteo, date) in zip(meteoData, dates) {
      progress.tracking(date: date)
      if let sun = solarPosition[date] {
        Collector.tracking(&Collector.status, sun: sun)
      }
      var timeRemain = 600.0
      solarField(&SolarField.status,
                 demand: demand,
                 date: date,
                 timeRemain: timeRemain,
                 meteo: meteo)
      
      
      while timeRemain > 0 { // "" 2.loop inside Perf. Loop: Time changes """""
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
         if date.day == 13 && date.hour == 0 && time.minutes == 0 {
         i = 1
         }
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
         }*/
        
        Plant.operate(demand: demand.value,
                      availableFuel: &availableFuel,
                      boiler:  &Boiler.status,
                      powerBlock: &PowerBlock.status,
                      solarField: &SolarField.status,
                      steamTurbine: &SteamTurbine.status,
                      heater: &Heater.status,
                      heatExchanger: &HeatExchanger.status,
                      storage: &Storage.status,
                      date: date, meteo: meteo)
        
        
        results.add(date: date, meteo: meteo,
                    electricEnergy: Plant.electricEnergy,
                    electricalParasitics: Plant.electricalParasitics,
                    heatFlow: Plant.heatFlow,
                    fuelConsumption: Plant.fuel,
                    solarfield: SolarField.status,
                    collector: Collector.status)
        
        /*
         if CalcTime / 3_600 = 1 / 6 {
         i = i
         } else if CalcTime / 3_600 = 1 / 12 {
         i = i
         } else {
         i = i
         }*/
        
        //  SumUpPCR(CalcTime% / 3_600, availableFuel) // fraction of an hour ->
        // if Ctl.WhichOptim = 4 { OpRestr(month, time.Tariff) = availableFuel // Dem+Fuel
        
        //WriteOpRep(ShowOP%, StopExec%, availableFuel)
        
        // Ltime = time     // - Increase time by CalcTime% - seconds -
        //YearEnd% = Not IncrTime%(time, CalcTime%)
        
        //  if Timec.ReportBase != "Y" && CalcTime% = nexttic% { WritePCR("D") { // Timec.RepBase
        
        // timeRemain = timeRemain - CalcTime  // Decrease the remaining time and the
        // imet.period = imet.period - CalcTime%  // validity period of the meteodata
        timeRemain -= 600
      }
    }
  }
  
  private static func checkForScheduleMaintenace(at date: Date) {
    /*
     CurrDate = month + monthDay / 100
     for i in 1 ... 6 {// 6 Different Maintenance Periods
     steamTurbine.isMaintained = (Maintnc(i).Lowlim <= CurrDate && CurrDate <= Maintnc(i).Uplim)
     }
     if !steamTurbine.isMaintained {      // Check up to 25 excluded days:
     if ExclDays(1) != 0 {
     for i in 1 ... 25 {
     steamTurbine.isMaintained = (CurrDate = ExclDays(i))
     if steamTurbine.isMaintained {
     }
     
     }  // ExclDays(1) != 0 THEN
     }
     
     }  // NOT steamTurbine.isMaintained THEN
     // new: - Because Heat Production only does not make sense
     SolarField.status.isMaintained = steamTurbine.isMaintained
     Heater.status.isMaintained = steamTurbine.isMaintained
     Boiler.status.isMaintained = steamTurbine.isMaintained
     GasTurbine.status.isMaintained = steamTurbine.isMaintained
     */
  }
  
  private static func solarField(
    _ solarField: inout SolarField.PerformanceData,
    demand: Ratio, date: Date, timeRemain: Double, meteo: MeteoData) {
    
    if Design.hasStorage {
      switch Storage.status.operationMode {
      case .freezeProtection:
        if Storage.parameter.tempInCst[1] > 0 {
          solarField.header.temperature.inlet = solarField.header.temperature.outlet
        } else {
          solarField.header.temperature.inlet = Storage.status.StoTcoldTout
        }
      case .sc:
        solarField.header.temperature.inlet = Storage.status.temperatureTank.cold
      case .charging where Plant.heatFlow.production == 0:
        solarField.header.temperature.inlet = solarField.header.temperature.outlet
      default:
        solarField.header.temperature.inlet = PowerBlock.status.temperature.outlet
      }
    } else {
      solarField.header.temperature.inlet = PowerBlock.status.temperature.outlet
    }
    
    Plant.heatFlow.dump = 0
    
    solarField.header.massFlow = SolarField.parameter.massFlow.max
    
    if demand.value < 1 { // added to reduced SOF massflow with electrical demand
      
      solarField.header.massFlow = demand.value * (SteamTurbine.parameter.power.max
        / SteamTurbine.parameter.efficiencyNominal
        / HeatExchanger.parameter.efficiency)
        / (htf.heatTransfered(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
      
      solarField.header.massFlow = max(
        1180, solarField.header.massFlow + Storage.parameter.massFlow)
    }
    
    if Design.hasStorage,
      Storage.status.heatrel >= Storage.parameter.chargeTo {
      if Design.hasGasTurbine {
        solarField.header.massFlow = HeatExchanger.parameter.SCCHTFmassFlow
      } else {
        // changed to reduced SOF massflow with electrical demand
        solarField.header.massFlow = demand.value
          * (SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal
            / HeatExchanger.parameter.efficiency)
          / (htf.heatTransfered(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
      }
    }
    
    SolarField.calculate(date: date, meteo: meteo, timeRemain: timeRemain,
                         solarField: &solarField)
    
    // the next is added to determine temperature drop in hot header
    var temperatureNow = solarField.header.temperature.outlet
    var temperatureLast = 0.0
    
    for _ in 1 ... 10 {
      
      solarField.heatLossHeader *= SolarField.parameter.heatLossHeader[0]
      // FIXME  + SolarField.parameter.heatLossHeader
      // FIXME  * (temperatureNow - meteo.temperature) // [MWt]
      solarField.heatLossHeader *= 1_000_000
        / (Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet)
      // for hourly results and night cooldown [W/m2 ap.]
      let temp = temperatureLast
      temperatureLast = temperatureNow
      temperatureNow = temp
      
      if solarField.header.massFlow > 0 {
        
        let dQHL = solarField.heatLossHeader * 1_000 / solarField.header.massFlow // [kJ/kg]
        temperatureNow = htf.temperature(-dQHL, solarField.header.temperature.outlet)
        
      } else {
        
        let averageTemperature = (temperatureNow + solarField.header.temperature.outlet) / 2
        // Calculate average Temp. and Areadens
        let areadens = htf.density(averageTemperature) * .pi
          * Collector.parameter.rabsInner ** 2 / Collector.parameter.aperture // kg/m2
        let dQperSqm = solarField.heatLossHeader  // FIXME * dtime / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let dQperkg = dQperSqm / areadens // Change kJ/sqm to kJ/kg:
        let Qperkg = htf.heatTransfered(
          solarField.header.temperature.outlet, Double(meteo.temperature))
        temperatureNow = htf.temperature(Qperkg - dQperkg, Double(meteo.temperature))
      }
      
      temperatureNow = min(htf.maxTemperature, temperatureNow)
      temperatureLast = min(htf.maxTemperature, temperatureLast)
      let temperatureDifference = abs(temperatureNow - temperatureLast)
      if temperatureDifference < Simulation.parameter.HLtempTolerance {
        break
      }
    }
    solarField.header.temperature.outlet = temperatureNow
  }
  
  private static func prepareGasTurbine() {
    HeatExchanger.parameter.SCCHTFheat = Design.layout.heatExchanger
      / SteamTurbine.parameter.efficiencySCC / HeatExchanger.parameter.SCCEff
    
    SolarField.parameter.massFlow.max = HeatExchanger.parameter.SCCHTFheat * 1_000
      / htf.heatTransfered(HeatExchanger.parameter.scc.htf.outlet.max,
                           HeatExchanger.parameter.scc.htf.inlet.max)
    
    WasteHeatRecovery.parameter.ratioHTF = HeatExchanger.parameter.SCCHTFheat
      / (SteamTurbine.parameter.power.max - HeatExchanger.parameter.SCCHTFheat)
  }
  
  private static func prepareModels() {
    // Turbine Gross Power is no longer an input parameter.
    // It is now calculated from Design.layout.powerBlock plus parasitics
    // old TB files can still be used. From now 0 is put in as Gross Power in the TB files
    if SteamTurbine.parameter.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + PowerBlock.parameter.fixelectricalParasitics
        + PowerBlock.parameter.nominalElectricalParasitics
        + PowerBlock.parameter.electricalParasiticsStep[1]
    }
    
    if Design.hasGasTurbine {
      prepareGasTurbine()
    } else {
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        HeatExchanger.parameter.SCCHTFheat = Design.layout.heatExchanger
          / SteamTurbine.parameter.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      } else {
        HeatExchanger.parameter.SCCHTFheat = SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      }
      SolarField.parameter.massFlow.max = HeatExchanger.parameter.SCCHTFheat * 1_000
        / htf.heatTransfered(HeatExchanger.parameter.temperature.htf.inlet.max,
                             HeatExchanger.parameter.temperature.htf.outlet.max)
    }
    
    if Design.hasSolarField {
      SolarField.parameter.EdgeFac += SolarField.parameter.distanceSCA / 2
        * (1 - 1 / Double(SolarField.parameter.numberOfSCAsInRow)
          / Collector.parameter.lengthSCA) // Constants
      SolarField.parameter.EdgeFac += (1.0 + 1.0
        / Double(SolarField.parameter.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA / 2
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
