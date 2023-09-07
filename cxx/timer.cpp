#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_timer_new(lean_object * /* RealWorld */)
{
    auto * timer = gcc_jit_timer_new();
    return map_notnull(timer, wrap_pointer<gcc_jit_timer>, "invalid timer");
}
} // namespace lean_gccjit