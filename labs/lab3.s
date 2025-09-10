.data
#.word 0b00111111000000000000000000000000, 5
.word 0b00111111001100110011001100110011, 5

.text

lui x3, 0x10000 
ld t0, 0(x3)
fmv.w.x fa0, t0
ld a0, 4(x3)
jal x1, exp
add x0, x0, x0

# fact(a0)
# INPUTS
# a0 := input (INT64)
# OUTPUTS
# a0 := a0! (INT64)
fact:
    li t0, 1

    fact_loop:
        bge x0, a0, fact_ret
        mul t0, t0, a0 # repeatedly multiply decremented a0
        addi a0, a0, -1 # decrement a0
        jal x0, fact_loop

    fact_ret:
        mv a0, t0
        ret

# pow(fa0, a0)
# INPUTS
# fa0 := base (FP32)
# a0 := exponent (INT64)
# OUTPUTS
# fa0 := pow(fa0, a0) (FP32)
pow:
    li t0, 1
    fcvt.s.l ft0, t0 # init to 1 (in float)

    pow_loop:
        bge x0, a0, pow_ret
        fmul.s ft0, ft0, fa0 # repeatedly multiply with fa0
        addi a0, a0, -1
        jal x0, pow_loop

    pow_ret:
        fmv.w.x ft1, x0
        fadd.s fa0, ft1, ft0 # move ft0 to fa0 by adding zero
        ret

# exp(fa0, a0)
# INPUTS
# fa0 := input (FP32)
# a0 := number of terms (INT64)
# OUTPUTS
# fa0 := exp(fa0) till a0 terms (FP32)
exp:
    # save saved registers (s0, fs0, fs1, fs2)

    # PLEASE NOTE THIS IS NOT CONFIRMED
    # NOTE := Although we only need 16 bytes of stack
    # and the stack should be 16 bit aligned
    # the stack pointer should leave space for a red zone?
    # So, we subtract it with 32
    addi sp, sp, -32
    sd s0, 8(sp)
    fsw fs1, 4(sp)
    fsw fs0, 0(sp)

    li s0, 1 # upward counter for 'n' in taylor series
    fcvt.s.l fs0, s0 # fs0 := result

    # decrease a0 by 1 as we already considered first term
    addi a0, a0, -1 

    exp_loop:
        bge x0, a0, exp_ret

        # saving registers (fa0, a0, x1)
        addi sp, sp, -32
        fsw fa0, 16(sp)
        sd a0, 8(sp)
        sd x1, 0(sp)

        # Calculating fact(s0)
        # a0 = s0
        # Stored in a0
        mv a0, s0
        jal x1, fact
        fcvt.s.l fs1, a0 # fs1 contains factorial

        # Calculating pow(fa0, s0)
        # Stored in fa0
        mv a0, s0
        # Input is already in fa0
        jal x1, pow
        fdiv.s fa0, fa0, fs1
        fadd.s fs0, fs0, fa0

        # loading back registers (fa0, a0, x1)
        ld x1, 0(sp)
        ld a0, 8(sp)
        flw fa0, 16(sp)
        addi sp, sp, 32

        addi a0, a0, -1
        addi s0, s0, 1 # increment 'n' by one
        jal x0, exp_loop 

    exp_ret:
        fmv.w.x ft1, x0
        fadd.s fa0, ft1, fs0 # move fs0 to fa0 by adding zero

        # load back the saved registers
        flw fs0, 0(sp)
        flw fs1, 4(sp)
        ld s0, 8(sp)
        addi sp, sp, 32

        ret

# cos(fa0, a0)
# INPUTS
# fa0 := input (FP32)
# a0 := number of terms (INT64)
# OUTPUTS
# fa0 := cos(fa0) till a0 terms (FP32)
cos:
    # save saved registers (s0, s1, fs0, fs1)
    # NOTE := Although we only need 24 bytes of stack
    # memory, the stack pointer should be 16 bit aligned
    # So, we subtract it with 32
    addi sp, sp, -32
    sd s1, 16(sp)
    sd s0, 8(sp)
    fsw fs1, 4(sp)
    fsw fs0, 0(sp)

    li s0, 1 # upward counter for 'n' in taylor series
    # cosine has alternating -1 and 1
    # it is just convenient to have a register for it
    li s1, 1 
    fcvt.s.l fs0, s0 # fs0 := result

    # decrease a0 by 1 as we already considered first term
    addi a0, a0, -1 

    cos_loop:
        bge x0, a0, exp_ret

        # saving registers (fa0, a0, x1)
        addi sp, sp, -32
        fsw fa0, 16(sp)
        sd a0, 8(sp)
        sd x1, 0(sp)

        # Calculating fact(s0)
        # a0 = s0
        # Stored in a0
        mv a0, s0
        jal x1, fact
        fcvt.s.l fs1, a0 # fs1 contains factorial

        # Calculating pow(fa0, s0)
        # Stored in fa0
        mv a0, s0
        # Input is already in fa0
        jal x1, pow
        fdiv.s fa0, fa0, fs1

        # switching the sign of s1
        # -2 = 0b11111.....1110
        # xor with -2 makes it switch from 1 to -1 and -1 to 1
        xori s1, s1, -2
        fcvt.w.s ft0, s1
        fmul.s fa0, fa0, ft0
        fadd.s fs0, fs0, fa0

        # loading back registers (fa0, a0, x1)
        ld x1, 0(sp)
        ld a0, 8(sp)
        flw fa0, 16(sp)
        addi sp, sp, 32

        addi a0, a0, -1
        # increment 'n' by 2
        # as the cos taylor series contains even powers only
        addi s0, s0, 2 
        jal x0, cos_loop 

    cos_ret:
        fmv.w.x ft1, x0
        fadd.s fa0, ft1, fs0 # move fs0 to fa0 by adding zero

        # load back the saved registers
        flw fs0, 0(sp)
        flw fs1, 4(sp)
        ld s0, 8(sp)
        ld s1, 16(sp)
        addi sp, sp, 32

        ret