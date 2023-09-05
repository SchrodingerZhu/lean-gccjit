#include "common.h"
#include "lean/lean.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_as_object(
    b_lean_obj_arg loc, lean_object * /* w */
) {
  auto *location = unwrap_pointer<gcc_jit_type>(loc);
  auto *obj = gcc_jit_type_as_object(location);
  return map_notnull(obj, wrap_pointer<gcc_jit_object>, "invalid location");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_type(
    b_lean_obj_arg ctx, uint8_t type_, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto type = static_cast<gcc_jit_types>(type_);
  auto result = gcc_jit_context_get_type(context, type);
  return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");
}
extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_get_int_type(b_lean_obj_arg ctx, b_lean_obj_arg num_bytes,
                                  uint8_t is_signed, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  if (!lean_is_scalar(num_bytes)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("num_bytes is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto bytes = lean_scalar_to_int(num_bytes);
  auto result =
      gcc_jit_context_get_int_type(context, bytes, static_cast<int>(is_signed));
  return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");
}
#define LEAN_GCC_JIT_TYPE_TO_TYPE(NAME)                                        \
  extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_##NAME(            \
      b_lean_obj_arg type, lean_object * /* w */) {                            \
    auto ty = unwrap_pointer<gcc_jit_type>(type);                              \
    auto result = gcc_jit_type_get_##NAME(ty);                                 \
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");    \
  }

LEAN_GCC_JIT_TYPE_TO_TYPE(pointer);
LEAN_GCC_JIT_TYPE_TO_TYPE(const);
LEAN_GCC_JIT_TYPE_TO_TYPE(volatile);

} // namespace lean_gccjit