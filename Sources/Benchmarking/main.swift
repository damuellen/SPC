import Benchmark
import Meteo

let handler = try! MeteoDataFileHandler(
  forReadingAtPath: "Model.playground/Resources/AlAbdaliyah.mto")
var source: MeteoDataProvider? = nil
benchmark("read Meteofile") { source = try! handler() }

Benchmark.main()
