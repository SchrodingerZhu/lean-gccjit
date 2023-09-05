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

opaque FunctionPointed : NonemptyType
def Function : Type := FunctionPointed.type
instance : Nonempty Function := FunctionPointed.property

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

inductive StrOption :=
  | ProgName

inductive IntOption :=
  | OptimizationLevel

inductive BoolOption :=
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

inductive TLSModel := 
  | None
  | GeneralDynamic
  | LocalDynamic
  | InitialExec
  | LocalExec

inductive GlobalKind := 
  | Exported
  | Internal
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

