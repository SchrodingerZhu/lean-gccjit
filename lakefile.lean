import Lake
open Lake DSL

package «lean-gccjit» {
  -- add package configuration options here
}

lean_lib «LeanGccJit» {
  srcDir := "lean"
  -- add library configuration options here
}

target gccjit.o pkg : FilePath := do
  let oFile := pkg.buildDir / "cxx" / "gccjit.o"
  let srcJob ← inputFile <| pkg.dir / "cxx" / "gccjit.cpp"
  let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-std=c++17"]
  buildO "gccjit.cpp" oFile srcJob flags "c++"

extern_lib liblean_gccjit.a pkg := do
  let name := nameToStaticLib "lean_gccjit"
  let gccJitO ← fetch <| pkg.target ``gccjit.o
  buildStaticLib (pkg.nativeLibDir / name) #[gccJitO]

@[default_target]
lean_exe «lean-gccjit» {
  root := `Main
  moreLinkArgs := #["-lgccjit"]
}
