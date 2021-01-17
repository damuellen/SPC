// swift-tools-version:5.2
import PackageDescription

let condition = BuildSettingCondition.when(configuration: .release)
let c = [CSetting.unsafeFlags(["-ffast-math", "-O3",  "-fomit-frame-pointer", "-funroll-loops"])]
var swift = [SwiftSetting.unsafeFlags(["-Ounchecked", "-enforce-exclusivity=unchecked", "-DRELEASE"], condition)]
swift.append(.define("DEBUG", .when(configuration: .debug)))
let package = Package(
  name: "SPC",
  platforms: [
    .macOS(.v10_13), .iOS(.v12),
  ],
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["SolarPerformanceCalc"]),
    .executable(name: "SolarFieldCalc", targets: ["SolarFieldCalc"]),
   // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
   // .library(name: "Utility", type: .dynamic, targets: ["Utility"])
    ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git",
             .revision("53555a04503c175eaffcf587e4b8c380a7c41a5c")),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master")),
    .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", .branch("main")),
//  .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.1")
    ],
  targets: [
    .target(name: "Libc"),
    .target(name: "Config", swiftSettings: swift),
    .target(name: "DateGenerator", swiftSettings: swift),
    .target(name: "CPikchr", cSettings: c),
    .target(name: "CSPA", cSettings: c),
    .target(name: "CSOLPOS", cSettings: c),
    .target(name: "CIAPWSIF97", cSettings: c),
    .target(name: "SolarPosition",
      dependencies: ["DateGenerator", "CSOLPOS", "CSPA"],
      swiftSettings: swift),
    .target(name: "BlackBoxModel",
      dependencies: [
        "Config", "Meteo", "SolarPosition", "CIAPWSIF97",
        .product(name: "SQLite", package: "SQLite.swift"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
     .target(name: "SolarFieldModel",
      dependencies: ["Libc"],
      swiftSettings: swift),
    .target(name: "SolarFieldCalc",
      dependencies: [
        "SolarFieldModel", "CPikchr",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
    .target(name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"],
      swiftSettings: swift),
    .target(name: "SolarPerformanceCalc",
      dependencies: [
        "Config", "BlackBoxModel",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
    .testTarget(name: "MeteoTests",
      dependencies: ["DateGenerator", "SolarPosition", "Meteo"]),
    .testTarget(name: "SolarFieldModelTests",
      dependencies: ["SolarFieldModel"]),
    .testTarget(name: "BlackBoxModelTests",
      dependencies: ["Config", "Meteo", "SolarPosition", "BlackBoxModel"])
    ],
  swiftLanguageVersions: [.v5]
)

// FIXME: conditionalise these flags since SwiftPM 5.3 and earlier will crash
// for platforms they don't know about.
#if os(Windows)
let flags = ["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"]

if let BlackBoxModel = package.targets.first(where: { $0.name == "BlackBoxModel" }) {
  BlackBoxModel.linkerSettings = [
    .linkedLibrary("C:/Library/sqlite3/sqlite3.lib"), .unsafeFlags(flags)
  ]
}

if let SolarPerformance = package.targets.first(where: { $0.name == "SolarPerformanceCalc" }) {
  SolarPerformance.linkerSettings = [.linkedLibrary("User32"), .unsafeFlags(flags)]
}

if let SolarField = package.targets.first(where: { $0.name == "SolarFieldCalc" }) {
  SolarField.linkerSettings = [.linkedLibrary("User32"), .unsafeFlags(flags)]
}

if let Utility = package.targets.first(where: { $0.name == "Utility" }) {
  Utility.cxxSettings = [.define("_CRT_SECURE_NO_WARNINGS")]
  Utility.linkerSettings = [.linkedLibrary("Pathcch")]
}
#endif
