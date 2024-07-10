import riscv_pkg            :: * ;
import riscv_privileged_pkg :: * ;

module lagarto_exception_handler
(
    input   logic                   clock_i,
    input   logic                   reset_ni,

    input   logic [XLEN - 1:0]      program_counter_i,
    input   logic                   instruction_retired_i,
    input   logic                   returned_from_trap_handler_i,

    input   logic [1:0]             csr_command_i,
    input   logic [MXLEN - 1:0]     csr_write_data_i,

    output  logic [MXLEN - 1:0]     csr_read_data_o,
    output  logic                   csr_read_data_valid_o

    output  logic                   flush_pipeline_o,

);

    typedef enum logic
    {
        RESET,
        IDLE,
        WAIT_FOR_RETIRE,
        PROCESS_TRAP,
        WAIT_FOR_TRAP_HANDLER,
        READ_CSR,
        MODIFY_CSR
    } state_t;

endmodule