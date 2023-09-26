import LeanGccJit.Core.Types
namespace LeanGccJit
namespace Core
/-!
This module contains the core API of constructing expressions. 

See also the [C API documentation](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html).
-/

/-- 
Add a new global variable of the given type and name to the context.

The parameter type must be non-void.

See `LeanGccJit.Core.GlobalKind` for visibility options.
-/
@[extern "lean_gcc_jit_context_new_global"]
opaque Context.newGlobal (ctx : @& Context) (loc : @& Option Location) (kind: @& GlobalKind) (type : @& JitType) (name : @& String)  : IO LValue

/--
Create a constructor for a struct as an rvalue.

`type` specifies what the constructor will build and has to be a struct.

`fields` need to have the same length as `values`, or `none`.

If fields is `none`, the values are applied in definition order.

Otherwise, each field in fields specifies which field in the struct to set to the corresponding value in `values`. `fields` and `values` are paired by index.

The fields in `fields` have to be in definition order, but there can be gaps. Any field in the struct that is not specified in `fields` will be zeroed.

The fields in `fields` need to be the same objects that were used to create the struct.

Each value has to have have the same unqualified type as the field it is applied to.

A `none` value element in values is a shorthand for zero initialization of the corresponding field.

-/
@[extern "lean_gcc_jit_context_new_struct_constructor"]
opaque Context.newStructConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (fields: @& Option (Array Field)) (values: @& Array (Option RValue))  : IO RValue
/--
Create a constructor for a union as an rvalue.

`type` specifies what the constructor will build and has to be an union.

`field` specifies which field to set. If it is `non`, the first field in the union will be set. 
`field` need to be the same object that were used to create the union.

`value` specifies what value to set the corresponding field to. If value is `none`, 
zero initialization will be used.

Each value has to have have the same unqualified type as the field it is applied to.
-/
@[extern "lean_gcc_jit_context_new_union_constructor"]
opaque Context.newUnionConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (field: @& Option Field) (value: @& Option RValue)  : IO RValue

/--
Create a constructor for an array as an rvalue.

`type` specifies what the constructor will build and has to be an array.

`values` can’t have more elements than the array type.

Each value in `values` sets the corresponding value in the array. If the array type itself has more elements than `values`, the left-over elements will be zeroed.

Each value in `values` need to be the same unqualified type as the array type’s element type.
-/
@[extern "lean_gcc_jit_context_new_array_constructor"]
opaque Context.newArrayConstructor 
  (ctx : @& Context) (loc : @& Option Location) (type : @& JitType) (values: @& Array RValue)  : IO RValue

/--
Set the initial value of a global with an rvalue.

The rvalue needs to be a constant expression, e.g. no function calls.

The global can’t have the kind `LeanGccJit.Core.GlobalKind.Imported`.

Returns the global itself.
-/
@[extern "lean_gcc_jit_global_set_initializer_rvalue"]
opaque Global.setInitializerRValue 
  (glob : @& LValue) (value: @& Array RValue) : IO LValue

/--
Set an initializer for global using the memory content pointed by `value`. The global `LValue` must be an array of an integral type. 
Returns the global itself.

The content will be stored in the compilation unit and used as initialization value of the array.
-/
@[extern "lean_gcc_jit_global_set_initializer"]
opaque Global.setInitializer
  (glob : @& LValue) (value: @& ByteArray) : IO LValue

/--
Upcast an `LValue` to an `Object`.
-/
@[extern "lean_gcc_jit_lvalue_as_object"]
opaque LValue.asObject (lval : @& LValue) : IO Object

/--
Upcast an `LValue` to an `RValue`.
-/
@[extern "lean_gcc_jit_lvalue_as_rvalue"]
opaque LValue.asRValue (lval : @& LValue) : IO RValue

/--
Upcast a `RValue` to an `Object`.
-/
@[extern "lean_gcc_jit_rvalue_as_object"]
opaque RValue.asObject (rval : @& RValue) : IO Object

/-- Get the type of this rvalue. -/
@[extern "lean_gcc_jit_rvalue_get_type"]
opaque RValue.getType(rval : @& RValue) : IO JitType

/-- 
Create a new `RValue` (integer or floating point) from a `UInt32` literal. 

This is a wrapper around []`gcc_jit_context_new_rvalue_from_int`](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#c.gcc_jit_context_new_rvalue_from_int).
-/
@[extern "lean_gcc_jit_context_new_rvalue_from_uint32"]
opaque Context.newRValueFromUInt32 (ctx : @& Context) (ty : @& JitType) (val : UInt32) : IO RValue

/--
Create a new `RValue` (integer or floating point) from a `UInt64` literal.

This is a wrapper around [`gcc_jit_context_new_rvalue_from_long`](https://gcc.gnu.org/onlinedocs/jit/topics/expressions.html#c.gcc_jit_context_new_rvalue_from_long).
-/
@[extern "lean_gcc_jit_context_new_rvalue_from_uint64"]
opaque Context.newRValueFromUInt64 (ctx : @& Context) (ty : @& JitType) (val : UInt64) : IO RValue

/--
Given a numeric type (integer or floating point), get the rvalue for zero.
-/
@[extern "lean_gcc_jit_context_zero"]
opaque Context.zero (ctx : @& Context) (ty : @& JitType) : IO RValue

/--
Given a numeric type (integer or floating point), get the rvalue for one.
-/
@[extern "lean_gcc_jit_context_one"]
opaque Context.one (ctx : @& Context) (ty : @& JitType) : IO RValue

/--
Given a numeric type (integer or floating point), build an rvalue for the given constant `Float` value.
-/
@[extern "lean_gcc_jit_context_new_rvalue_from_double"]
opaque Context.newRValueFromDouble (ctx : @& Context) (ty : @& JitType) (val: Float) : IO RValue

/--
Given a pointer type, build an rvalue for the given address (encoded in `USize`).
-/
@[extern "lean_gcc_jit_context_new_rvalue_from_addr"]
opaque Context.newRValueFromAddr (ctx : @& Context) (ty : @& JitType) (addr: USize) : IO RValue

/--
Given a pointer type, build an rvalue for the given address.
-/
@[extern "lean_gcc_jit_context_null"]
opaque Context.null (ctx : @& Context) (ty : @& JitType): IO RValue

/--
Generate an rvalue for the given NIL-terminated string, of type `const char *`.
-/
@[extern "lean_gcc_jit_context_new_string_literal"]
opaque Context.newStringLiteral (ctx : @& Context) (str: @& String) : IO RValue

/--
Build a unary operation out of an input rvalue.

The parameter `ty` must be a numeric type.
-/
@[extern "lean_gcc_jit_context_new_unary_op"]
opaque Context.newUnaryOp 
  (ctx : @& Context) (loc : @& Option Location) (op : @& UnaryOp) (ty : @& JitType) (val : @& RValue) : IO RValue

/--
Build a binary operation out of two constituent rvalues.
The parameter `ty` must be a numeric type.
-/
@[extern "lean_gcc_jit_context_new_binary_op"]
opaque Context.newBinaryOp 
  (ctx : @& Context) (loc : @& Option Location) (op : @& BinaryOp) (ty : @& JitType) (a : @& RValue) (b : @& RValue) : IO RValue

/--
Build a boolean rvalue out of the comparison of two other rvalues.
-/
@[extern "lean_gcc_jit_context_new_comparison"]
opaque Context.newComparison 
  (ctx : @& Context) (loc : @& Option Location) (op : @& Comparison) (a : @& RValue) (b : @& RValue) : IO RValue

/--
Given a function and the given table of argument rvalues, construct a call to the function, with the result as an rvalue.

## Note
This function merely builds a `RValue` i.e. an expression that can be evaluated, perhaps as part of a more complicated expression. 
The call won’t happen unless you add a statement to a function that evaluates the expression.
-/
@[extern "lean_gcc_jit_context_new_call"]
opaque Context.newCall 
  (ctx : @& Context) (loc : @& Option Location) (fn : @& Func) (args : @& Array RValue) : IO RValue

/--
Given an rvalue of function pointer type, and the given table of argument rvalues, 
construct a call to the function pointer, with the result as an rvalue.
-/
@[extern "lean_gcc_jit_context_new_call_through_ptr"]
opaque Context.newCallThroughPtr 
  (ctx : @& Context) (loc : @& Option Location) (fnPtr : @& RValue) (args : @& Array RValue) : IO RValue

/--
Given an rvalue of T, construct another rvalue of another type.
Currently only a limited set of conversions are possible:
- `int` ⇔ `float`
- `int` ⇔ `bool`
- `P *` ⇔ `Q *`
-/
@[extern "lean_gcc_jit_context_new_cast"]
opaque Context.newCast 
  (ctx : @& Context) (loc : @& Option Location)  (val : @& RValue) (ty : @& JitType) : IO RValue

/--
Given an rvalue of T, bitcast it to another type, 
meaning that this will generate a new rvalue by interpreting the bits of rvalue to the layout of type.

The type of `val` must be the same size as the size of `ty`.
-/
@[extern "lean_gcc_jit_context_new_bitcast"]
opaque Context.newBitCast 
  (ctx : @& Context) (loc : @& Option Location)  (val : @& RValue) (ty : @& JitType) : IO RValue

/--
Set the alignment of a variable, in bytes. Analogous to:
```c
int variable __attribute__((aligned (16)));
```
-/
@[extern "lean_gcc_jit_lvalue_set_alignment"]
opaque LValue.setAlignment (lval : @& LValue) (align : @& Nat) : IO PUnit

/--
Return the alignment of a variable set by `LValue.setAlignment`. 
Return 0 if the alignment was not set. Analogous to:
```c
_Alignof (variable)
```
-/
@[extern "lean_gcc_jit_lvalue_get_alignment"]
opaque LValue.getAlignment (lval : @& LValue) : IO Nat

/--
Given an rvalue of pointer type `T *`, get at the element `T` at the given index, 
using standard C array indexing rules i.e. each increment of index corresponds to `sizeof(T)` bytes. 
Analogous to:
```c
PTR[INDEX]
```
-/
@[extern "lean_gcc_jit_context_new_array_access"]
opaque Context.newArrayAccess 
  (ctx : @& Context) (loc : @& Option Location) (ptr : @& RValue) (index : @& RValue) : IO LValue

/--
Given an lvalue of struct or union type, access the given field as an lvalue. Analogous to:
```c
(EXPR).field = ...;
```
-/
@[extern "lean_gcc_jit_lvalue_access_field"]
opaque LValue.accessField 
  (lval : @& LValue) (loc : @& Option Location) (field : @& Field) : IO LValue

/--
Given an rvalue of struct or union type, access the given field as an rvalue. Analogous to:
```c
(EXPR).field
```
-/
@[extern "lean_gcc_jit_rvalue_access_field"]
opaque RValue.accessField 
  (rval : @& RValue) (loc : @& Option Location) (field : @& Field) : IO RValue

/--
Given an rvalue of pointer type `T *` where `T` is of struct or union type, access the given field as an lvalue. Analogous to:
```c
(EXPR)->field
```
-/
@[extern "lean_gcc_jit_rvalue_dereference_field"]
opaque RValue.dereferenceField 
  (rval : @& RValue) (loc : @& Option Location) (field : @& Field) : IO LValue

/--
Given an rvalue of pointer type `T *`, dereferencing the pointer, getting an lvalue of type T. Analogous to:
```c
*(EXPR)
```
-/
@[extern "lean_gcc_jit_rvalue_dereference"]
opaque RValue.dereference
  (rval : @& RValue) (loc : @& Option Location) : IO LValue

/--
Take the address of an lvalue; analogous to:
```c
&(EXPR)
```
-/
@[extern "lean_gcc_jit_lvalue_get_address"]
opaque LValue.getAddress
  (lval : @& LValue) (loc : @& Option Location) : IO RValue

/--
Make a variable a thread-local variable.

The `tlsModel` parameter determines the thread-local storage model of the `lval`:
```c
_Thread_local int foo __attribute__ ((tls_model("MODEL")));
```

See `LeanGccJit.Core.TlsModel` for options.
-/
@[extern "lean_gcc_jit_lvalue_set_tls_model"]
opaque LValue.setTlsModel
  (lval : @& RValue) (tlsModel: @& TlsModel) : IO PUnit

/--
Set the link section of a variable. 

The parameter `linkSection` must contain the leading dot.

Analogous to:
```c
int variable __attribute__((section(".section")));
```
-/
@[extern "lean_gcc_jit_lvalue_set_link_section"]
opaque LValue.setLinkSection
  (lval : @& RValue) (linkSection: @& String) : IO PUnit

/--
Set the register name of a variable. 

Analogous to:
```c
register int variable asm ("r12");
```
-/
@[extern "lean_gcc_jit_lvalue_set_register_name"]
opaque LValue.setRegisterName
  (lval : @& RValue) (regName: @& String) : IO PUnit

/--
Create a new local variable within the function, of the given type and name.

The parameter type must be non-void.
-/
@[extern "lean_gcc_jit_function_new_local"]
opaque Func.newLocal
  (func : @& Func) (loc : @& Option Location) (ty : @& JitType) (name : @& String) : IO LValue

/--
Given an `RValue` for a call created through `Context.newCall` or `Context.newCallThroughPtr`, 
mark/clear the call as needing tail-call optimization. The optimizer will attempt to optimize 
the call into a jump instruction; if it is unable to do do, an error will be emitted.

This may be useful when implementing functions that use the continuation-passing style 
(e.g. for functional programming languages), in which every function `returns` by calling a 
`continuation` function pointer. This call must be guaranteed to be implemented as a jump, 
otherwise the program could consume an arbitrary amount of stack space as it executed.
-/
@[extern "lean_gcc_jit_rvalue_set_bool_require_tail_call"]
opaque RValue.setBoolRequireTailCall
  (rval : @& RValue) (val : @& Bool) : IO PUnit

/--
Build a vector `RValue` from an array of elements.

`ty` should be a vector type, created using `JitType.getVector`.

`elems` should match the length and type of the vector type.
-/
@[extern "lean_gcc_jit_context_new_rvalue_from_vector"]
opaque Context.newRValueFromVector
  (ctx : @& Context) (loc : @& Option Location) (ty : @& JitType) (elems : @& Array RValue) : IO RValue