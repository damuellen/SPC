//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Dispatch

extension RandomAccessCollection {
  /// Returns `self.map(transform)`, computed in parallel.
  @inlinable
  public func concurrentMap<E>(minBatchSize: Int = 8760, _ transform: (Element) -> E)
    -> [E]
  {
    let n = self.count
    let batchCount = (n + minBatchSize - 1) / minBatchSize
    if batchCount < 2 { return self.map(transform) }
    return Array(unsafeUninitializedCapacity: n) {
      uninitializedMemory, resultCount in resultCount = n
      let baseAddress = uninitializedMemory.baseAddress!
      DispatchQueue.concurrentPerform(iterations: batchCount) { b in
        let startOffset = b * n / batchCount
        let endOffset = (b + 1) * n / batchCount
        var sourceIndex = index(self.startIndex, offsetBy: startOffset)
        for p in baseAddress + startOffset..<baseAddress + endOffset {
          p.initialize(to: transform(self[sourceIndex]))
          formIndex(after: &sourceIndex)
        }
      }
    }
  }
}
