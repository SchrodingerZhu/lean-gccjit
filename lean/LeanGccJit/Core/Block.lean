import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

@[extern "lean_gcc_jit_function_new_block"]
opaque Func.newBlock (func : @& Func) (name: @& Option String) : IO Block

@[extern "lean_gcc_jit_block_as_object"]
opaque Block.asObject (block : @& Block) : IO Object

@[extern "lean_gcc_jit_block_get_function"]
opaque Block.getFunction (block : @& Block) : IO Func

@[extern "lean_gcc_jit_block_add_eval"]
opaque Block.addEval (block : @& Block) (loc: @& Option Location) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_add_assignment"]
opaque Block.addAssignment (block : @& Block) (loc: @& Option Location) (lval : @& LValue) (rval : @& RValue) : IO PUnit

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