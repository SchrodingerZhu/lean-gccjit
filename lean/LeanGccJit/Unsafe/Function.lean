import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_function"]
opaque Context.newFunction (ctx : @& Context) (location : @& Option Location) (kind : @& FunctionKind) (retType : @& JitType) (name : @& String) (params : @& Array Param) (isVariadic : @& Bool) : IO Func

@[extern "lean_gcc_jit_context_get_builtin_function"]
opaque Context.getBuiltinFunction (ctx : @& Context) (name : @& String) : IO Func

@[extern "lean_gcc_jit_function_as_object"]
opaque Func.asObject (f : @& Func) : IO Object

@[extern "lean_gcc_jit_function_get_param"]
opaque Func.getParam (f : @& Func) (i : @& Nat) : IO Param

@[extern "lean_gcc_jit_function_dump_to_dot"]
opaque Func.dumpToDot (f : @& Func) (path : @& String) : IO PUnit