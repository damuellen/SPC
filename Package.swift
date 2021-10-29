// swift-tools-version:5.4
import PackageDescription

let c = [CSetting.unsafeFlags(["-ffast-math", "-O3", "-fomit-frame-pointer", "-funroll-loops"])]
let flags = ["-Ounchecked", "-enforce-exclusivity=unchecked"]
let posix = TargetDependencyCondition.when(platforms: [.linux, .macOS])
let win = BuildSettingCondition.when(platforms: [.windows])
let linker = LinkerSetting.unsafeFlags(["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"], win)
let swift: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .define("DEBUG", .when(configuration: .debug)),
]
var package = Package(
  name: "SPC",
  platforms: [.macOS(.v10_13), .iOS(.v12)],
  products: [
    .executable(name: "SolarPerformanceCalc", targets: ["SolarPerformanceCalc"]),
    .executable(name: "SolarFieldCalc", targets: ["SolarFieldCalc"]),
    .executable(name: "TransTES", targets: ["TransTES"]),
    .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
    .executable(name: "SunOl", targets: ["SunOl"]), 
 // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      .upToNextMinor(from: "0.5.0")
    ),
    .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master")),
    .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", .branch("main")),
    .package(
      name: "Swifter", url: "https://github.com/httpswift/swifter.git",
      .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
 // .package(url: "https://github.com/damuellen/Numerical.git", .branch("master")),
 // .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
 // .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
 // .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.1")
  ],
  targets: [
    .target(name: "Libc"),
    .target(
      name: "Helpers",
      dependencies: ["Libc", .product(name: "Numerics", package: "swift-numerics"),],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .target(
      name: "Physics",
      dependencies: ["Config", "Meteo", "Libc", "Helpers", "CIAPWSIF97",],
      swiftSettings: swift
    ), 
    .target(name: "Config", swiftSettings: swift),
    .target(name: "DateGenerator", swiftSettings: swift),
    .target(name: "CPikchr", cSettings: c), 
    .target(name: "CSPA", cSettings: c),
    .target(name: "CSOLPOS", cSettings: c), 
    .target(name: "CIAPWSIF97", cSettings: c),
    .target(
      name: "SolarPosition",
      dependencies: ["DateGenerator", "CSOLPOS", "CSPA"],
      swiftSettings: swift
    ),
    .target(
      name: "PinchPoint",
      dependencies: ["CPikchr", "Helpers", "Physics"],
      swiftSettings: swift
    ),
    .target(
      name: "BlackBoxModel",
      dependencies: [
        "Config", "Libc", "Meteo", "SolarPosition", "Helpers", "Physics",
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
      dependencies: ["Libc", "Helpers", "Physics"],
      swiftSettings: swift
    ), 
    .target(
      name: "SolarFieldModel",
      dependencies: ["Libc"],
      swiftSettings: swift
    ),
    .target(
      name: "Meteo",
      dependencies: ["DateGenerator", "SolarPosition"],
      swiftSettings: swift
    ),
    // .executableTarget(name: "Benchmarking",
    //   dependencies: ["Meteo", "Benchmark", "BlackBoxModel"],
    //   swiftSettings: swift),

    .executableTarget(
      name: "SolarFieldCalc",
      dependencies: [
        "SolarFieldModel", "CPikchr", "Helpers",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "SolarPerformanceCalc",
      dependencies: [
        "Config", "BlackBoxModel", "Helpers",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
      ],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "TransTES",
      dependencies: ["Helpers"],
      swiftSettings: swift,
      linkerSettings: [linker]
    ),
    .executableTarget(
      name: "SunOl",
      dependencies: [
         "Helpers", "Physics",
        .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
        .byName(name: "Swifter", condition: posix),
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
      dependencies: ["DateGenerator", "SolarPosition", "Meteo"]
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
