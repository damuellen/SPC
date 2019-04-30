import AppKit
import Meteo
import BlackBoxModel

extension PerformanceLog: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    let attributes: [NSAttributedString.Key : Any] = [
      .font: NSFont(name: "Menlo", size: 11.0)!,
      .foregroundColor: NSColor.white
    ]
    return NSAttributedString(string: description, attributes: attributes)
  }
}

let 🌦 = Bundle.main.path(forResource: "AlAbdaliyah", ofType: "mto")!
let recorder = PerformanceDataRecorder()

BlackBoxModel.meteoFilePath = 🌦
BlackBoxModel.interval = .every5minutes

//Simulation.adjustmentFactor.efficiencySolarField = 0.99
SolarField.parameter.massFlow.max = MassFlow(2500)

Design.layout.solarField = 140

let result1 = BlackBoxModel.runModel(with: recorder)

result1[\.electric.net, ofDay: 170]

result1[\.solarField.insolationAbsorber, ofDay: 170]

result1[\.thermal.solar.megaWatt, ofDay: 170]

result1[\.thermal.dumping.megaWatt, ofDay: 170]

var best = [result1]

for n in (142...156).reversed() {
  Design.layout.solarField = Double(n)
  var result = BlackBoxModel.runModel(with: recorder)
  let last = best.last!
    if last.thermal.production.watt / last.thermal.solar.watt
      < result.thermal.production.watt / result.thermal.solar.watt
    {
      best.append(result)
    }

  print(n, " ", result.thermal.solar.megaWatt,
        result.thermal.dumping.megaWatt,
        result.thermal.production.megaWatt,
        result.thermal.production.megaWatt / Design.layout.solarField,
        result.thermal.dumping.watt / result.thermal.solar.watt,
        result.thermal.production.watt / result.thermal.solar.watt)
}



