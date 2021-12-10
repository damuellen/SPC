
import Foundation
import Utilities

// let c = CSV(atPath: "/workspaces/SPC/Saudian.csv")!
// let dni = c["DNI"]
// let ss = dni.chunks(ofCount: 24)
// var count = 1
// var result = [Double]()

// for day in ss {
//   let y1 = Array(day)
//   let x1 = [Double](stride(from: 0, to: Double(y1.count), by: 1))
//   let x2 = [Double](stride(from: 0, to: Double(y1.count), by: 1 / 12))
//   let d = CubicSpline(x: x1, y: y1)
//   let y2 = x2.map(d.callAsFunction(x:)).map { max(0, $0) }
//   let factor = y1.reduce(0, +) / (y2.reduce(0, +) / 12)
//   let y3 = y2.map { factor * $0 }
//   // try! Gnuplot(xs: x1, x2, x2, ys: y1, y2, y3)(.pngLarge(path: "dni_\(count).png"))
//   count += 1
//   result.append(contentsOf: y3)
// }

// try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
//   .plot(multi: true, index: 0, x: 0, y: 1)
//   .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test1.png"))
// try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
//   .plot(multi: true, index: 0, x: 0, y: 1)
//   .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test2.png"))
// // dni.map { $0 < 5 ? 0 : $0 }.forEach { print($0) }


// let xml = try! XML(atPath: "/workspaces/SPC/wb.xml")

// print(xml.children[5].children.map {

//   "let " + $0.attributes["name"]! + " = 0.0 //" + $0.value
// }.sorted().joined(separator: "\n")
// ) 