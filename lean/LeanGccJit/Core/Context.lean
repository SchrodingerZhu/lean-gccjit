import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
This module contains methods related to `LeanGccJit.Core.Context`. `Context` is similar to
the `Module` in LLVM. It is the main entry point for creating and compiling code.

See descriptions at `LeanGccJit.Core.Context` for details. Or, one can also take a look at
the [C API documentation](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html).
-/

/--
This function acquires a new `Context` instance, 
which is independent of any others that may be present within this process.
-/
@[extern "lean_gcc_jit_context_acquire"]
opaque Context.acquire : IO Context

/--
This function releases all resources associated with the given `Context`. 
Both the `Context` itself and all of its `Object` instances are cleaned up. 
It should be called exactly once on a given `Context`.

It is invalid to use the `Context` or any of its "contextual" `Object`s after calling this.
-/
@[extern "lean_gcc_jit_context_release"]
opaque Context.release : Context → IO PUnit


@[extern "lean_gcc_jit_context_set_str_option"]
opaque Context.setStrOption : @& Context → @& StrOption → @& Option String → IO PUnit

@[extern "lean_gcc_jit_context_set_int_option"]
opaque Context.setIntOption : @& Context → @& IntOption → @& Int → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_option"]
opaque Context.setBoolOption : @& Context → @& BoolOption → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_allow_unreachable_blocks"]
opaque Context.setBoolAllowUnreachableBlocks : @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_print_errors_to_stderr"]
opaque Context.setBoolPrintErrorsToStderr : @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_use_external_driver"]
opaque Context.setBoolUseExtenalDriver: @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_add_command_line_option"]
opaque Context.addCommandLineOption: @& Context → @& String → IO PUnit

@[extern "lean_gcc_jit_context_add_driver_option"]
opaque Context.addDriverOption: @& Context → @& String → IO PUnit

@[extern "lean_gcc_jit_context_compile_to_file"]
opaque Context.compileToFile: @& Context → @& OutputKind → @& String → IO PUnit

@[extern "lean_gcc_jit_context_dump_to_file"]
opaque Context.dumpToFile: @& Context → @& String→ @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_logfile"]
opaque Context.setLogFile: @& Context → @& IO.FS.Handle → @& Int → @& Int → IO PUnit

/--
Returns the first error message that occurred on the context.
If no errors occurred, this will be none.
-/
@[extern "lean_gcc_jit_context_get_first_error"]
opaque Context.getFirstError: @& Context → IO (Option String)

/--
Returns the last error message that occurred on the context.
If no errors occurred, this will be none.

In this lean package, errors (typically `NULL` return values) can handled as `IO` exceptions
and sealed into the `IO` monad. Once an error is thrown, this function can be used to get the 
error message when you are handling the `IO` effects.
-/
@[extern "lean_gcc_jit_context_get_last_error"]
opaque Context.getLastError: @& Context → IO (Option String)

/--
Given an existing JIT `Context`, create a child `Context`.

The child inherits a copy of all option-settings from the parent.

The child can reference objects created within the parent, but not vice-versa.

The lifetime of the child `Context` must be bounded by that of the parent: 
you should release a child `Context` before releasing the parent context.

If you use a function from a parent `Context` within a child `Context`, 
you have to compile the parent `Context` before you can compile the child `Context`, 
and the `Result` of the parent `Context` must outlive the `Result` of the child `Context`.

This allows caching of shared initializations. 
For example, you could create types and declarations of global functions in a parent `Context` 
once within a process, and then create child `Context`s whenever a function or loop becomes hot. 
Each such child `Context` can be used for JIT-compiling just one function or loop, but can reference 
types and helper functions created within the parent `Context`.

`Context`s can be arbitrarily nested, provided the above rules are followed, 
but it’s probably not worth going above 2 or 3 levels, and there will likely be a performance hit 
for such nesting.
-/
@[extern "lean_gcc_jit_context_new_child_context"]
opaque Context.newChildContext: @& Context → IO Context

@[extern "lean_gcc_jit_context_dump_reproducer_to_file"]
opaque Context.dumpReproducerToFile: @& Context → @& String → IO PUnit

@[extern "lean_gcc_jit_context_register_dump_buffer"]
opaque Context.registerDumpBuffer: @& Context → @& String → @& DynamicBuffer → IO PUnit