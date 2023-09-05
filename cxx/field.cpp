#include "common.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_field(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, b_lean_obj_arg type,
    b_lean_obj_arg name, lean_object * /* w */
) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto ty = unwrap_pointer<gcc_jit_type>(type);
  auto fieldname = lean_string_cstr(name);
  auto result = gcc_jit_context_new_field(context, location, ty, fieldname);
  return map_notnull(result, wrap_pointer<gcc_jit_field>,
                     "failed to create field");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_bitfield(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, b_lean_obj_arg type,
    b_lean_obj_arg width, b_lean_obj_arg name, lean_object * /* w */
) {
  if (!lean_is_scalar(width)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("width is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto ty = unwrap_pointer<gcc_jit_type>(type);
  auto field_width = lean_scalar_to_int(width);
  auto field_name = lean_string_cstr(name);
  auto result = gcc_jit_context_new_bitfield(context, location, ty, field_width,
                                             field_name);
  return map_notnull(result, wrap_pointer<gcc_jit_field>,
                     "failed to create field");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_field_as_object(
    b_lean_obj_arg loc, lean_object * /* w */
) {
  auto *field = unwrap_pointer<gcc_jit_field>(loc);
  auto *obj = gcc_jit_field_as_object(field);
  return map_notnull(obj, wrap_pointer<gcc_jit_object>, "invalid field");
}
} // namespace lean_gccjit