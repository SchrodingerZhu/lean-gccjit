import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
This module contains methods related to `LeanGccJit.Core.Context`. `Context` is similar to
the `Module` in LLVM. It is the main entry point for creating and compiling code.

See descriptions at `LeanGccJit.Core.Context` for details. Or, one can also take a look at
the [C API documentation](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html).

## About Options

Options present in the initial release of libgccjit were handled using enums, 
whereas those added subsequently have their own per-option API entrypoints.
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

/--
Set a string option. See `LeanGccJit.Core.StrOption` for a list of options and their meanings.
-/
@[extern "lean_gcc_jit_context_set_str_option"]
opaque Context.setStrOption : @& Context → @& StrOption → @& Option String → IO PUnit

/--
Set an integer option. See `LeanGccJit.Core.IntOption` for a list of options and their meanings.
-/
@[extern "lean_gcc_jit_context_set_int_option"]
opaque Context.setIntOption : @& Context → @& IntOption → @& Int → IO PUnit

/--
Set a boolean option. See `LeanGccJit.Core.BoolOption` for a list of options and their meanings.
-/
@[extern "lean_gcc_jit_context_set_bool_option"]
opaque Context.setBoolOption : @& Context → @& BoolOption → @& Bool → IO PUnit

/--
By default, libgccjit will issue an error about unreachable blocks within a function.
This entrypoint can be used to disable that error.
-/
@[extern "lean_gcc_jit_context_set_bool_allow_unreachable_blocks"]
opaque Context.setBoolAllowUnreachableBlocks : @& Context → @& Bool → IO PUnit

/--
By default, libgccjit will print errors to stderr.

This entrypoint can be used to disable the printing.
-/
@[extern "lean_gcc_jit_context_set_bool_print_errors_to_stderr"]
opaque Context.setBoolPrintErrorsToStderr : @& Context → @& Bool → IO PUnit

/--
libgccjit internally generates assembler, and uses "driver" code for converting it to other formats (e.g. shared libraries).

By default, libgccjit will use an embedded copy of the driver code.

This option can be used to instead invoke an external driver executable as a subprocess.
-/
@[extern "lean_gcc_jit_context_set_bool_use_external_driver"]
opaque Context.setBoolUseExtenalDriver: @& Context → @& Bool → IO PUnit

/--
Add an arbitrary gcc command-line option to the context, for use by `Context.compile` and `Context.compileToFile`.

Extra options added by this function are applied after the regular options above, potentially overriding them. 
Options from parent contexts are inherited by child contexts; options from the parent are applied before those from the child.

For example:
```lean4
ctx.addCommandLineOption "-ffast-math"
ctx.addCommandLineOption "-fverbose-asm"
```
Note that only some options are likely to be meaningful; there is no "frontend" within libgccjit, so typically only those affecting 
optimization and code-generation are likely to be useful.
-/
@[extern "lean_gcc_jit_context_add_command_line_option"]
opaque Context.addCommandLineOption: @& Context → @& String → IO PUnit

/--
Add an arbitrary gcc driver option to the context, for use by `Context.compile` and `Context.compileToFile`.

Extra options added by this function are applied after all other options potentially overriding them. 
Options from parent contexts are inherited by child contexts; options from the parent are applied before those from the child.
For example:
```lean4
ctx.addDriverOption "-lm"
ctx.addDriverOption "-fuse-linker-plugin"
ctx.addDriverOption "obj.o"
ctx.addDriverOption "-L."
```
Note that only some options are likely to be meaningful; there is no “frontend” within libgccjit, 
so typically only those affecting assembler and linker are likely to be useful.
-/
@[extern "lean_gcc_jit_context_add_driver_option"]
opaque Context.addDriverOption: @& Context → @& String → IO PUnit

/--
Compile the `Context` to a file of the given kind. 
See `LeanGccJit.Core.OutputKind` for a list of options and their meanings.
-/
@[extern "lean_gcc_jit_context_compile_to_file"]
opaque Context.compileToFile: @& Context → @& OutputKind → @& String → IO PUnit

/--
To help with debugging: dump a C-like representation to the given path, describing what’s been 
set up on the context.

If `updateLoc` is true, then also set up `Location` information throughout the context, pointing at the 
dump file as if it were a source file. This may be of use in conjunction with `LeanGccJit.Core.BoolOption.DebugInfo` 
to allow stepping through the code in a debugger.
-/
@[extern "lean_gcc_jit_context_dump_to_file"]
opaque Context.dumpToFile
  (ctx: @& Context) (path: @& String) (updateLoc: @& Bool) : IO PUnit

/--
To help with debugging; enable ongoing logging of the `Context`’s activity to the given file.

Examples of information logged include:
- API calls
- the various steps involved within compilation
- activity on any gcc_jit_result instances created by the context
- activity within any child contexts

The caller remains responsible for closing logfile, and it must not be closed until all users are released. 
In particular, note that child `Context`s and `Result` instances created by the context will use the logfile.

There may a performance cost for logging.

You can turn off logging on `Context` by passing `none` for logfile. 
Doing so only affects the context; it does not affect child contexts or `Result` instances already created by the context.

The parameters `flags` and `verbosity` are reserved for future expansion, and must be zero for now.
-/
@[extern "lean_gcc_jit_context_set_logfile"]
opaque Context.setLogFile
  (ctx: @& Context) (handle: @& Option IO.FS.Handle) (flags: @& Int) (verbosity: @& Int) : IO PUnit

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

/--
Write C source code into path that can be compiled into a self-contained executable (i.e. with libgccjit as the only dependency). 
The generated code will attempt to replay the API calls that have been made into the given `Context`.

This may be useful when debugging the library or client code, for reducing a complicated recipe for reproducing a bug 
into a simpler form. For example, consider client code that parses some source file into some internal representation, 
and then walks this IR, calling into libgccjit. If this encounters a bug, a call to this function will write out C code 
for a much simpler executable that performs the equivalent calls into libgccjit, without needing the client code and its data.

Typically you need to supply `-Wno-unused-variable` when compiling the generated file 
(since the result of each API call is assigned to a unique variable within the generated C source, 
and not all are necessarily then used).
-/
@[extern "lean_gcc_jit_context_dump_reproducer_to_file"]
opaque Context.dumpReproducerToFile: @& Context → @& String → IO PUnit

/--
Enable the dumping of a specific set of internal state from the compilation, capturing the result in-memory as a buffer.

Parameter "dumpName" corresponds to the equivalent gcc command-line option, without the “-fdump-” prefix. For example, to get the equivalent of `-fdump-tree-vrp1`, supply "tree-vrp1":
```lean4
let buf ← DynamicBuffer.acquire
ctx.registerDumpBuffer "tree-vrp1" buf
```
After compilation, one can then read the contents of the buffer to a string:
```lean4
let str ← buf.getString
buf.releaseInner -- free the buffer
```
See documents of `LeanGccJit.Core.DynamicBuffer` for more details.
-/
@[extern "lean_gcc_jit_context_register_dump_buffer"]
opaque Context.registerDumpBuffer
   (ctx: @& Context) (dumpName: @& String) (buf: @& DynamicBuffer) : IO PUnit