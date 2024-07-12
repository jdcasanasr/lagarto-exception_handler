typedef enum logic [2:0]
{
    RESET,
    IDLE,
    CSR_READ,
    CSR_MODIFY,
    WAIT_FOR_RETIRE,
    PROCESS_TRAP,
    WAIT_FOR_RETURN
} state_t;

module test
(
    input   logic clock_i,
    input   logic reset_ni,

    input   logic csr_access_request_i,
    input   logic trap_taken_i,

    input   logic retire_i,
    input   logic mret_i,

    output  logic flush_o
);

    state_t current_state_r, next_state_w;

    always_ff @ (posedge clock_i, negedge reset_ni)
        if (!reset_ni)
            current_state_r = RESET;
        else
            current_state_r = next_state_w;

    always_comb
        unique case (current_state_r)
            RESET:              next_state_w = IDLE;
            IDLE:
                if (csr_access_request_i)
                    next_state_w = CSR_READ;

                else if (trap_taken_i)
                    next_state_w = WAIT_FOR_RETIRE;
                else
                    next_state_w = IDLE;

            CSR_READ:           next_state_w = CSR_MODIFY;
            CSR_MODIFY:         next_state_w = IDLE;
            WAIT_FOR_RETIRE:    next_state_w = retire_i ? PROCESS_TRAP : WAIT_FOR_RETIRE;
            PROCESS_TRAP:       next_state_w = WAIT_FOR_RETURN;
            WAIT_FOR_RETURN:    next_state_w = mret_i ? IDLE : WAIT_FOR_RETURN;

            default:            next_state_w = IDLE;
        endcase

    always_comb
        unique case (current_state_r)
            RESET:              flush_o = 1'b0;
            IDLE:               flush_o = 1'b0;
            CSR_READ:           flush_o = 1'b0;
            CSR_MODIFY:         flush_o = 1'b0;
            WAIT_FOR_RETIRE:    flush_o = 1'b0;
            PROCESS_TRAP:       flush_o = 1'b1;
            WAIT_FOR_RETURN:    flush_o = 1'b0;

            default:            flush_o = 1'b0;
        endcase

endmodule