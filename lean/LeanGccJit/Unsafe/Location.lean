import LeanGccJit.Types

@[extern "lean_gcc_jit_context_new_location"]
opaque Context.newLocation (ctx : @& Context) (file : @& CString) (line : @& Int) (column : @& Int) : IO Location

@[extern "lean_gcc_jit_location_as_object"]
opaque Location.asObject (loc : @& Location) : IO Object