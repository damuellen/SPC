import PlaygroundSupport
import AppKit

/*
 public func goalSeek(
 _ keyPath: KeyPath<PerformanceLog.Results, Double>,
 greaterThen: Double,
 block: ()->()
 ) -> PerformanceLog {
 var result = BlackBoxModel.runModel()
 var count = 1
 while result.annual[keyPath: keyPath] < greaterThen {
 block()
 count += 1
 result = BlackBoxModel.runModel(count)
 print(result.annual[keyPath: keyPath])
 }
 return result
 }
 */
public class View : NSView {
  
  var values: [CGFloat]
  
  public init(frame frameRect: NSRect, values: [CGFloat]) {
    self.values = values
    super.init(frame: frameRect)
  }
  
  required init?(coder decoder: NSCoder) { fatalError() }
  
  override public func draw(_ dirtyRect: NSRect) {
    
    let everest = values.max()!
    let scale = (bounds.height - 50) / everest
    let strides = bounds.width / CGFloat(values.count)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    let attrs: [NSAttributedString.Key:Any] = [
      .font: NSFont(name: "Menlo", size: 14)!,
      .paragraphStyle: paragraphStyle,
      .foregroundColor: NSColor.lightGray
    ]
    
    let steps = (0...24).map(String.init)
    
    for (n,step) in steps.enumerated() {
      let path = NSBezierPath()
      path.move(to: NSPoint(x: ((bounds.width / 24) * CGFloat(n)), y: 0))
      path.line(to: NSPoint(x: ((bounds.width / 24) * CGFloat(n)), y: bounds.height))
      NSColor.darkGray.setStroke()
      path.lineWidth = 1
      path.lineJoinStyle = .round
      path.lineCapStyle = .round
      path.stroke()
      step.draw(with: CGRect(x: ((bounds.width / 24) * CGFloat(n)), y: 3, width: 30, height: 20),
                options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    let interval = 50 as CGFloat
    var n = 0
    
    for _ in stride(from: 0, through: (bounds.height - 25), by: (bounds.height - 25) / 8) {
      let path = NSBezierPath()
      let y = ((bounds.height / 8) * CGFloat(n)) + 25
      path.move(to: NSPoint(x: 0, y: y))
      path.line(to: NSPoint(x: bounds.width, y: y))
      NSColor.darkGray.setStroke()
      path.lineWidth = 1
      path.lineJoinStyle = .round
      path.lineCapStyle = .round
      path.stroke()
      if n > 0 {
        String( Float(CGFloat(n) * interval / scale) )
          .draw(with: CGRect(x: 0, y: y, width: 50, height: 20),
                options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
      }
      n += 1
    }
    
    let path = NSBezierPath()
    var x = 0 as CGFloat
    
    path.move(to: NSPoint(x: x + 0.5, y: 25 + 0.5))
    for value in values {
      path.line(to: NSPoint(x: x + 0.5, y: 25 + 0.5 + (scale * value)))
      x += strides
      path.line(to: NSPoint(x: x + 0.5, y: 25 + 0.5 + (scale * value)))
      
    }
    
    NSColor.lightGray.setStroke()
    path.lineWidth = 2
    path.lineJoinStyle = .round
    path.lineCapStyle = .round
    path.stroke()
  }
}

extension Array: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    if self.isEmpty { return "[]" }
    if self.first is Double {
      return View(frame: NSRect(x: 0, y: 0, width: 1300, height: 500),
                  values: self.map { return CGFloat($0 as! Double) } )
    } else {
      return ""
    }
  }
}
