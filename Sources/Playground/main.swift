import Foundation
import Utilities
let newLine = UInt8(ascii: "\n")
let cr = UInt8(ascii: "\r")
let comma = UInt8(ascii: ",")
let point = UInt8(ascii: ".")
let path: URL
#if os(Windows)
guard let file = FileDialog() else { fatalError("Invalid file path.")}
path = URL(fileURLWithPath: file)
#else
path = URL(fileURLWithPath:CommandLine.arguments[3])
#endif
guard let steps = Int(CommandLine.arguments[1]) else { fatalError("Missing parameter.")}
let separator = CommandLine.arguments[2]
guard let data = try? Data(contentsOf: path) else { fatalError("Read error.")}
var buffer = [[Double]]()
let lines = data.split(separator: newLine, maxSplits: 13, omittingEmptySubsequences: false)
guard let line = String(data: lines[0], encoding: .utf8) else { fatalError("Read error.")}
let pvsyst = line.contains("PVSYST")
let date = line.lowercased().contains("hour") && line.lowercased().contains("month") && line.lowercased().contains("day")
let csv: CSVReader?
if pvsyst {
  let goodData = Data(lines[10] + [newLine] + lines[13].map { $0 == comma ? point : $0 })
  csv = CSVReader(data: goodData, separator: ";")
} else {
  csv = CSVReader(data: data, separator: separator.unicodeScalars.first!)
  for column in csv!.dataRows.transposed() {
      buffer.append(column.interpolate(steps: steps))
  }
}

if steps < 0 {
  #if os(Windows)
  setClipboard(
    csv!.headerRow!.joined(separator: "\t") + "\n"
    + stride(from: 0, to: csv!.dataRows, by: -steps).map {
      csv!.dataRows[$0].map(\.description).joined(separator: "\t") 
    }.joined(separator: "\n")
  )
  #endif
} else {
  if pvsyst || date {
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
  } 
}
#if os(Windows)
setClipboard(
  csv!.headerRow!.joined(separator: "\t") + "\n"
  + buffer.transposed().map { row in 
  row.map(\.description).joined(separator: "\t") 
  }.joined(separator: "\n")
)
MessageBox(text: "Check Clipboard", caption: "")
#else
let fileURL = URL(fileURLWithPath: CommandLine.arguments[3])
do {
  try Data((csv!.headerRow!.joined(separator: ",") + "\n").utf8).write(to: fileURL)
  let fileHandle = try FileHandle(forWritingTo: fileURL)
  fileHandle.seekToEndOfFile()
  for row in buffer.transposed() {
    fileHandle.write(Data((row.map(\.description).joined(separator: ",")  + "\n").utf8))
  }
  fileHandle.closeFile()
} catch {
  print(error)
}
#endif
