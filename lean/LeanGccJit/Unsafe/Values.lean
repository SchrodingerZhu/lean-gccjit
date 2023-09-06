import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_global"]
opaque Context.newGlobal (ctx : @& Context) (loc : @& Location) (kind: @& GlobalKind) (type : @& JitType) (name : @& String)  : IO LValue

@[extern "lean_gcc_jit_context_new_struct_constructor"]
opaque Context.newStructConstructor 
  (ctx : @& Context) (loc : @& Location) (type : @& JitType) (fields: @& Option (Array Field)) (values: @& Array RValue)  : IO LValue
