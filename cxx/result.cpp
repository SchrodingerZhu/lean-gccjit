#include "common.h"
namespace lean_gccjit
{

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_compile(b_lean_obj_arg ctx, lean_object * /* w */)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto result = gcc_jit_context_compile(context);
    return map_notnull(result, wrap_pointer<gcc_jit_result>, "failed to compile context");
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_result_get_code(b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */)
{
    auto result = unwrap_pointer<gcc_jit_result>(res);
    auto funcname = lean_string_cstr(name);
    auto addr = gcc_jit_result_get_code(result, funcname);
    return map_notnull(reinterpret_cast<size_t>(addr), lean_box_usize, "failed to get code");
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_result_get_global(b_lean_obj_arg res, b_lean_obj_arg name, lean_object * /* w */)
{
    auto result = unwrap_pointer<gcc_jit_result>(res);
    auto gname = lean_string_cstr(name);
    auto addr = gcc_jit_result_get_global(result, gname);
    return map_notnull(reinterpret_cast<size_t>(addr), lean_box_usize, "failed to get global");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_result_get_function(
    b_lean_obj_arg res,   /* @& Result */
    b_lean_obj_arg name,  /* @& String */
    b_lean_obj_arg arity, /* @& Nat */
    lean_object * /* w */)
{
    auto result = unwrap_pointer<gcc_jit_result>(res);
    auto fname = lean_string_cstr(name);
    auto addr = gcc_jit_result_get_code(result, fname);
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(arity));
    auto arity_ = lean_unbox(arity);
    LEAN_GCC_JIT_FAILED_IF(arity_ > UINT_MAX);
    return map_notnull(
        addr,
        [arity_](void * func) { return lean_alloc_closure(func, arity_, 0); },
        "failed to get function");
}

} // namespace lean_gccjit