import AppKit
import Meteo
import BlackBoxModel

let nf = NumberFormatter()
nf.minimumFractionDigits = 1
nf.minimumIntegerDigits = 1
func prettyPrint<T>(_ values: T..., separator: String) where T: Numeric {
  if values is [Double] {
    print(values.map { NSNumber(value:$0 as! Double) }
      .compactMap(nf.string(from:)).joined(separator: separator))
  } else if values is [Int] {
    print(values.map { String($0 as! Int) }.joined(separator: separator))
  }
}

extension PerformanceLog: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    let attributes: [NSAttributedString.Key : Any] = [
      .font: NSFont(name: "Menlo", size: 16.0)!,
      .foregroundColor: NSColor.white
    ]
    return NSAttributedString(string: description, attributes: attributes)
  }
}

let 🌦 = Bundle.main.path(forResource: "AlAbdaliyah", ofType: "mto")!
let recorder = PerformanceDataRecorder()
let recorder2 = PerformanceDataRecorder()
BlackBoxModel.configure(meteoFilePath: 🌦)
Simulation.time.steps = .every5minutes

//Simulation.adjustmentFactor.efficiencySolarField = 0.99
SolarField.parameter.massFlow = MassFlow(2500)

Design.layout.solarField = 140

let result1 = BlackBoxModel.runModel(with: recorder)

result1[\.collector.insolationAbsorber, ofDay: 188].sum()
let a = Array(result1[\.collector.insolationAbsorber, ofDay: 200]).filter {$0 > 0}
a.mean()
var best = result1
let log = PerformanceDataRecorder(noHistory: true)

for n in (142...156).reversed() {
  Design.layout.solarField = Double(n)
  var result = BlackBoxModel.runModel(with: log)

  if best.thermal.production.watt / best.thermal.solar.watt
    < result.thermal.production.watt / result.thermal.solar.watt
  {
    best = result
  }

  prettyPrint(Double(n), result.thermal.solar.megaWatt,
        result.thermal.dumping.megaWatt,
        result.thermal.production.megaWatt,
        result.thermal.production.megaWatt / Design.layout.solarField,
        result.thermal.dumping.watt / result.thermal.solar.watt,
        result.thermal.production.watt / result.thermal.solar.watt,
        separator: "\t\t")
}

best
