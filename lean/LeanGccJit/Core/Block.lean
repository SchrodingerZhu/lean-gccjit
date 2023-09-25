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

/--
Add a no-op textual comment to the internal representation of the code. 

It will be optimized away, but will be visible in the dumps seen via 
`BoolOption.DumpInitialTree` and `BoolOption.DumpInitialGimple`, 
and thus may be of use when debugging how your project’s internal representation 
gets converted to the libgccjit IR.
-/
@[extern "lean_gcc_jit_block_add_comment"]
opaque Block.addComment (block : @& Block) (loc: @& Option Location) (comment : @& String) : IO PUnit

/--
Terminate a block by adding evaluation of an rvalue, branching on the result to 
the appropriate successor block.

This is roughly equivalent to this C code:
```c
if (bval)
  goto on_true;
else
  goto on_false;
```
-/
@[extern "lean_gcc_jit_block_end_with_conditional"]
opaque Block.endWithConditional (block : @& Block) (loc: @& Option Location) (bval : @& RValue) (onTrue : @& Block) (onFalse : @& Block) : IO PUnit

/--
Terminate a block by adding a jump to the given target block.

This is roughly equivalent to this C code:
```c
goto target;
```
-/
@[extern "lean_gcc_jit_block_end_with_jump"]
opaque Block.endWithJump (block : @& Block) (loc: @& Option Location) (dest : @& Block) : IO PUnit

/--
Terminate a block by adding evaluation of an rvalue, returning the value.

This is roughly equivalent to this C code:
```c
return expression;
```
-/
@[extern "lean_gcc_jit_block_end_with_return"]
opaque Block.endWithReturn (block : @& Block) (loc: @& Option Location) (rval : @& RValue) : IO PUnit

/--
Terminate a block by adding a valueless return, for use within a function with `void` return type.

This is equivalent to this C code:

```c
return;
```
-/
@[extern "lean_gcc_jit_block_end_with_void_return"]
opaque Block.endWithVoidReturn (block : @& Block) (loc: @& Option Location) : IO PUnit

/--
Terminate a block by adding evalation of an rvalue, then performing a multiway branch.

This is roughly equivalent to this C code:

```c
switch (expr)
  {
  default:
    goto default_block;

  case C0.min_value ... C0.max_value:
    goto C0.dest_block;

  case C1.min_value ... C1.max_value:
    goto C1.dest_block;

  /*...etc...*/

  case C[N - 1].min_value ... C[N - 1].max_value:
    goto C[N - 1].dest_block;
}
```
## Note
- `expr` must be of the same integer type as all of the `min_value` and `max_value` within the cases.
- The ranges of the `cases` must not overlap (or have duplicate values).
-/
@[extern "lean_gcc_jit_block_end_with_switch"]
opaque Block.endWithSwitch 
  (block : @& Block) (loc: @& Option Location) (expr : @& RValue) (defaultBlock : @& Block) (cases : @& Array Case) : IO PUnit

/--
Create an `ExtendedAsm` for an extended asm statement that may perform jumps, and use it to terminate 
the given block. This is equivalent to the `goto` qualifier in C’s extended asm syntax.

## Note
- `fallthrough` can be `none`. If it is `some`, it specifies the block to fall through to after the statement.
- This is needed since each `Block` must have a single exit point, as a basic block: 
  you can’t jump from the middle of a block. 
- A `goto` is implicitly added after the asm to handle the fallthrough case, which is equivalent to what would have 
  happened in the C case.
-/
@[extern "lean_gcc_jit_block_end_with_extended_asm_goto"]
opaque Block.endWithExtendedAsmGoto 
  (block : @& Block) 
  (loc: @& Option Location)
  (asmString : @& String)
  (gotoBlocks : @& Array Block) 
  (fallthrough : @& Option Block) : IO ExtendedAsm