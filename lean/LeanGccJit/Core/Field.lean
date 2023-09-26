import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
`Field` is a member of a `Struct` or `Union`. It is used when creating a `Struct` or `Union` 
and accessing its members.

See documentation of `LeanGccJit.Core.Field`, 
and the [C API documentation](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#structures-and-unions) for `gcc_jit_field`.
-/

/-- Construct a new field, with the given type and name. -/
@[extern "lean_gcc_jit_context_new_field"]
opaque Context.newField
  (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (name : @& String) : IO Field
/--
Construct a new bit field, with the given type width and name.
## Note
The parameter width must be a positive integer that does not exceed the size of type.
-/
@[extern "lean_gcc_jit_context_new_bitfield"]
opaque Context.newBitField
  (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (width: @Nat) (name : @& String): IO Field
/-- Upcast from field to object. -/
@[extern "lean_gcc_jit_field_as_object"]
opaque Field.asObject (field : @& Field) : IO Object