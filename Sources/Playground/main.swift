import Foundation
import Utilities

let newLine = UInt8(ascii: "\n")
let cr = UInt8(ascii: "\r")
let comma = UInt8(ascii: ",")
let point = UInt8(ascii: ".")
let separator = UInt8(ascii: ";")

let data = try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2]))
var lines = data.filter({ $0 != cr }).split(separator: newLine, maxSplits: 13, omittingEmptySubsequences: false)
let csv = CSVReader(data: Data(lines[10] + [newLine] + lines[13].map { $0 == comma ? point : $0 }), separator: ";")

print(csv!.headerRow!.joined(separator: ","), separator: "")
var steps = Int(CommandLine.arguments[1])!

var buffer = [[Double]]()
for column in csv!.dataRows.transposed() {
  buffer.append(column.interpolate(steps: steps))
}

for row in buffer.transposed() {
  print(row.map(\.description).joined(separator: ","), separator: ",")
}