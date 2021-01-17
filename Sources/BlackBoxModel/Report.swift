// Copyright Daniel Müllenborn
// SPDX-License-Identifier: Apache-2.0

import struct Foundation.Date

extension Recording {

  func report() -> String {
    let solarField = designParameter.solarField
    let gasTurbine = designParameter.gasTurbine
    let steamTurbine = designParameter.steamTurbine
    let collector = designParameter.collector
    let layout = designParameter.layout
    let aperture = layout.solarField * 2 * collector.areaSCAnet
      * Double(solarField.numberOfSCAsInRow)
    var d = heading("PERFORMANCE RUN")
      + "\nSOLAR FIELD\n"
      + "    No of Loops:" * layout.solarField.description
      + "    Collector Type:" * collector.name.description
      + "    Aperture [m²]:" * String(format: "%G", aperture)
      + "    Massflow [kg/s]:" * String(format: "%G", solarField.maxMassFlow.rate)
      + "    Elevation [ø]:  " + "\(solarField.elevation)\t Azimut [ø]:  "
      + "\(solarField.azimut)\n"
      + "\nSTORAGE\n"
      + "    Capacity [MWH,th]:"
      * String(format: "%G", layout.storage * steamTurbine.power.max / steamTurbine.efficiencyNominal)
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
    d += heading("Annual Results")
      + "Gross electricty producution [MWh_el/a]:"
      * String(format: "%G", performance.electric.gross)
    //  Format((YTarS(0).EgrsST + YTarS(0).EgrsGasTurbine) * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Parasitic consumption [MWh_el/a]:" * String(format: "%G", performance.parasitics.shared)
    // Format(YTarS(0).electricalParasitics * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Net electricty producution [MWh_el/a]:" * String(format: "%G", performance.electric.net)
    // Format(YTarS(0).Enet * (1 - Simulation.parameter.UnSchedMain) * (1 - Simulation.parameter.TransLoss), )"
      + "Gas consumption [MWh_el/a]:\n"  // Format(YTarS(0).heatfuel, )"
      + "Solar share [%]:\n"  // Format(SolShare * 100, )"
      + "Annual direct solar insolation [kWh/m²a]:"  //  Format(YTarS(0).NDI,)"
      * String(format: "%G", radiation.dni / 1_000)
      + "Total heat from solar field [MWh_el/a]:"  // Format(YTarS(0).heatsol,)"
      * String(format: "%G", performance.thermal.solar.megaWatt)
    d += "\nAVAILABILITIES\n\n"
      + "Plant Availability [%]:\n"  // * Simulation.parameter.PlantAvail * 100, )"
      + "Plant Degradation [%]:\n"  // * Simulation.parameter.PlantDegrad,)"
      + heading("Files and Parameter")
      + "METEODATA  \(BlackBoxModel.meteoData!.name)\n"
      + "Meteodata of a leap year" * (Simulation.time.isLeapYear ? "YES" : "NO")
      + "Location:"
      * String(format: "longitude: %G, latitude: %G",
        BlackBoxModel.meteoData!.location.longitude,
        BlackBoxModel.meteoData!.location.latitude)
    //   + "Position of Wet Bulb Temp. in mto-file [row]:" * Simulation.parameter.WBTpos)"
   //    + "Position of Wind Direction in mto-file [row]:" * Simulation.parameter.WDpos)"
   //    + "Pos. of Global Direct Irr. in mto-file [row]:" * Simulation.parameter.GHI)"
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
    d += heading("OPERATION")
    let s1 = "First Date of Operation [MM.dd  HH:mm]:"
    if let firstDateOfOperation = Simulation.time.firstDateOfOperation {
      d += s1 * String(describing: firstDateOfOperation)
    } else {
      d += s1 * "01.01  00:00"
    }
    let s2 = "Last Date of Operation [MM.dd  HH:mm]:"
    if let lastDateOfOperation = Simulation.time.lastDateOfOperation {
      d += s2 * String(describing: lastDateOfOperation)
    } else {
      d += s2 * "12.31  23:59"
    }
    d += Simulation.initialValues.description
    d += "Delta T for Start-Up of Anti-Freeze Pumping:"
      * Simulation.parameter.dfreezeTemperaturePump.description
      + "Delta T for Start-Up of Anti-Freeze Heater:"
      * Simulation.parameter.dfreezeTemperatureHeat.description
      + "Minimum Insolation for Start-Up [W/m²]:"
      * Simulation.parameter.minInsolation.description
      + "Fuel strategy:" * OperationRestriction.fuelStrategy.description
    d += heading("AVAILABILITIES")
    d += Availability.current.description
      + "Periods for Scheduled Maintenance [MM.DD]:\n"  // Maintnc(1).Lowlim, ) to Format(Maintnc(1).Uplim, )"
      + "Unscheduled Maintenance [%]:\n"  // * Simulation.parameter.UnSchedMain * 100)"
    d += Plant.parameterDescriptions
    return d
  }
}