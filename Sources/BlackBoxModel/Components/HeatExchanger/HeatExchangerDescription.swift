//
//  HeatExchangerData.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

extension HeatExchanger: CustomStringConvertible {
    public var description: String {
      "  Mode:".padding(30) + "\(operationMode)\n" + "\(self.cycle)"
    }
}
