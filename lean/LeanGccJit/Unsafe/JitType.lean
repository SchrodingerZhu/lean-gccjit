import LeanGccJit.Types

@[extern "lean_gcc_jit_context_get_type"]
opaque Context.getType (ctx : @& Context) (type : @& TypeEnum) : IO JitType

@[extern "lean_gcc_jit_type_as_object"]
opaque JitType.asObject (ty : @& JitType) : IO Object

@[extern "lean_gcc_jit_context_get_int_type"]
opaque Context.getIntType 
(ctx : @& Context) (numBytes : @& Int) (isSigned: @& Bool)  : IO JitType

@[extern "lean_gcc_jit_type_get_pointer"]
opaque JitType.getPointer (ty : @& JitType) : IO JitType

@[extern "lean_gcc_jit_type_get_const"]
opaque JitType.getConst (ty : @& JitType) : IO JitType

@[extern "lean_gcc_jit_type_get_volatile"]
opaque JitType.getVolatile (ty : @& JitType) : IO JitType