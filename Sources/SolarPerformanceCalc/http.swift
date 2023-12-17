// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import BlackBoxModel
import Foundation
import DateExtensions
import Web

extension Recording {
  /// Processes an HTTP request and generates an HTTP response with a dynamic HTML body.
  func respond(request: HTTP.Request) -> HTTP.Response {
    // Extract the URI from the request
    guard let day = request["day"] else { 
      return .init(html: HTML(body: "<pre>\(description)</pre>")) 
    }
    let imageRequested: Bool = request.uri.hasSuffix("plot.png")
    // Extract the day from the URI
    guard let day = Int(day) else {
      return HTTP.Response(response: .BAD_REQUEST)
    }
    guard case 0..<366 = day else {
      return HTTP.Response(response: .METHOD_NOT_ALLOWED)
    }
    Swift.print("\r\(request)", terminator: "\u{001B}[?25l")
    fflush(stdout)
    let year = BlackBoxModel.simulatedYear
    // Calculate y-axis ranges for the plot
    let yRange = ((maxMassFlow / 100).rounded(.up) * 110, (maxHeatFlow / 100).rounded(.up) * 110)

    let range = DateInterval(ofDay: day, in: year)

    // Retrieve mass flow and power data for the specified day
    let y1 = massFlows(range: range)
    let y2 = power(range: range)
    
    // Create a TimeSeriesPlot with the extracted data and specific plot configuration
    let plot = TimeSeriesPlot(y1: y1, y2: y2, range: range, yRange: yRange, style: .impulses)
    
    // Set y-axis titles for the plot
    plot.y1Titles = ["solarfield", "powerblock", "storage"]
    let p = ["solar", "production", "toStorage", "fromStorage", "gross", "net", "consum"]
    plot.y2Titles = p
    
    // Convert the plot to a base64-encoded image string
    guard let data = try? plot.callAsFunction(toFile: "") else { return .init(response: .SERVER_ERROR) }
    if imageRequested { return HTTP.Response(bodyData: data) }
    let base64PNG = data.base64EncodedString()
    // Create the HTML body with dynamic content based on the data and plot
    var body = "<div>\n\(icon("left"))<h1></h1>\n"
    body += #"<img id="image" alt="" width="1573" height="800" src="data:image/png;base64,"#
    body += base64PNG + "\"/>\n\(icon("right"))\n</div>"

    // Return an HTTP response containing the generated HTML body
    return .init(html: .init(body: body + stylesheets() + script(day, year: year)))
  }
}