#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_opaque_struct(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg name,
    lean_object * /* w */
)
{
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto struct_name = lean_string_cstr(name);
    auto result = gcc_jit_context_new_opaque_struct(context, location, struct_name);
    return map_notnull(result, wrap_pointer<gcc_jit_struct>, "failed to create opaque struct");
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_context_new_struct_type(
    b_lean_obj_arg ctx,
    b_lean_obj_arg loc,
    b_lean_obj_arg name,
    b_lean_obj_arg fields,
    lean_object * /* w */
)
{
    auto array_len = lean_array_size(fields);
    if (array_len > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many fields"));
        return lean_io_result_mk_error(error);
    }
    auto context = unwrap_pointer<gcc_jit_context>(ctx);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto struct_name = lean_string_cstr(name);
    auto num_fields = static_cast<int>(array_len);
    gcc_jit_struct * result = with_allocation<gcc_jit_field *>(array_len, [=](gcc_jit_field ** ptr) {
        unwrap_area(array_len, lean_array_cptr(fields), ptr);
        return gcc_jit_context_new_struct_type(context, location, struct_name, num_fields, ptr);
    });
    return map_notnull(result, wrap_pointer<gcc_jit_struct>, "failed to create struct");
}

LEAN_GCC_JIT_UPCAST(struct, type)

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_struct_set_fields(
    b_lean_obj_arg st,
    b_lean_obj_arg loc,
    b_lean_obj_arg fields,
    lean_object * /* w */
)
{
    auto array_len = lean_array_size(fields);
    if (array_len > INT_MAX)
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("too many fields"));
        return lean_io_result_mk_error(error);
    }
    auto st_ = unwrap_pointer<gcc_jit_struct>(st);
    auto location = unwrap_pointer<gcc_jit_location>(loc);
    auto num_fields = static_cast<int>(array_len);

    auto res = with_allocation<gcc_jit_field *>(array_len, [=](gcc_jit_field ** ptr) {
        unwrap_area(array_len, lean_array_cptr(fields), ptr);
        gcc_jit_struct_set_fields(st_, location, num_fields, ptr);
        return lean_box(0);
    });
    return lean_io_result_mk_ok(res);
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_struct_get_field(
    b_lean_obj_arg st,
    b_lean_obj_arg idx,
    lean_object * /* w */
)
{
    if (!lean_is_scalar(idx))
    {
        auto error = lean_mk_io_error_invalid_argument(EINVAL, lean_mk_string("idx is not a scalar"));
        return lean_io_result_mk_error(error);
    }
    auto st_ = unwrap_pointer<gcc_jit_struct>(st);
    auto index = lean_unbox(idx);
    auto result = gcc_jit_struct_get_field(st_, index);
    return map_notnull(result, wrap_pointer<gcc_jit_field>, "failed to get field");
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_struct_get_field_count(
    b_lean_obj_arg st,
    lean_object * /* w */
)
{
    auto st_ = unwrap_pointer<gcc_jit_struct>(st);
    auto result = gcc_jit_struct_get_field_count(st_);
    return map_notnull(result, lean_usize_to_nat, "failed to get field count");
}
} // namespace lean_gccjit