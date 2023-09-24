import LeanGccJit.Core.Types
import LeanGccJit.Core.Context
import LeanGccJit.Core.Result
import LeanGccJit.Core.Object
import LeanGccJit.Core.Location
import LeanGccJit.Core.JitType
import LeanGccJit.Core.Field
import LeanGccJit.Core.Struct
import LeanGccJit.Core.Function
import LeanGccJit.Core.Param
import LeanGccJit.Core.Block
import LeanGccJit.Core.Values
import LeanGccJit.Core.Case
import LeanGccJit.Core.Timer
import LeanGccJit.Core.Asm

namespace LeanGccJit
namespace Core

class AsObject (α : Type) where
  /-- Convert a subtype of `Object` into an `Object` -/
  asObject : α -> IO Object

/-- 
Get a string for debugging purpose. The string is typically a `C`-style
representation of the object.
-/
def getDebugString [AsObject α] (x : α) : IO String := 
  AsObject.asObject x >>= Object.getDebugString

/--
Get the associated `Context` for the `Object`.
-/
def getContext [AsObject α] (x : α) : IO Context := 
  AsObject.asObject x >>= Object.getContext
  
instance : AsObject Object := ⟨ pure ⟩
instance : AsObject RValue := ⟨ RValue.asObject ⟩
instance : AsObject LValue := ⟨ LValue.asObject ⟩
instance : AsObject JitType := ⟨ JitType.asObject ⟩
instance : AsObject Location := ⟨ Location.asObject ⟩
instance : AsObject Field := ⟨ Field.asObject ⟩
instance : AsObject ExtendedAsm := ⟨ ExtendedAsm.asObject ⟩
instance : AsObject Block := ⟨ Block.asObject ⟩
instance : AsObject Case := ⟨ Case.asObject ⟩
instance : AsObject Func := ⟨ Func.asObject ⟩
instance : AsObject Param := ⟨ Param.asObject ⟩

