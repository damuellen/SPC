// swift-tools-version:5.0
import PackageDescription

let c: CSetting = .unsafeFlags(["-ffast-math", "-O3", "-fomit-frame-pointer", "-funroll-loops"])
var flags = ["-cross-module-optimization", "-Ounchecked", "-enforce-exclusivity=unchecked"]
let posix: TargetDependencyCondition = .when(platforms: [.linux, .macOS])
let swift: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .define("DEBUG", .when(configuration: .debug)),
]

let platformProducts: [Product] =  [
  .executable(name: "SPC", targets: ["SolarPerformanceCalc"]),
  .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
  .executable(name: "Playground", targets: ["Playground"]),
  .executable(name: "Optimizer", targets: ["Optimizer"]),
]

let dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/damuellen/swift-argument-parser.git", .branch("main")),
  .package(url: "https://github.com/damuellen/SQLite.swift.git", .branch("master")),
  .package(url: "https://github.com/damuellen/Utilities.git", .branch("main")),
  .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", .branch("main"))
  // .package(url: "https://github.com/damuellen/Swiftplot.git", .branch("master")),
  // .package(url: "https://github.com/damuellen/Numerical.git", .branch("master")),
  // .package(url: "https://github.com/google/swift-benchmark", .branch("main")),
  // .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
]

let platformTargets: [Target] = [
  .target(name: "Config", swiftSettings: swift),
  .target(name: "DateGenerator", swiftSettings: swift), .target(name: "CPikchr", cSettings: [c]),
  .target(name: "CSPA", cSettings: [c]), .target(name: "CSOLPOS", cSettings: [c]),
  .target(
    name: "SolarPosition",
    dependencies: ["Utilities", "DateGenerator", "CSOLPOS", "CSPA"],
    swiftSettings: swift
  ), .target(name: "PinchPoint", dependencies: ["CPikchr", "Utilities"], swiftSettings: swift),
  .target(name: "ThermalStorage", dependencies: ["Utilities"], swiftSettings: swift),
  .target(
    name: "Meteo",
    dependencies: ["DateGenerator", "SolarPosition", "Utilities"],
    swiftSettings: swift
  ),
  .target(
    name: "BlackBoxModel",
    dependencies: [
      "Config", "Meteo", "SolarPosition", "Utilities",
      .product(name: "SQLite", package: "SQLite.swift"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  // .executableTarget(name: "Benchmarking",
  //   dependencies: ["Meteo", "Benchmark", "BlackBoxModel"],
  //   swiftSettings: swift),
  .executableTarget(
    name: "Playground",
    dependencies: [
      "Utilities",
      .product(name: "xlsxwriter", package: "xlsxwriter.swift")
    ],
    swiftSettings: swift
  ),
  .executableTarget(
    name: "Optimizer",
    dependencies: [
      "Utilities", "SunOl",
      .product(name: "xlsxwriter", package: "xlsxwriter.swift")
    ],
    swiftSettings: swift
  ),
  .target(
    name: "SolarPerformanceCalc",
    dependencies: [
      "Config", "BlackBoxModel", "Utilities",
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swift
  ),
  .target(
    name: "SunOl",
    dependencies: [
      "Utilities", 
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    // .product(name: "SwiftPlot", package: "SwiftPlot")
    swiftSettings: swift
  ),
  .target(
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
    dependencies: ["Utilities", "DateGenerator", "SolarPosition", "Meteo"]
  ),
  // .testTarget(name: "SunOlTests", dependencies: ["SunOl"]),
  .testTarget(name: "ThermalStorageTests", dependencies: ["ThermalStorage"]),
  .testTarget(name: "PinchPointTests", dependencies: ["PinchPoint"]),
  .testTarget(
    name: "BlackBoxModelTests",
    dependencies: ["Config", "Meteo", "SolarPosition", "BlackBoxModel"]
  ),
]

let package = Package(
  name: "SPC",
  products: platformProducts,
  dependencies: dependencies,
  targets: platformTargets,
  swiftLanguageVersions: [.v5]
)
