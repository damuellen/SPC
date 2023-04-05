//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation 
import Helpers

extension Double {
  @inline(__always)
  func asString(precision: Int = 2) -> String {
    String(format: "%.\(precision)f", self)
  }
}

func formatting(_ values: [Double], _ labels: [String]) -> String {
  let pairs = zip(    
    labels.map { "  " + $0.padding(30) },
    values.map { String(format: "%03.2f", $0) }
  )
  return pairs.map { $0.0 + $0.1 }.joined(separator: "\n")
}

extension String {
  func padding(_ length: Int) -> String {
    padding(toLength: length, withPad: " ", startingAt: 0)
  }
}

/// Generates the title with border
public func decorated(_ title: String, width: Int = terminalWidth()) -> String {
  let width = median(80, width, 110)
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

typealias Angle = Double

extension Angle {
  public var toRadians: Double { self * .pi / 180 }
  public var toDegrees: Double { self * (180 / .pi) }
}

public struct RepeatedElementsSequence<Base: Sequence, Element>: Sequence
where Base.Element == Element {

  @usableFromInline
  let base: Base

  @usableFromInline
  var times: Int

  @inlinable
  init(_ base: Base, times: Int) {
    self.base = base
    self.times = times
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    var base: Base.Iterator

    @usableFromInline
    var times: Int

    @usableFromInline
    var counter: Int = 0

    @usableFromInline
    var element: Base.Element?

    @inlinable
    init(base: Base.Iterator, times: Int) {
      precondition(times > 0)
      self.base = base
      self.times = times
      self.element = nil
    }

    @inlinable
    public mutating func next() -> Element? {
      defer {
        counter += 1
        if counter == times {
          if let wrapped = base.next() {
            counter = 0
            element = wrapped
          } else {
            element = nil
          }
        } 
      }
      if element == nil, let wrapped = base.next() {
        element = wrapped
      }
      return element
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base.makeIterator(), times: times)
  }
}

extension Collection {

  /// Returns a sequence that repeats every element of this collection the
  /// specified number of times.
  ///
  /// Passing `1` as `times` results in this collection's elements being
  /// provided a single time.
  ///
  /// - Parameter times: The number of times to repeat this sequence. `times`
  ///   must be one or greater.
  /// - Returns: A sequence that repeats the elements of this sequence `times`
  ///   times.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func repeated(times: Int) -> RepeatedElementsSequence<Self, Element> {
    RepeatedElementsSequence(self, times: times)
  }
}