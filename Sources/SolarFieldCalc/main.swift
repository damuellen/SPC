import ArgumentParser
import SolarFieldModel
import Foundation
import xlsxwriter

#if os(Windows)
system("chcp 65001")
#endif

SolarFieldCalculator.main()

#if os(Windows)
system("pause")
#endif

struct SolarFieldCalculator: ParsableCommand {

  @Option(name: .long, help: "Total number of loops")
  var loops: Int? // "SolarFieldModel.json"

  @Option(name: .long, help: "Total mass flow rate")
  var massflow: Double? // "SolarFieldModel.json"

  @Option(name: .long, help: "Layout (h/i)")
  var layout: String? // "SolarFieldModel.json"

  @Option(name: .long, help: "Input file name")
  var input: String? // "SolarFieldModel.json"

  @Option(name: .long, help: "Output file name.")
  var output: String? // "SolarFieldModel.json"

  func run() throws {


    if let massflow = massflow {
  //    SolarField.designMassFlow = massflow
    }

    if let input = input {
   //   try SolarFieldModel.readFromFile(url: URL(fileURLWithPath: input))?.apply()
    }

    //guard let loops = loops else { return }
    let solarField = SolarField.createLayout(loops: 100)
    solarField.massFlow = 1000

    let wb = Workbook(name: "Solarfield.xlsx")
    wb.addTables(solarField: solarField)
    wb.close()

    openFile(atPath: "Solarfield.xlsx")
    print(TextTable.overview(solarField: solarField, style: Style.fancy))

  //  if let output = output {
  //    String(
   //     data: try JSONEncoder().encode(SolarFieldModel()),
  //      encoding: .utf8)?
  //      .clipboard()
    //  try SolarFieldModel().writeToFile(url: URL(fileURLWithPath: output))
    
  }
}

func openFile(atPath: String) {
#if os(Windows)
  system(atPath)
#elseif os(macOS)
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
  process.arguments = ["/Users/daniel/test.xlsx"]
  try? process.run()
#endif
}
