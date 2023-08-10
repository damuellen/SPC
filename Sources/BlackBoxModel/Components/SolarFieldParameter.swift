// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

extension SolarField {
  /// The layout type for the solar field.
  enum Layout: String, Equatable, Codable {
    /// The layout type 'I'.
    case I
    /// The layout type 'H'.
    case H
  }

  /**
  A struct representing the parameters of the solar field.

  The solar field is specified by:
  - the total number of loops
  - number of collectors per loop
  - distance between collectors in a row
  - distance between rows
  - azimuth angle and elevation angle of solar field
  - heat losses in piping
  - maximum wind speed for tracking
  - nominal HTF flow
  - "freeze protection" HTF flow and minimal HTF flow
  - parasitic power as a function of HTF flow
  */
  struct Parameter: Codable {
    /// Whether to consider heat loss of ANY dump collectors.
    var heatlossDump = true
    /// The layout type of the solar field.
    var layout = SolarField.Layout.H
    /// Whether to consider the effect of wind speed on collector efficiency.
    var etaWind = false
    /// Pipe heat losses in tested area [W/sqm].
    var SSFHL: Double = 0.0
    /// Heat losses in the hot header.
    var heatLossHotHeader: [Double]
    /// Whether to consider heat loss of dump collectors in the operating quadrant.
    var heatlossDumpQuad = true
    /// Imbalance design parameters for HTF flow.
    var imbalanceDesign: [Double] = [1.0, 1.0, 1.0]
    /// Minimum imbalance parameters for HTF flow.
    var imbalanceMin: [Double] = [1.03, 1.0, 0.97]
    /// Coefficients for the collector efficiency vs. wind speed equation.
    var windCoefficients: Polynomial = [0.0]
    /// Whether to use the reference ambient temperature from Solpipe.
    var useReferenceAmbientTemperature = true
    /// The reference ambient temperature.
    var referenceAmbientTemperature: Double = 0.0
    /// The design temperature at the inlet of the solar field.
    var designTemperatureInlet: Double = 0.0
    /// The design temperature at the outlet of the solar field.
    var designTemperatureOutlet: Double = 0.0
    /// Maximum wind speed for operation [m/sec].
    let maxWind: Float
    /// Number of collectors in a row.
    let numberOfSCAsInRow: Int
    /// Distance between rows [m].
    var rowDistance: Double
    /// Distance between Collectors in a Row
    var distanceSCA: Double
    /// Heat Losses in total HTF Piping
    var pipeHeatLosses: Double
    /// Azimuth angle of solar field orientation [°].
    var azimut, elevation: Double
    /// Parasitic power for anti-freeze pump [MW].
    var antiFreezeParastics: Double
    /// Parasitic power coefficients for pump power.
    var pumpParastics: Polynomial
    /// Maximum mass flow rate in the solar field.
    var maxMassFlow: MassFlow
    /// Minimum allowable HTF flow as a percentage.
    var minFlow: Ratio
    /// Parasitic power at full load for pump [MW].
    var pumpParasticsFullLoad: Double
    /// Anti-freeze flow as a percentage.
    var antiFreezeFlow: Ratio
    /// Total mass of HTF in the system [kg].
    var HTFmass: Double
    /// The heat transfer fluid used in the solar field.
    var HTF: HeatTransferFluid
    /// Edge factor for the solar field.
    var edgeFactor: [Double] = []
    /// The ratio of the pipe length to the loop ways.
    var distRatio: Double = 0
    /// The total pipe way length.
    var pipeWay: Double = 0
    /// The lengths of the loop ways.
    var loopWays: [Double] = []
    /// The heat losses in each loop.
    var heatlosses: [Double] = []
  }
}

extension SolarField.Parameter {
  /// Calculates the way lengths for the solar field.
  mutating func calculateWayLengths() {
    let multiplier = Double(numberOfSCAsInRow)
    let designWay =
      multiplier * (Collector.parameter.lengthSCA + distanceSCA) * 2.0
      + rowDistance

    var nearWay = multiplier * (Collector.parameter.lengthSCA + distanceSCA)

    var avgWay = Design.layout.solarField / 4 * rowDistance / 2
    var farWay: Double = (2 * (Design.layout.solarField / 4 * rowDistance / 2))

    if layout == .I {
      avgWay = avgWay + 0.5
    } else {
      nearWay = nearWay * 2 + rowDistance + 0.5
      avgWay += nearWay
      farWay += nearWay
    }

    self.loopWays = [designWay, nearWay, avgWay, farWay]
    self.distRatio = pipeWay / (2 * loopWays[1])
    self.pipeWay = loopWays[1] + 2 * loopWays[2]
  }
}

extension SolarField.Parameter: CustomStringConvertible {
  /// A description of the `SolarField.Parameter` instance.
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
      + "Parasitics(Load) = Parasitics(100%)*(c0+c1*load+c2*load^2)"
      + "\n\(pumpParastics)" + "Tilt of Collectors [°]:"
      * elevation.description + "Mass Flow in Solar Field at Full Load [kg/s]:"
      * String(format: "%.1f", maxMassFlow.rate)
      + "Minimum allowable Mass Flow [%]:" * minFlow.percentage.description
      + "Anti-Freeze Mass Flow [%]:" * antiFreezeFlow.percentage.description
      + "Total Mass of HTF in System [kg]:" * String(format: "%.1f", HTFmass)
      + "Consider HL of ANY Dump. Collectors:" * (heatlossDump ? "YES" : "NO ")
      + "Consider HL of Dump. Col. for operating quadrant:"
      * (heatlossDumpQuad ? "YES" : "NO ")
      + "Consider SKAL-ET DemoLoop Effect of Wind Speed.:"
      * (etaWind ? "YES" : "NO ")
      + (windCoefficients.isEmpty == false
        ? "Collector efficiency vs Wind Speed c0+c1*WS+c2*WS^2+c3*WS^3+c4*WS^4+c5*WS^5"
          + "\n\(windCoefficients)" : "") + "Layout Design Type:"
      * layout.rawValue + "Heat Losses in Hot Header [MW]:"
      * String(format: "%G", heatLossHotHeader[0])
      + (heatLossHotHeader.count > 1
        ? "Heat Losses in Hot Header Coefficients;\nHL(Tout - Tamb) = HL(design)*(c0+c1*dT)"
          + "\n\(Polynomial(heatLossHotHeader))" : "")
      + "Use Reference T_amb from Solpipe:"
      * (useReferenceAmbientTemperature ? "YES" : "NO ")
      + "Design SOF T_inlet [°C]:"
      * String(format: "%G", designTemperatureInlet)
      + "Design SOF T_outlet [°C]:"
      * String(format: "%G", designTemperatureOutlet) + "HTF Flow Imbalance\n"
      + "Near, Design:" * imbalanceDesign[0].description + "Average, Design:"
      * imbalanceDesign[1].description + "Far, Design:"
      * imbalanceDesign[2].description + "Near, Minimum:"
      * imbalanceMin[0].description + "Average, Minimum:"
      * imbalanceMin[1].description + "Far, Minimum:"
      * imbalanceMin[2].description
  }
}

extension SolarField.Parameter: TextConfigInitializable {
  /// Creates a `SolarField.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
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
    HTF = HeatTransferFluid.VP1
    heatLossHotHeader = try [ln(66), ln(67), ln(68)]
    imbalanceDesign = try [ln(72), ln(73), ln(74)]
    imbalanceMin = try [ln(75), ln(76), ln(77)]
    windCoefficients = try [ln(79), ln(80), ln(81), ln(82), ln(83), ln(84)]
    useReferenceAmbientTemperature = try ln(86) > 0 ? true : false
    referenceAmbientTemperature = try ln(87)
    designTemperatureInlet = try ln(89)
    designTemperatureOutlet = try ln(90)
    heatlosses = try [ln(93), ln(96), ln(99), ln(102), ln(105)]
  }
}
