
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
  let ty ← ty.getConst
  let obj ← ty.asObject
  let debug ← obj.getDebugString
  IO.println s!"{debug}"

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
  ctx.release
  IO.println s!"{(← ctx.getFirstError)}"

