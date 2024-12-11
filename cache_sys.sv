module cache_sys #(parameter MEM_WIDTH = 32, MEM_DEPTH = 1024, CACHE_BLOCK = 16*8, CACHE_SIZE = 512) (
    input  logic clk, rstn, memWr, memRd,
    input  logic [($clog2(MEM_DEPTH)-1):0] addr,
    input  logic [(MEM_WIDTH-1):0] w_data,
    output logic stall,
    output logic [(MEM_WIDTH-1):0] r_data
);  
    // Parameters
    localparam CACHE_DEPTH = CACHE_SIZE / CACHE_BLOCK * 8;
    localparam ADDR        = $clog2(MEM_DEPTH);
    localparam INDEX_S     = $clog2(CACHE_DEPTH);
    localparam TAG         = ADDR - INDEX_S - 2;

    // Internal signals
    logic cache_wen, cache_w_type, mm_ren, cache_status;
    logic [(CACHE_BLOCK-1):0] r_block_m;

    // Cache Control
    cache_ctrl CACHE_CONTROL (.clk(clk), .rstn(rstn), .memWr(memWr), .memRd(memRd), .cache_status(cache_status),
     .cache_wen(cache_wen), .mm_ren(mm_ren), .cache_w_type(cache_w_type), .stall(stall));

    // Cache MEM
    cache_mem #(.DEPTH(CACHE_DEPTH), .INDEX_S(INDEX_S), .TAG(TAG), .BLOCK(CACHE_BLOCK), .ADDR(ADDR),
     .MEM_WIDTH(MEM_WIDTH)) CACHE_MEM (.clk(clk), .rstn(rstn), .wen(cache_wen), .w_type(cache_w_type), 
     .addr(addr), .w_data(w_data), .w_block(r_block_m), .r_data(r_data), .status(cache_status));
 
    // Main memory 
    main_mem #(.WIDTH(MEM_WIDTH), .DEPTH(MEM_DEPTH), .CACHE_BLOCK(CACHE_BLOCK)) MAIN_MEM (.clk(clk), 
     .rstn(rstn), .wen(memWr), .ren(mm_ren), .addr(addr), .w_data(w_data), .r_block(r_block_m));
endmodule