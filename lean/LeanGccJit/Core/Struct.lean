import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
`Struct` is used to construct customized composite types.

See also:
- [C API reference](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#c.gcc_jit_struct)
- `LeanGccJit.Core.Struct`
-/

/--
Construct a new struct type, with the given name and fields.
-/
@[extern "lean_gcc_jit_context_new_struct_type"]
opaque Context.newStructType
  (ctx : @& Context) (location : @& Option Location) (name : @& String) (fields : @& Array Field) : IO Struct

/--
Construct a new struct type, with the given name, but without specifying the fields. 

The fields can be omitted (in which case the size of the struct is not known), 
or later specified using `LeanGccJit.Core.Struct.setFields`.
-/
@[extern "lean_gcc_jit_context_new_opaque_struct"]
opaque Context.newOpaqueStruct
  (ctx : @& Context) (location : @& Option Location) (name : @& String) : IO Struct

/--
Upcast from `Struct` to `JitType`.
-/
@[extern "lean_gcc_jit_struct_as_type"]
opaque Struct.asJitType (s : @& Struct) : IO JitType

/--
Populate the fields of a formerly-opaque struct type.

This can only be called once on a given struct type.
-/
@[extern "lean_gcc_jit_struct_set_fields"]
opaque Struct.setFields (s : @& Struct) (location : @& Option Location) (fields : @& Array Field) : IO PUnit

/--
Get a struct field by index.
-/
@[extern "lean_gcc_jit_struct_get_field"]
opaque Struct.getField (s : @& Struct) (idx : @& Nat) : IO Field

/--
Get the number of fields in the struct.
-/
@[extern "lean_gcc_jit_struct_get_field_count"]
opaque Struct.getFieldCount (s : @& Struct) : IO Nat