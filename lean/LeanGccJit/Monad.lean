import LeanGccJit.Unsafe
import LeanGccJit.Types
namespace LeanGccJit
namespace Core

private def collectFieldHandles (fields : List (String × AType)) (hFields : HList (FieldTypes fields)) : StateT (Array Unsafe.Field) Id Unit := 
  match fields, hFields with
  | [], () => pure ()
  | [_], h => do
    let h := h.handle
    let arr ← get
    set <| arr.push h
  | _::t::ts, (b, bs) => do
    let h := b.handle
    let arr ← get
    set <| arr.push h
    collectFieldHandles (t::ts) bs

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

class AsObject (x : Type u) where
  asObject : x → IO (Unsafe.Object)

instance : AsObject (RValue ty) where
  asObject x := x.handle.asObject

instance : AsObject (LValue ty) where
  asObject x := x.handle.asObject

instance : AsObject (IType ty) where
  asObject x := x.handle.asObject

abbrev ContextT := ReaderT Context
abbrev ContextM := ContextT IO

@[always_inline, inline]
def getCtx : ContextM Context := read

@[always_inline, inline]
def getRawCtx : ContextM Unsafe.Context := 
  read >>= fun x => pure x.handle

@[always_inline, inline]
def getRawCtxFromObject [AsObject α] (x : α) : IO Unsafe.Context :=
  AsObject.asObject x >>= fun obj => obj.getContext

@[always_inline, inline]
def getDebugString [AsObject α] (x : α) : IO String := 
  AsObject.asObject x >>= fun obj => obj.getDebugString

@[always_inline, inline]
def LValue.asRValue (x : LValue α) : IO (RValue α) := 
  RValue.mk <$> x.handle.asRValue

namespace IType 
  open AType

  def createRaw (α: RawTypeEnum) : ContextM (IType (CRaw α)) := 
    IType.Raw <$> (read >>= fun ctx => ctx.handle.getType α)

  def getPointer (x : IType α) : IO (IType (CPtr α)) := 
    IType.Ptr <$> x.handle.getPointer

  def getArray (x : IType α) (len: Nat) (loc: Option Location := none) : ContextM (IType (CArray α len)) := do
    let ctx ← getRawCtx
    let handle ← ctx.newArrayType loc x.handle len
    pure <| IType.Array handle

  def getVector (x : IType α) (lanes: Nat) : IO (IType (CVec α lanes)) := 
    IType.Vec <$> x.handle.getVector lanes

  def getVolatile (x : IType α) : IO (IType (CVolatile α)) := 
    IType.Volatile <$> x.handle.getVolatile
  
  def getConst (x : IType α) : IO (IType (CConst α)) :=
    IType.Const <$> x.handle.getConst

  def getAligned (x : IType α) (align: Nat) : IO (IType (CAligned α align)) := 
    IType.Aligned <$> x.handle.getAligned align

  def newField (x : IType α) (name: String) (loc: Option Location := none) : ContextM (Field name α) := 
    Field.Normal <$> (read >>= fun ctx => ctx.handle.newField loc x.handle name)

  def newBitField (x : IType α) (name: String) (width: Nat) (loc: Option Location := none) : ContextM (Field name α) := 
    Field.BitField <$> (read >>= fun ctx => ctx.handle.newBitField loc x.handle width name) <*> pure width

  def newStruct (name: String) (fields: HList (FieldTypes δ)) (loc: Option Location := none) : ContextM (IType (CStruct name δ)) := do
    let ctx ← getRawCtx
    let (_, handles) := collectFieldHandles δ fields |>.run #[]
    let handle ← ctx.newStructType loc name handles
    pure <| IType.Struct (← handle.asJitType) fields

  def newUnion (name: String) (fields: HList (FieldTypes δ)) (loc: Option Location := none) : ContextM (IType (CUnion name δ)) := do
    let ctx ← getRawCtx
    let (_, handles) := collectFieldHandles δ fields |>.run #[]
    let handle ← ctx.newUnionType loc name handles
    pure <| IType.Union handle fields
end IType

def newCast (x : RValue α)(target : IType β) (loc : Option Location := none) : ContextM (RValue β) :=
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newCast loc x.handle target.handle)

def newComparison  (x : RValue α)  (op : Comparison) (y : RValue α) (loc : Option Location := none) 
  : ContextM (RValue (AType.Raw Unsafe.TypeEnum.Bool)) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newComparison loc op x.handle y.handle)

def newRValueFromUInt32 (ty : IType τ) [IsIntegral τ] (x : UInt32) : ContextM (RValue τ) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newRValueFromUInt32 ty.handle x)

def newRValueFromUInt64 (ty : IType τ) [IsIntegral τ] (x : UInt64) : ContextM (RValue τ) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newRValueFromUInt64 ty.handle x)

def newRValueFromAddr (ty : IType τ) [IsPointer τ] (x : USize) : ContextM (RValue τ) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newRValueFromAddr ty.handle x)

def createGlobal (ty: IType α) (kind: GlobalKind) (name: String) (loc: Option Location := none) : ContextM (LValue α) := 
  LValue.mk <$> (read >>= fun ctx => ctx.handle.newGlobal loc kind ty.handle name)

def dereference  (ptr : RValue α) [Dereferenceable α ω] (loc: Option Location := none) : IO (LValue ω) := 
  LValue.mk <$> ptr.handle.dereference loc

def newArrayAccess (ptr : RValue α) [Indexible α ω] (idx: RValue β) [ IsIntegral β ] (loc: Option Location := none) : ContextM (LValue ω) := 
  LValue.mk <$> (read >>= fun ctx => ctx.handle.newArrayAccess loc ptr.handle idx.handle)

def newNull (ty: IType α) [IsPointer α] : ContextM (RValue α) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.null ty.handle)

def newOne (ty: IType α) [IsIntegral α] : ContextM (RValue α) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.one ty.handle)

def newZero (ty: IType α) [IsIntegral α] : ContextM (RValue α) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.zero ty.handle)

def newZeroedArray (ty: IType (AType.Array α n)) (loc: Option Location := none) : ContextM (RValue (AType.Array α n)) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newArrayConstructor loc ty.handle #[])

def newFilledArray 
  (array: Array (RValue α)) (ty: IType (AType.Array α array.size)) (loc: Option Location := none) 
  : ContextM (RValue (AType.Array α array.size)) := 
  RValue.mk <$> (read >>= fun ctx => ctx.handle.newArrayConstructor loc ty.handle <| array.map (·.handle))

def LValue.accessStructField (x : LValue (CStruct n δ)) (f : Field m β) (_ : (m, β) ∈ δ) (loc: Option Location := none) : IO (LValue β) := 
  LValue.mk <$> x.handle.accessField loc f.handle

def LValue.accessStructField! (x : LValue (CStruct n δ)) (f : Field m β) (loc: Option Location := none) : IO (LValue β) := 
  LValue.mk <$> x.handle.accessField loc f.handle
  
def RValue.accessStructField (x : RValue (CStruct n δ)) (f : Field m β) (_ : (m, β) ∈ δ) (loc: Option Location := none) : IO (RValue β) := 
  RValue.mk <$> x.handle.accessField loc f.handle

def RValue.accessStructField! (x : RValue (CStruct n δ)) (f : Field m β) (loc: Option Location := none) : IO (RValue β) := 
  RValue.mk <$> x.handle.accessField loc f.handle

def LValue.accessUnionField (x : LValue (CUnion n δ)) (f : Field m β) (_ : (m, β) ∈ δ) (loc: Option Location := none) : IO (LValue β) := 
  LValue.mk <$> x.handle.accessField loc f.handle

def LValue.accessUnionField! (x : LValue (CUnion n δ)) (f : Field m β) (loc: Option Location := none) : IO (LValue β) := 
  LValue.mk <$> x.handle.accessField loc f.handle
  
def RValue.accessUnionField (x : RValue (CUnion n δ)) (f : Field m β) (_ : (m, β) ∈ δ) (loc: Option Location := none) : IO (RValue β) := 
  RValue.mk <$> x.handle.accessField loc f.handle

def RValue.accessUnionField! (x : RValue (CUnion n δ)) (f : Field m β) (loc: Option Location := none) : IO (RValue β) := 
  RValue.mk <$> x.handle.accessField loc f.handle

@[reducible]
private def names (x : List (String × AType)) : List String := 
  match x with
  | [] => []
  | (name, _) :: xs => name :: names xs

@[reducible]
private def Proj (x : List (String × AType)) (n : List String) : List AType := 
  match x, n with
  | [], _ => []
  | _, [] => []
  | (u, ty) :: xs, v::ns => if u == v then ty :: Proj xs ns else Proj xs n

private def getFields (x : List (String × AType)) (h : HList (FieldTypes x)) (n : List String)  : List Unsafe.Field := 
  match x, h, n with
  | [], _, _ => []
  | _, _, [] => []
  | [(u, _)], t, x::_ => if u == x then [t.handle] else []
  | (u, ty) :: x :: xs, (t, ts), v::ns => 
    if u == v then t.handle :: getFields (x::xs) ts ns else getFields ((u, ty) :: x :: xs) (t, ts) ns

private def getHandles {x : List AType}(values : HList <| x.map RValue) : StateT (Array Unsafe.RValue) Id Unit :=
  match x, values with
  | [], () => pure ()
  | [_], h => do
    let h := h.handle
    let arr ← get
    set <| arr.push h
  | _::t::ts, (b, bs) => do
    let h := b.handle
    let arr ← get
    set <| arr.push h
    @getHandles (t::ts) bs

def newStructConstructor 
  (ty: IType (CStruct n δ)) 
  (names : List String) 
  (values : HList ((Proj δ names).map RValue)) (loc: Option Location := none) : ContextM (RValue (CStruct n δ)) := 
  match ty with
  | IType.Struct handle fields => do
    let selected := getFields δ fields names
    let ctx ← getRawCtx
    let (_, values) := getHandles values |>.run #[]
    RValue.mk <$> ctx.newStructConstructor loc handle selected.toArray values

def newZeroStructConstructor
  (ty: IType (CStruct n δ)) (loc: Option Location := none) : ContextM (RValue (CStruct n δ)) := 
    RValue.mk <$> (getRawCtx >>= fun ctx => ctx.newStructConstructor loc ty.handle none #[])

def getAddress (x : LValue α) (loc: Option Location := none) : IO (RValue (CPtr α)) := 
  RValue.mk <$> x.handle.getAddress loc 

def logicalNegate (x : RValue CBool) (loc: Option Location := none) : ContextM (RValue CBool) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newUnaryOp loc UnaryOp.LogicalNegate ty x.handle

def abs (x : RValue α) [IsSigned α] (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newUnaryOp loc UnaryOp.Abs ty x.handle

def unaryMinus (x : RValue α) [IsPlainNumber α] (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newUnaryOp loc UnaryOp.Minus ty x.handle

def bitwiseNegate (x : RValue α) [IsIntegral α] (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newUnaryOp loc UnaryOp.BitwiseNegate ty x.handle

def plus [IsPlainNumber α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.Plus ty x.handle y.handle

def minus [IsPlainNumber α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.Minus ty x.handle y.handle

def multiply [IsPlainNumber α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.Mult ty x.handle y.handle

def divide [IsPlainNumber α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.Divide ty x.handle y.handle

def modulo [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.Modulo ty x.handle y.handle

def bitwiseAnd [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.BitwiseAnd ty x.handle y.handle

def bitwiseOr [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.BitwiseOr ty x.handle y.handle

def bitwiseXor [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.BitwiseXor ty x.handle y.handle

def shiftLeft [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.LShift ty x.handle y.handle

def shiftRight [IsIntegral α] (x : RValue α) (y : RValue α) (loc: Option Location := none) : ContextM (RValue α) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.RShift ty x.handle y.handle

def logicalAnd (x : RValue CBool) (y : RValue CBool) (loc: Option Location := none) : ContextM (RValue CBool) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.LogicalAnd ty x.handle y.handle

def logicalOr (x : RValue CBool) (y : RValue CBool) (loc: Option Location := none) : ContextM (RValue CBool) := do
  let ty ← x.handle.getType
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newBinaryOp loc BinaryOp.LogicalOr ty x.handle y.handle

def newStringLiteral (x : String)  : ContextM (RValue CConstCharPtr) := do
  let ctx ← getRawCtx
  RValue.mk <$> ctx.newStringLiteral x

abbrev FuncT μ δ  := ReaderT (Func μ δ)
abbrev FunctionM μ δ := FuncT μ δ ContextM
abbrev BlockT := ReaderT Block
abbrev BlockM μ δ := BlockT (FunctionM μ δ)


def newBlockWithReturn (name : Option String) (x : BlockM μ δ (RValue α × Option Location × τ))  : FunctionM μ δ τ := do
  let func ← read
  let blk ← Block.mk <$> func.handle.newBlock name
  let (val, loc, res) ← x.run blk
  blk.handle.endWithReturn loc val.handle
  pure res

def newBlockWithJump (name : Option String) (x : BlockM μ δ (Option Location × Block × τ)) : FunctionM μ δ τ := do
  let func ← read
  let blk ← Block.mk <$> func.handle.newBlock name
  let (loc, blk', res) ← x.run blk
  blk.handle.endWithJump loc blk'.handle
  pure res

def newBlockWithConditional 
  (name : Option String) 
  (x : BlockM μ δ (RValue CBool × Option Location × Block × Block × τ)) : FunctionM μ δ τ := do
  let func ← read
  let blk ← Block.mk <$> func.handle.newBlock name
  let (val, loc, blk₀, blk₁, res) ← x.run blk
  blk.handle.endWithConditional loc val.handle blk₀.handle blk₁.handle
  pure res

structure Switch (α : AType) where
  location : Option Location
  value: RValue α
  default : Block
  cases : Array Case
  
def newBlockWithSwitch [IsIntegral α] (name : Option String) (x : BlockM μ δ (Switch α × τ)) : FunctionM μ δ τ := do
  let func ← read
  let blk ← Block.mk <$> func.handle.newBlock name
  let (switch, res) ← x.run blk
  blk.handle.endWithSwitch switch.location switch.value.handle switch.default.handle switch.cases
  pure res
-- def TestStruct := CStruct "TestStruct" [("a", CInt), ("b", CInt)]

-- def testVal (ty : IType TestStruct) : ContextM (RValue TestStruct) := do
--   let int ← IType.createRaw RawTypeEnum.Int
--   let zero ← newZero int
--   newStructConstructor ty ["a"] zero



-- namespace test
-- open AType


-- end test