#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_field(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg type,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto fieldname = lean_string_cstr(name);
    auto result = gcc_jit_context_new_field(context, location, ty, fieldname);
    return map_notnull(result, wrap_pointer<gcc_jit_field>, "failed to create field");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_bitfield(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg type,
    b_lean_obj_arg width,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(width));
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto field_width = lean_unbox(width);
    auto field_name = lean_string_cstr(name);
    auto result = gcc_jit_context_new_bitfield(context, location, ty, field_width, field_name);
    return map_notnull(result, wrap_pointer<gcc_jit_field>, "failed to create field");
}

LEAN_GCC_JIT_UPCAST(field, object)

} // namespace lean_gccjit