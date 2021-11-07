#if canImport(Glibc)
@_exported import Glibc
#elseif os(Windows)
@_exported import CRT
#else
@_exported import Darwin.C
#endif
