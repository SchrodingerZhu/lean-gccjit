#include "common.h"
#include "lean/lean.h"
namespace lean_gccjit {
extern "C" LEAN_EXPORT 
lean_obj_res lean_gcc_jit_object_get_context(b_lean_obj_arg object) {
  auto * obj = unwrap_pointer<gcc_jit_object>(object);
  auto * ctx = gcc_jit_object_get_context(obj);
  return wrap_pointer(ctx);
}
extern "C" LEAN_EXPORT
lean_obj_res lean_gcc_jit_object_get_debug_string(b_lean_obj_arg object) {
  auto * obj = unwrap_pointer<gcc_jit_object>(object);
  auto * str = gcc_jit_object_get_debug_string(obj);
  return lean_mk_string(str);
}
}