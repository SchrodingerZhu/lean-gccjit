#pragma once
#include <cstdint>
#include <lean/lean.h>
#include <libgccjit.h>
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

} // namespace lean_gccjit