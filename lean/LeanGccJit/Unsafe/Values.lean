import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_global"]
opaque Context.newGlobal (ctx : @& Context) (loc : @& Option Location) (kind: @& GlobalKind) (type : @& JitType) (name : @& String)  : IO LValue

@[extern "lean_gcc_jit_context_new_struct_constructor"]
opaque Context.newStructConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (fields: @& Option (Array Field)) (values: @& Array RValue)  : IO RValue

@[extern "lean_gcc_jit_context_new_union_constructor"]
opaque Context.newUnionConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (field: @& Field) (value: @& Option RValue)  : IO RValue

@[extern "lean_gcc_jit_context_new_array_constructor"]
opaque Context.newArrayConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (values: @& Array RValue)  : IO RValue

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
  (ctx : @& Context) (loc : @& Option Location) (op : @& UnaryOp) (ty : @& JitType) (val : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_binary_op"]
opaque Context.newBinaryOp 
  (ctx : @& Context) (loc : @& Option Location) (op : @& BinaryOp) (ty : @& JitType) (a : @& RValue) (b : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_comparison"]
opaque Context.newComparison 
  (ctx : @& Context) (loc : @& Option Location) (op : @& Comparison) (a : @& RValue) (b : @& RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_call"]
opaque Context.newCall 
  (ctx : @& Context) (loc : @& Option Location) (fn : @& Func) (args : @& Array RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_call_through_ptr"]
opaque Context.newCallThroughPtr 
  (ctx : @& Context) (loc : @& Option Location) (fnPtr : @& RValue) (args : @& Array RValue) : IO RValue

@[extern "lean_gcc_jit_context_new_cast"]
opaque Context.newCast 
  (ctx : @& Context) (loc : @& Option Location)  (val : @& RValue) (ty : @& JitType) : IO RValue

@[extern "lean_gcc_jit_context_new_bitcast"]
opaque Context.newBitCast 
  (ctx : @& Context) (loc : @& Option Location)  (val : @& RValue) (ty : @& JitType) : IO RValue

@[extern "lean_gcc_jit_lvalue_set_alignment"]
opaque LValue.setAlignment (lval : @& LValue) (align : @& Nat) : IO PUnit

@[extern "lean_gcc_jit_lvalue_get_alignment"]
opaque LValue.getAlignment (lval : @& LValue) : IO Nat

@[extern "lean_gcc_jit_context_new_array_access"]
opaque Context.newArrayAccess 
  (ctx : @& Context) (loc : @& Option Location) (ptr : @& RValue) (index : @& RValue) : IO LValue

@[extern "lean_gcc_jit_lvalue_access_field"]
opaque LValue.accessField 
  (lval : @& LValue) (loc : @& Option Location) (field : @& Field) : IO LValue

@[extern "lean_gcc_jit_rvalue_access_field"]
opaque RValue.accessField 
  (rval : @& RValue) (loc : @& Option Location) (field : @& Field) : IO RValue

@[extern "lean_gcc_jit_rvalue_dereference_field"]
opaque RValue.dereferenceField 
  (rval : @& RValue) (loc : @& Option Location) (field : @& Field) : IO LValue

@[extern "lean_gcc_jit_rvalue_dereference"]
opaque RValue.dereference
  (rval : @& RValue) (loc : @& Option Location) : IO LValue

@[extern "lean_gcc_jit_lvalue_get_address"]
opaque LValue.getAddress
  (lval : @& RValue) (loc : @& Option Location) : IO RValue

@[extern "lean_gcc_jit_lvalue_set_tls_model"]
opaque LValue.setTlsModel
  (lval : @& RValue) (tlsModel: @& TlsModel) : IO PUnit

@[extern "lean_gcc_jit_lvalue_set_link_section"]
opaque LValue.setLinkSection
  (lval : @& RValue) (linkSection: @& String) : IO PUnit

@[extern "lean_gcc_jit_lvalue_set_register_name"]
opaque LValue.setRegisterName
  (lval : @& RValue) (regName: @& String) : IO PUnit

@[extern "lean_gcc_jit_function_new_local"]
opaque Func.newLocal
  (func : @& Func) (loc : @& Option Location) (ty : @& JitType) (name : @& String) : IO LValue