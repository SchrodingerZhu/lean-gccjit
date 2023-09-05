
import «LeanGccJit»
import LeanGccJit.Version
import LeanGccJit.Types
import LeanGccJit.Unsafe

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
  ctx.release
  IO.println s!"{ctx.getFirstError}"

