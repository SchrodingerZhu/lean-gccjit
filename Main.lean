import «LeanGccJit»
import LeanGccJit.Version
import LeanGccJit.Core.Types
import LeanGccJit.Core

open LeanGccJit
open Core Version

inductive BFItem :=
  | Right
  | Left
  | Inc
  | Dec
  | PutChar
  | GetChar
  | Loop (body : Array BFItem)
deriving Repr

partial def compileBF (ctx: Context) (putchar: Func) (getchar: Func) (main: Func)
  (block: Block) (gBuffer : LValue) (cursor : LValue) (one: RValue) (prog: Array BFItem) 
  : IO Block := do
  let mut block := block
  for i in prog do
    match i with
    | BFItem.Right => 
      block.addAssignmentOp none cursor BinaryOp.Plus one
    | BFItem.Left =>
      block.addAssignmentOp none cursor BinaryOp.Minus one
    | BFItem.Inc =>
      let access ← ctx.newArrayAccess none (← gBuffer.asRValue) (← cursor.asRValue)
      block.addAssignmentOp none access BinaryOp.Plus one
    | BFItem.Dec =>
      let access ← ctx.newArrayAccess none (← gBuffer.asRValue) (← cursor.asRValue)
      block.addAssignmentOp none access BinaryOp.Minus one
    | BFItem.PutChar =>
      let access ← ctx.newArrayAccess none (← gBuffer.asRValue) (← cursor.asRValue)
      let ch ← ctx.newCall none putchar #[(← access.asRValue)] 
      block.addEval none ch
    | BFItem.GetChar =>
      let access ← ctx.newArrayAccess none (← gBuffer.asRValue) (← cursor.asRValue)
      let ch ← ctx.newCall none putchar #[(← access.asRValue)] 
      block.addAssignment none access ch
    | BFItem.Loop body =>
      let loop ← main.newBlock none
      let after ← main.newBlock none
      let access ← ctx.newArrayAccess none (← gBuffer.asRValue) (← cursor.asRValue)
      let access ← ctx.newCast none (← access.asRValue) (← ctx.getType TypeEnum.Bool)
      block.endWithConditional none access loop after
      let blk ← compileBF ctx putchar getchar main loop gBuffer cursor one body
      blk.endWithConditional none access loop after
      block := after
  pure block

def splitAtEnd  (prog: List Char) : (List Char × List Char) :=
  let rec loop (level: Nat) (prog: List Char) (acc: List Char) : (List Char × List Char) :=
    match prog, level with
    | '[' :: rest, level => loop (level + 1) rest ('[' :: acc)
    | ']' :: rest, 0 => (acc.reverse, rest)
    | ']' :: rest, level => loop (level - 1) rest (']' :: acc)
    | c :: rest, level => loop level rest (c :: acc)
    | _ , _ => panic! "unterminated loop"
  loop 0 prog []

partial def parseBFProg (prog: List Char) (compiled: Array BFItem) : Array BFItem := 
  match prog with
  | '>' :: rest => parseBFProg rest (compiled.push BFItem.Right)
  | '<' :: rest => parseBFProg rest (compiled.push BFItem.Left)
  | '+' :: rest => parseBFProg rest (compiled.push BFItem.Inc)
  | '-' :: rest => parseBFProg rest (compiled.push BFItem.Dec)
  | '.' :: rest => parseBFProg rest (compiled.push BFItem.PutChar)
  | ',' :: rest => parseBFProg rest (compiled.push BFItem.GetChar)
  | '[' :: rest => 
    let (body, tail) := splitAtEnd rest
    let bodyCompiled := parseBFProg body #[]
    parseBFProg tail (compiled.push (BFItem.Loop bodyCompiled))
  | _ => compiled

partial def compileBFToFile (path: System.FilePath) (prog: String) : IO Unit := do
  let ctx ← Context.acquire
  ctx.setIntOption IntOption.OptimizationLevel 3
  let int ← ctx.getType TypeEnum.Int
  let chParam ← ctx.newParam none int "ch"
  let putchar ← ctx.newFunction none FunctionKind.Imported int "putchar" #[chParam] false
  let getchar ← ctx.newFunction none FunctionKind.Imported int "getchar" #[] false
  let main ← ctx.newFunction none FunctionKind.Exported int "main" #[] false
  let buffer ← ctx.newArrayType none int 1024
  let gBuffer ← ctx.newGlobal none GlobalKind.Internal buffer "buffer"
  let cursor ← main.newLocal none int "cursor"
  let mut block ← main.newBlock "entry"
  let one ← ctx.one int
  block.addAssignment none cursor (← ctx.newRValueFromUInt32 int 512)
  let last ← compileBF ctx putchar getchar main block gBuffer cursor one (parseBFProg prog.toList #[])
  let zero ← ctx.zero int
  last.endWithReturn none zero
  ctx.compileToFile OutputKind.Executable path.toString
  IO.println s!"{(← ctx.getFirstError)}"
  ctx.release


def typeCheck1 (ctx : Context) : IO Unit := do
  let ty ← ctx.getType TypeEnum.ComplexLongDouble
  let obj ← ty.asObject
  let debug ← obj.getDebugString
  IO.println s!"{debug}"

def typeCheck2 (ctx : Context) : IO Unit := do
  let ty ← ctx.getIntType 8 false
  let ty ← ty.getPointer
  let ty ← ty.getVolatile
  let cty ← ty.getConst
  let compat ← cty.isCompatibleWith ty
  let obj ← cty.asObject
  let debug ← obj.getDebugString
  let obj2 ← ty.asObject
  let debug2 ← obj2.getDebugString
  IO.println s!"{debug} is compatible with {debug2}? {compat}"

def typeCheck3 (ctx : Context) : IO Unit := do
  let ty ← ctx.getIntType 8 false
  let obj ← ty.asObject
  let debug ← obj.getDebugString
  let size ← ty.getSize
  IO.println s!"{debug} is of size {size}."

def typeCheck4 (ctx : Context) : IO Unit := do
  let ty ← ctx.getIntType 8 false
  let location ← ctx.newLocation "test.c" 1 1
  let arr ← ctx.newArrayType location ty 10
  let obj ← arr.asObject
  let debug ← obj.getDebugString
  IO.println s!"array type: {debug}"

def typeCheck5 (ctx : Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 1 1
  let tyA ← ctx.getType TypeEnum.ComplexLongDouble
  let fieldA ← ctx.newField location tyA "a"
  let tyB ← ctx.getType TypeEnum.UnsignedLongLong
  let fieldB ← ctx.newField location tyB "b"
  let struct ← ctx.newStructType location "test" #[fieldA, fieldB]
  let numFields ← struct.getFieldCount
  let tySt ← struct.asJitType
  let obj ← tySt.asObject
  let debug ← obj.getDebugString
  IO.println s!"struct type: {debug}, with {numFields} fields."
  for i in [:numFields] do
    let field ← struct.getField i
    let obj ← field.asObject
    let debug ← obj.getDebugString
    IO.println s!"field {i}: {debug}"

def typeCheck6 (ctx : Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 1 1
  let tyA ← ctx.getType TypeEnum.ComplexLongDouble
  let tyA ← (← tyA.getPointer).getVolatile
  let tyB ← ctx.getType TypeEnum.UnsignedLongLong
  let void ← ctx.getType TypeEnum.Void
  let voidPtr ← void.getPointer
  let funcPtr ← ctx.newFunctionPtrType location voidPtr #[tyA, tyB] true
  let obj ← funcPtr.asObject
  let debug ← obj.getDebugString
  IO.println s!"function pointer: {debug}"

def functionCheck1 (ctx: Context) : IO Unit := do
  let memcpy ← ctx.getBuiltinFunction "memcpy"
  let obj ←  memcpy.asObject
  let debug ← obj.getDebugString
  IO.println s!"memcpy: {debug}"
  memcpy.dumpToDot "/tmp/memcpy.dot"
  let param ← memcpy.getParam 0
  let obj ← param.asObject
  let debug ← obj.getDebugString
  IO.println s!"memcpy param 0: {debug}"

def valueCheck1 (ctx: Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 2 2
  let long ← ctx.getType TypeEnum.Long
  let g ← ctx.newGlobal location GlobalKind.Exported long "G_test"
  let obj ← g.asObject
  let debug ← obj.getDebugString
  IO.println s!"global: {debug}"

def valueCheck2 (ctx: Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 2 2
  let long ← ctx.getType TypeEnum.Long
  let arr ← ctx.newArrayType location long 3
  let one ← ctx.one long
  let ctor ← ctx.newArrayConstructor location arr #[one, one, one]
  let obj ← ctor.asObject
  let debug ← obj.getDebugString
  IO.println s!"array ctor: {debug}"

def valueCheck3 (ctx: Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 2 2
  let long ← ctx.getType TypeEnum.Long
  let one ← ctx.one long
  let negOne ← ctx.newUnaryOp location UnaryOp.Minus long one
  let onePlusNegOne ← ctx.newBinaryOp location BinaryOp.Plus long one negOne
  let obj ← onePlusNegOne.asObject
  let debug ← obj.getDebugString
  IO.println s!"one + -one: {debug}"

def valueCheck4 (ctx: Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 2 2
  let long ← ctx.getType TypeEnum.Long
  let g ← ctx.newGlobal location GlobalKind.Internal long "g"
  g.setAlignment 16
  let a ← g.getAlignment
  IO.println s!"g alignment: {a}"

def blockCheck1 (ctx: Context) : IO Unit := do
  let location ← ctx.newLocation "test.c" 3 3
  let int ← ctx.getType TypeEnum.Int
  let code ← ctx.newParam location int "code"
  let exit ← ctx.newFunction location FunctionKind.Imported int "exit" #[code] false
  let main ← ctx.newFunction location FunctionKind.Exported int "main" #[] false
  let entry ← main.newBlock "entry"
  let zero ← ctx.zero int
  let callExit ← ctx.newCall location exit #[zero]
  entry.endWithReturn location callExit
  let obj ← callExit.asObject
  let debug ← obj.getDebugString
  IO.println s!"exit call: {debug}"

def timerTest (ctx: Context) : IO Unit := do
  let timer ← ctx.getTimer
  match timer with
  | none => IO.println "no timer"
  | some timer => do
    timer.pop "test"
    IO.FS.withFile "/tmp/test.timer" IO.FS.Mode.write fun h => do
      timer.print h


def main : IO Unit := do
  IO.println s!"major version: {getMajorVersion ()}"
  IO.println s!"minor version: {getMinorVersion ()}"
  IO.println s!"patch version: {getPatchlevel ()}"
  compileBFToFile "/tmp/bf" "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
  let ctx ← Context.acquire
  ctx.setIntOption IntOption.OptimizationLevel 3
  ctx.setBoolOption BoolOption.DumpEverything true
  ctx.setBoolAllowUnreachableBlocks true
  ctx.setBoolPrintErrorsToStderr true
  let timer ← Timer.new
  ctx.setTimer timer
  timer.push "test"
  typeCheck1 ctx
  typeCheck2 ctx
  typeCheck3 ctx
  typeCheck4 ctx
  typeCheck5 ctx
  typeCheck6 ctx
  functionCheck1 ctx
  valueCheck1 ctx
  valueCheck2 ctx
  valueCheck3 ctx
  valueCheck4 ctx
  blockCheck1 ctx
  ctx.compileToFile OutputKind.Executable "/tmp/test.o"
  ctx.dumpToFile "/tmp/test.data" true
  ctx.dumpReproducerToFile "/tmp/test.reproducer"
  let buf ← DynamicBuffer.acquire
  ctx.registerDumpBuffer "tree-vrp1" buf
  let res ← ctx.compile
  let main ← res.getCode "main"
  IO.println s!"{(← ctx.getFirstError)}"
  IO.println s!"main: {main}"
  IO.println s!"tree-vrp1: {← buf.getString}"
  timerTest ctx
  timer.release
  buf.releaseInner
  buf.release
  res.release
  ctx.release
  

