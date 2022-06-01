//
//  Model.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

import Utilities
import Foundation

extension SolarField {
  public struct Model: Codable {

    enum Absorber: String, Codable {
      case ptr70, uvac90, custom
    }
    var massFlow: Double
    var designStreamVelocity: Double
    var rowDistance: Double
    var inletTemperature: Double
    var outletTemperature: Double
    var ambientTemperature: Double
    var fluid: Fluid = .terminol
    var absorberTyp: Absorber = .ptr70
    // var absorberDiameter: Double?

    public init(_ solarField: SolarField) {
      self.massFlow = solarField.massFlow
      self.designStreamVelocity = solarField.designStreamVelocity
      self.rowDistance = solarField.rowDistance
      self.inletTemperature = SolarField.designTemperature.inlet
      self.outletTemperature = SolarField.designTemperature.outlet
      self.ambientTemperature = SolarField.ambientTemperature
      self.fluid = SolarField.fluid
    }
  }

  static func assign(_ model: Model) {
  //  massFlow = model.massFlow
  //  designStreamVelocity = model.designStreamVelocity
  //  rowDistance = model.rowDistance
    SolarField.designTemperature.inlet = model.inletTemperature
    SolarField.designTemperature.outlet = model.outletTemperature
    SolarField.ambientTemperature = model.ambientTemperature
    SolarField.fluid = model.fluid
  }
}
extension Connector {
  struct Model: Codable, Hashable, Equatable {
    var name: String = "Header "
    var distance: Double = 150
    var sizeAdaptation: [Int] = []
    var head: String?
  }

  convenience init(_ connector: Model) {
    self.init(solarField: SolarField(massFlow: 0))
  }

  func model() -> Model {
    var model = Connector.Model()
    model.name = name
    model.distance = distance

    model.sizeAdaptation = sizeAdaptation
    return model
  }
}

extension SubField {

  public struct Model: Codable {
    var name: String = "Subfield "
    var rowDistance: Double?
    var streamVelocity: Double?
    var distance: Double = 5
    var lhsLoops: Int = 0
    var rhsLoops: Int = 0
    var sizeAdaptation: [Int] = []
    var head: String?
  }

  convenience init(subField: Model) {
    self.init(name: subField.name, lhs: subField.lhsLoops, rhs: subField.rhsLoops)
    self.distance = subField.distance
    self.adaptedRowDistance = subField.rowDistance
    self.adaptedStreamVelocity = subField.streamVelocity
    self.sizeAdaptation = subField.sizeAdaptation
  }
  func model() -> Model {
    var model = Model()
    model.name = name
    model.distance = distance
    model.head = head?.name ?? "null"
    model.lhsLoops = lhsLoops
    model.rhsLoops = rhsLoops
    model.sizeAdaptation = sizeAdaptation
    return model
  }
}

enum ModelError: Error {
  case duplicatedConnection(name: String)
  case duplicatedConnector(name: String)
  case duplicatedSubField(name: String)
  case disconnectedSubField(name: String)
  case danglingConnector(name: String)
}

public struct SolarFieldModel: Codable {
  var solarField: SolarField.Model
  var connectors: [Connector.Model]
  var subfields: [SubField.Model]

  init(
    solarField: SolarField.Model,
    connectors: [Connector.Model],
    subfields: [SubField.Model]) 
  {
    self.solarField = solarField
    self.connectors = connectors
    self.subfields = subfields
  }

  public init(solarField: SolarField) {
    self.solarField = SolarField.Model(solarField)
    self.connectors = solarField.connectors.map { $0.model() }
    self.subfields = solarField.subfields.map { $0.model() }
  }

  public static func readFromFile(url: URL) -> SolarFieldModel? {
    return try? loadFromJSONIfExists(file: url)
  }

  public func writeToFile(url: URL) throws {
    try storeToJSON(file: url)
  }

  public func apply() throws {
    var connectors = self.connectors.map(Connector.init)

    do { // Ceck for duplicated names
      let names = connectors.map(\.name)
      let groups = Dictionary(grouping: names, by: {$0})
      if let duplicate = groups.filter( {$1.count > 1}).first?.key {
        throw ModelError.duplicatedConnector(name: duplicate)
      }
    }

    do { // Ceck for duplicated names
      let names = subfields.map(\.name)
      let groups = Dictionary(grouping: names, by: {$0})
      if let duplicate = groups.filter( {$1.count > 1}).first?.key {
        throw ModelError.duplicatedSubField(name: duplicate)
      }
    }

    let subfields: [SubField] = self.subfields.map { subfield in
      let s = SubField(subField: subfield)
      let c = connectors.first { connector in
        connector.name == subfield.head
      }
      s.head = c
      c?.connections.append(s)
      return s
    }

    for (instance, model) in zip(subfields, self.subfields) {
      if let subfield = subfields.first(where: { $0.name == model.head }) {
        if instance.isAttached(to: subfield) == false {
          throw ModelError.duplicatedConnection(name: subfield.name)
        }
      }
    }

    if let invalidSubfields = subfields.lazy.filter({ $0.head == nil }).first {
      throw ModelError.disconnectedSubField(name: invalidSubfields.name)
    }

    if let invalidConnectors = connectors.lazy.filter({ $0.connections.isEmpty }).first {
      throw ModelError.danglingConnector(name: invalidConnectors.name)
    }

    let zipped = zip(connectors, self.connectors)
    for (c, m) in zipped {
      if let s = zipped.first(where: { $0.1.head == m.name })?.0 {
        c.successor = s;
        connectors.removeAll { $0 === s }
      }
    }

    SolarField.assign(solarField)
  }
}
