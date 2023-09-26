#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_new(lean_object * /* RealWorld */)
{
    auto * timer = gcc_jit_timer_new();
    return map_notnull(timer, wrap_pointer<gcc_jit_timer>, "invalid timer");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_release(
    lean_obj_arg timer, /* @& Timer */
    lean_object *       /* RealWorld */
)
{
    auto * t = unwrap_pointer<gcc_jit_timer>(timer);
    gcc_jit_timer_release(t);
    lean_dec(timer);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_set_timer(
    b_lean_obj_arg ctx,   /* @& Context */
    b_lean_obj_arg timer, /* @& Timer */
    lean_object *         /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto * t = unwrap_pointer<gcc_jit_timer>(timer);
    gcc_jit_context_set_timer(context, t);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_timer(
    b_lean_obj_arg ctx, /* @& Context */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto * timer = gcc_jit_context_get_timer(context);
    return lean_io_result_mk_ok(wrap_option(timer));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_push(
    b_lean_obj_arg tm,   /* @& Timer */
    b_lean_obj_arg name, /* @& String */
    lean_object *        /* RealWorld */
)
{
    auto * timer = unwrap_pointer<gcc_jit_timer>(tm);
    auto name_ = lean_string_cstr(name);
    gcc_jit_timer_push(timer, name_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_pop(
    b_lean_obj_arg tm,   /* @& Timer */
    b_lean_obj_arg name, /* @& String */
    lean_object *        /* RealWorld */
)
{
    auto * timer = unwrap_pointer<gcc_jit_timer>(tm);
    auto name_ = unwrap_option_str(name);
    gcc_jit_timer_pop(timer, name_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_print(
    b_lean_obj_arg tm,     /* @& Timer */
    b_lean_obj_arg handle, /* @& Handle */
    lean_object *          /* RealWorld */
)
{
    auto * timer = unwrap_pointer<gcc_jit_timer>(tm);
    auto * h = static_cast<FILE *>(lean_get_external_data(handle));
    gcc_jit_timer_print(timer, h);
    return lean_io_result_mk_ok(lean_box(0));
}


} // namespace lean_gccjit