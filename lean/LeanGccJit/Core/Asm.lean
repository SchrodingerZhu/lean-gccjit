import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

@[extern "lean_gcc_jit_block_add_extended_asm"]
opaque Block.addExtendedAsm 
  (block : @& Block) (loc : @& Option Location) (asmTemplate : @& String) : IO PUnit

@[extern "lean_gcc_jit_extended_asm_as_object"]
opaque ExtendedAsm.asObject (asm : @& ExtendedAsm) : IO Object

@[extern "lean_gcc_jit_extended_asm_set_volatile_flag"]
opaque ExtendedAsm.setVolatileFlag (asm : @& ExtendedAsm) (isVolatile : Bool) : IO PUnit

@[extern "lean_gcc_jit_extended_asm_set_inline_flag"]
opaque ExtendedAsm.setInlineFlag (asm : @& ExtendedAsm) (isInline : Bool) : IO PUnit

@[extern "lean_gcc_jit_extended_asm_add_output_operand"]
opaque ExtendedAsm.addOutputOperand 
  (asm : @& ExtendedAsm) 
  (symbolicName : @& Option String)
  (constraint : @& String)
  (dest : @& LValue) : IO PUnit


@[extern "lean_gcc_jit_extended_asm_add_input_operand"]
opaque ExtendedAsm.addInputOperand 
  (asm : @& ExtendedAsm) 
  (symbolicName : @& Option String)
  (constraint : @& String)
  (src : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_extended_asm_add_clobber"]
opaque ExtendedAsm.addClobber 
  (asm : @& ExtendedAsm) 
  (clobber : @& String) : IO PUnit