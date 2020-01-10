module core 
#(
    parameter MEM_WA       = 8,
    parameter INSTR_MEM_WA = 8,
    parameter WIDTH_VECTOR = 8, // have to be 2**N
    parameter N            = 32,
    parameter WA_RF        = 8
)
(
    input logic clk,
    input logic rstn,

    input logic clkf,
    input logic rstnf,

    input logic we,
    input logic [WIDTH_VECTOR-1:0][N-1:0] wdata
);
localparam WIDTH_INSTR = 3 + 1 + 2*WA_RF + WIDTH_VECTOR;

logic next_instr;
logic [WIDTH_INSTR-1:0] instr_fet;
logic jump_com, jump_exe, jump_mem, jump_com_dec, jump_exe_t1;
logic we_jump, we_jump_exe, we_jump_mem;
logic [N-1:0] addr_instr_exe, addr_instr_mem;

logic [WA_RF-1:0] addr_rega, addr_rega_dec, addr_rega_exe, addr_rega_mem;
logic [WA_RF-1:0] addr_regb;
logic [2:0] com, com_dec;
logic we_mem, we_mem_dec, we_mem_exe;
logic mem_alu, mem_alu_dec, mem_alu_exe, mem_alu_mem;
logic [WIDTH_VECTOR-1:0][N-1:0] dataA, dataB;

logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a_rf, rdata_b_rf;
logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a_rf_dec, rdata_b_rf_dec;
logic [WIDTH_VECTOR-1:0] we_rf, we_rf_dec, we_rf_mem, we_rf_exe, enable_alu;
logic [WIDTH_VECTOR-1:0][N-1:0] wdata_rf, wdata_rf_mem;

logic zero;
logic valid;
logic [WIDTH_VECTOR-1:0][N-1:0] data_alu, data_alu_exe, data_alu_mem;
logic [WIDTH_VECTOR-1:0][N-1:0] data_mem;
// fetch
instr_mem
    #(
        .WIDTH_INSTR    (WIDTH_INSTR),
        .WIDTH_ADDR     (INSTR_MEM_WA)
    )
instr_mem
    (
        .rstn           (rstn),
        .clk            (clk),

        .inc            (next_instr),
        .rdata          (instr_fet),

        .jump           (jump_mem),
        .we_jump        (we_jump_mem),
        .data_jump      (addr_instr_mem)
    );

// decode
controller
    #(
        .WIDTH_INSTR    (WIDTH_INSTR),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .WA_RF          (WA_RF)
    )
controller
    (
        .instr          (instr_fet),
        .addr_rega      (addr_rega),
        .addr_regb      (addr_regb),
        .com            (com)

        .valid          (valid),
        .next_instr     (next_instr),

        .we_rf          (we_rf),

        .we_mem         (we_mem),

        .mem_alu        (mem_alu),

        .jump_com       (jump_com),
    );


reg_file 
    #(
        .WIDTH_ADDR     (WA_RF),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .N              (N),
        .VENDOR         ("xilinx")
    )
reg_file
    (
        .clk            (clk),
        
        .addra          (addr_rega),
        .addrb          (addr_regb),
        .rdata_a        (rdata_a_rf),
        .rdata_b        (rdata_b_rf),

        .wec            (we_rf_mem),
        .addrc          (addr_rega_mem),
        .wdata_c        (wdata_rf_mem)
    );

always_ff @(negedge rstn, posedge clk)
    if(~rstn)
        jump_exe_t1 <= 0;
    else 
        jump_exe_t1 <= jump_exe; 

always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        rdata_a_rf_dec <= 0;
        rdata_b_rf_dec <= 0;
        com_dec        <= 0;
        we_rf_dec      <= 0;
        we_mem_dec     <= 0;
        mem_alu_dec    <= 0;
        addr_rega_dec  <= 0;
        jump_com_dec   <= 0;      
    end
    else if(jump_exe || jump_exe_t1) begin
        rdata_a_rf_dec <= 0;
        rdata_b_rf_dec <= 0;
        com_dec        <= 0;
        we_rf_dec      <= 0;
        we_mem_dec     <= 0;
        mem_alu_dec    <= 0;
        addr_rega_dec  <= 0;
        jump_com_dec   <= 0;      
    end
    else begin
        rdata_a_rf_dec <= rdata_a_rf;
        rdata_b_rf_dec <= rdata_b_rf;
        com_dec        <= com;
        we_rf_dec      <= we_rf;
        we_mem_dec     <= we_mem;
        mem_alu_dec    <= mem_alu;
        addr_rega_dec  <= addr_rega;
        jump_com_dec   <= jump_com;
    end
// execute
always_comb
    if(we_rf_mem && addr_rega_mem == addr_rega_dec)
        dataA = wdata_rf_mem;
    else if(we_rf_mem && addr_rega_exe == addr_rega_dec)
        dataA = data_alu_exe;
    else 
        dataA = rdata_a_rf_dec;

always_comb
    if(we_rf_mem && addr_rega_mem == addr_regb_dec)
        dataB = wdata_rf_mem;
    else if(we_rf_mem && addr_rega_exe == addr_regb_dec)
        dataA = data_alu_exe;
    else 
        dataB = rdata_b_rf_dec;

assign enable_alu = (mem_alu_exe && addr_rega_exe == addr_rega_dec) ?
                                0 : we_rf_dec;

execute
    #(
        .N              (N),
        .Q              (Q),
        .ALU_NUM        (WIDTH_VECTOR)
    )
execute
    (
        .clk            (clk),
        .rstn           (rstn),

        .enable_alu     (we_rf_dec),
        .instr          (com_dec),
        .dataA          (dataA),
        .dataB          (dataB),

        .valid          (valid),
        .zero           (zero),
        .data_out       (data_alu)
    );

always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        addr_instr_exe <= 0;
        data_alu_exe   <= 0;
        we_mem_exe     <= 0;
        mem_alu_exe    <= 0;
        we_rf_exe      <= 0;
        addr_rega_exe  <= 0;
        jump_exe       <= 0;
        we_jump_exe    <= 0;   
    end
    else if(jump_exe || (mem_alu_exe && addr_rega_exe == addr_rega_dec)) begin
        addr_instr_exe <= 0;
        data_alu_exe   <= 0;
        we_mem_exe     <= 0;
        mem_alu_exe    <= 0;
        we_rf_exe      <= 0;
        addr_rega_exe  <= 0;
        jump_exe       <= 0;
        we_jump_exe    <= 0;   
    end
    else if(valid) begin
        addr_instr_exe <= rdata_a_rf_dec[0][N-1:0];
        data_alu_exe   <= data_alu;
        we_mem_exe     <= we_mem_dec;
        mem_alu_exe    <= mem_alu_dec;
        we_rf_exe      <= we_rf_dec;
        addr_rega_exe  <= addr_rega_dec;
        jump_exe       <= jump_com_dec && zero && (com_dec == 3'b100);
        we_jump_exe    <= jump_com_dec && (com_dec == 3'b101);
    end
// memory
simple_ram_vivado 
    #(
        .DSIZE          (WIDTH_VECTOR*N),
        .ASIZE          (MEM_WA),
        .INIT_FILE      ("")
    )
simple_ram_vivado
    (
        .addra          (addr_instr_exe),
        .dinc           (data_alu_exe),
        .clk            (clk),
        .wec            (we_mem_exe),
        .ena            (1'b1),
        .douta          (data_mem)
    )

always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        mem_alu_mem    <= 0;
        data_alu_mem   <= 0;
        we_rf_mem      <= 0;
        addr_rega_mem  <= 0;
        jump_mem       <= 0;
        we_jump_mem    <= 0;
        addr_instr_mem <= 0;
    end
    else begin
        mem_alu_mem    <= mem_alu_exe;
        data_alu_mem   <= data_alu_exe;
        we_rf_mem      <= we_rf_exe;
        addr_rega_mem  <= addr_rega_exe;
        jump_mem       <= jump_exe;
        we_jump_mem    <= we_jump_exe;
        addr_instr_mem <= addr_instr_exe; 
    end
//writeback
assign wdata_rf_mem = (mem_alu_mem) ? data_mem : data_alu_mem;

endmodule 