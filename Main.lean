
import «LeanGccJit»
import LeanGccJit.Version
import LeanGccJit.Types
import LeanGccJit.Unsafe

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

def main : IO Unit := do
  IO.println s!"major version: {getMajorVersion ()}"
  IO.println s!"minor version: {getMinorVersion ()}"
  IO.println s!"patch version: {getPatchlevel ()}"
  let ctx ← Context.acquire
  ctx.setIntOption IntOption.OptimizationLevel 3
  ctx.setBoolOption BoolOption.DumpEverything true
  ctx.setBoolAllowUnreachableBlocks true
  ctx.setBoolPrintErrorsToStderr true
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
  let res ← ctx.compile
  let main ← res.getCode "main"
  IO.println s!"{(← ctx.getFirstError)}"
  IO.println s!"main: {main}"
  res.release
  ctx.release
  

