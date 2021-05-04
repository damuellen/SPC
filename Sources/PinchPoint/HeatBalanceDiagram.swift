//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import PhysicalQuantities
import CPikchr
import Helpers

extension HeatExchanger {
  var inlet: Stream {
    Stream(temperature.ws.inlet, pressure.ws.inlet, massFlow.ws, enthalpy.ws.inlet)
  }

  var outlet: Stream {
    Stream(temperature.ws.outlet, pressure.ws.outlet, massFlow.ws, enthalpy.ws.outlet)
  }

  var htf: Stream {
    Stream(temperature.htf.inlet, 0, massFlow.htf, enthalpy.htf.inlet)
  }
}


struct HeatBalanceDiagram {
  init(values: PinchPoint) {
    self.streams = [
      Stream(values.mixHTFTemperature, 0, values.mixHTFMassflow, values.mixHTFAbsoluteEnthalpy),
      values.economizer.htf, //htf_outlet
      values.economizer.inlet,
      values.economizer.outlet,
      values.steamGenerator.inlet,
      values.steamGenerator.outlet,
      values.superheater.inlet,
      values.superheater.outlet,
      values.reheater.inlet,
      values.reheater.outlet,
      values.reheater.htf, // inlet
      values.superheater.outlet, // above
      values.economizer.htf, //sh_outlet
      values.steamGenerator.htf, //outlet
      values.reheater.htf, //rh_outlet
      values.superheater.htf, //sh_inlet
      Stream(values.upperHTFTemperature, 0, values.mixHTFMassflow, values.superheater.enthalpy.htf.inlet),
    ]
    self.singleValues = [("LMTD","1"),("LMTD","1"),("Blowdown","1"),("LMTD","1"),("LMTD","1")]
  }

  init?(streams: [Stream], singleValues: [(String, String)]) {
    guard streams.count == 17, singleValues.count == 5 else { return nil }
    self.streams = streams
    self.singleValues = singleValues
  }

  struct Stream {
    var temperature: String
    var massFlow: String
    var enthalpy: String
    var pressure: String

    init(stream: WaterSteam) {
      self.temperature = String(format: "%.2f °C", stream.temperature.celsius)
      self.massFlow = String(format: "%.1f kg/s", stream.massFlow)
      self.enthalpy = String(format: "%.1f kJ/kg", stream.enthalpy)
      self.pressure = String(format: "%.2f bar", stream.pressure)
    }

    init(
      _ temperature: Temperature, _ pressure: Double,
      _ massFlow: Double, _ enthalpy: Double) {
      self.temperature = String(format: "%.2f °C", temperature.celsius)
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

  var svg: String {
    let diagram = """
    RH: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "RH" thick
    ]

    line invis down 5cm

    SH: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "SH" thick
    ] with .end at previous.end

    line invis down 5cm

    SG: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "SG" thick
    ]with .end at previous.end

    line invis down 5cm

    EC: [
      boxwid = 0.75; boxht = 0.75;
      line left 1.0cm then up .5cm right .5cm then up .5cm left .5cm then right 1cm
      down; line invis down .5cm; left; box "EC" thick
    ] with .end at previous.end

    line invis right 15cm up 2cm

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
      box "\(singleValues[0].0)" thin;right
      box "\(singleValues[0].1)" thin
    ] with .ne at previous

    line invis up 2cm right 2cm
    \(streams[3].boxLabel) with .s at previous

    line invis up 2cm
    \(streams[4].boxLabel) with .s at previous

    line invis up 2.5cm left 2cm
    [
      box "\(singleValues[1].0)" thin;right
      box "\(singleValues[1].1)" thin
    ] with .ne at previous

    line invis up 1.25cm right 10cm
    [
      box "\(singleValues[2].0)" thin;right
      box "\(singleValues[2].1)" thin
    ] with .ne at previous

    line invis up 1.25cm left 8cm
    \(streams[5].boxLabel) with .s at previous

    line invis up 2cm
    \(streams[6].boxLabel) with .s at previous

    line invis up 2.5cm left 2cm
    [
      box "\(singleValues[3].0)" thin;right
      box "\(singleValues[3].1)" thin
    ] with .ne at previous

    line invis up 2cm right 2cm
    \(streams[7].boxLabel) with .sw at previous

    line invis up 2cm
    \(streams[8].boxLabel) with .s at previous

    line invis up 4cm
    \(streams[9].boxLabel) with .s at previous

    line invis left 3cm
    [
      box "\(singleValues[4].0)" thin;right
      box "\(singleValues[4].1)" thin
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
    let style = """
    <style media="print">
      svg.c {width: 28.2cm; height: 20.6cm; font-family: sans-serif; margin-left: 0.5cm;}
    </style>
    """
    return style + svg
  }
}