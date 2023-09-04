import «LeanGccJit»
def main : IO Unit := do
  let ctx ← Context.acquire
  ctx.setIntOption IntOption.OptimizationLevel 3
  ctx.setBoolOption BoolOption.DumpEverything true
  ctx.setBoolAllowUnreachableBlocks true
  ctx.setBoolPrintErrorsToStderr true
  ctx.compileToFile OutputKind.ObjectFile "/tmp/test.o"
  ctx.dumpToFile "/tmp/test.data" true
  ctx.release
  IO.println s!"{ctx.getFirstError}"

