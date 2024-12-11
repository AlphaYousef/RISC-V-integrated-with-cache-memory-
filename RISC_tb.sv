module RISC_tb ();
    logic clk, rstn;
    logic [31:0] test_mem;
    logic [127:0] test_cache;

    TOP_MODULE uut (.clk(clk), .rstn(rstn), .WE(1'b0), .WD(0), .test_mem(test_mem), .test_cache(test_cache));

    always 
        #1 clk = ~clk;

    initial begin
        clk = 1;    rstn = 0;

        $readmemh("Test_Program3.dat", uut.INSTR_MEM.I_MEM, 0, 7);
        $readmemh("mem_content.txt",   uut.D_MEM.MAIN_MEM.mem, 0, 1023);
        $readmemh("cache_content.txt", uut.D_MEM.CACHE_MEM.cache, 0, 31);

        @(negedge clk)  rstn = 1;

        repeat (100)  @(negedge clk);
        $stop;
    end
endmodule