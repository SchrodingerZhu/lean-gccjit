namespace LeanGccJit
namespace Core

opaque ContextPointed : NonemptyType
def Context : Type := ContextPointed.type
instance : Nonempty Context := ContextPointed.property

opaque ResultPointed : NonemptyType
def Result : Type := ResultPointed.type
instance : Nonempty Result := ResultPointed.property

opaque ObjectPointed : NonemptyType
def Object : Type := ObjectPointed.type
instance : Nonempty Object := ObjectPointed.property

opaque LocationPointed : NonemptyType
def Location : Type := LocationPointed.type
instance : Nonempty Location := LocationPointed.property

opaque JitTypePointed : NonemptyType
def JitType : Type := JitTypePointed.type
instance : Nonempty JitType := JitTypePointed.property

opaque FunctionPointed : NonemptyType
def Func : Type := FunctionPointed.type
instance : Nonempty Func := FunctionPointed.property

opaque FunctionTypePointed : NonemptyType
def FunctionType : Type := FunctionTypePointed.type
instance : Nonempty FunctionType := FunctionTypePointed.property

opaque VectorTypePointed : NonemptyType
def VectorType : Type := VectorTypePointed.type
instance : Nonempty VectorType := VectorTypePointed.property

opaque StructPointed : NonemptyType
def Struct : Type := StructPointed.type
instance : Nonempty Struct := StructPointed.property

opaque FieldPointed : NonemptyType
def Field : Type := FieldPointed.type
instance : Nonempty Field := FieldPointed.property

opaque BlockPointed : NonemptyType
def Block : Type := BlockPointed.type
instance : Nonempty Block := BlockPointed.property

opaque RValuePointed : NonemptyType
def RValue : Type := RValuePointed.type
instance : Nonempty RValue := RValuePointed.property

opaque LValuePointed : NonemptyType
def LValue : Type := LValuePointed.type
instance : Nonempty LValue := LValuePointed.property

opaque ParamPointed : NonemptyType
def Param : Type := ParamPointed.type
instance : Nonempty Param := ParamPointed.property

opaque CasePointed : NonemptyType
def Case : Type := CasePointed.type
instance : Nonempty Case := CasePointed.property

opaque ExtendedAsmPointed : NonemptyType
def ExtendedAsm : Type := ExtendedAsmPointed.type
instance : Nonempty ExtendedAsm := ExtendedAsmPointed.property

opaque TimerPointed : NonemptyType
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
|------------------|--------------------------|
| Assembler        | .s                       |
| ObjectFile       | .o                       |
| DynamicLibrary   | .so, .dll, .dylib        |
| Executable       | .exe, (no suffix)        |
See also [Output Kinds](https://gcc.gnu.org/onlinedocs/jit/topics/compilation.html#c.gcc_jit_output_kind).
-/
inductive OutputKind :=
  /-- Compile the context to an assembler file. -/
  | Assembler
  /-- Compile the context to an object file. -/
  | ObjectFile
  /-- Compile the context to a dynamic library. -/
  | DynamicLibrary
  /-- Compile the context to an executable. -/
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

inductive TlsModel := 
  | None
  | GeneralDynamic
  | LocalDynamic
  | InitialExec
  | LocalExec

/-- The kind of a global variable -/
inductive GlobalKind := 
  /-- `Exported` means that the symbol is visible outside the module. 
      This is similar to declare a global variable with default visibility in C. -/
  | Exported
  /-- `Internal` means that the symbol is not visible outside the module. 
      This is similar to declare a global variable with hidden visibility in C. -/
  | Internal
  /-- `Imported` means that the symbol is to be imported from other modules. -/
  | Imported

inductive UnaryOp :=
  | Minus
  | BitwiseNegate
  | LogicalNegate
  | Abs

inductive BinaryOp :=
  | Plus
  | Minus
  | Mult
  | Divide
  | Modulo
  | BitwiseAnd
  | BitwiseXor
  | BitwiseOr
  | LogicalAnd
  | LogicalOr
  | LShift
  | RShift

inductive Comparison :=
  | EQ
  | NE
  | LT
  | LE
  | GT
  | GE

opaque DynamicBufferPointed : NonemptyType
def DynamicBuffer : Type := DynamicBufferPointed.type
instance : Nonempty DynamicBuffer := DynamicBufferPointed.property

@[extern "lean_gcc_jit_dynamic_buffer_acquire"]
opaque DynamicBuffer.acquire : IO DynamicBuffer

@[extern "lean_gcc_jit_dynamic_buffer_release"]
opaque DynamicBuffer.release : DynamicBuffer → IO PUnit

@[extern "lean_gcc_jit_dynamic_buffer_release_inner"]
opaque DynamicBuffer.releaseInner : @& DynamicBuffer → IO PUnit

@[extern "lean_gcc_jit_dynamic_buffer_get_string"]
opaque DynamicBuffer.getString : @& DynamicBuffer → IO (Option String)