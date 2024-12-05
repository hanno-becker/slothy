                                                // Instructions:    20
                                                // Expected cycles: 28
                                                // Expected IPC:    0.71
                                                //
                                                // Wall time:     0.25s
                                                // User time:     0.25s
                                                //
                                                // ----- cycle (expected) ------>
                                                // 0                        25
                                                // |------------------------|----
        ldr q2, [x0, #48]                       // *.............................
        ldr q4, [x1, #0]                        // ..*...........................
        ldr q13, [x0, #16]                      // ....*.........................
        mul v27.8H, v2.8H, v4.H[0]              // ......*.......................
        sqrdmulh v6.8H, v2.8H, v4.H[1]          // .......*......................
        ldr q3, [x2, #0]                        // ........*.....................
        mul v24.8H, v13.8H, v4.H[0]             // ..........*...................
        ldr q28, [x0, #32]                      // ...........*..................
        mls v27.8H, v6.8H, v3.H[0]              // .............*................
        sqrdmulh v14.8H, v13.8H, v4.H[1]        // ..............*...............
        ldr q2, [x0]                            // ...............*..............
        sub v18.8H, v28.8H, v27.8H              // .................*............
        mls v24.8H, v14.8H, v3.H[0]             // ..................*...........
        add v9.8H, v28.8H, v27.8H               // ....................*.........
        str q18, [x0, #48]                      // .....................*........
        add v12.8H, v2.8H, v24.8H               // ......................*.......
        str q9, [x0, #32]                       // .......................*......
        sub v3.8H, v2.8H, v24.8H                // ........................*.....
        str q12, [x0], #4*16                    // .........................*....
        str q3, [x0, #-48]                      // ...........................*..

                                                  // ------ cycle (expected) ------>
                                                  // 0                        25
                                                  // |------------------------|-----
        // ldr q0, [x1, #0]                       // ..*............................
        // ldr q1, [x2, #0]                       // ........*......................
        // ldr q8,  [x0]                          // ...............*...............
        // ldr q9,  [x0, #1*16]                   // ....*..........................
        // ldr q10, [x0, #2*16]                   // ...........*...................
        // ldr q11, [x0, #3*16]                   // *..............................
        // mul v24.8h, v9.8h, v0.h[0]             // ..........*....................
        // sqrdmulh v9.8h, v9.8h, v0.h[1]         // ..............*................
        // mls v24.8h, v9.8h, v1.h[0]             // ..................*............
        // sub     v9.8h,    v8.8h, v24.8h        // ........................*......
        // add     v8.8h,    v8.8h, v24.8h        // ......................*........
        // mul v24.8h, v11.8h, v0.h[0]            // ......*........................
        // sqrdmulh v11.8h, v11.8h, v0.h[1]       // .......*.......................
        // mls v24.8h, v11.8h, v1.h[0]            // .............*.................
        // sub     v11.8h,    v10.8h, v24.8h      // .................*.............
        // add     v10.8h,    v10.8h, v24.8h      // ....................*..........
        // str q8,  [x0], #4*16                   // .........................*.....
        // str q9,  [x0, #-3*16]                  // ...........................*...
        // str q10, [x0, #-2*16]                  // .......................*.......
        // str q11, [x0, #-1*16]                  // .....................*.........
