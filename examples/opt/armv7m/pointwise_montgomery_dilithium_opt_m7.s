.syntax unified
.thumb

.macro montgomery_multiplication res, pa, pb, q, qinv
    smull \pa, \res, \pa, \pb
    mul \pb, \pa, \qinv
    smlal \pa, \res, \pb, \q
.endm


// void asm_pointwise_montgomery(int32_t c[N], const int32_t a[N], const int32_t b[N]);
.global pqcrystals_dilithium_asm_pointwise_montgomery_opt_m7
.type pqcrystals_dilithium_asm_pointwise_montgomery_opt_m7,%function
.align 2
pqcrystals_dilithium_asm_pointwise_montgomery_opt_m7:
    push.w {r4-r11, r14}
    c_ptr .req r0
    a_ptr .req r1
    b_ptr .req r2
    qinv  .req r3
    q     .req r4
    pa0   .req r5
    pa1   .req r6
    pa2   .req r7
    pb0   .req r8
    pb1   .req r9
    pb2   .req r10
    tmp0  .req r11
    ctr   .req r12
    res   .req r14

    movw qinv, #:lower16:0xfc7fdfff
    movt qinv, #:upper16:0xfc7fdfff
    movw q, #0xE001
    movt q, #0x7F


    // 85x3 = 255 coefficients
    movw ctr, #85
                                   // Instructions:    5
                                   // Expected cycles: 3
                                   // Expected IPC:    1.67
                                   //
                                   // Wall time:     0.15s
                                   // User time:     0.15s
                                   //
                                   // ----- cycle (expected) ------>
                                   // 0                        25
                                   // |------------------------|----
        ldr.w r6, [r1, #4]         // *.............................
        ldr.w r11, [r1, #8]        // *.............................
        ldr.w r8, [r2, #8]         // .*............................
        ldr.w r9, [r2, #4]         // .*............................
        ldr r7, [r1], #12          // ..*...........................

                                    // ------ cycle (expected) ------>
                                    // 0                        25
                                    // |------------------------|-----
        // ldr.w r6, [r1, #4]       // *..............................
        // ldr.w r11, [r1, #8]      // *..............................
        // ldr.w r8, [r2, #8]       // .*.............................
        // ldr.w r9, [r2, #4]       // .*.............................
        // ldr r7, [r1], #12        // ..*............................

        sub ctr, ctr, #1
1:
                                      // Instructions:    18
                                      // Expected cycles: 11
                                      // Expected IPC:    1.64
                                      //
                                      // Wall time:     2.53s
                                      // User time:     2.53s
                                      //
                                      // ----- cycle (expected) ------>
                                      // 0                        25
                                      // |------------------------|----
        smull r10, r5, r6, r9         // *.............................
        ldr r6, [r2], #12             // *.............................
        smull r9, r14, r11, r8        // .*............................
        smull r7, r11, r7, r6         // ..*...........................
        mul r6, r10, r3               // ...*..........................
        mul r8, r7, r3                // ....*.........................
        smlal r10, r5, r6, r4         // .....*........................
        ldr.w r6, [r1, #4]            // .....e........................
        smlal r7, r11, r8, r4         // ......*.......................
        str r11, [r0], #4             // ......*.......................
        ldr.w r11, [r1, #8]           // .......e......................
        mul r7, r9, r3                // .......*......................
        str r5, [r0], #4              // ........*.....................
        ldr.w r8, [r2, #8]            // ........e.....................
        smlal r9, r14, r7, r4         // .........*....................
        ldr.w r9, [r2, #4]            // .........e....................
        ldr r7, [r1], #12             // ..........e...................
        str r14, [r0], #4             // ..........*...................

                                       // ------ cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|-----
        // ldr.w r6, [r1, #4]          // e.....'....~.....'....~.....'..
        // ldr.w r7, [r1, #8]          // ..e...'......~...'......~...'..
        // ldr r5, [r1], #12           // .....e'.........~'.........~'..
        // ldr.w r9, [r2, #4]          // ....e.'........~.'........~.'..
        // ldr.w r10, [r2, #8]         // ...e..'.......~..'.......~..'..
        // ldr r8, [r2], #12           // ......*..........~..........~..
        // smull r5, r14, r5, r8       // ......'.*........'.~........'..
        // mul r8, r5, r3              // ......'...*......'...~......'..
        // smlal r5, r14, r8, r4       // .~....'.....*....'.....~....'..
        // str r14, [r0], #4           // .~....'.....*....'.....~....'..
        // smull r6, r14, r6, r9       // ......*..........~..........~..
        // mul r9, r6, r3              // ......'..*.......'..~.......'..
        // smlal r6, r14, r9, r4       // ~.....'....*.....'....~.....'..
        // str r14, [r0], #4           // ...~..'.......*..'.......~..'..
        // smull r7, r14, r7, r10      // ......'*.........'~.........'~.
        // mul r10, r7, r3             // ..~...'......*...'......~...'..
        // smlal r7, r14, r10, r4      // ....~.'........*.'........~.'..
        // str r14, [r0], #4           // .....~'.........*'.........~'..

        subs ctr, #1
        bne 1b
                                      // Instructions:    13
                                      // Expected cycles: 11
                                      // Expected IPC:    1.18
                                      //
                                      // Wall time:     0.53s
                                      // User time:     0.53s
                                      //
                                      // ----- cycle (expected) ------>
                                      // 0                        25
                                      // |------------------------|----
        smull r10, r5, r6, r9         // *.............................
        ldr r9, [r2], #12             // *.............................
        smull r6, r14, r11, r8        // .*............................
        smull r11, r7, r7, r9         // ..*...........................
        mul r9, r10, r3               // ...*..........................
        mul r8, r11, r3               // ....*.........................
        smlal r10, r5, r9, r4         // .....*........................
        smlal r11, r7, r8, r4         // ......*.......................
        str r7, [r0], #4              // ......*.......................
        mul r8, r6, r3                // .......*......................
        str r5, [r0], #4              // ........*.....................
        smlal r6, r14, r8, r4         // ..........*...................
        str r14, [r0], #4             // ..........*...................

                                       // ------ cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|-----
        // smull r10, r5, r6, r9       // *..............................
        // ldr r6, [r2], #12           // *..............................
        // smull r9, r14, r11, r8      // .*.............................
        // smull r7, r11, r7, r6       // ..*............................
        // mul r6, r10, r3             // ...*...........................
        // mul r8, r7, r3              // ....*..........................
        // smlal r10, r5, r6, r4       // .....*.........................
        // smlal r7, r11, r8, r4       // ......*........................
        // str r11, [r0], #4           // ......*........................
        // mul r7, r9, r3              // .......*.......................
        // str r5, [r0], #4            // ........*......................
        // smlal r9, r14, r7, r4       // ..........*....................
        // str r14, [r0], #4           // ..........*....................


    // final coefficient
    ldr.w pa0, [a_ptr]
    ldr.w pb0, [b_ptr]
    montgomery_multiplication res, pa0, pb0, q, qinv
    str.w res, [c_ptr]

    pop.w {r4-r11, pc}
