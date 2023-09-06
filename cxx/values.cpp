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
                for (size_t i = 0; i < fields_len; i++)
                {
                    fbuffer[i] = unwrap_pointer<gcc_jit_field>(lean_to_array(fields_)->m_data[i]);
                }
                for (size_t i = 0; i < values_len; i++)
                {
                    vbuffer[i] = unwrap_pointer<gcc_jit_rvalue>(lean_to_array(values)->m_data[i]);
                }
                return gcc_jit_context_new_struct_constructor(context, location, type, fields_len, fbuffer, vbuffer);
            });
        });
    }
    else
    {
        result = with_allocation<gcc_jit_rvalue *>(values_len, [=](auto * vbuffer) {
            for (size_t i = 0; i < values_len; i++)
            {
                vbuffer[i] = unwrap_pointer<gcc_jit_rvalue>(lean_to_array(values)->m_data[i]);
            }
            return gcc_jit_context_new_struct_constructor(context, location, type, num_values, nullptr, vbuffer);
        });
    }
    return map_notnull(result, wrap_pointer<gcc_jit_rvalue>, "failed to create struct constructor");
}
} // namespace lean_gccjit