#include "common.h"
namespace lean_gccjit
{
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_block_add_extended_asm(
    b_lean_obj_arg blk,     /* @& Block */
    b_lean_obj_arg loc,     /* @& Option Location */
    b_lean_obj_arg asm_str, /* @& String */
    lean_object *           /* w */
)
{
    auto * block = unwrap_pointer<gcc_jit_block>(blk);
    auto * location = unwrap_option<gcc_jit_location>(loc);
    auto asm_str_ = lean_string_cstr(asm_str);
    gcc_jit_block_add_extended_asm(block, location, asm_str_);
    return lean_io_result_mk_ok(lean_box(0));
}
LEAN_GCC_JIT_UPCAST(extended_asm, object);
extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_extended_asm_set_volatile_flag(
    b_lean_obj_arg easm, /* @& ExtendedAsm */
    uint8_t flag,        /* @ Bool */
    lean_object *        /* w */
)
{
    auto * easm_ = unwrap_pointer<gcc_jit_extended_asm>(easm);
    gcc_jit_extended_asm_set_volatile_flag(easm_, static_cast<int>(flag));
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_extended_asm_set_inline_flag(
    b_lean_obj_arg easm, /* @& ExtendedAsm */
    uint8_t flag,        /* @ Bool */
    lean_object *        /* w */
)
{
    auto * easm_ = unwrap_pointer<gcc_jit_extended_asm>(easm);
    gcc_jit_extended_asm_set_inline_flag(easm_, static_cast<int>(flag));
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_extended_asm_add_output_operand(
    b_lean_obj_arg easm,       /* @& ExtendedAsm */
    b_lean_obj_arg symbol,     /* @& Option String */
    b_lean_obj_arg constraint, /* @& String */
    b_lean_obj_arg lvalue,     /* @& LValue */
    lean_object *              /* w */
)
{
    auto * easm_ = unwrap_pointer<gcc_jit_extended_asm>(easm);
    auto symbol_ = unwrap_option_str(symbol);
    auto constraint_ = lean_string_cstr(constraint);
    auto * lvalue_ = unwrap_pointer<gcc_jit_lvalue>(lvalue);
    gcc_jit_extended_asm_add_output_operand(easm_, symbol_, constraint_, lvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_extended_asm_add_input_operand(
    b_lean_obj_arg easm,       /* @& ExtendedAsm */
    b_lean_obj_arg symbol,     /* @& Option String */
    b_lean_obj_arg constraint, /* @& String */
    b_lean_obj_arg rvalue,     /* @& RValue */
    lean_object *              /* w */
)
{
    auto * easm_ = unwrap_pointer<gcc_jit_extended_asm>(easm);
    auto symbol_ = unwrap_option_str(symbol);
    auto constraint_ = lean_string_cstr(constraint);
    auto * rvalue_ = unwrap_pointer<gcc_jit_rvalue>(rvalue);
    gcc_jit_extended_asm_add_input_operand(easm_, symbol_, constraint_, rvalue_);
    return lean_io_result_mk_ok(lean_box(0));
}

extern "C" LEAN_EXPORT lean_obj_res lean_gcc_jit_extended_asm_add_clobber(
    b_lean_obj_arg easm,   /* @& ExtendedAsm */
    b_lean_obj_arg victim, /* @& String */
    lean_object *          /* w */
)
{
    auto * easm_ = unwrap_pointer<gcc_jit_extended_asm>(easm);
    auto victim_ = lean_string_cstr(victim);
    gcc_jit_extended_asm_add_clobber(easm_, victim_);
    return lean_io_result_mk_ok(lean_box(0));
}

} // namespace lean_gccjit