//
//  Branch.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public struct Branch {

  public var name: String = ""
  let roughness = 0.1

  var nps: Float
  var schedule: NominalPipeSizes
  var temperature: Double
  var length: Double
  var massFlow: Double = 0.0

  /// Array containing valves, elbows, and other fixtures
  var components: [Component] = []

  public init(
    temperature: Double, nps: Float = 12.0, SCH: NominalPipeSizes = .sch40) {
    self.schedule = SCH
    self.length = 0.0
    self.temperature = temperature
    self.nps = nps
  }

  /// The branch diameter is determined automatically, so that the design
  /// flow velocity is not exceeded at the specified mass flow.
  init(temperature: Double, massFlow: Double,
       SCH: NominalPipeSizes = .sch40, header: Piping) {
    self.schedule = SCH
    self.length = 0.0
    self.temperature = temperature
    self.nps = 10.0
    self.massFlow = massFlow
    adjustSize(toStreamVelocity: header.streamVelocity)
  }

  /// Returns the appropriate insultation thickness for the diameter and the temperature.
  var insulationThickness: Double {
    guard let i = NominalPipeSizes.values.firstIndex(of: nps),
      i < Insulation.cold.count else { return 0.0 }
    return temperature < 350.0
      ? Double(Insulation.cold[i])
      : Double(Insulation.hot[i])
  }

  /// Returns the outside diameter of the branch.
  var outsideDiameter: Double {
    guard let i = NominalPipeSizes.values.firstIndex(of: nps) else { return 0.0 }
    return Double(NominalPipeSizes.outsideDiameters[i])
  }

  /// Returns the wallthickness of the pipe schedule.
  var wallThickness: Double {
    guard let i = NominalPipeSizes.values.firstIndex(of: nps) else { return 0.0 }
    return Double(schedule.wallthickness[i])
  }

  /// Returns the global ambient temperature of the solar field
  var ambientTemperature: Double { SolarField.shared.ambientTemperature }

  /// Returns the calculated insideDiameter of the branch.
  var insideDiameter: Double {
    Branch.insideDiameter(
      outsideDiameter: outsideDiameter, wallThickness: wallThickness)
  }

  /// Returns the calculated cross section area of the branch.
  var crossSectionArea: Double {
    Branch.crossSectionalArea(diameter: insideDiameter)
  }

  /// Returns the calculated friction factor of the branch.
  var frictionFactor: Double {
    Branch.frictionFactor(insideDiameter: insideDiameter,
                          pipeRoughness: roughness,
                          reynoldsNumber: reynoldsnumber)
  }

  /// Returns the calculated reynoldsnumber of the branch.
  var reynoldsnumber: Double {
    Branch.reynoldsNumber(streamVelocity: streamVelocity,
                          insideDiameter: insideDiameter,
                          temperature: Double(temperature))
  }

  /// Returns the calculated volume in the branch.
  var volume: Double { crossSectionArea * Double(length) }

  /// Returns the calculated volume flow of the branch.
  var volumeFlow: Double {
    Branch.volumeFlow(massFlow: massFlow, temperature: Double(temperature))
  }

  /// Returns the calculated stream velocity in the branch.
  var streamVelocity: Double {
    Branch.streamVelocity(volumeFlow: volumeFlow, crossSectionalArea: crossSectionArea)
  }

  /// Returns the calculated residence time in the branch.
  var residenceTime: Double { Double(length) / streamVelocity }

  /// Returns the calculated heat losses in the branch.
  var heatLosses: Double {
    length * Branch.heatLossPerMeter(
      outsideDiameter: outsideDiameter,
      insulationThickness: insulationThickness,
      designTemperature: temperature,
      ambientTemperature: ambientTemperature)
  }

  /// Returns the calculated major head loss in the branch.
  var majorHeadLoss: Double {
    Branch.headLoss(frictionFactor: frictionFactor,
                    length: length,
                    diameter: insideDiameter,
                    streamVelocity: streamVelocity)
  }

  /// Returns the number of elbows in the branch.
  var numberOfElbows: Int { components.filter({ $0.type == .elbow }).count }

  /// Returns true if branch contains one or more reducers.
  var hasReducer: Bool {
    !components.lazy.filter({ $0.type == .reducer }).isEmpty
  }

  /// Returns true if branch contains one or more valves.
  var hasValve: Bool {
    !components.lazy.filter({ $0.type == .valve }).isEmpty
  }

  /// Returns the calculated minor head loss in the branch.
  var minorHeadLoss: Double {
    let zeta = components.map({ $0.lossCoefficient }).reduce(0.0, +)
    return zeta > 0.0
      ? Branch.headLoss(lossCoeficient: zeta, streamVelocity: streamVelocity)
      : 0.0
  }

  /// Returns the calculated major pressure drop in the branch.
  var majorPressureDrop: Double {
    return majorHeadLoss > 0.0
      ? Branch.pressureDrop(headLoss: majorHeadLoss, temperature: temperature)
      : 0.0
  }

  /// Returns the calculated minor pressure drop in the branch.
  var minorPressureDrop: Double {
    return minorHeadLoss > 0.0
      ? Branch.pressureDrop(headLoss: minorHeadLoss, temperature: temperature)
      : 0.0
  }

  /// Returns the sum of head loss in the branch.
  var headLoss: Double { majorHeadLoss + minorHeadLoss }

  /// Returns the sum of pressure drop in the branch.
  var pressureDrop: Double { majorPressureDrop + minorPressureDrop }

  /// Decreases the branch size to next valid value
  mutating func decreaseSize(by steps: Int = 1) {
    let smallerSize = NominalPipeSizes.values.firstIndex(of: nps)! - steps
    self.nps = NominalPipeSizes.values[smallerSize]
  }

  /// Increases the branch size to next valid value
  mutating func increaseSize(by steps: Int = 1) {
    if steps == 0 { return }
    let largerSize = NominalPipeSizes.values.firstIndex(of: nps)! + steps
    if NominalPipeSizes.values.endIndex - 1 < largerSize { return }
    self.nps = NominalPipeSizes.values[largerSize]
  }

  /// Iterates the size of the branch until the design flow velocity is not exceeded
  mutating func adjustSize(toStreamVelocity design: Double) {
    let deviationBeforeResize = abs(streamVelocity - design)

    if streamVelocity < design { decreaseSize() }
    if streamVelocity > design { increaseSize() }

    let deviationAfterResize = abs(streamVelocity - design)

    if deviationBeforeResize > deviationAfterResize, nps > 6 {
      self.adjustSize(toStreamVelocity: design)
    }
  }

  /// Adds valve of given type to the branch
  mutating func addValve(type: Component.ValveType) {
    components.append(Component(valve: type, size: nps))
  }

  /// Adds reducer with given size to the branch
  mutating func addReducer(toSize: Float) {
    components.append(Component(type: .reducer, size: toSize, nps))
  }

  /// Adds given count of elbows with same size to the branch
  mutating func addElbows(count: Int) {
    components +=
      Array(repeating: Component(type: .elbow, size: nps), count: count)
  }
}

extension Branch: Equatable {
  public static func == (lhs: Branch, rhs: Branch) -> Bool {
    return lhs.nps == rhs.nps &&
      lhs.schedule == rhs.schedule &&
      lhs.temperature == rhs.temperature &&
      lhs.length == rhs.length &&
      lhs.massFlow == rhs.massFlow &&
      lhs.components == rhs.components
  }}
