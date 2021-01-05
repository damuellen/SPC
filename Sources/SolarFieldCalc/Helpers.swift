import SolarFieldModel
import Foundation
#if os(Windows)
import WinSDK
import CRT
#endif

extension String {
  func clipboard() {
#if os(Windows)
    let size = utf16.count * MemoryLayout<UInt16>.size
    guard let hMem = GlobalAlloc(UINT(GHND), SIZE_T(size + 1))
    else { return }
    withCString(encodedAs: UTF16.self) {
      let dst = GlobalLock(hMem)
      memcpy(dst, $0, size)
      GlobalUnlock(hMem)
    }
    if OpenClipboard(nil) {
      EmptyClipboard()
      SetClipboardData(UINT(CF_UNICODETEXT), hMem)
      CloseClipboard()
    }
#endif
  }
}

extension Dictionary where Key: Comparable {
	var sorted: [(Key, Value)] {
		return keys.sorted(by: <).map { ($0, self[$0]!) }
	}
}

extension TextTable {
  public static func overview(style: TextTableStyle.Type = Style.fancy) -> String {
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

    output += "SolarField\n"  + makeTable(SolarField.shared.table) + "\n"
    output += "Loop\n"        + makeTable(SolarField.shared.loop.table) + "\n"
    output += "PowerBlock\n"  + makeTable(SolarField.shared.powerBlock.table) + "\n"
    output += "Expansion\n"   + makeTable(SolarField.shared.expansionVolume.table) + "\n"

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

    output += "SubFields\n"   + makeOverviewTable(SolarField.shared.subfields) + "\n"
    output += "Connections\n" + makeOverviewTable(SolarField.shared.connectors) + "\n"

    return output
  }

  public static func bom(style: TextTableStyle.Type = Style.fancyCompact) -> String {
    var output = ""
    var billOfMaterials: [[Column]] = []

    BillOfMaterials.tubeLengthAndWeight.forEach { (key, value) in
      billOfMaterials.append([Column(title: "Description", value: key, width: 55),
                  Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
                  Column(title: "Quantity", value: String(format:"%.1f ", value.1), width: 9, align: .right)])
    }

    let tablePipeBOM = TextTable(billOfMaterials).string(style: style)
    billOfMaterials.removeAll()

    BillOfMaterials.fittingsQuantityAndWeight.forEach { (key, value) in
      billOfMaterials.append([Column(title: "Description", value: key, width: 55),
                  Column(title: "Weight", value: String(format:"%.2f ", value.0), width: 9, align: .right),
                  Column(title: "Quantity", value: String(Int(value.1)), width: 9, align: .right)])
    }

    let tableFittingsBOM = TextTable(billOfMaterials).string(style: style)
    Swift.print(tablePipeBOM, tableFittingsBOM, separator: "\n", to: &output)
    return output
  }
}
