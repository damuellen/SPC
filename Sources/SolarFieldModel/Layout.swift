//
//  Layout.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

extension SolarField {

  public enum Layout: String {
    case h, h2, i

    public init?(_ s: String) {
      switch s.lowercased() {
        case "h": self = .h
        case "h2": self = .h2
        case "i": self = .i
        default: return nil
      }
    }
  }

  public static func create(layout: Layout = .h, loops: Int) -> SolarField {
    let massFlow = Double(loops * 10)
    let sf = SolarField(massFlow: massFlow)
    switch layout {
    case .h, .h2:
      let i = loops / 8
      let r = loops % 8

      var nw = (lhs: i, rhs: i)
      var ne = (lhs: i, rhs: i)
      var sw = (lhs: i, rhs: i)
      var se = (lhs: i, rhs: i)

      if r > 0 {
        for x in 0..<r {
          switch x {
          case 0: nw.lhs += 1
          case 1: ne.lhs += 1
          case 2: sw.lhs += 1
          case 3: se.lhs += 1
          case 4: nw.rhs += 1
          case 5: ne.rhs += 1
          case 6: sw.rhs += 1
          case 7: se.rhs += 1
          default: break
          }
        }
      }

      let north = sf { 
        SubField(name: "NorthWest", lhs: nw.lhs, rhs: nw.rhs)
        SubField(name: "NorthEast", lhs: ne.lhs, rhs: ne.rhs)
      }

      north.name = "NorthHeader"

      let south = sf {
        SubField(name: "SouthWest", lhs: sw.lhs, rhs: sw.rhs)
        SubField(name: "SouthEast", lhs: se.lhs, rhs: se.rhs)
      }
      south.name = "SouthHeader"
      if case .h2 = layout {
        south.connected(to: north)
      }
    case .i:
      let loops = loops - 4
      let i = loops / 4
      let r = loops % 4
      var nw2 = (lhs: i, rhs: i)
      var ne2 = (lhs: i, rhs: i)

      if r > 0 {
        for x in 0..<r {
          switch x {
          case 0: nw2.lhs += 1
          case 1: ne2.lhs += 1
          case 2: nw2.rhs += 1
          case 3: ne2.rhs += 1
          default: break
          }
        }
      }

      let header = sf {
        SubField.loops(lhs: 0, ne2.lhs, rhs: 2, ne2.rhs)
        SubField.loops(lhs: 0, nw2.lhs, rhs: 2, nw2.rhs)
      }

      header.name = "NorthHeader"
      header.distance = 15

    }
    return sf
  }
}
