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

extension SolarField {
  enum Layout: String, Equatable {
    case I, H
  }

  /**
   ## The solar field is specified by:
   - the total number of loops
   - number of collectors per loop
   - distance between collectors in a row
   - distance between rows
   - azimuth angle and elevation angle of solar field
   - heat losses in piping
   - maximum wind speed for tracking
   - nominal HTF flow
   - “freeze protection” HTF flow and minimal HTF flow
   - parasitic power as a function of HTF flow
   */
  public struct Parameter: ComponentParameter {
    let HLDump = false
    let layout = SolarField.Layout.H
    let EtaWind = false
    /// Pipe heat losses in tested area [W/sqm]
    let SSFHL: Double = 0.0
    let heatLossHeader: [Double] = [0, 0.475, 0.0014]
    let HLDumpQuad = false
    var imbalanceDesign: [Double] = [1.0, 1.0, 1.0]
    var imbalanceMin: [Double] = [0.0, 1.025, 1.05]
    var windCoefficients: Polynomial = [0.0]
    var useReferenceAmbientTemperature = false
    var referenceAmbientTemperature: Double = 0.0
    var heatlosses: Polynomial = [0.0]
    var designTemperature: (inlet: Double, outlet: Double) = (0.0, 0.0)
    /// Maximum windspeed for operation [m/sec]
    let maxWind: Float
    let numberOfSCAsInRow: Int
    public var rowDistance, distanceSCA, pipeHeatLosses: Double
    public var azimut, elevation: Double
    let antiFreezeParastics: Double
    let pumpParastics: Polynomial
    public var massFlow: (max: MassFlow, min: MassFlow)
    var pumpParasticsFullLoad: Double
    var antiFreezeFlow: MassFlow
    var HTFmass: Double
    var HTF: HeatTransferFluid
    var collector: Collector.Parameter!
    var edgeFactor: [Double] = []
  }
}

extension SolarField.Parameter {

  var distRatio: Double {
    return self.pipeWay / (2 * self.loopWays[1])
  }

  var pipeWay: Double {
    return self.loopWays[1] + 2 * self.loopWays[2]
  }

  var loopWays: [Double] {
    let designWay = Double(numberOfSCAsInRow)
      * (collector.lengthSCA + distanceSCA) * 2.0 + rowDistance

    var nearWay = Double(numberOfSCAsInRow)
      * (collector.lengthSCA + distanceSCA)
    nearWay = layout ~= .I
      ? nearWay
      : nearWay * 2 + rowDistance + 0.5

    var avgWay = Design.layout.solarField / 4 * rowDistance / 2
    avgWay = layout ~= .I
      ? avgWay + 0.5
      : avgWay + nearWay

    var farWay: Double = (2 * (Design.layout.solarField / 4 * rowDistance / 2))
    farWay = layout ~= .I
      ? farWay
      : farWay + nearWay

    return [designWay, nearWay, avgWay, farWay]
  }
}

extension SolarField.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Number of Loops:"
      >< "\(Design.layout.solarField)"
    d += "Maximum allowable Wind Speed for Operation [m]:"
      >< "\(maxWind)"
    d += "Numbers of Collectors in a Row:"
      >< "\(numberOfSCAsInRow)"
    d += "Distance between Rows [m]:"
      >< "\(rowDistance)"
    d += "Distance between Collectors in a Row [m]:"
      >< "\(distanceSCA)"
    d += "Heat Losses in total HTF Piping (per sqm aperture) [W/m²]:"
      >< "\(pipeHeatLosses)"
    d += "Heat Losses in Piping of tested field (per sqm aperture) [W/m²]:"
      >< "\(SSFHL)"
    d += "Azimuth angle of Solar Field Orientation [°]:"
      >< "\(azimut)"
    d += "Mass Flow in Solar Field at Full Load [kg/s]:"
      >< "\(massFlow.max.rate)"
    d += "Minimum allowable Mass Flow [%]:"
      >< "\(massFlow.min.rate)"
    d += "Anti-Freeze Mass Flow [%]:"
      >< "\(antiFreezeFlow.rate)"
    d += "Total Mass of HTF in System [kg]:"
      >< "\(HTFmass)"
    d += "Consider HL of ANY Dump. Collectors:"
      >< (HLDump ? "YES" : "NO ")
    d += "Consider HL of Dump. Col. for operating quadrant:"
      >< (HLDumpQuad ? "YES" : "NO ")
    d += "Consider SKAL-ET DemoLoop Effect of Wind Speed.:"
      >< (EtaWind ? "YES" : "NO ")
    if windCoefficients.isEmpty == false {
      d += "Collector efficiency vs Wind Speed c0+c1*WS+c2*WS^2+c3*WS^3+c4*WS^4+c5*WS^5\n"
      for idx in windCoefficients.indices {
        d += "c\(idx):" >< "\(windCoefficients[idx])"
      }
    }
    d += "Layout Design Type:"
      >< "\(Design.layout.solarField)"
    d += "Heat Losses in Hot Header [MW]:"
      >< "\(heatLossHeader)"
    if heatlosses.isEmpty == false {
      d += "Heat Losses in Hot Header Coefficients;\nHL(Tout - Tamb) = HL(design)*(c0+c1*dT)\n"
      for idx in heatlosses.indices {
        d += "c\(idx):" >< "\(heatlosses[idx])"
      }
    }
    d += "Use Reference T_amb from Solpipe:"
      >< (useReferenceAmbientTemperature ? "YES" : "NO ")
    d += "Design SOF T_inlet [°C]:"
      >< "\(designTemperature.inlet)"
    d += "Design SOF T_outlet [°C]:"
      >< "\(designTemperature.outlet)"
    d += "HTF Flow Imbalance\n"
    d += "Near, Design:"
      >< "\(imbalanceDesign[0])"
    d += "Average, Design:"
      >< "\(imbalanceDesign[1])"
    d += "Far, Design:"
      >< "\(imbalanceDesign[2])"
    d += "Near, Minimum:"
      >< "\(imbalanceMin[0])"
    d += "Average, Minimum:"
      >< "\(imbalanceMin[1])"
    d += "Far, Minimum:"
      >< "\(imbalanceMin[2])"
    return d
  }
}

extension SolarField.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    maxWind = Float(try row(10))
    numberOfSCAsInRow = Int(try row(13))
    rowDistance = try row(16)
    distanceSCA = try row(19)
    pipeHeatLosses = try row(22)
    azimut = try row(25)
    elevation = try row(28)
    pumpParasticsFullLoad = try row(34)
    antiFreezeParastics = try row(37)
    pumpParastics = try [row(40), row(43), row(46)]
    massFlow = try (MassFlow(row(49)), MassFlow(row(52)))
    antiFreezeFlow = try MassFlow(row(55))
    HTFmass = try row(58)
    HTF = ParameterDefaults.HTF
    imbalanceDesign = try [row(72), row(73), row(74)]
    imbalanceMin = try [row(75), row(76), row(77)]
    windCoefficients = try [row(79), row(80), row(81), row(82), row(83), row(84)]
    useReferenceAmbientTemperature = try row(86) > 0 ? true : false
    referenceAmbientTemperature = try row(87)
    designTemperature = (try row(89), try row(90))
    heatlosses = try [row(93), row(96), row(99), row(102), row(105)]
  }
}

extension SolarField.Parameter: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case maxWind
    case numberOfSCAsInRow
    case rowDistance
    case distanceSCA
    case pipeHL
    case azimut, elevation
    case pumpParasticsFullLoad, antiFreezeParastics, pumpParastics
    case maxMassFlow, minMassFlow
    case antiFreezeFlow
    case HTFmass
    case imbalanceDesignNear, imbalanceDesignAverage, imbalanceDesignFar
    case imbalanceMinNear, imbalanceMinAverage, imbalanceMinFar
    case windCoefficients
    case useReferenceAmbientTemperature
    case referenceAmbientTemperature
    case inletDesignTemperature, outletDesignTemperature
    case heatlosses
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    maxWind = try values.decode(Float.self, forKey: .maxWind)
    numberOfSCAsInRow = try values.decode(
      Int.self, forKey: .numberOfSCAsInRow
    )
    rowDistance = try values.decode(Double.self, forKey: .rowDistance)
    distanceSCA = try values.decode(Double.self, forKey: .distanceSCA)
    pipeHeatLosses = try values.decode(Double.self, forKey: .pipeHL)
    azimut = try values.decode(Double.self, forKey: .elevation)
    elevation = try values.decode(Double.self, forKey: .elevation)
    pumpParasticsFullLoad = try values.decode(
      Double.self, forKey: .pumpParasticsFullLoad
    )
    antiFreezeParastics = try values.decode(
      Double.self, forKey: .antiFreezeParastics
    )
    pumpParastics = try values.decode(
      Polynomial.self, forKey: .pumpParastics
    )
    massFlow = (
      try values.decode(MassFlow.self, forKey: .maxMassFlow),
      try values.decode(MassFlow.self, forKey: .minMassFlow)
    )
    antiFreezeFlow = try values.decode(MassFlow.self, forKey: .antiFreezeFlow)
    HTFmass = try values.decode(Double.self, forKey: .HTFmass)
    HTF = ParameterDefaults.HTF
    imbalanceDesign = [
      try values.decode(Double.self, forKey: .imbalanceDesignNear),
      try values.decode(Double.self, forKey: .imbalanceDesignAverage),
      try values.decode(Double.self, forKey: .imbalanceDesignFar),
    ]
    imbalanceMin = [
      try values.decode(Double.self, forKey: .imbalanceMinNear),
      try values.decode(Double.self, forKey: .imbalanceMinAverage),
      try values.decode(Double.self, forKey: .imbalanceMinFar),
    ]
    windCoefficients = try values.decode(
      Polynomial.self, forKey: .windCoefficients
    )
    useReferenceAmbientTemperature = try values.decode(
      Bool.self, forKey: .useReferenceAmbientTemperature
    )
    referenceAmbientTemperature = try values.decode(
      Double.self, forKey: .referenceAmbientTemperature
    )
    designTemperature = (
      try values.decode(Double.self, forKey: .inletDesignTemperature),
      try values.decode(Double.self, forKey: .outletDesignTemperature)
    )
    heatlosses = try values.decode(Polynomial.self, forKey: .heatlosses)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(maxWind, forKey: .maxWind)
    try container.encode(numberOfSCAsInRow, forKey: .numberOfSCAsInRow)
    try container.encode(rowDistance, forKey: .rowDistance)
    try container.encode(distanceSCA, forKey: .distanceSCA)
    try container.encode(pipeHeatLosses, forKey: .pipeHL)
    try container.encode(azimut, forKey: .azimut)
    try container.encode(elevation, forKey: .elevation)
    try container.encode(pumpParasticsFullLoad, forKey: .pumpParasticsFullLoad)
    try container.encode(antiFreezeParastics, forKey: .antiFreezeParastics)
    try container.encode(pumpParastics, forKey: .pumpParastics)
    try container.encode(massFlow.max, forKey: .maxMassFlow)
    try container.encode(massFlow.min, forKey: .minMassFlow)
    try container.encode(antiFreezeFlow, forKey: .antiFreezeFlow)
    try container.encode(HTFmass, forKey: .HTFmass)
    try container.encode(imbalanceDesign[0], forKey: .imbalanceDesignNear)
    try container.encode(imbalanceDesign[1], forKey: .imbalanceDesignAverage)
    try container.encode(imbalanceDesign[2], forKey: .imbalanceDesignFar)
    try container.encode(imbalanceMin[0], forKey: .imbalanceMinNear)
    try container.encode(imbalanceMin[1], forKey: .imbalanceMinAverage)
    try container.encode(imbalanceMin[2], forKey: .imbalanceMinFar)
    try container.encode(windCoefficients, forKey: .windCoefficients)
    try container.encode(useReferenceAmbientTemperature,
                         forKey: .useReferenceAmbientTemperature)
    try container.encode(referenceAmbientTemperature,
                         forKey: .referenceAmbientTemperature)
    try container.encode(designTemperature.inlet, forKey: .inletDesignTemperature)
    try container.encode(designTemperature.outlet, forKey: .outletDesignTemperature)
    try container.encode(heatlosses, forKey: .heatlosses)
  }
}

extension SolarField.Parameter: Equatable {
  public static func ==(lhs: SolarField.Parameter, rhs: SolarField.Parameter) -> Bool {
    return lhs.HLDump == rhs.HLDump
      && lhs.layout == rhs.layout
      && lhs.EtaWind == rhs.EtaWind
      /// Pipe heat losses in tested area [W/sqm]
      && lhs.SSFHL == rhs.SSFHL
      && lhs.heatLossHeader == rhs.heatLossHeader
      && lhs.HLDumpQuad == rhs.HLDumpQuad
      && lhs.imbalanceDesign == rhs.imbalanceDesign
      && lhs.imbalanceMin == rhs.imbalanceMin
      && lhs.windCoefficients == rhs.windCoefficients
      && lhs.useReferenceAmbientTemperature == rhs.useReferenceAmbientTemperature
      && lhs.referenceAmbientTemperature == rhs.referenceAmbientTemperature
      && lhs.heatlosses == rhs.heatlosses
      && lhs.designTemperature.inlet == rhs.designTemperature.inlet
      && lhs.designTemperature.outlet == rhs.designTemperature.outlet
      /// Maximum windspeed for operation [m/sec]
      && lhs.maxWind == rhs.maxWind
      && lhs.numberOfSCAsInRow == rhs.numberOfSCAsInRow
      && lhs.rowDistance == rhs.rowDistance
      && lhs.distanceSCA == rhs.distanceSCA
      && lhs.pipeHeatLosses == rhs.pipeHeatLosses
      && lhs.azimut == rhs.azimut
      && rhs.elevation == rhs.elevation
      && lhs.antiFreezeParastics == rhs.antiFreezeParastics
      && lhs.pumpParastics == rhs.pumpParastics
      && lhs.massFlow.max == rhs.massFlow.max
      && lhs.massFlow.min == rhs.massFlow.min
      && lhs.pumpParasticsFullLoad == rhs.pumpParasticsFullLoad
      && lhs.antiFreezeFlow == rhs.antiFreezeFlow
      && lhs.HTFmass == rhs.HTFmass
      && lhs.HTF == rhs.HTF
      && lhs.collector == rhs.collector
      && lhs.edgeFactor == rhs.edgeFactor
  }
}
