#if os(Windows)
import CRT
import WinSDK
import func WinSDK.MessageBoxW
import let WinSDK.MB_OK
import struct WinSDK.UINT

extension String {
  internal init(from utf16: [UInt16]) {
    self = utf16.withUnsafeBufferPointer {
      String(decodingCString: $0.baseAddress!, as: UTF16.self)
    }
  }
}

extension String {
  public var wide: [UInt16] {
    return Array<UInt16>(from: self)
  }
}

extension Array where Element == UInt16 {
  internal init(from string: String) {
    self = string.withCString(encodedAs: UTF16.self) { buffer in
      Array<UInt16>(unsafeUninitializedCapacity: string.utf16.count + 1) {
        wcscpy_s($0.baseAddress, $0.count, buffer)
        $1 = $0.count
      }
    }
  }
}

public func setClipboard(_ text: String) {
  let size = text.utf16.count * MemoryLayout<UInt16>.size
  guard let hMem = GlobalAlloc(UINT(GHND), SIZE_T(size + 1))
  else { return }
  text.withCString(encodedAs: UTF16.self) {
    let dst = GlobalLock(hMem)
    memcpy(dst, $0, size)
    GlobalUnlock(hMem)
  }
  if OpenClipboard(nil) {
    EmptyClipboard()
    SetClipboardData(UINT(CF_UNICODETEXT), hMem)
    CloseClipboard()
  }
}

public func MessageBox(text: String, caption: String) {
  MessageBoxW(nil, text.wide, caption.wide, UINT(MB_OK))
}

public func currentDirectoryPath() -> String {
  let dwLength: DWORD = GetCurrentDirectoryW(0, nil)
  var szDirectory: [WCHAR] = Array<WCHAR>(repeating: 0, count: Int(dwLength + 1))

  GetCurrentDirectoryW(dwLength, &szDirectory)
  return String(decodingCString: &szDirectory, as: UTF16.self)
}

public func FileDialog() -> String? {
  var strFile = "".utf8CString

  var ofn = OPENFILENAMEA()

  strFile.withUnsafeMutableBufferPointer() {
    ofn.lpstrFile = $0.baseAddress
    ofn.lpstrFile[0] = 0
  }

  ofn.nFilterIndex = 1
  ofn.nMaxFile = 240
  ofn.Flags = DWORD(OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST)
  ofn.lStructSize = UInt32(MemoryLayout<OPENFILENAMEA>.size)

  return GetOpenFileNameA(&ofn) ? String(cString: ofn.lpstrFile) : nil
}
#endif
