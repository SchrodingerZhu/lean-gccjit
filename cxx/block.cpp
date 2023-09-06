#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_new_block(
    b_lean_obj_arg func,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto * function = unwrap_pointer<gcc_jit_function>(func);
    auto block_name = lean_string_cstr(name);
    auto * block = gcc_jit_function_new_block(function, block_name);
    return map_notnull(block, wrap_pointer<gcc_jit_block>, "invalid block");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_as_object(
    b_lean_obj_arg block,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * obj = gcc_jit_block_as_object(block_);
    return map_notnull(obj, wrap_pointer<gcc_jit_object>, "invalid block");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_get_function(
    b_lean_obj_arg block,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * func = gcc_jit_block_get_function(block_);
    return map_notnull(func, wrap_pointer<gcc_jit_function>, "invalid block");
}

} // namespace lean_gccjit