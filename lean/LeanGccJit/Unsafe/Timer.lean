import LeanGccJit.Types

@[extern "lean_gcc_jit_timer_new"]
opaque Timer.new : IO Timer