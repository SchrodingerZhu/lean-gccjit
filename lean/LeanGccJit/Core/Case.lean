import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/--
Create a new `Case` instance for use in a switch statement. 

## Note
- `min_value` and `max_value` must be constants of an integer type, 
  which must match that of the expression of the switch statement.
- dest_block must be within the same function as the switch statement.
-/
@[extern "lean_gcc_jit_context_new_case"]
opaque Context.newCase (ctx : @& Context) (min: @& RValue) (max: @& RValue) (block: @& Block) : IO Case

/--
Upcast from a case to an object.
-/
@[extern "lean_gcc_jit_case_as_object"]
opaque Case.asObject (c : @& Case) : IO Object