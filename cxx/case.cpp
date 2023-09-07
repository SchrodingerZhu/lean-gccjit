#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_case(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg min, /* @& RValue */
    b_lean_obj_arg max, /* @& RValue */
    b_lean_obj_arg blk, /* @& Block */
    lean_object *       /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto min_rvalue = unwrap_pointer<gcc_jit_rvalue>(min);
    auto max_rvalue = unwrap_pointer<gcc_jit_rvalue>(max);
    auto block = unwrap_pointer<gcc_jit_block>(blk);
    auto result = gcc_jit_context_new_case(context, min_rvalue, max_rvalue, block);
    return map_notnull(result, wrap_pointer<gcc_jit_case>, "invalid case");
}
LEAN_GCC_JIT_UPCAST(case, object)

} // namespace lean_gccjit