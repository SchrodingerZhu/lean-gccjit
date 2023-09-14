import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

@[extern "lean_gcc_jit_timer_new"]
opaque Timer.new : IO Timer

@[extern "lean_gcc_jit_timer_release"]
opaque Timer.release : (@& Timer) → IO PUnit

@[extern "lean_gcc_jit_context_set_timer"]
opaque Context.setTimer (ctx : @& Context) (timer : @& Timer) : IO PUnit

@[extern "lean_gcc_jit_context_get_timer"]
opaque Context.getTimer (ctx : @& Context) : IO (Option Timer)

@[extern "lean_gcc_jit_timer_push"]
opaque Timer.push (timer : @& Timer) (name: @& String) : IO PUnit

@[extern "lean_gcc_jit_timer_pop"]
opaque Timer.pop (timer : @& Timer) (name: @& String) : IO PUnit

@[extern "lean_gcc_jit_timer_print"]
opaque Timer.print (timer : @& Timer) (handle: @& IO.FS.Handle) : IO PUnit

