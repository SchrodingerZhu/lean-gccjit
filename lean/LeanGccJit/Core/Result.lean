import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/--
Compile the given context and load in into a binary module wrapped in a `Result`.
-/
@[extern "lean_gcc_jit_context_compile"]
opaque Context.compile: @& Context → IO Result

/--
Get the address of a function inside the compiled `Result`.
-/
@[extern "lean_gcc_jit_result_get_code"]
opaque Result.getCode: @& Result → @& String → IO USize

/-- 
Wrap a function address to a closure. The closure type is specified by user.
## Example
```lean
let func : IO Unit ← res.getFunction! "jit_entry_point" 1
```
## Safety
This function must be used with care. It is up to the user's responsibility to ensure that target function
conforms the Lean4's Uniform ABI (that is, roughly, inputs and outputs are boxed). Notice that apart from
normal function types, `IO α`, as shown in the example above, can also be used as the a closure that takes
a `RealWorld` as an input.
-/
@[extern "lean_gcc_jit_result_get_function"]
opaque Result.getFunction! {α : Type} [Nonempty α] 
 (res: @& Result) (name: @& String) (arity: @& Nat) : IO α

/--
Get the address of a global variable inside the compiled `Result`. One way to access the data
behind the address is to use some self-defined inline C code.
-/
@[extern "lean_gcc_jit_result_get_global"]
opaque Result.getGlobal: @& Result → @& String → IO USize

/--
Unload and release the memory resource associated with the compiled `Result`.
## Safety
It is up to the user's responsibility to ensure that the `Result` and also the symbols/functions inside it are not used 
after calling this function.
-/
@[extern "lean_gcc_jit_result_release"]
opaque Result.release: Result → IO PUnit