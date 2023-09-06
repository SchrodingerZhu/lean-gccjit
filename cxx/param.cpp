#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_param(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg ty,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto param_name = lean_string_cstr(name);
    auto result = gcc_jit_context_new_param(context, location, type, param_name);
    return map_notnull(result, wrap_pointer<gcc_jit_param>, "invalid param");
}

LEAN_GCC_JIT_UPCAST(param, object)

LEAN_GCC_JIT_UPCAST(param, lvalue)

LEAN_GCC_JIT_UPCAST(param, rvalue)

} // namespace lean_gccjit