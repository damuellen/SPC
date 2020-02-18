//
//  HeatExchangerData.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

extension HeatExchanger: CustomStringConvertible {
    public var description: String {
      return "\(operationMode), "
        + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format: "Tin: %.1f°C, ", temperature.inlet.celsius)
        + String(format: "Tout: %.1f°C", temperature.outlet.celsius)
    }
}
