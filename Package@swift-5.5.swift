// swift-tools-version:5.5
import PackageDescription
import class Foundation.ProcessInfo

let c: [CSetting] = [.unsafeFlags(["-ffast-math", "-O3", "-fomit-frame-pointer", "-funroll-loops"])]
var flags = ["-cross-module-optimization", "-Ounchecked", "-enforce-exclusivity=unchecked", "-remove-runtime-asserts"]

#if os(Windows)
//flags += ["-Xfrontend", "-entry-point-function-name", "-Xfrontend", "wWinMain"]
#endif
let posix: TargetDependencyCondition = .when(platforms: [.linux, .macOS])
let swift: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .unsafeFlags(["-enable-incremental-imports"], .when(configuration: .debug)),
  .define("DEBUG", .when(configuration: .debug)),
]

#if os(Linux) || os(iOS)
var platformProducts: [Product] = [
  // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
  // .library(name: "SolarPosition", type: .dynamic, targets: ["SolarPosition"]),
  // .library(name: "PinchPoint", type: .dynamic, targets: ["PinchPoint"]),
  // .library(name: "SunOl", type: .dynamic, targets: ["SunOl"]),
]
#else
var platformProducts: [Product] = []
#endif
#if !os(iOS)
platformProducts.append(contentsOf: [
  .executable(name: "SPC", targets: ["SolarPerformanceCalc"]),
  .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
  .executable(name: "Playground", targets: ["Playground"]),
  .executable(name: "Optimizer", targets: ["Optimizer"]),
])
#endif

let branch = (ProcessInfo.processInfo.environment["SPM"] != nil) ? "SPM" : "main"
let dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/damuellen/swift-argument-parser.git", branch: "main"),
  .package(url: "https://github.com/damuellen/Utilities.git", branch: "main"),
  .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", branch: branch),
]

let platformTargets: [Target] = [
  .target(name: "DateExtensions", swiftSettings: swift), .target(name: "CPikchr", cSettings: c),
  .target(name: "CSPA", cSettings: c), .target(name: "CSOLPOS", cSettings: c),
  .target(
    name: "SolarPosition",
    dependencies: ["Utilities", "DateExtensions", "CSOLPOS", "CSPA"],
    swiftSettings: swift
  ), .target(name: "PinchPoint", dependencies: ["CPikchr", "Utilities"], swiftSettings: swift),
  .target(name: "ThermalStorage", dependencies: ["Utilities"], swiftSettings: swift),
  .target(
    name: "Meteo",
    dependencies: ["DateExtensions", "SolarPosition", "Utilities"],
    cSettings: [(.define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])))],
    swiftSettings: swift     
  ),
  .target(
    name: "BlackBoxModel",
    dependencies: [
      "Meteo", "SolarPosition", "Utilities",
      // .product(name: "SQLite", package: "SQLite.swift"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  .executableTarget(
    name: "Playground",
    dependencies: [
      "Utilities", "DateExtensions",
      .product(name: "xlsxwriter", package: "xlsxwriter.swift")
    ],
    swiftSettings: swift
  ),
  .executableTarget(
    name: "Optimizer",
    dependencies: [
      "Utilities", "SunOl",
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift")
    ],
    swiftSettings: swift
  ),
  .executableTarget(
    name: "SolarPerformanceCalc",
    dependencies: [
      "BlackBoxModel", "Utilities",
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  .target(
    name: "SunOl",
    dependencies: [
      "Utilities", 
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  .executableTarget(
    name: "PinchPointTool",
    dependencies: [
      "PinchPoint", 
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  .testTarget(
    name: "MeteoTests",
    dependencies: ["Utilities", "DateExtensions", "SolarPosition", "Meteo"]
  ),
  .testTarget(name: "SunOlTests", dependencies: ["SunOl"]),
  .testTarget(name: "ThermalStorageTests", dependencies: ["ThermalStorage"]),
  .testTarget(name: "PinchPointTests", dependencies: ["PinchPoint"]),
  .testTarget(
    name: "BlackBoxModelTests",
    dependencies: ["Meteo", "SolarPosition", "BlackBoxModel"]
  ),
]

let package = Package(
  name: "SPC",
  platforms: [.macOS(.v12)],
  products: platformProducts,
  dependencies: dependencies,
  targets: platformTargets,
  swiftLanguageVersions: [.v5]
)
