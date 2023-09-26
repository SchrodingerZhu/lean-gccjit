import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core

/--
Access a specific type. See `LeanGccJit.Core.TypeEnum` for the list of types.
-/
@[extern "lean_gcc_jit_context_get_type"]
opaque Context.getType (ctx : @& Context) (type : @& TypeEnum) : IO JitType

/--
Upcast a `JitType` to an `Object`.
-/
@[extern "lean_gcc_jit_type_as_object"]
opaque JitType.asObject (ty : @& JitType) : IO Object

/--
Access the integer type of the given size.
-/
@[extern "lean_gcc_jit_context_get_int_type"]
opaque Context.getIntType 
(ctx : @& Context) (numBytes : @& Nat) (isSigned: @& Bool)  : IO JitType

/--
Given type `T`, get type `T*`.
-/
@[extern "lean_gcc_jit_type_get_pointer"]
opaque JitType.getPointer (ty : @& JitType) : IO JitType
/--
Given type `T`, get type `const T`.
-/
@[extern "lean_gcc_jit_type_get_const"]
opaque JitType.getConst (ty : @& JitType) : IO JitType
/--
Given type `T`, get type `volatile T`.
-/
@[extern "lean_gcc_jit_type_get_volatile"]
opaque JitType.getVolatile (ty : @& JitType) : IO JitType
/--
Return non-zero if the two types are compatible. 
For instance, if `uint64_t` and `unsigned long` are the same size on the target, 
this will return non-zero.
-/
@[extern "lean_gcc_jit_compatible_types"]
opaque JitType.isCompatibleWith (ty1 ty2 : @& JitType) : IO Bool
/--
Return the size of a type, in bytes. It only works on integer types for now. 
-/
@[extern "lean_gcc_jit_type_get_size"]
opaque JitType.getSize (ty: @& JitType) : IO Nat
/--
Given non-void type `T`, get type `T[N]` (for a constant N).
-/
@[extern "lean_gcc_jit_context_new_array_type"]
opaque Context.newArrayType 
  (ctx : @& Context) (location : @& Option Location) (elemType : @& JitType) (size : @& Nat) : IO JitType
/--
Construct a new union type, with the given name and fields.
-/
@[extern "lean_gcc_jit_context_new_union_type"]
opaque Context.newUnionType 
  (ctx : @& Context) (location : @& Option Location) (name : @& String) (fields: @& Array Field) : IO JitType

@[extern "lean_gcc_jit_context_new_function_ptr_type"]
opaque Context.newFunctionPtrType 
  (ctx : @& Context) (location : @& Option Location) (returnType : @& JitType) (params: @& Array JitType) (isVarArg : @& Bool) : IO JitType

@[extern "lean_gcc_jit_type_get_aligned"]
opaque JitType.getAligned (ty : @& JitType) (alignment : @& Nat) : IO JitType

@[extern "lean_gcc_jit_type_get_vector"]
opaque JitType.getVector (ty : @& JitType) (length : @& Nat) : IO JitType

@[extern "lean_gcc_jit_type_dyncast_array"]
opaque JitType.dynCastArray (ty : @& JitType) : IO (Option JitType)

@[extern "lean_gcc_jit_type_is_bool"]
opaque JitType.isBool (ty : @& JitType) : IO Bool

@[extern "lean_gcc_jit_type_dyncast_function_ptr_type"]
opaque JitType.dynCastFunctionPtrType (ty : @& JitType) : IO (Option FunctionType)

@[extern "lean_gcc_jit_function_type_get_return_type"]
opaque FunctionType.getReturnType (ty : @& FunctionType) : IO JitType

@[extern "lean_gcc_jit_function_type_get_param_count"]
opaque FunctionType.getParamCount (ty : @& FunctionType) : IO Nat

@[extern "lean_gcc_jit_function_type_get_param_type"]
opaque FunctionType.getParamType (ty : @& FunctionType) (i : @& Nat) : IO JitType

@[extern "lean_gcc_jit_type_is_integral"]
opaque JitType.isIntegral (ty : @& JitType) : IO Bool

@[extern "lean_gcc_jit_type_is_pointer"]
opaque JitType.isPointer (ty : @& JitType) : IO (Option JitType)

@[extern "lean_gcc_jit_type_dyncast_vector"]
opaque JitType.dynCastVector (ty : @& JitType) : IO (Option VectorType)

@[extern "lean_gcc_jit_vector_type_get_num_units"]
opaque VectorType.getNumUnits (ty : @& VectorType) : IO Nat

@[extern "lean_gcc_jit_vector_type_get_element_type"]
opaque VectorType.getElementType (ty : @& VectorType) : IO JitType

@[extern "lean_gcc_jit_type_unqualified"]
opaque JitType.unqualified (ty : @& JitType) : IO JitType
