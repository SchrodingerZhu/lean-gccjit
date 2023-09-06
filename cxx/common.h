#pragma once
#include <lean/lean.h>
#include <libgccjit.h>

#include <cerrno>
#include <climits>
#include <cstdint>
#if __has_include(<alloca.h>)
#include <alloca.h>
#endif
namespace lean_gccjit
{

static_assert(sizeof(size_t) >= sizeof(void *), "size_t must be at least as large as a pointer");

constexpr static inline bool POINTER_OF_64BIT = sizeof(size_t) == 8;

template <typename T>
static inline lean_obj_res wrap_pointer(T * ptr)
{
    size_t value = reinterpret_cast<size_t>(ptr);
    if constexpr (POINTER_OF_64BIT)
    {
        return lean_box(value);
    }
    else
    {
        return lean_box_usize(value);
    }
}

template <typename T>
static inline T * unwrap_pointer(b_lean_obj_arg obj)
{
    if constexpr (POINTER_OF_64BIT)
    {
        return reinterpret_cast<T *>(lean_unbox(obj));
    }
    else
    {
        return reinterpret_cast<T *>(lean_unbox_usize(obj));
    }
}

static inline lean_obj_res lean_option_string(const char * str)
{
    if (str == nullptr)
    {
        return lean_box(0);
    }
    else
    {
        auto msg = lean_mk_string(str);
        auto some = lean_alloc_ctor(1, 1, 0);
        lean_ctor_set(some, 0, msg);
        return some;
    }
}

template <typename T, typename C, typename F>
static inline lean_obj_res map_condition(T && res, C && c, F && f, const char * msg)
{
    if (LEAN_UNLIKELY(!c(std::forward<T>(res))))
    {
        return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
    }
    return lean_io_result_mk_ok(f(std::forward<T>(res)));
}

template <typename T, typename F>
static inline lean_obj_res map_notnull(T && res, F && f, const char * msg)
{
    return map_condition(
        std::forward<T>(res),
        [](auto x) { return x; },
        std::forward<F>(f),
        msg);
}

extern "C" {
void * malloc(size_t size);
void free(void * ptr);
}

template <typename T, typename F>
static inline auto with_allocation(size_t n, F f)
{
    if (LEAN_LIKELY(sizeof(T) * n <= 64))
    {
        return f(static_cast<T *>(LEAN_ALLOCA(sizeof(T) * n)));
    }
    auto size = lean_align(sizeof(T) * n, LEAN_OBJECT_SIZE_DELTA);
#ifdef LEAN_SMALL_ALLOCATOR
    if (size <= LEAN_MAX_SMALL_OBJECT_SIZE)
    {
        auto ptr = static_cast<T *>(lean_alloc_small(size, lean_get_slot_idx(size)));
        auto res = f(ptr);
        lean_free_small(ptr);
        return res;
    }
#endif
    lean_inc_heartbeat();
    auto ptr = static_cast<T *>(malloc(size));
    auto res = f(ptr);
    free(ptr);
    return res;
}

#define LEAN_GCC_JIT_STRINGIFY_(x) #x
#define LEAN_GCC_JIT_STRINGIFY(x) LEAN_GCC_JIT_STRINGIFY_(x)

#define LEAN_GCC_JIT_UPCAST(A, B)                                                             \
    extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_##A##_as_##B(                            \
        b_lean_obj_arg a,                                                                     \
        lean_object * /* w */                                                                 \
    )                                                                                         \
    {                                                                                         \
        auto * a_ = unwrap_pointer<gcc_jit_##A>(a);                                           \
        auto * b = gcc_jit_##A##_as_##B(a_);                                                  \
        return map_notnull(                                                                   \
            b,                                                                                \
            wrap_pointer<gcc_jit_##B>,                                                        \
            "invalid cast from " LEAN_GCC_JIT_STRINGIFY(A) " to " LEAN_GCC_JIT_STRINGIFY(B)); \
    }

} // namespace lean_gccjit