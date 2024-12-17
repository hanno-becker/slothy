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


.macro doublebasemul_asm_acc_cache_32_32 rptr_tmp, aptr, bptr, zetaptr, poly0, poly1, tmp, tmp2, q, qa, qinv, res, aprimeptr, zeta
  vmov \aprimeptr, s27
  ldr \poly0, [\aptr], #4
  ldr \poly1, [\bptr]

  ldr \res, [\rptr_tmp]
  ldr \zeta, [\zetaptr], #4

  smulwt \tmp, \zeta, \poly0
  smlabb \tmp, \tmp, \q, \qa
  pkhbt \tmp, \poly0, \tmp
  str \tmp, [\aprimeptr], #4 // store (poly0_t*zeta || poly0_b) for later re-use
  smlatt \tmp, \tmp, \poly1, \res
  smlabb \res, \poly0, \poly1, \tmp
  str \res, [\rptr_tmp], #4

  ldr.w \res, [\rptr_tmp]
  smladx \res, \poly0, \poly1, \res

  str.w \res, [\rptr_tmp], #4

  neg \zeta, \zeta

  ldr \poly0, [\aptr], #4
  ldr.w \poly1, [\bptr, #4]
  ldr \res, [\rptr_tmp]
  smulwt \tmp, \zeta, \poly0
  smlabb \tmp, \tmp, \q, \qa
  pkhbt \tmp, \poly0, \tmp
  str \tmp, [\aprimeptr], #4 // store (poly2_t*zeta || poly2_b) for later re-use
  smlatt \tmp, \tmp, \poly1, \res
  smlabb \res, \poly0, \poly1, \tmp
  str.w \res, [\rptr_tmp], #4

  ldr.w \res, [\rptr_tmp]
  smladx \res, \poly0, \poly1, \res

  str \res, [\rptr_tmp], #4
  vmov s27, \aprimeptr
.endm

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
                                         // Instructions:    39
                                         // Expected cycles: 24
                                         // Expected IPC:    1.62
                                         //
                                         // Cycle bound:     24.0
                                         // IPC bound:       1.62
                                         //
                                         // Wall time:     0.26s
                                         // User time:     0.26s
                                         //
                                         // ----- cycle (expected) ------>
                                         // 0                        25
                                         // |------------------------|----
        vmov s18, r3                     // *.............................
        ldr r7, [r1], #4                 // *.............................
        sub r2, #4*2                     // .*............................
        ldr r3, [r4], #4                 // .*............................
        vmov s19, r14                    // ..*...........................
        ldr r5, [r1], #4                 // ..*...........................
        smulwt r14, r3, r7               // ...*..........................
        neg r3, r3                       // ....*.........................
        ldr r9, [r0]                     // .....*........................
        smlabb r14, r14, r10, r11        // .....*........................
        smulwt r3, r3, r5                // ......*.......................
        vmov s20, r6                     // .......*......................
        ldr r6, [r2]                     // .......*......................
        pkhbt r8, r7, r14                // ........*.....................
        smlatt r14, r8, r6, r9           // .........*....................
        smlabb r9, r7, r6, r14           // ..........*...................
        vmov r14, s27                    // ...........*..................
        str r9, [r0], #4                 // ...........*..................
        ldr.w r9, [r0]                   // ............*.................
        smlabb r3, r3, r10, r11          // ............*.................
        str r8, [r14], #4                // .............*................
        ldr.w r8, [r2, #4]               // ..............*...............
        smladx r7, r7, r6, r9            // ..............*...............
        pkhbt r6, r5, r3                 // ...............*..............
        str.w r7, [r0], #4               // ...............*..............
        str r6, [r14], #4                // ................*.............
        ldr r3, [r0]                     // ................*.............
        smlatt r7, r6, r8, r3            // .................*............
        vmov s27, r14                    // ..................*...........
        smlabb r7, r5, r8, r7            // ..................*...........
        str.w r7, [r0], #4               // ...................*..........
        vmov r6, s20                     // ...................*..........
        ldr.w r7, [r0]                   // ....................*.........
        vmov r14, s19                    // ....................*.........
        vmov r3, s18                     // .....................*........
        add r14, #1                      // .....................*........
        smladx r5, r5, r8, r7            // ......................*.......
        movw r9, #0                      // .......................*......
        str r5, [r0], #4                 // .......................*......

                                        // ------ cycle (expected) ------>
                                        // 0                        25
                                        // |------------------------|-----
        // sub r2, #4*2                 // .*.............................
        // vmov s18, r3                 // *..............................
        // vmov s19, r14                // ..*............................
        // vmov s20, r6                 // .......*.......................
        // vmov r8, s27                 // ...........*...................
        // ldr r3, [r1], #4             // *..............................
        // ldr r9, [r2]                 // .......*.......................
        // ldr r7, [r0]                 // .....*.........................
        // ldr r14, [r4], #4            // .*.............................
        // smulwt r5, r14, r3           // ...*...........................
        // smlabb r5, r5, r10, r11      // .....*.........................
        // pkhbt r5, r3, r5             // ........*......................
        // str r5, [r8], #4             // .............*.................
        // smlatt r5, r5, r9, r7        // .........*.....................
        // smlabb r7, r3, r9, r5        // ..........*....................
        // str r7, [r0], #4             // ...........*...................
        // ldr.w r7, [r0]               // ............*..................
        // smladx r7, r3, r9, r7        // ..............*................
        // str.w r7, [r0], #4           // ...............*...............
        // neg r14, r14                 // ....*..........................
        // ldr r3, [r1], #4             // ..*............................
        // ldr.w r9, [r2, #4]           // ..............*................
        // ldr r7, [r0]                 // ................*..............
        // smulwt r5, r14, r3           // ......*........................
        // smlabb r5, r5, r10, r11      // ............*..................
        // pkhbt r5, r3, r5             // ...............*...............
        // str r5, [r8], #4             // ................*..............
        // smlatt r5, r5, r9, r7        // .................*.............
        // smlabb r7, r3, r9, r5        // ..................*............
        // str.w r7, [r0], #4           // ...................*...........
        // ldr.w r7, [r0]               // ....................*..........
        // smladx r7, r3, r9, r7        // ......................*........
        // str r7, [r0], #4             // .......................*.......
        // vmov s27, r8                 // ..................*............
        // vmov r3, s18                 // .....................*.........
        // vmov r14, s19                // ....................*..........
        // vmov r6, s20                 // ...................*...........
        // add r14, #1                  // .....................*.........
        // movw r9, #0                  // .......................*.......

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
                                       // Instructions:    37
                                       // Expected cycles: 24
                                       // Expected IPC:    1.54
                                       //
                                       // Cycle bound:     24.0
                                       // IPC bound:       1.54
                                       //
                                       // Wall time:     0.56s
                                       // User time:     0.56s
                                       //
                                       // ----- cycle (expected) ------>
                                       // 0                        25
                                       // |------------------------|----
        sub r2, #4*2                   // *.............................
        ldr r5, [r1], #4               // *.............................
        vmov s19, r14                  // .*............................
        ldr r14, [r4], #4              // .*............................
        ldr r9, [r1], #4               // ..*...........................
        vmov s18, r3                   // ..*...........................
        smulwt r6, r14, r5             // ...*..........................
        neg r14, r14                   // ....*.........................
        ldr r3, [r2]                   // .....*........................
        smlabb r6, r6, r10, r11        // .....*........................
        ldr r7, [r0]                   // ......*.......................
        smulwt r8, r14, r9             // ......*.......................
        vmov r14, s27                  // .......*......................
        pkhbt r6, r5, r6               // ........*.....................
        str r6, [r14], #4              // ........*.....................
        smlatt r7, r6, r3, r7          // .........*....................
        smlabb r7, r5, r3, r7          // ..........*...................
        str r7, [r0], #4               // ...........*..................
        ldr.w r6, [r0]                 // ............*.................
        smlabb r8, r8, r10, r11        // ............*.................
        ldr.w r7, [r2, #4]             // .............*................
        smladx r3, r5, r3, r6          // ..............*...............
        pkhbt r6, r9, r8               // ...............*..............
        str.w r3, [r0], #4             // ...............*..............
        str r6, [r14], #4              // ................*.............
        ldr r3, [r0]                   // ................*.............
        vmov s27, r14                  // .................*............
        smlatt r8, r6, r7, r3          // .................*............
        vmov r3, s18                   // ..................*...........
        smlabb r8, r9, r7, r8          // ..................*...........
        vmov r14, s19                  // ...................*..........
        str.w r8, [r0], #4             // ...................*..........
        add r14, #1                    // ....................*.........
        ldr.w r6, [r0]                 // ....................*.........
        smladx r7, r9, r7, r6          // ......................*.......
        movw r9, #0                    // .......................*......
        str r7, [r0], #4               // .......................*......

                                        // ------ cycle (expected) ------>
                                        // 0                        25
                                        // |------------------------|-----
        // sub r2, #4*2                 // *..............................
        // vmov s18, r3                 // ..*............................
        // vmov s19, r14                // .*.............................
        // vmov r8, s27                 // .......*.......................
        // ldr r3, [r1], #4             // *..............................
        // ldr r9, [r2]                 // .....*.........................
        // ldr r7, [r0]                 // ......*........................
        // ldr r14, [r4], #4            // .*.............................
        // smulwt r5, r14, r3           // ...*...........................
        // smlabb r5, r5, r10, r11      // .....*.........................
        // pkhbt r5, r3, r5             // ........*......................
        // str r5, [r8], #4             // ........*......................
        // smlatt r5, r5, r9, r7        // .........*.....................
        // smlabb r7, r3, r9, r5        // ..........*....................
        // str r7, [r0], #4             // ...........*...................
        // ldr.w r7, [r0]               // ............*..................
        // smladx r7, r3, r9, r7        // ..............*................
        // str.w r7, [r0], #4           // ...............*...............
        // neg r14, r14                 // ....*..........................
        // ldr r3, [r1], #4             // ..*............................
        // ldr.w r9, [r2, #4]           // .............*.................
        // ldr r7, [r0]                 // ................*..............
        // smulwt r5, r14, r3           // ......*........................
        // smlabb r5, r5, r10, r11      // ............*..................
        // pkhbt r5, r3, r5             // ...............*...............
        // str r5, [r8], #4             // ................*..............
        // smlatt r5, r5, r9, r7        // .................*.............
        // smlabb r7, r3, r9, r5        // ..................*............
        // str.w r7, [r0], #4           // ...................*...........
        // ldr.w r7, [r0]               // ....................*..........
        // smladx r7, r3, r9, r7        // ......................*........
        // str r7, [r0], #4             // .......................*.......
        // vmov s27, r8                 // .................*.............
        // vmov r3, s18                 // ..................*............
        // vmov r14, s19                // ...................*...........
        // add r14, #1                  // ....................*..........
        // movw r9, #0                  // .......................*.......

        slothy_end_2:

    2:
.endm


.macro load_vals val0, val1, bufptr, tmp
  ldrh \val0, [\bufptr], #2
  ldrb \val1, [\bufptr], #1
  ubfx \tmp, \val0, #12, #4
  orr \val1, \tmp, \val1, lsl #4
  ubfx \val0, \val0, #0, #12
  ubfx \val1, \val1, #0, #12
.endm

// shake128_squeezeblocks into buffer if all bytes have been used
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

      mov \rptr, \bufptr
      movw \bptr, #1
      vmov \cptr, s26 // load state

      bl shake128_squeezeblocks

      vmov r12, s16
      vmov \rptr, s18
      vmov \bptr, s19
      vmov \cptr, s20
      vmov \ctr, s21
      vmov \bufptr, s17
    2:
.endm

// void matacc_asm_cache_32_32(int32_t *r_tmp, const int16_t *b, int16_t c[4], unsigned char buf[XOF_BLOCKBYTES+2], const int32_t zetas[64], xof_state *state, int16_t *aprimeptr)
.global matacc_asm_cache_32_32_opt_m7
.type matacc_asm_cache_32_32_opt_m7, %function
.align 2
matacc_asm_cache_32_32_opt_m7:
  push {r0-r11, r14}

  movw qa, #26632
 movw q, #3329
 ### qinv=0x6ba8f301
 movw qinv, #62209
 movt qinv, #27560
  movw k, #0

  ldr.w zetaptr, [sp, #13*4] // load zetaptr from stack
  ldr.w tmp, [sp, #14*4] // load state from stack
  vmov s26, tmp

  ldr.w tmp, [sp, #15*4] // load aprimeptr from stack
  vmov s27, tmp

  // outer while loop
  movw ctr, #0
  vmov s17, bufptr // save bufptr to check later
  1:

    load_vals val0, val1, bufptr, tmp

    first_if

    second_if

    third_if tmp, tmp2, rptr, bptr, cptr, bufptr, ctr

    cmp ctr, #256/4
    blt.w 1b

  pop {r0-r11, pc}

.size matacc_asm_cache_32_32_opt_m7, .-matacc_asm_cache_32_32_opt_m7