import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/-!
`Func` represents a function in the JIT context. It is either created inside the context or imported.

See documentation of `LeanGccJit.Core.Func`,
or the [C API reference](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#creating-and-using-functions).
-/

/--
Create a gcc_jit_function with the given name and parameters.
`LeanGccJit.Core.FunctionKind` specifies the kind of function created.
-/
@[extern "lean_gcc_jit_context_new_function"]
opaque Context.newFunction (ctx : @& Context) (location : @& Option Location) (kind : @& FunctionKind) (retType : @& JitType) (name : @& String) (params : @& Array Param) (isVariadic : @& Bool) : IO Func
/--
Get the `Func` for the built-in function with the given name. For example:
```
let bMemcpy ← ctx.getBuiltinFunction "__builtin_memcpy"
```
-/
@[extern "lean_gcc_jit_context_get_builtin_function"]
opaque Context.getBuiltinFunction (ctx : @& Context) (name : @& String) : IO Func

/--
Upcasting from `Func` to `Object`.
-/
@[extern "lean_gcc_jit_function_as_object"]
opaque Func.asObject (f : @& Func) : IO Object
/--
Get the `Param` of the given index (0-based).
-/
@[extern "lean_gcc_jit_function_get_param"]
opaque Func.getParam (f : @& Func) (i : @& Nat) : IO Param
/--
Emit the `Func` in graphviz format to the given path.
-/
@[extern "lean_gcc_jit_function_dump_to_dot"]
opaque Func.dumpToDot (f : @& Func) (path : @& String) : IO PUnit

/--
Get the address of a function as an `RValue`, of function pointer type.

## Note
You can generate calls that use a function pointer via `LeanGccJit.Core.Context.newCallThroughPtr`,
which requires a `LeanGccJit.Core.RValue` containing the address of the function.
`Func.getAddress` is one way to obtain such a `LeanGccJit.Core.RValue`.
-/
@[extern "lean_gcc_jit_function_get_address"]
opaque Func.getAddress (f : @& Func) (loc: @& Option Location) : IO RValue

/--
Get the return type of the `Func`.
-/
@[extern "lean_gcc_jit_function_get_return_type"]
opaque Func.getReturnType (f : @& Func) : IO JitType

/--
Get the number of parameters of the `Func`.
-/
@[extern "lean_gcc_jit_function_get_param_count"]
opaque Func.getParamCount (f : @& Func) : IO Nat