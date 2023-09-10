import LeanGccJit.Unsafe
import LeanGccJit.Utilities

namespace LeanGccJit
namespace Core

abbrev Object := Unsafe.Object
abbrev RawType := Unsafe.JitType
abbrev UnaryOp := Unsafe.UnaryOp
abbrev BinaryOp := Unsafe.BinaryOp
abbrev Location := Unsafe.Location
abbrev RawTypeEnum := Unsafe.TypeEnum
abbrev Comparison := Unsafe.Comparison
abbrev GlobalKind := Unsafe.GlobalKind

namespace Comparison 
  export Unsafe.Comparison (
    EQ
    NE
    LT
    LE
    GT
    GE
  )
end Comparison

namespace BinaryOp 
  export Unsafe.BinaryOp (
    Plus
    Minus
    Mult
    Divide
    Modulo
    BitwiseAnd
    BitwiseXor
    BitwiseOr
    LogicalAnd
    LogicalOr
    LShift
    RShift
  )
end BinaryOp

namespace UnaryOp
  export Unsafe.UnaryOp (
    Minus
    BitwiseNegate
    LogicalNegate
    Abs
  )
end UnaryOp

namespace RawTypeEnum
  export Unsafe.TypeEnum (
    Void
    VoidPtr
    Bool
    Char
    SignedChar 
    UnsignedChar
    Short
    UnsignedShort
    Int
    UnsignedInt
    Long
    UnsignedLong
    LongLong
    UnsignedLongLong
    Float
    Double
    LongDouble
    ConstCharPtr
    SizeT
    FilePtr
    ComplexFloat
    ComplexDouble
    ComplexLongDouble
    UInt8
    UInt16
    UInt32
    UInt64
    UInt128
    Int8
    Int16
    Int32
    Int64
    Int128
  )
end RawTypeEnum

-- Abstract Type
inductive AType :=
  | Raw (ty: RawTypeEnum)
  | Ptr (ty: AType)
  | Vec (ty: AType) (lanes: Nat)
  | Array (ty: AType) (size: Nat)
  | Struct (name : String) (fields: List (String × AType))
  | Union (name: String) (fields: List (String × AType))
  | Volatile (ty: AType)
  | Const (ty: AType)
  | FunctionPtr (retTy: AType) (argTy: List AType) (isVar: Bool)
  | Aligned (ty: AType) (align: Nat)
  | BitField (ty: AType) (width: Nat)

abbrev CVoid := AType.Raw RawTypeEnum.Int
abbrev CVoidPtr := AType.Raw RawTypeEnum.VoidPtr
abbrev CBool := AType.Raw RawTypeEnum.Bool
abbrev CChar := AType.Raw RawTypeEnum.Char
abbrev CSignedChar := AType.Raw RawTypeEnum.SignedChar
abbrev CUnsignedChar := AType.Raw RawTypeEnum.UnsignedChar
abbrev CShort := AType.Raw RawTypeEnum.Short
abbrev CUnsignedShort := AType.Raw RawTypeEnum.UnsignedShort
abbrev CInt := AType.Raw RawTypeEnum.Int
abbrev CUnsignedInt := AType.Raw RawTypeEnum.UnsignedInt
abbrev CLong := AType.Raw RawTypeEnum.Long
abbrev CUnsignedLong := AType.Raw RawTypeEnum.UnsignedLong
abbrev CLongLong := AType.Raw RawTypeEnum.LongLong
abbrev CUnsignedLongLong := AType.Raw RawTypeEnum.UnsignedLongLong
abbrev CFloat := AType.Raw RawTypeEnum.Float
abbrev CDouble := AType.Raw RawTypeEnum.Double
abbrev CLongDouble := AType.Raw RawTypeEnum.LongDouble
abbrev CConstCharPtr := AType.Raw RawTypeEnum.ConstCharPtr
abbrev CSizeT := AType.Raw RawTypeEnum.SizeT
abbrev CFilePtr := AType.Raw RawTypeEnum.FilePtr
abbrev CComplexFloat := AType.Raw RawTypeEnum.ComplexFloat
abbrev CComplexDouble := AType.Raw RawTypeEnum.ComplexDouble
abbrev CComplexLongDouble := AType.Raw RawTypeEnum.ComplexLongDouble
abbrev CUInt8 := AType.Raw RawTypeEnum.UInt8
abbrev CUInt16 := AType.Raw RawTypeEnum.UInt16
abbrev CUInt32 := AType.Raw RawTypeEnum.UInt32
abbrev CUInt64 := AType.Raw RawTypeEnum.UInt64
abbrev CUInt128 := AType.Raw RawTypeEnum.UInt128
abbrev CInt8 := AType.Raw RawTypeEnum.Int8
abbrev CInt16 := AType.Raw RawTypeEnum.Int16
abbrev CInt32 := AType.Raw RawTypeEnum.Int32
abbrev CInt64 := AType.Raw RawTypeEnum.Int64
abbrev CInt128 := AType.Raw RawTypeEnum.Int128

abbrev CRaw (ty: RawTypeEnum) := AType.Raw ty
abbrev CPtr (ty: AType) := AType.Ptr ty
abbrev CVec (ty: AType) (lanes: Nat) := AType.Vec ty lanes
abbrev CArray (ty: AType) (size: Nat) := AType.Array ty size
abbrev CStruct (name : String) (fields: List (String × AType)) := AType.Struct name fields
abbrev CUnion (name: String) (fields: List (String × AType)) := AType.Union name fields
abbrev CVolatile (ty: AType) := AType.Volatile ty
abbrev CConst (ty: AType) := AType.Const ty
abbrev CFunctionPtr (retTy: AType) (argTy: List AType) (isVar: Bool) := AType.FunctionPtr retTy argTy isVar
abbrev CAligned (ty: AType) (align: Nat) := AType.Aligned ty align

inductive Field (name : String) (ty: AType) : Type where
  | Normal (handle : Unsafe.Field) : Field name ty
  | BitField (handle : Unsafe.Field) (width: Nat) : Field name ty

def Field.handle (x : Field name ty) : Unsafe.Field := 
  match x with
  | Field.Normal handle => handle
  | Field.BitField handle _ => handle

abbrev HList := Utilities.HList

def FieldTypes (x : List (String × AType)) : List Type := 
  match x with
  | [] => []
  | (name, ty) :: xs => (Field name ty) :: FieldTypes xs

inductive IType : AType → Type where
  | Raw : (handle: RawType) → IType (AType.Raw raw)
  | Ptr : (handle: RawType) → IType (AType.Ptr ty)
  | Vec : (handle: RawType) → IType (AType.Vec ty lanes)
  | Array : (handle: RawType) → IType (AType.Array ty size)
  | Struct : (handle: RawType) → (params: HList (FieldTypes fields)) → IType (AType.Struct name fields)
  | Union : (handle: RawType) → (params: HList (FieldTypes fields)) → IType (AType.Union name fields)
  | Volatile : (handle: RawType) → IType (AType.Volatile ty)
  | Const : (handle: RawType) → IType (AType.Const ty)
  | FunctionPtr : (handle: RawType) → IType (AType.FunctionPtr retTy argTy isVar)
  | Aligned : (handle: RawType) → IType (AType.Aligned ty align)

def IType.handle {ty} (x : IType ty) : RawType := 
  match x with
  | IType.Raw handle => handle
  | IType.Ptr handle => handle
  | IType.Vec handle => handle
  | IType.Array handle => handle
  | IType.Struct handle _ => handle
  | IType.Union handle _ => handle
  | IType.Volatile handle => handle
  | IType.Const handle => handle
  | IType.FunctionPtr handle => handle
  | IType.Aligned handle => handle

class IsIntegral (b : AType)

instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int8) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int16) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int32) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int64) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int128) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt8) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt16) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt32) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt64) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UInt128) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.SizeT) where

instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Int) where 
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Char) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Short) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.Long) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.LongLong) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UnsignedChar) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UnsignedShort) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UnsignedInt) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UnsignedLong) where
instance : IsIntegral (AType.Raw Unsafe.TypeEnum.UnsignedLongLong) where

class IsPointer (a : AType)
instance : IsPointer (AType.Ptr ty) where
instance [IsPointer ty] : IsPointer (AType.Volatile ty) where
instance [IsPointer ty] : IsPointer (AType.Const ty) where
instance : IsPointer (AType.Raw Unsafe.TypeEnum.ConstCharPtr) where
instance : IsPointer (AType.Raw Unsafe.TypeEnum.VoidPtr) where
instance : IsPointer (AType.Raw Unsafe.TypeEnum.FilePtr) where

class Dereferenceable (α : AType) (ω: outParam AType) extends IsPointer α where 
instance : Dereferenceable (CPtr α) (α) where
instance : Dereferenceable (CConstCharPtr) (CChar) where
instance [Dereferenceable α ω] : Dereferenceable (AType.Volatile α) ω  where
instance [Dereferenceable α ω] : Dereferenceable (AType.Const α) ω where

class Indexible (α : AType) (ω : outParam AType) where 
instance : Indexible (CArray α ℓ) α where
instance [Dereferenceable α ω] : Indexible (CPtr α) ω where
instance [Indexible α ω] : Indexible (AType.Volatile α) ω where
instance [Indexible α ω] : Indexible (AType.Const α) ω where

class IsFloatingPoint (b : AType)
instance : IsFloatingPoint CFloat where
instance : IsFloatingPoint CDouble where
instance : IsFloatingPoint CLongDouble where

class IsComplex (b : AType)
instance : IsComplex CComplexFloat where
instance : IsComplex CComplexDouble where
instance : IsComplex CComplexLongDouble where

class IsSigned (b : AType)
instance : IsSigned CInt where
instance : IsSigned CLong where
instance : IsSigned CLongLong where
instance : IsSigned CShort where
instance : IsSigned CSignedChar where
instance : IsSigned CFloat where
instance : IsSigned CDouble where
instance : IsSigned CLongDouble where
instance : IsSigned CInt8 where
instance : IsSigned CInt16 where
instance : IsSigned CInt32 where
instance : IsSigned CInt64 where
instance : IsSigned CInt128 where

class IsPlainNumber (x : AType) where
instance [IsIntegral x] : IsPlainNumber x where
instance [IsFloatingPoint x] : IsPlainNumber x where

structure Param (name : String) (ty : AType) where
  private mk::
  handle : Unsafe.Param

def ParamTypes (x : List (String × AType)) : List Type := 
  match x with
  | [] => []
  | (name, ty) :: xs => (Param name ty) :: ParamTypes xs

structure Func (μ : AType) (δ : List (String × AType)) where
  private mk::
  handle : Unsafe.Func
  ret : IType μ
  params : HList (ParamTypes δ)

structure Block where
  private mk::
  handle : Unsafe.Block



