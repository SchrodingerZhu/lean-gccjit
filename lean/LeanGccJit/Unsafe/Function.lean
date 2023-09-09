import LeanGccJit.Unsafe.Types
namespace LeanGccJit
namespace Unsafe

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

@[extern "lean_gcc_jit_function_get_address"]
opaque Func.getAddress (f : @& Func) (loc: @& Option Location) : IO RValue

@[extern "lean_gcc_jit_function_get_return_type"]
opaque Func.getReturnType (f : @& Func) : IO JitType

@[extern "lean_gcc_jit_function_get_param_count"]
opaque Func.getParamCount (f : @& Func) : IO Nat