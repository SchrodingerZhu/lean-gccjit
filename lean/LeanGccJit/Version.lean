namespace LeanGccJit
namespace Version
/-- Get the major version of the GCC JIT library. -/
@[extern "lean_gcc_jit_version_major"]
opaque getMajorVersion : Unit → Int

/-- Get the minor version of the GCC JIT library. -/
@[extern "lean_gcc_jit_version_minor"]
opaque getMinorVersion : Unit → Int

/-- Get the patchlevel of the GCC JIT library. -/
@[extern "lean_gcc_jit_version_patchlevel"]
opaque getPatchlevel : Unit → Int