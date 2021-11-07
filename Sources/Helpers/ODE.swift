//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Numerics

func explicitRungeKutta<Vector: OdeVector, Tableau: ButchersTableau>(
  tableau: Tableau, ys: inout UnsafeMutableBufferPointer<Vector>, ts: [Vector.Scalar],
  y0: Vector, dydx: (Vector, Vector.Scalar) -> Vector, tol: Vector.Scalar) -> Int
where Vector.Scalar == Tableau.Scalar {
  typealias Scalar = Tableau.Scalar
  let stages = tableau.stages
  let dense_order = tableau.dense_order
  let order = tableau.order
  let a = tableau.a
  let p = tableau.p
  let c = tableau.c
  let b = tableau.b
  let b_hat = tableau.b_hat

  var y_hat_n = y0
  ys[0] = y0
  var it = 1
  var k: [Vector] = [Vector](repeating: Vector(repeating: 0), count: stages)

  let N = ts.count
  if N == 0 { return 0 }
  var t_n = ts[0]
  var h_n = ts[N - 1] - t_n
  var step_count = 0
  k[stages - 1] = dydx(y0, t_n)
  while t_n < ts[N - 1] {
    var step_rejected = true
    while step_rejected {
      // reuse last k (we have asserted that the last c value is 1.0)
      let last_k_store = k[stages - 1]
      k[0] = k[stages - 1]
      for i in 1..<stages {
        var sum_ak = Vector(repeating: 0)
        for j in 0..<i { sum_ak += a[i][j] * k[j] }
        k[i] = dydx(y_hat_n + h_n * sum_ak, t_n + c[i] * h_n)
      }

      // calculate final value and error
      var error = Vector(repeating: 0)
      var sum_bk = Vector(repeating: 0)
      for i in 0..<stages {
        sum_bk += b_hat[i] * k[i]
        error += (b_hat[i] - b[i]) * k[i]
      }
      let y_hat_np1 = y_hat_n + h_n * sum_bk

      // check if step is successful, i.e error is below set tolerance
      let E_hp1 = (h_n * error).inf_norm()
      if E_hp1 < tol {
        // if moved over any requested times then interpolate their values
        let t_np1 = t_n + h_n
        while it < ts.count && t_np1 >= ts[it] {
          let sigma = (ts[it] - t_n) / h_n
          var Phi = Vector(repeating: 0)
          for i in 0..<stages {
            var term = sigma
            var b_i = term * p[i][0]
            for j in 1..<dense_order {
              term *= sigma
              b_i += term * p[i][j]
            }
            Phi += b_i * k[i]
          }
          ys[it] = y_hat_n + h_n * Phi
          it += 1
        }

        // move to next step
        step_rejected = false
        y_hat_n = y_hat_np1
        t_n = t_np1
        step_count += 1
      } else {
        // failed step, reset last k back to stored value
        k[stages - 1] = last_k_store
      }
      // adapt step size
      h_n *= 0.9 * Scalar.pow(tol / E_hp1, 1.0 / (Scalar(order) + 1.0))
    }
  }
  return it
}

protocol ButchersTableau {
  associatedtype Scalar
  var stages: Int { get }
  var order: Int { get }
  var estimator_order: Int { get }
  var dense_order: Int { get }
  var c: [Scalar] { get }
  var a: [[Scalar]] { get }
  var b_hat: [Scalar] { get }
  var b: [Scalar] { get }
  var p: [[Scalar]] { get }
}

struct DormondPrice<Scalar: Real & BinaryFloatingPoint>: ButchersTableau {
  typealias Scalar = Scalar
  let stages = 7
  let order = 5
  let estimator_order = 4
  let dense_order = 5
  let c: [Scalar] = [Scalar(0.0), Scalar(1.0 / 5.0), Scalar(3.0 / 10.0), Scalar(4.0 / 5.0), Scalar(8.0 / 9.0), Scalar(1.0), Scalar(1.0)]
  let a: [[Scalar]] = [
    [Scalar(0.0), Scalar(0.0), Scalar(0.0), Scalar(0.0), Scalar(0.0)], [Scalar(1.0 / 5.0), Scalar(0.0), Scalar(0.0), Scalar(0.0), Scalar(0.0)], [Scalar(3.0 / 40.0), Scalar(9.0 / 40.0), Scalar(0.0), Scalar(0.0), Scalar(0.0)],
    [Scalar(44.0 / 45.0), Scalar(-56.0 / 15.0), Scalar(32.0 / 9.0), Scalar(0.0), Scalar(0.0)], [Scalar(19372.0 / 6561.0), Scalar(-25360.0 / 2187.0), Scalar(64448.0 / 6561.0), Scalar(-212.0 / 729.0), Scalar(0.0)],
    [Scalar(9017.0 / 3168.0), Scalar(-355.0 / 33.0), Scalar(46732.0 / 5247.0), Scalar(49.0 / 176.0), Scalar(-5103.0 / 18656.0)],
    [Scalar(35.0 / 384.0), Scalar(0.0), Scalar(500.0 / 1113.0), Scalar(125.0 / 192.0), Scalar(-2187.0 / 6784.0), Scalar(11.0 / 84.0)],
  ]

  let b_hat: [Scalar] = [Scalar(35.0 / 384.0), Scalar(0.0), Scalar(500.0 / 1113.0), Scalar(125.0 / 192.0), Scalar(-2187.0 / 6784.0), Scalar(11.0 / 84.0), Scalar(0.0)]

  let b: [Scalar] = [Scalar(5179.0 / 57600.0), Scalar(0.0), Scalar(7571.0 / 16695.0), Scalar(393.0 / 640.0), Scalar(-92097.0 / 339200.0), Scalar(187.0 / 2100.0), Scalar(1.0 / 40.0)]

  let p: [[Scalar]] = [
    [Scalar(1.0), Scalar(-32272833064.0 / 11282082432.0), Scalar(34969693132.0 / 11282082432.0), Scalar(-13107642775.0 / 11282082432.0), Scalar(157015080.0 / 11282082432.0)], [Scalar(0.0), Scalar(0.0), Scalar(0.0), Scalar(0.0), Scalar(0.0)],
    [Scalar(0.0), Scalar(1323431896.0 * 100.0 / 32700410799.0), Scalar(-2074956840.0 * 100.0 / 32700410799.0), Scalar(914128567.0 * 100.0 / 32700410799.0), Scalar(-15701508.0 * 100.0 / 32700410799.0)],
    [Scalar(0.0), Scalar(-889289856.0 * 25.0 / 5641041216.0), Scalar(2460397220.0 * 25.0 / 5641041216.0), Scalar(-1518414297.0 * 25.0 / 5641041216.0), Scalar(94209048.0 * 25.0 / 5641041216.0)],
    [Scalar(0.0), Scalar(259006536.0 * 2187.0 / 199316789632.0), Scalar(-687873124.0 * 2187.0 / 199316789632.0), Scalar(451824525.0 * 2187.0 / 199316789632.0), Scalar(-52338360.0 * 2187.0 / 199316789632.0)],
    [Scalar(0.0), Scalar(-361440756.0 * 11.0 / 2467955532.0), Scalar(946554244.0 * 11.0 / 2467955532.0), Scalar(-661884105.0 * 11.0 / 2467955532.0), Scalar(106151040.0 * 11.0 / 2467955532.0)],
    [Scalar(0.0), Scalar(44764047.0 / 29380423.0), Scalar(-127_201_567 / 29380423.0), Scalar(90730570.0 / 29380423.0), Scalar(-8293050.0 / 29380423.0)],
  ]
}

public protocol OdeVector: AdditiveArithmetic {
  associatedtype Scalar: Real & BinaryFloatingPoint

  var scalarCount: Int { get }
  subscript(index: Int) -> Self.Scalar { get set }

  init(repeating x: Scalar)

  static func * (lhs: Self.Scalar, rhs: Self) -> Self

  func inf_norm() -> Scalar
}

extension OdeVector {
  /// Default implementation for inf_norm
  public func inf_norm() -> Scalar {
    var max: Scalar = abs(self[0])
    for i in 1..<self.scalarCount {
      let abs_data = abs(self[i])
      if abs_data > max { max = abs_data }
    }
    return max
  }

  public static func integrate(
    over ts: Array<Self.Scalar>, y0: Self, tol: Self.Scalar,
    dydx: (Self, Self.Scalar) -> Self) -> Array<Self>
  {
    let n = ts.count
    return Array<Self>(unsafeUninitializedCapacity: n) { buffer, initializedCount in
      initializedCount = explicitRungeKutta(tableau: DormondPrice<Scalar>(), ys: &buffer, ts: ts, y0: y0, dydx: dydx, tol: tol)
    }
  }
}

// Make a Double conform to a OdeVector of size 1
extension Double: OdeVector {
  public typealias Scalar = Double

  public subscript(index: Int) -> Self.Scalar {
    get { return self }
    set { self = newValue }
  }

  public var scalarCount: Int { return 1 }

  public init(repeating x: Scalar) { self = x }

  public func inf_norm() -> Scalar { return abs(self) }
}

// Make a Float conform to a OdeVector of size 1
extension Float: OdeVector {
  public typealias Scalar = Float

  public subscript(index: Int) -> Self.Scalar {
    get { return self }
    set { self = newValue }
  }

  public var scalarCount: Int { return 1 }

  public init(repeating x: Scalar) { self = x }

  public func inf_norm() -> Scalar { return abs(self) }
}

// Make all the SIMD types conform to a OdeVector
extension SIMD2: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD3: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD4: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD8: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD16: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD32: OdeVector where Scalar: Real & BinaryFloatingPoint {}
extension SIMD64: OdeVector where Scalar: Real & BinaryFloatingPoint {}

#if os(macOS)
extension SIMD2: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD3: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD4: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD8: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD16: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD32: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
extension SIMD64: AdditiveArithmetic where Scalar: Real & BinaryFloatingPoint {}
#endif
