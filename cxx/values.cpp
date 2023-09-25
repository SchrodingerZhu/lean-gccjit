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
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto kind_ = static_cast<gcc_jit_global_kind>(kind);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto global_name = lean_string_cstr(name);
    auto result = gcc_jit_context_new_global(context, location, kind_, type, global_name);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "invalid global");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_struct_constructor(
    b_lean_obj_arg ctx,    /* @& Context */
    b_lean_obj_arg loc,    /* @& Option Location */
    b_lean_obj_arg ty,     /* @& JitType */
    b_lean_obj_arg fields, /* @& Option (Array Field) */
    b_lean_obj_arg values, /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    auto values_len = lean_array_size(values);
    LEAN_GCC_JIT_FAILED_IF(values_len > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto num_values = static_cast<int>(values_len);

    auto fields_ctor = lean_obj_tag(fields);
    gcc_jit_rvalue * result;
    if (fields_ctor == 1)
    {
        auto fields_ = lean_ctor_get(fields, 0);
        auto fields_len = lean_array_size(fields_);
        LEAN_GCC_JIT_FAILED_IF(fields_len != values_len);
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
    b_lean_obj_arg loc,   /* @& Option Location */
    b_lean_obj_arg ty,    /* @& JitType */
    b_lean_obj_arg field, /* @& Field */
    b_lean_obj_arg value, /* @& Option RValue */
    lean_object *         /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto field_ = unwrap_pointer<gcc_jit_field>(field);
    auto value_ = lean_obj_tag(value) == 1 ? unwrap_pointer<gcc_jit_rvalue>(lean_ctor_get(value, 0)) : nullptr;
    auto result = gcc_jit_context_new_union_constructor(context, location, type, field_, value_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create union constructor");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_array_constructor(
    b_lean_obj_arg ctx,    /* @& Context */
    b_lean_obj_arg loc,    /* @& Option Location */
    b_lean_obj_arg ty,     /* @& JitType */
    b_lean_obj_arg values, /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    auto values_len = lean_array_size(values);
    LEAN_GCC_JIT_FAILED_IF(values_len > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
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
    return lean_io_result_mk_ok(wrap_pointer(result));
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
    b_lean_obj_arg loc, /* @& Option Location */
    uint8_t op,         /* @& UnaryOp */
    b_lean_obj_arg ty,  /* @& JitType */
    b_lean_obj_arg val, /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto op_ = static_cast<gcc_jit_unary_op>(op);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto result = gcc_jit_context_new_unary_op(context, location, op_, type, val_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create unary op");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_binary_op(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Option Location */
    uint8_t op,         /* @& BinaryOp */
    b_lean_obj_arg ty,  /* @& JitType */
    b_lean_obj_arg a,   /* @& RValue */
    b_lean_obj_arg b,   /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto op_ = static_cast<gcc_jit_binary_op>(op);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto a_ = unwrap_pointer<gcc_jit_rvalue>(a);
    auto b_ = unwrap_pointer<gcc_jit_rvalue>(b);
    auto result = gcc_jit_context_new_binary_op(context, location, op_, type, a_, b_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create binary op");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_comparison(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Option Location */
    uint8_t cmp,        /* @& Comparison */
    b_lean_obj_arg a,   /* @& RValue */
    b_lean_obj_arg b,   /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto cmp_ = static_cast<gcc_jit_comparison>(cmp);
    auto a_ = unwrap_pointer<gcc_jit_rvalue>(a);
    auto b_ = unwrap_pointer<gcc_jit_rvalue>(b);
    auto result = gcc_jit_context_new_comparison(context, location, cmp_, a_, b_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create comparison");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_call(
    b_lean_obj_arg ctx,  /* @& Context */
    b_lean_obj_arg loc,  /* @& Option Location */
    b_lean_obj_arg fn,   /* @& Func */
    b_lean_obj_arg args, /* @& Array RValue */
    lean_object *        /* RealWorld */
)
{
    LEAN_GCC_JIT_FAILED_IF(lean_array_size(args) > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
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
    b_lean_obj_arg loc,    /* @& Option Location */
    b_lean_obj_arg fn_ptr, /* @& RValue */
    b_lean_obj_arg args,   /* @& Array RValue */
    lean_object *          /* RealWorld */
)
{
    LEAN_GCC_JIT_FAILED_IF(lean_array_size(args) > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
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
    b_lean_obj_arg loc, /* @& Option Location */
    b_lean_obj_arg val, /* @& RValue */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto ty_ = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_cast(context, location, val_, ty_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create cast");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_bitcast(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Option Location */
    b_lean_obj_arg val, /* @& RValue */
    b_lean_obj_arg ty,  /* @& JitType */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto val_ = unwrap_pointer<gcc_jit_rvalue>(val);
    auto ty_ = unwrap_pointer<gcc_jit_type>(ty);
    auto result = gcc_jit_context_new_bitcast(context, location, val_, ty_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create bitcast");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_set_alignment(
    b_lean_obj_arg lv,    /* @& LValue */
    b_lean_obj_arg align, /* @& Nat */
    lean_object *         /* RealWorld */
)
{
    LEAN_GCC_JIT_FAILED_IF(!lean_is_scalar(align));
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto align_ = lean_unbox(align);
    LEAN_GCC_JIT_FAILED_IF(align_ > UINT_MAX);
    gcc_jit_lvalue_set_alignment(lvalue, static_cast<unsigned int>(align_));
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_get_alignment(
    b_lean_obj_arg lv, /* @& LValue */
    lean_object *      /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto result = gcc_jit_lvalue_get_alignment(lvalue);
    return lean_io_result_mk_ok(lean_usize_to_nat(static_cast<size_t>(result)));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_array_access(
    b_lean_obj_arg ctx, /* @& Context */
    b_lean_obj_arg loc, /* @& Option Location */
    b_lean_obj_arg ptr, /* @& RValue */
    b_lean_obj_arg idx, /* @& RValue */
    lean_object *       /* RealWorld */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto ptr_ = unwrap_pointer<gcc_jit_rvalue>(ptr);
    auto idx_ = unwrap_pointer<gcc_jit_rvalue>(idx);
    auto result = gcc_jit_context_new_array_access(context, location, ptr_, idx_);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "failed to create array access");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_access_field(
    b_lean_obj_arg lv,    /* @& LValue */
    b_lean_obj_arg loc,   /* @& Option Location */
    b_lean_obj_arg field, /* @& Field */
    lean_object *         /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto field_ = unwrap_pointer<gcc_jit_field>(field);
    auto result = gcc_jit_lvalue_access_field(lvalue, location, field_);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "failed to access field");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_rvalue_access_field(
    b_lean_obj_arg rv,    /* @& RValue */
    b_lean_obj_arg loc,   /* @& Option Location */
    b_lean_obj_arg field, /* @& Field */
    lean_object *         /* RealWorld */
)
{
    auto rvalue = unwrap_pointer<gcc_jit_rvalue>(rv);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto field_ = unwrap_pointer<gcc_jit_field>(field);
    auto result = gcc_jit_rvalue_access_field(rvalue, location, field_);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to access field");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_rvalue_dereference_field(
    b_lean_obj_arg rv,    /* @& RValue */
    b_lean_obj_arg loc,   /* @& Option Location */
    b_lean_obj_arg field, /* @& Field */
    lean_object *         /* RealWorld */
)
{
    auto rvalue = unwrap_pointer<gcc_jit_rvalue>(rv);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto field_ = unwrap_pointer<gcc_jit_field>(field);
    auto result = gcc_jit_rvalue_dereference_field(rvalue, location, field_);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "failed to dereference field");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_rvalue_dereference(
    b_lean_obj_arg rv,  /* @& RValue */
    b_lean_obj_arg loc, /* @& Option Location */
    lean_object *       /* RealWorld */
)
{
    auto rvalue = unwrap_pointer<gcc_jit_rvalue>(rv);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto result = gcc_jit_rvalue_dereference(rvalue, location);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "failed to dereference");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_get_address(
    b_lean_obj_arg lv,  /* @& LValue */
    b_lean_obj_arg loc, /* @& Option Location */
    lean_object *       /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto result = gcc_jit_lvalue_get_address(lvalue, location);
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to get address");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_set_tls_model(
    b_lean_obj_arg lv, /* @& LValue */
    uint8_t model,     /* @& TlsModel */
    lean_object *      /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto model_ = static_cast<gcc_jit_tls_model>(model);
    gcc_jit_lvalue_set_tls_model(lvalue, model_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_set_link_section(
    b_lean_obj_arg lv,      /* @& LValue */
    b_lean_obj_arg section, /* @& String */
    lean_object *           /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto section_ = lean_string_cstr(section);
    gcc_jit_lvalue_set_link_section(lvalue, section_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_lvalue_set_register_name(
    b_lean_obj_arg lv,  /* @& LValue */
    b_lean_obj_arg reg, /* @& String */
    lean_object *       /* RealWorld */
)
{
    auto lvalue = unwrap_pointer<gcc_jit_lvalue>(lv);
    auto reg_ = lean_string_cstr(reg);
    gcc_jit_lvalue_set_register_name(lvalue, reg_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_function_new_local(
    b_lean_obj_arg fn,   /* @& Func */
    b_lean_obj_arg loc,  /* @& Option Location */
    b_lean_obj_arg ty,   /* @& JitType */
    b_lean_obj_arg name, /* @& String */
    lean_object *        /* RealWorld */
)
{
    auto function = unwrap_pointer<gcc_jit_function>(fn);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto name_ = lean_string_cstr(name);
    auto result = gcc_jit_function_new_local(function, location, type, name_);
    return map_notnull(result, wrap_pointer<gcc_jit_lvalue>, "failed to create local");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_rvalue_set_bool_require_tail_call(
    b_lean_obj_arg rv, /* @& RValue */
    uint8_t val,       /* Bool */
    lean_object *      /* RealWorld */
)
{
    auto rvalue = unwrap_pointer<gcc_jit_rvalue>(rv);
    gcc_jit_rvalue_set_bool_require_tail_call(rvalue, static_cast<int>(val));
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_rvalue_from_vector(
    b_lean_obj_arg ctx,   /* @& Context */
    b_lean_obj_arg loc,   /* @& Option Location */
    b_lean_obj_arg ty,    /* @& JitType */
    b_lean_obj_arg elems, /* @& Array RValue */
    lean_object *         /* RealWorld */
)
{
    auto num_elems = lean_array_size(elems);
    LEAN_GCC_JIT_FAILED_IF(num_elems > INT_MAX);
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_option<gcc_jit_location>(loc);
    auto type = unwrap_pointer<gcc_jit_type>(ty);
    auto num_elems_ = static_cast<int>(num_elems);
    gcc_jit_rvalue * result = with_allocation<gcc_jit_rvalue *>(num_elems_, [=](gcc_jit_rvalue ** ptr) {
        unwrap_area(num_elems_, lean_array_cptr(elems), ptr);
        return gcc_jit_context_new_rvalue_from_vector(context, location, type, num_elems_, ptr);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create rvalue from vector");
}

} // namespace lean_gccjit