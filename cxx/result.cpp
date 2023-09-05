#include "common.h"
#include "lean/lean.h"
namespace lean_gccjit {

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_compile(b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto result = gcc_jit_context_compile(context);
  return map_notnull(result, wrap_pointer<gcc_jit_result>,
                     "failed to compile context");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_result_get_code(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto funcname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_code(result, funcname);
  return map_notnull(reinterpret_cast<size_t>(addr), lean_box_usize,
                     "failed to get code");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_result_get_global(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  auto gname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_global(result, gname);
  return map_notnull(reinterpret_cast<size_t>(addr), lean_box_usize,
                     "failed to get global");
}

} // namespace lean_gccjit