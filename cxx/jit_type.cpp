#include "common.h"
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

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_compatible_types(
    b_lean_obj_arg type1, b_lean_obj_arg type2, lean_object * /* w */) {
  auto t1 = unwrap_pointer<gcc_jit_type>(type1);
  auto t2 = unwrap_pointer<gcc_jit_type>(type2);
  if (gcc_jit_compatible_types(t1, t2) != 0) {
    return lean_io_result_mk_ok(lean_box(1));
  } else {
    return lean_io_result_mk_ok(lean_box(0));
  }
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_type_get_size(b_lean_obj_arg type, lean_object * /* w */) {
  auto ty = unwrap_pointer<gcc_jit_type>(type);
  auto result = gcc_jit_type_get_size(ty);
  return map_condition(
      result, [](ssize_t x) { return x > 0; },
      [](ssize_t x) { return lean_box(static_cast<size_t>(x)); },
      "failed to get size");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_array_type(
    b_lean_obj_arg ctx, b_lean_obj_arg location, b_lean_obj_arg element_type,
    b_lean_obj_arg num_elements, lean_object * /* w */
) {
  if (!lean_is_scalar(num_elements)) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("num_elements is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto loc = unwrap_pointer<gcc_jit_location>(location);
  auto element = unwrap_pointer<gcc_jit_type>(element_type);
  auto elements = lean_scalar_to_int(num_elements);
  auto result = gcc_jit_context_new_array_type(context, loc, element, elements);
  return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid array type");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_union_type(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, b_lean_obj_arg name,
    b_lean_obj_arg fields, lean_object * /* w */
) {
  auto array_len = lean_array_size(fields);
  if (array_len > INT_MAX) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("too many fields"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto union_name = lean_string_cstr(name);
  auto num_fields = static_cast<int>(array_len);
  gcc_jit_type *result =
      with_allocation<gcc_jit_field *>(array_len, [=](gcc_jit_field **ptr) {
        for (size_t i = 0; i < array_len; i++) {
          ptr[i] =
              unwrap_pointer<gcc_jit_field>(lean_to_array(fields)->m_data[i]);
        }
        return gcc_jit_context_new_union_type(context, location, union_name,
                                              num_fields, ptr);
      });
  return map_notnull(result, wrap_pointer<gcc_jit_type>,
                     "failed to create union");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_function_ptr_type(
    b_lean_obj_arg ctx, b_lean_obj_arg loc, b_lean_obj_arg ret_ty,
    b_lean_obj_arg params, uint8_t is_variadic, lean_object * /* w */
) {
  auto array_len = lean_array_size(params);
  if (array_len > INT_MAX) {
    auto error = lean_mk_io_error_invalid_argument(
        EINVAL, lean_mk_string("too many params"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto location = unwrap_pointer<gcc_jit_location>(loc);
  auto return_type = unwrap_pointer<gcc_jit_type>(ret_ty);
  auto num_params = static_cast<int>(array_len);
  auto variadic = static_cast<int>(is_variadic);
  gcc_jit_type *result =
      with_allocation<gcc_jit_type *>(array_len, [=](gcc_jit_type **ptr) {
        for (size_t i = 0; i < array_len; i++) {
          ptr[i] =
              unwrap_pointer<gcc_jit_type>(lean_to_array(params)->m_data[i]);
        }
        return gcc_jit_context_new_function_ptr_type(
            context, location, return_type, num_params, ptr, variadic);
      });
  return map_notnull(result, wrap_pointer<gcc_jit_type>,
                     "failed to create function ptr type");
}

} // namespace lean_gccjit