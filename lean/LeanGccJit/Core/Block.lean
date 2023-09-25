import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/--
Create a basic block of the given name. 

The name may be `none`, but providing meaningful names is often helpful 
when debugging: it may show up in dumps of the internal representation, 
and in error messages.
-/
@[extern "lean_gcc_jit_function_new_block"]
opaque Func.newBlock (func : @& Func) (name: @& Option String) : IO Block

/-- Upcast from block to object. -/
@[extern "lean_gcc_jit_block_as_object"]
opaque Block.asObject (block : @& Block) : IO Object

/-- Get the associated `Func` of the `Block` -/
@[extern "lean_gcc_jit_block_get_function"]
opaque Block.getFunction (block : @& Block) : IO Func

/--
Add evaluation of an rvalue, discarding the result (e.g. a function call that “returns” void).

This is equivalent to this C code:
```c
(void)rvalue;
```
 -/
@[extern "lean_gcc_jit_block_add_eval"]
opaque Block.addEval (block : @& Block) (loc: @& Option Location) (rval : @& RValue) : IO PUnit

/--
Add evaluation of an rvalue, assigning the result to the given lvalue.

This is roughly equivalent to this C code:
```c
lvalue = rvalue;
```
-/
@[extern "lean_gcc_jit_block_add_assignment"]
opaque Block.addAssignment (block : @& Block) (loc: @& Option Location) (lval : @& LValue) (rval : @& RValue) : IO PUnit

/--
Add evaluation of an rvalue, using the result to modify an lvalue.

This is analogous to `+=` and friends:
```c
lvalue += rvalue;
lvalue *= rvalue;
lvalue /= rvalues
// ...
```
-/
@[extern "lean_gcc_jit_block_add_assignment_op"]
opaque Block.addAssignmentOp (block : @& Block) (loc: @& Option Location) (lval : @& LValue) (op : @& BinaryOp) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_add_comment"]
opaque Block.addComment (block : @& Block) (loc: @& Option Location) (comment : @& String) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_conditional"]
opaque Block.endWithConditional (block : @& Block) (loc: @& Option Location) (bval : @& RValue) (onTrue : @& Block) (onFalse : @& Block) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_jump"]
opaque Block.endWithJump (block : @& Block) (loc: @& Option Location) (dest : @& Block) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_return"]
opaque Block.endWithReturn (block : @& Block) (loc: @& Option Location) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_void_return"]
opaque Block.endWithVoidReturn (block : @& Block) (loc: @& Option Location) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_switch"]
opaque Block.endWithSwitch 
  (block : @& Block) (loc: @& Option Location) (expr : @& RValue) (defaultBlock : @& Block) (cases : @& Array Case) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_extended_asm_goto"]
opaque Block.endWithExtendedAsmGoto 
  (block : @& Block) 
  (loc: @& Option Location)
  (asmString : @& String)
  (gotoBlocks : @& Array Block) 
  (fallthrough : @& Block) : IO ExtendedAsm