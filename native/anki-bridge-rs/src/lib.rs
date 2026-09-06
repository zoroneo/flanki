//! C ABI bridge for the Anki Rust backend (rslib).
//!
//! Exposes 4 primitive C ABI functions matching the pattern used by AnkiDroid (JNI)
//! and Amgi (Swift), allowing Flutter via `dart:ffi` to invoke any Anki backend
//! method using serialized Protobuf buffers.

use std::os::raw::c_int;
use std::slice;

/// Handle representing an opaque pointer to the Anki Backend.
pub type AnkiBackendHandle = i64;

/// Initialize and create a new Anki backend instance.
///
/// # Safety
/// - `init_data`: Pointer to serialized `BackendInit` protobuf bytes (or null for defaults).
/// - `init_len`: Length of `init_data`.
/// - `out_ptr`: Pointer to writable `i64` memory to receive the backend instance pointer.
///
/// Returns 0 on success, -1 on failure.
#[no_mangle]
pub unsafe extern "C" fn anki_open_backend(
    _init_data: *const u8,
    _init_len: usize,
    out_ptr: *mut AnkiBackendHandle,
) -> c_int {
    if out_ptr.is_null() {
        return -1;
    }
    // Stub pointer address representing initialized backend instance
    // When linked with rslib: anki::backend::init_backend(bytes)
    let stub_handle: AnkiBackendHandle = 0x1000;
    unsafe { *out_ptr = stub_handle };
    0
}

/// Execute a backend RPC method via Protobuf payload.
///
/// # Safety
/// - `backend_ptr`: Valid pointer returned by `anki_open_backend`.
/// - `service`: Target Service ID (from anki_proto enum).
/// - `method`: Target Method ID (from anki_proto enum).
/// - `input_data`: Pointer to serialized request protobuf bytes.
/// - `input_len`: Byte length of `input_data`.
/// - `out_data`: Double pointer to receive newly allocated response bytes.
/// - `out_len`: Pointer to receive response byte length.
///
/// Returns:
///  0 = Success (out_data has response protobuf)
///  1 = Backend Error (out_data has error protobuf)
/// -1 = FFI / Memory Error
#[no_mangle]
pub unsafe extern "C" fn anki_run_method(
    backend_ptr: AnkiBackendHandle,
    _service: u32,
    _method: u32,
    _input_data: *const u8,
    _input_len: usize,
    out_data: *mut *mut u8,
    out_len: *mut usize,
) -> c_int {
    if backend_ptr == 0 || out_data.is_null() || out_len.is_null() {
        return -1;
    }
    // Stub response buffer
    let response = vec![0u8; 0];
    set_output(response, out_data, out_len);
    0
}

/// Free a response buffer allocated by `anki_run_method`.
///
/// # Safety
/// - `data`: Pointer to memory allocated in `anki_run_method`.
/// - `len`: Byte length of `data`.
#[no_mangle]
pub unsafe extern "C" fn anki_free_response(data: *mut u8, len: usize) {
    if !data.is_null() && len > 0 {
        let _ = unsafe { Vec::from_raw_parts(data, len, len) };
    }
}

/// Close and destroy the Anki backend instance.
///
/// # Safety
/// - `backend_ptr`: Pointer returned by `anki_open_backend`.
#[no_mangle]
pub unsafe extern "C" fn anki_close_backend(backend_ptr: AnkiBackendHandle) {
    if backend_ptr != 0 {
        // Drop backend instance
    }
}

// -- Memory Helper --
unsafe fn set_output(data: Vec<u8>, out_data: *mut *mut u8, out_len: *mut usize) {
    let len = data.len();
    if len > 0 {
        let mut boxed = data.into_boxed_slice();
        let ptr = boxed.as_mut_ptr();
        std::mem::forget(boxed);
        unsafe {
            *out_data = ptr;
            *out_len = len;
        }
    } else {
        unsafe {
            *out_data = std::ptr::null_mut();
            *out_len = 0;
        }
    }
}
