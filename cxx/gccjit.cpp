#include <cstdint>
#include <cstdio>
#include <lean/lean.h>
#include <libgccjit.h>
#include <stdint.h>
namespace lean_gccjit {

static void empty_foreach(void *, b_lean_obj_arg) {}

#define LEAN_GCC_JIT_DELCARE_EXTERNAL_CLASS(TYPE, RELEASE)                     \
  static void lean_##TYPE##_finalize(void *value) { RELEASE }                  \
  constexpr static lean_external_class TYPE##_class{                           \
      .m_finalize = lean_##TYPE##_finalize,                                    \
      .m_foreach = empty_foreach,                                              \
  };                                                                           \
  static inline TYPE *get_##TYPE(b_lean_obj_res obj) {                         \
    return static_cast<TYPE *>(lean_get_external_data(obj));                   \
  }                                                                            \
  static inline lean_obj_res create_##TYPE(TYPE *value) {                      \
    return lean_alloc_external(                                                \
        const_cast<lean_external_class *>(&TYPE##_class), value);              \
  }

#define LEAN_GCC_JIT_DELCARE_EXTERNAL_CLASS_WITH_RELEASE(TYPE)                 \
  LEAN_GCC_JIT_DELCARE_EXTERNAL_CLASS(                                         \
      TYPE, TYPE##_release(static_cast<TYPE *>(value));)

LEAN_GCC_JIT_DELCARE_EXTERNAL_CLASS_WITH_RELEASE(gcc_jit_context);
LEAN_GCC_JIT_DELCARE_EXTERNAL_CLASS_WITH_RELEASE(gcc_jit_result);

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_acquire(lean_object * /* w */) {
  auto ctx = create_gcc_jit_context(gcc_jit_context_acquire());
  return lean_io_result_mk_ok(ctx);
};

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_str_option(
    b_lean_obj_arg ctx, b_lean_obj_arg opt, b_lean_obj_arg value,
    lean_object * /* w */) {
  auto context = get_gcc_jit_context(ctx);
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
  auto context = get_gcc_jit_context(ctx);
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
  auto context = get_gcc_jit_context(ctx);
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
    auto context = get_gcc_jit_context(ctx);                                   \
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
    auto context = get_gcc_jit_context(ctx);                                   \
    auto val = lean_string_cstr(value);                                        \
    gcc_jit_context_add_##NAME##_option(context, val);                         \
    return lean_io_result_mk_ok(lean_box(0));                                  \
  }

LEAN_GCC_JIT_ADD_STRING_OPTION(command_line);
LEAN_GCC_JIT_ADD_STRING_OPTION(driver);

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_compile(b_lean_obj_arg ctx) {
  auto context = get_gcc_jit_context(ctx);
  auto result = create_gcc_jit_result(gcc_jit_context_compile(context));
  return lean_io_result_mk_ok(result);
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_compile_to_file(
    b_lean_obj_arg ctx, uint8_t output_kind, b_lean_obj_arg output_path) {
  auto context = get_gcc_jit_context(ctx);
  auto kind = static_cast<gcc_jit_output_kind>(output_kind);
  auto path = lean_string_cstr(output_path);
  gcc_jit_context_compile_to_file(context, kind, path);
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_dump_to_file(
    b_lean_obj_arg ctx, b_lean_obj_arg output_path, uint8_t update_locations) {
  auto context = get_gcc_jit_context(ctx);
  auto path = lean_string_cstr(output_path);
  gcc_jit_context_dump_to_file(context, path,
                               static_cast<int>(update_locations));
  return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_logfile(
    b_lean_obj_arg ctx, b_lean_obj_arg handle, b_lean_obj_arg flags,
    b_lean_obj_arg verbosity) {
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
  auto context = get_gcc_jit_context(ctx);
  auto f = lean_scalar_to_int(flags);
  auto v = lean_scalar_to_int(verbosity);
  auto h = static_cast<FILE *>(lean_get_external_data(handle));
  gcc_jit_context_set_logfile(context, h, f, v);
  return lean_io_result_mk_ok(lean_box(0));
}

static inline lean_obj_res lean_option_string(const char *str) {
  if (str == nullptr) {
    return lean_box(0);
  } else {
    auto msg = lean_mk_string(str);
    auto some = lean_alloc_ctor(1, 1, 0);
    lean_ctor_set(some, 0, msg);
    return some;
  }
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_first_error(
    b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = get_gcc_jit_context(ctx);
  auto error = gcc_jit_context_get_first_error(context);
  return lean_option_string(error);
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_get_last_error(b_lean_obj_arg ctx, lean_object * /* w */) {
  auto context = get_gcc_jit_context(ctx);
  auto error = gcc_jit_context_get_last_error(context);
  return lean_option_string(error);
}

extern "C" LEAN_EXPORT size_t lean_gcc_jit_result_get_code(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = get_gcc_jit_result(res);
  auto funcname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_code(result, funcname);
  return reinterpret_cast<size_t>(addr);
}

extern "C" LEAN_EXPORT size_t lean_gcc_jit_result_get_global(
    b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */) {
  auto result = get_gcc_jit_result(res);
  auto gname = lean_string_cstr(name);
  auto addr = gcc_jit_result_get_global(result, gname);
  return reinterpret_cast<size_t>(addr);
}

} // namespace lean_gccjit