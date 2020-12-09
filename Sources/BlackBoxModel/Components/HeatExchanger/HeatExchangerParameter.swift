//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

extension HeatExchanger {
  public struct Parameter: ComponentParameter, Equatable {
    public struct Temperatures {
      let htf: (inlet: (max: Temperature, min: Temperature),
                outlet: (max: Temperature, min: Temperature))
      var h2o: (inlet: (max: Temperature, min: Temperature),
                outlet: (max: Temperature, min: Temperature))

      let range: (inlet: Temperature, outlet:Temperature)

      public init(
        htf: (inlet: (max: Double, min: Double),
              outlet: (max: Double, min: Double)),
        h2o: (inlet: (max: Double, min: Double),
              outlet: (max: Double, min: Double))
      ) {
        typealias T = Temperature
        self.htf = ((T(celsius: htf.inlet.max), T(celsius: htf.inlet.min)),
                    (T(celsius: htf.outlet.max),T(celsius: htf.outlet.min)))
        self.h2o = ((T(celsius: h2o.inlet.max), T(celsius: h2o.inlet.min)),
                    (T(celsius: h2o.outlet.max),T(celsius: h2o.outlet.min)))
        self.range = (
          inlet: T(celsius: htf.inlet.max - htf.inlet.min),
          outlet: T(celsius: htf.outlet.max - htf.outlet.min)
        )
      }
    }

    var heatDesign: Heat {
      SolarField.parameter.HTF.deltaHeat(temperature.htf.outlet.max, temperature.htf.inlet.max)
    }
    
    let name: String
    let efficiency: Double
    let sccEff: Double
    var temperature: Temperatures
    let scc: Temperatures
    let sccHTFmassFlow: MassFlow
    var sccHTFheat: Double
    var ToutMassFlow: Polynomial?
    var ToutTin: Polynomial?
    var ToutTinMassFlow: Polynomial?
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
    if Tout_f_Mfl, ToutMassFlow != nil {
      for (i, c) in ToutMassFlow!.coefficients.enumerated() {
        d += "c\(i):" >< String(format: "%.4E", c)
      }
    }
    d += "Calculate Outlet Temp. as function of HTF Inlet Temp.:"
      >< (Tout_f_Tin ? "YES" : "NO ")
    if Tout_f_Tin, ToutTin != nil {
      for (i, c) in ToutTin!.coefficients.enumerated() {
        d += "c\(i):" >< String(format: "%.4E", c)
      }
    }
    d += "Calculate Outlet Temp. as Andasol-3 Function.:"
      >< (useAndsolFunction ? "YES" : "NO ")
    d += "Calculate Outlet Temp. as f(Tin,Mfl):"
      >< (Tout_exp_Tin_Mfl ? "YES" : "NO ")
    if Tout_exp_Tin_Mfl, ToutTinMassFlow != nil {
      for (i, c) in ToutTinMassFlow!.coefficients.enumerated() {
        d += "c\(i):" >< String(format: "%.4E", c)
      }
    }
    // d += "not used:" HXc.H2OinTmax
    // d += "not used:" HXc.H2OinTmin
    // d += "not used:" HXc.H2OoutTmax - TK0
    // d += "not used:" HXc.H2OoutTmin - TK0
    d += "Parameter for ISCCS Cycle\n"
    d += "Efficiency [%]:"
      >< "\(sccEff * 100)"
    d += "Maximum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.max.celsius)"
    d += "Maximum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.max.celsius)"
    d += "Minimum Inlet Temperature [°C]:"
      >< "\(scc.htf.inlet.min.celsius)"
    d += "Minimum Outlet Temperature [°C]:"
      >< "\(scc.htf.outlet.min.celsius)"
    // d += "not used:" HXc.sccH2OinTmax - TK0
    // d += "not used:" HXc.sccH2OinTmin - TK0
    // d += "not used:" HXc.sccH2OoutTmax - TK0
    // d += "not used:" HXc.sccH2OoutTmin - TK0
    d += "Nominal HTF Mass Flow [kg/s]:"
      >< "\(sccHTFmassFlow.rate)"
    d += "Nominal Capacity [MW]:"
      >< String(format: "%.3f", sccHTFheat)
    return d
  }
}

extension HeatExchanger.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    efficiency = try line(10)
    temperature = try Temperatures(
      htf: (inlet: (max: line(13), min: line(16)),
            outlet: (max: line(19), min: line(22))),
      h2o: (inlet: (max: line(25), min: line(28)),
            outlet: (max: line(31), min: line(34)))
    )
    scc = try Temperatures(
      htf: (inlet: (max: line(47), min: line(50)),
            outlet: (max: line(53), min: line(56))),
      h2o: (inlet: (max: line(59), min: line(62)),
            outlet: (max: line(65), min: line(68)))
    )

    sccEff = try line(44)
    sccHTFmassFlow = try MassFlow(line(71))
    sccHTFheat = try line(74)
    useAndsolFunction = false
    Tout_f_Mfl = false
    Tout_f_Tin = false
    Tout_exp_Tin_Mfl = false
  }
}

extension HeatExchanger.Parameter: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case efficiency
    case temperature
    case scc
    case sccEff
    case sccHTFmassFlow
    case sccHTFthermal
    case useAndsolFunction
    case Tout_f_Mfl
    case Tout_f_Tin
    case Tout_exp_Tin_Mfl
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decode(String.self, forKey: .name)
    efficiency = try values.decode(Double.self, forKey: .efficiency)
    var temps = try values.decode(Array<Double>.self, forKey: .temperature)
    temperature = Temperatures(
      htf: (inlet: (max: temps[0], min: temps[1]),
            outlet: (max: temps[2], min: temps[3])),
      h2o: (inlet: (max: temps[4], min: temps[5]),
            outlet: (max: temps[6], min: temps[7]))
    )
    temps = try values.decode(Array<Double>.self, forKey: .scc)
    scc = Temperatures(
      htf: (inlet: (max: temps[0], min: temps[1]),
            outlet: (max: temps[2], min: temps[3])),
      h2o: (inlet: (max: temps[4], min: temps[5]),
            outlet: (max: temps[6], min: temps[7]))
    )
    sccEff = try values.decode(Double.self, forKey: .sccEff)
    sccHTFmassFlow = try values.decode(MassFlow.self, forKey: .sccHTFmassFlow)
    sccHTFheat = try values.decode(Double.self, forKey: .sccHTFthermal)
    useAndsolFunction = try values.decode(Bool.self, forKey: .useAndsolFunction)
    Tout_f_Mfl = try values.decode(Bool.self, forKey: .Tout_f_Mfl)
    Tout_f_Tin = try values.decode(Bool.self, forKey: .Tout_f_Tin)
    Tout_exp_Tin_Mfl = try values.decode(Bool.self, forKey: .Tout_exp_Tin_Mfl)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(efficiency, forKey: .efficiency)
    let temperatures = [
      temperature.htf.inlet.max.celsius, temperature.htf.inlet.min.celsius,
      temperature.htf.outlet.max.celsius, temperature.htf.outlet.min.celsius,
      temperature.h2o.inlet.max.celsius, temperature.h2o.inlet.min.celsius,
      temperature.h2o.outlet.max.celsius, temperature.h2o.outlet.min.celsius,
    ]
    try container.encode(temperatures, forKey: .temperature)
    let sccTemperatures = [
      scc.htf.inlet.max.celsius, scc.htf.inlet.min.celsius,
      scc.htf.outlet.max.celsius, scc.htf.outlet.min.celsius,
      scc.h2o.inlet.max.celsius, scc.h2o.inlet.min.celsius,
      scc.h2o.outlet.max.celsius, scc.h2o.outlet.min.celsius,
    ]
    try container.encode(sccTemperatures, forKey: .scc)
    try container.encode(sccEff, forKey: .sccEff)
    try container.encode(sccHTFmassFlow, forKey: .sccHTFmassFlow)
    try container.encode(sccHTFheat, forKey: .sccHTFthermal)
    try container.encode(useAndsolFunction, forKey: .useAndsolFunction)
    try container.encode(Tout_f_Mfl, forKey: .Tout_f_Mfl)
    try container.encode(Tout_f_Tin, forKey: .Tout_f_Tin)
    try container.encode(Tout_exp_Tin_Mfl, forKey: .Tout_exp_Tin_Mfl)
  }
}

public typealias HXTemps = HeatExchanger.Parameter.Temperatures

extension HXTemps: Equatable {
  public static func == (lhs: HXTemps, rhs: HXTemps) -> Bool {
    return lhs.range.inlet == rhs.range.inlet
      && lhs.range.outlet == rhs.range.outlet
      && lhs.htf.inlet.max == rhs.htf.inlet.max
      && lhs.htf.inlet.min == rhs.htf.inlet.min
      && lhs.htf.outlet.max == rhs.htf.outlet.max
      && lhs.htf.outlet.min == rhs.htf.outlet.min
      && lhs.h2o.inlet.max == rhs.h2o.inlet.max
      && lhs.h2o.inlet.min == rhs.h2o.inlet.min
      && lhs.h2o.outlet.max == rhs.h2o.outlet.max
      && lhs.h2o.outlet.min == rhs.h2o.outlet.min
  }
}

