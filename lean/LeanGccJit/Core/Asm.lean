import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/-!
`libgccjit` has some support for directly embedding assembler instructions. 

This is based on GCC’s support for `inline asm` in `C` code, and the following assumes a 
familiarity with that functionality. See 
[How to Use Inline Assembly Language in C Code](https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html) in 
GCC’s documentation, the ["Extended Asm"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html) section in particular.

Please see also:
- Descriptions of `LeanGccJit.Core.ExtendedAsm` in this documentation.
- Section ["Using Assembly Language with libgccjit"](https://gcc.gnu.org/onlinedocs/jit/topics/asm.html) from `libgccjit`’s documentation.
-/

/--
Create an `ExtendedAsm` for an extended asm statement with no control flow (i.e. without the `goto` qualifier).
The parameter `asmTemplate` corresponds to the AssemblerTemplate within `C`’s extended asm syntax. 
-/
@[extern "lean_gcc_jit_block_add_extended_asm"]
opaque Block.addExtendedAsm 
  (block : @& Block) (loc : @& Option Location) (asmTemplate : @& String) : IO ExtendedAsm

/--
Upcast an `ExtendedAsm` to an `Object`.
-/
@[extern "lean_gcc_jit_extended_asm_as_object"]
opaque ExtendedAsm.asObject (asm : @& ExtendedAsm) : IO Object

/--
Set whether the `ExtendedAsm` has side-effects, 
equivalent to the volatile qualifier in `C`’s extended asm syntax.
-/
@[extern "lean_gcc_jit_extended_asm_set_volatile_flag"]
opaque ExtendedAsm.setVolatileFlag (asm : @& ExtendedAsm) (isVolatile : Bool) : IO PUnit

/--
Set the equivalent of the `inline` qualifier in `C`’s extended asm syntax.
-/
@[extern "lean_gcc_jit_extended_asm_set_inline_flag"]
opaque ExtendedAsm.setInlineFlag (asm : @& ExtendedAsm) (isInline : Bool) : IO PUnit

/--
Add an output operand to the extended asm statement. 
See the ["Output Operands"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#OutputOperands) 
section of the documentation of the `C` syntax.

`symbolicName` corresponds to the `asmSymbolicName` component of `C`’s extended asm syntax. It is optional. 
If value is provided, it specifies the symbolic name for the operand.

`constraint` corresponds to the `constraint` component of `C`’s extended asm syntax.

`dest` corresponds to the `cvariablename` component of `C`'s extended asm syntax.

```lean
-- Example with a NULL symbolic name, the equivalent of:
--   : "=r" (dst)
extAsm.addOutputOperand none "=r" dst
-- Example with a symbolic name ("aIndex"), the equivalent of:
--   : [aIndex] "=r" (index)
extAsm.addOutputOperand "aIndex" "=r" index
```
This function can’t be called on an asm goto as such instructions can’t have outputs; 
see the ["Goto Labels"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#GotoLabels) section of GCC’s 
["Extended Asm"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html) documentation.
-/
@[extern "lean_gcc_jit_extended_asm_add_output_operand"]
opaque ExtendedAsm.addOutputOperand 
  (asm : @& ExtendedAsm) 
  (symbolicName : @& Option String)
  (constraint : @& String)
  (dest : @& LValue) : IO PUnit

/--
Add an input operand to the extended asm statement. 
See the  ["Input Operands"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#InputOperands) section of the documentation of the `C` syntax.

`symbolicName` corresponds to the `asmSymbolicName` component of `C`’s extended asm syntax. It is optional. 
If value is provided, it specifies the symbolic name for the operand.

`constraint corresponds` to the `constraint` component of `C`’s extended asm syntax.

`src` corresponds to the `cexpression` component of `C`'s extended asm syntax.
-/
@[extern "lean_gcc_jit_extended_asm_add_input_operand"]
opaque ExtendedAsm.addInputOperand 
  (asm : @& ExtendedAsm) 
  (symbolicName : @& Option String)
  (constraint : @& String)
  (src : @& RValue) : IO PUnit
/--
Add victim to the list of registers clobbered by the extended asm statement. See the ["Clobbers and Scratch Registers"](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#Clobbers-and-Scratch-Registers)
section of the documentation of the `C` syntax.

Statements with multiple clobbers will require multiple calls, one per clobber.
-/
@[extern "lean_gcc_jit_extended_asm_add_clobber"]
opaque ExtendedAsm.addClobber 
  (asm : @& ExtendedAsm) 
  (victim : @& String) : IO PUnit