import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_global"]
opaque Context.newGlobal (ctx : @& Context) (loc : @& Location) (kind: @& GlobalKind) (type : @& JitType) (name : @& String)  : IO LValue

@[extern "lean_gcc_jit_context_new_struct_constructor"]
opaque Context.newStructConstructor 
  (ctx : @& Context) (loc : @& Location) (type : @& JitType) (fields: @& Option (Array Field)) (values: @& Array RValue)  : IO RValue

@[extern "lean_gcc_jit_context_new_union_constructor"]
opaque Context.newUnionConstructor 
  (ctx : @& Context) (loc : @& Location) (type : @& JitType) (field: @& Field) (value: @& Option RValue)  : IO RValue

@[extern "lean_gcc_jit_context_new_array_constructor"]
opaque Context.newArrayConstructor 
  (ctx : @& Context) (loc : @& Location) (type : @& JitType) (values: @& Array RValue)  : IO RValue

@[extern "lean_gcc_jit_global_set_initializer_rvalue"]
opaque Global.setInitializerRValue 
  (glob : @& LValue) (value: @& Array RValue) : IO LValue

@[extern "lean_gcc_jit_global_set_initializer"]
opaque Global.setInitializer
  (glob : @& LValue) (value: @& ByteArray) : IO LValue

@[extern "lean_gcc_jit_lvalue_as_object"]
opaque LValue.asObject (lval : @& LValue) : IO Object

@[extern "lean_gcc_jit_lvalue_as_rvalue"]
opaque LValue.asRValue (lval : @& LValue) : IO RValue

@[extern "lean_gcc_jit_rvalue_as_object"]
opaque RValue.asObject (rval : @& RValue) : IO Object

@[extern "lean_gcc_jit_rvalue_get_type"]
opaque RValue.getType(rval : @& RValue) : IO JitType

@[extern "lean_gcc_jit_context_new_rvalue_from_uint32"]
opaque Context.newRvalueFromUInt32 (ctx : @& Context) (ty : @& JitType) (val : UInt32) : IO RValue

@[extern "lean_gcc_jit_context_new_rvalue_from_uint64"]
opaque Context.newRvalueFromUInt64 (ctx : @& Context) (ty : @& JitType) (val : UInt64) : IO RValue

@[extern "lean_gcc_jit_context_zero"]
opaque Context.zero (ctx : @& Context) (ty : @& JitType) : IO RValue

@[extern "lean_gcc_jit_context_one"]
opaque Context.one (ctx : @& Context) (ty : @& JitType) : IO RValue

@[extern "lean_gcc_jit_context_new_rvalue_from_double"]
opaque Context.newRValueFromDouble (ctx : @& Context) (ty : @& JitType) (val: Float) : IO RValue

@[extern "lean_gcc_jit_context_new_rvalue_from_addr"]
opaque Context.newRValueFromAddr (ctx : @& Context) (ty : @& JitType) (addr: USize) : IO RValue

@[extern "lean_gcc_jit_context_null"]
opaque Context.null (ctx : @& Context) (ty : @& JitType): IO RValue

@[extern "lean_gcc_jit_context_new_string_literal"]
opaque Context.newStringLiteral (ctx : @& Context) (str: @& String) : IO RValue

@[extern "lean_gcc_jit_context_new_unary_op"]
opaque Context.newUnaryOp 
  (ctx : @& Context) (loc : @& Location) (op : @& UnaryOp) (ty : @& JitType) (val : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_binary_op"]
opaque Context.newBinaryOp 
  (ctx : @& Context) (loc : @& Location) (op : @& BinaryOp) (ty : @& JitType) (a : @& RValue) (b : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_comparison"]
opaque Context.newComparison 
  (ctx : @& Context) (loc : @& Location) (op : @& Comparison) (a : @& RValue) (b : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_call"]
opaque Context.newCall 
  (ctx : @& Context) (loc : @& Location) (fn : @& Func) (args : @& Array RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_call_through_ptr"]
opaque Context.newCallThroughPtr 
  (ctx : @& Context) (loc : @& Location) (fnPtr : @& RValue) (args : @& Array RValue) : IO RValue