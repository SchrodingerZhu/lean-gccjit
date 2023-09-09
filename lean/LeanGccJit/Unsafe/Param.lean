import LeanGccJit.Unsafe.Types
namespace LeanGccJit
namespace Unsafe

@[extern "lean_gcc_jit_context_new_param"]
opaque Context.newParam (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (name : @& String) : IO Param

@[extern "lean_gcc_jit_param_as_object"]
opaque Param.asObject (param : @& Param) : IO Object

@[extern "lean_gcc_jit_param_as_lvalue"]
opaque Param.asLValue (param : @& Param) : IO LValue

@[extern "lean_gcc_jit_param_as_rvalue"]
opaque Param.asRValue (param : @& Param) : IO RValue