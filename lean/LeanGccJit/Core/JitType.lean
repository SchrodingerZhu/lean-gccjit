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
/--
Generate a `JitType` for a function pointer with the given return type and parameters.

Each of param_types must be non-`void`; return_type may be `void`.
-/
@[extern "lean_gcc_jit_context_new_function_ptr_type"]
opaque Context.newFunctionPtrType 
  (ctx : @& Context) (location : @& Option Location) (returnType : @& JitType) (params: @& Array JitType) (isVarArg : @& Bool) : IO JitType

/--
Given non-void type `T`, get type:
```c
T __attribute__ ((aligned (ALIGNMENT_IN_BYTES)))
```
The alignment must be a power of two.
-/
@[extern "lean_gcc_jit_type_get_aligned"]
opaque JitType.getAligned (ty : @& JitType) (alignment : @& Nat) : IO JitType

/--
Given type `T`, get type:
```
T  __attribute__ ((vector_size (sizeof(T) * num_units))
```
`T` must be integral or floating point; num_units must be a power of two.

This can be used to construct a vector type in which operations are applied element-wise. 
The compiler will automatically use SIMD instructions where possible. 

See also [Vector Extensions](https://gcc.gnu.org/onlinedocs/gcc/Vector-Extensions.html).
-/
@[extern "lean_gcc_jit_type_get_vector"]
opaque JitType.getVector (ty : @& JitType) (length : @& Nat) : IO JitType

/--
Get the element type of an array type or `none` if it’s not an array.
-/
@[extern "lean_gcc_jit_type_dyncast_array"]
opaque JitType.dynCastArray (ty : @& JitType) : IO (Option JitType)

/--
Return `true` if the type is a bool.
-/
@[extern "lean_gcc_jit_type_is_bool"]
opaque JitType.isBool (ty : @& JitType) : IO Bool

/--
Return the function type if it is one or `none`.
-/
@[extern "lean_gcc_jit_type_dyncast_function_ptr_type"]
opaque JitType.dynCastFunctionPtrType (ty : @& JitType) : IO (Option FunctionType)

/--
Given a function type, return its return type.
-/
@[extern "lean_gcc_jit_function_type_get_return_type"]
opaque FunctionType.getReturnType (ty : @& FunctionType) : IO JitType

/--
Given a function type, return its number of parameters.
-/
@[extern "lean_gcc_jit_function_type_get_param_count"]
opaque FunctionType.getParamCount (ty : @& FunctionType) : IO Nat

/--
Given a function type, return the type of the specified parameter.
-/
@[extern "lean_gcc_jit_function_type_get_param_type"]
opaque FunctionType.getParamType (ty : @& FunctionType) (i : @& Nat) : IO JitType

/--
Return `true` if the type is an integral.
-/
@[extern "lean_gcc_jit_type_is_integral"]
opaque JitType.isIntegral (ty : @& JitType) : IO Bool

/--
Return the type pointed by the pointer type or `none` if it’s not a pointer.
-/
@[extern "lean_gcc_jit_type_is_pointer"]
opaque JitType.isPointer (ty : @& JitType) : IO (Option JitType)

/--
Given a type, return a dynamic cast to a vector type or `none`.
-/
@[extern "lean_gcc_jit_type_dyncast_vector"]
opaque JitType.dynCastVector (ty : @& JitType) : IO (Option VectorType)

/--
Given a type, return a dynamic cast to a struct type or `none`.
-/
@[extern "lean_gcc_jit_type_is_struct"]
opaque JitType.isStruct (ty : @& JitType) : IO (Option JitType)

/--
Given a vector type, return the number of units it contains.
-/
@[extern "lean_gcc_jit_vector_type_get_num_units"]
opaque VectorType.getNumUnits (ty : @& VectorType) : IO Nat

/--
Given a vector type, return the type of its elements.
-/
@[extern "lean_gcc_jit_vector_type_get_element_type"]
opaque VectorType.getElementType (ty : @& VectorType) : IO JitType

/--
Given a type, return the unqualified type, removing `const`, `volatile` and alignment qualifiers.
-/
@[extern "lean_gcc_jit_type_unqualified"]
opaque JitType.unqualified (ty : @& JitType) : IO JitType
