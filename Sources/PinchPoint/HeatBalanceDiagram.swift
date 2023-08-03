// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import CPikchr
import Libc
import Utilities

typealias Stream = HeatBalanceDiagram.Stream

extension HeatExchanger {
  var steamSide: (inlet: Stream, outlet: Stream) {
    (
      Stream(temperature.ws.inlet, pressure.ws.inlet, massFlow.ws.inlet, enthalpy.ws.inlet),
      Stream(temperature.ws.outlet, pressure.ws.outlet, massFlow.ws.outlet, enthalpy.ws.outlet)
    )
  }

  var htfSide: (inlet: Stream, outlet: Stream) {
    (
      Stream(temperature.htf.inlet, 0, massFlow.htf, enthalpy.htf.inlet),
      Stream(temperature.htf.outlet, 0, massFlow.htf, enthalpy.htf.outlet)
    )
  }

  var LMTD: String {
    String(
      format: "%.2f",
      ((temperature.htf.outlet.kelvin - temperature.ws.inlet.kelvin)
        - (temperature.htf.inlet.kelvin - temperature.ws.outlet.kelvin))
        / (log(
          (temperature.htf.outlet.kelvin - temperature.ws.inlet.kelvin)
            / (temperature.htf.inlet.kelvin - temperature.ws.outlet.kelvin))))
  }
}

/// Heat Balance Diagram
///
/// Schematic representation of the whole steam cycle.
public struct HeatBalanceDiagram {
  public init(values: Calculation) {
    self.streams = [
      Stream(
       values.mixHTFTemperature, 0,
       values.mixHTFMassflow, values.mixHTFAbsoluteEnthalpy),
      values.economizer.htfSide.outlet,
      values.economizer.steamSide.inlet,
      values.economizer.steamSide.outlet,
      values.steamGenerator.steamSide.inlet,
      values.steamGenerator.steamSide.outlet,
      values.superheater.steamSide.inlet,
      Stream(
        values.turbine.temperature, values.turbine.pressure,
        values.turbine.massFlow, values.turbine.enthalpy),
      values.reheater.steamSide.inlet,
      values.reheater.steamSide.outlet,
      values.reheater.htfSide.inlet,
      values.superheater.steamSide.outlet,
      values.superheater.htfSide.outlet,
      values.steamGenerator.htfSide.outlet,
      values.reheater.htfSide.outlet,
      values.superheater.htfSide.inlet,
      Stream(
        values.upperHTFTemperature, 0,
        values.mixHTFMassflow, values.superheater.enthalpy.htf.inlet),
    ]
    self.singleValues = [

      ("RH", String(format: "%.2f MW", values.reheater.power)),
      ("SH", String(format: "%.2f MW", values.superheater.power)),
      ("SG", String(format: "%.2f MW", values.steamGenerator.power)),
      ("EC", String(format: "%.2f MW", values.economizer.power)),
      ("LMTD", values.economizer.LMTD),
      ("LMTD", values.steamGenerator.LMTD),
      ("Blow Down", String(format: "%.2f kg/s", values.blowDownMassFlow)),
      ("LMTD", values.superheater.LMTD),
      ("LMTD", values.reheater.LMTD),
    ]
  }

  init?(streams: [Stream], singleValues: [(String, String)]) {
    guard streams.count == 17, singleValues.count == 9 else { return nil }
    self.streams = streams
    self.singleValues = singleValues
  }

  struct Stream {
    var temperature: String
    var massFlow: String
    var enthalpy: String
    var pressure: String

    init(stream: WaterSteam) {
      self.temperature = String(format: "%.1f °C", stream.temperature.celsius)
      self.massFlow = String(format: "%.1f kg/s", stream.massFlow)
      self.enthalpy = String(format: "%.1f kJ/kg", stream.enthalpy)
      self.pressure = String(format: "%.2f bar", stream.pressure)
    }

    init(_ temperature: Temperature, _ pressure: Double, _ massFlow: Double, _ enthalpy: Double) {
      self.temperature = String(format: "%.1f °C", temperature.celsius)
      self.massFlow = String(format: "%.1f kg/s", massFlow)
      self.enthalpy = String(format: "%.1f kJ/kg", enthalpy)
      self.pressure = pressure > 0 ? String(format: "%.2f bar", pressure) : ""
    }

    var boxLabel: String {
      """
      [
        box "\(temperature)" thin;down;
        box "\(massFlow)" thin;right
        box "\(enthalpy)" thin;up
        box "\(pressure)" thin
      ]
      """
    }
  }

  var streams: [Stream]
  var singleValues: [(String, String)]

  public var svg: String {
    let diagram = """
    RH: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "\(singleValues[0].0)" thick
      down; "\(singleValues[0].1)"; line invis left.5cm;
    ]

    line invis down 5cm

    SH: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "\(singleValues[1].0)" thick
      down; "\(singleValues[1].1)"; line invis left.5cm;
    ] with .end at previous.end

    line invis down 5cm

    SG: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "\(singleValues[2].0)" thick
      down; "\(singleValues[2].1)"; line invis left.5cm;

    ]with .end at previous.end

    line invis down 5cm

    EC: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "\(singleValues[3].0)" thick
    down; "\(singleValues[3].1)"; line invis left.5cm;
    ] with .end at previous.end

    line invis right 15cm up 2.25cm

    CO: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "CO" thick
    ] with .end at previous.end

    line invis down 1cm right 1cm
    arrow down 1.5cm then left 4cm

    [
      P0: circle radius .2
      line from P0.s to P0.w
      line to P0.n
    ]

    arrow left 9cm
    line invis left 2cm
    arrow left 10cm

    boxht = 0.2
    \(streams[0].boxLabel) with .e at previous.end

    line invis right 7cm down 1cm
    \(streams[1].boxLabel) with .n at previous.end

    line invis right 20cm
    \(streams[2].boxLabel) with .nw at previous

    line invis up 2.5cm left 2cm
    [
      box "\(singleValues[4].0)" thin;right
      box "\(singleValues[4].1)" thin
    ] with .ne at previous

    line invis up 2cm right 2cm
    \(streams[3].boxLabel) with .s at previous

    line invis up 2cm
    \(streams[4].boxLabel) with .s at previous

    line invis up 2.5cm left 2cm
    [
      box "\(singleValues[5].0)" thin;right
      box "\(singleValues[5].1)" thin
    ] with .ne at previous

    line invis up 1.25cm right 10cm
    [
      box "\(singleValues[6].0)" thin;right
      box "\(singleValues[6].1)" thin
    ] with .ne at previous

    line invis up 1.25cm left 8cm
    \(streams[5].boxLabel) with .s at previous

    line invis up 2cm
    \(streams[6].boxLabel) with .s at previous

    line invis up 2.5cm left 2cm
    [
      box "\(singleValues[7].0)" thin;right
      box "\(singleValues[7].1)" thin
    ] with .ne at previous

    line invis up 2cm right 2cm
    \(streams[7].boxLabel) with .sw at previous

    line invis up 2cm
    \(streams[8].boxLabel) with .s at previous

    line invis up 4cm
    \(streams[9].boxLabel) with .s at previous

    line invis left 3cm
    [
      box "\(singleValues[8].0)" thin;right
      box "\(singleValues[8].1)" thin
    ] with .ne at previous.nw

    line invis left 18cm then up 0.5cm
    \(streams[10].boxLabel) with .ne at previous

    line invis down 9cm right 12cm
    \(streams[11].boxLabel) with .n at previous

    line invis down 9cm left 12cm
    \(streams[12].boxLabel) with .n at previous

    line invis down 10cm
    \(streams[13].boxLabel) with .n at previous

    line invis left 10cm up 4cm
    \(streams[14].boxLabel) with .e at previous

    line invis up 13cm
    \(streams[15].boxLabel) with .s at previous

    line invis up 3.7cm
    \(streams[16].boxLabel) with .s at previous

    arrow from previous.e right 10cm
    line invis down 1cm
    arrow left 8cm then down 15cm
    line invis up 16cm left 1cm
    arrow down 5cm then right 9cm
    line invis down 1cm
    arrow left 2cm then down 4cm then right 2cm
    line invis down 1cm
    arrow left 2cm then down 4cm then right 2cm
    line invis right 2cm
    arrow right 2cm then up 4cm then left 2cm
    line invis up 1cm
    arrow right 2cm then up 4cm then left 2cm
    line invis up 1cm
    arrow right 2cm then up 2cm then right 8cm then down 5cm
    line invis right 1.5cm
    arrow up 7cm then left 11.5cm
    line invis up 1cm
    arrow right 2cm then right 10cm then down 7.5cm
    line invis down 2cm right 2cm
    arrow down 3cm
    line invis left 4cm up 3.5cm
    line up 1.0cm then up .5cm right 1.5cm then down 2cm then left 1.5cm up .5cm thick
    line invis right 1.5cm up .5cm
    line right .5cm thickness 0.1
    line invis down 1cm
    line up 2.0cm then up 0.75cm right 2cm then down 3.5cm then left 2cm up .75cm thick
    line invis up 1cm right 2cm
    line right .5cm thickness 0.1
    circle "G" big big
    """
    let svg = diagram.withCString { String(cString: pikchr($0, "c", 0, nil, nil)) }
    return svg
  }
}
