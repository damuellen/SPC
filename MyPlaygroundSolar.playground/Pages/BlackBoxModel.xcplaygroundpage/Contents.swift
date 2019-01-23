import AppKit
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

let path = Bundle.main.path(forResource: "AlAbdaliyah", ofType: "mto")!
BlackBoxModel.meteoFilePath = path
BlackBoxModel.interval = .every5minutes
BlackBoxModel.logger = PerformanceDataLogger()

Simulation.adjustmentFactor.efficiencySolarField = 0.99
Design.layout.solarField = 100

let result = BlackBoxModel.runModel()

print(result.report)

result[\.insolationAbsorber, day: 170]
result[\.dni, day: 88]
result[\.insolationAbsorber, day: 144]
result[\.dni, day: 1]

result[\.electric.gross, day: 140]
result[\.temp, day: 140]

result[\.collector.parabolicElevation, day: 140]
result[\.collector.cosTheta, day: 140]
result[\.collector.cosTheta, day: 4]

result[\.collector.cosTheta, day: 40]
result.annual.thermal.production.megaWatt
