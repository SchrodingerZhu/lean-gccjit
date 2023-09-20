import Lake
import Init.System.IO
open Lake DSL

package «lean-gccjit» {
  -- add package configuration options here
}

lean_lib «LeanGccJit» {
  srcDir := "lean"
  -- add library configuration options here
}

def flags : SchedulerM (Array String) := do
  let extraFlags ← IO.getEnv "LEAN_GCCJIT_FLAGS" 
  let extraFlags := extraFlags.getD "" |>.trim |>.splitOn " " |>.filter (·.length > 0)
  return #[
    "-I", (← getLeanIncludeDir).toString, 
    "-fPIC", "-std=gnu++17", "-O3", "-fvisibility=hidden", "-ffreestanding"
  ] ++ extraFlags

def objectFile (pkg : Package) (name : String) : SchedulerM (BuildJob FilePath) := do
  let oFile := pkg.buildDir / "cxx" / (name ++ ".o")
  let srcJob ← inputFile <| pkg.dir / "cxx" / (name ++ ".cpp")
  buildO (name ++ ".cpp") oFile srcJob #[] (← flags) "c++"

target object.o pkg : FilePath := objectFile pkg "object"

target context.o pkg : FilePath := objectFile pkg "context"

target result.o pkg : FilePath := objectFile pkg "result"

target utilities.o pkg : FilePath := objectFile pkg "utilities"

target location.o pkg : FilePath := objectFile pkg "location"

target jit_type.o pkg : FilePath := objectFile pkg "jit_type"

target field.o pkg : FilePath := objectFile pkg "field"

target struct.o pkg : FilePath := objectFile pkg "struct"

target function.o pkg : FilePath := objectFile pkg "function"

target param.o pkg : FilePath := objectFile pkg "param"

target block.o pkg : FilePath := objectFile pkg "block"

target values.o pkg : FilePath := objectFile pkg "values"

target case.o pkg : FilePath := objectFile pkg "case"

target timer.o pkg : FilePath := objectFile pkg "timer"

target asm.o pkg : FilePath := objectFile pkg "asm"

extern_lib liblean_gccjit.a pkg := do
  let name := nameToStaticLib "lean_gccjit"
  let objectO ← fetch <| pkg.target ``object.o
  let contextO ← fetch <| pkg.target ``context.o
  let resultO ← fetch <| pkg.target ``result.o
  let utilitiesO ← fetch <| pkg.target ``utilities.o
  let locationO ← fetch <| pkg.target ``location.o
  let jit_typeO ← fetch <| pkg.target ``jit_type.o
  let fieldO ← fetch <| pkg.target ``field.o
  let structO ← fetch <| pkg.target ``struct.o
  let functionO ← fetch <| pkg.target ``function.o
  let paramO ← fetch <| pkg.target ``param.o
  let blockO ← fetch <| pkg.target ``block.o
  let valuesO ← fetch <| pkg.target ``values.o
  let caseO ← fetch <| pkg.target ``case.o
  let timerO ← fetch <| pkg.target ``timer.o
  let asmO ← fetch <| pkg.target ``asm.o
  buildStaticLib (pkg.nativeLibDir / name) #[
    objectO, 
    contextO, 
    resultO,
    utilitiesO,
    locationO, 
    jit_typeO,
    fieldO,
    structO,
    functionO,
    paramO,
    blockO,
    valuesO,
    caseO,
    timerO,
    asmO
  ]

@[default_target]
lean_exe «lean-gccjit» {
  root := `Main
  moreLinkArgs := #["-lgccjit"]
}
