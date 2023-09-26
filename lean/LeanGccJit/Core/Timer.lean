import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/-!
As of GCC 6, libgccjit exposes a timing API, 
for printing reports on how long was spent in different parts of code.

You can create a `Timer` instance, which will measure time spent since its creation. 
The timer maintains a stack of `timer items`: as control flow moves through your code, 
you can push and pop named items relating to your code onto the stack, 
and the timer will account the time spent accordingly.

You can also asssociate a timer with a `Context`, in which case the time spent inside 
compilation will be subdivided.

For example:
```
  let timer ← Timer.new
  ctx.setTimer timer
  timer.push "test"
  -- do some work
  IO.FS.withFile "/tmp/test.timer" IO.FS.Mode.write fun h => do
    timer.print h
  timer.release
```
This will gives you something like:
```
Execution times (seconds)
GCC items:
 phase setup             :   0.29 (14%) usr   0.00 ( 0%) sys   0.32 ( 5%) wall   10661 kB (50%) ggc
 phase parsing           :   0.02 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall     653 kB ( 3%) ggc
 phase finalize          :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
 dump files              :   0.02 ( 1%) usr   0.00 ( 0%) sys   0.01 ( 0%) wall       0 kB ( 0%) ggc
 callgraph construction  :   0.02 ( 1%) usr   0.01 ( 6%) sys   0.01 ( 0%) wall     242 kB ( 1%) ggc
 callgraph optimization  :   0.03 ( 2%) usr   0.00 ( 0%) sys   0.02 ( 0%) wall     142 kB ( 1%) ggc
 trivially dead code     :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
 df scan insns           :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       9 kB ( 0%) ggc
 df live regs            :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.01 ( 0%) wall       0 kB ( 0%) ggc
 inline parameters       :   0.02 ( 1%) usr   0.00 ( 0%) sys   0.01 ( 0%) wall      82 kB ( 0%) ggc
 tree CFG cleanup        :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
 tree PHI insertion      :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.02 ( 0%) wall      64 kB ( 0%) ggc
 tree SSA other          :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.01 ( 0%) wall      18 kB ( 0%) ggc
 expand                  :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall     398 kB ( 2%) ggc
 jump                    :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
 loop init               :   0.01 ( 0%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall      67 kB ( 0%) ggc
 integrated RA           :   0.02 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall    2468 kB (12%) ggc
 thread pro- & epilogue  :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall     162 kB ( 1%) ggc
 final                   :   0.01 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall     216 kB ( 1%) ggc
 rest of compilation     :   1.37 (69%) usr   0.00 ( 0%) sys   1.13 (18%) wall    1391 kB ( 6%) ggc
 assemble JIT code       :   0.01 ( 1%) usr   0.00 ( 0%) sys   4.04 (66%) wall       0 kB ( 0%) ggc
 load JIT result         :   0.02 ( 1%) usr   0.00 ( 0%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
 JIT client code         :   0.00 ( 0%) usr   0.01 ( 6%) sys   0.00 ( 0%) wall       0 kB ( 0%) ggc
Client items:
 test                    :   0.00 ( 0%) usr   0.01 ( 6%) sys   0.00 ( 0%) wall   14939 kB ( 0%) ggc
 TOTAL                   :   2.00             0.18             6.12              21444 kB
```
-/
/--
Create a `Timer` instance, and start timing:
-/
@[extern "lean_gcc_jit_timer_new"]
opaque Timer.new : IO Timer
/--
Release a `Timer` instance.

This should be called exactly once on a timer.
-/
@[extern "lean_gcc_jit_timer_release"]
opaque Timer.release : (@& Timer) → IO PUnit

/--
Associate a `Timer` instance with a `Context`.

A timer instance can be shared between multiple gcc_jit_context instances.

Timers have no locking, so if you have a multithreaded program, 
you must provide your own locks if more than one thread could be working with the same timer 
via timer-associated contexts.
-/
@[extern "lean_gcc_jit_context_set_timer"]
opaque Context.setTimer (ctx : @& Context) (timer : @& Timer) : IO PUnit

/--
Get the timer associated with a context (if any).
-/
@[extern "lean_gcc_jit_context_get_timer"]
opaque Context.getTimer (ctx : @& Context) : IO (Option Timer)

/--
Push the given item onto the timer’s stack.
-/
@[extern "lean_gcc_jit_timer_push"]
opaque Timer.push (timer : @& Timer) (name: @& String) : IO PUnit

/--
Pop the top item from the timer’s stack.

If `name` is provided, it must match that of the top item. 
Alternatively, `none` can be passed in, to suppress checking.
-/
@[extern "lean_gcc_jit_timer_pop"]
opaque Timer.pop (timer : @& Timer) (name: @& Option String) : IO PUnit

/--
Print timing information to the given stream about activity since the timer was started.
-/
@[extern "lean_gcc_jit_timer_print"]
opaque Timer.print (timer : @& Timer) (handle: @& IO.FS.Handle) : IO PUnit

