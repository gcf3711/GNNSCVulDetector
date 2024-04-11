 

 

 
 
 
pragma solidity ^0.6.12;

contract CpuConstraintPoly {
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

    fallback() external {
        uint256 res;
        assembly {
            let PRIME := 0x800000000000011000000000000000000000000000000000000000000000001
             
            calldatacopy(0x0, 0x0,   0x3ce0)
            let point :=   mload(0x460)
            function expmod(base, exponent, modulus) -> result {
              let p :=   0x4e20
              mstore(p, 0x20)                  
              mstore(add(p, 0x20), 0x20)       
              mstore(add(p, 0x40), 0x20)       
              mstore(add(p, 0x60), base)       
              mstore(add(p, 0x80), exponent)   
              mstore(add(p, 0xa0), modulus)    
               
              if iszero(staticcall(not(0), 0x05, p, 0xc0, p, 0x20)) {
                revert(0, 0)
              }
              result := mload(p)
            }
            {
               

               
              mstore(0x4280, expmod(point,   mload(0x80), PRIME))

               
              mstore(0x42a0, expmod(point, div(  mload(0x80), 16), PRIME))

               
              mstore(0x42c0, expmod(point, div(  mload(0x80), 2), PRIME))

               
              mstore(0x42e0, expmod(point, div(  mload(0x80), 256), PRIME))

               
              mstore(0x4300, expmod(point, div(  mload(0x80), 512), PRIME))

               
              mstore(0x4320, expmod(point, div(  mload(0x80), 128), PRIME))

               
              mstore(0x4340, expmod(point, div(  mload(0x80), 4096), PRIME))

               
              mstore(0x4360, expmod(point, div(  mload(0x80), 32), PRIME))

               
              mstore(0x4380, expmod(point, div(  mload(0x80), 8192), PRIME))

               
              mstore(0x43a0, expmod(point, div(  mload(0x80), 1024), PRIME))

               
              mstore(0x43c0, expmod(  mload(0x440), div(mul(15,   mload(0x80)), 16), PRIME))

               
              mstore(0x43e0, expmod(  mload(0x440), mul(16, sub(div(  mload(0x80), 16), 1)), PRIME))

               
              mstore(0x4400, expmod(  mload(0x440), mul(2, sub(div(  mload(0x80), 2), 1)), PRIME))

               
              mstore(0x4420, expmod(  mload(0x440), sub(  mload(0x80), 1), PRIME))

               
              mstore(0x4440, expmod(  mload(0x440), div(mul(255,   mload(0x80)), 256), PRIME))

               
              mstore(0x4460, expmod(  mload(0x440), div(mul(63,   mload(0x80)), 64), PRIME))

               
              mstore(0x4480, expmod(  mload(0x440), div(  mload(0x80), 2), PRIME))

               
              mstore(0x44a0, expmod(  mload(0x440), mul(128, sub(div(  mload(0x80), 128), 1)), PRIME))

               
              mstore(0x44c0, expmod(  mload(0x440), div(mul(251,   mload(0x80)), 256), PRIME))

               
              mstore(0x44e0, expmod(  mload(0x440), mul(8192, sub(div(  mload(0x80), 8192), 1)), PRIME))

               
              mstore(0x4500, expmod(  mload(0x440), div(mul(3,   mload(0x80)), 4), PRIME))

               
              mstore(0x4520, expmod(  mload(0x440), mul(4096, sub(div(  mload(0x80), 4096), 1)), PRIME))

               
              mstore(0x4540, expmod(  mload(0x440), div(  mload(0x80), 64), PRIME))

               
              mstore(0x4560, expmod(  mload(0x440), div(  mload(0x80), 32), PRIME))

               
              mstore(0x4580, expmod(  mload(0x440), div(mul(3,   mload(0x80)), 64), PRIME))

               
              mstore(0x45a0, expmod(  mload(0x440), div(  mload(0x80), 16), PRIME))

               
              mstore(0x45c0, expmod(  mload(0x440), div(mul(5,   mload(0x80)), 64), PRIME))

               
              mstore(0x45e0, expmod(  mload(0x440), div(mul(3,   mload(0x80)), 32), PRIME))

               
              mstore(0x4600, expmod(  mload(0x440), div(mul(7,   mload(0x80)), 64), PRIME))

               
              mstore(0x4620, expmod(  mload(0x440), div(  mload(0x80), 8), PRIME))

               
              mstore(0x4640, expmod(  mload(0x440), div(mul(9,   mload(0x80)), 64), PRIME))

               
              mstore(0x4660, expmod(  mload(0x440), div(mul(5,   mload(0x80)), 32), PRIME))

               
              mstore(0x4680, expmod(  mload(0x440), div(mul(11,   mload(0x80)), 64), PRIME))

               
              mstore(0x46a0, expmod(  mload(0x440), div(mul(3,   mload(0x80)), 16), PRIME))

               
              mstore(0x46c0, expmod(  mload(0x440), div(mul(13,   mload(0x80)), 64), PRIME))

               
              mstore(0x46e0, expmod(  mload(0x440), div(mul(7,   mload(0x80)), 32), PRIME))

               
              mstore(0x4700, expmod(  mload(0x440), div(mul(15,   mload(0x80)), 64), PRIME))

            }

            {
               

               
               
              mstore(0x49e0,
                     addmod(  mload(0x4280), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4a00,
                     addmod(
                         mload(0x42a0),
                       sub(PRIME,   mload(0x43c0)),
                       PRIME))

               
               
              mstore(0x4a20,
                     addmod(  mload(0x42a0), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4a40,
                     addmod(point, sub(PRIME, 1), PRIME))

               
               
              mstore(0x4a60,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x43e0)),
                       PRIME))

               
               
              mstore(0x4a80,
                     addmod(  mload(0x42c0), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4aa0,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x4400)),
                       PRIME))

               
               
              mstore(0x4ac0,
                     addmod(point, sub(PRIME,   mload(0x4420)), PRIME))

               
               
              mstore(0x4ae0,
                     addmod(  mload(0x42e0), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4b00,
                     addmod(
                         mload(0x42e0),
                       sub(PRIME,   mload(0x4460)),
                       PRIME))

               
               
              mstore(0x4b20,
                     addmod(
                         mload(0x42e0),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4b40,
                     addmod(  mload(0x4300), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4b60,
                     addmod(  mload(0x4320), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4b80,
                     addmod(  mload(0x4360), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4ba0,
                     addmod(
                         mload(0x4380),
                       sub(PRIME,   mload(0x44c0)),
                       PRIME))

               
               
              mstore(0x4bc0,
                     addmod(
                         mload(0x4380),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4be0,
                     addmod(
                         mload(0x4340),
                       sub(PRIME,   mload(0x44c0)),
                       PRIME))

               
               
              mstore(0x4c00,
                     addmod(
                         mload(0x4340),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4c20,
                     addmod(  mload(0x4380), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4c40,
                     addmod(  mload(0x4340), sub(PRIME, 1), PRIME))

               
               
              mstore(0x4c60,
                     addmod(  mload(0x43a0), sub(PRIME, 1), PRIME))

               
               
              {
                let denominator := mulmod(
                    mulmod(
                      mulmod(
                        addmod(  mload(0x4340), sub(PRIME, 1), PRIME),
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x4540)),
                          PRIME),
                        PRIME),
                      addmod(
                          mload(0x4340),
                        sub(PRIME,   mload(0x4560)),
                        PRIME),
                      PRIME),
                    addmod(
                        mload(0x4340),
                      sub(PRIME,   mload(0x4580)),
                      PRIME),
                    PRIME)
                denominator := mulmod(
                  denominator,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x45a0)),
                          PRIME),
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x45c0)),
                          PRIME),
                        PRIME),
                      addmod(
                          mload(0x4340),
                        sub(PRIME,   mload(0x45e0)),
                        PRIME),
                      PRIME),
                    addmod(
                        mload(0x4340),
                      sub(PRIME,   mload(0x4600)),
                      PRIME),
                    PRIME),
                  PRIME)
                denominator := mulmod(
                  denominator,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x4620)),
                          PRIME),
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x4640)),
                          PRIME),
                        PRIME),
                      addmod(
                          mload(0x4340),
                        sub(PRIME,   mload(0x4660)),
                        PRIME),
                      PRIME),
                    addmod(
                        mload(0x4340),
                      sub(PRIME,   mload(0x4680)),
                      PRIME),
                    PRIME),
                  PRIME)
                denominator := mulmod(
                  denominator,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x46a0)),
                          PRIME),
                        addmod(
                            mload(0x4340),
                          sub(PRIME,   mload(0x46c0)),
                          PRIME),
                        PRIME),
                      addmod(
                          mload(0x4340),
                        sub(PRIME,   mload(0x46e0)),
                        PRIME),
                      PRIME),
                    addmod(
                        mload(0x4340),
                      sub(PRIME,   mload(0x4700)),
                      PRIME),
                    PRIME),
                  PRIME)
                mstore(0x4c80, denominator)
              }

            }

            {
               

               
               
               
               
               
              let productsToValuesOffset := 0x2c0
              let prod := 1
              let partialProductEndPtr := 0x49e0
              for { let partialProductPtr := 0x4720 }
                  lt(partialProductPtr, partialProductEndPtr)
                  { partialProductPtr := add(partialProductPtr, 0x20) } {
                  mstore(partialProductPtr, prod)
                   
                  prod := mulmod(prod,
                                 mload(add(partialProductPtr, productsToValuesOffset)),
                                 PRIME)
              }

              let firstPartialProductPtr := 0x4720
               
              let prodInv := expmod(prod, sub(PRIME, 2), PRIME)

              if eq(prodInv, 0) {
                   
                   
                   
                   
                   

                  mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                  mstore(0x4, 0x20)
                  mstore(0x24, 0x1e)
                  mstore(0x44, "Batch inverse product is zero.")
                  revert(0, 0x62)
              }

               
               
               
              let currentPartialProductPtr := 0x49e0
              for { } gt(currentPartialProductPtr, firstPartialProductPtr) { } {
                  currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                   
                  mstore(currentPartialProductPtr,
                         mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                   
                  prodInv := mulmod(prodInv,
                                     mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                     PRIME)
              }
            }

            {
               

               
               
              mstore(0x4ca0,
                     addmod(
                         mload(0x42a0),
                       sub(PRIME,   mload(0x43c0)),
                       PRIME))

               
               
              mstore(0x4cc0,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x43e0)),
                       PRIME))

               
               
              mstore(0x4ce0,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x4400)),
                       PRIME))

               
               
              mstore(0x4d00,
                     addmod(point, sub(PRIME,   mload(0x4420)), PRIME))

               
               
              mstore(0x4d20,
                     addmod(
                         mload(0x42e0),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4d40,
                     addmod(
                         mload(0x4300),
                       sub(PRIME,   mload(0x4480)),
                       PRIME))

               
               
              mstore(0x4d60,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x44a0)),
                       PRIME))

               
               
              mstore(0x4d80,
                     addmod(
                         mload(0x4340),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4da0,
                     addmod(
                         mload(0x4380),
                       sub(PRIME,   mload(0x4440)),
                       PRIME))

               
               
              mstore(0x4dc0,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x44e0)),
                       PRIME))

               
               
              mstore(0x4de0,
                     addmod(
                         mload(0x4340),
                       sub(PRIME,   mload(0x4500)),
                       PRIME))

               
               
              mstore(0x4e00,
                     addmod(
                       point,
                       sub(PRIME,   mload(0x4520)),
                       PRIME))

            }

            {
               

              {
               
              let val := addmod(
                  mload(0x1de0),
                sub(
                  PRIME,
                  addmod(  mload(0x1e00),   mload(0x1e00), PRIME)),
                PRIME)
              mstore(0x3ce0, val)
              }


              {
               
              let val := addmod(
                  mload(0x1e20),
                sub(
                  PRIME,
                  addmod(  mload(0x1e40),   mload(0x1e40), PRIME)),
                PRIME)
              mstore(0x3d00, val)
              }


              {
               
              let val := addmod(
                  mload(0x1e60),
                sub(
                  PRIME,
                  addmod(  mload(0x1e80),   mload(0x1e80), PRIME)),
                PRIME)
              mstore(0x3d20, val)
              }


              {
               
              let val := addmod(
                  mload(0x1e40),
                sub(
                  PRIME,
                  addmod(  mload(0x1e60),   mload(0x1e60), PRIME)),
                PRIME)
              mstore(0x3d40, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                        mload(0x3d00),
                        mload(0x3d20),
                      PRIME),
                      mload(0x3d40),
                    PRIME)),
                PRIME)
              mstore(0x3d60, val)
              }


              {
               
              let val := addmod(
                  mload(0x1e80),
                sub(
                  PRIME,
                  addmod(  mload(0x1ea0),   mload(0x1ea0), PRIME)),
                PRIME)
              mstore(0x3d80, val)
              }


              {
               
              let val := addmod(
                  mload(0x1ea0),
                sub(
                  PRIME,
                  addmod(  mload(0x1ec0),   mload(0x1ec0), PRIME)),
                PRIME)
              mstore(0x3da0, val)
              }


              {
               
              let val := addmod(
                  mload(0x1f00),
                sub(
                  PRIME,
                  addmod(  mload(0x1f20),   mload(0x1f20), PRIME)),
                PRIME)
              mstore(0x3dc0, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                        mload(0x3d80),
                        mload(0x3da0),
                      PRIME),
                      mload(0x3dc0),
                    PRIME)),
                PRIME)
              mstore(0x3de0, val)
              }


              {
               
              let val := addmod(
                  mload(0x1ec0),
                sub(
                  PRIME,
                  addmod(  mload(0x1ee0),   mload(0x1ee0), PRIME)),
                PRIME)
              mstore(0x3e00, val)
              }


              {
               
              let val := addmod(
                  mload(0x1ee0),
                sub(
                  PRIME,
                  addmod(  mload(0x1f00),   mload(0x1f00), PRIME)),
                PRIME)
              mstore(0x3e20, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                        mload(0x3e00),
                        mload(0x3e20),
                      PRIME),
                      mload(0x3dc0),
                    PRIME)),
                PRIME)
              mstore(0x3e40, val)
              }


              {
               
              let val := addmod(
                  mload(0x1f60),
                sub(
                  PRIME,
                  addmod(  mload(0x1f80),   mload(0x1f80), PRIME)),
                PRIME)
              mstore(0x3e60, val)
              }


              {
               
              let val := addmod(
                  mload(0x1f80),
                sub(
                  PRIME,
                  addmod(  mload(0x1fa0),   mload(0x1fa0), PRIME)),
                PRIME)
              mstore(0x3e80, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                      mload(0x3e60),
                      mload(0x3e80),
                    PRIME)),
                PRIME)
              mstore(0x3ea0, val)
              }


              {
               
              let val := addmod(
                  mload(0x1e00),
                sub(
                  PRIME,
                  addmod(  mload(0x1e20),   mload(0x1e20), PRIME)),
                PRIME)
              mstore(0x3ec0, val)
              }


              {
               
              let val := addmod(
                addmod(
                    mload(0x2e20),
                    mload(0x3d00),
                  PRIME),
                1,
                PRIME)
              mstore(0x3ee0, val)
              }


              {
               
              let val := addmod(
                  mload(0x1f20),
                sub(
                  PRIME,
                  addmod(  mload(0x1f40),   mload(0x1f40), PRIME)),
                PRIME)
              mstore(0x3f00, val)
              }


              {
               
              let val := addmod(
                  mload(0x1f40),
                sub(
                  PRIME,
                  addmod(  mload(0x1f60),   mload(0x1f60), PRIME)),
                PRIME)
              mstore(0x3f20, val)
              }


              {
               
              let val := addmod(
                  mload(0x1fa0),
                sub(
                  PRIME,
                  addmod(  mload(0x1fc0),   mload(0x1fc0), PRIME)),
                PRIME)
              mstore(0x3f40, val)
              }


              {
               
              let val := addmod(  mload(0x3400), sub(PRIME,   mload(0x33c0)), PRIME)
              mstore(0x3f60, val)
              }


              {
               
              let val := addmod(  mload(0x35c0), sub(PRIME,   mload(0x3580)), PRIME)
              mstore(0x3f80, val)
              }


              {
               
              let val := addmod(
                  mload(0x2580),
                sub(
                  PRIME,
                  addmod(  mload(0x25a0),   mload(0x25a0), PRIME)),
                PRIME)
              mstore(0x3fa0, val)
              }


              {
               
              let val := addmod(
                1,
                sub(PRIME,   mload(0x3fa0)),
                PRIME)
              mstore(0x3fc0, val)
              }


              {
               
              let val := addmod(
                  mload(0x2800),
                sub(
                  PRIME,
                  addmod(  mload(0x2820),   mload(0x2820), PRIME)),
                PRIME)
              mstore(0x3fe0, val)
              }


              {
               
              let val := addmod(
                1,
                sub(PRIME,   mload(0x3fe0)),
                PRIME)
              mstore(0x4000, val)
              }


              {
               
              let val := addmod(
                  mload(0x2a80),
                sub(
                  PRIME,
                  addmod(  mload(0x2aa0),   mload(0x2aa0), PRIME)),
                PRIME)
              mstore(0x4020, val)
              }


              {
               
              let val := addmod(
                1,
                sub(PRIME,   mload(0x4020)),
                PRIME)
              mstore(0x4040, val)
              }


              {
               
              let val := addmod(
                  mload(0x2d00),
                sub(
                  PRIME,
                  addmod(  mload(0x2d20),   mload(0x2d20), PRIME)),
                PRIME)
              mstore(0x4060, val)
              }


              {
               
              let val := addmod(
                1,
                sub(PRIME,   mload(0x4060)),
                PRIME)
              mstore(0x4080, val)
              }


              {
               
              let val :=   mload(0x3460)
              mstore(0x40a0, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x40a0),
                    mload(0xa0),
                  PRIME),
                  mload(0x3480),
                PRIME)
              mstore(0x40c0, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x40c0),
                    mload(0xa0),
                  PRIME),
                  mload(0x34a0),
                PRIME)
              mstore(0x40e0, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x40e0),
                    mload(0xa0),
                  PRIME),
                  mload(0x34c0),
                PRIME)
              mstore(0x4100, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x4100),
                    mload(0xa0),
                  PRIME),
                  mload(0x34e0),
                PRIME)
              mstore(0x4120, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x4120),
                    mload(0xa0),
                  PRIME),
                  mload(0x3500),
                PRIME)
              mstore(0x4140, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x4140),
                    mload(0xa0),
                  PRIME),
                  mload(0x3520),
                PRIME)
              mstore(0x4160, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x4160),
                    mload(0xa0),
                  PRIME),
                  mload(0x3540),
                PRIME)
              mstore(0x4180, val)
              }


              {
               
              let val := mulmod(  mload(0x36a0),   mload(0x36a0), PRIME)
              mstore(0x41a0, val)
              }


              {
               
              let val := addmod(
                  mload(0x38e0),
                sub(
                  PRIME,
                  addmod(  mload(0x3940),   mload(0x3940), PRIME)),
                PRIME)
              mstore(0x41c0, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                    mload(0x41c0)),
                PRIME)
              mstore(0x41e0, val)
              }


              {
               
              let val := addmod(
                  mload(0x3640),
                sub(
                  PRIME,
                  addmod(  mload(0x3800),   mload(0x3800), PRIME)),
                PRIME)
              mstore(0x4200, val)
              }


              {
               
              let val := addmod(
                1,
                sub(
                  PRIME,
                    mload(0x4200)),
                PRIME)
              mstore(0x4220, val)
              }


              {
               
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                              mload(0x1fe0),
                            mulmod(  mload(0x2040), 2, PRIME),
                            PRIME),
                          mulmod(  mload(0x2060), 4, PRIME),
                          PRIME),
                        mulmod(  mload(0x2080), 8, PRIME),
                        PRIME),
                      mulmod(  mload(0x20a0), 18446744073709551616, PRIME),
                      PRIME),
                    mulmod(  mload(0x20c0), 36893488147419103232, PRIME),
                    PRIME),
                  mulmod(  mload(0x20e0), 73786976294838206464, PRIME),
                  PRIME),
                mulmod(  mload(0x2100), 147573952589676412928, PRIME),
                PRIME)
              mstore(0x4240, val)
              }


              {
               
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            mulmod(  mload(0x2120), 340282366920938463463374607431768211456, PRIME),
                            mulmod(  mload(0x2140), 680564733841876926926749214863536422912, PRIME),
                            PRIME),
                          mulmod(  mload(0x2160), 1361129467683753853853498429727072845824, PRIME),
                          PRIME),
                        mulmod(  mload(0x2180), 2722258935367507707706996859454145691648, PRIME),
                        PRIME),
                      mulmod(
                          mload(0x21a0),
                        6277101735386680763835789423207666416102355444464034512896,
                        PRIME),
                      PRIME),
                    mulmod(
                        mload(0x21c0),
                      12554203470773361527671578846415332832204710888928069025792,
                      PRIME),
                    PRIME),
                  mulmod(
                      mload(0x21e0),
                    25108406941546723055343157692830665664409421777856138051584,
                    PRIME),
                  PRIME),
                mulmod(
                    mload(0x2200),
                  50216813883093446110686315385661331328818843555712276103168,
                  PRIME),
                PRIME)
              mstore(0x4260, val)
              }


              {
               
              let val := addmod(
                mulmod(
                    mload(0x3ce0),
                    mload(0x3ce0),
                  PRIME),
                sub(PRIME,   mload(0x3ce0)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ca0), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x540), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x1de0)

               
               
               
               
               
              val := mulmod(val, mload(0x4740), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x560), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2e40),
                sub(
                  PRIME,
                  addmod(
                    mulmod(
                      addmod(
                        mulmod(
                          addmod(
                            mulmod(  mload(0x1de0),   mload(0xa0), PRIME),
                              mload(0x3420),
                            PRIME),
                            mload(0xa0),
                          PRIME),
                          mload(0x3440),
                        PRIME),
                        mload(0xa0),
                      PRIME),
                      mload(0x33a0),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x580), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3d60),
                    mload(0x3d60),
                  PRIME),
                sub(PRIME,   mload(0x3d60)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x5a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3de0),
                    mload(0x3de0),
                  PRIME),
                sub(PRIME,   mload(0x3de0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x5c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3e40),
                    mload(0x3e40),
                  PRIME),
                sub(PRIME,   mload(0x3e40)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x5e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3ea0),
                    mload(0x3ea0),
                  PRIME),
                sub(PRIME,   mload(0x3ea0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x600), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x2ee0),   mload(0xc0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                          mload(0x3ce0),
                          mload(0x36e0),
                        PRIME),
                      mulmod(
                        addmod(
                          1,
                          sub(PRIME,   mload(0x3ce0)),
                          PRIME),
                          mload(0x35e0),
                        PRIME),
                      PRIME),
                      mload(0x33a0),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x620), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x2ea0),   mload(0xc0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                          mload(0x3ec0),
                          mload(0x36e0),
                        PRIME),
                      mulmod(
                        addmod(
                          1,
                          sub(PRIME,   mload(0x3ec0)),
                          PRIME),
                          mload(0x35e0),
                        PRIME),
                      PRIME),
                      mload(0x3440),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x640), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x2f60),   mload(0xc0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          mulmod(
                              mload(0x3d00),
                              mload(0x2e20),
                            PRIME),
                          mulmod(
                              mload(0x3d20),
                              mload(0x35e0),
                            PRIME),
                          PRIME),
                        mulmod(
                            mload(0x3d40),
                            mload(0x36e0),
                          PRIME),
                        PRIME),
                      mulmod(
                          mload(0x3d60),
                          mload(0x2ec0),
                        PRIME),
                      PRIME),
                      mload(0x3420),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x660), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3660),
                sub(
                  PRIME,
                  mulmod(  mload(0x2ec0),   mload(0x2f80), PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x680), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(
                    1,
                    sub(PRIME,   mload(0x3dc0)),
                    PRIME),
                    mload(0x3760),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                          mload(0x3d80),
                        addmod(  mload(0x2ec0),   mload(0x2f80), PRIME),
                        PRIME),
                      mulmod(
                          mload(0x3da0),
                          mload(0x3660),
                        PRIME),
                      PRIME),
                    mulmod(
                        mload(0x3de0),
                        mload(0x2f80),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x6a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3620),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3dc0),
                      mload(0x2f00),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x6c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3720),
                sub(
                  PRIME,
                  mulmod(  mload(0x3620),   mload(0x3760), PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x6e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                      1,
                      sub(PRIME,   mload(0x3dc0)),
                      PRIME),
                      mload(0x2fa0),
                    PRIME),
                  mulmod(
                      mload(0x3620),
                    addmod(
                        mload(0x2fa0),
                      sub(
                        PRIME,
                        addmod(  mload(0x2e20),   mload(0x2f80), PRIME)),
                      PRIME),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                          mload(0x3e40),
                          mload(0x3ee0),
                        PRIME),
                      mulmod(
                          mload(0x3e00),
                          mload(0x3760),
                        PRIME),
                      PRIME),
                    mulmod(
                        mload(0x3e20),
                      addmod(  mload(0x2e20),   mload(0x3760), PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x700), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(
                    mload(0x3720),
                  sub(PRIME,   mload(0x3dc0)),
                  PRIME),
                addmod(
                    mload(0x2fa0),
                  sub(PRIME,   mload(0x3ee0)),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x720), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x37e0),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                          mload(0x35e0),
                        mulmod(
                            mload(0x3f00),
                            mload(0x3760),
                          PRIME),
                        PRIME),
                        mload(0x3f20),
                      PRIME),
                    mulmod(  mload(0x3e60), 2, PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x740), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3880),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                          mload(0x3ea0),
                          mload(0x36e0),
                        PRIME),
                      mulmod(
                          mload(0x3e80),
                          mload(0x2f00),
                        PRIME),
                      PRIME),
                    mulmod(
                        mload(0x3e60),
                      addmod(  mload(0x35e0), 2, PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4cc0), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x760), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e60),
                addmod(  mload(0x2f00), sub(PRIME,   mload(0x36e0)), PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x780), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e60),
                addmod(
                    mload(0x2ec0),
                  sub(
                    PRIME,
                    addmod(
                      addmod(
                          mload(0x2e20),
                          mload(0x3d00),
                        PRIME),
                      1,
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x7a0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e60),
                addmod(
                    mload(0x33a0),
                  sub(PRIME,   mload(0xc0)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x7c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e60),
                addmod(
                    mload(0x3440),
                  sub(PRIME, addmod(  mload(0xc0), 1, PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x7e0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e60),
                addmod(
                  addmod(
                    addmod(
                      addmod(
                          mload(0x3e60),
                          mload(0x3e60),
                        PRIME),
                      1,
                      PRIME),
                    1,
                    PRIME),
                  sub(
                    PRIME,
                    addmod(
                      addmod(
                          mload(0x3ce0),
                          mload(0x3ec0),
                        PRIME),
                      4,
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x800), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e80),
                addmod(
                  addmod(  mload(0x33a0), 2, PRIME),
                  sub(PRIME,   mload(0xc0)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x820), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e80),
                addmod(
                  addmod(  mload(0x3420), 1, PRIME),
                  sub(PRIME,   mload(0xc0)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x840), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3e80),
                addmod(
                  addmod(
                    addmod(
                      addmod(
                          mload(0x3e00),
                          mload(0x3ce0),
                        PRIME),
                        mload(0x3d40),
                      PRIME),
                      mload(0x3de0),
                    PRIME),
                  sub(PRIME, 4),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x860), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3f40),
                addmod(
                    mload(0x2f00),
                  sub(PRIME,   mload(0x3760)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x880), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x35e0), sub(PRIME,   mload(0xe0)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x8a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x36e0), sub(PRIME,   mload(0xe0)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x8c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x2e20), sub(PRIME,   mload(0x100)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x8e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x35e0), sub(PRIME,   mload(0x120)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x900), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x36e0), sub(PRIME,   mload(0xe0)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x920), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x2e20), sub(PRIME,   mload(0x140)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x940), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                  addmod(
                    mulmod(
                      addmod(
                          mload(0x160),
                        sub(
                          PRIME,
                          addmod(
                              mload(0x33c0),
                            mulmod(
                                mload(0x180),
                                mload(0x3560),
                              PRIME),
                            PRIME)),
                        PRIME),
                        mload(0x3c60),
                      PRIME),
                      mload(0x2e20),
                    PRIME),
                  mulmod(
                      mload(0x180),
                      mload(0x2e40),
                    PRIME),
                  PRIME),
                sub(PRIME,   mload(0x160)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x960), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(
                      mload(0x160),
                    sub(
                      PRIME,
                      addmod(
                          mload(0x3400),
                        mulmod(
                            mload(0x180),
                            mload(0x35a0),
                          PRIME),
                        PRIME)),
                    PRIME),
                    mload(0x3ca0),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x160),
                      sub(
                        PRIME,
                        addmod(
                            mload(0x2e60),
                          mulmod(
                              mload(0x180),
                              mload(0x2e80),
                            PRIME),
                          PRIME)),
                      PRIME),
                      mload(0x3c60),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ce0), PRIME)
               
               
              val := mulmod(val, mload(0x47c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x980), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3c60),
                sub(PRIME,   mload(0x1a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47e0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x9a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3f60),
                    mload(0x3f60),
                  PRIME),
                sub(PRIME,   mload(0x3f60)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ce0), PRIME)
               
               
              val := mulmod(val, mload(0x47c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x9c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(  mload(0x3f60), sub(PRIME, 1), PRIME),
                addmod(  mload(0x3560), sub(PRIME,   mload(0x35a0)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ce0), PRIME)
               
               
              val := mulmod(val, mload(0x47c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x9e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x33c0), sub(PRIME, 1), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xa00), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2e60)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xa20), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2e80)

               
               
               
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xa40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                        mload(0x1c0),
                      sub(PRIME,   mload(0x3580)),
                      PRIME),
                      mload(0x3c80),
                    PRIME),
                    mload(0x33a0),
                  PRIME),
                sub(PRIME,   mload(0x1c0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xa60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(
                      mload(0x1c0),
                    sub(PRIME,   mload(0x35c0)),
                    PRIME),
                    mload(0x3cc0),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x1c0),
                      sub(PRIME,   mload(0x33e0)),
                      PRIME),
                      mload(0x3c80),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ce0), PRIME)
               
               
              val := mulmod(val, mload(0x47c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xa80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3c80),
                sub(PRIME,   mload(0x1e0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47e0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xaa0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3f80),
                    mload(0x3f80),
                  PRIME),
                sub(PRIME,   mload(0x3f80)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4ce0), PRIME)
               
               
              val := mulmod(val, mload(0x47c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xac0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x3580), sub(PRIME,   mload(0x200)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xae0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x3580), sub(PRIME,   mload(0x220)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x47e0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xb00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                        mload(0x240),
                      sub(PRIME,   mload(0x23e0)),
                      PRIME),
                      mload(0x3c20),
                    PRIME),
                    mload(0x1fe0),
                  PRIME),
                sub(PRIME,   mload(0x240)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xb20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(
                      mload(0x240),
                    sub(PRIME,   mload(0x2400)),
                    PRIME),
                    mload(0x3c40),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x240),
                      sub(PRIME,   mload(0x2000)),
                      PRIME),
                      mload(0x3c20),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d00), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xb40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3c20),
                sub(PRIME,   mload(0x260)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4800), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xb60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x3be0), sub(PRIME, 1), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xb80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x23e0),
                sub(PRIME,   mload(0x280)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xba0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3c00),
                sub(
                  PRIME,
                  addmod(
                    mulmod(
                        mload(0x3be0),
                      addmod(
                        1,
                        mulmod(
                            mload(0x2a0),
                          addmod(  mload(0x2400), sub(PRIME,   mload(0x23e0)), PRIME),
                          PRIME),
                        PRIME),
                      PRIME),
                    mulmod(
                      mulmod(
                          mload(0x2c0),
                        addmod(  mload(0x2400), sub(PRIME,   mload(0x23e0)), PRIME),
                        PRIME),
                      addmod(  mload(0x2400), sub(PRIME,   mload(0x23e0)), PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d00), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xbc0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3be0),
                sub(PRIME,   mload(0x2e0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4800), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xbe0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x27e0),
                addmod(
                    mload(0x2580),
                  sub(
                    PRIME,
                    addmod(  mload(0x25a0),   mload(0x25a0), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xc00), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x27e0),
                addmod(
                    mload(0x25a0),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                        mload(0x25c0),
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xc20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x27e0),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2560),
                    addmod(
                        mload(0x25c0),
                      sub(
                        PRIME,
                        addmod(  mload(0x25e0),   mload(0x25e0), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xc40), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x2560),
                addmod(
                    mload(0x25e0),
                  sub(PRIME, mulmod(8,   mload(0x2600), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xc60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2560),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x2640),
                      sub(
                        PRIME,
                        addmod(  mload(0x2660),   mload(0x2660), PRIME)),
                      PRIME),
                    addmod(
                        mload(0x2600),
                      sub(
                        PRIME,
                        addmod(  mload(0x2620),   mload(0x2620), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xc80), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(
                    mload(0x2640),
                  sub(
                    PRIME,
                    addmod(  mload(0x2660),   mload(0x2660), PRIME)),
                  PRIME),
                addmod(
                    mload(0x2620),
                  sub(PRIME, mulmod(18014398509481984,   mload(0x2640), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xca0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3fa0),
                addmod(
                    mload(0x3fa0),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xcc0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2580)

               
               
               
               
               
              val := mulmod(val, mload(0x4840), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xce0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2580)

               
               
               
               
               
              val := mulmod(val, mload(0x4860), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xd00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3fa0),
                  addmod(
                      mload(0x24c0),
                    sub(PRIME,   mload(0x20)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2540),
                    addmod(
                        mload(0x2420),
                      sub(PRIME,   mload(0x0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xd20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x2540),   mload(0x2540), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3fa0),
                    addmod(
                      addmod(
                          mload(0x2420),
                          mload(0x0),
                        PRIME),
                        mload(0x2440),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xd40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3fa0),
                  addmod(  mload(0x24c0),   mload(0x24e0), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2540),
                    addmod(  mload(0x2420), sub(PRIME,   mload(0x2440)), PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xd60), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3fc0),
                addmod(  mload(0x2440), sub(PRIME,   mload(0x2420)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xd80), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3fc0),
                addmod(  mload(0x24e0), sub(PRIME,   mload(0x24c0)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xda0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2480),
                sub(PRIME,   mload(0x2460)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xdc0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2520),
                sub(PRIME,   mload(0x2500)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xde0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2420),
                sub(PRIME,   mload(0x300)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xe00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x24c0),
                sub(PRIME,   mload(0x320)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xe20), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x2ce0),
                addmod(
                    mload(0x2800),
                  sub(
                    PRIME,
                    addmod(  mload(0x2820),   mload(0x2820), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xe40), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x2ce0),
                addmod(
                    mload(0x2820),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                        mload(0x2840),
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xe60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2ce0),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2a60),
                    addmod(
                        mload(0x2840),
                      sub(
                        PRIME,
                        addmod(  mload(0x2860),   mload(0x2860), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xe80), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x2a60),
                addmod(
                    mload(0x2860),
                  sub(PRIME, mulmod(8,   mload(0x2880), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xea0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2a60),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x28c0),
                      sub(
                        PRIME,
                        addmod(  mload(0x28e0),   mload(0x28e0), PRIME)),
                      PRIME),
                    addmod(
                        mload(0x2880),
                      sub(
                        PRIME,
                        addmod(  mload(0x28a0),   mload(0x28a0), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xec0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(
                    mload(0x28c0),
                  sub(
                    PRIME,
                    addmod(  mload(0x28e0),   mload(0x28e0), PRIME)),
                  PRIME),
                addmod(
                    mload(0x28a0),
                  sub(PRIME, mulmod(18014398509481984,   mload(0x28c0), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xee0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3fe0),
                addmod(
                    mload(0x3fe0),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xf00), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2800)

               
               
               
               
               
              val := mulmod(val, mload(0x4840), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xf20), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2800)

               
               
               
               
               
              val := mulmod(val, mload(0x4860), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xf40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3fe0),
                  addmod(
                      mload(0x2740),
                    sub(PRIME,   mload(0x20)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x27c0),
                    addmod(
                        mload(0x26a0),
                      sub(PRIME,   mload(0x0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xf60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x27c0),   mload(0x27c0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3fe0),
                    addmod(
                      addmod(
                          mload(0x26a0),
                          mload(0x0),
                        PRIME),
                        mload(0x26c0),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xf80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3fe0),
                  addmod(  mload(0x2740),   mload(0x2760), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x27c0),
                    addmod(  mload(0x26a0), sub(PRIME,   mload(0x26c0)), PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xfa0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4000),
                addmod(  mload(0x26c0), sub(PRIME,   mload(0x26a0)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xfc0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4000),
                addmod(  mload(0x2760), sub(PRIME,   mload(0x2740)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0xfe0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2700),
                sub(PRIME,   mload(0x26e0)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1000), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x27a0),
                sub(PRIME,   mload(0x2780)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1020), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x26a0),
                sub(PRIME,   mload(0x300)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1040), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2740),
                sub(PRIME,   mload(0x320)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1060), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3b80),
                addmod(
                    mload(0x2a80),
                  sub(
                    PRIME,
                    addmod(  mload(0x2aa0),   mload(0x2aa0), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1080), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3b80),
                addmod(
                    mload(0x2aa0),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                        mload(0x2ac0),
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x10a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3b80),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3b40),
                    addmod(
                        mload(0x2ac0),
                      sub(
                        PRIME,
                        addmod(  mload(0x2ae0),   mload(0x2ae0), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x10c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3b40),
                addmod(
                    mload(0x2ae0),
                  sub(PRIME, mulmod(8,   mload(0x2b00), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x10e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3b40),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x2b40),
                      sub(
                        PRIME,
                        addmod(  mload(0x2b60),   mload(0x2b60), PRIME)),
                      PRIME),
                    addmod(
                        mload(0x2b00),
                      sub(
                        PRIME,
                        addmod(  mload(0x2b20),   mload(0x2b20), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1100), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(
                    mload(0x2b40),
                  sub(
                    PRIME,
                    addmod(  mload(0x2b60),   mload(0x2b60), PRIME)),
                  PRIME),
                addmod(
                    mload(0x2b20),
                  sub(PRIME, mulmod(18014398509481984,   mload(0x2b40), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1120), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4020),
                addmod(
                    mload(0x4020),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1140), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2a80)

               
               
               
               
               
              val := mulmod(val, mload(0x4840), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1160), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2a80)

               
               
               
               
               
              val := mulmod(val, mload(0x4860), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1180), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4020),
                  addmod(
                      mload(0x29c0),
                    sub(PRIME,   mload(0x20)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2a40),
                    addmod(
                        mload(0x2920),
                      sub(PRIME,   mload(0x0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x11a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x2a40),   mload(0x2a40), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x4020),
                    addmod(
                      addmod(
                          mload(0x2920),
                          mload(0x0),
                        PRIME),
                        mload(0x2940),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x11c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4020),
                  addmod(  mload(0x29c0),   mload(0x29e0), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2a40),
                    addmod(  mload(0x2920), sub(PRIME,   mload(0x2940)), PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x11e0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4040),
                addmod(  mload(0x2940), sub(PRIME,   mload(0x2920)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1200), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4040),
                addmod(  mload(0x29e0), sub(PRIME,   mload(0x29c0)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1220), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2980),
                sub(PRIME,   mload(0x2960)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1240), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2a20),
                sub(PRIME,   mload(0x2a00)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1260), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2920),
                sub(PRIME,   mload(0x300)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1280), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x29c0),
                sub(PRIME,   mload(0x320)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x12a0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3ba0),
                addmod(
                    mload(0x2d00),
                  sub(
                    PRIME,
                    addmod(  mload(0x2d20),   mload(0x2d20), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x12c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3ba0),
                addmod(
                    mload(0x2d20),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                        mload(0x2d40),
                      PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x12e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3ba0),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3b60),
                    addmod(
                        mload(0x2d40),
                      sub(
                        PRIME,
                        addmod(  mload(0x2d60),   mload(0x2d60), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1300), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x3b60),
                addmod(
                    mload(0x2d60),
                  sub(PRIME, mulmod(8,   mload(0x2d80), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1320), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3b60),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                        mload(0x2dc0),
                      sub(
                        PRIME,
                        addmod(  mload(0x2de0),   mload(0x2de0), PRIME)),
                      PRIME),
                    addmod(
                        mload(0x2d80),
                      sub(
                        PRIME,
                        addmod(  mload(0x2da0),   mload(0x2da0), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1340), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                addmod(
                    mload(0x2dc0),
                  sub(
                    PRIME,
                    addmod(  mload(0x2de0),   mload(0x2de0), PRIME)),
                  PRIME),
                addmod(
                    mload(0x2da0),
                  sub(PRIME, mulmod(18014398509481984,   mload(0x2dc0), PRIME)),
                  PRIME),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1360), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4060),
                addmod(
                    mload(0x4060),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1380), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2d00)

               
               
               
               
               
              val := mulmod(val, mload(0x4840), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x13a0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x2d00)

               
               
               
               
               
              val := mulmod(val, mload(0x4860), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x13c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4060),
                  addmod(
                      mload(0x2c40),
                    sub(PRIME,   mload(0x20)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2cc0),
                    addmod(
                        mload(0x2ba0),
                      sub(PRIME,   mload(0x0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x13e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x2cc0),   mload(0x2cc0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x4060),
                    addmod(
                      addmod(
                          mload(0x2ba0),
                          mload(0x0),
                        PRIME),
                        mload(0x2bc0),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1400), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4060),
                  addmod(  mload(0x2c40),   mload(0x2c60), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x2cc0),
                    addmod(  mload(0x2ba0), sub(PRIME,   mload(0x2bc0)), PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1420), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4080),
                addmod(  mload(0x2bc0), sub(PRIME,   mload(0x2ba0)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1440), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4080),
                addmod(  mload(0x2c60), sub(PRIME,   mload(0x2c40)), PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d20), PRIME)
               
               
              val := mulmod(val, mload(0x4720), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1460), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2c00),
                sub(PRIME,   mload(0x2be0)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1480), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2ca0),
                sub(PRIME,   mload(0x2c80)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d40), PRIME)
               
               
              val := mulmod(val, mload(0x4820), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x14a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2ba0),
                sub(PRIME,   mload(0x300)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x14c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2c40),
                sub(PRIME,   mload(0x320)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x14e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(  mload(0x2f40), sub(PRIME,   mload(0x2580)), PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1500), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x30e0),
                sub(PRIME,   mload(0x2800)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1520), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3160),
                sub(PRIME,   mload(0x2a80)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1540), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x31c0),
                sub(PRIME,   mload(0x2d00)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1560), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x30c0),
                sub(PRIME, addmod(  mload(0x3000), 1, PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d60), PRIME)
               
               
              val := mulmod(val, mload(0x48a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1580), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2f20),
                sub(PRIME,   mload(0x340)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x15a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3060),
                sub(PRIME,   mload(0x2680)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x15c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3120),
                sub(PRIME,   mload(0x2900)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x15e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x31a0),
                sub(PRIME,   mload(0x2b80)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1600), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3200),
                sub(PRIME,   mload(0x2e00)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1620), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3040),
                sub(PRIME, addmod(  mload(0x2f20), 1, PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x48a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1640), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3020),
                sub(PRIME,   mload(0x24a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1660), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3100),
                sub(PRIME,   mload(0x2720)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1680), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3180),
                sub(PRIME,   mload(0x29a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x16a0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x31e0),
                sub(PRIME,   mload(0x2c20)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4880), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x16c0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3000),
                sub(PRIME, addmod(  mload(0x3040), 1, PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x48a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x16e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x4180),
                sub(PRIME,   mload(0x30a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x48a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1700), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3140),
                sub(PRIME, addmod(  mload(0x3080), 1, PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d60), PRIME)
               
               
              val := mulmod(val, mload(0x48a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1720), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3080),
                sub(PRIME,   mload(0x360)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1740), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                        mload(0x41a0),
                        mload(0x41a0),
                      PRIME),
                      mload(0x41a0),
                    PRIME),
                    mload(0x380),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(  mload(0x37a0),   mload(0x37a0), PRIME),
                      mload(0x3600),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1760), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x3600),   mload(0x3600), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(  mload(0x36a0),   mload(0x36a0), PRIME),
                      mload(0x3840),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1780), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x37a0),   mload(0x38c0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3600),
                    addmod(
                        mload(0x36a0),
                      sub(PRIME,   mload(0x3840)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x17a0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x41c0),
                addmod(
                    mload(0x41c0),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x17c0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x38e0)

               
               
               
               
               
              val := mulmod(val, mload(0x48e0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x17e0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x38e0)

               
               
               
               
               
              val := mulmod(val, mload(0x4900), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1800), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x41c0),
                  addmod(
                      mload(0x3860),
                    sub(PRIME,   mload(0x60)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x37c0),
                    addmod(
                        mload(0x36c0),
                      sub(PRIME,   mload(0x40)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1820), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x37c0),   mload(0x37c0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x41c0),
                    addmod(
                      addmod(
                          mload(0x36c0),
                          mload(0x40),
                        PRIME),
                        mload(0x3900),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1840), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x41c0),
                  addmod(  mload(0x3860),   mload(0x3920), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x37c0),
                    addmod(
                        mload(0x36c0),
                      sub(PRIME,   mload(0x3900)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1860), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3b20),
                  addmod(
                      mload(0x36c0),
                    sub(PRIME,   mload(0x40)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1880), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x41e0),
                addmod(
                    mload(0x3900),
                  sub(PRIME,   mload(0x36c0)),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x18a0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x41e0),
                addmod(
                    mload(0x3920),
                  sub(PRIME,   mload(0x3860)),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4da0), PRIME)
               
               
              val := mulmod(val, mload(0x48c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x18c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4200),
                addmod(
                    mload(0x4200),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x18e0), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x3640)

               
               
               
               
               
              val := mulmod(val, mload(0x4920), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1900), PRIME),
                            PRIME)
              }

              {
               
              let val :=   mload(0x3640)

               
               
               
               
               
              val := mulmod(val, mload(0x4940), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1920), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4200),
                  addmod(
                      mload(0x3680),
                    sub(PRIME,   mload(0x37a0)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3780),
                    addmod(  mload(0x3700), sub(PRIME,   mload(0x36a0)), PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1940), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x3780),   mload(0x3780), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x4200),
                    addmod(
                      addmod(  mload(0x3700),   mload(0x36a0), PRIME),
                        mload(0x38a0),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1960), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x4200),
                  addmod(  mload(0x3680),   mload(0x3820), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3780),
                    addmod(
                        mload(0x3700),
                      sub(PRIME,   mload(0x38a0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1980), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3740),
                  addmod(  mload(0x3700), sub(PRIME,   mload(0x36a0)), PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x19a0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4220),
                addmod(
                    mload(0x38a0),
                  sub(PRIME,   mload(0x3700)),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x19c0), PRIME),
                            PRIME)
              }

              {
               
              let val := mulmod(
                  mload(0x4220),
                addmod(
                    mload(0x3820),
                  sub(PRIME,   mload(0x3680)),
                  PRIME),
                PRIME)

               
               
              val := mulmod(val, mload(0x4d80), PRIME)
               
               
              val := mulmod(val, mload(0x4760), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x19e0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x36c0),
                sub(PRIME,   mload(0x3a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1a00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3860),
                  mload(0x3c0),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1a20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3700),
                sub(PRIME,   mload(0x3a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1a40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3680),
                sub(PRIME,   mload(0x3c0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1a60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3aa0),
                sub(
                  PRIME,
                  addmod(
                      mload(0x3980),
                    mulmod(
                        mload(0x3a60),
                      addmod(
                          mload(0x3a40),
                        sub(PRIME,   mload(0x39a0)),
                        PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1a80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x3a60),   mload(0x3a60), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(  mload(0x3a40),   mload(0x39a0), PRIME),
                      mload(0x3a00),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1aa0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x3aa0),   mload(0x3a20), PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x3a60),
                    addmod(
                        mload(0x3a40),
                      sub(PRIME,   mload(0x3a00)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1ac0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3bc0),
                  addmod(
                      mload(0x3a40),
                    sub(PRIME,   mload(0x39a0)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1ae0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                    mload(0x3a80),
                    mload(0x3c0),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                      mload(0x39e0),
                    addmod(
                        mload(0x3ac0),
                      sub(PRIME,   mload(0x3a0)),
                      PRIME),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1b00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x39e0),   mload(0x39e0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                        mload(0x3ac0),
                        mload(0x3a0),
                      PRIME),
                      mload(0x3640),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1b20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                    mload(0x3b00),
                  addmod(
                      mload(0x3ac0),
                    sub(PRIME,   mload(0x3a0)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1b40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x38e0),   mload(0x39c0), PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1b60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x3640),   mload(0x3960), PRIME),
                sub(PRIME, 1),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1b80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3ae0),
                sub(
                  PRIME,
                  mulmod(  mload(0x36a0),   mload(0x36a0), PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1ba0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(  mload(0x37a0),   mload(0x37a0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(  mload(0x36a0),   mload(0x3ae0), PRIME),
                      mulmod(  mload(0x380),   mload(0x36a0), PRIME),
                      PRIME),
                      mload(0x3e0),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1bc0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2fc0),
                sub(PRIME,   mload(0x400)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1be0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3320),
                sub(PRIME, addmod(  mload(0x2fc0), 1, PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1c00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3380),
                sub(PRIME, addmod(  mload(0x3320), 1, PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4dc0), PRIME)
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1c20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3340),
                sub(PRIME,   mload(0x38e0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1c40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x2fe0),
                sub(PRIME,   mload(0x36a0)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4960), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1c60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3220),
                sub(PRIME,   mload(0x420)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4780), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1c80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3260),
                sub(PRIME, addmod(  mload(0x3220), 1, PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4de0), PRIME)
               
               
              val := mulmod(val, mload(0x49a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1ca0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3280),
                sub(PRIME, addmod(  mload(0x32e0), 1, PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1cc0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x3360),
                sub(PRIME, addmod(  mload(0x3280), 1, PRIME)),
                PRIME)

               
               
              val := mulmod(val, mload(0x4e00), PRIME)
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1ce0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(
                    mload(0x4240),
                    mload(0x4260),
                  PRIME),
                sub(PRIME,   mload(0x3240)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x49a0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1d00), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                  mload(0x32a0),
                sub(
                  PRIME,
                  addmod(  mload(0x32c0),   mload(0x3300), PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1d20), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                addmod(  mload(0x1fe0),   mload(0x2220), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(  mload(0x2320),   mload(0x2260), PRIME),
                      mload(0x2260),
                    PRIME)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x49c0), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1d40), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(  mload(0x22a0),   mload(0x2360), PRIME),
                  16,
                  PRIME),
                sub(PRIME,   mload(0x2020)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1d60), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(  mload(0x22c0),   mload(0x2380), PRIME),
                  16,
                  PRIME),
                sub(PRIME,   mload(0x2280)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1d80), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(  mload(0x22e0),   mload(0x23a0), PRIME),
                  16,
                  PRIME),
                sub(PRIME,   mload(0x2240)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1da0), PRIME),
                            PRIME)
              }

              {
               
              let val := addmod(
                mulmod(
                  addmod(  mload(0x2300),   mload(0x23c0), PRIME),
                  256,
                  PRIME),
                sub(PRIME,   mload(0x2340)),
                PRIME)

               
               
               
               
               
              val := mulmod(val, mload(0x4980), PRIME)

               
              res := addmod(res,
                            mulmod(val,   mload(0x1dc0), PRIME),
                            PRIME)
              }

            mstore(0, res)
            return(0, 0x20)
            }
        }
    }
}
 