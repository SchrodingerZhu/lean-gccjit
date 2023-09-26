import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
`Location` is used to provide source information for debugging.

See the documentation of `LeanGccJit.Core.Location` for more information. 

See also the [C API documentation](https://gcc.gnu.org/onlinedocs/jit/topics/locations.html).
-/

/-- Create a `Location` instance representing the given source location. -/
@[extern "lean_gcc_jit_context_new_location"]
opaque Context.newLocation (ctx : @& Context) (file : @& String) (line : @& Nat) (column : @& Nat) : IO Location

/-- Upcast a `Location` to an `Object`. -/
@[extern "lean_gcc_jit_location_as_object"]
opaque Location.asObject (loc : @& Location) : IO Object