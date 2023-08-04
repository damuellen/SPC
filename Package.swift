// swift-tools-version:5.7
import PackageDescription
import class Foundation.ProcessInfo

let cSettings = [CSetting.unsafeFlags(["-ffast-math", "-O3", "-fomit-frame-pointer", "-funroll-loops"])]
let flags = ["-cross-module-optimization", "-Ounchecked", "-enforce-exclusivity=unchecked", "-remove-runtime-asserts", "-Xllvm", "-sil-cross-module-serialize-all"]

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(flags, .when(configuration: .release)),
  .unsafeFlags(["-enable-incremental-imports"], .when(configuration: .debug)),
  .define("DEBUG", .when(configuration: .debug)),
]

#if os(Linux) || os(iOS)
var platformProducts: [Product] = [
  // .library(name: "BlackBoxModel", type: .dynamic, targets: ["BlackBoxModel"]),
  // .library(name: "SolarPosition", type: .dynamic, targets: ["SolarPosition"]),
  // .library(name: "PinchPoint", type: .dynamic, targets: ["PinchPoint"]),
]
#else
var platformProducts: [Product] = []
#endif
#if !os(iOS)
platformProducts.append(contentsOf: [
  .executable(name: "SPC", targets: ["SolarPerformanceCalc"]),
  .executable(name: "PinchPointTool", targets: ["PinchPointTool"]),
  .executable(name: "Playground", targets: ["Playground"]),
])
#endif

let branch = (ProcessInfo.processInfo.environment["SPM"] != nil) ? "SPM" : "main"
let dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/damuellen/swift-argument-parser.git", branch: "main"),
  .package(url: "https://github.com/damuellen/Utilities.git", branch: "main"),
  .package(url: "https://github.com/damuellen/xlsxwriter.swift.git", branch: branch),
]

let platformTargets: [Target] = [
  .target(name: "DateExtensions", swiftSettings: swiftSettings), .target(name: "CPikchr", cSettings: cSettings),
  .target(name: "CSPA", cSettings: cSettings), .target(name: "CSOLPOS", cSettings: cSettings),
  .target(
    name: "SolarPosition",
    dependencies: ["Utilities", "DateExtensions", "CSOLPOS", "CSPA"],
    swiftSettings: swiftSettings
  ), 
  .target(name: "PinchPoint", dependencies: ["CPikchr", "Utilities"], swiftSettings: swiftSettings),
//.target(name: "ThermalStorage", dependencies: ["Utilities"], swiftSettings: swift),
  .target(
    name: "Meteo",
    dependencies: ["DateExtensions", "SolarPosition", "Utilities"],
    cSettings: [(.define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])))],
    swiftSettings: swiftSettings     
  ),
  .target(
    name: "BlackBoxModel",
    dependencies: [
      "Meteo", "SolarPosition", "Utilities",
    //.product(name: "SQLite", package: "SQLite.swift"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swiftSettings
  ),
  .executableTarget(
    name: "Playground",
    dependencies: [
      "Utilities", "DateExtensions",
      .product(name: "xlsxwriter", package: "xlsxwriter.swift")
    ],
    exclude: ["README.md"],
    swiftSettings: swiftSettings
  ),
  .executableTarget(
    name: "SolarPerformanceCalc",
    dependencies: [
      "BlackBoxModel", "Utilities",
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    swiftSettings: swiftSettings
  ),
  .executableTarget(
    name: "PinchPointTool",
    dependencies: [
      "PinchPoint", 
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
      .product(name: "xlsxwriter", package: "xlsxwriter.swift"),
    ],
    exclude: ["README.md"],
    swiftSettings: swiftSettings
  ),
  .testTarget(
    name: "MeteoTests",
    dependencies: ["Utilities", "DateExtensions", "SolarPosition", "Meteo"]
  ),
//.testTarget(name: "ThermalStorageTests", dependencies: ["ThermalStorage"]),
  .testTarget(name: "PinchPointTests", dependencies: ["PinchPoint"]),
  .testTarget(
    name: "BlackBoxModelTests",
    dependencies: ["Meteo", "SolarPosition", "BlackBoxModel"]
  ),
]

let package = Package(
  name: "SPC",
  platforms: [.macOS(.v13), .iOS(.v16)],
  products: platformProducts,
  dependencies: dependencies,
  targets: platformTargets,
  swiftLanguageVersions: [.v5]
)
