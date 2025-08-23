# Reference: https://en.algorithmica.org/hpc/algorithms/gcd/
# Stein's algorithm (a.k.a. Binary GCD)
.section .text

li a0, 22224
li a1, 3334
jal x1, gcd

terminate:
   beq x0, x0, terminate

gcd:
    # Divide both the algorithms till you get odd
    # gcd(2a, 2b) = 2*gcd(a, b)
    loop_odd:
        and t0, a0, a1
        ori t0, t0, 1
        bne t0, x0, loop_gcd
        srli a0, a0, 1
        srli a1, a1, 1
        addi t6, t6, 1 # s0 will store number of shifts
        beq x0, x0, loop_odd

    loop_gcd:
        beq a0, x0, exit_loop_gcd # Return if a0 == 0
        bge a0, a1, continue

        # Swapping a0 and a1 with XOR if a0 < a1
        xor a0, a0, a1
        xor a1, a0, a1
        xor a0, a1, a1
        continue:

        sub a0, a0, a1

        # strip zeroes of a0
        # gcd(a, b) = gcd((a - b)/2, b)
        loop_strip_zeroes:
            andi t0, a0, 1
            bne t0, x0, loop_gcd
            srli a0, a0, 1

    exit_loop_gcd:
        # shift the output back
        # because gcd(2a, 2b) = 2*gcd(a, b)
        sll a0, a1, s0 
        ret