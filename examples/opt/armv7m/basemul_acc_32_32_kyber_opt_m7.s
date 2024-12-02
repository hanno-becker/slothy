.syntax unified
.cpu cortex-m4
.thumb

// void basemul_asm_acc_opt_32_32(int32_t *, const int16_t *, const int16_t *, const int16_t *)
.global basemul_asm_acc_opt_32_32_opt_m7
.type basemul_asm_acc_opt_32_32_opt_m7, %function
.align 2
basemul_asm_acc_opt_32_32_opt_m7:
  push {r4-r11, lr}

  rptr_tmp  .req r0
  aptr      .req r1
  bptr      .req r2
  aprimeptr .req r3
  poly0     .req r4
  poly1     .req r6
  res0      .req r5
  res1      .req r7
  q         .req r8
  qa        .req r9
  qinv      .req r10
  tmp       .req r11
  tmp2      .req r12
  loop      .req r14

  // movw qa, #26632
 // movt  q, #3329
 ### qinv=0x6ba8f301
 // movw qinv, #62209
 // movt qinv, #27560

  movw loop, #64
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
        ldr r7, [r2], #8        // *.............................

                                 // ------ cycle (expected) ------>
                                 // 0                        25
                                 // |------------------------|-----
        // ldr r7, [r2], #8      // *..............................

        sub r14, r14, #1
1:
                                       // Instructions:    19
                                       // Expected cycles: 10
                                       // Expected IPC:    1.90
                                       //
                                       // Cycle bound:     11.0
                                       // IPC bound:       1.73
                                       //
                                       // Wall time:     0.59s
                                       // User time:     0.59s
                                       //
                                       // ----- cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|----
        ldr.w r11, [r0, #4]            // *.............................
        ldr r10, [r1], #8              // *.............................
        ldr r4, [r2, #-4]              // .*............................
        ldr.w r6, [r0, #8]             // .*............................
        ldr r12, [r3, #4]              // ..*...........................
        smladx r9, r10, r7, r11        // ..*...........................
        ldr.w r8, [r0, #12]            // ...*..........................
        str r9, [r0, #4]               // ...*..........................
        ldr r5, [r1, #-4]              // ....*.........................
        smlad r6, r12, r4, r6          // ....*.........................
        str r6, [r0, #8]               // .....*........................
        ldr r11, [r3], #8              // .....*........................
        ldr.w r9, [r0]                 // ......*.......................
        smladx r10, r5, r4, r8         // ......*.......................
        str r10, [r0, #12]             // .......*......................
        subs.w r14, #1                 // .......*......................
        smlad r11, r11, r7, r9         // ........*.....................
        str r11, [r0], #16             // .........*....................
        ldr r7, [r2], #8               // .........e....................

                                       // ------ cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|-----
        // ldr r4, [r1], #8            // .*.........~.........~.........
        // ldr r6, [r2], #8            // e'........~'........~'.........
        // ldr.w r5, [r0]              // .'.....*...'.....~...'.....~...
        // ldr r12, [r3], #8           // .'....*....'....~....'....~....
        // ldr.w r7, [r0, #4]          // .*.........~.........~.........
        // smlad r12, r12, r6, r5      // .'.......*.'.......~.'.......~.
        // str r12, [r0], #16          // ~'........*'........~'.........
        // smladx r11, r4, r6, r7      // .'.*.......'.~.......'.~.......
        // str r11, [r0, #-12]         // .'..*......'..~......'..~......
        // ldr r4, [r1, #-4]           // .'...*.....'...~.....'...~.....
        // ldr r6, [r2, #-4]           // .'*........'~........'~........
        // ldr.w r5, [r0, #-8]         // .'*........'~........'~........
        // ldr r12, [r3, #-4]          // .'.*.......'.~.......'.~.......
        // ldr.w r7, [r0, #-4]         // .'..*......'..~......'..~......
        // smlad r12, r12, r6, r5      // .'...*.....'...~.....'...~.....
        // str r12, [r0, #-8]          // .'....*....'....~....'....~....
        // smladx r11, r4, r6, r7      // .'.....*...'.....~...'.....~...
        // str r11, [r0, #-4]          // .'......*..'......~..'......~..
        // subs.w r14, #1              // .'......*..'......~..'......~..

        bne 1b
                                      // Instructions:    18
                                      // Expected cycles: 10
                                      // Expected IPC:    1.80
                                      //
                                      // Cycle bound:     10.0
                                      // IPC bound:       1.80
                                      //
                                      // Wall time:     0.04s
                                      // User time:     0.04s
                                      //
                                      // ----- cycle (expected) ------>
                                      // 0                        25
                                      // |------------------------|----
        ldr.w r9, [r0, #4]            // *.............................
        ldr r11, [r1], #8             // *.............................
        ldr r8, [r3], #8              // .*............................
        ldr r5, [r3, #-4]             // .*............................
        ldr.w r4, [r0]                // ..*...........................
        smladx r9, r11, r7, r9        // ..*...........................
        ldr.w r11, [r0, #8]           // ...*..........................
        str r9, [r0, #4]              // ...*..........................
        ldr r9, [r2, #-4]             // ....*.........................
        smlad r7, r8, r7, r4          // ....*.........................
        str r7, [r0], #16             // .....*........................
        ldr.w r7, [r0, #-4]           // .....*........................
        ldr r8, [r1, #-4]             // ......*.......................
        smlad r11, r5, r9, r11        // ......*.......................
        subs.w r14, #1                // .......*......................
        str r11, [r0, #-8]            // .......*......................
        smladx r7, r8, r9, r7         // ........*.....................
        str r7, [r0, #-4]             // .........*....................

                                        // ------ cycle (expected) ------>
                                        // 0                        25
                                        // |------------------------|-----
        // ldr.w r11, [r0, #4]          // *..............................
        // ldr r10, [r1], #8            // *..............................
        // ldr r4, [r2, #-4]            // ....*..........................
        // ldr.w r6, [r0, #8]           // ...*...........................
        // ldr r12, [r3, #4]            // .*.............................
        // smladx r9, r10, r7, r11      // ..*............................
        // ldr.w r8, [r0, #12]          // .....*.........................
        // str r9, [r0, #4]             // ...*...........................
        // ldr r5, [r1, #-4]            // ......*........................
        // smlad r6, r12, r4, r6        // ......*........................
        // str r6, [r0, #8]             // .......*.......................
        // ldr r11, [r3], #8            // .*.............................
        // ldr.w r9, [r0]               // ..*............................
        // smladx r10, r5, r4, r8       // ........*......................
        // str r10, [r0, #12]           // .........*.....................
        // subs.w r14, #1               // .......*.......................
        // smlad r11, r11, r7, r9       // ....*..........................
        // str r11, [r0], #16           // .....*.........................


  pop {r4-r11, pc}
