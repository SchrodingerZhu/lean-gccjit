import LeanGccJit.Unsafe.Types
namespace LeanGccJit
namespace Unsafe

@[extern "lean_gcc_jit_context_new_field"]
opaque Context.newField
  (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (name : @& String) : IO Field

@[extern "lean_gcc_jit_context_new_bitfield"]
opaque Context.newBitField
  (ctx : @& Context) (location : @& Option Location) (type : @& JitType) (width: @Nat) (name : @& String): IO Field

@[extern "lean_gcc_jit_field_as_object"]
opaque Field.asObject (field : @& Field) : IO Object