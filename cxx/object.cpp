#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_object_get_context(b_lean_obj_arg object, lean_object * /* w */)
{
    auto * obj = unwrap_pointer<gcc_jit_object>(object);
    auto * ctx = gcc_jit_object_get_context(obj);
    return map_notnull(ctx, wrap_pointer<gcc_jit_context>, "invalid object");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_object_get_debug_string(b_lean_obj_arg object, lean_object * /* w */)
{
    auto * obj = unwrap_pointer<gcc_jit_object>(object);
    auto * str = gcc_jit_object_get_debug_string(obj);
    return map_notnull(str, lean_mk_string, "invalid object");
}
} // namespace lean_gccjit