.syntax unified
.cpu cortex-m4
.thumb

.extern shake128_squeezeblocks

 rptr    .req r0
 bptr    .req r1
 cptr    .req r2
 bufptr  .req r3
 zetaptr .req r4
 val0    .req r5
 val1    .req r6
 tmp     .req r7
 tmp2    .req r8
 k       .req r9
 q       .req r10
 qa      .req r11
 qinv    .req r12
 ctr     .req r14

// q locates in the bottom half of the register
.macro plant_red_b q, qa, qinv, tmp
 mul \tmp, \tmp, \qinv
 // tmp*qinv mod 2^2n/ 2^n; in high half
 smlatb \tmp, \tmp, \q, \qa
 // result in high half
.endm

.macro doublebasemul_asm rptr, aptr, bptr, zetaptr, poly0, poly1, poly2, poly3, q, qa, qinv, tmp, tmp2, zeta
    ldr.w \poly0, [\aptr], #4
    ldr.w \poly1, [\bptr]
    ldr.w \poly2, [\aptr], #4
    ldr.w \poly3, [\bptr, #4]
    ldr.w \zeta, [\zetaptr], #4

    // basemul(r->coeffs + 4 * i, a->coeffs + 4 * i, b->coeffs + 4 * i, zetas[64 + i]);
    smulwt \tmp, \zeta, \poly1
    // b_1*zeta*qinv*plant_const; in low half
    smlabb \tmp, \tmp, \q, \qa
    // b_1*zeta
    smultt \tmp, \poly0, \tmp
    // a_1*b_1*zeta <2^32
    smlabb \tmp, \poly0, \poly1, \tmp
    // a1*b1*zeta+a0*b0
    plant_red_b \q, \qa, \qinv, \tmp
    // r[0] in upper half of tmp
    smuadx \tmp2, \poly0, \poly1
    plant_red_b \q, \qa, \qinv, \tmp2
    // r[1] in upper half of tmp2
    pkhtb \tmp, \tmp2, \tmp, asr #16
    str \tmp, [\rptr], #4

    neg \zeta, \zeta

    // basemul(r->coeffs + 4 * i + 2, a->coeffs + 4 * i + 2, b->coeffs + 4 * i + 2, - zetas[64 + i]);
    smulwt \tmp, \zeta, \poly3
    smlabb \tmp, \tmp, \q, \qa
    smultt \tmp, \poly2, \tmp
    smlabb \tmp, \poly2, \poly3, \tmp
    plant_red_b \q, \qa, \qinv, \tmp
    // r[0] in upper half of tmp

    smuadx \tmp2, \poly2, \poly3
    plant_red_b \q, \qa, \qinv, \tmp2
    // r[1] in upper half of tmp2
    pkhtb \tmp, \tmp2, \tmp, asr #16
    str \tmp, [\rptr], #4
.endm

// s17: bufptr; s26: state
// Checks if val0 is suitable and multiplies with values from bptr using func
.macro first_if
// if (val0 < KYBER_Q)
    cmp.w val0, q
    bhs.w 2f
        strh val0, [cptr], #2
        add k, #1
        cmp.w k, #4
        bne.w 2f
        slothy_start_1:
                                         // Instructions:    37
                                         // Expected cycles: 23
                                         // Expected IPC:    1.61
                                         //
                                         // Cycle bound:     23.0
                                         // IPC bound:       1.61
                                         //
                                         // Wall time:     0.15s
                                         // User time:     0.15s
                                         //
                                         // ----- cycle (expected) ------>
                                         // 0                        25
                                         // |------------------------|----
        sub r2, #4*2                     // *.............................
        vmov s19, r14                    // *.............................
        ldr.w r14, [r1], #4              // .*............................
        ldr.w r9, [r2]                   // .*............................
        vmov s18, r3                     // ..*...........................
        ldr.w r3, [r4], #4               // ..*...........................
        smuadx r8, r14, r9               // ...*..........................
        vmov s20, r6                     // ....*.........................
        smulwt r6, r3, r9                // ....*.........................
        mul r5, r8, r12                  // .....*........................
        ldr.w r8, [r2, #4]               // ......*.......................
        smlabb r6, r6, r10, r11          // ......*.......................
        neg r3, r3                       // .......*......................
        smlatb r5, r5, r10, r11          // .......*......................
        smulwt r3, r3, r8                // ........*.....................
        smultt r7, r14, r6               // .........*....................
        ldr.w r6, [r1], #4               // ..........*...................
        smlabb r3, r3, r10, r11          // ..........*...................
        smlabb r7, r14, r9, r7           // ...........*..................
        smultt r9, r6, r3                // ............*.................
        smlabb r9, r6, r8, r9            // .............*................
        mul r14, r7, r12                 // ..............*...............
        smuadx r7, r6, r8                // ...............*..............
        vmov r6, s20                     // ................*.............
        smlatb r8, r14, r10, r11         // ................*.............
        vmov r3, s18                     // .................*............
        mul r9, r9, r12                  // .................*............
        vmov r14, s19                    // ..................*...........
        mul r7, r7, r12                  // ..................*...........
        pkhtb r8, r5, r8, asr #16        // ...................*..........
        smlatb r5, r9, r10, r11          // ...................*..........
        add r14, #1                      // ....................*.........
        smlatb r7, r7, r10, r11          // ....................*.........
        movw r9, #0                      // .....................*........
        str r8, [r0], #4                 // .....................*........
        pkhtb r7, r7, r5, asr #16        // ......................*.......
        str r7, [r0], #4                 // ......................*.......

                                          // ------ cycle (expected) ------>
                                          // 0                        25
                                          // |------------------------|-----
        // sub r2, #4*2                   // *..............................
        // vmov s18, r3                   // ..*............................
        // vmov s19, r14                  // *..............................
        // vmov s20, r6                   // ....*..........................
        // ldr.w r3, [r1], #4             // .*.............................
        // ldr.w r9, [r2]                 // .*.............................
        // ldr.w r5, [r1], #4             // ..........*....................
        // ldr.w r6, [r2, #4]             // ......*........................
        // ldr.w r14, [r4], #4            // ..*............................
        // smulwt r7, r14, r9             // ....*..........................
        // smlabb r7, r7, r10, r11        // ......*........................
        // smultt r7, r3, r7              // .........*.....................
        // smlabb r7, r3, r9, r7          // ...........*...................
        // mul r7, r7, r12                // ..............*................
        // smlatb r7, r7, r10, r11        // ................*..............
        // smuadx r8, r3, r9              // ...*...........................
        // mul r8, r8, r12                // .....*.........................
        // smlatb r8, r8, r10, r11        // .......*.......................
        // pkhtb r7, r8, r7, asr #16      // ...................*...........
        // str r7, [r0], #4               // .....................*.........
        // neg r14, r14                   // .......*.......................
        // smulwt r7, r14, r6             // ........*......................
        // smlabb r7, r7, r10, r11        // ..........*....................
        // smultt r7, r5, r7              // ............*..................
        // smlabb r7, r5, r6, r7          // .............*.................
        // mul r7, r7, r12                // .................*.............
        // smlatb r7, r7, r10, r11        // ...................*...........
        // smuadx r8, r5, r6              // ...............*...............
        // mul r8, r8, r12                // ..................*............
        // smlatb r8, r8, r10, r11        // ....................*..........
        // pkhtb r7, r8, r7, asr #16      // ......................*........
        // str r7, [r0], #4               // ......................*........
        // vmov r3, s18                   // .................*.............
        // vmov r14, s19                  // ..................*............
        // vmov r6, s20                   // ................*..............
        // add r14, #1                    // ....................*..........
        // movw r9, #0                    // .....................*.........

        slothy_end_1:

    2:
.endm

// Checks if val1 is suitable and multiplies with values from bptr using func
.macro second_if
// if (val1 < KYBER_Q && ctr < KYBER_N/4)
    cmp.w val1, q
    bhs.w 2f
        cmp.w ctr, #256/4
        bge.w 2f
            strh val1, [cptr], #2
            add k, #1
            cmp.w k, #4
            bne.w 2f
        slothy_start_2:
                                         // Instructions:    35
                                         // Expected cycles: 23
                                         // Expected IPC:    1.52
                                         //
                                         // Cycle bound:     23.0
                                         // IPC bound:       1.52
                                         //
                                         // Wall time:     0.22s
                                         // User time:     0.22s
                                         //
                                         // ----- cycle (expected) ------>
                                         // 0                        25
                                         // |------------------------|----
        sub r2, #4*2                     // *.............................
        vmov s18, r3                     // *.............................
        ldr.w r6, [r4], #4               // .*............................
        ldr.w r8, [r2]                   // .*............................
        ldr.w r3, [r1], #4               // ..*...........................
        vmov s19, r14                    // ..*...........................
        ldr.w r14, [r2, #4]              // ...*..........................
        smulwt r5, r6, r8                // ...*..........................
        neg r6, r6                       // ....*.........................
        smuadx r9, r3, r8                // ....*.........................
        ldr.w r7, [r1], #4               // .....*........................
        smlabb r5, r5, r10, r11          // .....*........................
        smulwt r6, r6, r14               // ......*.......................
        smultt r5, r3, r5                // .......*......................
        smlabb r6, r6, r10, r11          // ........*.....................
        smlabb r5, r3, r8, r5            // .........*....................
        smultt r6, r7, r6                // ..........*...................
        smlabb r6, r7, r14, r6           // ...........*..................
        smuadx r3, r7, r14               // ............*.................
        vmov r14, s19                    // .............*................
        mul r5, r5, r12                  // .............*................
        add r14, #1                      // ..............*...............
        mul r8, r3, r12                  // ..............*...............
        vmov r3, s18                     // ...............*..............
        smlatb r5, r5, r10, r11          // ...............*..............
        mul r9, r9, r12                  // ................*.............
        mul r7, r6, r12                  // .................*............
        smlatb r9, r9, r10, r11          // ..................*...........
        smlatb r6, r7, r10, r11          // ...................*..........
        pkhtb r5, r9, r5, asr #16        // ....................*.........
        smlatb r8, r8, r10, r11          // ....................*.........
        str r5, [r0], #4                 // .....................*........
        movw r9, #0                      // .....................*........
        pkhtb r5, r8, r6, asr #16        // ......................*.......
        str r5, [r0], #4                 // ......................*.......

                                          // ------ cycle (expected) ------>
                                          // 0                        25
                                          // |------------------------|-----
        // sub r2, #4*2                   // *..............................
        // vmov s18, r3                   // *..............................
        // vmov s19, r14                  // ..*............................
        // ldr.w r3, [r1], #4             // ..*............................
        // ldr.w r9, [r2]                 // .*.............................
        // ldr.w r5, [r1], #4             // .....*.........................
        // ldr.w r6, [r2, #4]             // ...*...........................
        // ldr.w r14, [r4], #4            // .*.............................
        // smulwt r7, r14, r9             // ...*...........................
        // smlabb r7, r7, r10, r11        // .....*.........................
        // smultt r7, r3, r7              // .......*.......................
        // smlabb r7, r3, r9, r7          // .........*.....................
        // mul r7, r7, r12                // .............*.................
        // smlatb r7, r7, r10, r11        // ...............*...............
        // smuadx r8, r3, r9              // ....*..........................
        // mul r8, r8, r12                // ................*..............
        // smlatb r8, r8, r10, r11        // ..................*............
        // pkhtb r7, r8, r7, asr #16      // ....................*..........
        // str r7, [r0], #4               // .....................*.........
        // neg r14, r14                   // ....*..........................
        // smulwt r7, r14, r6             // ......*........................
        // smlabb r7, r7, r10, r11        // ........*......................
        // smultt r7, r5, r7              // ..........*....................
        // smlabb r7, r5, r6, r7          // ...........*...................
        // mul r7, r7, r12                // .................*.............
        // smlatb r7, r7, r10, r11        // ...................*...........
        // smuadx r8, r5, r6              // ............*..................
        // mul r8, r8, r12                // ..............*................
        // smlatb r8, r8, r10, r11        // ....................*..........
        // pkhtb r7, r8, r7, asr #16      // ......................*........
        // str r7, [r0], #4               // ......................*........
        // vmov r3, s18                   // ...............*...............
        // vmov r14, s19                  // .............*.................
        // add r14, #1                    // ..............*................
        // movw r9, #0                    // .....................*.........

        slothy_end_2:

    2:
.endm

.macro third_if tmp, tmp2, rptr, bptr, cptr, bufptr, ctr
// if (pos + 3 > buflen && ctr < KYBER_N/4)
  vmov \tmp, s17
  add \tmp, #168 // XOF_BLOCKBYTES=168
  add \tmp2, \bufptr, #3
  cmp.w \tmp2, \tmp  // pos + 3 > buflen
  ble.w 2f
    cmp.w \ctr, #256/4
    bge.w 2f
      vmov \bufptr, s17

      vmov s16, r12
      vmov s18, \rptr
      vmov s19, \bptr
      vmov s20, \cptr
      vmov s21, \ctr

      mov \rptr, \bufptr // bufptr
      movw \bptr, #1
      vmov \cptr, s26 // load state
      #ifndef nohash
      bl shake128_squeezeblocks
      #endif

      vmov r12, s16
      vmov \rptr, s18
      vmov \bptr, s19
      vmov \cptr, s20
      vmov \ctr, s21
      vmov \bufptr, s17
    2:
.endm




// void matacc_asm(int16_t *r, const int16_t *b, int16_t c[4], unsigned char buf[XOF_BLOCKBYTES+2], const int32_t zetas[64], xof_state *state)
.global matacc_asm_opt_m7
.type matacc_asm_opt_m7, %function
.align 2
matacc_asm_opt_m7:
 push {r0-r11, r14}


 ldr.w zetaptr, [sp, #13*4] // load zetaptr from stack
 ldr.w tmp, [sp, #14*4] // load state from stack
 vmov s26, tmp

 movw qa, #26632
 movw q, #3329
 ### qinv=0x6ba8f301
 movw qinv, #62209
 movt qinv, #27560
 movw k, #0

 // outer while loop
 movw ctr, #0
 vmov s17, bufptr // save bufptr to check later
 1:
  ldrh val0, [bufptr], #2
  ldrb val1, [bufptr], #1
  ubfx tmp, val0, #12, #4
  orr val1, tmp, val1, lsl #4
  ubfx val0, val0, #0, #12
  ubfx val1, val1, #0, #12

  first_if

  second_if

  third_if tmp, tmp2, rptr, bptr, cptr, bufptr, ctr

 cmp ctr, #256/4
 blt.w 1b

 pop {r0-r11, pc}

.size matacc_asm_opt_m7, .-matacc_asm_opt_m7