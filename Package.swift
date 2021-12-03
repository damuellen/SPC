// swift-tools-version:5.4
import PackageDescription

let c = [CSetting.unsafeFlags(["-ffast-math", "-O3", "-fomit-frame-pointer", "-funroll-loops"])]
let flags = ["-cross-module-optimization", "-Ounchecked", "-enforce-exclusivity=unchecked"]
let posix = TargetDependencyCondition.when(platforms: [.linux, .macOS])
let win = BuildSettingCondition.when(platforms: [.windows])
let linker = LinkerSetting.unsafeFlags(["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"], win)
let swift: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .define("DEBUG", .when(configuration: .debug)),
]
var package = Package(
  name: "SPC",
  platforms: [.macOS(.v10_15), .iOS(.v14)],
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["SolarPerformanceCalc"]),
    .executable(name: "SolarFieldCalc", targets: ["SolarFieldCalc"]),
    .executable(name: "TransTES", targets: ["TransTES"]),
    .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
    .executable(name: "SunOl", targets: ["SunOl"]), 
    .executable(name: "Playground", targets: ["Playground"]), 
 // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      .upToNextMinor(from: "0.5.0")
    ),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master")),
    .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", .branch("main")),
    .package(url: "https://github.com/damuellen/Utilities.git", .branch("main")),
 // .package(
 //   name: "Swifter", url: "https://github.com/httpswift/swifter.git",
 //   .upToNextMajor(from: "1.5.0"))
 // .package(url: "https://github.com/damuellen/Numerical.git", .branch("master")),
 // .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
 // .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
 // .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.1")
  ],
  targets: [
    .target(name: "Config", swiftSettings: swift),
    .target(name: "DateGenerator", swiftSettings: swift),
    .target(name: "CPikchr", cSettings: c), 
    .target(name: "CSPA", cSettings: c),
    .target(name: "CSOLPOS", cSettings: c), 
    .target(
      name: "SolarPosition",
      dependencies: ["Utilities", "DateGenerator", "CSOLPOS", "CSPA"],
      swiftSettings: swift
    ),
    .target(
      name: "PinchPoint",
      dependencies: ["CPikchr", "Utilities"],
      swiftSettings: swift
    ),
    .target(
      name: "BlackBoxModel",
      dependencies: [
        "Config", "Meteo", "SolarPosition", "Utilities",
        // .product(name: "Yams", package: "Yams"),
        .product(name: "SQLite", package: "SQLite.swift"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [
        .linkedLibrary("sqlite3.lib", win), linker
      ]
    ),
    .target(
      name: "ThermalStorage",
      dependencies: ["Utilities"],
      swiftSettings: swift
    ), 
    .target(
      name: "SolarFieldModel",
      dependencies: ["Utilities"],
      swiftSettings: swift
    ),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition", "Utilities"],
      swiftSettings: swift
    ),
    // .executableTarget(name: "Benchmarking",
    //   dependencies: ["Meteo", "Benchmark", "BlackBoxModel"],
    //   swiftSettings: swift),
    .executableTarget(name: "Playground",
        dependencies: ["Utilities"], swiftSettings: swift, linkerSettings: [linker]),
    .executableTarget(
      name: "SolarFieldCalc",
      dependencies: [
        "SolarFieldModel", "CPikchr", "Utilities",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "SolarPerformanceCalc",
      dependencies: [
        "Config", "BlackBoxModel", "Utilities",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "TransTES",
      dependencies: ["Utilities"],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "SunOl",
      dependencies: [
         "Utilities",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "PinchPointTool",
      dependencies: [
        "PinchPoint",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    // MARK: Tests
    .testTarget(
      name: "MeteoTests",
      dependencies: ["Utilities", "DateGenerator", "SolarPosition", "Meteo"]
    ), 
    // .testTarget(name: "SunOlTests", dependencies: ["SunOl"]),
    .testTarget(name: "ThermalStorageTests", dependencies: ["ThermalStorage"]),
    .testTarget(name: "PinchPointTests", dependencies: ["PinchPoint"]),
    .testTarget(name: "SolarFieldModelTests", dependencies: ["SolarFieldModel"]),
    .testTarget(
      name: "BlackBoxModelTests",
      dependencies: ["Config", "Meteo", "SolarPosition", "BlackBoxModel"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
