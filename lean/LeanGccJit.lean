opaque ContextPointed : NonemptyType
def Context : Type := ContextPointed.type
instance : Nonempty Context := ContextPointed.property

opaque ResultPointed : NonemptyType
def Result : Type := ResultPointed.type
instance : Nonempty Result := ResultPointed.property

private opaque ObjectHandlePointed : NonemptyType
private def ObjectHandle : Type := ObjectHandlePointed.type
private instance : Nonempty ObjectHandle := ObjectHandlePointed.property

@[extern "lean_gcc_jit_context_acquire"]
opaque Context.acquire : IO Context

inductive StrOption :=
  | ProgName

inductive IntOption :=
  | OptimizationLevel

inductive BoolOption :=
  | DebugInfo
  | DumpInitialTree
  | DumpInitialGimple
  | DumpGenereatedCode
  | DumpExecutionCode
  | DumpSummary
  | DumpEverything
  | SelfCheckGC
  | KeepIntermediates

@[extern "lean_gcc_jit_context_set_str_option"]
opaque Context.setStrOption : @Context → @StrOption → @String → IO PUnit

@[extern "lean_gcc_jit_context_set_int_option"]
opaque Context.setIntOption : @Context → @IntOption → @Int → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_option"]
opaque Context.setBoolOption : @Context → @BoolOption → @Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_allow_unreachable_blocks"]
opaque Context.setBoolAllowUnreachableBlocks : @Context → @Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_print_errors_to_stderr"]
opaque Context.setBoolPrintErrorsToStderr : @Context → @Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_use_external_driver"]
opaque Context.setBoolUseExtenalDriver: @Context → @Bool → IO PUnit

@[extern "lean_gcc_jit_context_add_command_line_option"]
opaque Context.addCommandLineOption: @Context → @String → IO PUnit

@[extern "lean_gcc_jit_context_add_driver_option"]
opaque Context.addDriverOption: @Context → @String → IO PUnit

@[extern "lean_gcc_jit_context_compile"]
opaque Context.compile: @Context → IO Result

inductive OutputKind :=
  | Assembler
  | ObjectFile
  | DynamicLibrary
  | Executable

@[extern "lean_gcc_jit_context_compile_to_file"]
opaque Context.compileToFile: @Context → @OutputKind → @String → IO PUnit

@[extern "lean_gcc_jit_context_dump_to_file"]
opaque Context.dumpToFile: @Context → @String→ @Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_logfile"]
opaque Context.setLogFile: @Context → @IO.FS.Handle → @Int → @Int → IO PUnit

@[extern "lean_gcc_jit_context_get_first_error"]
opaque Context.getFirstError: @Context → Option String

@[extern "lean_gcc_jit_context_get_last_error"]
opaque Context.getLastError: @Context → Option String

@[extern "lean_gcc_jit_result_get_code"]
opaque Result.getCode: @Result → @String → USize

@[extern "lean_gcc_jit_result_get_global"]
opaque Result.getGlobal: @Result → @String → USize

structure Object :=
  private mk::
  getContext: Context
  private handle : ObjectHandle

