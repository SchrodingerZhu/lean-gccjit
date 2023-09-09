import LeanGccJit.Unsafe.Types
namespace LeanGccJit
namespace Unsafe

@[extern "lean_gcc_jit_object_get_context"]
opaque Object.getContext : @& Object -> IO Context

@[extern "lean_gcc_jit_object_get_debug_string"]
opaque Object.getDebugString : @& Object -> IO String