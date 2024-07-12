package lagarto_exception_handler_pkg;

    // Control FSM Definitions.
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

endpackage