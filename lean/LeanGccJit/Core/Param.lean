import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/-!
`Param` is to be used for function construction. 

See also:
- [C API reference](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#c.gcc_jit_param)
- `LeanGccJit.Core.Param`
-/

/--
In preparation for creating a function, create a new parameter of the given type and name.

The parameter type must be non-void.
-/
@[extern "lean_gcc_jit_context_new_param"]
opaque Context.newParam (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (name : @& String) : IO Param

/--
Upcast a `Param` to an `Object`.
-/
@[extern "lean_gcc_jit_param_as_object"]
opaque Param.asObject (param : @& Param) : IO Object

/--
Upcast a `Param` to an `LValue`.
-/
@[extern "lean_gcc_jit_param_as_lvalue"]
opaque Param.asLValue (param : @& Param) : IO LValue

/--
Upcast a `Param` to a `RValue`.
-/
@[extern "lean_gcc_jit_param_as_rvalue"]
opaque Param.asRValue (param : @& Param) : IO RValue