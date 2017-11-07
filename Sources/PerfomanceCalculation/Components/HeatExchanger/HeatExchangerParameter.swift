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
import Config

extension HeatExchanger {
  public struct Parameter: ComponentParameter {
    public struct Temperatures {
      let htf: (inlet: (max: Temperature, min: Temperature),
      outlet: (max: Temperature, min: Temperature))
      var h2o: (inlet: (max: Temperature, min: Temperature),
      outlet: (max: Temperature, min: Temperature))
      
      public init(
        htf: (inlet: (max: Double, min: Double), outlet: (max: Double, min: Double)),
        h2o: (inlet: (max: Double, min: Double), outlet: (max: Double, min: Double))) {
        
        self.htf = ((Temperature(htf.inlet.max), Temperature(htf.inlet.min)),
                    (Temperature(htf.outlet.max), Temperature(htf.outlet.min)))
        self.h2o = ((Temperature(h2o.inlet.max), Temperature(h2o.inlet.min)),
                    (Temperature(h2o.outlet.max), Temperature(h2o.outlet.min)))
      }
    }
    
    let name: String
    let efficiency: Double
    let SCCEff: Double
    var temperature: Temperatures
    let scc: Temperatures
    let SCCHTFmassFlow: Double
    var SCCHTFheatFlow: Double
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
      >< "\(efficiency)"
    d += "Maximum Inlet Temperature  [°C]:"
      >< "\(temperature.htf.inlet.max.toCelsius)"
    d += "Maximum Outlet Temperature [°C]:"
      >< "\(temperature.htf.outlet.max.toCelsius)"
    d += "Minimum Inlet Temperature  [°C]:"
      >< "\(temperature.htf.inlet.min.toCelsius)"
    d += "Minimum Outlet Temperature [°C]:"
      >< "\(temperature.htf.outlet.min.toCelsius)"
    d += "Calculate Outlet Temp. as function of HTF Massflow:"
      >< (Tout_f_Mfl ? "YES" : "NO ")
    if Tout_f_Mfl, ToutMassFlow != nil  {
      d += "c0:" >< "\(ToutMassFlow![0])"
      d += "c1:" >< "\(ToutMassFlow![1])"
      d += "c2:" >< "\(ToutMassFlow![2])"
      d += "c3:" >< "\(ToutMassFlow![3])"
      d += "c4:" >< "\(ToutMassFlow![4])"
    }
    d += "Calculate Outlet Temp. as function of HTF Inlet Temp.:"
      >< (Tout_f_Tin ? "YES" : "NO ")
    if Tout_f_Tin, ToutTin != nil {
      d += "c0:" >< "\(ToutTin![0])"
      d += "c1:" >< "\(ToutTin![1])"
      d += "c2:" >< "\(ToutTin![2])"
      d += "c3:" >< "\(ToutTin![3])"
      d += "c4:" >< "\(ToutTin![4])"
    }
    d += "Calculate Outlet Temp. as Andasol-3 Function.:"
      >< (useAndsolFunction ? "YES" : "NO ")
    d += "Calculate Outlet Temp. as f(Tin,Mfl):"
      >< (Tout_exp_Tin_Mfl ? "YES" : "NO ")
    if Tout_exp_Tin_Mfl, ToutTinMassFlow != nil {
      d += "c0:" >< "\(ToutTinMassFlow![0])"
      d += "c1:" >< "\(ToutTinMassFlow![1])"
      d += "c2:" >< "\(ToutTinMassFlow![2])"
      d += "c3:" >< "\(ToutTinMassFlow![3])"
      d += "c4:" >< "\(ToutTinMassFlow![4])"
    }
    // d += "not used:" HXc.H2OinTmax
    // d += "not used:" HXc.H2OinTmin
    // d += "not used:" HXc.H2OoutTmax - TK0
    // d += "not used:" HXc.H2OoutTmin - TK0
    d += "Parameter for ISCCS Cycle\n"
    d += "Efficiency [%]:"
      >< "\(SCCEff * 100)"
    d += "Maximum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.max)"
    d += "Maximum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.max)"
    d += "Minimum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.min)"
    d += "Minimum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.min)"
    // d += "not used:" HXc.SCCH2OinTmax - TK0
    // d += "not used:" HXc.SCCH2OinTmin - TK0
    // d += "not used:" HXc.SCCH2OoutTmax - TK0
    // d += "not used:" HXc.SCCH2OoutTmin - TK0
    d += "Nominal HTF Mass Flow [kg/s]:"
      >< "\(SCCHTFmassFlow)"
    d += "Nominal Capacity [MW]:"
      >< "\(SCCHTFheatFlow)"
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
    self.SCCHTFmassFlow = try row(71)
    self.SCCHTFheatFlow = try row(74)
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
    case SCCHTFheatFlow
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
    self.SCCHTFmassFlow = try values.decode(Double.self, forKey: .SCCHTFmassFlow)
    self.SCCHTFheatFlow = try values.decode(Double.self, forKey: .SCCHTFheatFlow)
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
      temperature.htf.inlet.max.toCelsius, temperature.htf.inlet.min.toCelsius,
      temperature.htf.outlet.max.toCelsius, temperature.htf.outlet.min.toCelsius,
      temperature.h2o.inlet.max.toCelsius, temperature.h2o.inlet.min.toCelsius,
      temperature.h2o.outlet.max.toCelsius, temperature.h2o.outlet.min.toCelsius]
    try container.encode(temperatures, forKey: .temperature)
    let sccTemperatures = [
      scc.htf.inlet.max.toCelsius, scc.htf.inlet.min.toCelsius,
      scc.htf.outlet.max.toCelsius, scc.htf.outlet.min.toCelsius,
      scc.h2o.inlet.max.toCelsius, scc.h2o.inlet.min.toCelsius,
      scc.h2o.outlet.max.toCelsius, scc.h2o.outlet.min.toCelsius]
    try container.encode(sccTemperatures, forKey: .scc)
    try container.encode(SCCEff, forKey: .SCCEff)
    try container.encode(SCCHTFmassFlow, forKey: .SCCHTFmassFlow)
    try container.encode(SCCHTFheatFlow, forKey: .SCCHTFheatFlow)
    try container.encode(useAndsolFunction, forKey: .useAndsolFunction)
    try container.encode(Tout_f_Mfl, forKey: .Tout_f_Mfl)
    try container.encode(Tout_f_Tin, forKey: .Tout_f_Tin)
    try container.encode(Tout_exp_Tin_Mfl, forKey: .Tout_exp_Tin_Mfl)
  }
}

