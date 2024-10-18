/******************************************************************************
* Integrating the improved Plantard arithmetic into Kyber.
*
* Efficient Plantard arithmetic enables a faster Kyber implementation with the
* same stack usage.
*
* See the paper at https:// eprint.iacr.org/2022/956.pdf for more details.
*
* @author   Junhao Huang, BNU-HKBU United International College, Zhuhai, China
*           jhhuang_nuaa@126.com
*
* @date     September 2022
******************************************************************************/

.macro doubleplant a, tmp, q, qa, plantconst
 smulwb \tmp, \plantconst, \a
 smulwt \a, \plantconst, \a
 smlabt \tmp, \tmp, \q, \qa
 smlabt \a, \a, \q, \qa
 pkhtb \a, \a, \tmp, asr #16
.endm

.syntax unified
.cpu cortex-m4
.thumb

.global asm_fromplant_opt_m7
.type asm_fromplant_opt_m7,%function
.align 2
asm_fromplant_opt_m7:
 push    {r4-r11, r14}

 poly        .req r0
 poly0       .req r1
 poly1       .req r2
 poly2       .req r3
 poly3       .req r4
 poly4       .req r5
 poly5       .req r6
 poly6       .req r7
 poly7       .req r8
 loop        .req r9
 plantconst  .req r10
 q           .req r11
 qa          .req r12
 tmp         .req r14

 movw qa, #26632
 movt q, #3329

 ### movt qinv, #3327
 ### plant_constant=(Plant_const^2%M)*(p^-1) % 2^32
 movw plantconst, #20396
 movt plantconst, #38900
 movw loop, #16
                // Instructions:    0
                // Expected cycles: 0
                // Expected IPC:    0.00
                //
                // Wall time:     0.01s
                // User time:     0.01s
                //
1:
                                           // Instructions:    56
                                           // Expected cycles: 37
                                           // Expected IPC:    1.51
                                           //
                                           // Wall time:     7.39s
                                           // User time:     7.39s
                                           //
                                           // --------- cycle (expected) --------->
                                           // 0                        25
                                           // |------------------------|-----------
        ldr r1, [r0, #8]                   // *....................................
        ldr r3, [r0, #12]                  // *....................................
        ldr r5, [r0, #16]                  // .*...................................
        ldr r2, [r0, #20]                  // ..*..................................
        smulwt r6, r10, r1                 // ..*..................................
        smulwb r14, r10, r3                // ...*.................................
        smulwb r8, r10, r5                 // ....*................................
        ldr r7, [r0, #4]                   // ....*................................
        smlabt r4, r6, r11, r12            // .....*...............................
        smulwb r1, r10, r1                 // ......*..............................
        smlabt r6, r8, r11, r12            // .......*.............................
        smlabt r1, r1, r11, r12            // ........*............................
        smlabt r14, r14, r11, r12          // .........*...........................
        pkhtb r1, r4, r1, asr #16          // ..........*..........................
        smulwt r3, r10, r3                 // ..........*..........................
        str r1, [r0, #8]                   // ...........*.........................
        smulwb r1, r10, r2                 // ...........*.........................
        smlabt r3, r3, r11, r12            // ............*........................
        ldr r4, [r0, #28]                  // ............*........................
        smulwt r8, r10, r7                 // .............*.......................
        smulwb r7, r10, r7                 // ..............*......................
        pkhtb r14, r3, r14, asr #16        // ..............*......................
        smulwt r5, r10, r5                 // ...............*.....................
        smulwt r3, r10, r4                 // ................*....................
        str r14, [r0, #12]                 // ................*....................
        smlabt r5, r5, r11, r12            // .................*...................
        smlabt r3, r3, r11, r12            // ..................*..................
        pkhtb r14, r5, r6, asr #16         // ...................*.................
        smlabt r6, r7, r11, r12            // ...................*.................
        smlabt r8, r8, r11, r12            // ....................*................
        ldr r7, [r0, #24]                  // ....................*................
        smulwt r5, r10, r2                 // .....................*...............
        str r14, [r0, #16]                 // .....................*...............
        pkhtb r8, r8, r6, asr #16          // ......................*..............
        smlabt r2, r1, r11, r12            // ......................*..............
        smulwt r1, r10, r7                 // .......................*.............
        str r8, [r0, #4]                   // .......................*.............
        smlabt r6, r5, r11, r12            // ........................*............
        smlabt r5, r1, r11, r12            // .........................*...........
        pkhtb r1, r6, r2, asr #16          // ..........................*..........
        smulwb r6, r10, r7                 // ..........................*..........
        str r1, [r0, #20]                  // ...........................*.........
        smulwb r1, r10, r4                 // ...........................*.........
        ldr r7, [r0, #0]                   // ............................*........
        smlabt r6, r6, r11, r12            // ............................*........
        smlabt r1, r1, r11, r12            // .............................*.......
        pkhtb r5, r5, r6, asr #16          // ..............................*......
        smulwb r2, r10, r7                 // ..............................*......
        str r5, [r0, #24]                  // ...............................*.....
        smulwt r5, r10, r7                 // ...............................*.....
        pkhtb r3, r3, r1, asr #16          // ................................*....
        smlabt r1, r2, r11, r12            // ................................*....
        str r3, [r0, #28]                  // .................................*...
        smlabt r3, r5, r11, r12            // .................................*...
        pkhtb r3, r3, r1, asr #16          // ...................................*.
        str r3, [r0], #32                  // ...................................*.

                                           // -------- cycle (expected) --------->
                                           // 0                        25
                                           // |------------------------|----------
        // ldr r1, [r0, #0]                // ............................*.......
        // ldr r2, [r0, #4]                // ....*...............................
        // ldr r3, [r0, #8]                // *...................................
        // ldr r4, [r0, #12]               // *...................................
        // ldr r5, [r0, #16]               // .*..................................
        // ldr r6, [r0, #20]               // ..*.................................
        // ldr r7, [r0, #24]               // ....................*...............
        // ldr r8, [r0, #28]               // ............*.......................
        // smulwb r14, r10, r1             // ..............................*.....
        // smulwt r1, r10, r1              // ...............................*....
        // smlabt r14, r14, r11, r12       // ................................*...
        // smlabt r1, r1, r11, r12         // .................................*..
        // pkhtb r1, r1, r14, asr #16      // ...................................*
        // smulwb r14, r10, r2             // ..............*.....................
        // smulwt r2, r10, r2              // .............*......................
        // smlabt r14, r14, r11, r12       // ...................*................
        // smlabt r2, r2, r11, r12         // ....................*...............
        // pkhtb r2, r2, r14, asr #16      // ......................*.............
        // smulwb r14, r10, r3             // ......*.............................
        // smulwt r3, r10, r3              // ..*.................................
        // smlabt r14, r14, r11, r12       // ........*...........................
        // smlabt r3, r3, r11, r12         // .....*..............................
        // pkhtb r3, r3, r14, asr #16      // ..........*.........................
        // smulwb r14, r10, r4             // ...*................................
        // smulwt r4, r10, r4              // ..........*.........................
        // smlabt r14, r14, r11, r12       // .........*..........................
        // smlabt r4, r4, r11, r12         // ............*.......................
        // pkhtb r4, r4, r14, asr #16      // ..............*.....................
        // smulwb r14, r10, r5             // ....*...............................
        // smulwt r5, r10, r5              // ...............*....................
        // smlabt r14, r14, r11, r12       // .......*............................
        // smlabt r5, r5, r11, r12         // .................*..................
        // pkhtb r5, r5, r14, asr #16      // ...................*................
        // smulwb r14, r10, r6             // ...........*........................
        // smulwt r6, r10, r6              // .....................*..............
        // smlabt r14, r14, r11, r12       // ......................*.............
        // smlabt r6, r6, r11, r12         // ........................*...........
        // pkhtb r6, r6, r14, asr #16      // ..........................*.........
        // smulwb r14, r10, r7             // ..........................*.........
        // smulwt r7, r10, r7              // .......................*............
        // smlabt r14, r14, r11, r12       // ............................*.......
        // smlabt r7, r7, r11, r12         // .........................*..........
        // pkhtb r7, r7, r14, asr #16      // ..............................*.....
        // smulwb r14, r10, r8             // ...........................*........
        // smulwt r8, r10, r8              // ................*...................
        // smlabt r14, r14, r11, r12       // .............................*......
        // smlabt r8, r8, r11, r12         // ..................*.................
        // pkhtb r8, r8, r14, asr #16      // ................................*...
        // str r8, [r0, #28]               // .................................*..
        // str r7, [r0, #24]               // ...............................*....
        // str r6, [r0, #20]               // ...........................*........
        // str r5, [r0, #16]               // .....................*..............
        // str r4, [r0, #12]               // ................*...................
        // str r3, [r0, #8]                // ...........*........................
        // str r2, [r0, #4]                // .......................*............
        // str r1, [r0], #32               // ...................................*

        subs loop, #1
        bne 1b
                // Instructions:    0
                // Expected cycles: 0
                // Expected IPC:    0.00
                //
                // Wall time:     0.01s
                // User time:     0.01s
                //

 .unreq poly
 .unreq poly0
 .unreq poly1
 .unreq poly2
 .unreq poly3
 .unreq poly4
 .unreq poly5
 .unreq poly6
 .unreq poly7
 .unreq loop
 .unreq plantconst
 .unreq q
 .unreq qa
 .unreq tmp
 pop     {r4-r11, pc}
