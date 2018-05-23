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
import Config

extension HeatExchanger {
  public struct Parameter: ComponentParameter {
    public struct Temperatures {
      let htf: (inlet: (max: Temperature, min: Temperature),
      outlet: (max: Temperature, min: Temperature))
      var h2o: (inlet: (max: Temperature, min: Temperature),
      outlet: (max: Temperature, min: Temperature))
      
      public init(
        htf: (inlet: (max: Double, min: Double),
        outlet: (max: Double, min: Double)),
        h2o: (inlet: (max: Double, min: Double),
        outlet: (max: Double, min: Double))) {
        
        self.htf = ((Temperature(celsius: htf.inlet.max),
                     Temperature(celsius: htf.inlet.min)),
                    (Temperature(celsius: htf.outlet.max),
                     Temperature(celsius: htf.outlet.min)))
        self.h2o = ((Temperature(celsius: h2o.inlet.max),
                     Temperature(celsius: h2o.inlet.min)),
                    (Temperature(celsius: h2o.outlet.max),
                     Temperature(celsius: h2o.outlet.min)))
      }
    }
    
    let name: String
    let efficiency: Double
    let SCCEff: Double
    var temperature: Temperatures
    let scc: Temperatures
    let SCCHTFmassFlow: MassFlow
    var SCCHTFthermal: Double
    var ToutMassFlow: Coefficients?
    var ToutTin: Coefficients?
    var ToutTinMassFlow: Coefficients?
    var useAndsolFunction, Tout_f_Mfl, Tout_f_Tin, Tout_exp_Tin_Mfl: Bool
  }
}

extension HeatExchanger.Parameter: CustomStringConvertible {
  public var description: String {
    var d = ""
    d += "Description:\t\(name)\n"
    d += "Parameter for Steam Cycle\n"
    d += "Efficiency [%]:"
      >< "\(efficiency * 100)"
    d += "Maximum Inlet Temperature  [°C]:"
      >< "\(temperature.htf.inlet.max.celsius)"
    d += "Maximum Outlet Temperature [°C]:"
      >< "\(temperature.htf.outlet.max.celsius)"
    d += "Minimum Inlet Temperature  [°C]:"
      >< "\(temperature.htf.inlet.min.celsius)"
    d += "Minimum Outlet Temperature [°C]:"
      >< "\(temperature.htf.outlet.min.celsius)"
    d += "Calculate Outlet Temp. as function of HTF Massflow:"
      >< (Tout_f_Mfl ? "YES" : "NO ")
    if Tout_f_Mfl, ToutMassFlow != nil  {
      for (i, c) in ToutMassFlow!.coefficients.enumerated() {
        d += "c\(i):" >< String(format:"%.4E", c)
      }
    }
    d += "Calculate Outlet Temp. as function of HTF Inlet Temp.:"
      >< (Tout_f_Tin ? "YES" : "NO ")
    if Tout_f_Tin, ToutTin != nil {
      for (i, c) in ToutTin!.coefficients.enumerated() {
        d += "c\(i):" >< String(format:"%.4E", c)
      }
    }
    d += "Calculate Outlet Temp. as Andasol-3 Function.:"
      >< (useAndsolFunction ? "YES" : "NO ")
    d += "Calculate Outlet Temp. as f(Tin,Mfl):"
      >< (Tout_exp_Tin_Mfl ? "YES" : "NO ")
    if Tout_exp_Tin_Mfl, ToutTinMassFlow != nil {
      for (i, c) in ToutTinMassFlow!.coefficients.enumerated() {
        d += "c\(i):" >< String(format:"%.4E", c)
      }
    }
    // d += "not used:" HXc.H2OinTmax
    // d += "not used:" HXc.H2OinTmin
    // d += "not used:" HXc.H2OoutTmax - TK0
    // d += "not used:" HXc.H2OoutTmin - TK0
    d += "Parameter for ISCCS Cycle\n"
    d += "Efficiency [%]:"
      >< "\(SCCEff)"
    d += "Maximum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.max.celsius)"
    d += "Maximum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.max.celsius)"
    d += "Minimum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.min.celsius)"
    d += "Minimum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.min.celsius)"
    // d += "not used:" HXc.SCCH2OinTmax - TK0
    // d += "not used:" HXc.SCCH2OinTmin - TK0
    // d += "not used:" HXc.SCCH2OoutTmax - TK0
    // d += "not used:" HXc.SCCH2OoutTmin - TK0
    d += "Nominal HTF Mass Flow [kg/s]:"
      >< "\(SCCHTFmassFlow.rate)"
    d += "Nominal Capacity [MW]:"
      >< String(format:"%.3f", SCCHTFthermal)
    return d
  }
}

extension HeatExchanger.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.efficiency = try row(10)
    self.temperature = try Temperatures(
      htf: (inlet: (max: row(13).toKelvin, min: row(16).toKelvin),
            outlet: (max: row(19).toKelvin, min: row(22).toKelvin)),
      h2o: (inlet: (max: row(25).toKelvin, min: row(28).toKelvin),
            outlet: (max: row(31).toKelvin, min: row(34).toKelvin)))
    self.scc = try Temperatures(
      htf: (inlet: (max: row(47).toKelvin, min: row(50).toKelvin),
            outlet: (max: row(53).toKelvin, min: row(56).toKelvin)),
      h2o: (inlet: (max: row(59).toKelvin, min: row(62).toKelvin),
            outlet: (max: row(65).toKelvin, min: row(68).toKelvin)))
    
    self.SCCEff = try row(44)
    self.SCCHTFmassFlow = try MassFlow(row(71))
    self.SCCHTFthermal = try row(74)
    self.useAndsolFunction = false
    self.Tout_f_Mfl = false
    self.Tout_f_Tin = false
    self.Tout_exp_Tin_Mfl = false
  }
}

extension HeatExchanger.Parameter: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case efficiency
    case temperature
    case scc
    case SCCEff
    case SCCHTFmassFlow
    case SCCHTFthermal
    case useAndsolFunction
    case Tout_f_Mfl
    case Tout_f_Tin
    case Tout_exp_Tin_Mfl
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try values.decode(String.self, forKey: .name)
    self.efficiency = try values.decode(Double.self, forKey: .efficiency)
    var temperatures = try values.decode(Array<Double>.self, forKey: .temperature)
    self.temperature = Temperatures(
      htf: (inlet: (max: temperatures[0].toKelvin, min: temperatures[1].toKelvin),
            outlet: (max: temperatures[2].toKelvin, min: temperatures[3].toKelvin)),
      h2o: (inlet: (max: temperatures[4].toKelvin, min: temperatures[5].toKelvin),
            outlet: (max: temperatures[6].toKelvin, min: temperatures[7].toKelvin)))
    temperatures = try values.decode(Array<Double>.self, forKey: .scc)
    self.scc = Temperatures(
      htf: (inlet: (max: temperatures[0].toKelvin, min: temperatures[1].toKelvin),
            outlet: (max: temperatures[2].toKelvin, min: temperatures[3].toKelvin)),
      h2o: (inlet: (max: temperatures[4].toKelvin, min: temperatures[5].toKelvin),
            outlet: (max: temperatures[6].toKelvin, min: temperatures[7].toKelvin)))
    self.SCCEff = try values.decode(Double.self, forKey: .SCCEff)
    self.SCCHTFmassFlow = try values.decode(MassFlow.self, forKey: .SCCHTFmassFlow)
    self.SCCHTFthermal = try values.decode(Double.self, forKey: .SCCHTFthermal)
    self.useAndsolFunction = try values.decode(Bool.self, forKey: .useAndsolFunction)
    self.Tout_f_Mfl = try values.decode(Bool.self, forKey: .Tout_f_Mfl)
    self.Tout_f_Tin = try values.decode(Bool.self, forKey: .Tout_f_Tin)
    self.Tout_exp_Tin_Mfl = try values.decode(Bool.self, forKey: .Tout_exp_Tin_Mfl)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(efficiency, forKey: .efficiency)
    let temperatures = [
      temperature.htf.inlet.max.celsius, temperature.htf.inlet.min.celsius,
      temperature.htf.outlet.max.celsius, temperature.htf.outlet.min.celsius,
      temperature.h2o.inlet.max.celsius, temperature.h2o.inlet.min.celsius,
      temperature.h2o.outlet.max.celsius, temperature.h2o.outlet.min.celsius]
    try container.encode(temperatures, forKey: .temperature)
    let sccTemperatures = [
      scc.htf.inlet.max.celsius, scc.htf.inlet.min.celsius,
      scc.htf.outlet.max.celsius, scc.htf.outlet.min.celsius,
      scc.h2o.inlet.max.celsius, scc.h2o.inlet.min.celsius,
      scc.h2o.outlet.max.celsius, scc.h2o.outlet.min.celsius]
    try container.encode(sccTemperatures, forKey: .scc)
    try container.encode(SCCEff, forKey: .SCCEff)
    try container.encode(SCCHTFmassFlow, forKey: .SCCHTFmassFlow)
    try container.encode(SCCHTFthermal, forKey: .SCCHTFthermal)
    try container.encode(useAndsolFunction, forKey: .useAndsolFunction)
    try container.encode(Tout_f_Mfl, forKey: .Tout_f_Mfl)
    try container.encode(Tout_f_Tin, forKey: .Tout_f_Tin)
    try container.encode(Tout_exp_Tin_Mfl, forKey: .Tout_exp_Tin_Mfl)
  }
}

