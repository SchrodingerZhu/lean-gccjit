import LeanGccJit.Types

@[extern "lean_gcc_jit_context_acquire"]
opaque Context.acquire : IO Context

@[extern "lean_gcc_jit_context_release"]
opaque Context.release : Context → IO PUnit

@[extern "lean_gcc_jit_context_set_str_option"]
opaque Context.setStrOption : @& Context → @& StrOption → @& String → IO PUnit

@[extern "lean_gcc_jit_context_set_int_option"]
opaque Context.setIntOption : @& Context → @& IntOption → @& Int → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_option"]
opaque Context.setBoolOption : @& Context → @& BoolOption → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_allow_unreachable_blocks"]
opaque Context.setBoolAllowUnreachableBlocks : @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_print_errors_to_stderr"]
opaque Context.setBoolPrintErrorsToStderr : @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_bool_use_external_driver"]
opaque Context.setBoolUseExtenalDriver: @& Context → @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_add_command_line_option"]
opaque Context.addCommandLineOption: @& Context → @& String → IO PUnit

@[extern "lean_gcc_jit_context_add_driver_option"]
opaque Context.addDriverOption: @& Context → @& String → IO PUnit

@[extern "lean_gcc_jit_context_compile"]
opaque Context.compile: @& Context → IO Result

@[extern "lean_gcc_jit_context_compile_to_file"]
opaque Context.compileToFile: @& Context → @& OutputKind → @& String → IO PUnit

@[extern "lean_gcc_jit_context_dump_to_file"]
opaque Context.dumpToFile: @& Context → @& String→ @& Bool → IO PUnit

@[extern "lean_gcc_jit_context_set_logfile"]
opaque Context.setLogFile: @& Context → @& IO.FS.Handle → @& Int → @& Int → IO PUnit

@[extern "lean_gcc_jit_context_get_first_error"]
opaque Context.getFirstError: @& Context → Option String

@[extern "lean_gcc_jit_context_get_last_error"]
opaque Context.getLastError: @& Context → Option String