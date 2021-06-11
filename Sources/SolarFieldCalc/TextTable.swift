import Foundation

private func + (left: [Column], right: [Int]) -> [Column] {
  precondition(left.count == right.count)
  return zip(left, right).map { $0.0.settingWidth($0.1) }
}

private func unwrap(_ any: Any) -> Any {
  let m = Mirror(reflecting: any)
  if m.displayStyle != .optional { return any }
  if m.children.count == 0 { return "NULL" }
  let (_, some) = m.children.first!
  return some
}

public enum StringAlignment {
  case left
  case right
  case center
}

public enum Truncation {
  case tail
  case head
  case error
}

public enum Style {
  public static let simple = Simple.self
  public static let plain = Plain.self
  public static let rst = Rst.self
  public static let pipe = Pipe.self
  public static let org = Org.self
  public static let html = Html.self
  public static let grid = Grid.self
  public static let fancy = FancyGrid.self
  public static let fancyCompact = FancyGridCompact.self
}

public struct Column {
  let title: String
  let value: Any
  let width: Int?
  let align: StringAlignment
  let truncate: Truncation
  let formatter: Formatter?

  public init(
    title: String, value: Any, width: Int? = nil,
    align: StringAlignment = .left, truncate: Truncation = .tail,
    formatter: Formatter? = nil
  ) {
    self.title = title
    self.value = unwrap(value)
    self.width = width
    self.align = align
    self.truncate = truncate
    self.formatter = formatter
  }

  public init(
    _ mapping: @autoclosure () -> (String, Any), width: Int? = nil,
    align: StringAlignment = .left, truncate: Truncation = .tail,
    formatter: Formatter? = nil
  ) {
    let (t, v) = mapping()
    self = Column(
      title: t,
      value: v,
      width: width,
      align: align,
      truncate: truncate,
      formatter: formatter)
  }

  internal var resolvedWidth: Int {
    return width ?? title.count
  }

  fileprivate func settingWidth(_ newWidth: Int) -> Column {
    return Column(
      title: self.title,
      value: self.value,
      width: newWidth,
      align: self.align,
      truncate: self.truncate,
      formatter: self.formatter)
  }
}

extension Column {
  public func string(for style: TextTableStyle.Type) -> String {
    var string = ""
    if let formatter = formatter {
      string = formatter.string(for: value) ?? string
    } else {
      string = String(describing: value)
    }
    return style.prepare(string, for: self)
  }

  public func headerString(for style: TextTableStyle.Type) -> String {
    return style.prepare(title, for: self)
  }

  public func repeated(_ string: String) -> String {
    return String(repeating: string, count: resolvedWidth)
  }
}

public protocol TextTableStyle {

  static func prepare(_ s: String, for column: Column) -> String
  static func escape(_ table: String) -> String
  static func begin(_ table: inout String, index: Int, columns: [Column])
  static func end(_ table: inout String, index: Int, columns: [Column])
  static func header(_ table: inout String, index: Int, columns: [Column])
  static func row(_ table: inout String, index: Int, columns: [Column])
}

public struct TextTable {

  private let columns: [[Column]]

  public init(_ columns: [[Column]]) {
    self.columns = columns
  }

  private func calculateWidths(style: TextTableStyle.Type) -> [Int] {
    guard let first = columns.first else { return [] }
    let headerCols = first
    var widths = headerCols.map { $0.width ?? 0 }
    for (index, column) in headerCols.enumerated() {
      if let w = column.width {
        widths[index] = w
      } else {
        let text = column.headerString(for: style)
        widths[index] = max(text.count, widths[index])
      }
    }
    for element in columns {
      let cols = element
      for (index, column) in cols.enumerated() {
        if let w = column.width {
          widths[index] = w
        } else {
          let text = column.string(for: style)
          widths[index] = max(text.count, widths[index])
        }
      }
    }
    return widths
  }

  public func string(style: TextTableStyle.Type = Style.simple) -> String {
    let first = columns.first!
    var table = ""
    let cols = first
    var widths = cols.compactMap { $0.width }
    if widths.count < cols.count {
      widths = calculateWidths(style: style)
    }
    style.begin(&table, index: -1, columns: cols + widths)
    style.header(&table, index: -1, columns: cols + widths)
    for (index, element) in columns.enumerated() {
      style.row(&table, index: index, columns: element + widths)
    }
    style.end(&table, index: -1, columns: cols + widths)
    return table
  }

  public func print(style: TextTableStyle.Type = Style.simple) {
    let table = string(style: style)
    Swift.print(table)
  }
}

public enum FancyGrid: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}

  public static func end(_ table: inout String, index _: Int, columns: [Column]) {
    table += "╘═"
    table += columns.map { $0.repeated("═") }.joined(separator: "═╧═")
    table += "═╛"
    table += "\r\n"
  }

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += "╒═"
    table += columns.map { $0.repeated("═") }.joined(separator: "═╤═")
    table += "═╕"
    table += "\r\n"

    table += "│ "
    table += columns.map { $0.headerString(for: self) }.joined(separator: " │ ")
    table += " │"
    table += "\r\n"
  }

  public static func row(_ table: inout String, index: Int, columns: [Column]) {
    if index == 0 {
      table += "╞═"
      table += columns.map { $0.repeated("═") }.joined(separator: "═╪═")
      table += "═╡"
      table += "\r\n"
    } else {
      table += "├─"
      table += columns.map { $0.repeated("─") }.joined(separator: "─┼─")
      table += "─┤"
      table += "\r\n"
    }

    table += "│ "
    table += columns.map { $0.string(for: self) }.joined(separator: " │ ")
    table += " │"
    table += "\r\n"
  }
}

public enum FancyGridCompact: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}

  public static func end(_ table: inout String, index _: Int, columns: [Column]) {
    table += "╘═"
    table += columns.map { $0.repeated("═") }.joined(separator: "═╧═")
    table += "═╛"
    table += "\r\n"
  }

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += "╒═"
    table += columns.map { $0.repeated("═") }.joined(separator: "═╤═")
    table += "═╕"
    table += "\r\n"

    table += "│ "
    table += columns.map { $0.headerString(for: self) }.joined(separator: " │ ")
    table += " │"
    table += "\r\n"
  }

  public static func row(_ table: inout String, index: Int, columns: [Column]) {
    if index == 0 {
      table += "╞═"
      table += columns.map { $0.repeated("═") }.joined(separator: "═╪═")
      table += "═╡"
      table += "\r\n"
    }

    table += "│ "
    table += columns.map { $0.string(for: self) }.joined(separator: " │ ")
    table += " │"
    table += "\r\n"
  }
}

public enum Grid: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  private static func line(_ table: inout String, columns: [Column]) {
    table += "+-"
    table += columns.map { $0.repeated("-") }.joined(separator: "-+-")
    table += "-+"
    table += "\r\n"
  }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}
  public static func end(_: inout String, index _: Int, columns _: [Column]) {}

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    line(&table, columns: columns)

    table += "| "
    table += columns.map { $0.headerString(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"

    table += "+="
    table += columns.map { $0.repeated("=") }.joined(separator: "=+=")
    table += "=+"
    table += "\r\n"
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += "| "
    table += columns.map { $0.string(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"
    line(&table, columns: columns)
  }
}

public enum Html: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String {
    return
      s
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: "<", with: "&gt;")
  }

  private static func string(for alignment: StringAlignment) -> String {
    switch alignment {
    case .left: return "left"
    case .right: return "right"
    case .center: return "center"
    }
  }

  private static func string(header col: Column) -> String {
    return "        <th style=\"text-align:\(string(for: col.align));\">"
      + col.headerString(for: self) + "</th>\n"
  }

  private static func string(row col: Column) -> String {
    return "        <td>" + col.string(for: self) + "</td>\n"
  }

  public static func begin(_ table: inout String, index _: Int, columns _: [Column]) {
    table += "<table border=\"1\">\n"
  }

  public static func end(_ table: inout String, index _: Int, columns _: [Column]) {
    table += "</table>\n"
  }

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += "    <tr>\n"
    for col in columns {
      table += string(header: col)
    }
    table += "    </tr>\n"
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += "    <tr>\n"
    for col in columns {
      table += string(row: col)
    }
    table += "    </tr>\n"
  }
}

public enum Org: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  private static func line(_ table: inout String, columns: [Column]) {
    table += "|-"
    table += columns.map { $0.repeated("-") }.joined(separator: "-+-")
    table += "-|"
    table += "\r\n"
  }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}
  public static func end(_: inout String, index _: Int, columns _: [Column]) {}

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += "| "
    table += columns.map { $0.headerString(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"
    line(&table, columns: columns)
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += "| "
    table += columns.map { $0.string(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"
  }
}

public enum Pipe: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  private static func line(_ table: inout String, columns: [Column]) {
    table += "|"
    table += columns.map(column).joined(separator: "|")
    table += "|"
    table += "\r\n"
  }

  private static func column(_ col: Column) -> String {
    let w = max(col.width ?? 0, 3)
    switch col.align {
    case .left:
      return ":" + String(repeating: "-", count: w + 1)
    case .right:
      return String(repeating: "-", count: w + 1) + ":"
    case .center:
      return ":" + String(repeating: "-", count: w) + ":"
    }
  }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}
  public static func end(_: inout String, index _: Int, columns _: [Column]) {}

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += "| "
    table += columns.map { $0.headerString(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"
    line(&table, columns: columns)
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += "| "
    table += columns.map { $0.string(for: self) }.joined(separator: " | ")
    table += " |"
    table += "\r\n"
  }
}

public enum Plain: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }
  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}
  public static func end(_: inout String, index _: Int, columns _: [Column]) {}

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.headerString(for: self) }.joined(separator: " ")
    table += "\r\n"
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.string(for: self) }.joined(separator: " ")
    table += "\r\n"
  }
}

public enum Rst: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  private static func line(_ table: inout String, columns: [Column]) {
    table += columns.map { $0.repeated("=") }.joined(separator: " ")
    table += "\r\n"
  }

  public static func begin(_ table: inout String, index _: Int, columns: [Column]) {
    line(&table, columns: columns)
  }

  public static func end(_ table: inout String, index _: Int, columns: [Column]) {
    line(&table, columns: columns)
  }

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.headerString(for: self) }.joined(separator: " ")
    table += "\r\n"
    line(&table, columns: columns)
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.string(for: self) }.joined(separator: " ")
    table += "\r\n"
  }
}

public enum Simple: TextTableStyle {
  public static func prepare(_ s: String, for column: Column) -> String {
    var string = s
    if let width = column.width {
      string = string.truncated(column.truncate, length: width)
      string = string.padding(column.align, length: width)
    }
    return escape(string)
  }

  public static func escape(_ s: String) -> String { return s }

  public static func begin(_: inout String, index _: Int, columns _: [Column]) {}

  public static func end(_: inout String, index _: Int, columns _: [Column]) {}

  public static func header(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.headerString(for: self) }.joined(separator: " ")
    table += "\r\n"

    table += columns.map { $0.repeated("-") }.joined(separator: " ")
    table += "\r\n"
  }

  public static func row(_ table: inout String, index _: Int, columns: [Column]) {
    table += columns.map { $0.string(for: self) }.joined(separator: " ")
    table += "\r\n"
  }
}

typealias PaddingFunction = (_ length: Int, _ character: Character) -> String

extension String {
  mutating func append(_ c: String, repeat count: Int) {
    append(String(repeating: c, count: count))
  }

  func leftpad(length: Int, character: Character = " ") -> String {
    var outString: String = self
    let extraLength = length - outString.count
    var i = 0
    while i < extraLength {
      outString.insert(character, at: outString.startIndex)
      i += 1
    }
    return outString
  }

  func rightpad(length: Int, character: Character = " ") -> String {
    return padding(toLength: length, withPad: String(character), startingAt: 0)
  }

  func centerpad(length: Int, character _: Character = " ") -> String {
    let leftlen = (length - count) / 2 + count
    return leftpad(length: leftlen).rightpad(length: length)
  }

  func replaceAll(_ character: Character) -> String {
    var out = ""
    for _ in self {
      out.append(character)
    }
    return out
  }

  func padding(_ align: StringAlignment, length: Int) -> String {
    let padfunc: PaddingFunction
    switch align {
    case .left: padfunc = rightpad
    case .right: padfunc = leftpad
    case .center: padfunc = centerpad
    }
    return padfunc(length, " ")
  }

  func truncated(_ mode: Truncation, length: Int) -> String {
    switch mode {
    case .tail:
      guard count > length else { return self }
      return self[startIndex..<index(startIndex, offsetBy: length - 1)] + "…"
    case .head:
      guard count > length else { return self }
      return "…" + self[index(endIndex, offsetBy: -1 * (length - 1))...]
    case .error:
      guard count <= length else { return self }
      fatalError("Truncation error")
    }
  }
}
