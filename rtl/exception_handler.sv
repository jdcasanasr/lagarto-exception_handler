//**********************************************************************//
//  Proyecto:       SoC_AXI_Lagarto_I                                   //
//  Archivo:        exception_handler.sv                                //
//  Organización:   Instituto Politécnico Nacional                      //
//  Autor(es):      Daniel Casañas, Marco Ramírez                       //
//  Supervisor:     Dr. Marco Antonio Ramírez Salinas                   //
//  E-mail:         lagarto@cic.ipn.mx                                  //
//  Referencias:    https://github.com/riscv/riscv-plic-spec            //
//**********************************************************************//

import riscv_pkg            :: * ;
import riscv_privileged_pkg :: * ;

module exception_handler
(
    input logic                             clock_i,
    input logic                             reset_ni,

    // From Lagarto Hun Core.
    input csr_address_t                     csr_address_i,
    input csr_command_t                     csr_command_i,
    input logic [MXLEN - 1:0]               csr_write_data_i,

    input logic                             csr_exception_i,
    input csr_exception_cause_t             csr_exception_cause_i,
    input logic [XLEN - 1:0]                csr_exception_pc_i,

    // Interrupts.
    //input logic                             external_interrupt_i,
    input logic                             timer_interrupt_i,
    //input logic                             software_interrupt_i,

    // To Lagarto Hun Core.
    output logic [MXLEN - 1:0]              csr_read_data_o,
    output logic                            csr_read_data_valid_o
);
    // Supported CSR's & Driving Buses.
    // M-Mode Registers.
    // Machine Trap Setup.
    mstatus_t       mstatus_r,          mstatus_w,          mstatus_reset_w;
    misa_t          misa_r,             misa_w,             misa_reset_w;
    mie_t           mie_r,              mie_w,              mie_reset_w;
    mtvec_t         mtvec_r,            mtvec_w,            mtvec_reset_w;
    mcounteren_t    mcounteren_r,       mcounteren_w,       mcounteren_reset_w;

    // Machine Trap Handling.
    mscratch_t      mscratch_r,         mscratch_w,         mscratch_reset_w;
    mepc_t          mepc_r,             mepc_w,             mepc_reset_w;
    mcause_t        mcause_r,           mcause_w,           mcause_reset_w;
    mtval_t         mtval_r,            mtval_w,            mtval_reset_w;
    mip_t           mip_r,              mip_w,              mip_reset_w;
    mtinst_t        mtinst_r,           mtinst_w,           mtinst_reset_w;
    mtval2_t        mtval2_r,           mtval2_w,           mtval2_reset_w;

    // Machine Counters/Timers.
    mcycle_t        mcycle_r,           mcycle_w,           mcycle_reset_w;
    minstret_t      minstret_r,         minstret_w,         minstret_reset_w;
    mhpmcounter_t   mhpmcounter3_r,     mhpmcounter3_w,     mhpmcounter3_reset_w;
    mhpmcounter_t   mhpmcounter4_r,     mhpmcounter4_w,     mhpmcounter4_reset_w;
    mhpmcounter_t   mhpmcounter5_r,     mhpmcounter5_w,     mhpmcounter5_reset_w;
    mhpmcounter_t   mhpmcounter6_r,     mhpmcounter6_w,     mhpmcounter6_reset_w;
    mhpmcounter_t   mhpmcounter7_r,     mhpmcounter7_w,     mhpmcounter7_reset_w;
    mhpmcounter_t   mhpmcounter8_r,     mhpmcounter8_w,     mhpmcounter8_reset_w;
    mhpmcounter_t   mhpmcounter9_r,     mhpmcounter9_w,     mhpmcounter9_reset_w;
    mhpmcounter_t   mhpmcounter10_r,    mhpmcounter10_w,    mhpmcounter10_reset_w;
    mhpmcounter_t   mhpmcounter11_r,    mhpmcounter11_w,    mhpmcounter11_reset_w;
    mhpmcounter_t   mhpmcounter12_r,    mhpmcounter12_w,    mhpmcounter12_reset_w;
    mhpmcounter_t   mhpmcounter13_r,    mhpmcounter13_w,    mhpmcounter13_reset_w;
    mhpmcounter_t   mhpmcounter14_r,    mhpmcounter14_w,    mhpmcounter14_reset_w;
    mhpmcounter_t   mhpmcounter15_r,    mhpmcounter15_w,    mhpmcounter15_reset_w;
    mhpmcounter_t   mhpmcounter16_r,    mhpmcounter16_w,    mhpmcounter16_reset_w;
    mhpmcounter_t   mhpmcounter17_r,    mhpmcounter17_w,    mhpmcounter17_reset_w;
    mhpmcounter_t   mhpmcounter18_r,    mhpmcounter18_w,    mhpmcounter18_reset_w;
    mhpmcounter_t   mhpmcounter19_r,    mhpmcounter19_w,    mhpmcounter19_reset_w;
    mhpmcounter_t   mhpmcounter20_r,    mhpmcounter20_w,    mhpmcounter20_reset_w;
    mhpmcounter_t   mhpmcounter21_r,    mhpmcounter21_w,    mhpmcounter21_reset_w;
    mhpmcounter_t   mhpmcounter22_r,    mhpmcounter22_w,    mhpmcounter22_reset_w;
    mhpmcounter_t   mhpmcounter23_r,    mhpmcounter23_w,    mhpmcounter23_reset_w;
    mhpmcounter_t   mhpmcounter24_r,    mhpmcounter24_w,    mhpmcounter24_reset_w;
    mhpmcounter_t   mhpmcounter25_r,    mhpmcounter25_w,    mhpmcounter25_reset_w;
    mhpmcounter_t   mhpmcounter26_r,    mhpmcounter26_w,    mhpmcounter26_reset_w;
    mhpmcounter_t   mhpmcounter27_r,    mhpmcounter27_w,    mhpmcounter27_reset_w;
    mhpmcounter_t   mhpmcounter28_r,    mhpmcounter28_w,    mhpmcounter28_reset_w;
    mhpmcounter_t   mhpmcounter29_r,    mhpmcounter29_w,    mhpmcounter29_reset_w;
    mhpmcounter_t   mhpmcounter30_r,    mhpmcounter30_w,    mhpmcounter30_reset_w;
    mhpmcounter_t   mhpmcounter31_r,    mhpmcounter31_w,    mhpmcounter31_reset_w;

    // Internal Signals.
    privilege_level_t privilege_level_r, privilege_level_w;

    // Control Signals.
    logic csr_address_exists_w;
    logic csr_privilege_violation_w;

    logic csr_read_enable_w;
    logic csr_write_enable_w;

    // Type Casts.
    // M-Mode Registers.
    // Machine Trap Setup.
    mstatus_t       mstatus_write_data      = mstatus_t'(csr_write_data_i);
    mie_t           mie_write_data_w        = mie_t'(csr_write_data_i);
    mtvec_t         mtvec_write_data_w      = mtvec_t'(csr_write_data_i);
    mcounteren_t    mcounteren_write_data   = mcounteren_t'(csr_write_data_i[31:0]);

    // Machine Trap Handling.
    mscratch_t      mscratch_write_data     = mscratch_t'(csr_write_data_i);
    mepc_t          mepc_write_data         = mepc_t'(csr_exception_pc_i);
    mcause_t        mcause_write_data       = mcause_t'(csr_exception_cause_i);
    mtval_t         mtval_write_data        = mtval_t'(csr_write_data_i);
    mip_t           mip_write_data          = mip_t'(csr_write_data_i);
    mtinst_t        mtinst_write_data       = mtinst_t'(csr_write_data_i);
    mtval2_t        mtval2_write_data       = mtval2_t'(csr_write_data_i);

    // Drive Reset Buses.
    // M-Mode Registers.
    // Machine Trap Setup.
    assign mstatus_reset_w          = '0;
    assign misa_reset_w             = misa_w;
    assign mie_reset_w              = '0;

    assign mtvec_reset_w.base       = {2'b0, BOOT_ADDRESS};
    assign mtvec_reset_w.mode       = DIRECT;

    assign mcounteren_reset_w       = '0;

    // Machine Trap Handling.
    assign mscratch_reset_w         = '0;
    assign mepc_reset_w             = '0;
    assign mcause_reset_w           = '0;
    assign mtval_reset_w            = '0;
    assign mip_reset_w              = '0;
    assign mtinst_reset_w           = '0;
    assign mtval2_reset_w           = '0;

    // Machine Counters/Timers.
    assign mcycle_reset_w           = '0;
    assign minstret_reset_w         = '0;
    assign mhpmcounter3_reset_w     = '0;
    assign mhpmcounter4_reset_w     = '0;
    assign mhpmcounter5_reset_w     = '0;
    assign mhpmcounter6_reset_w     = '0;
    assign mhpmcounter7_reset_w     = '0;
    assign mhpmcounter8_reset_w     = '0;
    assign mhpmcounter9_reset_w     = '0;
    assign mhpmcounter10_reset_w    = '0;
    assign mhpmcounter11_reset_w    = '0;
    assign mhpmcounter12_reset_w    = '0;
    assign mhpmcounter13_reset_w    = '0;
    assign mhpmcounter14_reset_w    = '0;
    assign mhpmcounter15_reset_w    = '0;
    assign mhpmcounter16_reset_w    = '0;
    assign mhpmcounter17_reset_w    = '0;
    assign mhpmcounter18_reset_w    = '0;
    assign mhpmcounter19_reset_w    = '0;
    assign mhpmcounter20_reset_w    = '0;
    assign mhpmcounter21_reset_w    = '0;
    assign mhpmcounter22_reset_w    = '0;
    assign mhpmcounter23_reset_w    = '0;
    assign mhpmcounter24_reset_w    = '0;
    assign mhpmcounter25_reset_w    = '0;
    assign mhpmcounter26_reset_w    = '0;
    assign mhpmcounter27_reset_w    = '0;
    assign mhpmcounter28_reset_w    = '0;
    assign mhpmcounter29_reset_w    = '0;
    assign mhpmcounter30_reset_w    = '0;
    assign mhpmcounter31_reset_w    = '0;
    
    // Internal Signals Update.
    // Note: For the mean time, we'll only support this mode.
    assign privilege_level_w = MACHINE;

    // Control Signals Update.
    // Drive csr_address_exists_w.
    always_comb
        case(csr_address_i)
            // M-Mode Registers.
            // Machine Trap Setup.
            CSR_MSTATUS,
            CSR_MISA,
            CSR_MEDELEG,
            CSR_MIDELEG,
            CSR_MIE,
            CSR_MTVEC,
            CSR_MCOUNTEREN,

            // Machine Trap Handling.
            CSR_MSCRATCH,
            CSR_MEPC,
            CSR_MCAUSE,
            CSR_MTVAL,
            CSR_MIP,
            CSR_MTINST,
            CSR_MTVAL2,
            
            // Machine Counters/Timers.
            CSR_MCYCLE,
            CSR_MINSTRET,
            CSR_MHPMCOUNTER_3,
            CSR_MHPMCOUNTER_4,
            CSR_MHPMCOUNTER_5,
            CSR_MHPMCOUNTER_6,
            CSR_MHPMCOUNTER_7,
            CSR_MHPMCOUNTER_8,
            CSR_MHPMCOUNTER_9,
            CSR_MHPMCOUNTER_10,
            CSR_MHPMCOUNTER_11,
            CSR_MHPMCOUNTER_12,
            CSR_MHPMCOUNTER_13,
            CSR_MHPMCOUNTER_14,
            CSR_MHPMCOUNTER_15,
            CSR_MHPMCOUNTER_16,
            CSR_MHPMCOUNTER_17,
            CSR_MHPMCOUNTER_18,
            CSR_MHPMCOUNTER_19,
            CSR_MHPMCOUNTER_20,
            CSR_MHPMCOUNTER_21,
            CSR_MHPMCOUNTER_22,
            CSR_MHPMCOUNTER_23,
            CSR_MHPMCOUNTER_24,
            CSR_MHPMCOUNTER_25,
            CSR_MHPMCOUNTER_26,
            CSR_MHPMCOUNTER_27,
            CSR_MHPMCOUNTER_28,
            CSR_MHPMCOUNTER_29,
            CSR_MHPMCOUNTER_30,
            CSR_MHPMCOUNTER_31:     csr_address_exists_w = 1'b1;

            default:                csr_address_exists_w = 1'b0;
        endcase
    
    assign csr_privilege_violation_w    = (csr_address_i.minimum_privilege_level < privilege_level_r) ? 1'b1 : 1'b0;

    assign csr_read_enable_w            = (csr_command_i inside {READ_ONLY, WRITE_AND_READ})    && csr_address_exists_w && !csr_privilege_violation_w ? 1'b1 : 1'b0;
    assign csr_write_enable_w           = (csr_command_i inside {WRITE_ONLY, WRITE_AND_READ})   && csr_address_exists_w && !csr_privilege_violation_w ? 1'b1 : 1'b0;

    // Output Signals Update.
    assign csr_read_data_valid_o        = csr_address_exists_w && !csr_privilege_violation_w ? 1'b1 : 1'b0;

    // Privilege Level Update.
    always_ff @ (posedge clock_i, negedge reset_ni)
        if (!reset_ni)
            privilege_level_r = MACHINE;

        else
            privilege_level_r = privilege_level_w;

    // CSR Read Loop.
    always_comb
        if (csr_read_enable_w)
            case(csr_allocation_t'(csr_address_i))
                // M-Mode Registers.
                // Machine Trap Setup.
                CSR_MSTATUS:            csr_read_data_o = mstatus_r;
                CSR_MISA:               csr_read_data_o = misa_r;
                CSR_MIE:                csr_read_data_o = mie_r;
                CSR_MTVEC:              csr_read_data_o = mtvec_r;
                CSR_MCOUNTEREN:         csr_read_data_o = mcounteren_r;
                
                // Machine Trap Handling.
                CSR_MSCRATCH:           csr_read_data_o = mscratch_r;
                CSR_MEPC:               csr_read_data_o = mepc_r;
                CSR_MCAUSE:             csr_read_data_o = mcause_r;
                CSR_MTVAL:              csr_read_data_o = mtval_r;
                CSR_MIP:                csr_read_data_o = mip_r;
                CSR_MTINST:             csr_read_data_o = mtinst_r;
                CSR_MTVAL2:             csr_read_data_o = mtval2_r;

                // Machine Counters/Timers.
                CSR_MCYCLE:             csr_read_data_o = mcycle_r;
                CSR_MINSTRET:           csr_read_data_o = minstret_r;
                CSR_MHPMCOUNTER_3:      csr_read_data_o = mhpmcounter3_r;
                CSR_MHPMCOUNTER_4:      csr_read_data_o = mhpmcounter4_r;
                CSR_MHPMCOUNTER_5:      csr_read_data_o = mhpmcounter5_r;
                CSR_MHPMCOUNTER_6:      csr_read_data_o = mhpmcounter6_r;
                CSR_MHPMCOUNTER_7:      csr_read_data_o = mhpmcounter7_r;
                CSR_MHPMCOUNTER_8:      csr_read_data_o = mhpmcounter8_r;
                CSR_MHPMCOUNTER_9:      csr_read_data_o = mhpmcounter9_r;
                CSR_MHPMCOUNTER_10:     csr_read_data_o = mhpmcounter10_r;
                CSR_MHPMCOUNTER_11:     csr_read_data_o = mhpmcounter11_r;
                CSR_MHPMCOUNTER_12:     csr_read_data_o = mhpmcounter12_r;
                CSR_MHPMCOUNTER_13:     csr_read_data_o = mhpmcounter13_r;
                CSR_MHPMCOUNTER_14:     csr_read_data_o = mhpmcounter14_r;
                CSR_MHPMCOUNTER_15:     csr_read_data_o = mhpmcounter15_r;
                CSR_MHPMCOUNTER_16:     csr_read_data_o = mhpmcounter16_r;
                CSR_MHPMCOUNTER_17:     csr_read_data_o = mhpmcounter17_r;
                CSR_MHPMCOUNTER_18:     csr_read_data_o = mhpmcounter18_r;
                CSR_MHPMCOUNTER_19:     csr_read_data_o = mhpmcounter19_r;
                CSR_MHPMCOUNTER_20:     csr_read_data_o = mhpmcounter20_r;
                CSR_MHPMCOUNTER_21:     csr_read_data_o = mhpmcounter21_r;
                CSR_MHPMCOUNTER_22:     csr_read_data_o = mhpmcounter22_r;
                CSR_MHPMCOUNTER_23:     csr_read_data_o = mhpmcounter23_r;
                CSR_MHPMCOUNTER_24:     csr_read_data_o = mhpmcounter24_r;
                CSR_MHPMCOUNTER_25:     csr_read_data_o = mhpmcounter25_r;
                CSR_MHPMCOUNTER_26:     csr_read_data_o = mhpmcounter26_r;
                CSR_MHPMCOUNTER_27:     csr_read_data_o = mhpmcounter27_r;
                CSR_MHPMCOUNTER_28:     csr_read_data_o = mhpmcounter28_r;
                CSR_MHPMCOUNTER_29:     csr_read_data_o = mhpmcounter29_r;
                CSR_MHPMCOUNTER_30:     csr_read_data_o = mhpmcounter30_r;
                CSR_MHPMCOUNTER_31:     csr_read_data_o = mhpmcounter31_r;

                default:            csr_read_data_o = '0;
            endcase

        else
            csr_read_data_o = '0;

    // CSR Write Loop.
    always_ff @ (posedge clock_i, negedge reset_ni)
        if (!reset_ni)
            begin
                // M-Mode Registers.
                // Machine Trap Se:tup.
                mstatus_r       = mstatus_reset_w;
                misa_r          = misa_reset_w;
                mie_r           = mie_reset_w;
                mtvec_r         = mtvec_reset_w;
                mcounteren_r    = mcounteren_reset_w;

                // Machine Trap Handling.
                mscratch_r      = mscratch_reset_w;
                mepc_r          = mepc_reset_w;
                mcause_r        = mcause_reset_w;
                mtval_r         = mtval_reset_w;
                mip_r           = mip_reset_w;
                mtinst_r        = mtinst_reset_w;
                mtval2_r        = mtval2_reset_w;

                // Machine Counters/Timers.
                mcycle_r        = mcycle_reset_w;
                minstret_r      = minstret_reset_w;
                mhpmcounter3_r  = mhpmcounter3_reset_w;
                mhpmcounter4_r  = mhpmcounter4_reset_w;
                mhpmcounter5_r  = mhpmcounter5_reset_w;
                mhpmcounter6_r  = mhpmcounter6_reset_w;
                mhpmcounter7_r  = mhpmcounter7_reset_w;
                mhpmcounter8_r  = mhpmcounter8_reset_w;
                mhpmcounter9_r  = mhpmcounter9_reset_w;
                mhpmcounter10_r = mhpmcounter10_reset_w;
                mhpmcounter11_r = mhpmcounter11_reset_w;
                mhpmcounter12_r = mhpmcounter12_reset_w;
                mhpmcounter13_r = mhpmcounter13_reset_w;
                mhpmcounter14_r = mhpmcounter14_reset_w;
                mhpmcounter15_r = mhpmcounter15_reset_w;
                mhpmcounter16_r = mhpmcounter16_reset_w;
                mhpmcounter17_r = mhpmcounter17_reset_w;
                mhpmcounter18_r = mhpmcounter18_reset_w;
                mhpmcounter19_r = mhpmcounter19_reset_w;
                mhpmcounter20_r = mhpmcounter20_reset_w;
                mhpmcounter21_r = mhpmcounter21_reset_w;
                mhpmcounter22_r = mhpmcounter22_reset_w;
                mhpmcounter23_r = mhpmcounter23_reset_w;
                mhpmcounter24_r = mhpmcounter24_reset_w;
                mhpmcounter25_r = mhpmcounter25_reset_w;
                mhpmcounter26_r = mhpmcounter26_reset_w;
                mhpmcounter27_r = mhpmcounter27_reset_w;
                mhpmcounter28_r = mhpmcounter28_reset_w;
                mhpmcounter29_r = mhpmcounter29_reset_w;
                mhpmcounter30_r = mhpmcounter30_reset_w;
                mhpmcounter31_r = mhpmcounter31_reset_w;
            end

        else
            begin
                // M-Mode Registers.
                // Machine Trap Setup.
                mstatus_r       = mstatus_w;
                misa_r          = misa_w;
                mie_r           = mie_w;
                mtvec_r         = mtvec_w;
                mcounteren_r    = mcounteren_w;

                // Machine Trap Handling.
                mscratch_r      = mscratch_w;
                mepc_r          = mepc_w;
                mcause_r        = mcause_w;
                mtval_r         = mtval_w;
                mip_r           = mip_w;
                mtinst_r        = mtinst_w;
                mtval2_r        = mtval2_w;

                // Machine Counters/Timers.
                mcycle_r        = mcycle_w;
                minstret_r      = minstret_w;
                mhpmcounter3_r  = mhpmcounter3_w;
                mhpmcounter4_r  = mhpmcounter4_w;
                mhpmcounter5_r  = mhpmcounter5_w;
                mhpmcounter6_r  = mhpmcounter6_w;
                mhpmcounter7_r  = mhpmcounter7_w;
                mhpmcounter8_r  = mhpmcounter8_w;
                mhpmcounter9_r  = mhpmcounter9_w;
                mhpmcounter10_r = mhpmcounter10_w;
                mhpmcounter11_r = mhpmcounter11_w;
                mhpmcounter12_r = mhpmcounter12_w;
                mhpmcounter13_r = mhpmcounter13_w;
                mhpmcounter14_r = mhpmcounter14_w;
                mhpmcounter15_r = mhpmcounter15_w;
                mhpmcounter16_r = mhpmcounter16_w;
                mhpmcounter17_r = mhpmcounter17_w;
                mhpmcounter18_r = mhpmcounter18_w;
                mhpmcounter19_r = mhpmcounter19_w;
                mhpmcounter20_r = mhpmcounter20_w;
                mhpmcounter21_r = mhpmcounter21_w;
                mhpmcounter22_r = mhpmcounter22_w;
                mhpmcounter23_r = mhpmcounter23_w;
                mhpmcounter24_r = mhpmcounter24_w;
                mhpmcounter25_r = mhpmcounter25_w;
                mhpmcounter26_r = mhpmcounter26_w;
                mhpmcounter27_r = mhpmcounter27_w;
                mhpmcounter28_r = mhpmcounter28_w;
                mhpmcounter29_r = mhpmcounter29_w;
                mhpmcounter30_r = mhpmcounter30_w;
                mhpmcounter31_r = mhpmcounter31_w;
            end

    // CSR Update Loops.
    // Machine Trap Setup.
    // mstatus.
    always_comb
        begin   : mstatus_update
            // Implemented Extensions.
            // Note: In The Mean Time, All Extensions Are Off.
            mstatus_w.sd        = '0;
            mstatus_w.xs        = '0;
            mstatus_w.fs        = '0;
            mstatus_w.vs        = '0;

            // Reserved Fields For Future Use.
            mstatus_w.wpri_4    = '0;
            mstatus_w.wpri_3    = '0;
            mstatus_w.wpri_2    = '0;
            mstatus_w.wpri_1    = '0;
            mstatus_w.wpri_0    = '0;

            // Endianness Control.
            mstatus_w.sbe       = '0;
            mstatus_w.ube       = '0;

            // U-Mode & S-MODE XLEN
            // Note: Read-Only Zero, Since U-Mode & S-Mode Is Not Yet Supported.
            mstatus_w.uxl       = '0;
            mstatus_w.sxl       = '0;

            // Trap SRET.
            mstatus_w.tsr       = '0;

            // Time Waitout.
            // Note: tw = 0 Indicates WFI Can Execute In Any Privilege Mode,
            // Whenever Possible.
            mstatus_w.tw        = '0;

            // Trap Virtual Memory.
            // Note: Off, Since S-Mode Is Not Yet Supported.
            mstatus_w.tvm       = '0;

            // Make Executable Readable Support (Virtual Memory Page Access).
            // Note: Read-Only Zero, Since S-Mode Is Not Yet Supported.
            mstatus_w.mxr       = '0;

            // Permit Supervisor U-Mode Memory Access.
            // Note: Off, Since S-Mode Is Not Yet Supported.
            mstatus_w.sum       = '0;

            // Modify Privilege Support.
            // Note: Off, Since U-Mode Is Not Supported.
            mstatus_w.mprv      = '0;

            // Supervisor Interrupt Control.
            mstatus_w.spp       = '0;
            mstatus_w.spie      = '0;
            mstatus_w.sie       = '0;

            // Q: What Fields Are Writable By Direct Access?.
            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MSTATUS)
                begin
                    mstatus_w.mbe = mstatus_write_data.mbe;
                    mstatus_w.mie = mstatus_write_data.mie;
                end

            else
                begin
                    mstatus_w.mbe = mstatus_r.mbe;
                    mstatus_w.mie = mstatus_r.mie;
                end

            if (csr_exception_i && !csr_privilege_violation_w)
                begin
                    mstatus_w.mpp   = privilege_level_r;
                    mstatus_w.mpie  = mstatus_r.mie;
                end
            
            else
                begin
                    mstatus_w.mpp   = mstatus_r.mpp;
                    mstatus_w.mpie  = mstatus_r.mpie;
                end
        end     : mstatus_update

    // misa.
    always_comb
        begin   : misa_update
            misa_w.mxl          = XLEN_64;
            misa_w.zero         = '0;
            misa_w.extensions   = I;
        end     : misa_update

    // mie.
    always_comb
        begin   : mie_update
            // Undefined Region.
            mie_w.non_standard  = '0;

            // Unsupported Interrupts.
            mie_w.lcofie        = '0;
            mie_w.seie          = '0;
            mie_w.stie          = '0;
            mie_w.ssie          = '0;

            // Always-Zero Regions.
            mie_w.zero_7        = '0;
            mie_w.zero_6        = '0;
            mie_w.zero_5        = '0;
            mie_w.zero_4        = '0;
            mie_w.zero_3        = '0;
            mie_w.zero_2        = '0;
            mie_w.zero_1        = '0;
            mie_w.zero_0        = '0;

            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MIE)
                begin
                    // Note: Only M-Mode Interrupts Are Supported.
                    mie_w.meie = mie_write_data_w.meie;
                    mie_w.mtie = mie_write_data_w.mtie;
                    mie_w.msie = mie_write_data_w.msie;
                end

            else
                begin
                    mie_w.meie = mie_r.meie;
                    mie_w.mtie = mie_r.mtie;
                    mie_w.msie = mie_r.msie;
                end
        end     : mie_update

    // mtvec.
    always_comb
        begin   : mtvec_update
            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MTVEC)
                begin
                    mtvec_w.base = mtvec_write_data_w.base;
                    mtvec_w.mode = mtvec_write_data_w.mode;
                end

            else
                mtvec_w = mtvec_r;
        end     : mtvec_update

    // mcounteren
    always_comb
        begin   : mcounteren_update
            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MCOUNTEREN)
                mcounteren_w = mcounteren_write_data;

            else
                mcounteren_w = mcounteren_r;

        end     : mcounteren_update

    // Machine Trap Handling.
    // mscratch.
    always_comb
        begin   : mscratch_update
            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MSCRATCH)
                mscratch_w = mscratch_write_data;

            else
                mscratch_w = mscratch_r;
        end     : mscratch_update

    // mepc.
    always_comb
        begin   : mepc_update
            // Note: Should I Check csr_write_enable?
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MEPC)
                mepc_w = {mepc_write_data[63:1], 1'b0};

            else
                mepc_w = mepc_r;
        end     : mepc_update

    // mcause.
    always_comb
        begin   : mcause_update
            // Note: Should I Check csr_write_enable?
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MCAUSE)
                mcause_w = mcause_write_data;

            else
                mcause_w = mcause_r;
        end     : mcause_update

    // mtval.
    always_comb
        begin   : mtval_update
            if (csr_exception_i && csr_write_enable_w)
                case (csr_exception_cause_i)
                    LOAD_ADDRESS_MISALIGNED,
                    LOAD_ACCESS_FAULT, 
                    STORE_AMO_ADDRESS_MISALIGNED,
                    STORE_AMO_ACCESS_FAULT,
                    LOAD_ACCESS_FAULT,
                    STORE_AMO_PAGE_FAULT,
                    INSTRUCTION_PAGE_FAULT,
                    INSTRUCTION_ADDRESS_MISALIGNED  : mtval_w = csr_write_data_i;

                    ILLEGAL_INSTRUCTION             : mtval_w = '0;
                    BREAKPOINT                      : mtval_w = csr_exception_pc_i;

                    default                         : mtval_w = '0; 

                endcase

            else
                mtval_w = mtval_r;
        end     : mtval_update

    // mip.
    always_comb
        begin   : mip_update
            mip_w.non_standard  = '0;
            mip_w.lcofip        = '0;
            mip_w.seip          = '0;
            mip_w.stip          = '0;
            mip_w.ssip          = '0;

            mip_w.zero_7        = '0;
            mip_w.zero_6        = '0;
            mip_w.zero_5        = '0;
            mip_w.zero_4        = '0;
            mip_w.zero_3        = '0;
            mip_w.zero_2        = '0;
            mip_w.zero_1        = '0;
            mip_w.zero_0        = '0;

            // Default State.
            mip_w.meip          = '0;
            mip_w.mtip          = '0;
            mip_w.msip          = '0;

            //if (external_interrupt_i)
            //    mip_w.meip = '1;

            if (timer_interrupt_i)
                mip_w.mtip = '1;

            //if (software_interrupt_i)
            //    mip_w.msip = '1;

            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MIP)
                begin
                    mip_w.meip = mip_write_data.meip;
                    mip_w.mtip = mip_write_data.mtip;
                    mip_w.msip = mip_write_data.msip;
                end

            else
                mip_w = mip_r;
        end     : mip_update

    // mtinst.
    always_comb
        begin   : mtinst_update
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MTINST)
                mtinst_w = mtinst_write_data;

            else
                mtinst_w = mtinst_r;

        end     : mtinst_update

    // mtval2.
    always_comb
        begin   : mtval2_update
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MTVAL2)
                mtval2_w = mtval2_write_data;

            else
                mtval2_w = mtval2_r;
        end     : mtval2_update

endmodule