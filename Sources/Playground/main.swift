import Foundation
import Utilities

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
let csv = CSVReader(data: data, separator: separator.unicodeScalars.first!)
var buffer = [[Double]]()
for column in csv!.dataRows.transposed() {
    buffer.append(column.interpolate(steps: steps))
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
