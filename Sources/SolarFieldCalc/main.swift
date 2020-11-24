import ArgumentParser
import Foundation
import SolarFieldModel

SolarField.createLayout(loops: 100)
SolarField.designMassFlow = 500

let table1 = TextTable.overview()
let table2 = TextTable.bom()
let table3 = SolarField.branchTable

let url1 = URL(fileURLWithPath: "Report.txt")
let url2 = URL(fileURLWithPath: "BOM.txt")
let url3 = URL(fileURLWithPath: "Branches.csv")

try! table1.write(to: url1, atomically: false, encoding: .utf8)
try! table2.write(to: url2, atomically: false, encoding: .utf8)
try! table3.write(to: url3, atomically: false, encoding: .utf8)

print(TextTable.overview(style: Style.fancy))

try! ModelModel().writeToFile(url: URL(fileURLWithPath: "Model.json"))

extension TextTable {
	public static func overview(style: TextTableStyle.Type = Style.fancy) -> String {
		var output = ""
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		numberFormatter.formatWidth = 8

		let makeTable: ([(String, String)]) -> String = {
			let columns: [Column] = $0.map { (key, measurement) in
				return Column(title: key, value: measurement)
			}
			return TextTable([columns]).string(style: style)
		}

		output += "SolarField\n"  + makeTable(SolarField.shared.measurements.sorted) + "\n"
		output += "Loop\n"        + makeTable(SolarField.shared.loop.measurements.sorted) + "\n"
		output += "PowerBlock\n"  + makeTable(SolarField.shared.powerBlock.measurements.sorted) + "\n"
		output += "Expansion\n"   + makeTable(SolarField.shared.expansionVolume.measurements.sorted) + "\n"

		let makeOverviewTable: ([System]) -> String = { systems in
			var measurements: [[Column]] = []
			for system in systems {
				var columns = [Column(title: "Name", value: system.name + " ")]
				columns += system.measurements.sorted.map { (key, measurement) in
					return Column(title: key, value: measurement.description, align: .right)
				}
				measurements.append(columns)
			}
			return TextTable(measurements).string(style: style)
		}

		output += "SubFields\n"   + makeOverviewTable(SolarField.shared.subfields) + "\n"
		output += "Connections\n" + makeOverviewTable(SolarField.shared.connectors) + "\n"

		return output
	}

	public static func bom(style: TextTableStyle.Type = Style.fancyCompact) -> String {
		var output = ""
		var billOfMaterials: [[Column]] = []

		BillOfMaterials.tubesWeightAndLength.sorted.forEach { (key, value) in
			billOfMaterials.append([Column(title: "Description", value: key, width: 55),
									Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
									Column(title: "Quantity", value: String(format:"%.1f ", value.1), width: 9, align: .right)])
		}

		let tablePipeBOM = TextTable(billOfMaterials).string(style: style)
		billOfMaterials.removeAll()

		BillOfMaterials.fittingsWeightAndQuantity.sorted.forEach { (key, value) in
			billOfMaterials.append([Column(title: "Description", value: key, width: 55),
									Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
									Column(title: "Quantity", value: String(Int(value.1)), width: 9, align: .right)])
		}

		let tableFittingsBOM = TextTable(billOfMaterials).string(style: style)
		Swift.print(tablePipeBOM, tableFittingsBOM, separator: "\n", to: &output)
		return output
	}
}
