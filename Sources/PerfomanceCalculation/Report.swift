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
import Dispatch
import Config

public enum Report {
  
  static let dateFormatter = { dateFormatter -> DateFormatter in
    dateFormatter.calendar = calendar
    dateFormatter.dateFormat = "MM.dd  HH:mm"
    return dateFormatter
  }(DateFormatter())
  
  public static var description: String {
    var d = "PROJECT:"
    
    d += " BlaBla\n"
    d += "\n"
    d += "Location: \(Plant.location.longitude) \(Plant.location.latitude)"
    d += "Simulation Ref:\n"//ProjectFilePath(0)"
    d += "Performance Run:\n"//(NSDate())"
    d += "Program-Version:\n"//t0.1\n"
    // if let SolarField.status = SolarField.status {
    d += "SOLAR FIELD\n"
    d += "  No of Loops:" >< "\(Design.layout.solarField)"
    d += "  Collector Type:" >< "\(Collector.parameter.name))"
    let aperture = Design.layout.solarField * 2 * Collector.parameter.areaSCAnet
      * Double(SolarField.parameter.numberOfSCAsInRow)
    d += "  Aperture [m²]:" >< "\(aperture)"
    d += "  Massflow [kg/s]:" >< "\(SolarField.parameter.massFlow.max)"
    d += "  Elevation [ø]:" + "\(SolarField.parameter.elev) Azimut [ø]:\t"
      + "\(SolarField.parameter.azim)"
    // }
    // let storage = Storage.parameter
    d += "\n"
    d += "STORAGE\n"
    d += "  Capacity [MWH,th]:" >< "\(Design.layout.storage * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal)"
    
    d += "\n"
    d += "STEAM TURBINE\n"
    d += "  Gross Output [MW]:" >< "\(SteamTurbine.parameter.power.max)"
    d += "  Efficiency [%] :" >< "\(SteamTurbine.parameter.efficiencyNominal * 100)"
    d += "\n"
    
    d += "GAS TURBINE\n"
    d += "  Gross Output [MW]:" >< "\(Design.layout.gasTurbine)"
    d += "  Efficiency [%]:" >< "\(GasTurbine.parameter.efficiencyISO * 100)"
    d += "WHR- SYSTEM\n"
    d += "  Therm Output [MW]:"
      >< "\(Design.layout.gasTurbine * (1 / GasTurbine.parameter.efficiencyISO - 1)); \(WasteHeatRecovery.parameter.efficiencyNominal)"
    d += "  Efficiency [%]:\t\t WasteHeatRecovery.parameter.effnom\n"
    d += "\n"
    
    // if let _ = Boiler.parameter.first {
    // For I% = 0 To 4: Efficiency = Efficiency + boiler.parameter.efficiency(I%): Next
    // Power = Design.layout.boiler: Efficiency = Efficiency * 100
    // }
    
    // Power = Design.layout.heater: Efficiency = heater.parameter.efficiency * 100
    
    d += "BACKUP SYSTEM"
    d += "  Therm.Output [MW]:\tPower\n"
    d += "  Efficiency [%]:\t\tEfficiency\n"
    d += " * "
    d += "FOSSIL FUEL:\t(Fuel.Name)"
    d += "  LHV [kWH/kg]: Fuel.LHV\n"
    d += "\n"
    d += "\n"
    d += "    Annual Results \n"
    d += "   String$(16, )"
    d += "\n"
    d += "\n"
    d += "Gross electricty prodcution [MWh_el/a]:\n"  //  Format((YTarS(0).EgrsST + YTarS(0).EgrsGasTurbine) * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Parasitic consumption [MWh_el/a]:\n" // Format(YTarS(0).electricalParasitics * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Net electricty prodcution [MWh_el/a]:\n" // Format(YTarS(0).Enet * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
    d += "Gas consumption [MWh_el/a]:\n" // Format(YTarS(0).heatfuel, )"
    d += "Solar share [%]:" //Format(SolShare * 100, )"
    d += "Annual direct solar insolation [kWh/m²a]:\n"//  Format(YTarS(0).NDI,)"
    d += "Total heat from solar field [MWh_el/a]:\n"// Format(YTarS(0).heatsol,)"
    d += "________________________________________________________________________________\n"
    d += "\n\n\n"
    d += "    Input Files\n"
    d += "   -\n"
    d += "\n\n"
    d += "METEODATA  Filespec.MTO\n"
    d += "GAS CONSUMPTION Filespec.PFC\n"
    d += "\n\n\n"
    d += "    Variable Input Parameter\n"
    d += "   \n"
    d += "\n\n"
    d += "STORAGE"
    
    // if Storage.parameter.tempInCst0(1) = 0 {
    // Storage.parameter.TexC0to1(0) = Storage.parameter.heatLossConstants0(2) - Storage.parameter.TexC0to1(0)
    // Storage.parameter.TexCst0(0) = Storage.parameter.TexC0to1(0)
    // Storage.parameter.tempInC0to1(0) = Storage.parameter.heatLossConstants0(1) - Storage.parameter.tempInC0to1(0)
    // Storage.parameter.tempInCst0(0) = Storage.parameter.tempInC0to1(0)
    // }
    
    d += "\n"
    // if let heater = Heater.shared.parameter.first {
    d += "HEATER\n\n"
    //   d += heater.description
    d += "\n\n"
    // }
    //   if Design.heatExchanger {
    d += "HEAT EXCHANGER\n\n"
    //   d += heatExchanger.description
    d += "\n"
    // }
    // if let turbine = SteamTurbine.shared.parameter.first {
    d += "STEAM TURBINE\n\n"
    //     d += turbine.description
    d += "\n"
    // }
    //    d += "Power Block Availability [%]:" >< "\(Plant.availability[0).powerBlock * 100)"
    //      d += "Transmission Losses [%]:" >< "\(Simulation.parameter.TransLoss * 100)"
    d += "\n\n"
    d += "OPERATION\n"
    d += "\n"
    d += "First Date of Operation [MM.dd  HH:mm]:                             "
    if let firstDateOfOperation = Simulation.time.firstDateOfOperation {
      d += dateFormatter.string(from: firstDateOfOperation) + "\n"
    } else {
      d += "01.01  00:00\n"
    }
    d += "Last Date of Operation [MM.dd  HH:mm]:                              "
    if let lastDateOfOperation = Simulation.time.lastDateOfOperation {
      d += dateFormatter.string(from: lastDateOfOperation) + "\n"
    } else {
      d += "12.31  23:59\n"
    }
    d += "HTF Temperature in Header [°C]:"
      >< "\(Simulation.initialValues.temperatureOfHTFinPipes.toCelsius)"
    d += "HTF Temperature in Collector [°C]:"
      >< "\(Simulation.initialValues.temperatureOfHTFinHCE.toCelsius)"
    d += "Mass Flow in Solar Field [kg/s]:"
      >< "\(Simulation.initialValues.massflowInSolarField.toCelsius)"
    d += "Delta T for Start-Up of Anti-Freeze Pumping:"
      >< "\(Simulation.parameter.dfreezeTemperaturePump)"
    d += "Delta T for Start-Up of Anti-Freeze Heater:"
      >< "\(Simulation.parameter.dfreezeTemperatureHeat)"
    d += "Minimum Insolation for Start-Up [W/m²]:"
      >< "\(Simulation.parameter.minInsolation)"
    d += "Fuel strategy (0=predefined, 1=strategy) :\tFuelmodeI\n"
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
    d += "Periods for Scheduled Maintenance [MM.DD]:\n" //Maintnc(1).Lowlim, ) to Format(Maintnc(1).Uplim, )"
    d += "Unscheduled Maintenance [%]:\n" //>< "\(Simulation.parameter.UnSchedMain * 100)"
    d += "\n"
    d += "________________________________________________________________________________\n"
    d += "\n\n"
    d += "    Fixed Parameter\n"
    d += "\n\n"
    
    d += "SOLAR FIELD\n\n"
    d += SolarField.parameter.description
    d += "\n"
    
    d += "COLLECTOR\n\n"
    d += "\(Collector.parameter.description)"
    d += "\n\n"
    d += "    Input Files"
    d += "\n\n"
    //Jn = InStrRev(Filespec.MTO, "\")
    //Bname = Mid(Filespec.MTO, Jn + 1, 40)
    //Bname = Trim(Bname)
    d += "METEODATA Bname\n"
    
    
    d += "Meteodata of a leap year"
      >< "\(Simulation.time.isLeapYear ? "YES" : "NO")"    /*
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
    d += "if NO, use Grid Availability from File: Bname\n"
    d += "\n"
    d += "    Variable Input Parameter\n"
    d += "   \n"
    d += "\n\n"
    d += "OPERATION\n"
    d += "\n"
    
    d += "\n"
    d += "Turbine is Op. at Program Start [1: YES, 0: NO]: SteamTurbine.status.Op\n"
    d += "\n"
    // if Storage.parameter.Strategy = "Ful" {
    d += "Storage Strategy [1: Shifter, 0: demand] : 1\n"
    // } else {
    //  d += "Storage Strategy: [1: Shifter, 0: demand] : 0
    // }
    d += "\n\n"
    d += "AVAILABILITIES\n"
    d += "\n"
    d += "Plant Availability [%]:" //>< "\(Simulation.parameter.PlantAvail * 100, )"
    d += "Plant Degradation [%]:" //>< "\(Simulation.parameter.PlantDegrad,)"
    d += "\n"
    return d
  }
}

