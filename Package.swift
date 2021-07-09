// swift-tools-version:5.2
import PackageDescription
let c = [CSetting.unsafeFlags(["-ffast-math", "-O3",  "-fomit-frame-pointer", "-funroll-loops"])]
let flags = ["-cross-module-optimization", "-Ounchecked", "-enforce-exclusivity=unchecked", "-DRELEASE"]
let swift: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .define("DEBUG", .when(configuration: .debug))
]
let package = Package(
  name: "SPC",
  platforms: [
    .macOS(.v10_13), .iOS(.v12),
  ],
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["SolarPerformanceCalc"]),
    .executable(name: "SolarFieldCalc", targets: ["SolarFieldCalc"]),
    .executable(name: "TransTES", targets: ["TransTES"]),
    .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
    // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
    ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.4.0")),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master")),
    .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", .branch("main")),
    .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.0")
    // .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.1")
    ],
  targets: [
    .target(name: "Libc"),
    .target(name: "Helpers", dependencies: ["Libc"], swiftSettings: swift),
    .target(name: "PhysicalQuantities",
      dependencies: ["Config", "Meteo", "Libc", "Helpers"],
      swiftSettings: swift),
    .target(name: "TransTES",
      dependencies: ["Helpers", "BlackBoxModel"],
      swiftSettings: swift),
    .target(name: "SunOl",
      dependencies: ["Helpers", "BlackBoxModel", "PhysicalQuantities"],
      swiftSettings: swift),
    .target(name: "PinchPoint",
      dependencies: ["CPikchr", "CIAPWSIF97", "Helpers", "PhysicalQuantities"],
      swiftSettings: swift),
    .target(name: "PinchPointTool",
      dependencies: ["PinchPoint",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
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
      dependencies: ["Config", "Libc", "Meteo", "SolarPosition", "Helpers", "PhysicalQuantities",
        // .product(name: "Yams", package: "Yams"),
        .product(name: "SQLite", package: "SQLite.swift"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
    .target(name: "ThermalStorage",
      dependencies: ["Libc", "Helpers", "PhysicalQuantities"],
      swiftSettings: swift),
     .target(name: "SolarFieldModel",
      dependencies: ["Libc"],
      swiftSettings: swift),
    .target(name: "SolarFieldCalc",
      dependencies: ["SolarFieldModel", "CPikchr", "Helpers",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
    .target(name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"],
      swiftSettings: swift),
    .target(name: "SolarPerformanceCalc",
      dependencies: ["Config", "BlackBoxModel", "Helpers",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift")],
      swiftSettings: swift),
    .target(name: "Benchmarking",
      dependencies: ["Meteo", "Benchmark", "BlackBoxModel"],
      swiftSettings: swift),
    .testTarget(name: "MeteoTests",
      dependencies: ["DateGenerator", "SolarPosition", "Meteo"]),
    .testTarget(name: "ThermalStorageTests",
      dependencies: ["ThermalStorage"]),
    .testTarget(name: "PinchPointTests",
      dependencies: ["PinchPoint"]),
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
let linker = ["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"]

if let BlackBoxModel = package.targets.first(where: { $0.name == "BlackBoxModel" }) {
  BlackBoxModel.linkerSettings = [.linkedLibrary("sqlite3.lib"), .unsafeFlags(linker)]
}

if let Helpers = package.targets.first(where: { $0.name == "Helpers" }) {
  Helpers.linkerSettings = [.linkedLibrary("User32"), .unsafeFlags(flags)]
}
#endif
