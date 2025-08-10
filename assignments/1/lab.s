.section .text
    # Init variables zero
    xor x5, x5, x5 # Temp
    xor x6, x6, x6 # Temp
    xor x29, x29, x29 # Output
    xor x31, x31, x31 # Counter

    Load:
        li x5, 0x10000000 # memory location of numbers

        # --- debug ---
        li x6, -9
        sd x6, 0(x5) 
        li x6, -3
        sd x6, 8(x5) 
        # --- debug ---

        # load the numbers
        ld x7, 0(x5)
        ld x8, 8(x5)

    # check if x8 is negative or not
    xor x5, x5, x5
    li x5, 63
    srl x5, x8, x5

    beq x5, x0, Loop # straightaway jump to loop if x8 is positive
    sub x8, x0, x8 # Negate x8 for lesser iterations

    Loop:
        beq x8, x0, Exit # exit the loop if x8 is zero
        andi x6, x8, 1 # check if last bit is one

        # skip shifting and adding if the last bit is not one
        beq x6, x0, Skip_Add

        # Shift by "counter" number of steps
        # Basically multiply by some power of 2
        sll x6, x7, x31
        add x29, x29, x6

        Skip_Add:
            # Increment counter
            addi x31, x31, 1
            srli x8, x8, 1

        beq x0, x0, Loop # Infinite Loop

    Exit:
        beq x5, x0, Store # x5 stores whether x8 was negative
        sub x29, x0, x29 # Negate the output otherwise

    Store:
        li x5, 0x10000050
        sd x29, 0(x5)
