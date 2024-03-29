// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Utilities

/// Represents the performance report of a simulation.
extension Recording {
    
  /// Generates a formatted performance report for the simulation.
  ///
  /// - Returns: The formatted performance report as a string.
  func report() -> String {
    let solarField = designParameter.solarField
    let gasTurbine = designParameter.gasTurbine
    let steamTurbine = designParameter.steamTurbine
    let collector = designParameter.collector
    let layout = designParameter.layout
    let aperture = layout.solarField * 2 * collector.areaSCAnet
      * Double(solarField.numberOfSCAsInRow)
    var d: String = decorated("PERFORMANCE RUN")
      + "\nSOLAR FIELD\n"
      + "    No of Loops:" * layout.solarField.description
      + "    Collector Type:" * collector.name.description
      + "    Aperture [m²]:" * aperture.scientificFormatted
      + "    Massflow [kg/s]:" * solarField.maxMassFlow.rate.scientificFormatted
      + "    Elevation [ø]:  " + "\(solarField.elevation)\t Azimut [ø]:  "
      + "\(solarField.azimut)\n"
      + "\nSTORAGE\n"
      + "    Capacity [MWH,th]:"
      * (layout.storageHours * steamTurbine.power.max / steamTurbine.efficiencyNominal).scientificFormatted
      + "\nSTEAM TURBINE\n"
      + "    Gross Output [MW]:" * steamTurbine.power.max.description
      + "    Efficiency [%] :" * (steamTurbine.efficiencyNominal * 100).description
      + "\nGAS TURBINE\n"
      + "    Gross Output [MW]:" * layout.gasTurbine.description
      + "    Efficiency [%]:" * (gasTurbine.efficiencyISO * 100).description
      + "\nWHR-SYSTEM\n"
      + "    Therm Output [MW]:"
      * "\(layout.gasTurbine * (1 / gasTurbine.efficiencyISO - 1)); \(WasteHeatRecovery.parameter.efficiencyNominal)"
      + "    Efficiency [%]:" * WasteHeatRecovery.parameter.efficiencyNominal.description
    // if let _ = Boiler.parameter.first {
    // For I% = 0 To 4: Efficiency = Efficiency + boiler.parameter.efficiency(I%): Next
    // Power = Design.layout.boiler: Efficiency = Efficiency * 100
    // }
    // Power = Design.layout.heater: Efficiency = heater.parameter.efficiency * 100
      + "\nBACKUP SYSTEM\n"
      + "    Therm.Output [MW]:\n"
      + "    Efficiency [%]:\n"
      + " * "
      + "FOSSIL FUEL:\n"
      + "    LHV [kWH/kg]: Fuel.LHV\n"
      + "\n\n"
    d += decorated("Annual Results") + "\n"
      + "Gross electricty production [MWh_el/a]:"
      * performance.electric.gross.scientificFormatted
    //  Format((YTarS(0).EgrsST + YTarS(0).EgrsGasTurbine) * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Parasitic consumption [MWh_el/a]:" * performance.parasitics.shared.scientificFormatted
    // Format(YTarS(0).electricalParasitics * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Net electricty production [MWh_el/a]:" * performance.electric.net.scientificFormatted
    // Format(YTarS(0).Enet * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Gas consumption [MWh_el/a]:\n"  // Format(YTarS(0).heatfuel, )"
      + "Solar share [%]:\n"  // Format(SolShare * 100, )"
      + "Annual direct solar insolation [kWh/m²a]:"  //  Format(YTarS(0).NDI,)"
      * (irradiance.direct / 1_000).scientificFormatted
      + "Total heat from solar field [MWh_el/a]:"  // Format(YTarS(0).heatsol,)"
      * performance.thermal.solar.megaWatt.scientificFormatted
    d += "\nAVAILABILITIES\n\n"
      + "Plant Availability [%]:\n"  // * Simulation.parameter.PlantAvail * 100, )"
      + "Plant Degradation [%]:\n"  // * Simulation.parameter.PlantDegrad,)"
      + decorated("Files and Parameter") + "\n"
      + "Meteodata of a leap year" * (Simulation.time.isLeapYear ? "YES" : "NO")
      + "Location:"
      * String(format: "longitude: %G, latitude: %G",
        BlackBoxModel.sun!.location.longitude,
        BlackBoxModel.sun!.location.latitude)
       + "\n"
       + "Use Fuel Data from Typical Year [1: YES, 0: NO]: PFCsource\n"
     //Jn = InStrRev(Filespec.PFC, "\")
     //Bname = Mid(Filespec.PFC, Jn + 1, 40)
     //Bname = Trim(Bname)
       + "Fuel Data file Bname\n"
       + "\n"
       + "Grid Availability [1: always, 2: use file]: GridAlways\n"
     //Jn = InStrRev(Filespec.GAV, "\")
     //Bname = Mid(Filespec.GAV, Jn + 1, 40)
     //Bname = Trim(Bname)
     
      + "\n"
      + "Turbine is Op. at Program Start [1: YES, 0: NO]: SteamTurbine.status.Op\n"
      + "\n"
    // if storage.Strategy = "Ful" {
      + "Storage Strategy [1: Shifter, 0: demand] : 1\n"
    // } else {
    //  d += "Storage Strategy: [1: Shifter, 0: demand] : 0
    // }
      + "\n"
      + "if NO, use Grid Availability from File: Bname\n"
      + "OPERATION\n\n"
      + "GAS CONSUMPTION Filespec.PFC\n"
    //   d += "STORAGE"
    // if storage.tempInCst0(1) = 0 {
    // storage.TexC0to1(0) = storage.heatLossConstants0(2) - storage.TexC0to1(0)
    // storage.TexCst0(0) = storage.TexC0to1(0)
    // storage.tempInC0to1(0) = storage.heatLossConstants0(1) - storage.tempInC0to1(0)
    // storage.tempInCst0(0) = storage.tempInC0to1(0)
    // }
    //      + "Power Block Availability [%]:" * Availability.current[0).powerBlock * 100)"
    //        + "Transmission Losses [%]:" * Simulation.parameter.TransLoss * 100)"
    d += decorated("OPERATION") + "\n"
    let s1 = "First Date of Operation:"
    if let firstDateOfOperation = Simulation.time.dateInterval?.start {
      d += s1 * DateTime(firstDateOfOperation).calendarDay
    } else {
      d += s1 * "New Year"
    }
    let s2 = "Last Date of Operation:"
    if let lastDateOfOperation = Simulation.time.dateInterval?.end {
      d += s2 * DateTime(lastDateOfOperation).calendarDay
    } else {
      d += s2 * "Silvester"
    }
    d += Simulation.initialValues.description
    d += "Delta T for Start-Up of Anti-Freeze Pumping:"
      * Simulation.parameter.deltaFreezeTemperaturePump.description
      + "Delta T for Start-Up of Anti-Freeze Heater:"
      * Simulation.parameter.deltaFreezeTemperatureHeat.description
      + "Minimum Insolation for Start-Up [W/m²]:"
      * Simulation.parameter.minInsolation.description
      + "Fuel strategy:" * OperationRestriction.fuelStrategy.description
    d += decorated("AVAILABILITIES") + "\n"
    d += Availability.current.description
      + "Periods for Scheduled Maintenance [MM.DD]:\n"  // Maintnc(1).Lowlim, ) to Format(Maintnc(1).Uplim, )"
      + "Unscheduled Maintenance [%]:\n"  // * Simulation.parameter.UnSchedMain * 100)"
    d += Plant.parameterDescriptions
    return d
  }
}

extension Double {
  /// Represents the value in scientific notation.
  var scientificFormatted: String { String(format: "%G", self) }
}