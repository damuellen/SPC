// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SPC",
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["Run"]),
    ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "../DateGenerator", .branch("master")),
    .package(url: "../SolarPosition", .branch("master")),
    .package(url: "https://github.com/Nike-Inc/Willow.git", from: "5.0.0")
    ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "Config",
      dependencies: []),
    .target(
      name: "BlackBoxModel",
      dependencies: ["Config", "Meteo", "SolarPosition", "Willow"]),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator"]),
    .target(
      name: "Run",
      dependencies: ["Config", "BlackBoxModel"]),
    .testTarget(
      name: "MeteoTests",
      dependencies: ["DateGenerator"]),
    .testTarget(
      name: "BlackBoxModelTests",
      dependencies: ["Config", "Meteo", "BlackBoxModel"]),
    ]
)
