
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

def main : IO Unit := do
  IO.println s!"major version: {getMajorVersion ()}"
  IO.println s!"minor version: {getMinorVersion ()}"
  IO.println s!"patch version: {getPatchlevel ()}"
  let ctx ← Context.acquire
  ctx.setIntOption IntOption.OptimizationLevel 3
  ctx.setBoolOption BoolOption.DumpEverything true
  ctx.setBoolAllowUnreachableBlocks true
  ctx.setBoolPrintErrorsToStderr true
  ctx.compileToFile OutputKind.ObjectFile "/tmp/test.o"
  ctx.dumpToFile "/tmp/test.data" true
  typeCheck1 ctx
  typeCheck2 ctx
  typeCheck3 ctx
  typeCheck4 ctx
  typeCheck5 ctx
  typeCheck6 ctx
  functionCheck1 ctx
  IO.println s!"{(← ctx.getFirstError)}"
  ctx.release
  

