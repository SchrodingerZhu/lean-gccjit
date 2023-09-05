#include "common.h"
namespace lean_gccjit {

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_acquire(lean_object * /* w */) {
  auto ctx = wrap_pointer(gcc_jit_context_acquire());
  return lean_io_result_mk_ok(ctx);
};

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_release(lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  gcc_jit_context_release(context);
  lean_dec(ctx);
  return lean_io_result_mk_ok(lean_box(0));
};

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_str_option(
    b_lean_obj_arg ctx, b_lean_obj_arg opt, b_lean_obj_arg value,
    lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto option = static_cast<gcc_jit_str_option>(lean_unbox(opt));
  if (option >= GCC_JIT_NUM_STR_OPTIONS) {
    auto error = lean_mk_io_error_invalid_argument(
        2, lean_mk_string("invalid StrOption"));
    return lean_io_result_mk_error(error);
  }
  auto val = lean_string_cstr(value);
  gcc_jit_context_set_str_option(context, option, val);
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_int_option(
    b_lean_obj_arg ctx, b_lean_obj_arg opt, b_lean_obj_arg value,
    lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto option = static_cast<gcc_jit_int_option>(lean_unbox(opt));
  if (option >= GCC_JIT_NUM_INT_OPTIONS) {
    auto error = lean_mk_io_error_invalid_argument(
        2, lean_mk_string("invalid IntOption"));
    return lean_io_result_mk_error(error);
  }
  if (!lean_is_scalar(value)) {
    auto error = lean_mk_io_error_invalid_argument(
        2, lean_mk_string("value is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto val = lean_scalar_to_int(value);
  gcc_jit_context_set_int_option(context, option, val);
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_bool_option(
    b_lean_obj_arg ctx, uint8_t opt, uint8_t value, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto option = static_cast<gcc_jit_bool_option>(opt);
  if (option >= GCC_JIT_NUM_BOOL_OPTIONS) {
    auto error = lean_mk_io_error_invalid_argument(
        2, lean_mk_string("invalid BoolOption"));
    return lean_io_result_mk_error(error);
  }
  gcc_jit_context_set_bool_option(context, option, static_cast<int>(value));
  return lean_io_result_mk_ok(lean_box(0));
}

#define LEAN_GCC_JIT_SEPARATE_BOOL_OPTION(NAME)                                \
  extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_bool_##NAME(    \
      b_lean_obj_arg ctx, uint8_t value, lean_object * /* w */) {              \
    auto context = unwrap_pointer<gcc_jit_context>(ctx);                       \
    gcc_jit_context_set_bool_##NAME(context, static_cast<int>(value));         \
    return lean_io_result_mk_ok(lean_box(0));                                  \
  }

LEAN_GCC_JIT_SEPARATE_BOOL_OPTION(allow_unreachable_blocks);
LEAN_GCC_JIT_SEPARATE_BOOL_OPTION(print_errors_to_stderr);
LEAN_GCC_JIT_SEPARATE_BOOL_OPTION(use_external_driver);

#define LEAN_GCC_JIT_ADD_STRING_OPTION(NAME)                                   \
  extern "C" LEAN_EXPORT lean_obj_res                                          \
      lean_gcc_jit_context_add_##NAME##_option(                                \
          b_lean_obj_arg ctx, b_lean_obj_arg value, lean_object * /* w */) {   \
    auto context = unwrap_pointer<gcc_jit_context>(ctx);                       \
    auto val = lean_string_cstr(value);                                        \
    gcc_jit_context_add_##NAME##_option(context, val);                         \
    return lean_io_result_mk_ok(lean_box(0));                                  \
  }

LEAN_GCC_JIT_ADD_STRING_OPTION(command_line);
LEAN_GCC_JIT_ADD_STRING_OPTION(driver);

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_compile(b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto result = wrap_pointer(gcc_jit_context_compile(context));
  return lean_io_result_mk_ok(result);
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_result_release(lean_obj_arg res, lean_object * /* w */) {
  auto result = unwrap_pointer<gcc_jit_result>(res);
  gcc_jit_result_release(result);
  lean_dec(res);
  return lean_io_result_mk_ok(lean_box(0));
};

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_compile_to_file(
    b_lean_obj_arg ctx, uint8_t output_kind, b_lean_obj_arg output_path, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto kind = static_cast<gcc_jit_output_kind>(output_kind);
  auto path = lean_string_cstr(output_path);
  gcc_jit_context_compile_to_file(context, kind, path);
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_dump_to_file(
    b_lean_obj_arg ctx, b_lean_obj_arg output_path, uint8_t update_locations, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto path = lean_string_cstr(output_path);
  gcc_jit_context_dump_to_file(context, path,
                               static_cast<int>(update_locations));
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_logfile(
    b_lean_obj_arg ctx, b_lean_obj_arg handle, b_lean_obj_arg flags,
    b_lean_obj_arg verbosity, lean_object * /* w */) {
  if (!lean_is_scalar(flags)) {
    auto error = lean_mk_io_error_invalid_argument(
        2, lean_mk_string("value is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  if (!lean_is_scalar(verbosity)) {
    auto error = lean_mk_io_error_invalid_argument(
        3, lean_mk_string("verbosity is not a scalar"));
    return lean_io_result_mk_error(error);
  }
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto f = lean_scalar_to_int(flags);
  auto v = lean_scalar_to_int(verbosity);
  auto h = static_cast<FILE *>(lean_get_external_data(handle));
  gcc_jit_context_set_logfile(context, h, f, v);
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_first_error(
    b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto error = gcc_jit_context_get_first_error(context);
  return lean_option_string(error);
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_get_last_error(b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = unwrap_pointer<gcc_jit_context>(ctx);
  auto error = gcc_jit_context_get_last_error(context);
  return lean_option_string(error);
}
} // namespace lean_gccjit