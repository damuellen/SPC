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
  public struct Parameter: ComponentParameter {
    let HLDump = false
    let layout = ""
    let EtaWind = false
    let SSFHL: Double = 0.0
    let heatLossHeader: [Double] = [20]
    let HLDumpQuad = false
    var imbalanceDesign: [Double] = [1.0, 1.0, 1.0]
    var imbalanceMin: [Double] = [0.0, 1.025, 1.05]
    var windCoefficients: Coefficients = [0.0]
    var useReferenceAmbientTemperature = true
    var referenceAmbientTemperature: Double = 0.0
    var heatlosses: Coefficients = [0.0]
    var designTemperature: (inlet: Double, outlet: Double) = (0.0, 0.0)
    let maxWind: Float
    let numberOfSCAsInRow: Int
    let rowDistance, distanceSCA, pipeHL, azim, elev: Double
    let antiFreezeParastics: Double
    let pumpParastics: Coefficients
    var massFlow: (max: MassFlow, min: MassFlow)
    var pumpParasticsFullLoad: Double
    var antiFreezeFlow: MassFlow
    var HTFmass: Double
    var collector: Collector.Parameter! = nil
    var edgeFactor: [Double] = []
  }
}

extension SolarField.Parameter {
  
  var distRatio: Double {
    return pipeWay / (2 * loopWays[1])
  }
  
  var pipeWay: Double {
    return loopWays[1] + 2 * loopWays[2]
  }
  
  var loopWays: [Double] {
    let designWay = Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA) * 2.0 + rowDistance

    var nearWay = Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA)
    nearWay = layout == "I"
      ? nearWay
      : nearWay * 2 + rowDistance + 0.5

    var avgWay = Design.layout.solarField / 4 * rowDistance / 2
    avgWay = layout == "I"
      ? avgWay + 0.5
      : avgWay + nearWay

    var farWay: Double = (2 * (Design.layout.solarField / 4 * rowDistance / 2))
    farWay = layout == "I"
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
      >< "\(pipeHL)"
    d += "Heat Losses in Piping of tested field (per sqm aperture) [W/m²]:"
      >< "\(SSFHL)"
    d += "Azimuth angle of Solar Field Orientation [°]:"
      >< "\(azim)"
    d += "Mass Flow in Solar Field at Full Load [kg/s]:"
      >< massFlow.max.description
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
    if !windCoefficients.isEmpty {
      d += "Collector efficiency from Wind Speed = c0+c1*WS+c2*WS^2+c3*WS^3+c4*WS^4+c5*WS^5\n"
      for idx in windCoefficients.indices {
        d += "c\(idx):" >< "\(windCoefficients[idx])"
      }
    }
    d += "Layout Design Type:"
      >< "\(Design.layout.solarField)"
    d += "Heat Losses in Hot Header [MW]:"
      >< "\(heatLossHeader)"
    if !heatlosses.isEmpty {
      d += "Heat Losses in Hot Header Coefficients; HL(Tout - Tamb) = HL(design)*(c0+c1*dT)\n"
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
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.maxWind = Float(try row(10))
    self.numberOfSCAsInRow = Int(try row(13))
    self.rowDistance = try row(16)
    self.distanceSCA = try row(19)
    self.pipeHL = try row(22)
    self.azim = try row(25)
    self.elev = try row(28)
    self.pumpParasticsFullLoad = try row(34)
    self.antiFreezeParastics = try row(37)
    self.pumpParastics = try [row(40), row(43), row(46)]
    self.massFlow = try (MassFlow(row(49)), MassFlow(row(52)))
    self.antiFreezeFlow = try MassFlow(row(55))
    self.HTFmass = try row(58)
    self.imbalanceDesign = try [row(72), row(73), row(74)]
    self.imbalanceMin = try [row(75), row(76), row(77)]
    self.windCoefficients = try [row(79), row(80), row(81), row(82), row(83), row(84)]
    self.useReferenceAmbientTemperature = try row(86) > 0 ? true : false
    self.referenceAmbientTemperature = try row(87)
    self.designTemperature = (try row(89), try row(90))
    self.heatlosses = try [row(93), row(96), row(99), row(102), row(105)]
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
    case azim, elev
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
    self.maxWind = try values.decode(Float.self, forKey: .maxWind)
    self.numberOfSCAsInRow = try values.decode(
      Int.self, forKey: .numberOfSCAsInRow)
    self.rowDistance = try values.decode(Double.self, forKey: .rowDistance)
    self.distanceSCA = try values.decode(Double.self, forKey: .distanceSCA)
    self.pipeHL = try values.decode(Double.self, forKey: .pipeHL)
    self.azim = try values.decode(Double.self, forKey: .azim)
    self.elev = try values.decode(Double.self, forKey: .elev)
    self.pumpParasticsFullLoad = try values.decode(
      Double.self, forKey: .pumpParasticsFullLoad)
    self.antiFreezeParastics = try values.decode(
      Double.self, forKey: .antiFreezeParastics)
    self.pumpParastics = try values.decode(
      Coefficients.self, forKey: .pumpParastics)
    self.massFlow = (
      try values.decode(MassFlow.self, forKey: .maxMassFlow),
      try values.decode(MassFlow.self, forKey: .minMassFlow))
    self.antiFreezeFlow = try values.decode(MassFlow.self, forKey: .antiFreezeFlow)
    self.HTFmass = try values.decode(Double.self, forKey: .HTFmass)
    self.imbalanceDesign = [
      try values.decode(Double.self, forKey: .imbalanceDesignNear),
      try values.decode(Double.self, forKey: .imbalanceDesignAverage),
      try values.decode(Double.self, forKey: .imbalanceDesignFar)]
    self.imbalanceMin = [
      try values.decode(Double.self, forKey: .imbalanceMinNear),
      try values.decode(Double.self, forKey: .imbalanceMinAverage),
      try values.decode(Double.self, forKey: .imbalanceMinFar)]
    self.windCoefficients = try values.decode(
      Coefficients.self, forKey: .windCoefficients)
    self.useReferenceAmbientTemperature = try values.decode(
      Bool.self, forKey: .useReferenceAmbientTemperature)
    self.referenceAmbientTemperature = try values.decode(
      Double.self, forKey: .referenceAmbientTemperature)
    self.designTemperature = (
      try values.decode(Double.self, forKey: .inletDesignTemperature),
      try values.decode(Double.self, forKey: .outletDesignTemperature))
    self.heatlosses = try values.decode(Coefficients.self, forKey: .heatlosses)
    
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(maxWind, forKey: .maxWind)
    try container.encode(numberOfSCAsInRow, forKey: .numberOfSCAsInRow)
    try container.encode(rowDistance, forKey: .rowDistance)
    try container.encode(distanceSCA, forKey: .distanceSCA)
    try container.encode(pipeHL, forKey: .pipeHL)
    try container.encode(azim, forKey: .azim)
    try container.encode(elev, forKey: .elev)
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
