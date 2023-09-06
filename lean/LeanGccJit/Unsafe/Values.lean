import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_global"]
opaque Context.newGlobal (ctx : @& Context) (loc : @& Location) (kind: @& GlobalKind) (type : @& JitType) (name : @& String)  : IO Global
