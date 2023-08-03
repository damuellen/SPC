//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension HeatExchanger {
  /// A struct representing the parameters of the heat exchanger.
  struct Parameter: Equatable {
    /// A struct representing the temperatures in the heat exchanger.
    struct Temperatures {
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
        precondition(htf.inlet.max > htf.inlet.min)
        precondition(htf.inlet.max > htf.outlet.max)
        precondition(htf.inlet.min > htf.outlet.min)
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
    
    /// The name of the heat exchanger.
    let name: String
    /// The efficiency of the heat exchanger.
    let efficiency: Double
    /// The efficiency of the heat exchanger in the secondary cooling circuit (SCC).
    let sccEfficiency: Double
    /// The temperatures in the heat exchanger.
    var temperature: Temperatures
    /// The temperatures in the secondary cooling circuit (SCC).
    let scc: Temperatures
    /// The mass flow rate of the heat transfer fluid (HTF).
    let massFlowHTF: MassFlow
    /// The heat flow rate of the heat transfer fluid (HTF).
    var heatFlowHTF: Double
    /// Polynomial expression to calculate outlet temperature as a function of HTF mass flow rate.
    var ToutMassFlow: Polynomial?
    /// Polynomial expression to calculate outlet temperature as a function of HTF inlet temperature.
    var ToutTin: Polynomial?
    /// Polynomial expression to calculate outlet temperature as an Andasol-3 function.
    var ToutTinMassFlow: Polynomial?
    /// Determines whether the outlet temperature is calculated as a function of HTF mass flow rate.
    var useAndsolFunction: Bool
    /// Determines whether the outlet temperature is calculated as a function of HTF mass flow rate.
    var Tout_f_Mfl: Bool
    /// Determines whether the outlet temperature is calculated as a function of HTF inlet temperature.
    var Tout_f_Tin: Bool
    /// Determines whether the outlet temperature is calculated as f(Tin, Mfl).
    var Tout_exp_Tin_Mfl: Bool
  }
}

extension HeatExchanger.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" * name
    + "Parameter for Steam Cycle\n"
    + "Efficiency [%]:" * String(format: "%.1f", (efficiency * 100))
    + "Maximum Inlet Temperature  [°C]:"
    * String(format: "%.1f", temperature.htf.inlet.max.celsius)
    + "Maximum Outlet Temperature [°C]:"
    * String(format: "%.1f", temperature.htf.outlet.max.celsius)
    + "Minimum Inlet Temperature  [°C]:"
    * String(format: "%.1f", temperature.htf.inlet.min.celsius)
    + "Minimum Outlet Temperature [°C]:"
    * String(format: "%.1f", temperature.htf.outlet.min.celsius)
    + "Calculate Outlet Temp. as function of HTF Massflow:"
    * (Tout_f_Mfl ? "YES" : "NO ")
    + ((Tout_f_Mfl && ToutMassFlow != nil) ? "\(ToutMassFlow!)" : "")
    + "Calculate Outlet Temp. as function of HTF Inlet Temp.:"
    * (Tout_f_Tin ? "YES" : "NO ")
    + ((Tout_f_Tin && ToutTin != nil) ? "\(ToutTin!)" : "")    
    + "Calculate Outlet Temp. as Andasol-3 Function.:"
    * (useAndsolFunction ? "YES" : "NO ")
    + "Calculate Outlet Temp. as f(Tin,Mfl):"
    * (Tout_exp_Tin_Mfl ? "YES" : "NO ")
    + ((Tout_exp_Tin_Mfl && ToutTinMassFlow != nil) ?
    "\(ToutTinMassFlow!)" : "")
    //  + "not used:" HXc.H2OinTmax
    //  + "not used:" HXc.H2OinTmin
    //  + "not used:" HXc.H2OoutTmax - TK0
    //  + "not used:" HXc.H2OoutTmin - TK0
    + "Parameter for ISCCS Cycle\n"
    + "Efficiency [%]:" * String(format: "%.1f", (sccEfficiency * 100))
    + "Maximum Inlet Temperature [°C]:"
    * String(format: "%.1f", scc.htf.inlet.max.celsius)
    + "Maximum Outlet Temperature [°C]:"
    * String(format: "%.1f", scc.htf.outlet.max.celsius)
    + "Minimum Inlet Temperature [°C]:"
    * String(format: "%.1f", scc.htf.inlet.min.celsius)
    + "Minimum Outlet Temperature [°C]:"
    * String(format: "%.1f", scc.htf.outlet.min.celsius)
  //  + "not used:" HXc.sccH2OinTmax - TK0
  //  + "not used:" HXc.sccH2OinTmin - TK0
  //  + "not used:" HXc.sccH2OoutTmax - TK0
  //  + "not used:" HXc.sccH2OoutTmin - TK0
    + "Nominal HTF Mass Flow [kg/s]:" * massFlowHTF.rate.description
    + "Nominal Capacity [MW]:" * String(format: "%.3f", heatFlowHTF)
  }
}

extension HeatExchanger.Parameter: TextConfigInitializable {
  /// Creates a `HeatExchanger.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    name = file.name
    efficiency = try ln(10) / 100
    temperature = try Temperatures(
      htf: (inlet: (max: ln(13), min: ln(16)),
            outlet: (max: ln(19), min: ln(22))),
      h2o: (inlet: (max: ln(25), min: ln(28)),
            outlet: (max: ln(31), min: ln(34)))
    )
    scc = try Temperatures(
      htf: (inlet: (max: ln(47), min: ln(50)),
            outlet: (max: ln(53), min: ln(56))),
      h2o: (inlet: (max: ln(59), min: ln(62)),
            outlet: (max: ln(65), min: ln(68)))
    )

    sccEfficiency = try ln(44) / 100
    massFlowHTF = try MassFlow(ln(71))
    heatFlowHTF = try ln(74)
    useAndsolFunction = true
    Tout_f_Mfl = false
    Tout_f_Tin = false
    Tout_exp_Tin_Mfl = false
  }
}

extension HeatExchanger.Parameter {
  /// Calculates the heat flow of the heat exchanger.
  /// - Returns: The calculated heat flow in megawatts.
  func heatFlow() -> Double {
    let st = SteamTurbine.parameter
    if Design.hasGasTurbine {
      return Design.layout.heatExchanger / st.efficiencySCC / sccEfficiency
    }
    if Design.layout.heatExchanger != Design.layout.powerBlock {
      return Design.layout.heatExchanger / st.efficiencyNominal / efficiency
    }
    return st.power.max / st.efficiencyNominal / efficiency    
  }
}

extension HeatExchanger.Parameter: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case efficiency
    case temperature
    case scc
    case sccEfficiency
    case massFlowHTF
    case heatFlowHTF
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
    sccEfficiency = try values.decode(Double.self, forKey: .sccEfficiency)
    massFlowHTF = try values.decode(MassFlow.self, forKey: .massFlowHTF)
    heatFlowHTF = try values.decode(Double.self, forKey: .heatFlowHTF)
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
    try container.encode(sccEfficiency, forKey: .sccEfficiency)
    try container.encode(massFlowHTF, forKey: .massFlowHTF)
    try container.encode(heatFlowHTF, forKey: .heatFlowHTF)
    try container.encode(useAndsolFunction, forKey: .useAndsolFunction)
    try container.encode(Tout_f_Mfl, forKey: .Tout_f_Mfl)
    try container.encode(Tout_f_Tin, forKey: .Tout_f_Tin)
    try container.encode(Tout_exp_Tin_Mfl, forKey: .Tout_exp_Tin_Mfl)
  }
}

typealias HXTemps = HeatExchanger.Parameter.Temperatures

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

