#include "common.h"
#include "lean/lean.h"
namespace lean_gccjit {

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_compile(b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto result = wrap_pointer(gcc_jit_context_compile(context));
  return lean_io_result_mk_ok(result);
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_result_get_code(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto funcname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_code(result, funcname);
  return lean_io_result_mk_ok(lean_box_usize(reinterpret_cast<size_t>(addr)));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_result_get_global(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto gname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_global(result, gname);
  return lean_io_result_mk_ok(lean_box_usize(reinterpret_cast<size_t>(addr)));
}

} // namespace lean_gccjit