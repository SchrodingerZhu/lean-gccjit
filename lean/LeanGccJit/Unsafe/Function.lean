import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_function"]
opaque Context.newFunction
  (ctx : @& Context)
  (location : @& Location)
  (kind : @& FunctionKind)
  (retType : @& JitType)
  (name : @& String)
  (params : @& Array Param)
  (isVariadic : @& Bool)
  : IO Function

@[extern "lean_gcc_jit_context_get_builtin_function"]
opaque Context.getBuiltinFunction (ctx : @& Context) (name : @& String) : IO Function

@[extern "lean_gcc_jit_function_as_object"]
opaque Function.asObject (f : @& Function) : IO Object