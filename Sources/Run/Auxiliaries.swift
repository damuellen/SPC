
import Foundation
import BlackBoxModel

let dateString: String = {
  let infoPath = Bundle.main.executablePath!
  let infoAttr = try! FileManager.default.attributesOfItem(atPath: infoPath)
  let infoDate = infoAttr[FileAttributeKey.creationDate] as! Date
  
  let df = DateFormatter()
  df.dateStyle = .short
  df.timeStyle = .short
  return df.string(from: infoDate)
}()

extension Substring.SubSequence {
  var integerValue: Int? { return Int(self) }
}

public func goalSeek(
  _ keyPath: KeyPath<PerformanceLog.Results, Double>,
  greaterThen: Double,
  block: ()->()
  ) -> PerformanceLog {
  var result = BlackBoxModel.runModel()
  while result.annual[keyPath: keyPath] < greaterThen {
    block()
    result = BlackBoxModel.runModel()
    print(result.annual[keyPath: keyPath])
  }
  return result
}
