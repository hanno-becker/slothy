        ldr q10, [x1, #0]                        // *..................
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        ldr q11, [x0, #16]                       // ..*................
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        ldr q25, [x0, #48]                       // ....*..............
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        mul v16.8H, v11.8H, v10.H[0]             // .....*.............
// gap                                   // ...................
        sqrdmulh v11.8H, v11.8H, v10.H[1]        // ......*............
// gap                                   // ...................
        mul v9.8H, v25.8H, v10.H[0]              // ..........*........
// gap                                   // ...................
        sqrdmulh v10.8H, v25.8H, v10.H[1]        // ...........*.......
// gap                                   // ...................
        ldr q25, [x0]                            // .*.................
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        mls v16.8H, v11.8H, v1.H[0]              // .......*...........
// gap                                   // ...................
        mls v9.8H, v10.8H, v1.H[0]               // ............*......
// gap                                   // ...................
        ldr q10, [x0, #32]                       // ...*...............
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        sub v11.8H, v25.8H, v16.8H               // ........*..........
// gap                                   // ...................
        add v25.8H, v25.8H, v16.8H               // .........*.........
// gap                                   // ...................
        sub v16.8H, v10.8H, v9.8H                // .............*.....
// gap                                   // ...................
        str q11, [x0, #16]                       // ................*..
// gap                                   // ...................
        add v10.8H, v10.8H, v9.8H                // ..............*....
// gap                                   // ...................
        str q25, [x0], #4*16                     // ...............*...
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        str q10, [x0, #-32]                      // .................*.
// gap                                   // ...................
// gap                                   // ...................
// gap                                   // ...................
        str q16, [x0, #-16]                      // ..................*
// gap                                   // ...................

// original source code
// ldr q0, [x1, #0]                       // *..................
// ldr q8,  [x0]                          // .......*...........
// ldr q9,  [x0, #1*16]                   // .*.................
// ldr q10, [x0, #2*16]                   // ..........*........
// ldr q11, [x0, #3*16]                   // ..*................
// mul v24.8h, v9.8h, v0.h[0]             // ...*...............
// sqrdmulh v9.8h, v9.8h, v0.h[1]         // ....*..............
// mls v24.8h, v9.8h, v1.h[0]             // ........*..........
// sub     v9.8h,    v8.8h, v24.8h        // ...........*.......
// add     v8.8h,    v8.8h, v24.8h        // ............*......
// mul v24.8h, v11.8h, v0.h[0]            // .....*.............
// sqrdmulh v11.8h, v11.8h, v0.h[1]       // ......*............
// mls v24.8h, v11.8h, v1.h[0]            // .........*.........
// sub     v11.8h,    v10.8h, v24.8h      // .............*.....
// add     v10.8h,    v10.8h, v24.8h      // ...............*...
// str q8,  [x0], #4*16                   // ................*..
// str q9,  [x0, #-3*16]                  // ..............*....
// str q10, [x0, #-2*16]                  // .................*.
// str q11, [x0, #-1*16]                  // ..................*
