.data
.word 0b00111111000000000000000000000000, 5

.text

# DEBUG
# -----

lui x3, 0x10000 
ld t0, 0(x3)
fmv.w.x fa0, t0
ld a0, 4(x3)
jal x1, pow

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
    addi sp, sp, -32
    sd s0, 24(sp)
    fsd fs0, 16(sp)
    fsd fs1, 8(sp)
    fsd fs0, 0(sp)

    li s0, 1 # upward counter for 'n' in taylor series
    fcvt.s.l fs0, s0 # fs0 := result

    # decrease a0 by 1 as we already considered first term
    addi a0, a0, -1 

    exp_loop:
        blt x0, a0, exp_ret

        addi sp, sp, -16
        sd a0, 8(sp)
        sd x1, 0(sp)

        # Calculating fact(s0)
        # a0 = s0
        mv a0, s0
        jal x1, fact
        fcvt.s.l fs1, a0 # fs1 contains factorial

        # calculate pow(fa0, s0), store in fs2
        # todo
        fdiv.d fa0, fa0, fs1
        fadd.d fs0, fs0, fa0

        addi a0, a0, -1
        addi s0, s0, 1 # increment by one

    exp_ret:
        fmv.w.x ft1, x0
        fadd.s fa0, ft1, fs0 # move fs0 to fa0 by adding zero

        # load back the saved registers
        fld fs0, 0(sp)
        fld fs1, 8(sp)
        fld fs0, 16(sp)
        ld s0, 24(sp)
        addi sp, sp, 32

        ret