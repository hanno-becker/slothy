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

.macro doublebarrett a, tmp, tmp2, q, barrettconst
  smulbb \tmp, \a, \barrettconst
  smultb \tmp2, \a, \barrettconst
  asr \tmp, \tmp, #26
  asr \tmp2, \tmp2, #26
  smulbb \tmp, \tmp, \q
  smulbb \tmp2, \tmp2, \q
  pkhbt \tmp, \tmp, \tmp2, lsl #16
  usub16 \a, \a, \tmp
.endm

.syntax unified
.cpu cortex-m4
.thumb

.global asm_barrett_reduce_opt_m7
.type asm_barrett_reduce_opt_m7,%function
.align 2
asm_barrett_reduce_opt_m7:
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
 barrettconst .req r10
 q           .req r11
 tmp         .req r12
 tmp2        .req r14

 movw barrettconst, #20159
 movw q, #3329

 movw loop, #16
                                // Instructions:    1
                                // Expected cycles: 1
                                // Expected IPC:    1.00
                                //
                                // Cycle bound:     1.0
                                // IPC bound:       1.00
                                //
                                // Wall time:     0.00s
                                // User time:     0.00s
                                //
                                // ----- cycle (expected) ------>
                                // 0                        25
                                // |------------------------|----
        ldr r2, [r0, #4]        // *.............................

                                 // ------ cycle (expected) ------>
                                 // 0                        25
                                 // |------------------------|-----
        // ldr r2, [r0, #4]      // *..............................

        sub r9, r9, #1
1:
                                           // Instructions:    81
                                           // Expected cycles: 41
                                           // Expected IPC:    1.98
                                           //
                                           // Cycle bound:     42.0
                                           // IPC bound:       1.93
                                           //
                                           // Wall time:     22.48s
                                           // User time:     22.48s
                                           //
                                           // ----------- cycle (expected) ----------->
                                           // 0                        25
                                           // |------------------------|---------------
        ldr r1, [r0, #8]                   // *........................................
        smultb r8, r2, r10                 // *........................................
        ldr r7, [r0, #28]                  // .*.......................................
        smulbb r3, r2, r10                 // .*.......................................
        asr r8, r8, #26                    // ..*......................................
        smultb r4, r1, r10                 // ..*......................................
        asr r3, r3, #26                    // ...*.....................................
        smulbb r8, r8, r11                 // ...*.....................................
        asr r4, r4, #26                    // ....*....................................
        smulbb r3, r3, r11                 // ....*....................................
        ldr r5, [r0, #0]                   // .....*...................................
        smultb r6, r7, r10                 // .....*...................................
        pkhbt r8, r3, r8, lsl #16          // ......*..................................
        smulbb r12, r7, r10                // ......*..................................
        asr r3, r6, #26                    // .......*.................................
        smulbb r6, r4, r11                 // .......*.................................
        asr r12, r12, #26                  // ........*................................
        smulbb r3, r3, r11                 // ........*................................
        ldr r4, [r0, #20]                  // .........*...............................
        smulbb r12, r12, r11               // .........*...............................
        usub16 r8, r2, r8                  // ..........*..............................
        smulbb r2, r1, r10                 // ..........*..............................
        pkhbt r3, r12, r3, lsl #16         // ...........*.............................
        smultb r12, r4, r10                // ...........*.............................
        usub16 r3, r7, r3                  // ............*............................
        smulbb r7, r4, r10                 // ............*............................
        asr r12, r12, #26                  // .............*...........................
        str r8, [r0, #4]                   // .............*...........................
        asr r7, r7, #26                    // ..............*..........................
        smulbb r8, r12, r11                // ..............*..........................
        asr r12, r2, #26                   // ...............*.........................
        smulbb r7, r7, r11                 // ...............*.........................
        str r3, [r0, #28]                  // ................*........................
        ldr r3, [r0, #12]                  // ................*........................
        pkhbt r7, r7, r8, lsl #16          // .................*.......................
        smulbb r12, r12, r11               // .................*.......................
        usub16 r7, r4, r7                  // ..................*......................
        str r7, [r0, #20]                  // ..................*......................
        pkhbt r12, r12, r6, lsl #16        // ...................*.....................
        smulbb r2, r3, r10                 // ...................*.....................
        usub16 r6, r1, r12                 // ....................*....................
        smultb r7, r3, r10                 // ....................*....................
        asr r2, r2, #26                    // .....................*...................
        smultb r12, r5, r10                // .....................*...................
        asr r7, r7, #26                    // ......................*..................
        smulbb r8, r5, r10                 // ......................*..................
        ldr r4, [r0, #24]                  // .......................*.................
        str r6, [r0, #8]                   // .......................*.................
        asr r14, r12, #26                  // ........................*................
        smulbb r7, r7, r11                 // ........................*................
        asr r8, r8, #26                    // .........................*...............
        smulbb r6, r14, r11                // .........................*...............
        subs.w r9, #1                      // ..........................*..............
        smulbb r14, r8, r11                // ..........................*..............
        ldr r1, [r0, #16]                  // ...........................*.............
        smultb r12, r4, r10                // ...........................*.............
        pkhbt r14, r14, r6, lsl #16        // ............................*............
        smulbb r8, r4, r10                 // ............................*............
        asr r12, r12, #26                  // .............................*...........
        smulbb r2, r2, r11                 // .............................*...........
        asr r8, r8, #26                    // ..............................*..........
        smulbb r12, r12, r11               // ..............................*..........
        usub16 r14, r5, r14                // ...............................*.........
        smulbb r8, r8, r11                 // ...............................*.........
        pkhbt r2, r2, r7, lsl #16          // ................................*........
        smultb r6, r1, r10                 // ................................*........
        pkhbt r7, r8, r12, lsl #16         // .................................*.......
        smulbb r8, r1, r10                 // .................................*.......
        asr r12, r6, #26                   // ..................................*......
        str r14, [r0], #32                 // ..................................*......
        asr r8, r8, #26                    // ...................................*.....
        smulbb r6, r12, r11                // ...................................*.....
        usub16 r2, r3, r2                  // ....................................*....
        str r2, [r0, #-20]                 // ....................................*....
        usub16 r3, r4, r7                  // .....................................*...
        smulbb r4, r8, r11                 // .....................................*...
        str r3, [r0, #-8]                  // ......................................*..
        pkhbt r8, r4, r6, lsl #16          // .......................................*.
        ldr r2, [r0, #4]                   // .......................................e.
        usub16 r3, r1, r8                  // ........................................*
        str r3, [r0, #-16]                 // ........................................*

                                             // ------------ cycle (expected) ------------>
                                             // 0                        25
                                             // |------------------------|-----------------
        // ldr r1, [r0, #0]                  // ..'....*...................................
        // ldr r2, [r0, #4]                  // e.'......................................~.
        // ldr r3, [r0, #8]                  // ..*........................................
        // ldr r4, [r0, #12]                 // ..'...............*........................
        // ldr r5, [r0, #16]                 // ..'..........................*.............
        // ldr r6, [r0, #20]                 // ..'........*...............................
        // ldr r7, [r0, #24]                 // ..'......................*.................
        // ldr r8, [r0, #28]                 // ..'*.......................................
        // smulbb r12, r1, r10               // ..'.....................*..................
        // smultb r14, r1, r10               // ..'....................*...................
        // asr r12, r12, #26                 // ..'........................*...............
        // asr r14, r14, #26                 // ..'.......................*................
        // smulbb r12, r12, r11              // ..'.........................*..............
        // smulbb r14, r14, r11              // ..'........................*...............
        // pkhbt r12, r12, r14, lsl #16      // ..'...........................*............
        // usub16 r1, r1, r12                // ..'..............................*.........
        // smulbb r12, r2, r10               // ..'*.......................................
        // smultb r14, r2, r10               // ..*........................................
        // asr r12, r12, #26                 // ..'..*.....................................
        // asr r14, r14, #26                 // ..'.*......................................
        // smulbb r12, r12, r11              // ..'...*....................................
        // smulbb r14, r14, r11              // ..'..*.....................................
        // pkhbt r12, r12, r14, lsl #16      // ..'.....*..................................
        // usub16 r2, r2, r12                // ..'.........*..............................
        // smulbb r12, r3, r10               // ..'.........*..............................
        // smultb r14, r3, r10               // ..'.*......................................
        // asr r12, r12, #26                 // ..'..............*.........................
        // asr r14, r14, #26                 // ..'...*....................................
        // smulbb r12, r12, r11              // ..'................*.......................
        // smulbb r14, r14, r11              // ..'......*.................................
        // pkhbt r12, r12, r14, lsl #16      // ..'..................*.....................
        // usub16 r3, r3, r12                // ..'...................*....................
        // smulbb r12, r4, r10               // ..'..................*.....................
        // smultb r14, r4, r10               // ..'...................*....................
        // asr r12, r12, #26                 // ..'....................*...................
        // asr r14, r14, #26                 // ..'.....................*..................
        // smulbb r12, r12, r11              // ..'............................*...........
        // smulbb r14, r14, r11              // ..'.......................*................
        // pkhbt r12, r12, r14, lsl #16      // ..'...............................*........
        // usub16 r4, r4, r12                // ..'...................................*....
        // smulbb r12, r5, r10               // ..'................................*.......
        // smultb r14, r5, r10               // ..'...............................*........
        // asr r12, r12, #26                 // ..'..................................*.....
        // asr r14, r14, #26                 // ..'.................................*......
        // smulbb r12, r12, r11              // ..'....................................*...
        // smulbb r14, r14, r11              // ..'..................................*.....
        // pkhbt r12, r12, r14, lsl #16      // ~.'......................................*.
        // usub16 r5, r5, r12                // .~'.......................................*
        // smulbb r12, r6, r10               // ..'...........*............................
        // smultb r14, r6, r10               // ..'..........*.............................
        // asr r12, r12, #26                 // ..'.............*..........................
        // asr r14, r14, #26                 // ..'............*...........................
        // smulbb r12, r12, r11              // ..'..............*.........................
        // smulbb r14, r14, r11              // ..'.............*..........................
        // pkhbt r12, r12, r14, lsl #16      // ..'................*.......................
        // usub16 r6, r6, r12                // ..'.................*......................
        // smulbb r12, r7, r10               // ..'...........................*............
        // smultb r14, r7, r10               // ..'..........................*.............
        // asr r12, r12, #26                 // ..'.............................*..........
        // asr r14, r14, #26                 // ..'............................*...........
        // smulbb r12, r12, r11              // ..'..............................*.........
        // smulbb r14, r14, r11              // ..'.............................*..........
        // pkhbt r12, r12, r14, lsl #16      // ..'................................*.......
        // usub16 r7, r7, r12                // ..'....................................*...
        // smulbb r12, r8, r10               // ..'.....*..................................
        // smultb r14, r8, r10               // ..'....*...................................
        // asr r12, r12, #26                 // ..'.......*................................
        // asr r14, r14, #26                 // ..'......*.................................
        // smulbb r12, r12, r11              // ..'........*...............................
        // smulbb r14, r14, r11              // ..'.......*................................
        // pkhbt r12, r12, r14, lsl #16      // ..'..........*.............................
        // usub16 r8, r8, r12                // ..'...........*............................
        // str r8, [r0, #28]                 // ..'...............*........................
        // str r7, [r0, #24]                 // ..'.....................................*..
        // str r6, [r0, #20]                 // ..'.................*......................
        // str r5, [r0, #16]                 // .~'.......................................*
        // str r4, [r0, #12]                 // ..'...................................*....
        // str r3, [r0, #8]                  // ..'......................*.................
        // str r2, [r0, #4]                  // ..'............*...........................
        // str r1, [r0], #32                 // ..'.................................*......
        // subs.w r9, #1                     // ..'.........................*..............

        bne 1b
                                           // Instructions:    80
                                           // Expected cycles: 40
                                           // Expected IPC:    2.00
                                           //
                                           // Cycle bound:     40.0
                                           // IPC bound:       2.00
                                           //
                                           // Wall time:     1.33s
                                           // User time:     1.33s
                                           //
                                           // ---------- cycle (expected) ----------->
                                           // 0                        25
                                           // |------------------------|--------------
        ldr r3, [r0, #8]                   // *.......................................
        smultb r1, r2, r10                 // *.......................................
        ldr r5, [r0, #28]                  // .*......................................
        smulbb r12, r2, r10                // .*......................................
        subs.w r9, #1                      // ..*.....................................
        smulbb r6, r3, r10                 // ..*.....................................
        asr r14, r1, #26                   // ...*....................................
        smultb r4, r5, r10                 // ...*....................................
        asr r8, r12, #26                   // ....*...................................
        smulbb r12, r14, r11               // ....*...................................
        asr r14, r6, #26                   // .....*..................................
        smulbb r7, r8, r11                 // .....*..................................
        ldr r6, [r0, #0]                   // ......*.................................
        smultb r1, r3, r10                 // ......*.................................
        pkhbt r8, r7, r12, lsl #16         // .......*................................
        smulbb r7, r5, r10                 // .......*................................
        usub16 r2, r2, r8                  // ........*...............................
        str r2, [r0, #4]                   // ........*...............................
        asr r8, r1, #26                    // .........*..............................
        smulbb r1, r14, r11                // .........*..............................
        asr r2, r7, #26                    // ..........*.............................
        smulbb r14, r8, r11                // ..........*.............................
        asr r12, r4, #26                   // ...........*............................
        smultb r8, r6, r10                 // ...........*............................
        ldr r7, [r0, #20]                  // ............*...........................
        smulbb r12, r12, r11               // ............*...........................
        asr r8, r8, #26                    // .............*..........................
        smulbb r4, r6, r10                 // .............*..........................
        pkhbt r1, r1, r14, lsl #16         // ..............*.........................
        smulbb r8, r8, r11                 // ..............*.........................
        usub16 r1, r3, r1                  // ...............*........................
        smultb r3, r7, r10                 // ...............*........................
        asr r4, r4, #26                    // ................*.......................
        smulbb r14, r7, r10                // ................*.......................
        asr r3, r3, #26                    // .................*......................
        smulbb r4, r4, r11                 // .................*......................
        asr r14, r14, #26                  // ..................*.....................
        smulbb r3, r3, r11                 // ..................*.....................
        pkhbt r4, r4, r8, lsl #16          // ...................*....................
        smulbb r8, r14, r11                // ...................*....................
        usub16 r4, r6, r4                  // ....................*...................
        smulbb r14, r2, r11                // ....................*...................
        ldr r6, [r0, #24]                  // .....................*..................
        str r1, [r0, #8]                   // .....................*..................
        pkhbt r2, r8, r3, lsl #16          // ......................*.................
        str r4, [r0], #32                  // ......................*.................
        pkhbt r1, r14, r12, lsl #16        // .......................*................
        smultb r8, r6, r10                 // .......................*................
        ldr r3, [r0, #-16]                 // ........................*...............
        smulbb r14, r6, r10                // ........................*...............
        usub16 r12, r5, r1                 // .........................*..............
        str r12, [r0, #-4]                 // .........................*..............
        usub16 r2, r7, r2                  // ..........................*.............
        smulbb r7, r3, r10                 // ..........................*.............
        str r2, [r0, #-12]                 // ...........................*............
        ldr r2, [r0, #-20]                 // ...........................*............
        asr r7, r7, #26                    // ............................*...........
        smultb r1, r3, r10                 // ............................*...........
        asr r8, r8, #26                    // .............................*..........
        smulbb r12, r2, r10                // .............................*..........
        asr r1, r1, #26                    // ..............................*.........
        smultb r4, r2, r10                 // ..............................*.........
        asr r14, r14, #26                  // ...............................*........
        smulbb r1, r1, r11                 // ...............................*........
        asr r4, r4, #26                    // ................................*.......
        smulbb r7, r7, r11                 // ................................*.......
        asr r12, r12, #26                  // .................................*......
        smulbb r4, r4, r11                 // .................................*......
        pkhbt r1, r7, r1, lsl #16          // ..................................*.....
        smulbb r12, r12, r11               // ..................................*.....
        usub16 r1, r3, r1                  // ...................................*....
        smulbb r3, r8, r11                 // ...................................*....
        pkhbt r12, r12, r4, lsl #16        // ....................................*...
        smulbb r4, r14, r11                // ....................................*...
        usub16 r2, r2, r12                 // .....................................*..
        str r2, [r0, #-20]                 // .....................................*..
        pkhbt r2, r4, r3, lsl #16          // ......................................*.
        str r1, [r0, #-16]                 // ......................................*.
        usub16 r2, r6, r2                  // .......................................*
        str r2, [r0, #-8]                  // .......................................*

                                            // ---------- cycle (expected) ----------->
                                            // 0                        25
                                            // |------------------------|--------------
        // ldr r1, [r0, #8]                 // *.......................................
        // smultb r8, r2, r10               // *.......................................
        // ldr r7, [r0, #28]                // .*......................................
        // smulbb r3, r2, r10               // .*......................................
        // asr r8, r8, #26                  // ...*....................................
        // smultb r4, r1, r10               // ......*.................................
        // asr r3, r3, #26                  // ....*...................................
        // smulbb r8, r8, r11               // ....*...................................
        // asr r4, r4, #26                  // .........*..............................
        // smulbb r3, r3, r11               // .....*..................................
        // ldr r5, [r0, #0]                 // ......*.................................
        // smultb r6, r7, r10               // ...*....................................
        // pkhbt r8, r3, r8, lsl #16        // .......*................................
        // smulbb r12, r7, r10              // .......*................................
        // asr r3, r6, #26                  // ...........*............................
        // smulbb r6, r4, r11               // ..........*.............................
        // asr r12, r12, #26                // ..........*.............................
        // smulbb r3, r3, r11               // ............*...........................
        // ldr r4, [r0, #20]                // ............*...........................
        // smulbb r12, r12, r11             // ....................*...................
        // usub16 r8, r2, r8                // ........*...............................
        // smulbb r2, r1, r10               // ..*.....................................
        // pkhbt r3, r12, r3, lsl #16       // .......................*................
        // smultb r12, r4, r10              // ...............*........................
        // usub16 r3, r7, r3                // .........................*..............
        // smulbb r7, r4, r10               // ................*.......................
        // asr r12, r12, #26                // .................*......................
        // str r8, [r0, #4]                 // ........*...............................
        // asr r7, r7, #26                  // ..................*.....................
        // smulbb r8, r12, r11              // ..................*.....................
        // asr r12, r2, #26                 // .....*..................................
        // smulbb r7, r7, r11               // ...................*....................
        // str r3, [r0, #28]                // .........................*..............
        // ldr r3, [r0, #12]                // ...........................*............
        // pkhbt r7, r7, r8, lsl #16        // ......................*.................
        // smulbb r12, r12, r11             // .........*..............................
        // usub16 r7, r4, r7                // ..........................*.............
        // str r7, [r0, #20]                // ...........................*............
        // pkhbt r12, r12, r6, lsl #16      // ..............*.........................
        // smulbb r2, r3, r10               // .............................*..........
        // usub16 r6, r1, r12               // ...............*........................
        // smultb r7, r3, r10               // ..............................*.........
        // asr r2, r2, #26                  // .................................*......
        // smultb r12, r5, r10              // ...........*............................
        // asr r7, r7, #26                  // ................................*.......
        // smulbb r8, r5, r10               // .............*..........................
        // ldr r4, [r0, #24]                // .....................*..................
        // str r6, [r0, #8]                 // .....................*..................
        // asr r14, r12, #26                // .............*..........................
        // smulbb r7, r7, r11               // .................................*......
        // asr r8, r8, #26                  // ................*.......................
        // smulbb r6, r14, r11              // ..............*.........................
        // subs.w r9, #1                    // ..*.....................................
        // smulbb r14, r8, r11              // .................*......................
        // ldr r1, [r0, #16]                // ........................*...............
        // smultb r12, r4, r10              // .......................*................
        // pkhbt r14, r14, r6, lsl #16      // ...................*....................
        // smulbb r8, r4, r10               // ........................*...............
        // asr r12, r12, #26                // .............................*..........
        // smulbb r2, r2, r11               // ..................................*.....
        // asr r8, r8, #26                  // ...............................*........
        // smulbb r12, r12, r11             // ...................................*....
        // usub16 r14, r5, r14              // ....................*...................
        // smulbb r8, r8, r11               // ....................................*...
        // pkhbt r2, r2, r7, lsl #16        // ....................................*...
        // smultb r6, r1, r10               // ............................*...........
        // pkhbt r7, r8, r12, lsl #16       // ......................................*.
        // smulbb r8, r1, r10               // ..........................*.............
        // asr r12, r6, #26                 // ..............................*.........
        // str r14, [r0], #32               // ......................*.................
        // asr r8, r8, #26                  // ............................*...........
        // smulbb r6, r12, r11              // ...............................*........
        // usub16 r2, r3, r2                // .....................................*..
        // str r2, [r0, #-20]               // .....................................*..
        // usub16 r3, r4, r7                // .......................................*
        // smulbb r4, r8, r11               // ................................*.......
        // str r3, [r0, #-8]                // .......................................*
        // pkhbt r8, r4, r6, lsl #16        // ..................................*.....
        // usub16 r3, r1, r8                // ...................................*....
        // str r3, [r0, #-16]               // ......................................*.


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
 .unreq barrettconst
 .unreq q
 .unreq tmp
 .unreq tmp2

 pop     {r4-r11, pc}

.size asm_barrett_reduce_opt_m7, .-asm_barrett_reduce_opt_m7