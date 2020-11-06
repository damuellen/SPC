#if canImport(Glibc)
@_exported import Glibc
#elseif os(Windows)
@_exported import CRT
@_exported import WinSDK
#else
@_exported import Darwin.C
#endif
