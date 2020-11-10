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
}

func MessageBox(text: String, caption: String) {
  MessageBoxW(nil, text.LPCWSTR, caption.LPCWSTR, UINT(MB_OK))
}

#endif
