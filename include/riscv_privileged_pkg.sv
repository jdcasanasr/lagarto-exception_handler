package riscv_privileged_pkg;

    // Implementation-Defined Parameters.
    localparam MXLEN            = 64;
    localparam BOOT_ADDRESS     = 63'h100;

    typedef enum logic [1:0]
    {
        XLEN_32     = 2'd1,
        XLEN_64     = 2'd2,
        XLEN_128    = 2'd3
    } mxl_t;

    typedef enum logic [25:0]
    {
        A  = 26'h1,
        B  = 26'h2,
        C  = 26'h4,
        D  = 26'h8,
        E  = 26'h10,
        F  = 26'h20,
        G  = 26'h40,          // Reserved.
        H  = 26'h80,
        I  = 26'h100,         // RV32I/64I/128I Base ISA.
        J  = 26'h200,         // Reserved.
        K  = 26'h400,         // Reserved.
        L  = 26'h800,         // Reserved.
        M  = 26'h1000,
        N  = 26'h2000,
        O  = 26'h4000,        // Reserved.
        P  = 26'h8000,
        Q  = 26'h10000,
        R  = 26'h20000,       // Reserved.
        S  = 26'h40000,
        T  = 26'h80000,       // Reserved.
        U  = 26'h100000,
        V  = 26'h200000,
        W  = 26'h400000,      // Reserved.
        X  = 26'h800000,
        Y  = 26'h1000000,     // Reserved.
        Z  = 26'h2000000      // Reserved.
    } extensions_t;


    // Supported CSR's.
    // M-Mode Registers.
    // Machine Trap Setup.
    typedef struct packed
    {
        logic           sd;
        logic [24:0]    wpri_4;
        logic           mbe;
        logic           sbe;
        logic [1:0]     sxl;
        logic [1:0]     uxl;
        logic [8:0]     wpri_3;
        logic           tsr;
        logic           tw;
        logic           tvm;
        logic           mxr;
        logic           sum;
        logic           mprv;
        logic [1:0]     xs;
        logic [1:0]     fs;
        logic [1:0]     mpp;
        logic [1:0]     vs;
        logic           spp;
        logic           mpie;
        logic           ube;
        logic           spie;
        logic           wpri_2;
        logic           mie;
        logic           wpri_1;
        logic           sie;
        logic           wpri_0;
    } mstatus_t;

    typedef struct packed
    {
        logic [1:0]     mxl;
        logic [35:0]    zero;
        logic [25:0]    extensions;
    } misa_t;

    typedef logic [63:0]        medeleg_t;
    typedef logic [MXLEN - 1:0] mideleg_t;

    typedef struct packed {
        logic [47:0]    non_standard;
        logic [1:0]     zero_7;
        logic           lcofie;
        logic           zero_6;
        logic           meie;
        logic           zero_5;
        logic           seie;
        logic           zero_4;
        logic           mtie;
        logic           zero_3;
        logic           stie;
        logic           zero_2;
        logic           msie;
        logic           zero_1;
        logic           ssie;
        logic           zero_0;
    } mie_t;

    typedef struct packed
    {
        logic [61:0]    base;
        logic [1:0]     mode;
    } mtvec_t;

    typedef enum logic [1:0]
    {
        DIRECT      = 2'd0,
        VECTORED    = 2'd1
    } mtvec_mode_t;

    typedef struct packed
    {
        logic hpm31;
        logic hpm30;
        logic hpm29;
        logic hpm28;
        logic hpm27;
        logic hpm26;
        logic hpm25;
        logic hpm24;
        logic hpm23;
        logic hpm22;
        logic hpm21;
        logic hpm20;
        logic hpm19;
        logic hpm18;
        logic hpm17;
        logic hpm16;
        logic hpm15;
        logic hpm14;
        logic hpm13;
        logic hpm12;
        logic hpm11;
        logic hpm10;
        logic hpm9;
        logic hpm8;
        logic hpm7;
        logic hpm6;
        logic hpm5;
        logic hpm4;
        logic hpm3;
        logic ir;
        logic tm;
        logic cy;
    } mcounteren_t;

    typedef struct packed {
        logic [25:0]    wpri_1;
        logic           mbe;
        logic           sbe;
        logic [3:0]     wpri_0;
    } mstatush_t;

    typedef logic [MXLEN - 1:0] medelegh_t; // Does not exists.

    // Machine Trap Handling.
    typedef logic [MXLEN - 1:0] mscratch_t;
    typedef logic [MXLEN - 1:0] mepc_t;

    typedef struct packed {
        logic           interrupt;
        logic [62:0]    exception_code;
    } mcause_t;

    typedef logic [MXLEN - 1:0] mtval_t;

    typedef struct packed {
        logic [47:0]    non_standard;
        logic [1:0]     zero_7;
        logic           lcofip;
        logic           zero_6;
        logic           meip;
        logic           zero_5;
        logic           seip;
        logic           zero_4;
        logic           mtip;
        logic           zero_3;
        logic           stip;
        logic           zero_2;
        logic           msip;
        logic           zero_1;
        logic           ssip;
        logic           zero_0;
    } mip_t;

    typedef logic [MXLEN - 1:0] mtinst_t;
    typedef logic [MXLEN - 1:0] mtval2_t;

    // Machine Counters/Timers.
    typedef logic [MXLEN - 1:0] mcycle_t;
    typedef logic [MXLEN - 1:0] minstret_t;
    typedef logic [MXLEN - 1:0] mhpmcounter_t;

    typedef enum logic [MXLEN - 2:0]
    {
        SUPERVISOR_SOFTWARE_INTERRUPT   = 63'd1,
        MACHINE_SOFTWARE_INTERRUPT      = 63'd3,
        SUPERVISOR_TIMER_INTERRUPT      = 63'd5,
        MACHINE_TIMER_INTERRUPT         = 63'd7,
        SUPERVISOR_EXTERNAL_INTERRUPT   = 63'd9,
        MACHINE_EXTERNAL_INTERRUPT      = 63'd11,
        COUNTER_OVERFLOW_INTERRUPT      = 63'd13
    } asynchronous_exception_code_t;

    typedef enum logic [MXLEN - 2:0]
    {   
        INSTRUCTION_ADDRESS_MISALIGNED  = 63'd0,
        INSTRUCTION_ACCESS_FAULT        = 63'd1,
        ILLEGAL_INSTRUCTION             = 63'd2,
        BREAKPOINT                      = 63'd3,
        LOAD_ADDRESS_MISALIGNED         = 63'd4,
        LOAD_ACCESS_FAULT               = 63'd5,
        STORE_AMO_ADDRESS_MISALIGNED    = 63'd6,
        STORE_AMO_ACCESS_FAULT          = 63'd7,
        ENVIRONMENT_CALL_FROM_U_MODE    = 63'd8,
        ENVIRONMENT_CALL_FROM_S_MODE    = 63'd9,
        ENVIRONMENT_CALL_FROM_M_MODE    = 63'd11,
        INSTRUCTION_PAGE_FAULT          = 63'd12,
        LOAD_PAGE_FAULT                 = 63'd13,
        STORE_AMO_PAGE_FAULT            = 63'd15,
        SOFTWARE_CHECK                  = 63'd18,
        HARDWARE_ERROR                  = 63'd19
    } synchronous_exception_code_t;

    typedef logic [MXLEN - 1:0] exception_code_t;

    typedef struct packed
    {
        logic               interrupt;
        exception_code_t    exception_code;
    } csr_exception_cause_t;

    typedef enum logic [1:0]
    {
        USER        = 2'b00,
        SUPERVISOR  = 2'b01,
        RESERVED    = 2'b10,
        MACHINE     = 2'b11
    } privilege_level_t;

    typedef enum logic [1:0]
    {
        OFF     = 2'b00,
        INITIAL = 2'b01,
        CLEAN   = 2'b10,
        DIRTY   = 2'b11
    } extension_status_t;

    typedef enum logic [11:0]
    {
        // M-Mode Registers.
        // Machine Trap Setup.
        CSR_MSTATUS         = 12'h300,
        CSR_MISA            = 12'h301,
        CSR_MEDELEG         = 12'h302,
        CSR_MIDELEG         = 12'h303,
        CSR_MIE             = 12'h304,
        CSR_MTVEC           = 12'h305,
        CSR_MCOUNTEREN      = 12'h306,

        // Machine Trap Handling.
        CSR_MSCRATCH        = 12'h340,
        CSR_MEPC            = 12'h341,
        CSR_MCAUSE          = 12'h342,
        CSR_MTVAL           = 12'h343,
        CSR_MIP             = 12'h344,
        CSR_MTINST          = 12'h34A,
        CSR_MTVAL2          = 12'h34B,

        // Machine Counters/Timers.
        // Note: Values From BSC's Versions Started At 0xC00.
        CSR_MCYCLE           = 12'hB00,
        CSR_MINSTRET         = 12'hB02,
        CSR_MHPMCOUNTER_3    = 12'hB03,
        CSR_MHPMCOUNTER_4    = 12'hB04,
        CSR_MHPMCOUNTER_5    = 12'hB05,
        CSR_MHPMCOUNTER_6    = 12'hB06,
        CSR_MHPMCOUNTER_7    = 12'hB07,
        CSR_MHPMCOUNTER_8    = 12'hB08,
        CSR_MHPMCOUNTER_9    = 12'hB09,
        CSR_MHPMCOUNTER_10   = 12'hB0A,
        CSR_MHPMCOUNTER_11   = 12'hB0B,
        CSR_MHPMCOUNTER_12   = 12'hB0C,
        CSR_MHPMCOUNTER_13   = 12'hB0D,
        CSR_MHPMCOUNTER_14   = 12'hB0E,
        CSR_MHPMCOUNTER_15   = 12'hB0F,
        CSR_MHPMCOUNTER_16   = 12'hB10,
        CSR_MHPMCOUNTER_17   = 12'hB11,
        CSR_MHPMCOUNTER_18   = 12'hB12,
        CSR_MHPMCOUNTER_19   = 12'hB13,
        CSR_MHPMCOUNTER_20   = 12'hB14,
        CSR_MHPMCOUNTER_21   = 12'hB15,
        CSR_MHPMCOUNTER_22   = 12'hB16,
        CSR_MHPMCOUNTER_23   = 12'hB17,
        CSR_MHPMCOUNTER_24   = 12'hB18,
        CSR_MHPMCOUNTER_25   = 12'hB19,
        CSR_MHPMCOUNTER_26   = 12'hB1A,
        CSR_MHPMCOUNTER_27   = 12'hB1B,
        CSR_MHPMCOUNTER_28   = 12'hB1C,
        CSR_MHPMCOUNTER_29   = 12'hB1D,
        CSR_MHPMCOUNTER_30   = 12'hB1E,
        CSR_MHPMCOUNTER_31   = 12'hB1F
    } csr_allocation_t;

    typedef enum logic [3:0]
    {
        WRITE_AND_READ  = 4'b0001,
        SET_AND_READ    = 4'b0010,
        CLEAR_AND_READ  = 4'b0011,
        READ_ONLY       = 4'b0101,
        WRITE_ONLY      = 4'b1000
    } csr_command_t;

    typedef struct packed
    {
        logic [1:0]         read_write_access;
        privilege_level_t   minimum_privilege_level;
        logic [7:0]         physical_address;
    } csr_address_t;

endpackage