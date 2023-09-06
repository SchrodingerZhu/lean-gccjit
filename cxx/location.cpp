#include "common.h"
namespace lean_gccjit
{

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_location(
    b_lean_obj_arg ctx,
    b_lean_obj_arg filename,
    b_lean_obj_arg line,
    b_lean_obj_arg column,
    lean_object * /* w */)
{
    if (!lean_is_scalar(line))
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("line is not a scalar"));
        return lean_io_result_mk_error(error);
    }
    if (!lean_is_scalar(column))
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("column is not a scalar"));
        return lean_io_result_mk_error(error);
    }
    auto * context = unwrap_pointer<gcc_jit_context>(ctx);
    auto * fname = lean_string_cstr(filename);
    auto l = lean_scalar_to_int(line);
    auto c = lean_scalar_to_int(column);
    auto * loc = gcc_jit_context_new_location(context, fname, l, c);
    return map_notnull(loc, wrap_pointer<gcc_jit_location>, "invalid context");
}

LEAN_GCC_JIT_UPCAST(location, object)

} // namespace lean_gccjit