import Foundation
import Utilities

let path: String
#if os(Windows)
guard let file = FileDialog() else { fatalError("Invalid file path.")}
path = file
#else
path = CommandLine.arguments[2]
#endif

let newLine = UInt8(ascii: "\n")
let cr = UInt8(ascii: "\r")
let comma = UInt8(ascii: ",")
let point = UInt8(ascii: ".")
let separator = UInt8(ascii: ";")

let steps = Int(CommandLine.arguments[1])!
let data = try! Data(contentsOf: URL(fileURLWithPath: path))
var lines = data.filter({ $0 != cr }).split(separator: newLine, maxSplits: 13, omittingEmptySubsequences: false)
let csv = CSVReader(data: Data(lines[10] + [newLine] + lines[13].map { $0 == comma ? point : $0 }), separator: ";")

var buffer = [[Double]]()
for column in csv!.dataRows.transposed() {
  buffer.append(column.interpolate(steps: steps))
}

#if os(Windows)
let url = URL(fileURLWithPath: path)
let fileURL = url.deletingLastPathComponent().appendingPathComponent(pathComponent: "\(steps)" + url.lastPathComponent)
#else
let fileURL = URL(fileURLWithPath: CommandLine.arguments[3])
#endif

do {
    try Data((csv!.headerRow!.joined(separator: ",") + "\n").utf8).write(to: fileURL)
    let fileHandle = try FileHandle(forWritingTo: fileURL)
    fileHandle.seekToEndOfFile()
    for row in buffer.transposed() {
      fileHandle.write(Data((row.map(\.description).joined(separator: ",")  + "\n").utf8))
    }
    fileHandle.closeFile()
    print(fileURL.absoluteString)
} catch {
    print(error)
}

