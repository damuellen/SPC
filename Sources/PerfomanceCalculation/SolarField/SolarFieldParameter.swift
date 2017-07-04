//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Config

extension SolarField {
  public struct Parameter: ModelParameter {
    let HLDump = false
    let layout = ""
    let EtaWind = false
    let SSFHL: Double = 0.0
    let heatLossHeader: [Double] = [0.0]
    let HLDumpQuad = false
    var imbalanceDesign: (near: Double, average: Double, far: Double) =
      ( 1.0, 1.0, 1.0)
    var imbalanceMin: (near: Double, average: Double, far: Double) =
      (0.0, 1.025, 1.05)
    var windCoefficients: Coefficients = []
    var useReferenceAmbientTemperature = true
    var referenceAmbientTemperature: Double = 0.0
    var heatlosses: [Double] = [0.0]
    var designTemperature: (inlet: Double, outlet: Double) = (0.0, 0.0)
    let name: String
    let maxWind: Float
    let numberOfSCAsInRow: Int
    let rowDistance, distanceSCA, pipeHL, azim, elev: Double
    let antiFreezeParastics: Double
    let pumpParastics: Coefficients
    var massFlow: (max: Double, min: Double)
    var pumpParasticsFullLoad, antiFreezeFlow: Double
    var HTFmass: Double
    var collector: Collector.Parameter! = nil
    var EdgeFac: [Double] = []
  }
}

extension SolarField.Parameter {
  
  var loopWay: Double {
    return Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA) * 2.0 + rowDistance
  }
  
  var nearWay: Double {
    return Double(numberOfSCAsInRow)
      * (Collector.parameter.lengthSCA + distanceSCA) * 2 + rowDistance + 0.5
  }
  
  var avgWay: Double { return 0.0 }
  var farWay: Double { return 0.0 }
  /*
   If SFc.Layout = "I" Then
   'no change
   Else
   var nearWay: Double = Int(1 * (SFc.NSCAsInRow * (SFc.SCAlen + SFc.SCAdist)))
   var avgWay = Int(1# * (Design.layout.solarField. / 4 * SFc.Rowdist / 2)) + SFc.nearWay
   End If
   If SFc.Layout = "I" Then
   var farWay: Double = Int(2# * (Design.layout.solarField. / 4 * SFc.Rowdist / 2)) ' MH No2: + SFc.nearWay
   Else
   var farWay = Int(2# * (Design.layout.solarField. / 4 * SFc.Rowdist / 2)) + SFc.nearWay
   End If */
}

extension SolarField.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:"
      >< "\(name)"
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
      >< "\(massFlow.max)"
    d += "Minimum allowable Mass Flow [%]:"
      >< "\(massFlow.min)"
    d += "Anti-Freeze Mass Flow [%]:"
      >< "\(antiFreezeFlow)"
    d += "Total Mass of HTF in System [kg]:"
      >< "\(HTFmass)"
    d += "Consider HL of ANY Dump. Collectors:"
      >< (HLDump ? "YES" : "NO ")
    d += "Consider HL of Dump. Col. for operating quadrant:"
      >< (HLDumpQuad ? "YES" : "NO ")
    d += "Consider SKAL-ET DemoLoop Effect of Wind Speed.:"
      >< (EtaWind ? "YES" : "NO ")
    d += "Collector efficiency from Wind Speed = c0+c1*WS+c2*WS^2+c3*WS^3+c4*WS^4+c5*WS^5\n"
    for idx in windCoefficients.coefficients {
      d += "c\(idx):" >< "\(windCoefficients[idx])"
    }
    d += "Layout Design Type:"
      >< "\(Design.layout.solarField)"
    d += "Heat Losses in Hot Header [MW]:"
      >< "\(heatLossHeader)"
    d += "Heat Losses in Hot Header Coefficients; HL(Tout - Tamb) = HL(design)*(c0+c1*dT)\n"
    for idx in heatlosses.indices {
      d += "c\(idx):" >< "\(heatlosses[idx])"
    }
    d += "Use Reference T_amb from Solpipe:"
      >< (useReferenceAmbientTemperature ? "YES" : "NO ")
    d += "Design SOF T_inlet [°C]:"
      >< "\(designTemperature.inlet)"
    d += "Design SOF T_outlet [°C]:"
      >< "\(designTemperature.outlet)"
    d += "HTF Flow Imbalance\n"
    d += "Near, Design:"
      >< "\(imbalanceDesign.near)"
    d += "Average, Design:"
      >< "\(imbalanceDesign.average)"
    d += "Far, Design:"
      >< "\(imbalanceDesign.far)"
    d += "Near, Minimum:"
      >< "\(imbalanceMin.near)"
    d += "Average, Minimum:"
      >< "\(imbalanceMin.average)"
    d += "Far, Minimum:"
      >< "\(imbalanceMin.far)"
    return d
  }
}

extension SolarField.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.double(row: $0) }
    self.name = file.name
    self.maxWind = Float(try row(10))
    self.numberOfSCAsInRow = Int(try row(13))
    self.rowDistance = try row(16)
    self.distanceSCA = try row(19)
    self.pipeHL = try row(22)
    self.azim = try row(25)
    self.elev = try row(28)
    self.pumpParasticsFullLoad = try row(34)
    self.antiFreezeParastics = try row(37)
    self.pumpParastics = .init(try file.doubles(rows: 40, 43, 46))
    self.massFlow = (try row(49), try row(52))
    self.antiFreezeFlow = try row(55)
    self.HTFmass = try row(58)
    self.imbalanceDesign = (try row(72), try row(73), try row(74))
    self.imbalanceMin = (try row(75), try row(76), try row(77))
    self.windCoefficients = .init(try file.doubles(rows: 79, 80, 81, 82, 83, 84))
    self.useReferenceAmbientTemperature = try row(86) > 0 ? true : false
    self.referenceAmbientTemperature = try row(87)
    self.designTemperature = (try row(89), try row(90))
    self.heatlosses = .init(try file.doubles(rows: 93, 96, 99, 102, 105))
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
    case azim
    case elev
    case pumpParasticsFullLoad
    case antiFreezeParastics
    case pumpParastics
    case maxMassFlow
    case minMassFlow
    case antiFreezeFlow
    case HTFmass
    case imbalanceDesignNear
    case imbalanceDesignAverage
    case imbalanceDesignFar
    case imbalanceMinNear
    case imbalanceMinAverage
    case imbalanceMinFar
    case windCoefficients
    case useReferenceAmbientTemperature
    case referenceAmbientTemperature
    case inletDesignTemperature
    case outletDesignTemperature
    case Heatlosses
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try values.decode(String.self, forKey: .name)
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
      try values.decode(Double.self, forKey: .maxMassFlow),
      try values.decode(Double.self, forKey: .minMassFlow))
    self.antiFreezeFlow = try values.decode(Double.self, forKey: .antiFreezeFlow)
    self.HTFmass = try values.decode(Double.self, forKey: .HTFmass)
    self.imbalanceDesign = (
      try values.decode(Double.self, forKey: .imbalanceDesignNear),
      try values.decode(Double.self, forKey: .imbalanceDesignAverage),
      try values.decode(Double.self, forKey: .imbalanceDesignFar))
    self.imbalanceMin = (
      try values.decode(Double.self, forKey: .imbalanceMinNear),
      try values.decode(Double.self, forKey: .imbalanceMinAverage),
      try values.decode(Double.self, forKey: .imbalanceMinFar))
    self.windCoefficients = try values.decode(
      Coefficients.self, forKey: .windCoefficients)
    self.useReferenceAmbientTemperature = try values.decode(
      Bool.self, forKey: .useReferenceAmbientTemperature)
    self.referenceAmbientTemperature = try values.decode(
      Double.self, forKey: .referenceAmbientTemperature)
    self.designTemperature = (
      try values.decode(Double.self, forKey: .inletDesignTemperature),
      try values.decode(Double.self, forKey: .outletDesignTemperature))
    self.heatlosses = try values.decode(Array<Double>.self, forKey: .Heatlosses)
    
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
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
    try container.encode(imbalanceDesign.near, forKey: .imbalanceDesignNear)
    try container.encode(imbalanceDesign.average, forKey: .imbalanceDesignAverage)
    try container.encode(imbalanceDesign.far, forKey: .imbalanceDesignFar)
    try container.encode(imbalanceMin.near, forKey: .imbalanceMinNear)
    try container.encode(imbalanceMin.average, forKey: .imbalanceMinAverage)
    try container.encode(imbalanceMin.far, forKey: .imbalanceMinFar)
    try container.encode(windCoefficients, forKey: .windCoefficients)
    try container.encode(useReferenceAmbientTemperature,
                         forKey: .useReferenceAmbientTemperature)
    try container.encode(referenceAmbientTemperature,
                         forKey: .referenceAmbientTemperature)
    try container.encode(designTemperature.inlet, forKey: .inletDesignTemperature)
    try container.encode(designTemperature.outlet, forKey: .outletDesignTemperature)
    try container.encode(heatlosses, forKey: .Heatlosses)
  }
}
