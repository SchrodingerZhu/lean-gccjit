import LeanGccJit.Unsafe.Types
namespace LeanGccJit
namespace Unsafe

@[extern "lean_gcc_jit_context_new_case"]
opaque Context.newCase (ctx : @& Context) (min: @& RValue) (max: @& RValue) (block: @& Block) : IO Case

@[extern "lean_gcc_jit_case_as_object"]
opaque Case.asObject (c : @& Case) : IO Object