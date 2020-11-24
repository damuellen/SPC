//
//  PipeDimensions.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public enum Insulation {
  public static let cold: [Float] = [
    60, 60, 60, 60, 60, 60, 60, 60, 100, 100, 100, 100, 100, 100, 150, 150,
    200, 200, 200, 200, 200, 200, 250, 250, 300, 300, 300, 300,
    ]
  public static let hot: [Float] = [
    60, 60, 60, 60, 60, 60, 60, 60, 100, 100, 100, 100, 100, 100, 150, 150,
    200, 250, 250, 250, 250, 250, 300, 300, 300, 300, 300, 300,
    ]
}

public struct Schedule {
  public var wallthickness: [Float]

  public static let sch10 = Schedule(wallthickness: [
    1.24, 1.65, 1.65, 2.11, 2.11, 2.77, 2.77, 2.77, 2.77, 3.05,
    3.05, 3.05, 3.05, 3.40, 3.40, 3.76, 0, 0, 6.35, 6.35, 6.35,
    6.35, 6.35,	6.35, 7.92, 7.92, 7.92, 7.92, 7.92, 0.00])

  public static let sch10S = Schedule(wallthickness: [
    1.24, 1.65, 1.65, 2.11, 2.11, 2.77, 2.77, 2.77, 2.77, 3.05,
    3.05, 3.05, 3.05, 3.40, 3.40, 3.76, 4.19, 4.57, 4.78, 4.78,
    4.78, 4.78,	5.54, 6.35, 0.00, 0.00, 0.00, 0.00, 0.00])

  public static let sch30 = Schedule(wallthickness: [
    1.45, 1.85, 1.85, 2.41, 2.41, 2.90, 2.97, 3.17, 3.17, 4.78,
    4.78, 4.78, 4.78, 0.00, 0.00, 7.04, 7.80, 8.38, 9.53, 9.53,
    11.13, 12.70, 14.27, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00])

  public static let sch40 = Schedule(wallthickness: [
    1.73, 2.24, 2.31, 2.77, 2.87, 3.38, 3.56, 3.68, 3.91, 5.16,
    5.49, 5.70,	6.02, 6.55, 7.11, 8.18, 9.27, 10.31, 11.07, 12.70,
    14.28, 15.08, 17.45, 17.48,	17.48, 17.48, 17.48, 19.05, 19.05])

  public static let sch80S = Schedule(wallthickness: [
    2.41, 3.02, 3.2, 3.73, 3.91, 4.55, 4.85, 5.08, 5.54, 7.01,
    7.62, 8.08,	8.56, 9.53, 10.97, 12.70, 12.70, 12.70, 12.70, 12.70,
    12.70, 12.70, 12.70, 12.70, 0.00, 0.00, 0.00, 0.00, 0.00])

  public static let sch80 = Schedule(wallthickness: [
    2.41, 3.02, 3.2, 3.73, 3.91, 4.55, 4.85, 5.08, 5.54, 7.01,
    7.62, 8.08,	8.56, 9.53, 10.97, 12.7, 15.09, 17.48, 19.05, 21.44,
    23.83, 26.19, 30.96, 0, 0, 0, 0, 0, 0])

  public static let sch120 = Schedule(wallthickness: [
    0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
    0.00, 0.00, 11.13, 12.70, 14.27, 18.26, 21.44, 25.40, 27.79, 30.96,
    34.93, 38.10, 46.02, 0, 0, 0, 0, 0, 0])

  public static let sch140 = Schedule(wallthickness: [
    0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
    0.00, 0.00, 0.00, 0.00, 0.00, 20.62, 25.40, 28.58, 31.75, 36.53,
    39.67, 44.45, 52.37, 0, 0, 0, 0, 0, 0])

  public static let sch160 = Schedule(wallthickness: [
    0.00, 0.00, 0.00, 4.78, 5.56, 6.35, 6.35, 7.14, 8.74, 9.53,
    11.13, 0, 13.49, 15.88, 18.26, 23.01, 28.58, 33.32, 35.71, 40.49,
    45.24, 50.01, 59.54, 0, 0, 0, 0, 0, 0])
}

public enum NominalPipeSizes: String, CaseIterable {

  case sch10 = "SCH10", sch10S = "SCH10S", sch30 = "SCH30",
  sch40 = "SCH40", sch80 = "SCH80", sch80S = "SCH80S",
  sch120 = "SCH120", sch140 = "SCH140", sch160 = "SCH160"

  subscript(nps: Float) -> (Float, Float) {
    guard let idx = NominalPipeSizes.values.firstIndex(of: nps)
      else { return (0, 0)}
    return (NominalPipeSizes.outsideDiameters[idx], wallthickness[idx])
  }

  public var wallthickness: [Float] {
    switch self {
    case .sch10: return Schedule.sch10.wallthickness
    case .sch10S: return Schedule.sch10S.wallthickness
    case .sch30: return Schedule.sch30.wallthickness
    case .sch40: return Schedule.sch40.wallthickness
    case .sch80: return Schedule.sch80.wallthickness
    case .sch80S: return Schedule.sch80S.wallthickness
    case .sch120: return Schedule.sch120.wallthickness
    case .sch140: return Schedule.sch140.wallthickness
    case .sch160: return Schedule.sch160.wallthickness
    }
  }

  public var weightPerMeter: [Float] { CalculatedWeight.ofTubes(with: self) }

  public static let values: [Float] = [
    0.125, 0.25, 0.38, 0.50, 0.75, 1.00, 1.25, 1.50, 2.00, 2.50,
    3.00, 3.50, 4.00, 5.00, 6.00, 8.00, 10.00, 12.00, 14.00, 16.00,
    18.00, 20.00, 24.00, 28.0, 30.00, 32.00, 34.00, 36.00]

  public static let outsideDiameters: [Float] = [
    10.29, 13.72, 17.15, 21.34, 26.67, 33.40, 42.16, 48.26, 60.33, 73.03,
    88.90, 101.6, 114.3, 141.3, 168.28, 219.08, 273.05, 323.85, 355.6, 406.4,
    457.20, 508.00, 609.60, 711.20, 762.00, 813.00, 864.0, 914.0]
}
