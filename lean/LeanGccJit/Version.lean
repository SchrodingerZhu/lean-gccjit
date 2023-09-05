@[extern "lean_gcc_jit_version_major"]
opaque getMajorVersion : Unit → Int

@[extern "lean_gcc_jit_version_minor"]
opaque getMinorVersion : Unit → Int

@[extern "lean_gcc_jit_version_patchlevel"]
opaque getPatchlevel : Unit → Int