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

.macro doublebasemul_frombytes_asm_acc rptr, bptr, zeta, poly0, poly1, poly3, res0, tmp, tmp2, q, qa, qinv

 ldr \poly0, [\bptr], #8

 ldr \res0, [\rptr]
 smulwt \tmp, \zeta, \poly1
 // b_1*zeta*qinv*plant_const; in low half
 smlabt \tmp, \tmp, \q, \qa
 // b_1*zeta
 smultt \tmp, \poly0, \tmp
 // a_1*b_1*zeta <2^32
 smlabb \tmp, \poly0, \poly1, \tmp
 // a1*b1*zeta+a0*b0
 plant_red \q, \qa, \qinv, \tmp
 // r[0] in upper half of tmp

 smuadx \tmp2, \poly0, \poly1
 plant_red \q, \qa, \qinv, \tmp2

 // r[1] in upper half of tmp2
 pkhtb \tmp, \tmp2, \tmp, asr #16
 uadd16 \res0, \res0, \tmp
 str \res0, [\rptr], #8 // @slothy:core

 neg \zeta, \zeta

 ldr \poly0, [\bptr, #-4]
 ldr \res0, [\rptr, #-4]

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
 uadd16 \res0, \res0, \tmp
 str \res0, [\rptr, #-4]
.endm

// reduce 2 registers
.macro deserialize aptr, tmp, tmp2, tmp3, t0, t1
 ldrb.w \tmp, [\aptr, #2]
 ldrh.w \tmp2, [\aptr, #3]
 ldrb.w \tmp3, [\aptr, #5]
 ldrh.w \t0, [\aptr], #6

 ubfx.w \t1, \t0, #12, #4
 ubfx.w \t0, \t0, #0, #12
 orr \t1, \t1, \tmp, lsl #4
 orr \t0, \t0, \t1, lsl #16
 // tmp is free now
 ubfx.w \t1, \tmp2, #12, #4
 ubfx.w \tmp, \tmp2, #0, #12
 orr \t1, \t1, \tmp3, lsl #4
 orr \t1, \tmp, \t1, lsl #16
.endm

// void frombytes_mul_asm_acc(int16_t *r, const int16_t *b, const unsigned char *a, const int32_t zetas[64])
.global frombytes_mul_asm_acc_opt_m7
.type frombytes_mul_asm_acc_opt_m7, %function
.align 2
frombytes_mul_asm_acc_opt_m7:
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
 vmov s0, ctr
                                        // Instructions:    17
                                        // Expected cycles: 11
                                        // Expected IPC:    1.55
                                        //
                                        // Cycle bound:     11.0
                                        // IPC bound:       1.55
                                        //
                                        // Wall time:     0.04s
                                        // User time:     0.04s
                                        //
                                        // ----- cycle (expected) ------>
                                        // 0                        25
                                        // |------------------------|----
        ldrb.w r7, [r2, #5]             // *.............................
        ldrh.w r4, [r2, #3]             // *.............................
        ldrb.w r6, [r2, #2]             // .*............................
        ldrh.w r12, [r2], #6            // .*............................
        ldr r5, [r1], #8                // ..*...........................
        ubfx.w r8, r4, #12, #4          // ...*..........................
        ubfx.w r14, r12, #12, #4        // ....*.........................
        orr r14, r14, r6, lsl #4        // .....*........................
        ubfx.w r6, r12, #0, #12         // ......*.......................
        ldr.w r12, [r3], #4             // ......*.......................
        orr r6, r6, r14, lsl #16        // .......*......................
        orr r8, r8, r7, lsl #4          // ........*.....................
        smulwt r14, r12, r6             // ........*.....................
        ubfx.w r4, r4, #0, #12          // .........*....................
        smuadx r7, r5, r6               // .........*....................
        orr r8, r4, r8, lsl #16         // ..........*...................
        smlabt r4, r14, r9, r10         // ..........*...................

                                          // ------ cycle (expected) ------>
                                          // 0                        25
                                          // |------------------------|-----
        // ldrh.w r14, [r2, #3]           // *..............................
        // ldrb.w r6, [r2, #5]            // *..............................
        // ubfx.w r12, r14, #12, #4       // ...*...........................
        // orr r12, r12, r6, lsl #4       // ........*......................
        // ubfx.w r14, r14, #0, #12       // .........*.....................
        // ldrb.w r6, [r2, #2]            // .*.............................
        // ldrh.w r4, [r2], #6            // .*.............................
        // orr r8, r14, r12, lsl #16      // ..........*....................
        // ldr.w r12, [r3], #4            // ......*........................
        // ubfx.w r14, r4, #12, #4        // ....*..........................
        // orr r6, r14, r6, lsl #4        // .....*.........................
        // ubfx.w r4, r4, #0, #12         // ......*........................
        // ldr r5, [r1], #8               // ..*............................
        // orr r6, r4, r6, lsl #16        // .......*.......................
        // smulwt r7, r12, r6             // ........*......................
        // smlabt r4, r7, r9, r10         // ..........*....................
        // smuadx r7, r5, r6              // .........*.....................

        push {r14}
        vmov r14, s0
        sub r14, r14, #8
        vmov s0, r14
        pop {r14}
1:
                                           // Instructions:    44
                                           // Expected cycles: 23
                                           // Expected IPC:    1.91
                                           //
                                           // Cycle bound:     32.0
                                           // IPC bound:       1.38
                                           //
                                           // Wall time:     81.53s
                                           // User time:     81.53s
                                           //
                                           // ----- cycle (expected) ------>
                                           // 0                        25
                                           // |------------------------|----
        neg r12, r12                       // *.............................
        smultt r4, r5, r4                  // *.............................
        ldrh.w r14, [r2, #3]               // .e............................
        smlabb r4, r5, r6, r4              // .*............................
        ldrb.w r6, [r2, #5]                // ..e...........................
        mul r5, r7, r11                    // ..*...........................
        mul r4, r4, r11                    // ...*..........................
        smulwt r7, r12, r8                 // ....*.........................
        ubfx.w r12, r14, #12, #4           // .....e........................
        smlatt r4, r4, r9, r10             // .....*........................
        orr r12, r12, r6, lsl #4           // ......e.......................
        smlatt r6, r5, r9, r10             // ......*.......................
        ldr r5, [r1, #-4]                  // .......*......................
        smlabt r7, r7, r9, r10             // .......*......................
        pkhtb r4, r6, r4, asr #16          // ........*.....................
        ldr r6, [r0]                       // ........*.....................
        ubfx.w r14, r14, #0, #12           // .........e....................
        smultt r7, r5, r7                  // .........*....................
        uadd16 r4, r6, r4                  // ..........*...................
        smlabb r7, r5, r8, r7              // ..........*...................
        ldrb.w r6, [r2, #2]                // ...........e..................
        str r4, [r0], #8                   // ...........*.................. // @slothy:core
        ldrh.w r4, [r2], #6                // ............e.................
        smuadx r5, r5, r8                  // ............*.................
        orr r8, r14, r12, lsl #16          // .............e................
        mul r7, r7, r11                    // .............*................
        ldr.w r12, [r3], #4                // ..............e...............
        mul r5, r5, r11                    // ..............*...............
        ubfx.w r14, r4, #12, #4            // ...............e..............
        smlatt r7, r7, r9, r10             // ...............*..............
        orr r6, r14, r6, lsl #4            // ................e.............
        smlatt r14, r5, r9, r10            // ................*.............
        ubfx.w r4, r4, #0, #12             // .................e............
        ldr r5, [r1], #8                   // .................e............
        orr r6, r4, r6, lsl #16            // ..................e...........
        ldr r4, [r0, #-4]                  // ..................*...........
        pkhtb r14, r14, r7, asr #16        // ...................*..........
        smulwt r7, r12, r6                 // ...................e..........
        uadd16 r14, r4, r14                // ....................*.........
        str r14, [r0, #-4]                 // ....................*.........
        vmov r14, s0                       // .....................*........
        smlabt r4, r7, r9, r10             // .....................e........
        cmp.w r0, r14                      // ......................*.......
        smuadx r7, r5, r6                  // ......................e.......

                                          // ------------- cycle (expected) ------------->
                                          // 0                        25
                                          // |------------------------|-------------------
        // ldr.w r12, [r3], #4            // .............e........'.............~........
        // ldrb.w r6, [r2, #2]            // ..........e...........'..........~...........
        // ldrh.w r7, [r2, #3]            // e.....................'~.....................
        // ldrb.w r8, [r2, #5]            // .e....................'.~....................
        // ldrh.w r4, [r2], #6            // ...........e..........'...........~..........
        // ubfx.w r5, r4, #12, #4         // ..............e.......'..............~.......
        // ubfx.w r4, r4, #0, #12         // ................e.....'................~.....
        // orr r5, r5, r6, lsl #4         // ...............e......'...............~......
        // orr r4, r4, r5, lsl #16        // .................e....'.................~....
        // ubfx.w r5, r7, #12, #4         // ....e.................'....~.................
        // ubfx.w r6, r7, #0, #12         // ........e.............'........~.............
        // orr r5, r5, r8, lsl #4         // .....e................'.....~................
        // orr r5, r6, r5, lsl #16        // ............e.........'............~.........
        // ldr r8, [r1], #8               // ................e.....'................~.....
        // ldr r14, [r0]                  // .......~..............'.......*..............
        // smulwt r6, r12, r4             // ..................e...'..................~...
        // smlabt r6, r6, r9, r10         // ....................e.'....................~.
        // smultt r6, r8, r6              // ......................*......................
        // smlabb r6, r8, r4, r6          // ~.....................'*.....................
        // mul r6, r6, r11                // ..~...................'..*...................
        // smlatt r6, r6, r9, r10         // ....~.................'....*.................
        // smuadx r7, r8, r4              // .....................e'......................
        // mul r7, r7, r11                // .~....................'.*....................
        // smlatt r7, r7, r9, r10         // .....~................'.....*................
        // pkhtb r6, r7, r6, asr #16      // .......~..............'.......*..............
        // uadd16 r14, r14, r6            // .........~............'.........*............
        // str r14, [r0], #8              // ..........~...........'..........*...........
        // neg r12, r12                   // ......................*......................
        // ldr r8, [r1, #-4]              // ......~...............'......*...............
        // ldr r14, [r0, #-4]             // .................~....'.................*....
        // smulwt r6, r12, r5             // ...~..................'...*..................
        // smlabt r6, r6, r9, r10         // ......~...............'......*...............
        // smultt r6, r8, r6              // ........~.............'........*.............
        // smlabb r6, r8, r5, r6          // .........~............'.........*............
        // mul r6, r6, r11                // ............~.........'............*.........
        // smlatt r6, r6, r9, r10         // ..............~.......'..............*.......
        // smuadx r7, r8, r5              // ...........~..........'...........*..........
        // mul r7, r7, r11                // .............~........'.............*........
        // smlatt r7, r7, r9, r10         // ...............~......'...............*......
        // pkhtb r6, r7, r6, asr #16      // ..................~...'..................*...
        // uadd16 r14, r14, r6            // ...................~..'...................*..
        // str r14, [r0, #-4]             // ...................~..'...................*..
        // vmov r14, s0                   // ....................~.'....................*.
        // cmp.w r0, r14                  // .....................~'.....................*

        bne 1b
                                         // Instructions:    27
                                         // Expected cycles: 19
                                         // Expected IPC:    1.42
                                         //
                                         // Cycle bound:     19.0
                                         // IPC bound:       1.42
                                         //
                                         // Wall time:     0.09s
                                         // User time:     0.09s
                                         //
                                         // ----- cycle (expected) ------>
                                         // 0                        25
                                         // |------------------------|----
        neg r12, r12                     // *.............................
        smultt r14, r5, r4               // *.............................
        ldr r4, [r1, #-4]                // .*............................
        smlabb r6, r5, r6, r14           // .*............................
        ldr r14, [r0]                    // ..*...........................
        mul r7, r7, r11                  // ..*...........................
        smulwt r5, r12, r8               // ...*..........................
        mul r6, r6, r11                  // ....*.........................
        smlabt r5, r5, r9, r10           // .....*........................
        smuadx r12, r4, r8               // ......*.......................
        smultt r5, r4, r5                // .......*......................
        smlabb r4, r4, r8, r5            // ........*.....................
        vmov r5, s0                      // .........*....................
        smlatt r6, r6, r9, r10           // .........*....................
        smlatt r7, r7, r9, r10           // ..........*...................
        mul r4, r4, r11                  // ...........*..................
        pkhtb r6, r7, r6, asr #16        // ............*.................
        mul r7, r12, r11                 // ............*.................
        uadd16 r6, r14, r6               // .............*................
        str r6, [r0], #8                 // .............*................ // @slothy:core
        cmp.w r0, r5                     // ..............*...............
        smlatt r6, r4, r9, r10           // ..............*...............
        ldr r14, [r0, #-4]               // ...............*..............
        smlatt r7, r7, r9, r10           // ...............*..............
        pkhtb r6, r7, r6, asr #16        // .................*............
        uadd16 r6, r14, r6               // ..................*...........
        str r6, [r0, #-4]                // ..................*...........

                                            // ------ cycle (expected) ------>
                                            // 0                        25
                                            // |------------------------|-----
        // neg r12, r12                     // *..............................
        // smultt r4, r5, r4                // *..............................
        // smlabb r4, r5, r6, r4            // .*.............................
        // mul r5, r7, r11                  // ..*............................
        // mul r4, r4, r11                  // ....*..........................
        // smulwt r7, r12, r8               // ...*...........................
        // smlatt r4, r4, r9, r10           // .........*.....................
        // smlatt r6, r5, r9, r10           // ..........*....................
        // ldr r5, [r1, #-4]                // .*.............................
        // smlabt r7, r7, r9, r10           // .....*.........................
        // pkhtb r4, r6, r4, asr #16        // ............*..................
        // ldr r6, [r0]                     // ..*............................
        // smultt r7, r5, r7                // .......*.......................
        // uadd16 r4, r6, r4                // .............*.................
        // smlabb r7, r5, r8, r7            // ........*......................
        // str r4, [r0], #8                 // .............*.................
        // smuadx r5, r5, r8                // ......*........................
        // mul r7, r7, r11                  // ...........*...................
        // mul r5, r5, r11                  // ............*..................
        // smlatt r7, r7, r9, r10           // ..............*................
        // smlatt r14, r5, r9, r10          // ...............*...............
        // ldr r4, [r0, #-4]                // ...............*...............
        // pkhtb r14, r14, r7, asr #16      // .................*.............
        // uadd16 r14, r4, r14              // ..................*............
        // str r14, [r0, #-4]               // ..................*............
        // vmov r14, s0                     // .........*.....................
        // cmp.w r0, r14                    // ..............*................


 pop {r4-r11, pc}