module cache_ctrl (
    input  logic clk, rstn, memWr, memRd, cache_status,
    output logic cache_wen, cache_w_type, mm_ren, stall
);  
    typedef enum bit [1:0] {IDLE, WRITE, READ} state_ctrl_e;
    state_ctrl_e cs, ns;
    logic [1:0] stall_cnt;
    logic cnt_en, mm_ready;

    // stall counter
    always @(negedge clk, negedge rstn) begin
        if (!rstn)
            stall_cnt <= 0;
        else if (cnt_en)
            stall_cnt <= stall_cnt + 1;
        else 
            stall_cnt <= 0;
    end

    // mm_ready
    always @(negedge clk, negedge rstn) begin
        if (!rstn)
            mm_ready <= 0;
        else
            mm_ready <= (stall_cnt == 3);
    end

    ///////////// Cnotrol FSM ///////////////
    // Current state logic
    always @(negedge clk, negedge rstn) begin
        if (!rstn)
            cs <= IDLE;
        else 
            cs <= ns;
    end

    // Next state logic
    always @(*) begin
        case (cs)
            IDLE:       
                if (memWr)
                    ns = WRITE;
                else if (memRd)
                    ns = READ;
            WRITE:
                if (mm_ready)
                    ns = IDLE;
                else
                    ns = WRITE;
            READ:
                if (cache_status)
                    ns = IDLE;
                else
                    ns = READ;
            default:    ns = IDLE;
        endcase
    end

    /////////// Control Signals ////////////
    assign cnt_en       = (cs == WRITE) || ((cs == READ) && (~cache_status));
    assign cache_wen    = ((cs == READ) && (~cache_status) && (mm_ready)) || cache_w_type;
    assign cache_w_type = ((cs == WRITE) && cache_status);
    assign mm_ren       = (memRd && (~cache_status));
    assign stall        = ((cs == READ) && (~cache_status)) || ((cs == WRITE) && (~mm_ready));
endmodule