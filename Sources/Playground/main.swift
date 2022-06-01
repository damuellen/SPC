import Foundation


func downsample(values: [(x:Double, y: Double)], threshold: Int) -> [(x:Double,y: Double)] {

  guard values.count > threshold && values.count > 2 else { return values }
  
  let bucketSize = (values.count - 2) / (threshold - 2)
  
  var A = 0, nextA = 0
  var out = [(x:Double, y: Double)]()
  var maxAreaPoint: (x:Double, y: Double) = (x:0, y: 0)
  out.append(values.first!)
  
  for i in 0..<(threshold - 2) {
    
    var avgRangeStart = (i + 1) * bucketSize + 1
    var avgRangeEnd   = (i + 2) * bucketSize + 1
    
    avgRangeEnd = avgRangeEnd < values.count ? avgRangeEnd : values.count
    
    let avgRangeLength = avgRangeEnd - avgRangeStart
    
    var avgX = 0.0, avgY = 0.0
    
    while avgRangeStart < avgRangeEnd {
      avgX += values[avgRangeStart].x
      avgY += values[avgRangeStart].y
      avgRangeStart += 1;
    }
    
    avgX /= Double(avgRangeLength)
    avgY /= Double(avgRangeLength)
    
    var rangeOffs = (i + 0) * bucketSize + 1
    let rangeTo   = (i + 1) * bucketSize + 1
    
    let pointAx = values[A].x
    let pointAy = values[A].y
    
    var maxArea = -1.0;
    
    while rangeOffs < rangeTo {
      
      let x = (pointAx - avgX) * ( values[rangeOffs].y - pointAy)
      let y = (pointAx - values[rangeOffs].x ) * (avgY - pointAy)
      let area = abs ( x - y ) * 0.5;
      
      if area > maxArea {
        maxArea = area;
        maxAreaPoint = values[rangeOffs]
        nextA = rangeOffs
      }
      rangeOffs += 1
    }
    out.append( maxAreaPoint  )
    A = nextA
  }
  out.append (values.last!)
  return out
}

public struct ExcelFormula {

  public var formula: String

  public init(_ formula: String) { self.formula = formula }

  public var indented: String {
    var indentCount = 0
    let indented: [String] = tokens.compactMap { token in
      if token.subtype == .Stop { indentCount -= indentCount > 0 ? 1 : 0 }
      var indent = ""
      indent.append("")
      for _ in 0..<indentCount { indent.append("    ") }
      indent.append(token.value)
      if token.subtype == .Start { indentCount += 1 }
      if token.value == "," { return "" }
      if token.value == "" { return nil }
      return indent
    }
    return indented.joined(separator: "\n")
  }

  public func levels() -> [[[Token]]] {
    var indentCount = 0
    var levels = [[[Token]]]()
    var previous = -1
    tokens.forEach { token in
      if token.subtype == .Stop { indentCount -= indentCount > 0 ? 1 : 0 }
      if levels.count == indentCount {
        levels.append([])
      }
      if previous != indentCount {
        levels[indentCount].append([])
      }
      if token.value.count > 0 {
        levels[indentCount][levels[indentCount].endIndex - 1].append(token)
      }
      previous = indentCount
      if token.subtype == .Start { indentCount += 1 }
    }
    return levels
  }

  public struct Token: CustomStringConvertible {
    var value: String
    var type: TokenType
    var subtype: TokenSubtype?

    public var description: String {
      return [value, type.rawValue, subtype?.rawValue ?? ""].joined(separator: " ")
    }
  }

  public enum TokenType: String {
    case Noop, Operand, Function, Subexpression, Argument, OperatorPrefix, OperatorInfix,
      OperatorPostfix, Whitespace, Unknown
  }

  public enum TokenSubtype: String {
    case Nothing, Start, Stop, Text, Number, Logical, Error, Range, Math, Concatenation,
      Intersection, Union
  }

  public var tokens: [Token] {
    // No attempt is made to verify formulas; assumes formulas are derived from Excel, where
    // they can only exist if valid; stack overflows/underflows sunk as nils without exceptions.
    let formula = formula.map(Character.init)
    if formula.count < 2 || formula[0] != "=" { return [] }
    var tokens1 = [Token]()
    var stack = [Token]()
    let QUOTE_DOUBLE: Character = "\""
    let QUOTE_SINGLE: Character = "\\"
    let BRACKET_CLOSE: Character = "]"
    let BRACKET_OPEN: Character = "["
    let BRACE_OPEN: Character = "{"
    let BRACE_CLOSE: Character = "}"
    let PAREN_OPEN: Character = "("
    let PAREN_CLOSE: Character = ")"
    let SEMICOLON: Character = ";"
    let WHITESPACE: Character = " "
    let COMMA: Character = ","
    let ERROR_START: Character = "#"

    let OPERATORS_SN = "+-"
    let OPERATORS_INFIX = "+-*/^&=><"
    let OPERATORS_POSTFIX = "%"

    let ERRORS: [String] = ["#nil!", "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A"]

    let COMPARATORS_MULTI = [">=", "<=", "<>"]
    var inString = false
    var inPath = false
    var inRange = false
    var inError = false
    var index = 1
    var tokens1index = -1
    var tokens2index = -1
    var value = ""
    while index < formula.count {
      // state-dependent character evaluation (order is important)

      // double-quoted strings
      // embeds are doubled
      // end marks token
      if inString {
        if formula[index] == QUOTE_DOUBLE {
          if ((index + 2) <= formula.count) && (formula[index + 1] == QUOTE_DOUBLE) {
            value += String(QUOTE_DOUBLE)
            index += 1
          } else {
            inString = false
            tokens1.append(Token(value: value, type: .Operand, subtype: .Text))
            value = ""
          }
        } else {
          value += String(formula[index])
        }
        index += 1
        continue
      }

      // single-quoted strings (links)
      // embeds are double
      // end does not mark a token
      if inPath {
        if formula[index] == QUOTE_SINGLE {
          if ((index + 2) <= formula.count) && (formula[index + 1] == QUOTE_SINGLE) {
            value += String(QUOTE_SINGLE)
            index += 1
          } else {
            inPath = false
          }
        } else {
          value += String(formula[index])
        }
        index += 1
        continue
      }

      // bracked strings (R1C1 range index or linked workbook name)
      // no embeds (changed to "()" by Excel)
      // end does not mark a token
      if inRange {
        if formula[index] == BRACKET_CLOSE { inRange = false }
        value += String(formula[index])
        index += 1
        continue
      }

      // error values
      // end marks a token, determined from absolute list of values
      if inError {
        value += String(formula[index])
        index += 1
        if ERRORS.contains(value) {
          inError = false
          tokens1.append(Token(value: value, type: .Operand, subtype: .Error))
          value = ""
        }
        continue
      }
      // scientific notation check
      if OPERATORS_SN.contains(value) {
        if value.count > 1 {
          let regex = try! NSRegularExpression(pattern: #"^[1-9]{1}(\.[0-9]+)?E{1}$"#)
          if regex.firstMatch(in: value, range: NSRange(value)!) != nil {
            value += String(formula[index])
            index += 1
            continue
          }
        }
      }

      // independent character evaluation (order not important)
      // establish state-dependent character evaluations
      if formula[index] == QUOTE_DOUBLE {
        if value.count > 0 {  // unexpected
          tokens1.append(Token(value: value, type: .Unknown, subtype: nil))
          value = ""
        }
        inString = true
        index += 1
        continue
      }

      if formula[index] == QUOTE_SINGLE {
        if value.count > 0 {  // unexpected
          tokens1.append(Token(value: value, type: .Unknown, subtype: nil))
          value = ""
        }
        inPath = true
        index += 1
        continue
      }

      if formula[index] == BRACKET_OPEN {
        inRange = true
        value += String(BRACKET_OPEN)
        index += 1
        continue
      }

      if formula[index] == ERROR_START {
        if value.count > 0 {  // unexpected
          tokens1.append(Token(value: value, type: .Unknown, subtype: nil))
          value = ""
        }
        inError = true
        value += String(ERROR_START)
        index += 1
        continue
      }

      // mark start and end of arrays and array rows
      if formula[index] == BRACE_OPEN {
        if value.count > 0 {  // unexpected
          tokens1.append(Token(value: value, type: .Unknown, subtype: nil))
          value = ""
        }
        var token = Token(value: "ARRAY", type: .Function, subtype: .Start)
        stack.append(token)
        tokens1.append(token)
        token = Token(value: "ARRAYROW", type: .Function, subtype: .Start)
        stack.append(token)
        tokens1.append(token)
        index += 1
        continue
      }

      if formula[index] == SEMICOLON {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand, subtype: nil))
          value = ""
        }
        tokens1.append(Token(value: "", type: stack.removeLast().type, subtype: .Stop))
        tokens1.append(Token(value: ",", type: .Argument, subtype: nil))
        let token = Token(value: "ARRAYROW", type: .Function, subtype: .Start)
        tokens1.append(token)
        stack.append(token)
        index += 1
        continue
      }

      if formula[index] == BRACE_CLOSE {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand, subtype: nil))
          value = ""
        }
        tokens1.append(Token(value: "", type: stack.removeLast().type, subtype: .Stop))
        tokens1.append(Token(value: "", type: stack.removeLast().type, subtype: .Stop))
        index += 1
        continue
      }

      // trim white-space
      if formula[index] == WHITESPACE {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand, subtype: nil))
          value = ""
        }
        // tokens1.append(Token(value: "", type: .Whitespace, subtype: nil))
        index += 1
        while (formula[index] == WHITESPACE) && (index < formula.count) { index += 1 }
        continue
      }

      // multi-character comparators
      if (index + 2) <= formula.count {
        if COMPARATORS_MULTI.contains(String(formula[index..<index + 2])) {
          if value.count > 0 {
            tokens1.append(Token(value: value, type: .Operand, subtype: nil))
            value = ""
          }
          tokens1.append(
            Token(
              value: String(formula[index..<index + 2]), type: .OperatorInfix, subtype: .Logical))
          index += 2
          continue
        }
      }

      // standard infix operators
      if OPERATORS_INFIX.contains(formula[index]) {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand))
          value = ""
        }
        tokens1.append(Token(value: String(formula[index]), type: .OperatorInfix, subtype: nil))
        index += 1
        continue
      }

      // standard postfix operators (only one)
      if OPERATORS_POSTFIX.contains(formula[index]) {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand))
          value = ""
        }
        tokens1.append(Token(value: String(formula[index]), type: .OperatorPostfix, subtype: nil))
        index += 1
        continue
      }

      // start subexpression or function
      if formula[index] == PAREN_OPEN {
        if value.count > 0 {
          let token = Token(value: value, type: .Function, subtype: .Start)
          tokens1.append(token)
          stack.append(token)
          value = ""
        } else {
          let token = Token(value: "", type: .Subexpression, subtype: .Start)
          tokens1.append(token)
          stack.append(token)
        }
        index += 1
        continue
      }

      // function, subexpression, or array parameters, or operand unions
      if formula[index] == COMMA {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand))
          value = ""
        }
        if stack.last!.type != .Function {
          tokens1.append(Token(value: ",", type: .OperatorInfix, subtype: .Union))
        } else {
          tokens1.append(Token(value: ",", type: .Argument))
        }
        index += 1
        continue
      }

      // stop subexpression
      if formula[index] == PAREN_CLOSE {
        if value.count > 0 {
          tokens1.append(Token(value: value, type: .Operand))
          value = ""
        }
        tokens1.append(Token(value: "", type: stack.removeLast().type, subtype: .Stop))
        index += 1
        continue
      }

      // token accumulation
      value += String(formula[index])
      index += 1
    }

    // dump remaining accumulation
    if value.count > 0 { tokens1.append(Token(value: value, type: .Operand)) }

    // move tokenList to new set, excluding unnecessary white-space tokens and converting necessary ones to intersections
    var tokens2 = [Token]()
    while tokens1index < tokens1.count - 1 {
      tokens1index += 1
      guard let token = tokens1index == -1 ? nil : tokens1[tokens1index] else { continue }
      if token.type != TokenType.Whitespace {
        tokens2.append(token)
        continue
      }

      if tokens1index <= 0 || (tokens1index >= (tokens1.count - 1)) { continue }

      guard let previous = tokens1index < 1 ? nil : tokens1[tokens1index - 1] else { continue }
      if !(((previous.type == .Function) && (previous.subtype == .Stop))
        || ((previous.type == .Subexpression) && (previous.subtype == .Stop))
        || (previous.type == .Operand))
      {
        continue
      }
      guard let next = tokens1index >= (tokens2.count - 1) ? nil : tokens1[tokens1index + 1] else {
        continue
      }
      if !(((next.type == .Function) && (next.subtype == .Start))
        || ((next.type == .Subexpression) && (next.subtype == .Start)) || (next.type == .Operand))
      {
        continue
      }
      tokens2.append(Token(value: "", type: .OperatorInfix, subtype: .Intersection))
    }

    // move tokens to final list, switching infix "-" operators to prefix when appropriate, switching infix "+" operators
    // to noop when appropriate, identifying operand and infix-operator subtypes, and pulling "@" from function names
    var tokens = [Token]()
    while tokens2index < tokens2.count - 1 {
      tokens2index += 1
      guard var token = tokens2index == -1 ? nil : tokens2[tokens2index] else { continue }

      let previous = tokens2index < 1 ? nil : tokens2[tokens2index - 1]

      if token.type == .OperatorInfix && token.value == "-" {
        if tokens2index <= 0 {
          token.type = .OperatorPrefix
        } else if ((previous!.type == .Function) && (previous!.subtype == .Stop))
          || ((previous!.type == .Subexpression) && (previous!.subtype == .Stop))
          || (previous!.type == .OperatorPostfix) || (previous!.type == .Operand)
        {
          token.subtype = .Math
        } else {
          token.type = .OperatorPrefix
        }
        tokens.append(token)
        continue
      }

      if token.type == .OperatorInfix && token.value == "+" {
        if tokens2index <= 0 {
          continue
        } else if ((previous!.type == .Function) && (previous!.subtype == .Stop))
          || ((previous!.type == .Subexpression) && (previous!.subtype == .Stop))
          || (previous!.type == .OperatorPostfix) || (previous!.type == .Operand)
        {
          token.subtype = .Math
        } else {
          continue
        }
        tokens.append(token)
        continue
      }

      if token.type == .OperatorInfix && token.subtype == .Nothing {
        if token.value.hasPrefix("<>=") {
          token.subtype = .Logical
        } else if token.value == "&" {
          token.subtype = .Concatenation
        } else {
          token.subtype = .Math
        }
        tokens.append(token)
        continue
      }

      if token.type == .Operand && token.subtype == .Nothing {
        let d = Double(token.value)
        let isNumber = d != nil
        if !isNumber {
          if token.value == "TRUE" || token.value == "FALSE" {
            token.subtype = .Logical
          } else {
            token.subtype = .Range
          }
        } else {
          token.subtype = .Number
        }
        tokens.append(token)
        continue
      }

      if token.type == .Function {
        if token.value.count > 0 {
          if token.value.hasPrefix("@") { token.value = String(token.value.dropFirst()) }
        }
      }
      tokens.append(token)
    }
    return tokens
  }
}

// let formula = #"=IF(UW1664=0,0,MIN(A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(UT1665=0,0,A_overall_heat_stup_cons),MAX(0,MIN(El_boiler_cap_ud,UA1664+UN1664-(UP1664-UQ1664)-UT1664)*El_boiler_eff+UO1664+UE1664/PB_Ratio_Heat_input_vs_output-UU1664),MAX(0,UA1664+UN1664-(UP1664-UQ1664)-UT1664-MIN(El_boiler_cap_ud,MAX(0,A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons+IF(UT1665=0,0,A_overall_heat_stup_cons)+UU1664-UO1664-UE1664/PB_Ratio_Heat_input_vs_output)/El_boiler_eff)-IF(UT1665=0,0,A_overall_stup_cons)-A_overall_fix_stby_cons)/A_overall_var_max_cons*A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons+IF(UT1665=0,0,A_overall_heat_stup_cons)))"#

// let formula1 = #"=COUNTIFS(Calculation!$CS$5:$CS$8764,"="&$A240,Calculation!$BX$5:$BX$8764,">0",Calculation!$CC$5:$CC$8764,">0")"#

// print(ExcelFormula(formula1).indented)
// ExcelFormula(formula1).tokens.forEach { print($0) }
// ExcelFormula(formula1).tokens.map(\.type).forEach { print($0) }

import Utilities

func foo1() {
  let date = Date()
  let csv = CSVReader(atPath: "20220416_sun overtaking.csv", separator: ";", filter: "ValueY", parseDates: 0)!

  let xs = csv.dates.map(\.timeIntervalSince1970).map{Double($0)}.prefix(3600)
  for header in csv.headerRow! { 
    let ys = csv[header].prefix(3600)
    if ys[0].isZero { continue }
    let plot1 = Gnuplot(xs: xs, ys: ys, style: .lines(smooth: true))
    // let plot1 = Gnuplot(xys: downsample(values: zip(xs,ys).map { ($0.0, $0.1) }, threshold: 540).map { [$0.0, $0.1] }, style: .lines(smooth: true))
    plot1.settings["xdata"] = "time"
    plot1.settings["timefmt"] = "'%s'"
    try! plot1(.pdf(path: "\(header.filter({$0 != "\""})).pdf"))
  }
}
foo1()
