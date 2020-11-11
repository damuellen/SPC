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
      dependencies: ["Libc"]),
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
      swiftSettings: swiftSettings),
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


// FIXME: conditionalise these flags since SwiftPM 5.3 and earlier will crash
// for platforms they don't know about.
#if os(Windows)

import CRT
import WinSDK

extension Array where Element == WCHAR {
  init(from string: String) {
    self = string.withCString(encodedAs: UTF16.self) { buffer in
      Array<WCHAR>(unsafeUninitializedCapacity: string.utf16.count + 1) {
        wcscpy_s($0.baseAddress, $0.count, buffer)
        $1 = $0.count
      }
    }
  }
}
extension String {
  var wide: [WCHAR] {
    return Array<WCHAR>(from: self)
  }
  init(wide: [WCHAR]) {
    self = wide.withUnsafeBufferPointer {
      String(decodingCString: $0.baseAddress!, as: UTF16.self)
    }
  }
}

func GetEnvironmentVariable(_ name: String)-> String? {
  let dwLength: DWORD = GetEnvironmentVariableW(name.wide, nil, 0)
  guard dwLength > 0 else { return nil }
  let buffer = Array<WCHAR>(unsafeUninitializedCapacity: Int(dwLength)) {
    let dwResult = GetEnvironmentVariableW(name.wide, $0.baseAddress, DWORD($0.count))
    $1 = Int(dwResult)
  }
  return String(wide: buffer)
}

if let BlackBoxModel = package.targets.first(where: { $0.name == "BlackBoxModel" }) {
  BlackBoxModel.linkerSettings = [
    .linkedLibrary(GetEnvironmentVariable("LIBSQLITE3")!),
    .unsafeFlags(["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"])
  ]
}

if let Run = package.targets.first(where: { $0.name == "Run" }) {
  Run.linkerSettings = [
    .linkedLibrary("User32"),
    .unsafeFlags(["-Xlinker", "/INCREMENTAL:NO", "-Xlinker", "/IGNORE:4217,4286"])
  ]
}

if let Utility = package.targets.first(where: { $0.name == "Utility" }) {
  Utility.cxxSettings = [.define("_CRT_SECURE_NO_WARNINGS")]
  Utility.linkerSettings = [.linkedLibrary("Pathcch")]
}
#endif
