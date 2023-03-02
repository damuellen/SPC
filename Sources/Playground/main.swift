import Foundation
import Libc
import Utilities
let fm = FileManager.default

func dd(_ dateString: Substring) -> Double? {
  let date = dateString.split(maxSplits: 6, omittingEmptySubsequences: false, whereSeparator: { !$0.isWholeNumber })
  let values = date.prefix(6).map { Int32(String($0))! }
  if date.count < 6 { return nil }
  var t = time_t()
  time(&t)
  #if os(Windows)
  var info = tm()
  localtime_s(&info, &t)
  #else
  var info = localtime(&t)!.pointee
  #endif
  info.tm_year = values[2] - 1900
  info.tm_mon = values[1] - 1
  info.tm_mday = values[0]
  if values.count > 4 {
    info.tm_hour = values[3] + 1
    info.tm_min = values[4]
  }
  if values.count > 5 {
    info.tm_sec = values[5]
  }
  return Double(mktime(&info))
}


var store = [Double:Double]()
var nn = 0
let files = try! fm.contentsOfDirectory(atPath: "Shagaya")
for file in files {
  if file.hasSuffix(".csv") {
    nn += 1
    let content = try! String(contentsOfFile: "Shagaya/" + file)
    for line in content.split(separator: "\r\n") {
      if let date = dd(line), 
        let value = Double(line.split(separator: ",", maxSplits: 1).last!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")) {
          store[date] = value
      }
    }    
  }
}

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

func unixtime_to_excel_date(_ unixtime: Double, date_1904: Bool = false) -> Double {
  var excel_datetime = 0.0
  let epoch = date_1904 ? 24107.0 : 25568.0
  excel_datetime = epoch + (unixtime / (24 * 60 * 60.0))

  if (!date_1904 && excel_datetime >= 60.0) {
      excel_datetime += 1.0
  }
  return excel_datetime;
}

var bucket = [(Double, Double)]()

for date in store.keys.sorted() {
  let value = store[date]!
  bucket.append((date, value > 1 ? value : 0))
}

for line in downsample(values: bucket, threshold: nn * 24 * 6) {
  print("\(unixtime_to_excel_date(line.0)), \(line.1)", separator: "\t", terminator: "\r\n")
}

let plot1 = Gnuplot(xs: bucket.map(\.0), ys: bucket.map(\.1), style: .lines(smooth: true))

plot1.settings["xdata"] = "time"
plot1.settings["timefmt"] = "'%s'"
try! plot1(.pngLarge(("Plot.png"))
