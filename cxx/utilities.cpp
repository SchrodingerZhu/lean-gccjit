#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_version_major(lean_object *)
{
    return lean_int_to_int(gcc_jit_version_major());
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_version_minor(lean_object *)
{
    return lean_int_to_int(gcc_jit_version_minor());
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_version_patchlevel(lean_object *)
{
    return lean_int_to_int(gcc_jit_version_patchlevel());
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_dynamic_buffer_acquire(lean_object *)
{
    char ** buffer;
#ifdef LEAN_SMALL_ALLOCATOR
    auto size = lean_align(sizeof(char *), LEAN_OBJECT_SIZE_DELTA);
    auto slot = lean_get_slot_idx(size);
    buffer = reinterpret_cast<char **>(lean_alloc_small(size, slot));
#else
    buffer = reinterpret_cast<char **>(malloc(sizeof(char *)));
#endif
    *buffer = nullptr;
    return wrap_pointer(buffer);
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_dynamic_buffer_release_inner(b_lean_obj_arg buffer, lean_object *)
{
    auto * buf = unwrap_pointer<char *>(buffer);
    free(*buf);
    return lean_io_result_mk_ok(lean_box(0));
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_dynamic_buffer_release(b_lean_obj_arg buffer, lean_object *)
{
    auto * buf = unwrap_pointer<char *>(buffer);
#ifdef LEAN_SMALL_ALLOCATOR
    lean_free_small(buf);
#else
    free(buf);
#endif
    return lean_io_result_mk_ok(lean_box(0));
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_dynamic_buffer_get_string(b_lean_obj_arg buffer, lean_object *)
{
    auto * buf = unwrap_pointer<char *>(buffer);
    return lean_option_string(*buf);
}
} // namespace lean_gccjit