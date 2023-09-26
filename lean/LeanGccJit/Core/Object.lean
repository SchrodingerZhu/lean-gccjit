import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/-!
`Object` is the superclass of almost every contextual structures in the library.

There is a tree hierarchy of objects.

For more details, see:
- [C API Documentation](https://gcc.gnu.org/onlinedocs/jit/topics/objects.html1)
- `LeanGccJit.Core.Object`
-/

/-- Which `Context` is an `Object` within? -/
@[extern "lean_gcc_jit_object_get_context"]
opaque Object.getContext : @& Object -> IO Context

/-- 
Generate a human-readable description for the given object. 

## Note

Underlying the C API, this function call will create a string buffer attached to the object. It is of the
same lifetime as the object itself.
-/
@[extern "lean_gcc_jit_object_get_debug_string"]
opaque Object.getDebugString : @& Object -> IO String

