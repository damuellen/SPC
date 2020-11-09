// swift-tools-version:5.2
import PackageDescription

let condition = BuildSettingCondition.when(configuration: .release)
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
   // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
   // .library(name: "Utility", type: .dynamic, targets: ["Utility"])
    ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git",
             .revision("53555a04503c175eaffcf587e4b8c380a7c41a5c")),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master"))
    ],
  targets: [
    .target(
      name: "Libc",
      dependencies: []),
    .target(
      name: "Utility",
      dependencies: ["Libc"],
      cxxSettings: [.define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows]))],
      linkerSettings: [.linkedLibrary("Pathcch", .when(platforms: [.windows]))]),
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
      dependencies: [
        "Config", "Meteo", "SolarPosition", "CIAPWSIF97", "Utility",
        .product(name: "SQLite", package: "SQLite.swift")],
      swiftSettings: swiftSettings,
      linkerSettings: [
        .linkedLibrary("C:/Library/sqlite3/sqlite3.lib", .when(platforms: [.windows])),
        .unsafeFlags(["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"], .when(platforms: [.windows]))]),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"],
      swiftSettings: swiftSettings),
    .target(
      name: "Run",
      dependencies: [
        "Config", "BlackBoxModel",
        .product(name: "ArgumentParser", package: "swift-argument-parser")],
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
