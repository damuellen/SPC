import Foundation
import Utilities
import DateExtensions

let newLine = UInt8(ascii: "\n")
let cr = UInt8(ascii: "\r")
let comma = UInt8(ascii: ",")
let point = UInt8(ascii: ".")
let separator = UInt8(ascii: ";")

let data = try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
var lines = data.filter({ $0 != cr }).split(separator: newLine, maxSplits: 13, omittingEmptySubsequences: false)
let csv = CSVReader(data: Data(lines[10] + [newLine] + lines[13].map { $0 == comma ? point : $0 }), separator: ";")
let dates = DateSequence(year: 2023, interval: .hour).map(DateTime.init(_:))
print("Date,",csv!.headerRow!.dropFirst(3).joined(separator: ","), separator: "")
for idx in csv!.dataRows.indices {
  let values = Array(csv!.dataRows[idx].dropFirst(3))
  print(dates[idx].description, values.map(\.description).joined(separator: ","), separator: ",")
}