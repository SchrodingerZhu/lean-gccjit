#include "common.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_function(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, uint8_t kind,
    b_lean_obj_arg ret_type, b_lean_obj_arg name, b_lean_obj_arg params,
    uint8_t is_variadic, lean_object * /* w */
) {
  auto params_len = lean_array_size(params);
  if (params_len > INT_MAX) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("too many params"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto function_kind = static_cast<gcc_jit_function_kind>(kind);
  auto return_type = unwrap_pointer<gcc_jit_type>(ret_type);
  auto function_name = lean_string_cstr(name);
  auto num_params = static_cast<int>(params_len);
  auto variadic = static_cast<int>(is_variadic);
  auto result =
      with_allocation<gcc_jit_param *>(params_len, [=](gcc_jit_param **ptr) {
        for (size_t i = 0; i < params_len; i++) {
          ptr[i] =
              unwrap_pointer<gcc_jit_param>(lean_to_array(params)->m_data[i]);
        }
        return gcc_jit_context_new_function(context, location, function_kind,
                                            return_type, function_name,
                                            num_params, ptr, variadic);
      });
  return map_notnull(result, wrap_pointer<gcc_jit_function>,
                     "failed to create function");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_builtin_function(
    b_lean_obj_arg ctx, b_lean_obj_arg name, lean_object * /* w */
) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto function_name = lean_string_cstr(name);
  auto result = gcc_jit_context_get_builtin_function(context, function_name);
  return map_notnull(result, wrap_pointer<gcc_jit_function>,
                     "failed to get builtin function");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_as_object(
    b_lean_obj_arg fn, lean_object * /* w */
) {
  auto *fn_ = unwrap_pointer<gcc_jit_function>(fn);
  auto *obj = gcc_jit_function_as_object(fn_);
  return map_notnull(obj, wrap_pointer<gcc_jit_object>, "invalid function");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_get_param(
    b_lean_obj_arg fn, b_lean_obj_arg idx, lean_object * /* w */
) {
  if (!lean_is_scalar(idx)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("idx is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto *fn_ = unwrap_pointer<gcc_jit_function>(fn);
  auto index = lean_unbox(idx);
  if (index > INT_MAX) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("idx too large"));
    return lean_io_result_mk_error(error);
  }
  auto index_ = static_cast<int>(index);
  auto *param = gcc_jit_function_get_param(fn_, index_);
  return map_notnull(param, wrap_pointer<gcc_jit_param>, "invalid param");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_dump_to_dot(
    b_lean_obj_arg fn, b_lean_obj_arg path, lean_object * /* w */
) {
  auto *fn_ = unwrap_pointer<gcc_jit_function>(fn);
  auto *path_ = lean_string_cstr(path);
  gcc_jit_function_dump_to_dot(fn_, path_);
  return lean_io_result_mk_ok(lean_box(0));
}
} // namespace lean_gccjit