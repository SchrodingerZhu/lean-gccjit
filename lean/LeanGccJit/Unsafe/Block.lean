import LeanGccJit.Types

@[extern "lean_gcc_jit_function_new_block"]
opaque Func.newBlock (func : @& Func) : IO Block

@[extern "lean_gcc_jit_block_as_object"]
opaque Block.asObject (block : @& Block) : IO Object

@[extern "lean_gcc_jit_block_get_function"]
opaque Block.getFunction (block : @& Block) : IO Func
