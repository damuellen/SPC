//
//  Workbook.swift
//  
//
//  Created by Daniel Müllenborn on 05.01.21.
//

import SolarFieldModel
import Foundation
import xlsxwriter

extension Workbook {
  
  func addTables(solarField: SolarField) {
    addOverviews(solarField: solarField)
    addBranches(solarField: solarField)
    addBillOfMaterials(solarField: solarField)
  }
  
  func addOverviews(solarField: SolarField) {
    let f1 = addFormat().bold()
    let f2 = addFormat().set(num_format: 4)
    let f3 = addFormat().bold().align(horizontal: .right)
    func writeTable(_ table: TableConvertible) {
      let ws = addWorksheet(name: table.name)
        .set_default(row_height: 15)
        .hide_columns(2)
        .column([0,0], width: 25)
        .column([1,1], width: 10)
      
      table.table.enumerated().forEach { (n, pair) in
        ws.write(.string(pair.key), [n, 0], format: f1)
        ws.write(.number(pair.value), [n, 1], format: f2)
      }
    }
    
    writeTable(solarField)
    writeTable(solarField.loop)
    writeTable(solarField.powerBlock)
    writeTable(solarField.expansionVolume)

    /// The values of the individual tables are written next to each other
    func writeOverviewTable(name: String, tables: [TableConvertible]) {
      let ws = addWorksheet(name: name)
        .set_default(row_height: 15)
        .hide_columns(tables.count)
        .column([0,tables.count], width: 15)
      
      for (t, c) in zip(tables, 1...) {
        if c == 1 { ws.write(.string("Name"), [0, 0], format: f1) }
        ws.write(.string(t.name), [0, c], format: f3)
        t.table.enumerated().forEach { (n, pair) in
          if c == 1 { ws.write(.string(pair.key), [n+1, 0], format: f1) }
          ws.write(.number(pair.value), [n+1, c], format: f2)
        }
      }
    }

    writeOverviewTable(name: "Subfields", tables: solarField.subfields)
    writeOverviewTable(name: "Connectors", tables: solarField.connectors)
  }

  func addBillOfMaterials(solarField: SolarField) {
    let text = addFormat()
    let sch = addFormat().align(horizontal: .center)
    let size = addFormat().set(num_format: 1)
    let qty = addFormat().set(num_format: 4)
    
    var row = 0
    
    let ws = addWorksheet(name: "BOM")
      .activate()
      .set_default(row_height: 15)
      .column("A:B", width: 25)
      .column("C:F", width: 10)
      .hide_columns(BillOfMaterials.headings.count)
      
    let bom = BillOfMaterials(solarField: solarField)
    bom.tubeLengthAndWeight.sorted.forEach { (key, value) in
      row += 1
      ws.write(.string(key.name), [row,0], format: text)
        .write(.string(key.material), [row,1], format: text)
        .write(.string(key.schedule), [row,2], format: sch)
        .write(.number(Double(key.size)), [row,3], format: size)
        .write(.number(Double(value.length)), [row,4], format: qty)
        .write(.number(Double(value.weight)), [row,5], format: qty)
    }

    bom.fittingsQuantityAndWeight.sorted.forEach { (key, value) in
      row += 1
      ws.write(.string(key.name), [row,0], format: text)
        .write(.string(key.material), [row,1], format: text)
        .write(.string(key.schedule), [row,2], format: sch)
        .write(.number(Double(key.size)), [row,3], format: size)
        .write(.number(Double(value.qty)), [row,4], format: qty)
        .write(.number(Double(value.weight)), [row,5], format: qty)
    }
    ws.table(
      range: [0,0,row,5], name: "BOM",
      header: BillOfMaterials.headings,
      totalRow: [0, 0, 0, 0, 109, 109]
    )
  }
  
  func addBranches(solarField: SolarField) {
    let f = addFormat().set(num_format: 4)
    let f1 = addFormat().align(horizontal: .center)
    let ws = addWorksheet(name: "Branches")
      .set_default(row_height: 15)
      .column("A:A", width: 27)
      .column("B:C", width: 12)
      .column("D:O", width: 15)
      .hide_columns(Branch.tableHeader.count + 3)

    zip(solarField.branches, 1...).forEach { value, row in
      ws.write(.string(value.name), [row,0])
        .write(.boolean(value.hasReducer), [row,1], format: f1)
        .write(.boolean(value.hasValve), [row,2], format: f1)
        .write(value.values, row: row, col: 3, format: f)
    }
    ws.table(range: [0,0,solarField.branches.count,15], name: "Branches",
             header: ["Name", "Reducer", "Valve"] + Branch.tableHeader)
  }
}
