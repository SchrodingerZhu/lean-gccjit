#include "common.h"
namespace lean_gccjit
{
LEAN_GCC_JIT_UPCAST(type, object)
extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_context_get_type(b_lean_obj_arg ctx, uint8_t type_, lean_object * /* w */)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = static_cast<gcc_jit_types>(type_);
    auto result = gcc_jit_context_get_type(context, type);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_get_int_type(
    b_lean_obj_arg ctx,
    b_lean_obj_arg num_bytes,
    uint8_t is_signed,
    lean_object * /* w */)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(num_bytes));
    auto bytes = lean_unbox(num_bytes);
    LEAN_GCC_JIT_FAILED_IF(bytes > INT_MAX);
    auto result = gcc_jit_context_get_int_type(context, static_cast<unsigned>(bytes), static_cast<int>(is_signed));
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");
}
#define LEAN_GCC_JIT_TYPE_TO_TYPE(NAME)                                                                          \
    extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_##NAME(b_lean_obj_arg type, lean_object * /* w */) \
    {                                                                                                            \
        auto ty = unwrap_pointer<gcc_jit_type>(type);                                                            \
        auto result = gcc_jit_type_get_##NAME(ty);                                                               \
        return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");                                  \
    }

LEAN_GCC_JIT_TYPE_TO_TYPE(pointer);
LEAN_GCC_JIT_TYPE_TO_TYPE(const);
LEAN_GCC_JIT_TYPE_TO_TYPE(volatile);

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_restrict(b_lean_obj_arg type, lean_object * /* w */)
{
#if defined(LIBGCCJIT_HAVE_gcc_jit_type_get_restrict)
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto result = gcc_jit_type_get_restrict(ty);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid type");
#else
    return lean_io_result_mk_error(
        lean_mk_io_error_unsupported_operation(ENOTSUP, lean_mk_string("gcc_jit_type_get_restrict is not supported")));
#endif
}

extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_compatible_types(b_lean_obj_arg type1, b_lean_obj_arg type2, lean_object * /* w */)
{
    auto t1 = unwrap_pointer<gcc_jit_type>(type1);
    auto t2 = unwrap_pointer<gcc_jit_type>(type2);
    if (gcc_jit_compatible_types(t1, t2) != 0)
    {
        return lean_io_result_mk_ok(lean_box(1));
    }
    else
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_size(b_lean_obj_arg type, lean_object * /* w */)
{
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto result = gcc_jit_type_get_size(ty);
    return map_condition(
        result,
        [](ssize_t x) { return x > 0; },
        [](ssize_t x) { return lean_box(static_cast<size_t>(x)); },
        "failed to get size");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_array_type(
    b_lean_obj_arg ctx,
    b_lean_obj_arg location,
    b_lean_obj_arg element_type,
    b_lean_obj_arg num_elements,
    lean_object * /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(num_elements));
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto loc = unwrap_option<gcc_jit_location>(location);
    auto element = unwrap_pointer<gcc_jit_type>(element_type);
    auto elements = lean_unbox(num_elements);
    auto result = gcc_jit_context_new_array_type(context, loc, element, elements);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "invalid array type");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_union_type(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg name,
    b_lean_obj_arg fields,
    lean_object * /* w */
)
{
    auto array_len = lean_array_size(fields);
    LEAN_GCC_JIT_FAILED_IF(array_len > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto union_name = lean_string_cstr(name);
    auto num_fields = static_cast<int>(array_len);
    gcc_jit_type * result = with_allocation<gcc_jit_field *>(array_len, [=](gcc_jit_field ** ptr) {
        unwrap_area(array_len, lean_array_cptr(fields), ptr);
        return gcc_jit_context_new_union_type(context, location, union_name, num_fields, ptr);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "failed to create union");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_function_ptr_type(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg ret_ty,
    b_lean_obj_arg params,
    uint8_t is_variadic,
    lean_object * /* w */
)
{
    auto array_len = lean_array_size(params);
    LEAN_GCC_JIT_FAILED_IF(array_len > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto return_type = unwrap_pointer<gcc_jit_type>(ret_ty);
    auto num_params = static_cast<int>(array_len);
    auto variadic = static_cast<int>(is_variadic);
    gcc_jit_type * result = with_allocation<gcc_jit_type *>(array_len, [=](gcc_jit_type ** ptr) {
        unwrap_area(array_len, lean_array_cptr(params), ptr);
        return gcc_jit_context_new_function_ptr_type(context, location, return_type, num_params, ptr, variadic);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "failed to create function ptr type");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_aligned(
    b_lean_obj_arg type,  /* @& Type */
    b_lean_obj_arg align, /* @& Nat */
    lean_object *         /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(align));
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto alignment = lean_unbox(align);
    auto result = gcc_jit_type_get_aligned(ty, alignment);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "failed to aligned type");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_type_get_vector(
    b_lean_obj_arg type, /* @& Type */
    b_lean_obj_arg len,  /* @& Nat */
    lean_object *        /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(len));
    auto ty = unwrap_pointer<gcc_jit_type>(type);
    auto length = lean_unbox(len);
    auto result = gcc_jit_type_get_vector(ty, length);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "failed to get vector type");
}

LEAN_GCC_JIT_QUERY_OPTION(type, _dyncast, array);
LEAN_GCC_JIT_QUERY_SCALAR(type, _is, bool)
LEAN_GCC_JIT_QUERY_OPTION(type, _dyncast, function_ptr_type);
LEAN_GCC_JIT_QUERY_OBJECT(function_type, _get, return_type);
LEAN_GCC_JIT_QUERY_SCALAR(function_type, _get, param_count);

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_type_get_param_type(
    b_lean_obj_arg fun, /* @& FunctionType */
    b_lean_obj_arg idx, /* @& Nat */
    lean_object *       /* w */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(idx));
    auto fun_ = unwrap_pointer<gcc_jit_function_type>(fun);
    auto idx_ = lean_unbox(idx);
    auto result = gcc_jit_function_type_get_param_type(fun_, idx_);
    return map_notnull(result, wrap_pointer<gcc_jit_type>, "failed to query gcc_jit_function_type_get_param_type");
}

LEAN_GCC_JIT_QUERY_SCALAR(type, _is, integral);
LEAN_GCC_JIT_QUERY_OPTION(type, _is, pointer);
LEAN_GCC_JIT_QUERY_OPTION(type, _dyncast, vector);
LEAN_GCC_JIT_QUERY_OPTION(type, _is, struct);
LEAN_GCC_JIT_QUERY_SCALAR(vector_type, _get, num_units);
LEAN_GCC_JIT_QUERY_OBJECT(vector_type, _get, element_type)
LEAN_GCC_JIT_QUERY_OBJECT(type, , unqualified);
} // namespace lean_gccjit