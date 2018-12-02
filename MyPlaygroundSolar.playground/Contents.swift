import Foundation
import BlackBoxModel

typealias PC = PerformanceCalculator

let path = Bundle.main.path(forResource: "AlAbdaliyah",
                            ofType: "mto")!
PC.meteoFilePath = path
PC.interval = .every5minutes
Simulation.adjustmentFactor.efficiencySolarField = 0.99
Design.layout.solarField = 100
PC.logger = PerformanceDataLogger()
var results = PerformanceCalculator.runModel()

results[\.insolationAbsorber, day: 170]
results[\.dni, day: 88]
results[\.insolationAbsorber, day: 144]
results[\.dni, day: 1]
results[\.solarField.inFocus.percentage, day: 40]
results[\.solarField.inFocus.percentage, day: 130]

results[\.electric.gross, day: 140]
results[\.temp, day: 140]

results[\.collector.parabolicElevation, day: 140]
results[\.collector.cosTheta, day: 140]
results[\.collector.cosTheta, day: 4]

results[\.collector.cosTheta, day: 40]
results.annual.thermal.production

log = goalSeek(\.thermal.production, greaterThen: 194000) {
  Design.layout.solarField += 1
}

Design.layout.solarField
log
