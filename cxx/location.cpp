#include "common.h"
#include "lean/lean.h"
namespace lean_gccjit {

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_location(
    b_lean_obj_arg ctx, b_lean_obj_arg filename, b_lean_obj_arg line,
    b_lean_obj_arg column, lean_object * /* w */) {
  if (!lean_is_scalar(line)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("line is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  if (!lean_is_scalar(column)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("column is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto *context = unwrap_pointer<gcc_jit_context>(ctx);
  auto *fname = lean_string_cstr(filename);
  auto l = lean_scalar_to_int(line);
  auto c = lean_scalar_to_int(column);
  auto *loc = gcc_jit_context_new_location(context, fname, l, c);
  auto *wrapped = wrap_pointer(loc);
  return lean_io_result_mk_ok(wrapped);
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_location_as_object(
    b_lean_obj_arg loc, lean_object * /* w */
) {
  auto *location = unwrap_pointer<gcc_jit_location>(loc);
  auto *obj = gcc_jit_location_as_object(location);
  auto *wrapped = wrap_pointer(obj);
  return lean_io_result_mk_ok(wrapped);
}

} // namespace lean_gccjit