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
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_param_as_object(
    b_lean_obj_arg param,
    lean_object * /* w */
)
{
    auto * param_ = unwrap_pointer<gcc_jit_param>(param);
    auto * obj = gcc_jit_param_as_object(param_);
    return map_notnull(obj, wrap_pointer<gcc_jit_object>, "invalid param");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_param_as_lvalue(
    b_lean_obj_arg param,
    lean_object * /* w */
)
{
    auto * param_ = unwrap_pointer<gcc_jit_param>(param);
    auto * obj = gcc_jit_param_as_lvalue(param_);
    return map_notnull(obj, wrap_pointer<gcc_jit_lvalue>, "invalid param");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_param_as_rvalue(
    b_lean_obj_arg param,
    lean_object * /* w */
)
{
    auto * param_ = unwrap_pointer<gcc_jit_param>(param);
    auto * obj = gcc_jit_param_as_rvalue(param_);
    return map_notnull(obj, wrap_pointer<gcc_jit_rvalue>, "invalid param");
}

} // namespace lean_gccjit