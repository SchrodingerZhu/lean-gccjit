#include "common.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT size_t lean_gcc_jit_result_get_code(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto funcname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_code(result, funcname);
  return reinterpret_cast<size_t>(addr);
}

extern "C" LEAN_EXPORT size_t lean_gcc_jit_result_get_global(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto gname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_global(result, gname);
  return reinterpret_cast<size_t>(addr);
}

} // namespace lean_gccjit