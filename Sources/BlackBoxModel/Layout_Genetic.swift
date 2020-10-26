//
//  LayoutGenetic.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 14.02.19.
//

extension Layout {

  public static func random() -> Layout {
    var layout = Layout()
    layout.solarField = Double.random(in: 80...120)
    layout.solarField.round()
    layout.heatExchanger = Double.random(in: 75...140)
    layout.heatExchanger.round()
    layout.powerBlock = Double.random(in: 50...100)
    layout.powerBlock.round()
    return layout
  }

  public static func crossover(first: Layout, second: Layout) -> Layout {
    var layout = first
    layout.solarField = Bool.random() ? first.solarField : second.solarField
    //   layout.heater = Bool.random() ? first.heater : second.heater
    layout.heatExchanger = Bool.random() ? first.heatExchanger : second.heatExchanger
    //   layout.boiler = Bool.random() ? first.boiler : second.boiler
    //   layout.gasTurbine = Bool.random() ? first.gasTurbine : second.gasTurbine
    layout.powerBlock = Bool.random() ? first.powerBlock : second.powerBlock
    //   layout.storage = Bool.random() ? first.storage : second.storage
    //   layout.storage_cap = Bool.random() ? first.storage_cap : second.storage_cap
    //   layout.storage_ton = Bool.random() ? first.storage_ton : second.storage_ton
    return layout
  }

  public static func mutate(_ layout: Layout, mutationRate: Double) -> Layout {
    var layout = layout
    if Double.random(in: 0...1) < mutationRate {
      layout.solarField += Double.random(in: -10...10).rounded()
      layout.solarField = min(max(layout.solarField, 80), 120)
    }
    if Double.random(in: 0...1) < mutationRate {
      layout.heatExchanger += Double.random(in: -10...10).rounded()
      layout.heatExchanger = min(max(layout.heatExchanger, 70), 145)
    }
    if Double.random(in: 0...1) < mutationRate {
      layout.powerBlock += Double.random(in: -10...10).rounded()
      layout.powerBlock = min(max(layout.powerBlock, 45), 105)
    }
    return layout
  }
}
