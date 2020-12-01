//
//  Layout.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

extension SolarField {

  public enum Layout: String {
    case h, i

    public init?(_ s: String) {
      switch s.lowercased() {
        case "h": self = .h
        case "i": self = .i
        default: return nil
      }
    }
  }

  public static func createLayout(loops: Int, layout: Layout = .h) {
    switch layout {
    case .h:
      let i = loops / 8
      let r = loops % 8

      let nw = SubField(name: "NorthWest", lhs: i, rhs: i)
      let ne = SubField(name: "NorthEast", lhs: i, rhs: i)
      let sw = SubField(name: "SouthWest", lhs: i, rhs: i)
      let se = SubField(name: "SouthEast", lhs: i, rhs: i)

      if r > 0 {
        for x in 0..<r {
            switch x {
            case 0: nw.lhsLoops += 1
            case 1: ne.lhsLoops += 1
            case 2: sw.lhsLoops += 1
            case 3: se.lhsLoops += 1
            case 4: nw.rhsLoops += 1
            case 5: ne.rhsLoops += 1
            case 6: sw.rhsLoops += 1
            case 7: se.rhsLoops += 1
            default: break
            }
        }
      }
      let northSide = Connector(with: [nw, ne])
      northSide.name = "North"
      let southSide = Connector(with: [sw, se])
      southSide.name = "South"
      SolarField.attach([northSide, southSide])

    case .i:
      let i = loops / 4
      let r = loops % 4
      let nw = SubField(name: "NorthWest", lhs: i, rhs: i)
      let ne = SubField(name: "NorthEast", lhs: i, rhs: i)

      if r > 0 {
        for x in 0..<r {
            switch x {
            case 0: nw.lhsLoops += 1
            case 1: ne.lhsLoops += 1
            case 2: nw.rhsLoops += 1
            case 3: ne.rhsLoops += 1
            default: break
            }
        }
      }

      let conn = Connector(with: [nw, ne])
      conn.name = "NorthHeader"
      conn.distance = 15

      SolarField.attach([conn])
    }
  }
}
