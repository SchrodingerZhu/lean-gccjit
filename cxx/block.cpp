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
    auto block_name = unwrap_option_str(name);
    auto * block = gcc_jit_function_new_block(function, block_name);
    return map_notnull(block, wrap_pointer<gcc_jit_block>, "invalid block");
}

LEAN_GCC_JIT_UPCAST(block, object)

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_get_function(
    b_lean_obj_arg block,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * func = gcc_jit_block_get_function(block_);
    return map_notnull(func, wrap_pointer<gcc_jit_function>, "invalid block");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_add_eval(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg rvalue,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * rvalue_ = unwrap_pointer<gcc_jit_rvalue>(rvalue);
    gcc_jit_block_add_eval(block_, location, rvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_add_assignment(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg lvalue,
    b_lean_obj_arg rvalue,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * lvalue_ = unwrap_pointer<gcc_jit_lvalue>(lvalue);
    auto * rvalue_ = unwrap_pointer<gcc_jit_rvalue>(rvalue);
    gcc_jit_block_add_assignment(block_, location, lvalue_, rvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_add_assignment_op(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg lvalue,
    uint8_t bin_op,
    b_lean_obj_arg rvalue,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * lvalue_ = unwrap_pointer<gcc_jit_lvalue>(lvalue);
    auto binary_op = static_cast<gcc_jit_binary_op>(bin_op);
    auto * rvalue_ = unwrap_pointer<gcc_jit_rvalue>(rvalue);
    gcc_jit_block_add_assignment_op(block_, location, lvalue_, binary_op, rvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_add_comment(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg comment,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto comment_ = lean_string_cstr(comment);
    gcc_jit_block_add_comment(block_, location, comment_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_conditional(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg bval,
    b_lean_obj_arg on_true,
    b_lean_obj_arg on_false,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * bval_ = unwrap_pointer<gcc_jit_rvalue>(bval);
    auto * on_true_ = unwrap_pointer<gcc_jit_block>(on_true);
    auto * on_false_ = unwrap_pointer<gcc_jit_block>(on_false);
    gcc_jit_block_end_with_conditional(block_, location, bval_, on_true_, on_false_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_jump(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg dest,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * dest_ = unwrap_pointer<gcc_jit_block>(dest);
    gcc_jit_block_end_with_jump(block_, location, dest_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_return(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    b_lean_obj_arg rvalue,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * rvalue_ = unwrap_pointer<gcc_jit_rvalue>(rvalue);
    gcc_jit_block_end_with_return(block_, location, rvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_void_return(
    b_lean_obj_arg block,
    b_lean_obj_arg loc,
    lean_object * /* w */
)
{
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    gcc_jit_block_end_with_void_return(block_, location);
    return lean_io_result_mk_ok(lean_box(0));
}


} // namespace lean_gccjit