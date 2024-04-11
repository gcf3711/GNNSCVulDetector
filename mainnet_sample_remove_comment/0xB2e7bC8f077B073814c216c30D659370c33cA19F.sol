 

 

 
 
pragma solidity ^0.6.12;

contract PrimeFieldElement0 {
    uint256 internal constant K_MODULUS =
        0x800000000000011000000000000000000000000000000000000000000000001;
    uint256 internal constant K_MONTGOMERY_R =
        0x7fffffffffffdf0ffffffffffffffffffffffffffffffffffffffffffffffe1;
    uint256 internal constant K_MONTGOMERY_R_INV =
        0x40000000000001100000000000012100000000000000000000000000000000;
    uint256 internal constant GENERATOR_VAL = 3;
    uint256 internal constant ONE_VAL = 1;

    function fromMontgomery(uint256 val) internal pure returns (uint256 res) {
         
        assembly {
            res := mulmod(val, K_MONTGOMERY_R_INV, K_MODULUS)
        }
        return res;
    }

    function fromMontgomeryBytes(bytes32 bs) internal pure returns (uint256) {
         
         
        uint256 res = uint256(bs);
        return fromMontgomery(res);
    }

    function toMontgomeryInt(uint256 val) internal pure returns (uint256 res) {
         
        assembly {
            res := mulmod(val, K_MONTGOMERY_R, K_MODULUS)
        }
        return res;
    }

    function fmul(uint256 a, uint256 b) internal pure returns (uint256 res) {
         
        assembly {
            res := mulmod(a, b, K_MODULUS)
        }
        return res;
    }

    function fadd(uint256 a, uint256 b) internal pure returns (uint256 res) {
         
        assembly {
            res := addmod(a, b, K_MODULUS)
        }
        return res;
    }

    function fsub(uint256 a, uint256 b) internal pure returns (uint256 res) {
         
        assembly {
            res := addmod(a, sub(K_MODULUS, b), K_MODULUS)
        }
        return res;
    }

    function fpow(uint256 val, uint256 exp) internal view returns (uint256) {
        return expmod(val, exp, K_MODULUS);
    }

    function expmod(
        uint256 base,
        uint256 exponent,
        uint256 modulus
    ) private view returns (uint256 res) {
        assembly {
            let p := mload(0x40)
            mstore(p, 0x20)  
            mstore(add(p, 0x20), 0x20)  
            mstore(add(p, 0x40), 0x20)  
            mstore(add(p, 0x60), base)  
            mstore(add(p, 0x80), exponent)  
            mstore(add(p, 0xa0), modulus)  
             
            if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
                revert(0, 0)
            }
            res := mload(p)
        }
    }

    function inverse(uint256 val) internal view returns (uint256) {
        return expmod(val, K_MODULUS - 2, K_MODULUS);
    }
}
 

 
 
 
pragma solidity ^0.6.12;

contract MemoryMap {
     
    uint256 constant internal MAX_N_QUERIES = 48;
    uint256 constant internal FRI_QUEUE_SIZE = MAX_N_QUERIES;

    uint256 constant internal MAX_FRI_STEPS = 10;
    uint256 constant internal MAX_SUPPORTED_FRI_STEP_SIZE = 4;

    uint256 constant internal MM_EVAL_DOMAIN_SIZE =                          0x0;
    uint256 constant internal MM_BLOW_UP_FACTOR =                            0x1;
    uint256 constant internal MM_LOG_EVAL_DOMAIN_SIZE =                      0x2;
    uint256 constant internal MM_PROOF_OF_WORK_BITS =                        0x3;
    uint256 constant internal MM_EVAL_DOMAIN_GENERATOR =                     0x4;
    uint256 constant internal MM_PUBLIC_INPUT_PTR =                          0x5;
    uint256 constant internal MM_TRACE_COMMITMENT =                          0x6;  
    uint256 constant internal MM_OODS_COMMITMENT =                           0x8;
    uint256 constant internal MM_N_UNIQUE_QUERIES =                          0x9;
    uint256 constant internal MM_CHANNEL =                                   0xa;  
    uint256 constant internal MM_MERKLE_QUEUE =                              0xd;  
    uint256 constant internal MM_FRI_QUEUE =                                0x6d;  
    uint256 constant internal MM_FRI_QUERIES_DELIMITER =                    0xfd;
    uint256 constant internal MM_FRI_CTX =                                  0xfe;  
    uint256 constant internal MM_FRI_STEP_SIZES_PTR =                      0x126;
    uint256 constant internal MM_FRI_EVAL_POINTS =                         0x127;  
    uint256 constant internal MM_FRI_COMMITMENTS =                         0x131;  
    uint256 constant internal MM_FRI_LAST_LAYER_DEG_BOUND =                0x13b;
    uint256 constant internal MM_FRI_LAST_LAYER_PTR =                      0x13c;
    uint256 constant internal MM_CONSTRAINT_POLY_ARGS_START =              0x13d;
    uint256 constant internal MM_PERIODIC_COLUMN__PEDERSEN__POINTS__X =    0x13d;
    uint256 constant internal MM_PERIODIC_COLUMN__PEDERSEN__POINTS__Y =    0x13e;
    uint256 constant internal MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__X = 0x13f;
    uint256 constant internal MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__Y = 0x140;
    uint256 constant internal MM_TRACE_LENGTH =                            0x141;
    uint256 constant internal MM_OFFSET_SIZE =                             0x142;
    uint256 constant internal MM_HALF_OFFSET_SIZE =                        0x143;
    uint256 constant internal MM_INITIAL_AP =                              0x144;
    uint256 constant internal MM_INITIAL_PC =                              0x145;
    uint256 constant internal MM_FINAL_AP =                                0x146;
    uint256 constant internal MM_FINAL_PC =                                0x147;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__PERM__INTERACTION_ELM = 0x148;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__HASH_INTERACTION_ELM0 = 0x149;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__PERM__PUBLIC_MEMORY_PROD = 0x14a;
    uint256 constant internal MM_RC16__PERM__INTERACTION_ELM =             0x14b;
    uint256 constant internal MM_RC16__PERM__PUBLIC_MEMORY_PROD =          0x14c;
    uint256 constant internal MM_RC_MIN =                                  0x14d;
    uint256 constant internal MM_RC_MAX =                                  0x14e;
    uint256 constant internal MM_DILUTED_CHECK__PERMUTATION__INTERACTION_ELM = 0x14f;
    uint256 constant internal MM_DILUTED_CHECK__PERMUTATION__PUBLIC_MEMORY_PROD = 0x150;
    uint256 constant internal MM_DILUTED_CHECK__FIRST_ELM =                0x151;
    uint256 constant internal MM_DILUTED_CHECK__INTERACTION_Z =            0x152;
    uint256 constant internal MM_DILUTED_CHECK__INTERACTION_ALPHA =        0x153;
    uint256 constant internal MM_DILUTED_CHECK__FINAL_CUM_VAL =            0x154;
    uint256 constant internal MM_PEDERSEN__SHIFT_POINT_X =                 0x155;
    uint256 constant internal MM_PEDERSEN__SHIFT_POINT_Y =                 0x156;
    uint256 constant internal MM_INITIAL_PEDERSEN_ADDR =                   0x157;
    uint256 constant internal MM_INITIAL_RC_ADDR =                         0x158;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_ALPHA =                 0x159;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_SHIFT_POINT_X =         0x15a;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_SHIFT_POINT_Y =         0x15b;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_BETA =                  0x15c;
    uint256 constant internal MM_INITIAL_ECDSA_ADDR =                      0x15d;
    uint256 constant internal MM_INITIAL_BITWISE_ADDR =                    0x15e;
    uint256 constant internal MM_INITIAL_EC_OP_ADDR =                      0x15f;
    uint256 constant internal MM_EC_OP__CURVE_CONFIG_ALPHA =               0x160;
    uint256 constant internal MM_TRACE_GENERATOR =                         0x161;
    uint256 constant internal MM_OODS_POINT =                              0x162;
    uint256 constant internal MM_INTERACTION_ELEMENTS =                    0x163;  
    uint256 constant internal MM_COEFFICIENTS =                            0x169;  
    uint256 constant internal MM_OODS_VALUES =                             0x210;  
    uint256 constant internal MM_CONSTRAINT_POLY_ARGS_END =                0x2e4;
    uint256 constant internal MM_COMPOSITION_OODS_VALUES =                 0x2e4;  
    uint256 constant internal MM_OODS_EVAL_POINTS =                        0x2e6;  
    uint256 constant internal MM_OODS_COEFFICIENTS =                       0x316;  
    uint256 constant internal MM_TRACE_QUERY_RESPONSES =                   0x3ec;  
    uint256 constant internal MM_COMPOSITION_QUERY_RESPONSES =             0x5cc;  
    uint256 constant internal MM_LOG_N_STEPS =                             0x62c;
    uint256 constant internal MM_N_PUBLIC_MEM_ENTRIES =                    0x62d;
    uint256 constant internal MM_N_PUBLIC_MEM_PAGES =                      0x62e;
    uint256 constant internal MM_CONTEXT_SIZE =                            0x62f;
}

 
 
 
pragma solidity ^0.6.12;



contract StarkParameters is PrimeFieldElement0 {
    uint256 constant internal N_COEFFICIENTS = 167;
    uint256 constant internal N_INTERACTION_ELEMENTS = 6;
    uint256 constant internal MASK_SIZE = 212;
    uint256 constant internal N_ROWS_IN_MASK = 149;
    uint256 constant internal N_COLUMNS_IN_MASK = 10;
    uint256 constant internal N_COLUMNS_IN_TRACE0 = 9;
    uint256 constant internal N_COLUMNS_IN_TRACE1 = 1;
    uint256 constant internal CONSTRAINTS_DEGREE_BOUND = 2;
    uint256 constant internal N_OODS_VALUES = MASK_SIZE + CONSTRAINTS_DEGREE_BOUND;
    uint256 constant internal N_OODS_COEFFICIENTS = N_OODS_VALUES;

     
    uint256 constant internal PUBLIC_MEMORY_STEP = 8;
    uint256 constant internal DILUTED_SPACING = 4;
    uint256 constant internal DILUTED_N_BITS = 16;
    uint256 constant internal PEDERSEN_BUILTIN_RATIO = 32;
    uint256 constant internal PEDERSEN_BUILTIN_REPETITIONS = 1;
    uint256 constant internal RC_BUILTIN_RATIO = 16;
    uint256 constant internal RC_N_PARTS = 8;
    uint256 constant internal ECDSA_BUILTIN_RATIO = 2048;
    uint256 constant internal ECDSA_BUILTIN_REPETITIONS = 1;
    uint256 constant internal BITWISE__RATIO = 64;
    uint256 constant internal EC_OP_BUILTIN_RATIO = 1024;
    uint256 constant internal EC_OP_SCALAR_HEIGHT = 256;
    uint256 constant internal EC_OP_N_BITS = 252;
    uint256 constant internal LAYOUT_CODE = 42052439942391375477807157877090637012086313290658661;
    uint256 constant internal LOG_CPU_COMPONENT_HEIGHT = 4;
}
 
 
 
pragma solidity ^0.6.12;




contract CpuOods is MemoryMap, StarkParameters {
     
     
     
     
    uint256 constant internal BATCH_INVERSE_CHUNK = (2 + N_ROWS_IN_MASK);

     
    fallback() external {
         
         
        uint256[] memory ctx;
        assembly {
            let ctxSize := mul(add(calldataload(0), 1), 0x20)
            ctx := mload(0x40)
            mstore(0x40, add(ctx, ctxSize))
            calldatacopy(ctx, 0, ctxSize)
        }
        uint256 n_queries = ctx[MM_N_UNIQUE_QUERIES];
        uint256[] memory batchInverseArray = new uint256[](2 * n_queries * BATCH_INVERSE_CHUNK);
        oodsPrepareInverses(ctx, batchInverseArray);

        uint256 kMontgomeryRInv = PrimeFieldElement0.K_MONTGOMERY_R_INV;

        assembly {
            let PRIME := 0x800000000000011000000000000000000000000000000000000000000000001
            let context := ctx
            let friQueue :=   add(context, 0xdc0)
            let friQueueEnd := add(friQueue,  mul(n_queries, 0x60))
            let traceQueryResponses :=   add(context, 0x7da0)

            let compositionQueryResponses :=   add(context, 0xb9a0)

             
             
            let denominatorsPtr := add(batchInverseArray, 0x20)

            for {} lt(friQueue, friQueueEnd) {friQueue := add(friQueue, 0x60)} {
                 
                 
                 
                let res := 0

                 

                 
                {
                 
                let columnValue := mulmod(mload(traceQueryResponses), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x62e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4220)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6300)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4240)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x6320)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4260)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x60)),
                                    mload(add(context, 0x6340)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4280)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x80)),
                                    mload(add(context, 0x6360)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x42a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa0)),
                                    mload(add(context, 0x6380)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x42c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc0)),
                                    mload(add(context, 0x63a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x42e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe0)),
                                    mload(add(context, 0x63c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4300)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x100)),
                                    mload(add(context, 0x63e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4320)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x120)),
                                    mload(add(context, 0x6400)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4340)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x140)),
                                    mload(add(context, 0x6420)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4360)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x160)),
                                    mload(add(context, 0x6440)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4380)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x180)),
                                    mload(add(context, 0x6460)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x43a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1a0)),
                                    mload(add(context, 0x6480)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x43c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1c0)),
                                    mload(add(context, 0x64a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x43e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1e0)),
                                    mload(add(context, 0x64c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4400)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x20)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x64e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4420)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6500)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4440)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x980)),
                                    mload(add(context, 0x6520)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4460)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x9a0)),
                                    mload(add(context, 0x6540)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4480)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xac0)),
                                    mload(add(context, 0x6560)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x44a0)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x40)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6580)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x44c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x65a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x44e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x980)),
                                    mload(add(context, 0x65c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4500)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x9a0)),
                                    mload(add(context, 0x65e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4520)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x60)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6600)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4540)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6620)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4560)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x7e0)),
                                    mload(add(context, 0x6640)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4580)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x800)),
                                    mload(add(context, 0x6660)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x45a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x820)),
                                    mload(add(context, 0x6680)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x45c0)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x840)),
                                    mload(add(context, 0x66a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x45e0)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x940)),
                                    mload(add(context, 0x66c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4600)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x960)),
                                    mload(add(context, 0x66e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4620)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x9a0)),
                                    mload(add(context, 0x6700)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4640)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x80)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6720)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4660)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x980)),
                                    mload(add(context, 0x6740)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4680)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0xa0)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6760)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x46a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6780)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x46c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x67a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x46e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x60)),
                                    mload(add(context, 0x67c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4700)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x80)),
                                    mload(add(context, 0x67e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4720)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa0)),
                                    mload(add(context, 0x6800)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4740)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc0)),
                                    mload(add(context, 0x6820)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4760)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe0)),
                                    mload(add(context, 0x6840)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4780)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x100)),
                                    mload(add(context, 0x6860)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x47a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x120)),
                                    mload(add(context, 0x6880)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x47c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x180)),
                                    mload(add(context, 0x68a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x47e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1a0)),
                                    mload(add(context, 0x68c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4800)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x200)),
                                    mload(add(context, 0x68e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4820)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x4e0)),
                                    mload(add(context, 0x6900)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4840)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x500)),
                                    mload(add(context, 0x6920)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4860)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x6e0)),
                                    mload(add(context, 0x6940)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4880)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x700)),
                                    mload(add(context, 0x6960)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x48a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x860)),
                                    mload(add(context, 0x6980)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x48c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x880)),
                                    mload(add(context, 0x69a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x48e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x9e0)),
                                    mload(add(context, 0x69c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4900)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa00)),
                                    mload(add(context, 0x69e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4920)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa40)),
                                    mload(add(context, 0x6a00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4940)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa60)),
                                    mload(add(context, 0x6a20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4960)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa80)),
                                    mload(add(context, 0x6a40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4980)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xaa0)),
                                    mload(add(context, 0x6a60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x49a0)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xb00)),
                                    mload(add(context, 0x6a80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x49c0)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xb60)),
                                    mload(add(context, 0x6aa0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x49e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc20)),
                                    mload(add(context, 0x6ac0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4a00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc40)),
                                    mload(add(context, 0x6ae0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4a20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc80)),
                                    mload(add(context, 0x6b00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4a40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xca0)),
                                    mload(add(context, 0x6b20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4a60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xd20)),
                                    mload(add(context, 0x6b40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4a80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xd40)),
                                    mload(add(context, 0x6b60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4aa0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xd60)),
                                    mload(add(context, 0x6b80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ac0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xd80)),
                                    mload(add(context, 0x6ba0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ae0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xda0)),
                                    mload(add(context, 0x6bc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4b00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xdc0)),
                                    mload(add(context, 0x6be0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4b20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xde0)),
                                    mload(add(context, 0x6c00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4b40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe00)),
                                    mload(add(context, 0x6c20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4b60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe20)),
                                    mload(add(context, 0x6c40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4b80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe40)),
                                    mload(add(context, 0x6c60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ba0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe60)),
                                    mload(add(context, 0x6c80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4bc0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xf00)),
                                    mload(add(context, 0x6ca0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4be0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xf20)),
                                    mload(add(context, 0x6cc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4c00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xf40)),
                                    mload(add(context, 0x6ce0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4c20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xf60)),
                                    mload(add(context, 0x6d00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4c40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1120)),
                                    mload(add(context, 0x6d20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4c60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1140)),
                                    mload(add(context, 0x6d40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4c80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1160)),
                                    mload(add(context, 0x6d60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ca0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1280)),
                                    mload(add(context, 0x6d80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4cc0)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0xc0)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6da0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ce0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6dc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4d00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x6de0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4d20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x60)),
                                    mload(add(context, 0x6e00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4d40)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0xe0)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x6e20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4d60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x6e40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4d80)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x6e60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4da0)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x60)),
                                    mload(add(context, 0x6e80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4dc0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x80)),
                                    mload(add(context, 0x6ea0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4de0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa0)),
                                    mload(add(context, 0x6ec0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4e00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc0)),
                                    mload(add(context, 0x6ee0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4e20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe0)),
                                    mload(add(context, 0x6f00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4e40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x100)),
                                    mload(add(context, 0x6f20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4e60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x120)),
                                    mload(add(context, 0x6f40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4e80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x160)),
                                    mload(add(context, 0x6f60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ea0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x180)),
                                    mload(add(context, 0x6f80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ec0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1a0)),
                                    mload(add(context, 0x6fa0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4ee0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1e0)),
                                    mload(add(context, 0x6fc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4f00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x220)),
                                    mload(add(context, 0x6fe0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4f20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x260)),
                                    mload(add(context, 0x7000)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4f40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x2e0)),
                                    mload(add(context, 0x7020)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4f60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x320)),
                                    mload(add(context, 0x7040)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4f80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x3c0)),
                                    mload(add(context, 0x7060)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4fa0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x3e0)),
                                    mload(add(context, 0x7080)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4fc0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x480)),
                                    mload(add(context, 0x70a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x4fe0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x520)),
                                    mload(add(context, 0x70c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5000)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x540)),
                                    mload(add(context, 0x70e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5020)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x5e0)),
                                    mload(add(context, 0x7100)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5040)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x660)),
                                    mload(add(context, 0x7120)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5060)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x680)),
                                    mload(add(context, 0x7140)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5080)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x6c0)),
                                    mload(add(context, 0x7160)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x50a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x720)),
                                    mload(add(context, 0x7180)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x50c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x740)),
                                    mload(add(context, 0x71a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x50e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x760)),
                                    mload(add(context, 0x71c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5100)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x7a0)),
                                    mload(add(context, 0x71e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5120)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x7c0)),
                                    mload(add(context, 0x7200)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5140)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x800)),
                                    mload(add(context, 0x7220)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5160)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x8a0)),
                                    mload(add(context, 0x7240)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5180)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x8c0)),
                                    mload(add(context, 0x7260)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x51a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x8e0)),
                                    mload(add(context, 0x7280)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x51c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x900)),
                                    mload(add(context, 0x72a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x51e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x920)),
                                    mload(add(context, 0x72c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5200)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x9c0)),
                                    mload(add(context, 0x72e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5220)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa20)),
                                    mload(add(context, 0x7300)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5240)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xae0)),
                                    mload(add(context, 0x7320)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5260)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xb20)),
                                    mload(add(context, 0x7340)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5280)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xb40)),
                                    mload(add(context, 0x7360)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x52a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xb80)),
                                    mload(add(context, 0x7380)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x52c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xba0)),
                                    mload(add(context, 0x73a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x52e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xbc0)),
                                    mload(add(context, 0x73c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5300)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xbe0)),
                                    mload(add(context, 0x73e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5320)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc00)),
                                    mload(add(context, 0x7400)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5340)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc60)),
                                    mload(add(context, 0x7420)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5360)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xcc0)),
                                    mload(add(context, 0x7440)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5380)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xce0)),
                                    mload(add(context, 0x7460)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x53a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xd00)),
                                    mload(add(context, 0x7480)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x53c0)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x100)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x74a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x53e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x74c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5400)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x80)),
                                    mload(add(context, 0x74e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5420)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xc0)),
                                    mload(add(context, 0x7500)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5440)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x100)),
                                    mload(add(context, 0x7520)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5460)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x140)),
                                    mload(add(context, 0x7540)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5480)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x180)),
                                    mload(add(context, 0x7560)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x54a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x240)),
                                    mload(add(context, 0x7580)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x54c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x280)),
                                    mload(add(context, 0x75a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x54e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x2a0)),
                                    mload(add(context, 0x75c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5500)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x2c0)),
                                    mload(add(context, 0x75e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5520)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x300)),
                                    mload(add(context, 0x7600)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5540)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x340)),
                                    mload(add(context, 0x7620)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5560)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x360)),
                                    mload(add(context, 0x7640)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5580)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x380)),
                                    mload(add(context, 0x7660)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x55a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x3a0)),
                                    mload(add(context, 0x7680)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x55c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x3c0)),
                                    mload(add(context, 0x76a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x55e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x400)),
                                    mload(add(context, 0x76c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5600)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x420)),
                                    mload(add(context, 0x76e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5620)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x440)),
                                    mload(add(context, 0x7700)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5640)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x460)),
                                    mload(add(context, 0x7720)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5660)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x4a0)),
                                    mload(add(context, 0x7740)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5680)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x4c0)),
                                    mload(add(context, 0x7760)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x56a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x4e0)),
                                    mload(add(context, 0x7780)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x56c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x520)),
                                    mload(add(context, 0x77a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x56e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x560)),
                                    mload(add(context, 0x77c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5700)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x580)),
                                    mload(add(context, 0x77e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5720)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x5a0)),
                                    mload(add(context, 0x7800)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5740)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x5c0)),
                                    mload(add(context, 0x7820)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5760)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x600)),
                                    mload(add(context, 0x7840)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5780)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x620)),
                                    mload(add(context, 0x7860)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x57a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x640)),
                                    mload(add(context, 0x7880)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x57c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x660)),
                                    mload(add(context, 0x78a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x57e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x6a0)),
                                    mload(add(context, 0x78c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5800)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x6e0)),
                                    mload(add(context, 0x78e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5820)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x780)),
                                    mload(add(context, 0x7900)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5840)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x860)),
                                    mload(add(context, 0x7920)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5860)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe80)),
                                    mload(add(context, 0x7940)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5880)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xea0)),
                                    mload(add(context, 0x7960)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x58a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xec0)),
                                    mload(add(context, 0x7980)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x58c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xee0)),
                                    mload(add(context, 0x79a0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x58e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xf80)),
                                    mload(add(context, 0x79c0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5900)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xfa0)),
                                    mload(add(context, 0x79e0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5920)))),
                           PRIME))

                 
                res := addmod(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xfc0)),
                                    mload(add(context, 0x7a00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5940)))),
                           PRIME),
                    PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xfe0)),
                                    mload(add(context, 0x7a20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5960)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1000)),
                                    mload(add(context, 0x7a40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5980)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1020)),
                                    mload(add(context, 0x7a60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x59a0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1040)),
                                    mload(add(context, 0x7a80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x59c0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1060)),
                                    mload(add(context, 0x7aa0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x59e0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1080)),
                                    mload(add(context, 0x7ac0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5a00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x10a0)),
                                    mload(add(context, 0x7ae0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5a20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x10c0)),
                                    mload(add(context, 0x7b00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5a40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x10e0)),
                                    mload(add(context, 0x7b20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5a60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1100)),
                                    mload(add(context, 0x7b40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5a80)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1180)),
                                    mload(add(context, 0x7b60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5aa0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x11a0)),
                                    mload(add(context, 0x7b80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5ac0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x11c0)),
                                    mload(add(context, 0x7ba0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5ae0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x11e0)),
                                    mload(add(context, 0x7bc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5b00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1200)),
                                    mload(add(context, 0x7be0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5b20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1220)),
                                    mload(add(context, 0x7c00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5b40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1240)),
                                    mload(add(context, 0x7c20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5b60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1260)),
                                    mload(add(context, 0x7c40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5b80)))),
                           PRIME))
                }

                 
                {
                 
                let columnValue := mulmod(mload(add(traceQueryResponses, 0x120)), kMontgomeryRInv, PRIME)

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(denominatorsPtr),
                                    mload(add(context, 0x7c60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5ba0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x20)),
                                    mload(add(context, 0x7c80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5bc0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x40)),
                                    mload(add(context, 0x7ca0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5be0)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x60)),
                                    mload(add(context, 0x7cc0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5c00)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xa0)),
                                    mload(add(context, 0x7ce0)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5c20)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0xe0)),
                                    mload(add(context, 0x7d00)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5c40)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x160)),
                                    mload(add(context, 0x7d20)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5c60)))),
                           PRIME))

                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x1e0)),
                                    mload(add(context, 0x7d40)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5c80)))),
                           PRIME))
                }

                 
                traceQueryResponses := add(traceQueryResponses, 0x140)

                 

                {
                 
                let columnValue := mulmod(mload(compositionQueryResponses), kMontgomeryRInv, PRIME)
                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x12a0)),
                                    mload(add(context, 0x7d60)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5ca0)))),
                           PRIME))
                }

                {
                 
                let columnValue := mulmod(mload(add(compositionQueryResponses, 0x20)), kMontgomeryRInv, PRIME)
                 
                res := add(
                    res,
                    mulmod(mulmod(  mload(add(denominatorsPtr, 0x12a0)),
                                    mload(add(context, 0x7d80)),
                                  PRIME),
                           add(columnValue, sub(PRIME,   mload(add(context, 0x5cc0)))),
                           PRIME))
                }

                 
                compositionQueryResponses := add(compositionQueryResponses, 0x40)

                 
                 
                mstore(add(friQueue, 0x20), mod(res, PRIME))

                 
                mstore(add(friQueue, 0x40),   mload(add(denominatorsPtr,0x12c0)))

                 
                denominatorsPtr := add(denominatorsPtr, 0x12e0)
            }
            return(  add(context, 0xdc0), 0x1200)
        }
    }

     
    function oodsPrepareInverses(
        uint256[] memory context, uint256[] memory batchInverseArray)
        internal view {
        uint256 evalCosetOffset_ = PrimeFieldElement0.GENERATOR_VAL;
         
         
         
         
         
        uint256[183] memory expmodsAndPoints;
        assembly {
            function expmod(base, exponent, modulus) -> result {
              let p := mload(0x40)
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

            let traceGenerator :=   mload(add(context, 0x2c40))
            let PRIME := 0x800000000000011000000000000000000000000000000000000000000000001

             

             
            mstore(expmodsAndPoints,
                   mulmod(traceGenerator,  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x20),
                   mulmod(mload(expmodsAndPoints),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x40),
                   mulmod(mload(add(expmodsAndPoints, 0x20)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x60),
                   mulmod(mload(add(expmodsAndPoints, 0x40)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x80),
                   mulmod(mload(add(expmodsAndPoints, 0x60)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0xa0),
                   mulmod(mload(add(expmodsAndPoints, 0x80)),  
                          mload(expmodsAndPoints),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0xc0),
                   mulmod(mload(add(expmodsAndPoints, 0xa0)),  
                          mload(expmodsAndPoints),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0xe0),
                   mulmod(mload(add(expmodsAndPoints, 0xc0)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x100),
                   mulmod(mload(add(expmodsAndPoints, 0xe0)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x120),
                   mulmod(mload(add(expmodsAndPoints, 0x100)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x140),
                   mulmod(mload(add(expmodsAndPoints, 0x120)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x160),
                   mulmod(mload(add(expmodsAndPoints, 0x140)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x180),
                   mulmod(mload(add(expmodsAndPoints, 0x160)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x1a0),
                   mulmod(mload(add(expmodsAndPoints, 0x180)),  
                          mload(add(expmodsAndPoints, 0x180)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x1c0),
                   mulmod(mload(add(expmodsAndPoints, 0x1a0)),  
                          mload(add(expmodsAndPoints, 0x180)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x1e0),
                   mulmod(mload(add(expmodsAndPoints, 0x1c0)),  
                          mload(add(expmodsAndPoints, 0x40)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x200),
                   mulmod(mload(add(expmodsAndPoints, 0x1e0)),  
                          mload(add(expmodsAndPoints, 0x60)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x220),
                   mulmod(mload(add(expmodsAndPoints, 0x200)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x240),
                   mulmod(mload(add(expmodsAndPoints, 0x220)),  
                          mload(add(expmodsAndPoints, 0x20)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x260),
                   mulmod(mload(add(expmodsAndPoints, 0x240)),  
                          mload(expmodsAndPoints),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x280),
                   mulmod(mload(add(expmodsAndPoints, 0x260)),  
                          traceGenerator,  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x2a0),
                   mulmod(mload(add(expmodsAndPoints, 0x280)),  
                          mload(add(expmodsAndPoints, 0x240)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x2c0),
                   mulmod(mload(add(expmodsAndPoints, 0x2a0)),  
                          mulmod(mload(add(expmodsAndPoints, 0x1c0)),  
                                 mload(add(expmodsAndPoints, 0x20)),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x2e0),
                   mulmod(mload(add(expmodsAndPoints, 0x2c0)),  
                          mload(add(expmodsAndPoints, 0xa0)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x300),
                   mulmod(mload(add(expmodsAndPoints, 0x2e0)),  
                          mload(add(expmodsAndPoints, 0xa0)),  
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x320),
                   mulmod(mload(add(expmodsAndPoints, 0x300)),  
                          mulmod(mload(add(expmodsAndPoints, 0x180)),  
                                 mload(add(expmodsAndPoints, 0x60)),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x340),
                   mulmod(mload(add(expmodsAndPoints, 0x2c0)),  
                          mulmod(mload(add(expmodsAndPoints, 0x2c0)),  
                                 mload(expmodsAndPoints),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x360),
                   mulmod(mload(add(expmodsAndPoints, 0x340)),  
                          mulmod(mload(add(expmodsAndPoints, 0x1a0)),  
                                 mload(add(expmodsAndPoints, 0xc0)),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x380),
                   mulmod(mload(add(expmodsAndPoints, 0x360)),  
                          mulmod(mload(add(expmodsAndPoints, 0x360)),  
                                 mulmod(mload(add(expmodsAndPoints, 0x340)),  
                                        mulmod(mload(add(expmodsAndPoints, 0x280)),  
                                               mload(add(expmodsAndPoints, 0x80)),  
                                               PRIME),
                                        PRIME),
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x3a0),
                   mulmod(mload(add(expmodsAndPoints, 0x380)),  
                          mulmod(mload(add(expmodsAndPoints, 0x2a0)),  
                                 mload(add(expmodsAndPoints, 0x140)),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x3c0),
                   mulmod(mload(add(expmodsAndPoints, 0x380)),  
                          mulmod(mload(add(expmodsAndPoints, 0x360)),  
                                 mload(add(expmodsAndPoints, 0x260)),  
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x3e0),
                   mulmod(mload(add(expmodsAndPoints, 0x3c0)),  
                          mulmod(mload(add(expmodsAndPoints, 0x340)),  
                                 mulmod(mload(add(expmodsAndPoints, 0x180)),  
                                        mload(expmodsAndPoints),  
                                        PRIME),
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x400),
                   mulmod(mload(add(expmodsAndPoints, 0x3e0)),  
                          mulmod(mload(add(expmodsAndPoints, 0x3e0)),  
                                 mulmod(mload(add(expmodsAndPoints, 0x3e0)),  
                                        mulmod(mload(add(expmodsAndPoints, 0x3a0)),  
                                               mload(add(expmodsAndPoints, 0x2e0)),  
                                               PRIME),
                                        PRIME),
                                 PRIME),
                          PRIME))

             
            mstore(add(expmodsAndPoints, 0x420),
                   mulmod(mload(add(expmodsAndPoints, 0x400)),  
                          mulmod(mload(add(expmodsAndPoints, 0x340)),  
                                 mulmod(mload(add(expmodsAndPoints, 0x2a0)),  
                                        mload(add(expmodsAndPoints, 0x1a0)),  
                                        PRIME),
                                 PRIME),
                          PRIME))

            let oodsPoint :=   mload(add(context, 0x2c60))
            {
               
              let point := sub(PRIME, oodsPoint)
               
               

               

               
              mstore(add(expmodsAndPoints, 0x440), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x460), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x480), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x4a0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x4c0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x4e0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x500), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x520), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x540), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x560), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x580), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x5a0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x5c0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x5e0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x600), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x620), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x640), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x660), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x680), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x6a0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x6c0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x6e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x40)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x700), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x720), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x740), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x760), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x780), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x7a0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x7c0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x40)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x7e0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x800), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x820), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x840), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x860), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x880), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x8a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x8c0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x8e0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x900), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x920), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x940), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x960), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x980), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x9a0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x9c0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x9e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xa00), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xa20), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xa40), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0xa60), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0xa80), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xaa0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xac0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x20)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xae0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x120)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xb00), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xb20), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xb40), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xb60), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xb80), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xba0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xbc0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xbe0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xc00), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x160)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xc20), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xc40), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x20)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xc60), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xc80), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xca0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xcc0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xce0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xd00), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xd20), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xe0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xd40), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xd60), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xc0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xd80), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xda0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x20)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xdc0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xde0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xe00), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xe20), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xe40), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0xe60), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x240)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xe80), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x280)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xea0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0xec0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x260)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xee0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x200)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xf00), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0xf20), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xf40), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x20)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xf60), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x2e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xf80), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xfa0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xc0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xfc0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0xfe0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1000), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1020), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xa0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1040), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x2a0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1060), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x1080), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x220)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x10a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x60)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x10c0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x10e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xc0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1100), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1120), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1140), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x320)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1160), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x380)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1180), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x11a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x11c0), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x11e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1200), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x1220), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1240), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x1260), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1280), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x12a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3c0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x12c0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x280)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x12e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x300)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1300), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x280)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1320), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x1e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1340), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x1360), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3e0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1380), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x13a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x3a0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x13c0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x280)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x13e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x2c0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1400), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xa0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1420), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xc0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1440), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1460), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xa0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1480), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xa0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x14a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xa0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x14c0), point)

               
              point := mulmod(point,   mload(expmodsAndPoints), PRIME)
               
              mstore(add(expmodsAndPoints, 0x14e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1500), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0xc0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1520), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x1a0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1540), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x340)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1560), point)

               
              point := mulmod(point, traceGenerator, PRIME)
               
              mstore(add(expmodsAndPoints, 0x1580), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x420)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x15a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x400)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x15c0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x180)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x15e0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x1c0)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1600), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x140)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1620), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1640), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x100)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1660), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x140)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x1680), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x80)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x16a0), point)

               
              point := mulmod(point,   mload(add(expmodsAndPoints, 0x360)), PRIME)
               
              mstore(add(expmodsAndPoints, 0x16c0), point)
            }

            let evalPointsPtr :=   add(context, 0x5ce0)
            let evalPointsEndPtr := add(
                evalPointsPtr,
                mul(  mload(add(context, 0x140)), 0x20))

             
             
             
            let productsPtr := add(batchInverseArray, 0x20)
             
            let productsToValuesOffset := mul(
                  mload(batchInverseArray),
                  0x10)
            let valuesPtr := add(productsPtr, productsToValuesOffset)
            let partialProduct := 1
            let minusPointPow := sub(PRIME, mulmod(oodsPoint, oodsPoint, PRIME))
            for {} lt(evalPointsPtr, evalPointsEndPtr)
                     {evalPointsPtr := add(evalPointsPtr, 0x20)} {
                let evalPoint := mload(evalPointsPtr)

                 
                let shiftedEvalPoint := mulmod(evalPoint, evalCosetOffset_, PRIME)

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x440)))
                mstore(productsPtr, partialProduct)
                mstore(valuesPtr, denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x460)))
                mstore(add(productsPtr, 0x20), partialProduct)
                mstore(add(valuesPtr, 0x20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x480)))
                mstore(add(productsPtr, 0x40), partialProduct)
                mstore(add(valuesPtr, 0x40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x4a0)))
                mstore(add(productsPtr, 0x60), partialProduct)
                mstore(add(valuesPtr, 0x60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x4c0)))
                mstore(add(productsPtr, 0x80), partialProduct)
                mstore(add(valuesPtr, 0x80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x4e0)))
                mstore(add(productsPtr, 0xa0), partialProduct)
                mstore(add(valuesPtr, 0xa0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x500)))
                mstore(add(productsPtr, 0xc0), partialProduct)
                mstore(add(valuesPtr, 0xc0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x520)))
                mstore(add(productsPtr, 0xe0), partialProduct)
                mstore(add(valuesPtr, 0xe0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x540)))
                mstore(add(productsPtr, 0x100), partialProduct)
                mstore(add(valuesPtr, 0x100), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x560)))
                mstore(add(productsPtr, 0x120), partialProduct)
                mstore(add(valuesPtr, 0x120), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x580)))
                mstore(add(productsPtr, 0x140), partialProduct)
                mstore(add(valuesPtr, 0x140), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x5a0)))
                mstore(add(productsPtr, 0x160), partialProduct)
                mstore(add(valuesPtr, 0x160), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x5c0)))
                mstore(add(productsPtr, 0x180), partialProduct)
                mstore(add(valuesPtr, 0x180), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x5e0)))
                mstore(add(productsPtr, 0x1a0), partialProduct)
                mstore(add(valuesPtr, 0x1a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x600)))
                mstore(add(productsPtr, 0x1c0), partialProduct)
                mstore(add(valuesPtr, 0x1c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x620)))
                mstore(add(productsPtr, 0x1e0), partialProduct)
                mstore(add(valuesPtr, 0x1e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x640)))
                mstore(add(productsPtr, 0x200), partialProduct)
                mstore(add(valuesPtr, 0x200), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x660)))
                mstore(add(productsPtr, 0x220), partialProduct)
                mstore(add(valuesPtr, 0x220), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x680)))
                mstore(add(productsPtr, 0x240), partialProduct)
                mstore(add(valuesPtr, 0x240), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x6a0)))
                mstore(add(productsPtr, 0x260), partialProduct)
                mstore(add(valuesPtr, 0x260), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x6c0)))
                mstore(add(productsPtr, 0x280), partialProduct)
                mstore(add(valuesPtr, 0x280), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x6e0)))
                mstore(add(productsPtr, 0x2a0), partialProduct)
                mstore(add(valuesPtr, 0x2a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x700)))
                mstore(add(productsPtr, 0x2c0), partialProduct)
                mstore(add(valuesPtr, 0x2c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x720)))
                mstore(add(productsPtr, 0x2e0), partialProduct)
                mstore(add(valuesPtr, 0x2e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x740)))
                mstore(add(productsPtr, 0x300), partialProduct)
                mstore(add(valuesPtr, 0x300), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x760)))
                mstore(add(productsPtr, 0x320), partialProduct)
                mstore(add(valuesPtr, 0x320), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x780)))
                mstore(add(productsPtr, 0x340), partialProduct)
                mstore(add(valuesPtr, 0x340), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x7a0)))
                mstore(add(productsPtr, 0x360), partialProduct)
                mstore(add(valuesPtr, 0x360), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x7c0)))
                mstore(add(productsPtr, 0x380), partialProduct)
                mstore(add(valuesPtr, 0x380), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x7e0)))
                mstore(add(productsPtr, 0x3a0), partialProduct)
                mstore(add(valuesPtr, 0x3a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x800)))
                mstore(add(productsPtr, 0x3c0), partialProduct)
                mstore(add(valuesPtr, 0x3c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x820)))
                mstore(add(productsPtr, 0x3e0), partialProduct)
                mstore(add(valuesPtr, 0x3e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x840)))
                mstore(add(productsPtr, 0x400), partialProduct)
                mstore(add(valuesPtr, 0x400), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x860)))
                mstore(add(productsPtr, 0x420), partialProduct)
                mstore(add(valuesPtr, 0x420), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x880)))
                mstore(add(productsPtr, 0x440), partialProduct)
                mstore(add(valuesPtr, 0x440), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x8a0)))
                mstore(add(productsPtr, 0x460), partialProduct)
                mstore(add(valuesPtr, 0x460), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x8c0)))
                mstore(add(productsPtr, 0x480), partialProduct)
                mstore(add(valuesPtr, 0x480), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x8e0)))
                mstore(add(productsPtr, 0x4a0), partialProduct)
                mstore(add(valuesPtr, 0x4a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x900)))
                mstore(add(productsPtr, 0x4c0), partialProduct)
                mstore(add(valuesPtr, 0x4c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x920)))
                mstore(add(productsPtr, 0x4e0), partialProduct)
                mstore(add(valuesPtr, 0x4e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x940)))
                mstore(add(productsPtr, 0x500), partialProduct)
                mstore(add(valuesPtr, 0x500), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x960)))
                mstore(add(productsPtr, 0x520), partialProduct)
                mstore(add(valuesPtr, 0x520), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x980)))
                mstore(add(productsPtr, 0x540), partialProduct)
                mstore(add(valuesPtr, 0x540), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x9a0)))
                mstore(add(productsPtr, 0x560), partialProduct)
                mstore(add(valuesPtr, 0x560), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x9c0)))
                mstore(add(productsPtr, 0x580), partialProduct)
                mstore(add(valuesPtr, 0x580), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x9e0)))
                mstore(add(productsPtr, 0x5a0), partialProduct)
                mstore(add(valuesPtr, 0x5a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xa00)))
                mstore(add(productsPtr, 0x5c0), partialProduct)
                mstore(add(valuesPtr, 0x5c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xa20)))
                mstore(add(productsPtr, 0x5e0), partialProduct)
                mstore(add(valuesPtr, 0x5e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xa40)))
                mstore(add(productsPtr, 0x600), partialProduct)
                mstore(add(valuesPtr, 0x600), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xa60)))
                mstore(add(productsPtr, 0x620), partialProduct)
                mstore(add(valuesPtr, 0x620), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xa80)))
                mstore(add(productsPtr, 0x640), partialProduct)
                mstore(add(valuesPtr, 0x640), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xaa0)))
                mstore(add(productsPtr, 0x660), partialProduct)
                mstore(add(valuesPtr, 0x660), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xac0)))
                mstore(add(productsPtr, 0x680), partialProduct)
                mstore(add(valuesPtr, 0x680), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xae0)))
                mstore(add(productsPtr, 0x6a0), partialProduct)
                mstore(add(valuesPtr, 0x6a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xb00)))
                mstore(add(productsPtr, 0x6c0), partialProduct)
                mstore(add(valuesPtr, 0x6c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xb20)))
                mstore(add(productsPtr, 0x6e0), partialProduct)
                mstore(add(valuesPtr, 0x6e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xb40)))
                mstore(add(productsPtr, 0x700), partialProduct)
                mstore(add(valuesPtr, 0x700), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xb60)))
                mstore(add(productsPtr, 0x720), partialProduct)
                mstore(add(valuesPtr, 0x720), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xb80)))
                mstore(add(productsPtr, 0x740), partialProduct)
                mstore(add(valuesPtr, 0x740), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xba0)))
                mstore(add(productsPtr, 0x760), partialProduct)
                mstore(add(valuesPtr, 0x760), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xbc0)))
                mstore(add(productsPtr, 0x780), partialProduct)
                mstore(add(valuesPtr, 0x780), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xbe0)))
                mstore(add(productsPtr, 0x7a0), partialProduct)
                mstore(add(valuesPtr, 0x7a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xc00)))
                mstore(add(productsPtr, 0x7c0), partialProduct)
                mstore(add(valuesPtr, 0x7c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xc20)))
                mstore(add(productsPtr, 0x7e0), partialProduct)
                mstore(add(valuesPtr, 0x7e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xc40)))
                mstore(add(productsPtr, 0x800), partialProduct)
                mstore(add(valuesPtr, 0x800), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xc60)))
                mstore(add(productsPtr, 0x820), partialProduct)
                mstore(add(valuesPtr, 0x820), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xc80)))
                mstore(add(productsPtr, 0x840), partialProduct)
                mstore(add(valuesPtr, 0x840), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xca0)))
                mstore(add(productsPtr, 0x860), partialProduct)
                mstore(add(valuesPtr, 0x860), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xcc0)))
                mstore(add(productsPtr, 0x880), partialProduct)
                mstore(add(valuesPtr, 0x880), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xce0)))
                mstore(add(productsPtr, 0x8a0), partialProduct)
                mstore(add(valuesPtr, 0x8a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xd00)))
                mstore(add(productsPtr, 0x8c0), partialProduct)
                mstore(add(valuesPtr, 0x8c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xd20)))
                mstore(add(productsPtr, 0x8e0), partialProduct)
                mstore(add(valuesPtr, 0x8e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xd40)))
                mstore(add(productsPtr, 0x900), partialProduct)
                mstore(add(valuesPtr, 0x900), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xd60)))
                mstore(add(productsPtr, 0x920), partialProduct)
                mstore(add(valuesPtr, 0x920), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xd80)))
                mstore(add(productsPtr, 0x940), partialProduct)
                mstore(add(valuesPtr, 0x940), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xda0)))
                mstore(add(productsPtr, 0x960), partialProduct)
                mstore(add(valuesPtr, 0x960), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xdc0)))
                mstore(add(productsPtr, 0x980), partialProduct)
                mstore(add(valuesPtr, 0x980), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xde0)))
                mstore(add(productsPtr, 0x9a0), partialProduct)
                mstore(add(valuesPtr, 0x9a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xe00)))
                mstore(add(productsPtr, 0x9c0), partialProduct)
                mstore(add(valuesPtr, 0x9c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xe20)))
                mstore(add(productsPtr, 0x9e0), partialProduct)
                mstore(add(valuesPtr, 0x9e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xe40)))
                mstore(add(productsPtr, 0xa00), partialProduct)
                mstore(add(valuesPtr, 0xa00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xe60)))
                mstore(add(productsPtr, 0xa20), partialProduct)
                mstore(add(valuesPtr, 0xa20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xe80)))
                mstore(add(productsPtr, 0xa40), partialProduct)
                mstore(add(valuesPtr, 0xa40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xea0)))
                mstore(add(productsPtr, 0xa60), partialProduct)
                mstore(add(valuesPtr, 0xa60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xec0)))
                mstore(add(productsPtr, 0xa80), partialProduct)
                mstore(add(valuesPtr, 0xa80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xee0)))
                mstore(add(productsPtr, 0xaa0), partialProduct)
                mstore(add(valuesPtr, 0xaa0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xf00)))
                mstore(add(productsPtr, 0xac0), partialProduct)
                mstore(add(valuesPtr, 0xac0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xf20)))
                mstore(add(productsPtr, 0xae0), partialProduct)
                mstore(add(valuesPtr, 0xae0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xf40)))
                mstore(add(productsPtr, 0xb00), partialProduct)
                mstore(add(valuesPtr, 0xb00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xf60)))
                mstore(add(productsPtr, 0xb20), partialProduct)
                mstore(add(valuesPtr, 0xb20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xf80)))
                mstore(add(productsPtr, 0xb40), partialProduct)
                mstore(add(valuesPtr, 0xb40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xfa0)))
                mstore(add(productsPtr, 0xb60), partialProduct)
                mstore(add(valuesPtr, 0xb60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xfc0)))
                mstore(add(productsPtr, 0xb80), partialProduct)
                mstore(add(valuesPtr, 0xb80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0xfe0)))
                mstore(add(productsPtr, 0xba0), partialProduct)
                mstore(add(valuesPtr, 0xba0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1000)))
                mstore(add(productsPtr, 0xbc0), partialProduct)
                mstore(add(valuesPtr, 0xbc0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1020)))
                mstore(add(productsPtr, 0xbe0), partialProduct)
                mstore(add(valuesPtr, 0xbe0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1040)))
                mstore(add(productsPtr, 0xc00), partialProduct)
                mstore(add(valuesPtr, 0xc00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1060)))
                mstore(add(productsPtr, 0xc20), partialProduct)
                mstore(add(valuesPtr, 0xc20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1080)))
                mstore(add(productsPtr, 0xc40), partialProduct)
                mstore(add(valuesPtr, 0xc40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x10a0)))
                mstore(add(productsPtr, 0xc60), partialProduct)
                mstore(add(valuesPtr, 0xc60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x10c0)))
                mstore(add(productsPtr, 0xc80), partialProduct)
                mstore(add(valuesPtr, 0xc80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x10e0)))
                mstore(add(productsPtr, 0xca0), partialProduct)
                mstore(add(valuesPtr, 0xca0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1100)))
                mstore(add(productsPtr, 0xcc0), partialProduct)
                mstore(add(valuesPtr, 0xcc0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1120)))
                mstore(add(productsPtr, 0xce0), partialProduct)
                mstore(add(valuesPtr, 0xce0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1140)))
                mstore(add(productsPtr, 0xd00), partialProduct)
                mstore(add(valuesPtr, 0xd00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1160)))
                mstore(add(productsPtr, 0xd20), partialProduct)
                mstore(add(valuesPtr, 0xd20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1180)))
                mstore(add(productsPtr, 0xd40), partialProduct)
                mstore(add(valuesPtr, 0xd40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x11a0)))
                mstore(add(productsPtr, 0xd60), partialProduct)
                mstore(add(valuesPtr, 0xd60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x11c0)))
                mstore(add(productsPtr, 0xd80), partialProduct)
                mstore(add(valuesPtr, 0xd80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x11e0)))
                mstore(add(productsPtr, 0xda0), partialProduct)
                mstore(add(valuesPtr, 0xda0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1200)))
                mstore(add(productsPtr, 0xdc0), partialProduct)
                mstore(add(valuesPtr, 0xdc0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1220)))
                mstore(add(productsPtr, 0xde0), partialProduct)
                mstore(add(valuesPtr, 0xde0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1240)))
                mstore(add(productsPtr, 0xe00), partialProduct)
                mstore(add(valuesPtr, 0xe00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1260)))
                mstore(add(productsPtr, 0xe20), partialProduct)
                mstore(add(valuesPtr, 0xe20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1280)))
                mstore(add(productsPtr, 0xe40), partialProduct)
                mstore(add(valuesPtr, 0xe40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x12a0)))
                mstore(add(productsPtr, 0xe60), partialProduct)
                mstore(add(valuesPtr, 0xe60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x12c0)))
                mstore(add(productsPtr, 0xe80), partialProduct)
                mstore(add(valuesPtr, 0xe80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x12e0)))
                mstore(add(productsPtr, 0xea0), partialProduct)
                mstore(add(valuesPtr, 0xea0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1300)))
                mstore(add(productsPtr, 0xec0), partialProduct)
                mstore(add(valuesPtr, 0xec0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1320)))
                mstore(add(productsPtr, 0xee0), partialProduct)
                mstore(add(valuesPtr, 0xee0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1340)))
                mstore(add(productsPtr, 0xf00), partialProduct)
                mstore(add(valuesPtr, 0xf00), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1360)))
                mstore(add(productsPtr, 0xf20), partialProduct)
                mstore(add(valuesPtr, 0xf20), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1380)))
                mstore(add(productsPtr, 0xf40), partialProduct)
                mstore(add(valuesPtr, 0xf40), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x13a0)))
                mstore(add(productsPtr, 0xf60), partialProduct)
                mstore(add(valuesPtr, 0xf60), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x13c0)))
                mstore(add(productsPtr, 0xf80), partialProduct)
                mstore(add(valuesPtr, 0xf80), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x13e0)))
                mstore(add(productsPtr, 0xfa0), partialProduct)
                mstore(add(valuesPtr, 0xfa0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1400)))
                mstore(add(productsPtr, 0xfc0), partialProduct)
                mstore(add(valuesPtr, 0xfc0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1420)))
                mstore(add(productsPtr, 0xfe0), partialProduct)
                mstore(add(valuesPtr, 0xfe0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1440)))
                mstore(add(productsPtr, 0x1000), partialProduct)
                mstore(add(valuesPtr, 0x1000), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1460)))
                mstore(add(productsPtr, 0x1020), partialProduct)
                mstore(add(valuesPtr, 0x1020), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1480)))
                mstore(add(productsPtr, 0x1040), partialProduct)
                mstore(add(valuesPtr, 0x1040), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x14a0)))
                mstore(add(productsPtr, 0x1060), partialProduct)
                mstore(add(valuesPtr, 0x1060), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x14c0)))
                mstore(add(productsPtr, 0x1080), partialProduct)
                mstore(add(valuesPtr, 0x1080), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x14e0)))
                mstore(add(productsPtr, 0x10a0), partialProduct)
                mstore(add(valuesPtr, 0x10a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1500)))
                mstore(add(productsPtr, 0x10c0), partialProduct)
                mstore(add(valuesPtr, 0x10c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1520)))
                mstore(add(productsPtr, 0x10e0), partialProduct)
                mstore(add(valuesPtr, 0x10e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1540)))
                mstore(add(productsPtr, 0x1100), partialProduct)
                mstore(add(valuesPtr, 0x1100), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1560)))
                mstore(add(productsPtr, 0x1120), partialProduct)
                mstore(add(valuesPtr, 0x1120), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1580)))
                mstore(add(productsPtr, 0x1140), partialProduct)
                mstore(add(valuesPtr, 0x1140), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x15a0)))
                mstore(add(productsPtr, 0x1160), partialProduct)
                mstore(add(valuesPtr, 0x1160), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x15c0)))
                mstore(add(productsPtr, 0x1180), partialProduct)
                mstore(add(valuesPtr, 0x1180), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x15e0)))
                mstore(add(productsPtr, 0x11a0), partialProduct)
                mstore(add(valuesPtr, 0x11a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1600)))
                mstore(add(productsPtr, 0x11c0), partialProduct)
                mstore(add(valuesPtr, 0x11c0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1620)))
                mstore(add(productsPtr, 0x11e0), partialProduct)
                mstore(add(valuesPtr, 0x11e0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1640)))
                mstore(add(productsPtr, 0x1200), partialProduct)
                mstore(add(valuesPtr, 0x1200), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1660)))
                mstore(add(productsPtr, 0x1220), partialProduct)
                mstore(add(valuesPtr, 0x1220), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x1680)))
                mstore(add(productsPtr, 0x1240), partialProduct)
                mstore(add(valuesPtr, 0x1240), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x16a0)))
                mstore(add(productsPtr, 0x1260), partialProduct)
                mstore(add(valuesPtr, 0x1260), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, mload(add(expmodsAndPoints, 0x16c0)))
                mstore(add(productsPtr, 0x1280), partialProduct)
                mstore(add(valuesPtr, 0x1280), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                {
                 
                let denominator := add(shiftedEvalPoint, minusPointPow)
                mstore(add(productsPtr, 0x12a0), partialProduct)
                mstore(add(valuesPtr, 0x12a0), denominator)
                partialProduct := mulmod(partialProduct, denominator, PRIME)
                }

                 
                 
                mstore(add(productsPtr, 0x12c0), partialProduct)
                mstore(add(valuesPtr, 0x12c0), evalPoint)
                partialProduct := mulmod(partialProduct, evalPoint, PRIME)

                 
                productsPtr := add(productsPtr, 0x12e0)
                valuesPtr := add(valuesPtr, 0x12e0)
            }

            let firstPartialProductPtr := add(batchInverseArray, 0x20)
             
            let prodInv := expmod(partialProduct, sub(PRIME, 2), PRIME)

            if eq(prodInv, 0) {
                 
                 
                 
                 
                 

                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x4, 0x20)
                mstore(0x24, 0x1e)
                mstore(0x44, "Batch inverse product is zero.")
                revert(0, 0x62)
            }

             
             
             
            let currentPartialProductPtr := productsPtr
             
             
             
             
            let midPartialProductPtr := add(firstPartialProductPtr, 0xe0)
            for { } gt(currentPartialProductPtr, midPartialProductPtr) { } {
                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)

                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)
            }

             
            for { } gt(currentPartialProductPtr, firstPartialProductPtr) { } {
                currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                 
                mstore(currentPartialProductPtr,
                       mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                 
                prodInv := mulmod(prodInv,
                                   mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                   PRIME)
            }
        }
    }
}
