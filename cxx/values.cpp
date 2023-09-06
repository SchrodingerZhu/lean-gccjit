#include "common.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_global(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, uint8_t kind, b_lean_obj_arg ty,
    b_lean_obj_arg name, lean_object * /* w */
) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto kind_ = static_cast<gcc_jit_global_kind>(kind);
  auto type = unwrap_pointer<gcc_jit_type>(ty);
  auto global_name = lean_string_cstr(name);
  auto result =
      gcc_jit_context_new_global(context, location, kind_, type, global_name);
  return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "invalid global");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_struct_constructor(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, b_lean_obj_arg ty,
    b_lean_obj_arg fields,               /* Option of Array Field */
    b_lean_obj_arg values, lean_object * /* w */
) {                                      /* TODO */
}
} // namespace lean_gccjit