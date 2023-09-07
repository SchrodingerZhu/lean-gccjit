#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_global(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    uint8_t kind,
    b_lean_obj_arg ty,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto kind_ = static_cast<gcc_jit_global_kind>(kind);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto global_name = lean_string_cstr(name);
    auto result = gcc_jit_context_new_global(context, location, kind_, type, global_name);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "invalid global");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_struct_constructor(
    b_lean_obj_arg ctx,    /* @& Context */
    b_lean_obj_arg loc,    /* @& Location */
    b_lean_obj_arg ty,     /* @& JitType */
    b_lean_obj_arg fields, /* @& Option (Array Field) */
    b_lean_obj_arg values, /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    auto values_len = lean_array_size(values);
    if (values_len > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many values"));
        return lean_io_result_mk_error(error);
    }

    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto num_values = static_cast<int>(values_len);

    auto fields_ctor = lean_obj_tag(fields);
    gcc_jit_rvalue * result;
    if (fields_ctor == 1)
    {
        auto fields_ = lean_ctor_get(fields, 0);
        auto fields_len = lean_array_size(fields_);
        if (fields_len != values_len)
        {
            auto error
                = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("fields and values have different lengths"));
            return lean_io_result_mk_error(error);
        }
        result = with_allocation<gcc_jit_rvalue *>(values_len, [=](auto * vbuffer) {
            return with_allocation<gcc_jit_field *>(fields_len, [=](auto * fbuffer) {
                unwrap_area(fields_len, lean_array_cptr(fields_), fbuffer);
                unwrap_area(values_len, lean_array_cptr(values), vbuffer);
                return gcc_jit_context_new_struct_constructor(context, location, type, fields_len, fbuffer, vbuffer);
            });
        });
    }
    else
    {
        result = with_allocation<gcc_jit_rvalue *>(values_len, [=](auto * vbuffer) {
            unwrap_area(values_len, lean_array_cptr(values), vbuffer);
            return gcc_jit_context_new_struct_constructor(context, location, type, num_values, nullptr, vbuffer);
        });
    }
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create struct constructor");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_union_constructor(
    b_lean_obj_arg ctx,   /* @& Context */
    b_lean_obj_arg loc,   /* @& Location */
    b_lean_obj_arg ty,    /* @& JitType */
    b_lean_obj_arg field, /* @& Field */
    b_lean_obj_arg value, /* @& Option RValue */
    lean_object *         /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto field_ = unwrap_pointer<gcc_jit_field>(field);
    auto value_ = lean_obj_tag(value) == 1 ? unwrap_pointer<gcc_jit_rvalue>(lean_ctor_get(value, 0)) : nullptr;
    auto result = gcc_jit_context_new_union_constructor(context, location, type, field_, value_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create union constructor");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_array_constructor(
    b_lean_obj_arg ctx,    /* @& Context */
    b_lean_obj_arg loc,    /* @& Location */
    b_lean_obj_arg ty,     /* @& JitType */
    b_lean_obj_arg values, /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    auto values_len = lean_array_size(values);
    if (values_len > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many values"));
        return lean_io_result_mk_error(error);
    }

    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto num_values = static_cast<int>(values_len);

    auto result = with_allocation<gcc_jit_rvalue *>(values_len, [=](auto * vbuffer) {
        unwrap_area(values_len, lean_array_cptr(values), vbuffer);
        return gcc_jit_context_new_array_constructor(context, location, type, num_values, vbuffer);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create array constructor");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_global_set_initializer_rvalue(
    b_lean_obj_arg global, /* @& LValue */
    b_lean_obj_arg init,   /* @& RValue */
    lean_object *          /* RealWorld */
)
{
    auto global_ = unwrap_pointer<gcc_jit_lvalue>(global);
    auto init_ = unwrap_pointer<gcc_jit_rvalue>(init);
    auto res = gcc_jit_global_set_initializer_rvalue(global_, init_);
    return map_notnull(res, wrap_pointer<gcc_jit_lvalue>, "failed to set initializer");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_global_set_initializer(
    b_lean_obj_arg global, /* @& LValue */
    b_lean_obj_arg blob,   /* @& ByteArray */
    lean_object *          /* RealWorld */
)
{
    auto global_ = unwrap_pointer<gcc_jit_lvalue>(global);
    auto blob_ = lean_sarray_cptr(blob);
    auto num_bytes = lean_sarray_size(blob);
    auto res = gcc_jit_global_set_initializer(global_, blob_, num_bytes);
    return map_notnull(res, wrap_pointer<gcc_jit_lvalue>, "failed to set initializer");
}

LEAN_GCC_JIT_UPCAST(lvalue, object)
LEAN_GCC_JIT_UPCAST(lvalue, rvalue)
LEAN_GCC_JIT_UPCAST(rvalue, object)

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_rvalue_get_type(
    b_lean_obj_arg rv, /* @& RValue */
    lean_object *      /* RealWorld */
)
{
    auto rvalue = unwrap_pointer<gcc_jit_rvalue>(rv);
    auto result = gcc_jit_rvalue_get_type(rvalue);
    return wrap_pointer(result);
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_rvalue_from_uint32(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    uint32_t val,       /* UInt32 */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_rvalue_from_int(context, type, static_cast<int>(val));
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from uint32");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_rvalue_from_uint64(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    uint64_t val,       /* UInt64 */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_rvalue_from_long(context, type, static_cast<long>(val));
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from uint64");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_zero(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_zero(context, type);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue 0");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_one(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_one(context, type);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue 1");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_rvalue_from_double(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    double val,         /* @& Float */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_rvalue_from_double(context, type, val);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from double");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_rvalue_from_addr(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    size_t val,         /* @& USize */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_rvalue_from_ptr(context, type, reinterpret_cast<void *>(val));
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from ptr");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_null(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_null(context, type);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue null");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_string_literal(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg val, /* @& String */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto val_ = lean_string_cstr(val);
    auto result = gcc_jit_context_new_string_literal(context, val_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from string literal");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_unary_op(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Location */
    uint8_t op,         /* @& UnaryOp */
    b_lean_obj_arg ty,  /* @& JitType */
    b_lean_obj_arg val, /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto op_ = static_cast<gcc_jit_unary_op>(op);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto result = gcc_jit_context_new_unary_op(context, location, op_, type, val_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create unary op");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_binary_op(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Location */
    uint8_t op,         /* @& BinaryOp */
    b_lean_obj_arg ty,  /* @& JitType */
    b_lean_obj_arg a,   /* @& RValue */
    b_lean_obj_arg b,   /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto op_ = static_cast<gcc_jit_binary_op>(op);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto a_ = unwrap_pointer<gcc_jit_rvalue>(a);
    auto b_ = unwrap_pointer<gcc_jit_rvalue>(b);
    auto result = gcc_jit_context_new_binary_op(context, location, op_, type, a_, b_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create binary op");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_comparison(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Location */
    uint8_t cmp,        /* @& Comparison */
    b_lean_obj_arg a,   /* @& RValue */
    b_lean_obj_arg b,   /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto cmp_ = static_cast<gcc_jit_comparison>(cmp);
    auto a_ = unwrap_pointer<gcc_jit_rvalue>(a);
    auto b_ = unwrap_pointer<gcc_jit_rvalue>(b);
    auto result = gcc_jit_context_new_comparison(context, location, cmp_, a_, b_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create comparison");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_call(
    b_lean_obj_arg ctx,  /* @& Context */
    b_lean_obj_arg loc,  /* @& Location */
    b_lean_obj_arg fn,   /* @& Func */
    b_lean_obj_arg args, /* @& Array RValue */
    lean_object *        /* RealWorld */
)
{
    if (lean_array_size(args) > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many args"));
        return lean_io_result_mk_error(error);
    }
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto fn_ = unwrap_pointer<gcc_jit_function>(fn);
    auto num_args = static_cast<int>(lean_array_size(args));
    gcc_jit_rvalue * result = with_allocation<gcc_jit_rvalue *>(num_args, [=](gcc_jit_rvalue ** ptr) {
        unwrap_area(num_args, lean_array_cptr(args), ptr);
        return gcc_jit_context_new_call(context, location, fn_, num_args, ptr);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create call");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_call_through_ptr(
    b_lean_obj_arg ctx,    /* @& Context */
    b_lean_obj_arg loc,    /* @& Location */
    b_lean_obj_arg fn_ptr, /* @& RValue */
    b_lean_obj_arg args,   /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    if (lean_array_size(args) > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many args"));
        return lean_io_result_mk_error(error);
    }
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto fn_ptr_ = unwrap_pointer<gcc_jit_rvalue>(fn_ptr);
    auto num_args = static_cast<int>(lean_array_size(args));
    gcc_jit_rvalue * result = with_allocation<gcc_jit_rvalue *>(num_args, [=](gcc_jit_rvalue ** ptr) {
        unwrap_area(num_args, lean_array_cptr(args), ptr);
        return gcc_jit_context_new_call_through_ptr(context, location, fn_ptr_, num_args, ptr);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create call through ptr");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_cast(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Location */
    b_lean_obj_arg val, /* @& RValue */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto ty_ = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_cast(context, location, val_, ty_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create cast");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_bitcast(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Location */
    b_lean_obj_arg val, /* @& RValue */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto ty_ = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_bitcast(context, location, val_, ty_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create bitcast");
}

} // namespace lean_gccjit