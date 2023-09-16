import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

@[extern "lean_gcc_jit_context_compile"]
opaque Context.compile: @& Context → IO Result

@[extern "lean_gcc_jit_result_get_code"]
opaque Result.getCode: @& Result → @& String → IO USize

@[extern "lean_gcc_jit_result_get_function"]
opaque Result.getFunction! {α : Type} [Nonempty α] : @& Result → @& String → IO α

@[extern "lean_gcc_jit_result_get_global"]
opaque Result.getGlobal: @& Result → @& String → IO USize

@[extern "lean_gcc_jit_result_release"]
opaque Result.release: Result → IO PUnit