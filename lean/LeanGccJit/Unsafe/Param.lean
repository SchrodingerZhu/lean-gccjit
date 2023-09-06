import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_location"]
opaque Context.newParam (ctx : @& Context) (location : @& Location) (type : @& Type) (name : @& String) : IO Param

@[extern "lean_gcc_jit_param_as_object"]
opaque Param.asObject (param : @& Param) : IO Object

@[extern "lean_gcc_jit_param_as_lvalue"]
opaque Param.asLValue (param : @& Param) : IO LValue

@[extern "lean_gcc_jit_param_as_rvalue"]
opaque Param.asRValue (param : @& Param) : IO RValue