//
//  CalculatedWeight.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public enum CalculatedWeight {

  public static func ofTubes(with schedule: NominalPipeSize) -> [Float] {
    func weightForTube(_ pair: (Float, Int)) -> Float {
      let (wt, idx) = pair
      return 0.02466 * wt * (NominalPipeSize.outsideDiameters[idx] - wt)
    }
    if let weights = tubeWeight[schedule] {
      return weights
    } else {
      let weights = zip(schedule.wallthickness, NominalPipeSize.values.indices)
        .map(weightForTube)
      tubeWeight[schedule] = weights
      return weights
    }
  }

  public static func ofElbows(with schedule: NominalPipeSize) -> [Float] {
    func weightForElbow(_ pair: (Float, Int)) -> Float {
      let (wt, idx) = pair
      let clr = 1.5 * NominalPipeSize.values[idx] * 25.4
      return 0.0387 * wt * (NominalPipeSize.outsideDiameters[idx] - wt)
        * clr / 1_000
    }
    if let weights = elbowWeight[schedule] {
      return weights
    } else {
      let weights = zip(schedule.wallthickness, NominalPipeSize.values.indices)
        .map(weightForElbow)
      elbowWeight[schedule] = weights
      return weights
    }
  }

  public static func ofTees(with schedule: NominalPipeSize) -> [Float] {
    func weightForTee(_ pair: (Float, Int)) -> Float {
      let (wt, idx) = pair
      let clr = 3 * centerToEnd[idx] - NominalPipeSize.outsideDiameters[idx] / 2
      return 0.02466 * (wt + 1.5)
        * (NominalPipeSize.outsideDiameters[idx] - wt - 1.5) * clr / 1_000
    }
    if let weights = teeWeight[schedule] {
      return weights
    } else {
      let weights = zip(schedule.wallthickness, NominalPipeSize.values.indices)
        .map(weightForTee)
      teeWeight[schedule] = weights
      return weights
    }
  }

  public static func ofReducers(with schedule: NominalPipeSize) -> [Float] {
    func weightForReducer(_ pair: (Float, Int)) -> Float {
      let (wt, idx) = pair
      return 0.02466 * wt * (NominalPipeSize.outsideDiameters[idx] - wt)
        * heightReducers[idx] / 1_000
    }
    if let weights = reducerWeight[schedule] {
      return weights
    } else {
      let weights = zip(schedule.wallthickness, NominalPipeSize.values.indices)
        .map(weightForReducer)
      reducerWeight[schedule] = weights
      return weights
    }
  }

  private static var tubeWeight: [NominalPipeSize : [Float]] = [:]
  private static var elbowWeight: [NominalPipeSize : [Float]] = [:]
  private static var teeWeight: [NominalPipeSize : [Float]] = [:]
  private static var reducerWeight: [NominalPipeSize : [Float]] = [:]

  private static let centerToEnd: [Float] = [
    0, 0, 0, 25, 29, 38, 48, 57, 64, 76, 86, 95, 105, 124, 143, 178, 216,
    254, 279, 305, 343, 381, 419, 495, 521, 559, 597, 635, 673]

  private static let weightReductionTee: [Float] = [0.94, 0.91, 0.89, 0.86]

  private static let heightReducers: [Float] = [
    0, 0, 0, 0, 38.1, 50.8, 50.8, 63.5, 76.2, 88.9, 88.9, 101.6, 127, 139.7,
    152.5, 177.8, 203.2, 330.2, 355.6, 381.1, 508.0, 508.0, 0, 0, 0, 0, 0, 0]

  private static let weightReductionReducers: [Float] = [0.94, 0.91, 0.89]
}
