import ArgumentParser
import Foundation
import Utilities
import Web
import xlsxwriter


let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
var timeout = Date()

ClearScreen()
#if os(Windows)
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
#else
signal(SIGINT, SIG_IGN)
source.setEventHandler { source.cancel() }
#endif

source.resume()

Command.main()

semaphore.signal()

struct Command: ParsableCommand {
  @Option(name: .short, help: "Meteo file") var file: String?

  @Option(name: .short, help: "Parameter file") var json: String?

  @Flag(name: .long, help: "Do not use Multi-group algorithm") var noGroups = false

  @Flag(name: .long, help: "Run HTTP server") var http = false
  #if os(Windows)
  @Flag(name: .long, help: "Start excel afterwards") var excel = false
  #endif
  @Option(name: .short, help: "Population size") var n: Int?

  @Option(name: .short, help: "Iterations") var iterations: Int?

  @Option(name: .short, help: "Repeats") var repeats: Int?

  func run() throws {
 
    let server = HTTP(handler: respond)
    if http {
      server.start()
      print("web server listening on port \(server.port)")
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { 
        start("http://127.0.0.1:\(server.port)") 
      }
    }

    defer {
      if http {
        source.cancel()
        if -timeout.timeIntervalSinceNow < 10 {
          print("waiting before shutting down")
          Thread.sleep(until: timeout.addingTimeInterval(10))
          Thread.sleep(forTimeInterval: 1)
        }
        server.stop()
      }
    }

    let past = Date()
    //let id = String(Int(past.timeIntervalSince1970), radix: 36, uppercase: true).suffix(4)
    let file = file ?? "/home/daniel/spc/COM/Midelt.mto"
    let bounds = [10.0...200.0,0.0...0.0,20.0...100.0,0.0...0.0,0.0...0.0,10.0...100.0,3.0...12.0]
    let optimizer = IGOA(n: n ?? 30, maxIterations: iterations ?? 100, bounds: bounds)
    let results = optimizer(file)
      
    for result in results {
      print(result)
    }

    print("Elapsed seconds:", -past.timeIntervalSinceNow)
  }
  
}

func removingNearby(_ results: Table) -> Table {
  var addedDict = [Int:Bool]()
  return results.filter {
    addedDict.updateValue(true, forKey: Int($0[1] * 10)) == nil
  }
}

func respond(request: HTTP.Request) -> HTTP.Response {
  var uri = request.uri
  if uri == "/cancel" {
    source.cancel()
  } else {
    uri.remove(at: uri.startIndex)
    timeout = Date()
  }

  let curves = convergenceCurves.map { Array($0.suffix(Int(uri) ?? 10)) }
  if curves[0].count > 1 {
    let m = curves.map(\.last!).map { $0[1] }.min()
    let i = curves.firstIndex(where: { $0.last![1] == m })!
    let plot = Gnuplot()
    plot.settings["xtics"] = "1"
    plot.data(ys: curves[0]).plot(multi: true, index: 0)
    .data(ys: curves[1]).plot(multi: true, index: 1)
    .data(ys: curves[2]).plot(multi: true, index: 2)
    return .init(html: .init(body: plot.svg(), refresh: source.isCancelled ? 0:10))
  }
  return .init(html: .init(refresh: 10))
}

typealias Row = [Double]
typealias Table = [Row]
typealias Tables = [Int:Table]
