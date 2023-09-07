#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_new(lean_object * /* RealWorld */)
{
    auto * timer = gcc_jit_timer_new();
    return map_notnull(timer, wrap_pointer<gcc_jit_timer>, "invalid timer");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_release(
    lean_obj_arg timer, /* Timer */
    lean_object * /* RealWorld */)
{
    auto * t = unwrap_pointer<gcc_jit_timer>(timer);
    gcc_jit_timer_release(t);
    lean_dec(timer);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_timer(
    b_lean_obj_arg ctx,   /* Context */
    b_lean_obj_arg timer, /* Timer */
    lean_object * /* RealWorld */)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto * t = unwrap_pointer<gcc_jit_timer>(timer);
    gcc_jit_context_set_timer(context, t);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_timer(
    b_lean_obj_arg ctx, /* Context */
    lean_object * /* RealWorld */)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto * timer = gcc_jit_context_get_timer(context);
    return lean_io_result_mk_ok(wrap_option(timer));
}
} // namespace lean_gccjit