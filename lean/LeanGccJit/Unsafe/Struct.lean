import LeanGccJit.Types
@[extern "lean_gcc_jit_context_new_struct_type"]
opaque Context.newStructType
  (ctx : @& Context) (location : @& Location) (name : @& String) (fields : @& Array Field) : IO Struct

@[extern "lean_gcc_jit_context_new_opaque_struct"]
opaque Context.newOpaqueStruct
  (ctx : @& Context) (location : @& Location) (name : @& String) : IO Struct

@[extern "lean_gcc_jit_struct_as_type"]
opaque Struct.asJitType (s : @& Struct) : IO JitType

@[extern "lean_gcc_jit_struct_set_fields"]
opaque Struct.setFields (s : @& Struct) (location : @& Location) (fields : @& Array Field) : IO PUnit

@[extern "lean_gcc_jit_struct_get_field"]
opaque Struct.getField (s : @& Struct) (idx : @& Nat) : IO Field

@[extern "lean_gcc_jit_struct_get_field_count"]
opaque Struct.getFieldCount (s : @& Struct) : IO Nat