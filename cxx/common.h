#pragma once
#include <cerrno>
#include <cstdint>
#include <lean/lean.h>
#include <libgccjit.h>
#include <utility>
namespace lean_gccjit {

static_assert(sizeof(size_t) >= sizeof(void *),
              "size_t must be at least as large as a pointer");

constexpr static inline bool POINTER_OF_64BIT = sizeof(size_t) == 8;

template <typename T> static inline lean_obj_res wrap_pointer(T *ptr) {
  size_t value = reinterpret_cast<size_t>(ptr);
  if constexpr (POINTER_OF_64BIT) {
    return lean_box(value);
  } else {
    return lean_box_usize(value);
  }
}

template <typename T> static inline T *unwrap_pointer(b_lean_obj_arg obj) {
  if constexpr (POINTER_OF_64BIT) {
    return reinterpret_cast<T *>(lean_unbox(obj));
  } else {
    return reinterpret_cast<T *>(lean_unbox_usize(obj));
  }
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

template <typename T, typename C, typename F>
static inline lean_obj_res map_condition(T &&res, C &&c, F &&f,
                                         const char *msg) {
  if (LEAN_UNLIKELY(!c(std::forward<T>(res)))) {
    return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
  }
  return lean_io_result_mk_ok(f(std::forward<T>(res)));
}

template <typename T, typename F>
static inline lean_obj_res map_notnull(T &&res, F &&f, const char *msg) {
  return map_condition(
      std::forward<T>(res), [](auto x) { return x; }, std::forward<F>(f), msg);
}

} // namespace lean_gccjit