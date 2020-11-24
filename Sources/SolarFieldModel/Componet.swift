//
//  Component.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

struct Component {

  enum Kind {
    case valve, reducer, elbow, hx
  }

  enum ValveType {
    case globe, control, butterfly
  }

  var lossCoefficient: Double
  var type: Kind
  var name: String
  var nps: Float

  init(valve: ValveType, size: Float) {
    switch valve {
    case .globe:
      self.type = .valve
      self.name = "GLOBE VALVE ANSI B16.34 \(size)\""
      self.lossCoefficient = 4
      self.nps = size
    case .control:
      self.type = .valve
      self.name = "CONTROL VALVE ANSI B16.34 \(size)\""
      self.lossCoefficient = 5
      self.nps = size
    case .butterfly:
      self.type = .valve
      self.name = "BUTTERFLY VALVE ANSI B16.34 \(size)\""
      self.lossCoefficient = 0.2
      self.nps = size
    }
  }

  init(type: Kind, size: Float...) {
    switch type {
    case .reducer:
      self.type = type
      self.name = "REDUCER ECC, BE, A-234 Gr WPB \(size[0])\" > \(size[1])\""
      self.lossCoefficient = 0.05
      self.nps = size[0]
    case .elbow:
      self.type = type
      self.name = "90 DEGREE LR ELBOW, BE, A-234 GR. WPB SCH40 \(size[0])\""
      self.lossCoefficient = 0.2
      self.nps = size[0]
    case .valve:
      self.type = type
      self.name = "UNKNOWN VALVE TYPE \(size[0])\""
      self.lossCoefficient = 0.0
      self.nps = size[0]
    case .hx:
      self.type = type
      self.name = "HEATEXCHANGER \(size[0])\""
      self.lossCoefficient = 30.0
      self.nps = size[0]
    }
  }

  init(lossCoeficient: Double, size: Float) {
    self.type = .hx
    self.name = "HEATEXCHANGER"
    self.lossCoefficient = lossCoeficient
    self.nps = size
  }
}

extension Component: CustomStringConvertible {
  var description: String {
    return name
  }
}

extension Component: Equatable {
  static func ==(lhs: Component, rhs: Component) -> Bool {
    return lhs.type == rhs.type
      && lhs.lossCoefficient == rhs.lossCoefficient
      && lhs.nps == rhs.nps
  }
}
