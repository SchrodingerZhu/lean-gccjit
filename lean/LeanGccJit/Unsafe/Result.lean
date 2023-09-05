@[extern "lean_gcc_jit_result_get_code"]
opaque Result.getCode: @Result → @String → USize

@[extern "lean_gcc_jit_result_get_global"]
opaque Result.getGlobal: @Result → @String → USize

@[extern "lean_gcc_jit_context_compile"]
opaque Result.release: Result → IO PUnit