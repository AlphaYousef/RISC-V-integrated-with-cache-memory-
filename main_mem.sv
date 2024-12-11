module main_mem #(parameter WIDTH = 32, DEPTH = 1024, CACHE_BLOCK = 16*8) (
    input  logic clk, rstn, wen, ren,
    input  logic [($clog2(DEPTH)-1):0] addr,    // Word address
    input  logic [(WIDTH-1):0] w_data,
    output logic [(CACHE_BLOCK-1):0] r_block
);
    logic [(WIDTH-1):0] mem [0:(DEPTH-1)];           // Word Addressable 
    logic [($clog2(DEPTH/4)-1):0] int_addr;

    assign int_addr = {addr[($clog2(DEPTH)-1):2], 2'b00}; 

    // Write
    always @(posedge clk) begin
        if (rstn && wen) 
            mem[addr] <= repeat(4) @(posedge clk) w_data;
    end
    
    // Read
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            r_block <= 0;
        else if (ren) 
            r_block <= repeat(4) @(posedge clk) {mem[int_addr+3], mem[int_addr+2], mem[int_addr+1], mem[int_addr]}; 
    end
endmodule