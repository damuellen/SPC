/*
import CPikchr

"""
PB: box "Powerblock"
N: circle "Header" at 0.8 n of PB; arrow from PB.n to last chop ->
S: circle "Header" at 0.8 s of PB; arrow from PB.s to last chop ->
S2: circle "Header" at 1.2 s of S; arrow from S.s to last chop ->
box "NE" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 2.0 ne of PB fit
arrow from N.e right until even with last chop then to last chop <->
box "NE2" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 1.5 e of last box fit
arrow from N.e right until even with last chop then to last chop <->
box "NW" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 2.0 nw of PB fit
arrow from N.w left until even with last chop then to last chop <->
box "SW" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 2.0 sw of PB fit
arrow from S.w right until even with last chop then to last chop <->
box "SW2" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 1.2 s of last box fit
arrow from S2.w right until even with last chop then to last chop <->
box "SW3" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 1.5 w of last box fit
arrow from S2.w right until even with last chop then to last chop <->
box "SW4" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 1.5 w of last box fit
arrow from S2.w right until even with last chop then to last chop <->
box "SE" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 2.0 se of PB fit
arrow from S.e left until even with last chop then to last chop <->
box "SE2" "Loops: 20" "Headloss: 20m" "Volume: 20m3" at 1.2 s of last box fit
arrow from S2.e left until even with last chop then to last chop <->
""".withCString {
  try! ("<html><body>" + String(cString: pikchr($0,nil,0,nil,nil)) + "</body></html>").write(toFile: "pikchr.html", atomically: false, encoding: .utf8)
}
solarField.subfields.first!.measurements.reduce("") { (k,v) in 
""""
"\(k): \(v)"
""""
 }
box "\(solarField.subfields.first!.name)" 
SolarField(massFlow: 888) {
  header("North") {
    subfield("East") {
      loops(lhs: 5, rhs: 6)
    }
    subfield("West") {
      SubField(loops: 10)
      SubField(loops: 10)
      SubField(loops: 10)
      SubField(loops: 10)
      SubField(loops: 10)
    }
  }
  header("South") {
    subfield("East") {
      loops(lhs: 5, rhs: 6) { (8,9) } 
      loops(lhs: 5, rhs: 6) { (8,9) } 
    }
    subfield("West") {
      loops(lhs: 5, rhs: 6) { (8,9) } 
      loops(lhs: 5, rhs: 6) { (8,9) }
    }
  }
}
*/