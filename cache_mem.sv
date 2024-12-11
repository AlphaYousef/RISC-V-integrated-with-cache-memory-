module cache_mem #(parameter DEPTH = 32, INDEX_S = 5, TAG = 3, BLOCK = 16*8, ADDR = 10, MEM_WIDTH = 32) (
    input  logic clk, rstn, wen, w_type,
    input  logic [(ADDR-1):0] addr, // Word address
    input  logic [(MEM_WIDTH-1):0] w_data,
    input  logic [(BLOCK-1):0] w_block, 
    output logic [(MEM_WIDTH-1):0] r_data,
    output logic status
);
    logic [(BLOCK-1):0] cache [0:((2**INDEX_S)-1)];
    logic [((2**INDEX_S)-1):0] valid_arr;
    logic [(TAG-1):0] tag_arr [0:((2**INDEX_S)-1)];
    logic [(INDEX_S-1):0] index;
    logic [(TAG-1):0] tag;
    logic [(BLOCK-1):0] r_block, w_block_d;
    logic tag_status;

    assign index = addr[(ADDR-INDEX_S+1):2];
    assign tag   = addr[(ADDR-1):(ADDR-TAG)];

    // w_block_d >> W_BLOCK in case of write && hit
    always @(*) begin
        if (w_type)
            case (addr[1:0])
                2'b00:      w_block_d = {r_block[((4*MEM_WIDTH)-1):MEM_WIDTH], w_data};
                2'b01:      w_block_d = {r_block[((4*MEM_WIDTH)-1):(2*MEM_WIDTH)], w_data, r_block[(MEM_WIDTH-1):0]};
                2'b10:      w_block_d = {r_block[((4*MEM_WIDTH)-1):(3*MEM_WIDTH)], w_data, r_block[((2*MEM_WIDTH)-1):0]};
                2'b11:      w_block_d = {w_data, r_block[((3*MEM_WIDTH)-1):0]};
                default:    w_block_d = 0;
            endcase
        else 
            w_block_d = 0;
    end

    // Valid Array
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            valid_arr <= 0;
        else if (wen)
            valid_arr[index] <= 1;
    end

    // Tag array
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            for (int i = 0; i < (2**INDEX_S); i++) 
                tag_arr[i] <= 0;
        else if (wen)
            tag_arr[index] <= tag;
    end

    // Write 
    always @(posedge clk) begin
        if (rstn && wen)
            if (w_type)
                cache[index] <= w_block_d;
            else
                cache[index] <= w_block;
    end

    // Read
    assign r_block = cache[index];

    // Status >> 1 for hit, 0 for miss
    assign tag_status = (tag == tag_arr[index]);
    assign status     = (tag_status & valid_arr[index]);

    // read data
    always @(*) begin
        if (status)
            case (addr[1:0])
                2'b00:      r_data = r_block[(MEM_WIDTH-1):0];
                2'b01:      r_data = r_block[((2*MEM_WIDTH)-1):MEM_WIDTH];
                2'b10:      r_data = r_block[((3*MEM_WIDTH)-1):(2*MEM_WIDTH)];
                2'b11:      r_data = r_block[((4*MEM_WIDTH)-1):(3*MEM_WIDTH)];
                default:    r_data = 0;
            endcase
        else 
            r_data = 0;
    end
endmodule