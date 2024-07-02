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

    //input logic                             csr_exception_i,
    //input csr_exception_cause_t             csr_exception_cause_i,
    //input logic [XLEN - 1:0]                csr_exception_pc_i,

    // To Lagarto Hun Core.
    output logic [MXLEN - 1:0]              csr_read_data_o,
    output logic                            csr_read_data_valid_o
);
    // Supported CSR's & Driving Buses.
    // M-Mode Registers.
    // Machine Trap Setup.
    mstatus_t       mstatus_r,      mstatus_w;
    misa_t          misa_r,         misa_w;
    mie_t           mie_r,          mie_w;
    mtvec_t         mtvec_r,        mtvec_w;
    mcounteren_t    mcounteren_r,   mcounteren_w;

    // Machine Trap Handling.
    mscratch_t      mscratch_r,     mscratch_w;
    mepc_t          mepc_r,         mepc_w;
    mcause_t        mcause_r,       mcause_w;
    mtval_t         mtval_r,        mtval_w;
    mip_t           mip_r,          mip_w;
    mtinst_t        mtinst_r,       mtinst_w;
    mtval2_t        mtval2_r,       mtval2_w;

    // Internal Signals.
    privilege_level_t privilege_level_r, privilege_level_w;

    // Control Signals.
    logic csr_address_exists_w;
    logic csr_privilege_violation_w;

    logic csr_read_enable_w;
    logic csr_write_enable_w;

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
                // Machine Trap Setup.
                mstatus_r       = '0;
                misa_r          = '0;
                mie_r           = '0;
                mtvec_r         = '0;
                mcounteren_r    = '0;

                // Machine Trap Handling.
                mscratch_r      = '0;
                mepc_r          = '0;
                mcause_r        = '0;
                mtval_r         = '0;
                mip_r           = '0;
                mtinst_r        = '0;
                mtval2_r        = '0;
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
    always_comb
        begin   : misa_update
            misa_w.mxl          = XLEN_64;
            misa_w.zero         = '0;
            misa_w.extensions   = I;
        end     : misa_update

endmodule