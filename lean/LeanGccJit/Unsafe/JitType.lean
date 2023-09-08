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

@[extern "lean_gcc_jit_compatible_types"]
opaque JitType.isCompatibleWith (ty1 ty2 : @& JitType) : IO Bool

@[extern "lean_gcc_jit_type_get_size"]
opaque JitType.getSize (ty: @& JitType) : IO Nat

@[extern "lean_gcc_jit_context_new_array_type"]
opaque Context.newArrayType 
  (ctx : @& Context) (location : @& Option Location) (elemType : @& JitType) (size : @& Int) : IO JitType

@[extern "lean_gcc_jit_context_new_union_type"]
opaque Context.newUnionType 
  (ctx : @& Context) (location : @& Option Location) (name : @& CString) (fields: @& Array Field) : IO JitType

@[extern "lean_gcc_jit_context_new_function_ptr_type"]
opaque Context.newFunctionPtrType 
  (ctx : @& Context) (location : @& Option Location) (returnType : @& JitType) (params: @& Array JitType) (isVarArg : @& Bool) : IO JitType

@[extern "lean_gcc_jit_type_get_aligned"]
opaque JitType.getAligned (ty : @& JitType) (alignment : @& Nat) : IO JitType

@[extern "lean_gcc_jit_type_get_vector"]
opaque JitType.getVector (ty : @& JitType) (length : @& Nat) : IO JitType