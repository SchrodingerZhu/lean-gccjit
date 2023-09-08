#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_function(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    uint8_t kind,
    b_lean_obj_arg ret_type,
    b_lean_obj_arg name,
    b_lean_obj_arg params,
    uint8_t is_variadic,
    lean_object * /* w */
)
{
    auto params_len = lean_array_size(params);
    LEAN_GCC_JIT_FAILED_IF(params_len > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto function_kind = static_cast<gcc_jit_function_kind>(kind);
    auto return_type = unwrap_pointer<gcc_jit_type>(ret_type);
    auto function_name = lean_string_cstr(name);
    auto num_params = static_cast<int>(params_len);
    auto variadic = static_cast<int>(is_variadic);
    auto result = with_allocation<gcc_jit_param *>(params_len, [=](gcc_jit_param ** ptr) {
        unwrap_area(params_len, lean_array_cptr(params), ptr);
        return gcc_jit_context_new_function(
            context,
            location,
            function_kind,
            return_type,
            function_name,
            num_params,
            ptr,
            variadic);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_function>, "failed to create function");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_builtin_function(
    b_lean_obj_arg ctx,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto function_name = lean_string_cstr(name);
    auto result = gcc_jit_context_get_builtin_function(context, function_name);
    return map_notnull(result, wrap_pointer<gcc_jit_function>, "failed to get builtin function");
}

LEAN_GCC_JIT_UPCAST(function, object)

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_get_param(
    b_lean_obj_arg fn,
    b_lean_obj_arg idx,
    lean_object * /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(idx));
    auto * fn_ = unwrap_pointer<gcc_jit_function>(fn);
    auto index = lean_unbox(idx);
    LEAN_GCC_JIT_FAILED_IF(index > INT_MAX);
    auto index_ = static_cast<int>(index);
    auto * param = gcc_jit_function_get_param(fn_, index_);
    return map_notnull(param, wrap_pointer<gcc_jit_param>, "invalid param");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_dump_to_dot(
    b_lean_obj_arg fn,
    b_lean_obj_arg path,
    lean_object * /* w */
)
{
    auto * fn_ = unwrap_pointer<gcc_jit_function>(fn);
    auto * path_ = lean_string_cstr(path);
    gcc_jit_function_dump_to_dot(fn_, path_);
    return lean_io_result_mk_ok(lean_box(0));
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_get_address(
    b_lean_obj_arg fn,  /* @& Function */
    b_lean_obj_arg loc, /* @& Option Location */
    lean_object *       /* w */
)
{
    auto * fn_ = unwrap_pointer<gcc_jit_function>(fn);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto * result = gcc_jit_function_get_address(fn_, location);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to get address");
}

LEAN_GCC_JIT_QUERY_OBJECT(function, _get, return_type);
LEAN_GCC_JIT_QUERY_SCALAR(function, _get, param_count)


} // namespace lean_gccjit