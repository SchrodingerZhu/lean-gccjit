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

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_switch(
    b_lean_obj_arg block,       /* @& Block */
    b_lean_obj_arg loc,         /* @& Option Location */
    b_lean_obj_arg expr,        /* @& RValue */
    b_lean_obj_arg default_blk, /* @& Block */
    b_lean_obj_arg cases,       /* @& Array Case */
    lean_object *               /* RealWorld */
)
{
    auto cases_len = lean_array_size(cases);
    LEAN_GCC_JIT_FAILED_IF(cases_len > INT_MAX);
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * expr_ = unwrap_pointer<gcc_jit_rvalue>(expr);
    auto * default_blk_ = unwrap_pointer<gcc_jit_block>(default_blk);
    auto num_cases = static_cast<int>(cases_len);
    auto * result = with_allocation<gcc_jit_case *>(cases_len, [=](gcc_jit_case ** ptr) {
        unwrap_area(cases_len, lean_array_cptr(cases), ptr);
        gcc_jit_block_end_with_switch(block_, location, expr_, default_blk_, num_cases, ptr);
        return lean_box(0);
    });
    return lean_io_result_mk_ok(result);
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_end_with_extended_asm_goto(
    b_lean_obj_arg block,       /* @& Block */
    b_lean_obj_arg loc,         /* @& Option Location */
    b_lean_obj_arg asm_str,     /* @& String */
    b_lean_obj_arg blocks,      /* @& Array Block */
    b_lean_obj_arg fallthrough, /* @& Option Block */
    lean_object *               /* RealWorld */
)
{
    size_t blocks_len = lean_array_size(blocks);
    LEAN_GCC_JIT_FAILED_IF(blocks_len > INT_MAX);
    auto * block_ = unwrap_pointer<gcc_jit_block>(block);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto asm_str_ = lean_string_cstr(asm_str);
    auto num_blocks = static_cast<int>(blocks_len);
    auto fallthrough_ = unwrap_option<gcc_jit_block>(fallthrough);
    auto * result = with_allocation<gcc_jit_block *>(blocks_len, [=](gcc_jit_block ** ptr) {
        unwrap_area(blocks_len, lean_array_cptr(blocks), ptr);
        auto asm_ = gcc_jit_block_end_with_extended_asm_goto(block_, location, asm_str_, num_blocks, ptr, fallthrough_);
        return map_notnull(asm_, wrap_pointer<gcc_jit_extended_asm>, "invalid extended asm");
    });
    return result;
}


} // namespace lean_gccjit