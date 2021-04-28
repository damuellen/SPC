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
import PhysicalQuantities

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
  public struct Parameter {
    let HLDump = true
    let layout = SolarField.Layout.H
    let EtaWind = false
    /// Pipe heat losses in tested area [W/sqm]
    let SSFHL: Double = 0.0
    var heatLossHotHeader: [Double]
    let HLDumpQuad = true
    var imbalanceDesign: [Double] = [1.0, 1.0, 1.0]
    var imbalanceMin: [Double] = [1.03, 1.0, 0.97]
    var windCoefficients: Polynomial = [0.0]
    var useReferenceAmbientTemperature = true
    var referenceAmbientTemperature: Double = 0.0
    var designTemperature: (inlet: Double, outlet: Double) = (0.0, 0.0)
    /// Maximum windspeed for operation [m/sec]
    let maxWind: Float
    let numberOfSCAsInRow: Int
    public var rowDistance, distanceSCA, pipeHeatLosses: Double
    public var azimut, elevation: Double
    let antiFreezeParastics: Double
    let pumpParastics: Polynomial
    var maxMassFlow: MassFlow
    var minFlow: Ratio 
    var pumpParasticsFullLoad: Double
    var antiFreezeFlow: Ratio
    var HTFmass: Double
    var HTF: HeatTransferFluid
    var edgeFactor: [Double] = []

    var distRatio: Double = 0
    var pipeWay: Double = 0
    var loopWays: [Double] = [] 
    var heatlosses: [Double] = [] 
  }
}

extension SolarField.Parameter {

  mutating func wayLength() {
    let designWay =
      Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA) * 2.0 + rowDistance

    var nearWay =
      Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA)
    nearWay = layout ~= .I
      ? nearWay : nearWay * 2 + rowDistance + 0.5

    var avgWay = Design.layout.solarField / 4 * rowDistance / 2
    avgWay = layout ~= .I
      ? avgWay + 0.5 : avgWay + nearWay

    var farWay: Double = (2 * (Design.layout.solarField / 4 * rowDistance / 2))
    farWay = layout ~= .I
      ? farWay : farWay + nearWay

    self.loopWays = [designWay, nearWay, avgWay, farWay]
    self.distRatio = pipeWay / (2 * loopWays[1])
    self.pipeWay = loopWays[1] + 2 * loopWays[2]
  }
}

extension SolarField.Parameter: CustomStringConvertible {
  public var description: String {
    "Number of Loops:" * Design.layout.solarField.description
    + "Maximum allowable Wind Speed for Operation [m]:" * maxWind.description
    + "Numbers of Collectors in a Row:" * numberOfSCAsInRow.description
    + "Distance between Rows [m]:" * rowDistance.description
    + "Distance between Collectors in a Row [m]:" * distanceSCA.description
    + "Heat Losses in total HTF Piping (per sqm aperture) [W/m²]:"
    * String(format: "%G", pipeHeatLosses)
    + "Heat Losses in Piping of tested field (per sqm aperture) [W/m²]:"
    * String(format: "%G", SSFHL)
    + "Azimuth angle of Solar Field Orientation [°]:" * azimut.description
    + "Pumping Parasitics at Full Load [MW]:"
    * String(format: "%G", pumpParasticsFullLoad)
    + "Pumping Parasitics of Anti-Freeze Pump [MW]:"
    * String(format: "%G", antiFreezeParastics)
    + "Parasitic Energy Coefficients; \n"
    + "Parasitics(Load) = Parasitcs(100%)*(c0+c1*load+c2*load^2)"
    + "\n\(pumpParastics)"
    + "Tilt of Collectors [°]:" * elevation.description
    + "Mass Flow in Solar Field at Full Load [kg/s]:"
    * String(format: "%.1f", maxMassFlow.rate)
    + "Minimum allowable Mass Flow [%]:" * minFlow.percentage.description
    + "Anti-Freeze Mass Flow [%]:" * antiFreezeFlow.percentage.description
    + "Total Mass of HTF in System [kg]:"
    * String(format: "%.1f", HTFmass)
    + "Consider HL of ANY Dump. Collectors:" * (HLDump ? "YES" : "NO ")
    + "Consider HL of Dump. Col. for operating quadrant:"
    * (HLDumpQuad ? "YES" : "NO ")
    + "Consider SKAL-ET DemoLoop Effect of Wind Speed.:"
    * (EtaWind ? "YES" : "NO ")
    + (windCoefficients.isEmpty == false ?
    "Collector efficiency vs Wind Speed c0+c1*WS+c2*WS^2+c3*WS^3+c4*WS^4+c5*WS^5"
    + "\n\(windCoefficients)" : "")
    + "Layout Design Type:" * layout.rawValue
    + "Heat Losses in Hot Header [MW]:"
    * String(format: "%G" ,heatLossHotHeader[0])
    + (heatLossHotHeader.count > 1 ?
    "Heat Losses in Hot Header Coefficients;\nHL(Tout - Tamb) = HL(design)*(c0+c1*dT)"
    + "\n\(Polynomial(heatLossHotHeader))" : "")
    + "Use Reference T_amb from Solpipe:"
    * (useReferenceAmbientTemperature ? "YES" : "NO ")
    + "Design SOF T_inlet [°C]:"
    * String(format: "%G", designTemperature.inlet)
    + "Design SOF T_outlet [°C]:"
    * String(format: "%G", designTemperature.outlet)
    + "HTF Flow Imbalance\n"
    + "Near, Design:" * imbalanceDesign[0].description
    + "Average, Design:" * imbalanceDesign[1].description
    + "Far, Design:" * imbalanceDesign[2].description
    + "Near, Minimum:" * imbalanceMin[0].description
    + "Average, Minimum:" * imbalanceMin[1].description
    + "Far, Minimum:" * imbalanceMin[2].description
  }
}

extension SolarField.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    maxWind = Float(try ln(10))
    numberOfSCAsInRow = Int(try ln(13))
    rowDistance = try ln(16)
    distanceSCA = try ln(19)
    pipeHeatLosses = try ln(22)    
    azimut = try ln(25)
    elevation = try ln(28)
    pumpParasticsFullLoad = try ln(34)
    antiFreezeParastics = try ln(37)
    pumpParastics = try [ln(40), ln(43), ln(46)]
    maxMassFlow = try MassFlow(ln(49))
    minFlow = try Ratio(ln(52) / 100)
    antiFreezeFlow = try Ratio(ln(55) / 100)
    HTFmass = try ln(58)
    HTF = ParameterDefaults.HTF
    heatLossHotHeader = try [ln(66), ln(67), ln(68)]
    imbalanceDesign = try [ln(72), ln(73), ln(74)]
    imbalanceMin = try [ln(75), ln(76), ln(77)]
    windCoefficients =
      try [ln(79), ln(80), ln(81), ln(82), ln(83), ln(84)]
    useReferenceAmbientTemperature = try ln(86) > 0 ? true : false
    referenceAmbientTemperature = try ln(87)
    designTemperature = (try ln(89), try ln(90))
    heatlosses = try [ln(93), ln(96), ln(99), ln(102), ln(105)]
  }
}

extension SolarField.Parameter: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case maxWind
    case numberOfSCAsInRow
    case rowDistance
    case distanceSCA
    case pipeHL, heatLossHotHeader
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
    heatLossHotHeader = try values.decode(Array<Double>.self, forKey: .heatLossHotHeader)
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
    maxMassFlow = 
      try values.decode(MassFlow.self, forKey: .maxMassFlow)      
    minFlow = 
      try values.decode(Ratio.self, forKey: .minMassFlow)
    antiFreezeFlow = try values.decode(Ratio.self, forKey: .antiFreezeFlow)
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
    heatlosses = try values.decode(Array<Double>.self, forKey: .heatlosses)
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
    try container.encode(maxMassFlow, forKey: .maxMassFlow)
    try container.encode(minFlow, forKey: .minMassFlow)
    try container.encode(antiFreezeFlow, forKey: .antiFreezeFlow)
    try container.encode(HTFmass, forKey: .HTFmass)
    try container.encode(imbalanceDesign[0], forKey: .imbalanceDesignNear)
    try container.encode(imbalanceDesign[1], forKey: .imbalanceDesignAverage)
    try container.encode(imbalanceDesign[2], forKey: .imbalanceDesignFar)
    try container.encode(imbalanceMin[0], forKey: .imbalanceMinNear)
    try container.encode(imbalanceMin[1], forKey: .imbalanceMinAverage)
    try container.encode(imbalanceMin[2], forKey: .imbalanceMinFar)
    try container.encode(windCoefficients, forKey: .windCoefficients)
    try container.encode(
      useReferenceAmbientTemperature,
      forKey: .useReferenceAmbientTemperature)
    try container.encode(
      referenceAmbientTemperature,
      forKey: .referenceAmbientTemperature)
    try container.encode(designTemperature.inlet, forKey: .inletDesignTemperature)
    try container.encode(designTemperature.outlet, forKey: .outletDesignTemperature)
    try container.encode(heatlosses, forKey: .heatlosses)
  }
}

extension SolarField.Parameter: Equatable {
  public static func == (lhs: SolarField.Parameter, rhs: SolarField.Parameter) -> Bool {
    return lhs.HLDump == rhs.HLDump
      && lhs.layout == rhs.layout
      && lhs.EtaWind == rhs.EtaWind
      /// Pipe heat losses in tested area [W/sqm]
      && lhs.SSFHL == rhs.SSFHL
      && lhs.heatLossHotHeader == rhs.heatLossHotHeader
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
      && lhs.maxMassFlow == rhs.maxMassFlow
      && lhs.minFlow == rhs.minFlow
      && lhs.pumpParasticsFullLoad == rhs.pumpParasticsFullLoad
      && lhs.antiFreezeFlow == rhs.antiFreezeFlow
      && lhs.HTFmass == rhs.HTFmass
      && lhs.HTF == rhs.HTF
      && lhs.edgeFactor == rhs.edgeFactor
  }
}
