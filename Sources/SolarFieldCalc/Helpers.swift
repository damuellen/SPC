import SolarFieldModel
import Foundation
#if os(Windows)
import WinSDK
import CRT
#endif

extension Dictionary where Key: Comparable {
	var sorted: [(Key, Value)] {
		return keys.sorted(by: <).map { ($0, self[$0]!) }
	}
}

extension TextTable {
  public static func overview(solarField: SolarField, style: TextTableStyle.Type = Style.fancy) -> String {
    var output = ""
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.formatWidth = 8

    let makeTable: (KeyValuePairs<String, Double>) -> String = {
      let columns: [Column] = $0.map { (key, value) in
        return Column(title: key, value: String(format:"%.1f ", value))
      }
      return TextTable([columns]).string(style: style)
    }

    output += "SolarField\n"  + makeTable(solarField.table) + "\n"
    output += "Loop\n"        + makeTable(solarField.loop.table) + "\n"
    output += "PowerBlock\n"  + makeTable(solarField.powerBlock.table) + "\n"
    output += "Expansion\n"   + makeTable(solarField.expansionVolume.table) + "\n"

    let makeOverviewTable: ([TableConvertible]) -> String = { systems in
      var measurements: [[Column]] = []
      for system in systems {

        var columns = [Column(title: "Name", value: system.name + " ")]
        columns += system.table.map { (key, value) in
          return Column(title: key, value: String(format:"%.1f ", value), align: .right)
        }
        measurements.append(columns)
      }
      return TextTable(measurements).string(style: style)
    }

    output += "SubFields\n"   + makeOverviewTable(solarField.subfields) + "\n"
    output += "Connections\n" + makeOverviewTable(solarField.connectors) + "\n"

    return output
  }

  public static func bom(solarField: SolarField, style: TextTableStyle.Type = Style.fancyCompact) -> String {
    var output = ""
    var billOfMaterials: [[Column]] = []
    let bom = BillOfMaterials(solarField: solarField)
    bom.tubeLengthAndWeight.forEach { (key, value) in
      billOfMaterials.append([Column(title: "Description", value: key, width: 55),
                  Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
                  Column(title: "Quantity", value: String(format:"%.1f ", value.1), width: 9, align: .right)])
    }

    let tablePipeBOM = TextTable(billOfMaterials).string(style: style)
    billOfMaterials.removeAll()

    bom.fittingsQuantityAndWeight.forEach { (key, value) in
      billOfMaterials.append([Column(title: "Description", value: key, width: 55),
                  Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
                  Column(title: "Quantity", value: String(Int(value.1)), width: 9, align: .right)])
    }

    let tableFittingsBOM = TextTable(billOfMaterials).string(style: style)
    Swift.print(tablePipeBOM, tableFittingsBOM, separator: "\n", to: &output)
    return output
  }
}
