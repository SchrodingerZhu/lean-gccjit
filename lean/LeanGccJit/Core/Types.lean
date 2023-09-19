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
  | DumpInitialTree
  | DumpInitialGimple
  | DumpGenereatedCode
  | DumpExecutionCode
  | DumpSummary
  | DumpEverything
  | SelfCheckGC
  | KeepIntermediates

inductive OutputKind :=
  | Assembler
  | ObjectFile
  | DynamicLibrary
  | Executable

inductive TypeEnum := 
  | Void
  | VoidPtr
  | Bool
  | Char
  | SignedChar 
  | UnsignedChar
  | Short
  | UnsignedShort
  | Int
  | UnsignedInt
  | Long
  | UnsignedLong
  | LongLong
  | UnsignedLongLong
  | Float
  | Double
  | LongDouble
  | ConstCharPtr
  | SizeT
  | FilePtr
  | ComplexFloat
  | ComplexDouble
  | ComplexLongDouble
  | UInt8
  | UInt16
  | UInt32
  | UInt64
  | UInt128
  | Int8
  | Int16
  | Int32
  | Int64
  | Int128

inductive FunctionKind := 
  | Exported
  | Internal
  | Imported
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