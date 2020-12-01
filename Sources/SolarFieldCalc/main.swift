import ArgumentParser
import SolarFieldModel
import Foundation

#if os(Windows)
system("chcp 65001")
#endif

SolarFieldCalculator.main()

#if os(Windows)
system("pause")
#endif

struct SolarFieldCalculator: ParsableCommand {

  @Option(name: .shortAndLong, help: "Total number of loops")
  var loops: Int? // "SolarFieldModel.json"

  @Option(name: .shortAndLong, help: "Total mass flow rate")
  var massFlow: Double? // "SolarFieldModel.json"

  @Option(name: .shortAndLong, help: "Layout (h/i)")
  var layout: String? // "SolarFieldModel.json"

  @Option(name: .shortAndLong, help: "Input file name")
  var input: String? // "SolarFieldModel.json"

  @Option(name: .shortAndLong, help: "Output file name.")
  var output: String? // "SolarFieldModel.json"

  func run() throws {

    if let loops = loops {
      SolarField.createLayout(loops: loops)
    }
    if let massFlow = massFlow {
      SolarField.designMassFlow = massFlow
    }
    if let input = input {
      try SolarFieldModel.readFromFile(url: URL(fileURLWithPath: input))?.apply()
    }

    let table1 = TextTable.overview()
    let table2 = TextTable.bom()
    let table3 = SolarField.branchTable

    let url1 = URL(fileURLWithPath: "Report.txt")
    let url2 = URL(fileURLWithPath: "BOM.txt")
    let url3 = URL(fileURLWithPath: "Branches.csv")

    try table1.write(to: url1, atomically: false, encoding: .utf8)
    try table2.write(to: url2, atomically: false, encoding: .utf8)
    try table3.write(to: url3, atomically: false, encoding: .utf8)

    print(TextTable.overview(style: Style.fancy))

    table3.clipboard()
    if let output = output {
      try SolarFieldModel().writeToFile(url: URL(fileURLWithPath: output))
    }
  }
}
