import LeanGccJit.Unsafe
namespace LeanGccJit
namespace Core

abbrev Object := Unsafe.Object
abbrev RawType := Unsafe.JitType
abbrev BinaryOP := Unsafe.BinaryOp
abbrev Location := Unsafe.Location
abbrev RawTypeEnum := Unsafe.TypeEnum
abbrev Comparison := Unsafe.Comparison


-- Abstract Type
inductive AType :=
  | Raw (ty: RawTypeEnum)
  | Ptr (ty: AType)
  | Vec (ty: AType) (lanes: Nat)
  | Array (ty: AType) (size: Nat)
  | Struct (name : String) (fields: Array (String × AType))
  | Union (name: String) (fields: Array (String × AType))
  | Volatile (ty: AType)
  | Const (ty: AType)
  | FunctionPtr (retTy: AType) (argTy: Array AType) (isVar: Bool)
  | Aligned (ty: AType) (align: Nat)

def unqualified (ty: AType) : AType := 
  match ty with
  | AType.Volatile ty => unqualified ty
  | AType.Const ty => unqualified ty
  | AType.Aligned ty _ => unqualified ty
  | _ => ty

-- Instantiated Type
structure IType (tag : AType) where
  private mk::
  handle : RawType

structure Context where 
  private mk::
  handle : Unsafe.Context
  dumpBuffers: Array (String × Unsafe.DynamicBuffer)

structure RValue (tag : AType) where
  private mk::
  handle : Unsafe.RValue

structure LValue (tag : AType) where
  private mk::
  handle : Unsafe.LValue

class AsRValue (ty: AType) (x : Type) where
  asRValue : x → IO (RValue ty)

class AsObject (x : Type) where
  asObject : x → IO (Unsafe.Object)
  
instance : AsRValue (ty : AType) (RValue ty) where
  asRValue x := pure x

instance : AsObject (RValue ty) where
  asObject x := x.handle.asObject

instance : AsObject (LValue ty) where
  asObject x := x.handle.asObject

instance : AsObject (IType ty) where
  asObject x := x.handle.asObject

def getRawCtx [AsObject α] (x : α) : IO Unsafe.Context := do
  let obj ← AsObject.asObject x
  obj.getContext

def getDebugString [AsObject α] (x : α) : IO String := do
  let obj ← AsObject.asObject x
  obj.getDebugString

instance : AsRValue (ty : AType) (LValue ty) where
  asRValue x := RValue.mk <$> x.handle.asRValue

abbrev ContextT := ReaderT Context
abbrev ContextM := ContextT IO

namespace IType 
  open AType

  def createRaw (ty: RawTypeEnum) (ctx : Context) : IO (IType (Raw ty)) := 
    IType.mk <$> ctx.handle.getType ty

  def getPointer (x : IType ty) : IO (IType (Ptr ty)) := 
    IType.mk <$> x.handle.getPointer

  def getArray (x : IType ty) (len: Nat) (loc: Option Location := none) : ContextM (IType (Array ty len)) := do
    let ctx ← read
    let array ← ctx.handle.newArrayType loc x.handle len
    pure <| IType.mk array

  def getVector (x : IType ty) (lanes: Nat) : IO (IType (Vec ty lanes)) := 
    IType.mk <$> x.handle.getVector lanes

  def getVolatile (x : IType ty) : IO (IType (Volatile ty)) := 
    IType.mk <$> x.handle.getVolatile
  
  def getConst (x : IType ty) : IO (IType (Const ty)) :=
    IType.mk <$> x.handle.getConst

  def getAligned (x : IType ty) (align: Nat) : IO (IType (Aligned ty align)) := 
    IType.mk <$> x.handle.getAligned align
  
  def getUnqualified (x : IType ty) : IO (IType (unqualified ty)) := 
    IType.mk <$> x.handle.unqualified

end IType 

class IsIntegral (b : AType)

instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int) where 
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int8) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int16) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int32) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int64) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt8) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt16) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt32) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt64) where

def RValue.cast (x : RValue α) (target : IType β) (loc : Option Location := none) : ContextM (RValue β) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newCast loc x.handle target.handle)

def RValue.cmp (x : RValue α) (y : RValue α) (op : Comparison) (loc : Option Location := none) : ContextM (RValue (AType.Raw Unsafe.TypeEnum.Bool)) := do
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newComparison loc op x.handle y.handle)
