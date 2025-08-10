.section .text
    # Make temp regs zero
    xor x29, x29, x29
    xor x30, x30, x30
    xor x31, x31, x31

    li x5, 0x10000000
    li x28, 1 # constant one

    # --- debug ---
    li x6, 9
    sd x6, 0(x5) 
    li x6, 3
    sd x6, 8(x5) 
    # --- debug ---

    ld x7, 0(x5)
    ld x8, 8(x5)

    Loop:
        beq x8, x0, Loop_Exit

        and x31, x8, x28
        beq x31, x28, Shift
        beq x0, x0, Shift_Exit

        Shift:
            sll x31, x7, x30
            add x29, x29, x31

        Shift_Exit:
            addi x30, x30, 1
            srli x8, x8, 1

        beq x0, x0, Loop

    Loop_Exit: