import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

typedef AnkiOpenBackendNative = Int32 Function(
  Pointer<Uint8> initData,
  IntPtr initLen,
  Pointer<Int64> outPtr,
);
typedef AnkiOpenBackendDart = int Function(
  Pointer<Uint8> initData,
  int initLen,
  Pointer<Int64> outPtr,
);

typedef AnkiRunMethodNative = Int32 Function(
  Int64 backendPtr,
  Uint32 service,
  Uint32 method,
  Pointer<Uint8> inputData,
  IntPtr inputLen,
  Pointer<Pointer<Uint8>> outData,
  Pointer<IntPtr> outLen,
);
typedef AnkiRunMethodDart = int Function(
  int backendPtr,
  int service,
  int method,
  Pointer<Uint8> inputData,
  int inputLen,
  Pointer<Pointer<Uint8>> outData,
  Pointer<IntPtr> outLen,
);

typedef AnkiFreeResponseNative = Void Function(Pointer<Uint8> data, IntPtr len);
typedef AnkiFreeResponseDart = void Function(Pointer<Uint8> data, int len);

typedef AnkiCloseBackendNative = Void Function(Int64 backendPtr);
typedef AnkiCloseBackendDart = void Function(int backendPtr);

/// FFI Bridge communicating with `anki-bridge-rs` (Anki rslib C ABI).
class AnkiBridge {
  final DynamicLibrary _dylib;
  late final AnkiOpenBackendDart _openBackend;
  late final AnkiRunMethodDart _runMethod;
  late final AnkiFreeResponseDart _freeResponse;
  late final AnkiCloseBackendDart _closeBackend;

  int _backendHandle = 0;

  static String get _defaultLibraryName {
    if (Platform.isWindows) return 'anki_bridge.dll';
    if (Platform.isMacOS || Platform.isIOS) return 'libanki_bridge.dylib';
    return 'libanki_bridge.so';
  }

  static bool? _cachedIsAvailable;

  /// Safely checks whether the native `anki_bridge` dynamic library is present and loadable.
  static bool get isAvailable {
    if (_cachedIsAvailable != null) return _cachedIsAvailable!;
    try {
      final dylib = DynamicLibrary.open(_defaultLibraryName);
      dylib.lookup<NativeFunction<AnkiOpenBackendNative>>('anki_open_backend');
      _cachedIsAvailable = true;
    } catch (_) {
      _cachedIsAvailable = false;
    }
    return _cachedIsAvailable!;
  }

  /// Attempts to load and create an [AnkiBridge] instance. Returns null if library is not available.
  static AnkiBridge? tryCreate({String? libraryPath}) {
    try {
      final dylib = libraryPath != null
          ? DynamicLibrary.open(libraryPath)
          : DynamicLibrary.open(_defaultLibraryName);
      return AnkiBridge(dylib);
    } catch (_) {
      return null;
    }
  }

  AnkiBridge(this._dylib) {
    _openBackend = _dylib
        .lookup<NativeFunction<AnkiOpenBackendNative>>('anki_open_backend')
        .asFunction();
    _runMethod = _dylib
        .lookup<NativeFunction<AnkiRunMethodNative>>('anki_run_method')
        .asFunction();
    _freeResponse = _dylib
        .lookup<NativeFunction<AnkiFreeResponseNative>>('anki_free_response')
        .asFunction();
    _closeBackend = _dylib
        .lookup<NativeFunction<AnkiCloseBackendNative>>('anki_close_backend')
        .asFunction();
  }

  bool get isInitialized => _backendHandle != 0;

  /// Open and initialize the Anki rslib backend.
  bool initialize({Uint8List? initData}) {
    final outPtr = calloc<Int64>();
    try {
      Pointer<Uint8> initBuffer = nullptr;
      int initLen = 0;
      if (initData != null && initData.isNotEmpty) {
        initBuffer = calloc<Uint8>(initData.length);
        initBuffer.asTypedList(initData.length).setAll(0, initData);
        initLen = initData.length;
      }

      final result = _openBackend(initBuffer, initLen, outPtr);
      if (initBuffer != nullptr) {
        calloc.free(initBuffer);
      }

      if (result == 0) {
        _backendHandle = outPtr.value;
        return true;
      }
      return false;
    } finally {
      calloc.free(outPtr);
    }
  }

  /// Run a protobuf RPC method against the Anki backend.
  Uint8List? runMethod(int service, int method, Uint8List inputBytes) {
    if (!isInitialized) return null;

    final inputPtr = calloc<Uint8>(inputBytes.length);
    inputPtr.asTypedList(inputBytes.length).setAll(0, inputBytes);

    final outDataPtr = calloc<Pointer<Uint8>>();
    final outLenPtr = calloc<IntPtr>();

    try {
      final code = _runMethod(
        _backendHandle,
        service,
        method,
        inputPtr,
        inputBytes.length,
        outDataPtr,
        outLenPtr,
      );

      if (code == 0 && outDataPtr.value != nullptr && outLenPtr.value > 0) {
        final respBytes = outDataPtr.value.asTypedList(outLenPtr.value);
        final copy = Uint8List.fromList(respBytes);
        _freeResponse(outDataPtr.value, outLenPtr.value);
        return copy;
      }
      return null;
    } finally {
      calloc.free(inputPtr);
      calloc.free(outDataPtr);
      calloc.free(outLenPtr);
    }
  }

  /// Dispose and close backend.
  void dispose() {
    if (isInitialized) {
      _closeBackend(_backendHandle);
      _backendHandle = 0;
    }
  }
}
