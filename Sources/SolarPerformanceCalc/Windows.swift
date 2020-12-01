#if os(Windows)
import Libc
import func WinSDK.MessageBoxW
import let WinSDK.MB_OK
import struct WinSDK.UINT

extension String {
  var LPCWSTR: [UInt16] {
    self.withCString(encodedAs: UTF16.self) { buffer in
      Array<UInt16>(unsafeUninitializedCapacity: self.utf16.count + 1) {
        wcscpy_s($0.baseAddress, $0.count, buffer)
        $1 = $0.count
      }
    }
  }
  func clipboard() {
    let size = utf16.count * MemoryLayout<UInt16>.size
    guard let hMem = GlobalAlloc(UINT(GHND), SIZE_T(size + 1))
    else { return }
    withCString(encodedAs: UTF16.self) {
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
}

func MessageBox(text: String, caption: String) {
  MessageBoxW(nil, text.LPCWSTR, caption.LPCWSTR, UINT(MB_OK))
}

func currentDirectoryPath() -> String {
  let dwLength: DWORD = GetCurrentDirectoryW(0, nil)
  var szDirectory: [WCHAR] = Array<WCHAR>(repeating: 0, count: Int(dwLength + 1))

  GetCurrentDirectoryW(dwLength, &szDirectory)
  return String(decodingCString: &szDirectory, as: UTF16.self)
}

func FileDialog() -> String? {
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
