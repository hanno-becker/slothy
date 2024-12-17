.syntax unified
.cpu cortex-m4
.thumb

// q locate in the top half of the register
.macro plant_red q, qa, qinv, tmp
 mul \tmp, \tmp, \qinv
 // tmp*qinv mod 2^2n/ 2^n; in high half
 smlatt \tmp, \tmp, \q, \qa
 // result in high half
.endm

.macro doublebasemul_frombytes_asm rptr, bptr, zeta, poly0, poly1, poly3, tmp, tmp2, q, qa, qinv
 ldr.w \poly0, [\bptr], #8

 smulwt \tmp, \zeta, \poly1
 smlabt \tmp, \tmp, \q, \qa
 smultt \tmp, \poly0, \tmp
 smlabb \tmp, \poly0, \poly1, \tmp
 // a1*b1*zeta+a0*b0
 plant_red \q, \qa, \qinv, \tmp
 // r[0] in upper half of tmp

 smuadx \tmp2, \poly0, \poly1
 plant_red \q, \qa, \qinv, \tmp2

 // r[1] in upper half of tmp2
 pkhtb \tmp, \tmp2, \tmp, asr #16
 str \tmp, [rptr], #8  // @slothy:core

 neg \zeta, \zeta

 ldr.w \poly0, [\bptr, #-4]
 // basemul(r->coeffs + 4 * i + 2, a->coeffs + 4 * i + 2, b->coeffs + 4 * i + 2, - zetas[64 + i]);
 smulwt \tmp, \zeta, \poly3
 smlabt \tmp, \tmp, \q, \qa
 smultt \tmp, \poly0, \tmp
 smlabb \tmp, \poly0, \poly3, \tmp
 plant_red \q, \qa, \qinv, \tmp
 // r[0] in upper half of tmp

 smuadx \tmp2, \poly0, \poly3
 plant_red \q, \qa, \qinv, \tmp2
 // r[1] in upper half of tmp2
 pkhtb \tmp, \tmp2, \tmp, asr #16
 str \tmp, [rptr, #-4]
.endm

// reduce 2 registers
.macro deserialize aptr, tmp, tmp2, tmp3, t0, t1
 ldrb.w \tmp, [\aptr, #2]
 ldrh.w \tmp2, [\aptr, #3]
 ldrb.w \tmp3, [\aptr, #5]
 ldrh.w \t0, [\aptr], #6

 ubfx \t1, \t0, #12, #4
 ubfx \t0, \t0, #0, #12
 orr \t1, \t1, \tmp, lsl #4
 orr \t0, \t0, \t1, lsl #16
 // tmp is free now
 ubfx \t1, \tmp2, #12, #4
 ubfx \tmp, \tmp2, #0, #12
 orr \t1, \t1, \tmp3, lsl #4
 orr \t1, \tmp, \t1, lsl #16
.endm


// void frombytes_mul_asm(int16_t *r, const int16_t *b, const unsigned char *a, const int32_t zetas[64])
.global frombytes_mul_asm_opt_m7
.type frombytes_mul_asm_opt_m7, %function
.align 2
frombytes_mul_asm_opt_m7:
 push {r4-r11, r14}

 rptr    .req r0
 bptr    .req r1
 aptr    .req r2
 zetaptr .req r3
 t0      .req r4
 t1      .req r5
 tmp     .req r6
 tmp2    .req r7
 tmp3    .req r8
 q       .req r9
 qa      .req r10
 qinv    .req r11
 zeta    .req r12
 ctr     .req r14

 movw qa, #26632
 movt  q, #3329
 ### qinv=0x6ba8f301
 movw qinv, #62209
 movt qinv, #27560

 add ctr, rptr, #64*4*2
                                       // Instructions:    10
                                       // Expected cycles: 10
                                       // Expected IPC:    1.00
                                       //
                                       // Cycle bound:     10.0
                                       // IPC bound:       1.00
                                       //
                                       // Wall time:     0.02s
                                       // User time:     0.02s
                                       //
                                       // ----- cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|----
        ldrh.w r5, [r2], #6            // *.............................
        ldr.w r12, [r1], #8            // *.............................
        ldrb.w r7, [r2, #-4]           // .*............................
        ldr.w r6, [r3], #4             // ..*...........................
        ubfx r8, r5, #12, #4         // ...*..........................
        orr r8, r8, r7, lsl #4         // ....*.........................
        ubfx r7, r5, #0, #12         // .....*........................
        orr r7, r7, r8, lsl #16        // ......*.......................
        smulwt r8, r6, r7              // .......*......................
        smlabt r5, r8, r9, r10         // .........*....................

                                        // ------ cycle (expected) ------>
                                        // 0                        25
                                        // |------------------------|-----
        // ldrh.w r7, [r2], #6          // *..............................
        // ldrb.w r6, [r2, #-4]         // .*.............................
        // ubfx r8, r7, #0, #12       // .....*.........................
        // ubfx r7, r7, #12, #4       // ...*...........................
        // orr r7, r7, r6, lsl #4       // ....*..........................
        // ldr.w r6, [r3], #4           // ..*............................
        // orr r7, r8, r7, lsl #16      // ......*........................
        // smulwt r5, r6, r7            // .......*.......................
        // ldr.w r12, [r1], #8          // *..............................
        // smlabt r5, r5, r9, r10       // .........*.....................

        sub r14, r14, #8
1:
                                          // Instructions:    39
                                          // Expected cycles: 21
                                          // Expected IPC:    1.86
                                          //
                                          // Cycle bound:     30.0
                                          // IPC bound:       1.30
                                          //
                                          // Wall time:     21.90s
                                          // User time:     21.90s
                                          //
                                          // ----- cycle (expected) ------>
                                          // 0                        25
                                          // |------------------------|----
        ldrh.w r8, [r2, #-3]              // *.............................
        smultt r4, r12, r5                // *.............................
        ldrb.w r5, [r2, #-1]              // .*............................
        smlabb r4, r12, r7, r4            // .*............................
        neg r6, r6                        // ..*...........................
        smuadx r12, r12, r7               // ..*...........................
        ubfx r7, r8, #12, #4            // ...*..........................
        mul r4, r4, r11                   // ...*..........................
        orr r5, r7, r5, lsl #4            // ....*.........................
        mul r12, r12, r11                 // ....*.........................
        ubfx r8, r8, #0, #12            // .....*........................
        smlatt r4, r4, r9, r10            // .....*........................
        orr r5, r8, r5, lsl #16           // ......*.......................
        smlatt r12, r12, r9, r10          // ......*.......................
        ldrh.w r7, [r2], #6               // .......e......................
        smulwt r6, r6, r5                 // .......*......................
        pkhtb r8, r12, r4, asr #16        // ........*.....................
        ldr.w r4, [r1, #-4]               // ........*.....................
        cmp.w r0, r14                     // .........*....................
        smlabt r12, r6, r9, r10           // .........*....................
        ldrb.w r6, [r2, #-4]              // ..........e...................
        str r8, [r0], #8                  // ..........*................... // @slothy:core
        ubfx r8, r7, #0, #12            // ...........e..................
        smultt r12, r4, r12               // ...........*..................
        ubfx r7, r7, #12, #4            // ............e.................
        smlabb r12, r4, r5, r12           // ............*.................
        orr r7, r7, r6, lsl #4            // .............e................
        smuadx r5, r4, r5                 // .............*................
        ldr.w r6, [r3], #4                // ..............e...............
        mul r4, r12, r11                  // ..............*...............
        orr r7, r8, r7, lsl #16           // ...............e..............
        mul r12, r5, r11                  // ...............*..............
        smlatt r4, r4, r9, r10            // ................*.............
        smulwt r5, r6, r7                 // .................e............
        smlatt r8, r12, r9, r10           // ..................*...........
        ldr.w r12, [r1], #8               // ...................e..........
        smlabt r5, r5, r9, r10            // ...................e..........
        pkhtb r4, r8, r4, asr #16         // ....................*.........
        str r4, [r0, #-4]                 // ....................*.........

                                          // -------- cycle (expected) -------->
                                          // 0                        25
                                          // |------------------------|---------
        // ldr.w r12, [r3], #4            // .......e......'.............~......
        // ldrb.w r6, [r2, #2]            // ...e..........'.........~..........
        // ldrh.w r7, [r2, #3]            // ..............*....................
        // ldrb.w r8, [r2, #5]            // ..............'*...................
        // ldrh.w r4, [r2], #6            // e.............'......~.............
        // ubfx r5, r4, #12, #4         // .....e........'...........~........
        // ubfx r4, r4, #0, #12         // ....e.........'..........~.........
        // orr r5, r5, r6, lsl #4         // ......e.......'............~.......
        // orr r4, r4, r5, lsl #16        // ........e.....'..............~.....
        // ubfx r5, r7, #12, #4         // ..............'..*.................
        // ubfx r6, r7, #0, #12         // ..............'....*...............
        // orr r5, r5, r8, lsl #4         // ..............'...*................
        // orr r5, r6, r5, lsl #16        // ..............'.....*..............
        // ldr.w r8, [r1], #8             // ............e.'..................~.
        // smulwt r6, r12, r4             // ..........e...'................~...
        // smlabt r6, r6, r9, r10         // ............e.'..................~.
        // smultt r6, r8, r6              // ..............*....................
        // smlabb r6, r8, r4, r6          // ..............'*...................
        // mul r6, r6, r11                // ..............'..*.................
        // smlatt r6, r6, r9, r10         // ..............'....*...............
        // smuadx r7, r8, r4              // ..............'.*..................
        // mul r7, r7, r11                // ..............'...*................
        // smlatt r7, r7, r9, r10         // ..............'.....*..............
        // pkhtb r6, r7, r6, asr #16      // .~............'.......*............
        // str r6, [r0], #8               // ...~..........'.........*..........
        // neg r12, r12                   // ..............'.*..................
        // ldr.w r8, [r1, #-4]            // .~............'.......*............
        // smulwt r6, r12, r5             // ~.............'......*.............
        // smlabt r6, r6, r9, r10         // ..~...........'........*...........
        // smultt r6, r8, r6              // ....~.........'..........*.........
        // smlabb r6, r8, r5, r6          // .....~........'...........*........
        // mul r6, r6, r11                // .......~......'.............*......
        // smlatt r6, r6, r9, r10         // .........~....'...............*....
        // smuadx r7, r8, r5              // ......~.......'............*.......
        // mul r7, r7, r11                // ........~.....'..............*.....
        // smlatt r7, r7, r9, r10         // ...........~..'.................*..
        // pkhtb r6, r7, r6, asr #16      // .............~'...................*
        // str r6, [r0, #-4]              // .............~'...................*
        // cmp.w r0, r14                  // ..~...........'........*...........

        bne 1b
                                          // Instructions:    29
                                          // Expected cycles: 20
                                          // Expected IPC:    1.45
                                          //
                                          // Cycle bound:     20.0
                                          // IPC bound:       1.45
                                          //
                                          // Wall time:     0.07s
                                          // User time:     0.07s
                                          //
                                          // ----- cycle (expected) ------>
                                          // 0                        25
                                          // |------------------------|----
        ldrh.w r8, [r2, #-3]              // *.............................
        smultt r4, r12, r5                // *.............................
        ldrb.w r5, [r2, #-1]              // .*............................
        smlabb r4, r12, r7, r4            // .*............................
        neg r6, r6                        // ..*...........................
        smuadx r7, r12, r7                // ..*...........................
        ubfx r12, r8, #12, #4           // ...*..........................
        mul r4, r4, r11                   // ...*..........................
        orr r5, r12, r5, lsl #4           // ....*.........................
        mul r7, r7, r11                   // ....*.........................
        ubfx r8, r8, #0, #12            // .....*........................
        smlatt r12, r4, r9, r10           // .....*........................
        orr r4, r8, r5, lsl #16           // ......*.......................
        smlatt r8, r7, r9, r10            // ......*.......................
        cmp.w r0, r14                     // .......*......................
        smulwt r7, r6, r4                 // .......*......................
        pkhtb r8, r8, r12, asr #16        // ........*.....................
        str r8, [r0], #8                  // ........*..................... // @slothy:core
        ldr.w r5, [r1, #-4]               // .........*....................
        smlabt r8, r7, r9, r10            // .........*....................
        smultt r8, r5, r8                 // ...........*..................
        smlabb r7, r5, r4, r8             // ............*.................
        smuadx r8, r5, r4                 // .............*................
        mul r7, r7, r11                   // ..............*...............
        mul r8, r8, r11                   // ...............*..............
        smlatt r7, r7, r9, r10            // ................*.............
        smlatt r8, r8, r9, r10            // .................*............
        pkhtb r8, r8, r7, asr #16         // ...................*..........
        str r8, [r0, #-4]                 // ...................*..........

                                           // ------ cycle (expected) ------>
                                           // 0                        25
                                           // |------------------------|-----
        // ldrh.w r8, [r2, #-3]            // *..............................
        // smultt r4, r12, r5              // *..............................
        // ldrb.w r5, [r2, #-1]            // .*.............................
        // smlabb r4, r12, r7, r4          // .*.............................
        // neg r6, r6                      // ..*............................
        // smuadx r12, r12, r7             // ..*............................
        // ubfx r7, r8, #12, #4          // ...*...........................
        // mul r4, r4, r11                 // ...*...........................
        // orr r5, r7, r5, lsl #4          // ....*..........................
        // mul r12, r12, r11               // ....*..........................
        // ubfx r8, r8, #0, #12          // .....*.........................
        // smlatt r4, r4, r9, r10          // .....*.........................
        // orr r5, r8, r5, lsl #16         // ......*........................
        // smlatt r12, r12, r9, r10        // ......*........................
        // smulwt r6, r6, r5               // .......*.......................
        // pkhtb r8, r12, r4, asr #16      // ........*......................
        // ldr.w r4, [r1, #-4]             // .........*.....................
        // cmp.w r0, r14                   // .......*.......................
        // smlabt r12, r6, r9, r10         // .........*.....................
        // str r8, [r0], #8                // ........*......................
        // smultt r12, r4, r12             // ...........*...................
        // smlabb r12, r4, r5, r12         // ............*..................
        // smuadx r5, r4, r5               // .............*.................
        // mul r4, r12, r11                // ..............*................
        // mul r12, r5, r11                // ...............*...............
        // smlatt r4, r4, r9, r10          // ................*..............
        // smlatt r8, r12, r9, r10         // .................*.............
        // pkhtb r4, r8, r4, asr #16       // ...................*...........
        // str r4, [r0, #-4]               // ...................*...........


 pop {r4-r11, pc}

.size frombytes_mul_asm_opt_m7, .-frombytes_mul_asm_opt_m7