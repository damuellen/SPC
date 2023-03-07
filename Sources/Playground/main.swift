import Foundation
import Utilities

print(CommandLine.arguments)

let path: URL
#if os(Windows)
guard let file = FileDialog() else { fatalError("Invalid file path.")}
path = URL(fileURLWithPath: file)
#else
path = URL(fileURLWithPath:CommandLine.arguments[2])
#endif
print("read:", path.absoluteString)
let newLine = UInt8(ascii: "\n")
let cr = UInt8(ascii: "\r")
let comma = UInt8(ascii: ",")
let point = UInt8(ascii: ".")
let separator = UInt8(ascii: ";")

let steps = Int(CommandLine.arguments[1])!
let data = try! Data(contentsOf: path)
let lines = data.filter({ $0 != cr }).split(separator: newLine, maxSplits: 13, omittingEmptySubsequences: false)
guard let _  = String(data: lines[0], encoding: .utf8)?.contains("PVSYST") else { fatalError("Invalid file content.")}
let csv = CSVReader(data: Data(lines[10] + [newLine] + lines[13].map { $0 == comma ? point : $0 }), separator: ";")

var buffer = [[Double]]()
var count = 0 
let increment = 1 / (Double(steps) + 1)
for column in csv!.dataRows.transposed() {
  if count == 2 { 
    let c = column.dropLast().map( { Array(stride(from: $0, to: $0 + 1, by: increment)) }).joined() + [column.last!]
    buffer.append(Array(c))
  } else if count < 2 { 
    let c = column.dropLast().map( { Array(repeating: $0, count: steps + 1) }).joined() + [column.last!]
    buffer.append(Array(c))
  } else { 
    buffer.append(column.interpolate(steps: steps))
  }
  count += 1
}

#if os(Windows)
let fileURL = path.deletingLastPathComponent().appendingPathComponent("\(steps)" + path.lastPathComponent)
#else
let fileURL = URL(fileURLWithPath: CommandLine.arguments[3])
#endif
print("write:", fileURL.absoluteString)
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

