import LeanGccJit.Types

@[extern "lean_gcc_jit_function_new_block"]
opaque Func.newBlock (func : @& Func) (name: @& String) : IO Block

@[extern "lean_gcc_jit_block_as_object"]
opaque Block.asObject (block : @& Block) : IO Object

@[extern "lean_gcc_jit_block_get_function"]
opaque Block.getFunction (block : @& Block) : IO Func

@[extern "lean_gcc_jit_block_add_eval"]
opaque Block.addEval (block : @& Block) (loc: @& Location) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_add_assignment"]
opaque Block.addAssignment (block : @& Block) (loc: @& Location) (lval : @& LValue) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_add_assignment_op"]
opaque Block.addAssignmentOp (block : @& Block) (loc: @& Location) (lval : @& LValue) (op : @& BinaryOp) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_add_comment"]
opaque Block.addComment (block : @& Block) (loc: @& Location) (comment : @& String) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_conditional"]
opaque Block.endWithConditional (block : @& Block) (loc: @& Location) (bval : @& RValue) (onTrue : @& Block) (onFalse : @& Block) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_jump"]
opaque Block.endWithJump (block : @& Block) (loc: @& Location) (dest : @& Block) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_return"]
opaque Block.endWithReturn (block : @& Block) (loc: @& Location) (rval : @& RValue) : IO PUnit

@[extern "lean_gcc_jit_block_end_with_void_return"]
opaque Block.endWithVoidReturn (block : @& Block) (loc: @& Location) : IO PUnit
