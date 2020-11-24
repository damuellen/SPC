//
//  Model.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

import Foundation

extension Connector {

  convenience init(_ connector: Model.Connector) {
    self.init()
    self.name = connector.name
    self.distance = connector.distance
  }

  func model() -> Model.Connector {
    var model = Model.Connector()
    model.name = name
    model.distance = distance
    model.head = start.name
    model.sizeAdaptation = sizeAdaptation
    return model
  }
}

extension SubField {

  convenience init(subField: Model.SubField) {
    self.init(name: subField.name, lhs: subField.lhsLoops, rhs: subField.rhsLoops)
    self.distance = subField.distance
    self.adaptedRowDistance = subField.rowDistance
    self.adaptedStreamVelocity = subField.streamVelocity
    self.sizeAdaptation = subField.sizeAdaptation
  }

  func model() -> Model.SubField {
    var model = Model.SubField()
    model.name = name
    model.distance = distance
    model.head = connection?.name ?? "null"
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

public struct ModelModel: Codable {
  var solarField: Model
  var connectors: [Model.Connector]
  var subfields: [Model.SubField]

  public init() {
    self.solarField = Model(SolarField.shared)
    self.connectors = SolarField.shared.connectors.map { $0.model() }
    self.subfields = SolarField.shared.subfields.map { $0.model() }
  }

  public static func readFromFile(url: URL) -> ModelModel? {
    guard let data = try? Data(contentsOf: url) else { return nil }
    let decoder = JSONDecoder()
    return try? decoder.decode(ModelModel.self, from: data)
  }

  public func writeToFile(url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try? encoder.encode(self)
    try data?.write(to: url)
  }

  public func apply() throws {
    var connectors = self.connectors.map(Connector.init)

    do { // Ceck for duplicated names
      let names = connectors.map { $0.name }
      let groups = Dictionary(grouping: names, by: {$0})
      if let duplicate = groups.filter( {$1.count > 1}).first?.key {
        throw ModelError.duplicatedConnector(name: duplicate)
      }
    }

    do { // Ceck for duplicated names
      let names = subfields.map { $0.name }
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
      s.connection = c
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

    if let invalidSubfields = subfields.lazy.filter({ $0.connection == nil }).first {
      throw ModelError.disconnectedSubField(name: invalidSubfields.name)
    }

    if let invalidConnectors = connectors.lazy.filter({ $0.connections.isEmpty }).first {
      throw ModelError.danglingConnector(name: invalidConnectors.name)
    }

    let zipped = zip(connectors, self.connectors)
    for (c, m) in zipped {
      if let s = zipped.first(where: { $0.1.head == m.name })?.0 {
        c.successor = s; s.start = c
        connectors.removeAll { $0 === s }
      }
    }

    solarField.assign()
    SolarField.attach(connectors)
  }
}

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
    self.inletTemperature = solarField.designTemperature.inlet
    self.outletTemperature = solarField.designTemperature.outlet
    self.ambientTemperature = solarField.ambientTemperature
    self.fluid = solarField.fluid
  }

  public func assign() {
    SolarField.shared.massFlow = massFlow
    SolarField.shared.designStreamVelocity = designStreamVelocity
    SolarField.shared.rowDistance = rowDistance
    SolarField.shared.designTemperature.inlet = inletTemperature
    SolarField.shared.designTemperature.outlet = outletTemperature
    SolarField.shared.ambientTemperature = ambientTemperature
    SolarField.shared.fluid = fluid
  }
}

extension Model {
  struct Connector: Codable, Hashable, Equatable {
    var name: String = "Header "
    var distance: Double = 150
    var sizeAdaptation: [Int] = []
    var head: String?
  }

  struct SubField: Codable {
    var name: String = "Subfield "
    var rowDistance: Double?
    var streamVelocity: Double?
    var distance: Double = 5
    var lhsLoops: Int = 0
    var rhsLoops: Int = 0
    var sizeAdaptation: [Int] = []
    var head: String?
  }
}
