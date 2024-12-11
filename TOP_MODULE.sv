module TOP_MODULE (
    input clk, rstn, WE,
    input [31:0] WD,
    output [31:0] test_mem,
    output [127:0] test_cache
);
    // Internal Signals
    logic memWrite, memRead, aluSrcB, regWrite, zero, mem_stall;
    logic [2:0] funct3, immSrc, load;
    logic [3:0] ALU_control;
    logic [1:0] OP_f7, resultSrc, aluSrcA, PCSrc, store;
    logic [31:0] instr, mem_RD, aluResult, PC, mem_WD;
    logic [6:0] opcode;

    // INSTR
    assign opcode  = instr[6:0];
    assign funct3  = instr [14:12];
    assign OP_f7   = {opcode[5], instr[30]};
   
    // Data Path
    data_path DATA_PATH (.clk(clk), .rstn(rstn), .mem_stall(mem_stall), .PCSrc(PCSrc), .resultSrc(resultSrc), .memWrite(memWrite),
     .aluSrcA(aluSrcA), .aluSrcB(aluSrcB), .regWrite(regWrite), .aluControl(ALU_control), .immSrc(immSrc), 
     .instr(instr), .load(load), .store(store), .mem_RD(mem_RD), .aluResult(aluResult), .PC(PC), 
     .mem_WD(mem_WD), .zero(zero));

    // Control Unit
    control_unit CONTROL_UNIT (.opcode(opcode), .funct3(funct3), .OP_f7(OP_f7), .zero(zero), .PC_src(PCSrc), 
     .resultSrc(resultSrc), .memWrite(memWrite), .memRead(memRead), .aluSrcA(aluSrcA), .aluSrcB(aluSrcB), 
     .regWrite(regWrite), .immSrc(immSrc), .load(load), .store(store), .ALU_control(ALU_control));

    // Instruction Memory
    instr_mem #(.DATA(32), .ADDR(32), .MEM_DEPTH(256)) INSTR_MEM (.clk(clk), .WE(WE), .WD(WD), .PC(PC), .RD(instr));

    // Data Memory
    cache_sys #(.MEM_WIDTH(32), .MEM_DEPTH(1024), .CACHE_BLOCK(16*8), .CACHE_SIZE(512)) D_MEM (.clk(clk), 
     .rstn(rstn), .memWr(memWrite), .memRd(memRead), .addr(aluResult[9:0]), .w_data(mem_WD), .stall(mem_stall),
     .r_data(mem_RD));

    // test
    assign test_mem   = D_MEM.MAIN_MEM.mem[0];
    assign test_cache = D_MEM.CACHE_MEM.cache[0];
endmodule