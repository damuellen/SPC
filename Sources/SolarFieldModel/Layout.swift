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

  public static func createLayout(loops: Int, layout: Layout = .h) -> SolarField {
    let solarField = SolarField(massFlow: Double(loops * 10))
    switch layout {
    case .h:
      let i = loops / 8
      let r = loops % 8

      let nw = solarField(name: "NorthWest", lhs: i, rhs: i)
      let ne = solarField(name: "NorthEast", lhs: i, rhs: i)
      let sw = solarField(name: "SouthWest", lhs: i, rhs: i)
      let se = solarField(name: "SouthEast", lhs: i, rhs: i)

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

      let northSide = solarField.connect(between: nw, ne)
      northSide.name = "North"
      let southSide = solarField.connect(between: nw, ne)
      southSide.name = "South"

    case .i:
      let loops = loops - 4
      let i = loops / 4
      let r = loops % 4
      let nw1 = solarField(name: "NorthWest", lhs: 0, rhs: 2)
      let ne1 = solarField(name: "NorthEast", lhs: 0, rhs: 2)
      let nw2 = solarField(name: "NorthWest2", lhs: i, rhs: i)
      let ne2 = solarField(name: "NorthEast2", lhs: i, rhs: i)
      nw2.attach(to: nw1)
      ne2.attach(to: ne1)
      
      if r > 0 {
        for x in 0..<r {
            switch x {
            case 0: nw2.lhsLoops += 1
            case 1: ne2.lhsLoops += 1
            case 2: nw2.rhsLoops += 1
            case 3: ne2.rhsLoops += 1
            default: break
            }
        }
      }

      let conn = solarField.connect(between: nw1, ne1)
      conn.name = "NorthHeader"
      conn.distance = 15
    }
    return solarField
  }
}
