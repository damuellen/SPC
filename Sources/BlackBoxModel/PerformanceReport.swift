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

extension PerformanceLog {
  static let formatter = { dateFormatter -> DateFormatter in
    dateFormatter.calendar = calendar
    dateFormatter.dateFormat = "MM-dd  HH:mm"
    return dateFormatter
  }(DateFormatter())

  static let number = { numberFormatter -> NumberFormatter in
     return numberFormatter
  }(NumberFormatter())

  public var report: String {
    let solarField = SolarField.parameter
    let heater = Heater.parameter
    let heatExchanger = HeatExchanger.parameter
    let gasTurbine = GasTurbine.parameter
    let steamTurbine = SteamTurbine.parameter
    let collector = Collector.parameter
    
    var d: String = ""
    d += "\n"
    d += "Location: \(Plant.location.longitude) \(Plant.location.latitude)"
    d += "\n\n"
    d += "SOLAR FIELD\n"
    d += "  No of Loops:" >< "\(Design.layout.solarField)"
    d += "  Collector Type:" >< "\(collector.name)"
    let aperture = Design.layout.solarField * 2 * collector.areaSCAnet
      * Double(solarField.numberOfSCAsInRow)
    d += "  Aperture [m²]:" >< "\(aperture)"
    d += "  Massflow [kg/s]:" >< solarField.massFlow.max.rate.description
    d += "  Elevation [ø]:  " + "\(solarField.elevation)\t Azimut [ø]:  "
      + "\(solarField.azimut)"

    d += "\n"
    d += "STORAGE\n"
    d += "  Capacity [MWH,th]:"
      >< "\(Design.layout.storage * steamTurbine.power.max / steamTurbine.efficiencyNominal)"

    d += "\n"
    d += "STEAM TURBINE\n"
    d += "  Gross Output [MW]:" >< "\(steamTurbine.power.max)"
    d += "  Efficiency [%] :" >< "\(steamTurbine.efficiencyNominal * 100)"
    d += "\n"

    d += "GAS TURBINE\n"
    d += "  Gross Output [MW]:" >< "\(Design.layout.gasTurbine)"
    d += "  Efficiency [%]:" >< "\(gasTurbine.efficiencyISO * 100)"
    d += "\n"

    d += "WHR-SYSTEM\n"
    d += "  Therm Output [MW]:"
      >< "\(Design.layout.gasTurbine * (1 / gasTurbine.efficiencyISO - 1)); \(WasteHeatRecovery.parameter.efficiencyNominal)"
    d += "  Efficiency [%]:" >< "\(WasteHeatRecovery.parameter.efficiencyNominal)"
    d += "\n"

    // if let _ = Boiler.parameter.first {
    // For I% = 0 To 4: Efficiency = Efficiency + boiler.parameter.efficiency(I%): Next
    // Power = Design.layout.boiler: Efficiency = Efficiency * 100
    // }

    // Power = Design.layout.heater: Efficiency = heater.parameter.efficiency * 100

    d += "BACKUP SYSTEM\n"
    d += "  Therm.Output [MW]:\n"
    d += "  Efficiency [%]:\n"
    d += " * "
    d += "FOSSIL FUEL:\n"
    d += "  LHV [kWH/kg]: Fuel.LHV\n"
    d += "\n"
    d += "________________________________________________________________________________\n"
     d += "\n"
    d += " Annual Results \n"
    d += "\n"
    d += "\n"
    d += "Gross electricty producution [MWh_el/a]:"
      >< "\(PerformanceLog.number.string(from: NSNumber(value: annually.electric.gross))!)"
    //  Format((YTarS(0).EgrsST + YTarS(0).EgrsGasTurbine) * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Parasitic consumption [MWh_el/a]:"
      >< "\(PerformanceLog.number.string(from: NSNumber(value: annually.parasitics.shared))!)"
    // Format(YTarS(0).electricalParasitics * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Net electricty producution [MWh_el/a]:"
      >< "\(PerformanceLog.number.string(from: NSNumber(value: annually.electric.net))!)"
    // Format(YTarS(0).Enet * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Gas consumption [MWh_el/a]:\n" // Format(YTarS(0).heatfuel, )"
    d += "Solar share [%]:\n" // Format(SolShare * 100, )"
    d += "Annual direct solar insolation [kWh/m²a]:" //  Format(YTarS(0).NDI,)"
      >< "\(PerformanceLog.number.string(from: NSNumber(value: annually.dni))!)"
    d += "Total heat from solar field [MWh_el/a]:" // Format(YTarS(0).heatsol,)"
    >< "\(PerformanceLog.number.string(from: NSNumber(value: annually.thermal.solar.megaWatt))!)"
    d += "________________________________________________________________________________\n"
    d += "\n"
    d += "AVAILABILITIES\n"
    d += "\n"
    d += "Plant Availability [%]:" // >< "\(Simulation.parameter.PlantAvail * 100, )"
    d += "Plant Degradation [%]:" // >< "\(Simulation.parameter.PlantDegrad,)"
    d += "\n"
    d += "\n\n"
    d += " Input Files\n"
    d += "\n"
    d += "METEODATA  \(PerformanceCalculator.meteoDataSource.name)\n"
    d += "Meteodata of a leap year"
      >< "\(Simulation.time.isLeapYear ? "YES" : "NO")" /*
     d += "Position of Wet Bulb Temp. in mto-file [row]:" >< "\(Simulation.parameter.WBTpos)"
     d += "Position of Wind Direction in mto-file [row]:" >< "\(Simulation.parameter.WDpos)"
     d += "Pos. of Global Direct Irr. in mto-file [row]:""\(Simulation.parameter.GHI)"
     d += "\n"
     d += "Use Fuel Data from Typical Year [1: YES, 0: NO]: PFCsource\n"
     //Jn = InStrRev(Filespec.PFC, "\")
     //Bname = Mid(Filespec.PFC, Jn + 1, 40)
     //Bname = Trim(Bname)
     d += "Fuel Data file Bname\n"
     d += "\n"
     d += "Grid Availability [1: always, 2: use file]: GridAlways\n"
     //Jn = InStrRev(Filespec.GAV, "\")
     //Bname = Mid(Filespec.GAV, Jn + 1, 40)
     //Bname = Trim(Bname)
     */
    d += "\n"
    d += "Turbine is Op. at Program Start [1: YES, 0: NO]: SteamTurbine.status.Op\n"
    d += "\n"
    // if storage.Strategy = "Ful" {
    d += "Storage Strategy [1: Shifter, 0: demand] : 1\n"
    // } else {
    //  d += "Storage Strategy: [1: Shifter, 0: demand] : 0
    // }
    d += "\n\n"

    d += "if NO, use Grid Availability from File: Bname\n"
    d += "OPERATION\n"
    d += "\n"
    d += "GAS CONSUMPTION Filespec.PFC\n"

 //   d += "STORAGE"

    // if storage.tempInCst0(1) = 0 {
    // storage.TexC0to1(0) = storage.heatLossConstants0(2) - storage.TexC0to1(0)
    // storage.TexCst0(0) = storage.TexC0to1(0)
    // storage.tempInC0to1(0) = storage.heatLossConstants0(1) - storage.tempInC0to1(0)
    // storage.tempInCst0(0) = storage.tempInC0to1(0)
    // }
    //    d += "Power Block Availability [%]:" >< "\(Plant.availability[0).powerBlock * 100)"
    //      d += "Transmission Losses [%]:" >< "\(Simulation.parameter.TransLoss * 100)"
    d += "\n\n"
    d += "OPERATION\n"
    d += "\n"
    d += "First Date of Operation [MM.dd  HH:mm]:                             "
    if let firstDateOfOperation = Simulation.time.firstDateOfOperation {
      d += PerformanceLog.formatter.string(from: firstDateOfOperation) + .lineBreak
    } else {
      d += "01.01  00:00\n"
    }
    d += "Last Date of Operation [MM.dd  HH:mm]:                              "
    if let lastDateOfOperation = Simulation.time.lastDateOfOperation {
      d += PerformanceLog.formatter.string(from: lastDateOfOperation) + .lineBreak
    } else {
      d += "12.31  23:59\n"
    }
    d += "HTF Temperature in Header [°C]:"
      >< "\(Simulation.initialValues.temperatureOfHTFinPipes.celsius)"
    d += "HTF Temperature in Collector [°C]:"
      >< "\(Simulation.initialValues.temperatureOfHTFinHCE.celsius)"
    d += "Mass Flow in Solar Field [kg/s]:"
      >< "\(Simulation.initialValues.massFlowInSolarField.rate)"
    d += "Delta T for Start-Up of Anti-Freeze Pumping:"
      >< "\(Simulation.parameter.dfreezeTemperaturePump.celsius)"
    d += "Delta T for Start-Up of Anti-Freeze Heater:"
      >< "\(Simulation.parameter.dfreezeTemperatureHeat.celsius)"
    d += "Minimum Insolation for Start-Up [W/m²]:"
      >< "\(Simulation.parameter.minInsolation)"
    d += "Fuel strategy:\t\(Fuelmode)I\n"
    d += "\n\n"
    d += "AVAILABILITIES\n"
    d += "\n"
    d += "Annual Average Solar Field Availability [%]:"
      >< "\(Plant.availability.values.solarField.percentage)"
    d += "Average Percentage of Broken HCE [%]:"
      >< "\(Plant.availability.values.breakHCE.percentage)"
    d += "Average Percentage of HCE with Lost Vacuum [%]:"
      >< "\(Plant.availability.values.airHCE.percentage)"
    d += "Average Percentage of Flourescent HCE [%]:"
      >< "\(Plant.availability.values.fluorHCE.percentage)"
    d += "Average Mirror Reflectivity [%]:"
      >< "\(Plant.availability.values.reflMirror.percentage)"
    d += "Broken Mirrors [%]:"
      >< "\(Plant.availability.values.missingMirros.percentage)"
    d += "Periods for Scheduled Maintenance [MM.DD]:\n" // Maintnc(1).Lowlim, ) to Format(Maintnc(1).Uplim, )"
    d += "Unscheduled Maintenance [%]:\n" // >< "\(Simulation.parameter.UnSchedMain * 100)"
    d += "________________________________________________________________________________\n"
    d += "\n\n"
    d += " Fixed Parameter\n"
    d += "\n\n"
    d += "HEATER\n\n"
    d += String(describing: heater)
    d += "\n"
    d += "HEAT EXCHANGER\n\n"
    d += String(describing: heatExchanger)
    d += "\n"
    d += "STEAM TURBINE\n\n"
    d += String(describing: steamTurbine)
    d += "\n"
    d += "SOLAR FIELD\n\n"
    d += String(describing: solarField)
    d += "\n"
    d += "COLLECTOR\n\n"
    d += String(describing: collector)
    d += "\n"
    d += "HEAT TRANSFER FLUID\n\n"
    d += String(describing: solarField.HTF)
    d += "\n\n"
    return d
  }
}
