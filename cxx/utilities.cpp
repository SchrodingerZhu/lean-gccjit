#include "common.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_version_major(lean_object *) {
  return lean_int_to_int(gcc_jit_version_major());
}
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_version_minor(lean_object *) {
  return lean_int_to_int(gcc_jit_version_minor());
}
extern "C" LEAN_EXPORT lean_obj_res
lean_gcc_jit_version_patchlevel(lean_object *) {
  return lean_int_to_int(gcc_jit_version_patchlevel());
}
} // namespace lean_gccjit