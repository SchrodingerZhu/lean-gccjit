namespace LeanGccJit
namespace Core

opaque ContextPointed : NonemptyType
/--
`Context` is the Lean4 representation of `gcc_jit_context`.

See also [`Compilation Contexts`](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html#compilation-contexts).

## Note

The top-level of the API is the `Context` type.

A `Context` instance encapsulates the state of a compilation.

You can set up options on it, and add types, functions and code. 
Invoking `Context.compile` on it gives you a `Result`.

### Lifetime-management

Contexts are the unit of lifetime-management within the API:
objects have their lifetime bounded by the context they are created within, 
and cleanup of such objects is done for you when the context is released.

### Thread-safety

Instances of `Context` created via `Context.acquire` are independent from each other: 
only one thread may use a given context at once, but multiple threads could each have their own contexts without needing locks.

`Context`s created via `Context.newChildContext` are related to their parent context. 
They can be partitioned by their ultimate ancestor into independent “family trees”. 
Only one thread within a process may use a given “family tree” of such contexts at once, 
and if you’re using multiple threads you should provide your own locking around entire 
such context partitions.

### Error Handling
Various kinds of errors are possible when using the API, such as mismatched types in an assignment.
 You can only compile and get code from a context if no errors occur.

Errors are printed on stderr and can be queried using `Context.getFirstError`.

They typically contain the name of the API entrypoint where the error occurred, and pertinent information 
on the problem:
```bash
./buggy-program: error: gcc_jit_block_add_assignment: mismatching types: assignment to i (type: int) from "hello world" (type: const char *)
```
In general, if an error occurs when using an API entrypoint, the low-level entrypoint returns `NULL`. 
Unlike the original C-API, the lean wrapper is designed to be fast-fail, i.e. it will return an `IO` error
once a step returns `NULL`.
-/
def Context : Type := ContextPointed.type
instance : Nonempty Context := ContextPointed.property

opaque ResultPointed : NonemptyType
/--
`Result` is the Lean4 representation of `gcc_jit_result`.

See also [`gcc_jit_result`](https://gcc.gnu.org/onlinedocs/jit/topics/compilation.html#c.gcc_jit_result).

## Note

A `Result` encapsulates the result of compiling a context in-memory, and the lifetimes of any machine code 
functions or globals that are within the result.
-/
def Result : Type := ResultPointed.type
instance : Nonempty Result := ResultPointed.property

opaque ObjectPointed : NonemptyType
/--
`Object` is the Lean4 representation of `gcc_jit_object`.

See also [`Objects`](https://gcc.gnu.org/onlinedocs/jit/topics/objects.html).

## Note
Almost every entity in the API (with the exception of `Context` and `Result`) 
is a **contextual** object, thus, inherited from `Object`.

A JIT `Object`:
- is associated with a `Context`.
- is automatically cleaned up for you when its context is released so you 
  don’t need to manually track and cleanup all objects, just the contexts.

The `Object` hierarchy is as follows:
- `Object`
  - `Location`
  - `JitType`
    - `Struct`
  - `Field`
  - `Func`
  - `Block`
  - `RValue`
    - `LValue`
        - `Param`
  - `Case`
  - `ExtendedAsm`

One can upcast a derived object to its base object via APIs such as `asObject`. For convenience,
we provide an `AsObject` typeclass through which one can use common APIs for objects, e.g. 
`.getDebugString` and `getContext`.
-/
def Object : Type := ObjectPointed.type
instance : Nonempty Object := ObjectPointed.property

opaque LocationPointed : NonemptyType
/--
`Location` is the Lean4 representation of `gcc_jit_location`.
See also [`Source Localtions`](https://gcc.gnu.org/onlinedocs/jit/topics/locations.html#source-locations).
## Note
A `Location` encapsulates a source code location, so that you can (optionally) 
associate locations in your language with statements in the JIT-compiled code, 
allowing the debugger to single-step through your language.

`Location` instances are optional: it is always passed as `Option Location` 
to the APIs that use it.

You can construct them using `Context.newLocation`.

You need to enable `BoolOption.DebugInfo` on the `Context` for these locations to actually 
be usable by the debugger.
-/
def Location : Type := LocationPointed.type
instance : Nonempty Location := LocationPointed.property

opaque JitTypePointed : NonemptyType
/--
`JitType` is the Lean4 representation of `gcc_jit_type`.
See also [`Types`](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#types).
-/
def JitType : Type := JitTypePointed.type
instance : Nonempty JitType := JitTypePointed.property

opaque FunctionPointed : NonemptyType
/--
`Func` is the Lean4 representation of `gcc_jit_function`.

`Function` is a special namespace in Lean4, so we use `Func` instead.
See also [`Functions`](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#functions).
## Note
A `Func` represents a function - either one that we’re creating ourselves, or one that we’re referencing.
-/
def Func : Type := FunctionPointed.type
instance : Nonempty Func := FunctionPointed.property

opaque FunctionTypePointed : NonemptyType
/--
`FunctionType` is the Lean4 representation of `gcc_jit_function_type`.

## Note
`FunctionType` can be obtained by calling `JitType.dyncastFunction` on function pointer types.
It is typically used in reflection APIs, 
e.g. `FunctionType.getReturnType`, `FunctionType.getParamCount` and `FunctionType.getParamType`. 
-/
def FunctionType : Type := FunctionTypePointed.type
instance : Nonempty FunctionType := FunctionTypePointed.property

opaque VectorTypePointed : NonemptyType
/--
`VectorType` is the Lean4 representation of `gcc_jit_vector_type`.

It represents a simd vector type, e.g. `int __attribute__((vector_size(16)))`.

## Note
In `GCCJIT`, `JitType.getVector` is the typical way to obtain a vectorized data type. However,
that API actually returns a new `JitType`. Instead, `GCCJIT` uses `VectorType` in those reflection APIs,
namely `VectorType.getNumUnits` and `VectorType.getElementType`. For those two APIs, one can
call `JitType.dyncastVector` to obtain a `VectorType` instance first.
-/
def VectorType : Type := VectorTypePointed.type
instance : Nonempty VectorType := VectorTypePointed.property

opaque StructPointed : NonemptyType
/--
`Struct` is the Lean4 representation of `gcc_jit_struct`.
See also [`gcc_jit_struct`](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#c.gcc_jit_struct).
## Note
A `Struct` represents a compound type analagous to a `C` struct.

A `Struct` can be created in mainly two ways:
- `Context.newStruct` creates a new `Struct` with given fields. 
- `Context.newOpaqueStruct` creates a new opaque `Struct` with given name. 
  The fields of the `Struct` can be added later using `Struct.setFields`.

Notice that once fields are set, the struct cannot be changed anymore.
-/
def Struct : Type := StructPointed.type
instance : Nonempty Struct := StructPointed.property

opaque FieldPointed : NonemptyType
/--
`Field` is the Lean4 representation of `gcc_jit_field`.
See also [`gcc_jit_field`](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#c.gcc_jit_field).
## Note
A `Field` is used to refer a member of a `Struct` type.
-/
def Field : Type := FieldPointed.type
instance : Nonempty Field := FieldPointed.property

opaque BlockPointed : NonemptyType
/--
`Block` is the Lean4 representation of `gcc_jit_block`.
See also [Blocks](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#blocks).
## Note
A `Block` represents a basic block within a function 
i.e. a sequence of statements with a single entry point and a single exit point.

The first basic block that you create within a function will be the entrypoint.

Each basic block that you create within a function **MUST** be terminated,
either with a conditional, a jump, a return, a switch, or an asm goto.

It’s legal to have multiple basic blocks that return within one function.
-/
def Block : Type := BlockPointed.type
instance : Nonempty Block := BlockPointed.property

opaque RValuePointed : NonemptyType
/--

`RValue` is the Lean4 representation of `gcc_jit_rvalue`.

See also [RValues](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#rvalues).

## Note
A `RValue` is an expression that can be computed.
It can be simple, e.g.:
 - an integer value e.g. `0` or `42`
 - a string literal e.g. `“Hello world”`
 - a variable e.g. i. These are also lvalues (see below).

or compound e.g.:
 - a unary expression e.g. `!cond`
 - a binary expression e.g. `(a + b)`
 - a function call e.g. `get_distance (&player_ship, &target)`
etc.

Every `RValue` has an associated type, and the API will check to ensure that types match up 
correctly (otherwise the `Context` will emit an error).

-/
def RValue : Type := RValuePointed.type
instance : Nonempty RValue := RValuePointed.property

opaque LValuePointed : NonemptyType
/--
`LValue` is the Lean4 representation of `gcc_jit_lvalue`.
See also [LValues](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#lvalues).
## Note
An `LValue` is something that can of the left-hand side of an assignment: 
a storage area (such as a variable). 
It is also usable as an `RValue` (converted with `LValue.asRValue`), 
where the rvalue is computed by reading from the storage area.
-/
def LValue : Type := LValuePointed.type
instance : Nonempty LValue := LValuePointed.property

opaque ParamPointed : NonemptyType
/--
`Param` is the Lean4 representation of `gcc_jit_param`.
See also [Params](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#params).
## Note
One should **NOT** reuse a `Param` in multiple functions.
-/
def Param : Type := ParamPointed.type
instance : Nonempty Param := ParamPointed.property

opaque CasePointed : NonemptyType
/--
`Case` is the Lean4 representation of `gcc_jit_case`.

## Note
A `Case` represents a case within a switch statement, and is created within a particular 
`Context` using `Context.newCase`. Each case expresses a multivalued range of integer values. 
You can express single-valued cases by passing in the same value for both `min_value` and `max_value`.
-/
def Case : Type := CasePointed.type
instance : Nonempty Case := CasePointed.property

opaque ExtendedAsmPointed : NonemptyType
/--
`ExtendedAsm` is the Lean4 representation of `gcc_jit_extended_asm`.
See also [Extended Asm](https://gcc.gnu.org/onlinedocs/jit/topics/asm.html#c.gcc_jit_extended_asm).

`ExtendedAsm` is designed to be constructed in multiple steps:
- An initial call that creates an empty `ExtendedAsm` with assembly template.
  - `Block.addExtendedAsm` is used to create `asm` statement with no control flow
  - `Block.endWithExtendedAsmGoto` is used to create `asm goto` statement with control flow 
- A series of calls to add operands to the `ExtendedAsm` or set attributes.
-/
def ExtendedAsm : Type := ExtendedAsmPointed.type
instance : Nonempty ExtendedAsm := ExtendedAsmPointed.property

opaque TimerPointed : NonemptyType
/--
`Timer` is the Lean4 representation of `gcc_jit_timer`.
For detailed descriptions, see [The Timing API](https://gcc.gnu.org/onlinedocs/jit/topics/performance.html#the-timing-api).
-/
def Timer : Type := TimerPointed.type
instance : Nonempty Timer := TimerPointed.property

/--
`StrOption` is the Lean4 representation of `gcc_jit_str_option`.
See also [String Options](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html#string-options).
-/
inductive StrOption :=
  /-- 
    The name of the program, for use as a prefix when printing error messages to stderr. 
    If NULL, or default, `libgccjit.so` is used.
  -/
  | ProgName

/--
`IntOption` is the Lean4 representation of `gcc_jit_int_option`.
See also [Integer Options](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html#integer-options).
-/
inductive IntOption :=
  /--
    How much to optimize the code.
    Valid values are `0-3`, corresponding to GCC’s command-line options `-O0` through `-O3`.
    The default value is `0` (unoptimized).
  -/
  | OptimizationLevel

/--
`BoolOption` is the Lean4 representation of `gcc_jit_bool_option`.
See also [Boolean Options](https://gcc.gnu.org/onlinedocs/jit/topics/contexts.html#boolean-options).
-/
inductive BoolOption :=
  /--
    If `true`, `Context.compile` will attempt to do the right thing so that if you attach a debugger to the process, 
    it will be able to inspect variables and step through your code.
    Note that you can’t step through code unless you set up source location information for the code 
    (by creating and passing in `Location` instances).
  -/
  | DebugInfo
  /--
    If `true`, `Context.compile` will dump its initial `tree` representation of your code to `stderr` 
    (before any optimizations).
  -/
  | DumpInitialTree
  /--
    If `true`, `Context.compile` will dump the `gimple` representation of your code to `stderr`, 
    before any optimizations are performed.
  -/
  | DumpInitialGimple
  /--
    If `true`, `Context.compile` will dump the final generated code to `stderr`, 
    in the form of assembly language.
  -/
  | DumpGenereatedCode
  /--
    If `true`, `Context.compile` will print information to stderr on the actions it is performing.
  -/
  | DumpSummary
  /--
    If `true`, `Context.compile` will dump copious amount of information on what it’s doing to 
    various files within a temporary directory. Use `KeepIntermediates` (see below) to see the results. 
    The files are intended to be human-readable, but the exact files and their formats are subject to change.
  -/
  | DumpEverything
  /--
    If `true`, `libgccjit` will aggressively run its garbage collector, to shake out bugs 
    (greatly slowing down the compile). This is likely to only be of interest to developers of the library. 
    It is used when running the selftest suite.
  -/
  | SelfCheckGC
  /--
    If `true`, `Context.compile` will not clean up intermediate files written to the filesystem, 
    and will display their location on stderr.
  -/
  | KeepIntermediates

/--
The kind of output to generate (corresponds to `gcc_jit_output_kind`). Available kinds are:
| OutputKind       | Typical Suffix           |
|## Note## Note## Note## Note## Note## Note|## Note## Note## Note## Note## Note## Note## Note## Note--|
| Assembler        | .s                       |
| ObjectFile       | .o                       |
| DynamicLibrary   | .so, .dll, .dylib        |
| Executable       | .exe, (no suffix)        |
See also [Output Kinds](https://gcc.gnu.org/onlinedocs/jit/topics/compilation.html#c.gcc_jit_output_kind).
-/
inductive OutputKind :=
  /-- `GCC_JIT_OUTPUT_KIND_ASSEMBLER`: Compile the context to an assembler file. -/
  | Assembler
  /-- `GCC_JIT_OUTPUT_KIND_OBJECT_FILE`: Compile the context to an object file. -/
  | ObjectFile
  /-- `GCC_JIT_OUTPUT_KIND_DYNAMIC_LIBRARY`: Compile the context to a dynamic library. -/
  | DynamicLibrary
  /-- `GCC_JIT_OUTPUT_KIND_EXECUTABLE`: Compile the context to an executable. -/
  | Executable

/--
`TypeEnum` is the Lean4 representation of `gcc_jit_types`.
See [Standard Types](https://gcc.gnu.org/onlinedocs/jit/topics/types.html#standard-types) for more details.
-/
inductive TypeEnum := 
  /-- `GCC_JIT_TYPE_VOID` (represents `void` in C) -/
  | Void
  /-- `GCC_JIT_TYPE_VOID_PTR` (represents `void*` in C) -/
  | VoidPtr
  /-- `GCC_JIT_TYPE_BOOL` (represents `_Bool` in C99, or `bool` in C++) -/
  | Bool
  /-- `GCC_JIT_TYPE_CHAR` (represents `char` in C) -/
  | Char
  /-- `GCC_JIT_TYPE_SIGNED_CHAR` (represents `signed char` in C) -/
  | SignedChar 
  /-- `GCC_JIT_TYPE_UNSIGNED_CHAR` (represents `unsigned char` in C) -/
  | UnsignedChar
  /-- `GCC_JIT_TYPE_SHORT` (represents `short` in C) -/
  | Short
  /-- `GCC_JIT_TYPE_UNSIGNED_SHORT` (represents `unsigned short` in C) -/
  | UnsignedShort
  /-- `GCC_JIT_TYPE_INT` (represents `int` in C) -/
  | Int
  /-- `GCC_JIT_TYPE_UNSIGNED_INT` (represents `unsigned int` in C) -/
  | UnsignedInt
  /-- `GCC_JIT_TYPE_LONG` (represents `long` in C) -/
  | Long
  /-- `GCC_JIT_TYPE_UNSIGNED_LONG` (represents `unsigned long` in C) -/
  | UnsignedLong
  /-- `GCC_JIT_TYPE_LONG_LONG` (represents `long long` in C) -/
  | LongLong
  /-- `GCC_JIT_TYPE_UNSIGNED_LONG_LONG` (represents `unsigned long long` in C) -/
  | UnsignedLongLong
  /-- `GCC_JIT_TYPE_FLOAT` (represents `float` in C) -/
  | Float
  /-- `GCC_JIT_TYPE_DOUBLE` (represents `double` in C) -/
  | Double
  /-- `GCC_JIT_TYPE_LONG_DOUBLE` (represents `long double` in C) -/
  | LongDouble
  /-- `GCC_JIT_TYPE_CONST_CHAR_PTR` (represents `const char*` in C) -/
  | ConstCharPtr
  /-- `GCC_JIT_TYPE_SIZE_T` (represents `size_t` in C) -/
  | SizeT 
  /-- `GCC_JIT_TYPE_FILE_PTR` (represents `FILE*` in C) -/
  | FilePtr
  /-- `GCC_JIT_TYPE_COMPLEX_FLOAT` (represents `_Complex float` in C) -/
  | ComplexFloat
  /-- `GCC_JIT_TYPE_COMPLEX_DOUBLE` (represents `_Complex double` in C) -/
  | ComplexDouble
  /-- `GCC_JIT_TYPE_COMPLEX_LONG_DOUBLE` (represents `_Complex long double` in C) -/
  | ComplexLongDouble
  /-- `GCC_JIT_TYPE_UINT8_T` (represents `uint8_t` in C) -/
  | UInt8
  /-- `GCC_JIT_TYPE_UINT16_T` (represents `uint16_t` in C) -/
  | UInt16
  /-- `GCC_JIT_TYPE_UINT32_T` (represents `uint32_t` in C) -/
  | UInt32
  /-- `GCC_JIT_TYPE_UINT64_T` (represents `uint64_t` in C) -/
  | UInt64
  /-- `GCC_JIT_TYPE_UINT128_T` (represents `uint128_t` in C) -/
  | UInt128
  /-- `GCC_JIT_TYPE_INT8_T` (represents `int8_t` in C) -/
  | Int8
  /-- `GCC_JIT_TYPE_INT16_T` (represents `int16_t` in C) -/
  | Int16
  /-- `GCC_JIT_TYPE_INT32_T` (represents `int32_t` in C) -/
  | Int32
  /-- `GCC_JIT_TYPE_INT64_T` (represents `int64_t` in C) -/
  | Int64
  /-- `GCC_JIT_TYPE_INT128_T` (represents `int128_t` in C) -/
  | Int128

/-- 
`FunctionKind` is the Lean4 representation of `gcc_jit_function_kind`. 
This enum controls the kind of function created.
See also [Function Kinds](https://gcc.gnu.org/onlinedocs/jit/topics/functions.html#c.gcc_jit_context_new_function.gcc_jit_function_kind).
-/
inductive FunctionKind := 
  /-- 
    `GCC_JIT_FUNCTION_EXPORTED`: Function is defined by the client code and visible by name outside of the JIT.
    This value is required if you want to extract machine code for this function from a `Result` via `Result.getCode`.
  -/
  | Exported
   /--
    `GCC_JIT_FUNCTION_INTERNAL`: Function is defined by the client code, but is invisible outside of the JIT. 
    Analogous to a `static` function.
   -/
  | Internal
  /--
    `GCC_JIT_FUNCTION_IMPORTED`: Function is not defined by the client code; we’re merely referring to it. 
    Analogous to using an “extern” function from a header file.
  -/
  | Imported
  /--
    `GCC_JIT_FUNCTION_ALWAYS_INLINE`: Function is only ever inlined into other functions, 
    and is invisible outside of the JIT.
    Analogous to prefixing with `inline` and adding `__attribute__((always_inline))`
    
    Inlining will only occur when the optimization level is above 0; when optimization is off, 
    this is essentially the same as GCC_JIT_FUNCTION_INTERNAL.
  -/
  | AlwaysInline

/--
`TlsModel` is the Lean4 representation of `gcc_jit_tls_model`.
It is to be used with `LValue.setTlsModel`.

- [`gcc_jit_tls_model`](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#c.gcc_jit_lvalue_set_tls_model.gcc_jit_tls_model).
- [`Thread Local`](https://gcc.gnu.org/onlinedocs/gcc/Thread-Local.html)
-/
inductive TlsModel := 
  /-- `GCC_JIT_TLS_MODEL_NONE`: Do not set specific TLS model -/
  | None
  /-- `GCC_JIT_TLS_MODEL_GLOBAL_DYNAMIC`: Global dynamic TLS model -/
  | GeneralDynamic
  /-- `GCC_JIT_TLS_MODEL_LOCAL_DYNAMIC`: Local dynamic TLS model -/
  | LocalDynamic
  /-- `GCC_JIT_TLS_MODEL_INITIAL_EXEC`: Initial exec TLS model -/
  | InitialExec
  /-- `GCC_JIT_TLS_MODEL_LOCAL_EXEC`: Local exec TLS model -/
  | LocalExec

/-- 
`GlobalKind` is the Lean4 representation of `gcc_jit_global_kind`.
It is to be used with `Context.newGlobal`.
See also [Global Variables](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#global-variables).
-/
inductive GlobalKind := 
  /-- 
    `GCC_JIT_GLOBAL_EXPORTED`: Global is defined by the client code and is visible by name outside of this JIT context 
    via `Result.getGlobal` (and this value is required for the global to be accessible via that entrypoint).
  -/
  | Exported
  /-- 
    `GCC_JIT_GLOBAL_INTERNAL`: Global is defined by the client code, but is invisible outside of it. Analogous to a `static`
    global within a `.c` file. Specifically, the variable will only be visible within this context and within child contexts.
  -/
  | Internal
  /-- 
    `GCC_JIT_GLOBAL_IMPORTED`: Global is not defined by the client code; we’re merely referring to it. Analogous to using an `extern`
    global from a header file.
  -/
  | Imported

/--
`UnaryOp` is the Lean4 representation of `gcc_jit_unary_op`.
It is to be used with `Context.newUnaryOp`.
See also [Unary Operations](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#unary-operations).
-/
inductive UnaryOp :=
  /-- `GCC_JIT_UNARY_OP_MINUS`: equivalent to `- (EXPR)` in C. -/
  | Minus
  /-- `GCC_JIT_UNARY_OP_BITWISE_NEGATE`: equivalent to `~ (EXPR)` in C. -/
  | BitwiseNegate
  /-- `GCC_JIT_UNARY_OP_LOGICAL_NEGATE`: equivalent to `! (EXPR)` in C. -/
  | LogicalNegate
  /-- `GCC_JIT_UNARY_OP_ABS`: equivalent to `abs(EXPR)` in C. -/
  | Abs

/--
`BinaryOp` is the Lean4 representation of `gcc_jit_binary_op`.
It is to be used with `Context.newBinaryOp` or `Block.addAssignmentOp`.
See also [Binary Operations](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#binary-operations).
-/
inductive BinaryOp :=
  /-- `GCC_JIT_BINARY_OP_PLUS`: equivalent to `x + y` in C. -/
  | Plus
  /-- `GCC_JIT_BINARY_OP_MINUS`: equivalent to `x - y` in C. -/
  | Minus
  /-- `GCC_JIT_BINARY_OP_MULT`: equivalent to `x * y` in C. -/
  | Mult
  /-- `GCC_JIT_BINARY_OP_DIVIDE`: equivalent to `x / y` in C. -/
  | Divide
  /-- `GCC_JIT_BINARY_OP_MODULO`: equivalent to `x % y` in C. -/
  | Modulo
  /-- `GCC_JIT_BINARY_OP_BITWISE_AND`: equivalent to `x & y` in C. -/
  | BitwiseAnd
  /-- `GCC_JIT_BINARY_OP_BITWISE_XOR`: equivalent to `x ^ y` in C. -/
  | BitwiseXor
  /-- `GCC_JIT_BINARY_OP_BITWISE_OR`: equivalent to `x | y` in C. -/
  | BitwiseOr
  /-- `GCC_JIT_BINARY_OP_LOGICAL_AND`: equivalent to `x && y` in C. -/
  | LogicalAnd
  /-- `GCC_JIT_BINARY_OP_LOGICAL_OR`: equivalent to `x || y` in C. -/
  | LogicalOr
  /-- `GCC_JIT_BINARY_OP_LSHIFT`: equivalent to `x << y` in C. -/
  | LShift
  /-- `GCC_JIT_BINARY_OP_RSHIFT`: equivalent to `x >> y` in C. -/
  | RShift

/--
`Comparison` is the Lean4 representation of `gcc_jit_comparison`. 
It is to be used with `Context.newComparison`.
See also [Comparisons](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#c.gcc_jit_comparison).
-/
inductive Comparison :=
  /-- `GCC_JIT_COMPARISON_EQ`: equivalent to `x == y` in C. -/
  | EQ
  /-- `GCC_JIT_COMPARISON_NE`: equivalent to `x != y` in C. -/
  | NE
  /-- `GCC_JIT_COMPARISON_LT`: equivalent to `x < y` in C. -/
  | LT
  /-- `GCC_JIT_COMPARISON_LE`: equivalent to `x <= y` in C. -/
  | LE
  /-- `GCC_JIT_COMPARISON_GT`: equivalent to `x > y` in C. -/
  | GT
  /-- `GCC_JIT_COMPARISON_GE`: equivalent to `x >= y` in C. -/
  | GE

opaque DynamicBufferPointed : NonemptyType
/--
A `DynamicBuffer` is a buffer used to store a string. This is to be used with
`Context.registerDumpBuffer`. In the backstage, this is just a wrapper around
`char **`.
-/
def DynamicBuffer : Type := DynamicBufferPointed.type
instance : Nonempty DynamicBuffer := DynamicBufferPointed.property

/--
Create a `DynamicBuffer`. This will allocate a word as the same size as `char *`.
The initial value of the word is set to `NULL`.
-/
@[extern "lean_gcc_jit_dynamic_buffer_acquire"]
opaque DynamicBuffer.acquire : IO DynamicBuffer

/--
Release a `DynamicBuffer`. This will free the memory allocated by `DynamicBuffer.acquire`.
### Note
The inner string is not freed by this function. It is recommended to call `DynamicBuffer.releaseInner`
before calling this function.
-/
@[extern "lean_gcc_jit_dynamic_buffer_release"]
opaque DynamicBuffer.release : DynamicBuffer → IO PUnit

/--
Release the memory associated with the string stored in the `DynamicBuffer`. This string is set
by `libgccjit` via `Context.compile` or `Context.compileToFile`. It is safe to call this function
multiple times as it will reset the string to `NULL` after its first call.
-/
@[extern "lean_gcc_jit_dynamic_buffer_release_inner"]
opaque DynamicBuffer.releaseInner : @& DynamicBuffer → IO PUnit

/--
Get the string stored in the `DynamicBuffer`. This function returns `none` if the string is `NULL`.
-/
@[extern "lean_gcc_jit_dynamic_buffer_get_string"]
opaque DynamicBuffer.getString : @& DynamicBuffer → IO (Option String)