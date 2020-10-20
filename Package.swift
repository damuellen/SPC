// swift-tools-version:5.0
import PackageDescription

let condition =  BuildSettingCondition.when(platforms: [.linux], configuration: .release)
let cSettings = [CSetting.unsafeFlags(["-ffast-math", "-O3",  "-fomit-frame-pointer", "-march=core2", "-funroll-loops"])]
var swiftSettings = [SwiftSetting.unsafeFlags(["-Ounchecked", "-enforce-exclusivity=unchecked", "-DRELEASE"], condition)]
swiftSettings.append(.define("DEBUG", .when(configuration: .debug)))
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
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.5")),
    .package(url: "https://github.com/damuellen/swift-tools-support-core.git",  .branch("main")),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master"))
    ],
  targets: [
    .target(
      name: "Config",
      dependencies: [],
      swiftSettings: swiftSettings),
    .target(
    name: "DateGenerator",
    dependencies: [],
    swiftSettings: swiftSettings),
    .target(
       name: "CSPA",
       dependencies: [],
       cSettings: cSettings),
    .target(
       name: "CSOLPOS",
       cSettings: cSettings),
    .target(
       name: "CIAPWSIF97",
       cSettings: cSettings),
    .target(
      name: "SolarPosition",
      dependencies: ["DateGenerator", "CSOLPOS", "CSPA"],
      swiftSettings: swiftSettings),
    .target(
      name: "BlackBoxModel",
      dependencies: ["Config", "Meteo", "SolarPosition", "CIAPWSIF97", "SwiftToolsSupport", "SQLite"],
      swiftSettings: swiftSettings),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"],
      swiftSettings: swiftSettings),
    .target(
      name: "Run",
      dependencies: [
        "Config", "BlackBoxModel", "ArgumentParser"],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "MeteoTests",
      dependencies: ["DateGenerator", "SolarPosition", "Meteo"]),
    .testTarget(
      name: "BlackBoxModelTests",
      dependencies: ["Config", "Meteo", "SolarPosition", "BlackBoxModel"]),
    ],
  swiftLanguageVersions: [.v5]
)
