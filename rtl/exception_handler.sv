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

    // To Lagarto Hun Core.
    output logic [MXLEN - 1:0]              csr_read_data_o,
    output logic                            csr_read_data_valid_o
);
    // Supported CSR's & Driving Buses.
    // M-Mode Registers.
    // Machine Trap Setup.
    mstatus_t       mstatus_r,      mstatus_w,      mstatus_reset_w;
    misa_t          misa_r,         misa_w,         misa_reset_w;
    mie_t           mie_r,          mie_w,          mie_reset_w;
    mtvec_t         mtvec_r,        mtvec_w,        mtvec_reset_w;
    mcounteren_t    mcounteren_r,   mcounteren_w,   mcounteren_reset_w;

    // Machine Trap Handling.
    mscratch_t      mscratch_r,     mscratch_w,     mscratch_reset_w;
    mepc_t          mepc_r,         mepc_w,         mepc_reset_w;
    mcause_t        mcause_r,       mcause_w,       mcause_reset_w;
    mtval_t         mtval_r,        mtval_w,        mtval_reset_w;
    mip_t           mip_r,          mip_w,          mip_reset_w;
    mtinst_t        mtinst_r,       mtinst_w,       mtinst_reset_w;
    mtval2_t        mtval2_r,       mtval2_w,       mtval2_reset_w;

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
    mie_t           mie_write_data_w        = mie_t'(csr_write_data_i);
    mtvec_t         mtvec_write_data_w      = mtvec_t'(csr_write_data_i);
    mcounteren_t    mcounteren_write_data   = mcounteren_t'(csr_write_data_i[31:0]);

    // Machine Trap Handling.
    mscratch_t      mscratch_write_data     = mscratch_t'(csr_write_data_i);
    mepc_t          mepc_write_data         = mepc_t'(csr_exception_pc_i);
    mcause_t        mcause_write_data       = mcause_t'(csr_exception_cause_i);

    // Drive Reset Buses.
    // M-Mode Registers.
    // Machine Trap Setup.
    assign mstatus_reset_w      = '0;
    assign misa_reset_w         = misa_w;
    assign mie_reset_w          = '0;

    assign mtvec_reset_w.base   = {2'b0, BOOT_ADDRESS};
    assign mtvec_reset_w.mode   = DIRECT;

    assign mcounteren_reset_w   = '0;

    // Machine Trap Handling.
    assign mscratch_reset_w     = '0;
    assign mepc_reset_w         = '0;
    assign mcause_reset_w       = '0;
    assign mtval_reset_w        = '0;
    assign mip_reset_w          = '0;
    assign mtinst_reset_w       = '0;
    assign mtval2_reset_w       = '0;

    // Internal Signals Update.
    // Note: For the mean time, we'll only support this mode.
    assign privilege_level_w = MACHINE;

    // Control Signals Update.
    assign csr_address_exists_w         = (csr_address_i inside {CSR_MSTATUS, CSR_MISA, CSR_MEDELEG, CSR_MIDELEG, CSR_MIE, CSR_MTVEC, CSR_MCOUNTEREN, CSR_MSTATUSH, CSR_MEDELEGH, CSR_MSCRATCH, CSR_MEPC, CSR_MCAUSE, CSR_MTVAL, CSR_MIP, CSR_MTINST, CSR_MTVAL2}) ? 1'b1 : 1'b0;
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
                CSR_MSTATUS:    csr_read_data_o = mstatus_r;
                CSR_MISA:       csr_read_data_o = misa_r;
                CSR_MIE:        csr_read_data_o = mie_r;
                CSR_MTVEC:      csr_read_data_o = mtvec_r;
                CSR_MCOUNTEREN: csr_read_data_o = mcounteren_r;
                
                // Machine Trap Handling.
                CSR_MSCRATCH:   csr_read_data_o = mscratch_r;
                CSR_MEPC:       csr_read_data_o = mepc_r;
                CSR_MCAUSE:     csr_read_data_o = mcause_r;
                CSR_MTVAL:      csr_read_data_o = mtval_r;
                CSR_MIP:        csr_read_data_o = mip_r;
                CSR_MTINST:     csr_read_data_o = mtinst_r;
                CSR_MTVAL2:     csr_read_data_o = mtval2_r;

                default:        csr_read_data_o = '0;
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
            end

    // CSR Update Loops.
    // Machine Trap Setup.
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
    always_comb
        begin   : mscratch_update
            if (csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MSCRATCH)
                mscratch_w = mscratch_write_data;

            else
                mscratch_w = mscratch_r;
        end     : mscratch_update

    always_comb
        begin   : mepc_update
            // Note: Should I Check csr_write_enable?
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MEPC)
                mepc_w = {mepc_write_data[63:1], 1'b0};

            else
                mepc_w = mepc_r;
        end     : mepc_update

    always_comb
        begin   : mcause_update
            // Note: Should I Check csr_write_enable?
            if (csr_exception_i && csr_write_enable_w && csr_allocation_t'(csr_address_i) == CSR_MCAUSE)
                mcause_w = mcause_write_data;

            else
                mcause_w = mcause_r;
        end     : mcause_update

endmodule