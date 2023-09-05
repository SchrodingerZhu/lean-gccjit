import Lake
open Lake DSL

package «lean-gccjit» {
  -- add package configuration options here
}

lean_lib «LeanGccJit» {
  srcDir := "lean"
  -- add library configuration options here
}

target object.o pkg : FilePath := do
  let oFile := pkg.buildDir / "cxx" / "object.o"
  let srcJob ← inputFile <| pkg.dir / "cxx" / "object.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-std=c++17"]
  buildO "object.cpp" oFile srcJob flags "c++"

target context.o pkg : FilePath := do
  let oFile := pkg.buildDir / "cxx" / "context.o"
  let srcJob ← inputFile <| pkg.dir / "cxx" / "context.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-std=c++17"]
  buildO "context.cpp" oFile srcJob flags "c++"

target result.o pkg : FilePath := do
  let oFile := pkg.buildDir / "cxx" / "result.o"
  let srcJob ← inputFile <| pkg.dir / "cxx" / "result.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-std=c++17"]
  buildO "result.cpp" oFile srcJob flags "c++"

target utilities.o pkg : FilePath := do
  let oFile := pkg.buildDir / "cxx" / "utilities.o"
  let srcJob ← inputFile <| pkg.dir / "cxx" / "utilities.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-std=c++17"]
  buildO "utilities.cpp" oFile srcJob flags "c++"

extern_lib liblean_gccjit.a pkg := do
  let name := nameToStaticLib "lean_gccjit"
  let objectO ← fetch <| pkg.target ``object.o
  let contextO ← fetch <| pkg.target ``context.o
  let resultO ← fetch <| pkg.target ``result.o
  let utilitiesO ← fetch <| pkg.target ``utilities.o
  buildStaticLib (pkg.nativeLibDir / name) #[objectO, contextO, resultO, utilitiesO]

@[default_target]
lean_exe «lean-gccjit» {
  root := `Main
  moreLinkArgs := #["-lgccjit"]
}
