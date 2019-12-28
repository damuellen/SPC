// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SPC",
  platforms: [
    .macOS(.v10_13), .iOS(.v12),
  ],
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["Run"]),
    .library(name: "BlackBoxModel", targets: ["BlackBoxModel"]),
    ],

  dependencies: [
  //  .package(url: "../SwiftPV", .branch("master")),
    .package(url: "https://github.com/Nike-Inc/Willow.git", from: "5.0.0")
    ],
  targets: [
    .target(
      name: "Config",
      dependencies: []),
    .target(
    name: "DateGenerator",
    dependencies: []),
    .target(
       name: "CSPA",
       dependencies: []),
    .target(
       name: "CSOLPOS",
       dependencies: []),
    .target(
    name: "SolarPosition",
    dependencies: ["DateGenerator", "CSOLPOS", "CSPA"]),
    .target(
      name: "BlackBoxModel",
      dependencies: ["Config", "Meteo", "SolarPosition", "Willow"]),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"]),
    .target(
      name: "Run",
      dependencies: ["Config", "BlackBoxModel"]),
    .testTarget(
      name: "MeteoTests",
      dependencies: ["DateGenerator", "SolarPosition"]),
    .testTarget(
      name: "BlackBoxModelTests",
      dependencies: ["Config", "Meteo", "SolarPosition", "BlackBoxModel"]),
    ],
  swiftLanguageVersions: [.v5]
)
