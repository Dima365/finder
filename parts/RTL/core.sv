module core 
#(
    parameter MEM_WA       = 8,
    parameter INSTR_MEM_WA = 8,
    parameter WIDTH_VECTOR = 8, // have to be 2**N
    parameter N            = 32, //have to N < WIDTH_VECTOR
    parameter WA_RF        = 8,
    parameter WA_FIFO      = 8,
    parameter WIDTH_OPCODE = 4
)
(
    input  logic clk,
    input  logic rstn,

    input  logic clkf,
    input  logic rstnf,

    output logic fifo_full,
    input  logic [WIDTH_VECTOR-1:0][N-1:0] fifo_wdata,
    input  logic fifo_winc,
    input  logic fifo_wclk,
    input  logic fifo_wrstn
);
localparam WIDTH_INSTR = WIDTH_OPCODE + 2*WA_RF + WIDTH_VECTOR;
localparam WIDTH_JDATA = WIDTH_VECTOR + 2*WA_RF;
localparam WA_MEM_SIGN = WIDTH_VECTOR + WA_RF;

logic next_instr;
logic [WIDTH_INSTR-1:0] instr_dec;
logic jump;
logic [WIDTH_JDATA-1:0] jdata, jdata_exe, jdata_mem, jdata_wb;

logic [WA_RF-1:0] addr_rega, addr_rega_exe, addr_rega_mem, addr_rega_wb;
logic [WA_RF-1:0] addr_regb;
logic [WIDTH_OPCODE-1:0] opcode, opcode_dec, opcode_exe;
logic mem_we, mem_we_dec, mem_we_exe;
logic mem_alu, mem_alu_dec, mem_alu_exe, mem_alu_mem, mem_alu_wb;
logic [WIDTH_VECTOR-1:0][N-1:0] dataA, dataB;
logic [WA_MEM_SIGN-1:0] mem_addr, mem_addr_exe, mem_addr_mem;

logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a_rf_exe, rdata_b_rf_exe;
logic [WIDTH_VECTOR-1:0] we_rf, we_rf_mem, we_rf_exe; 
logic [WIDTH_VECTOR-1:0] enable_alu;
logic [WIDTH_VECTOR-1:0][N-1:0] wdata_rf_wb;

logic zero;
logic valid;
logic [WIDTH_VECTOR-1:0][N-1:0] data_alu, data_alu_mem, data_alu_wb;
logic [WIDTH_VECTOR-1:0][N-1:0] mem_data_mem;

logic [ALU_NUM-1:0] data_imm, data_imm_exe;
// fetch
instr_mem
    #(
        .WIDTH_INSTR    (WIDTH_INSTR),
        .WIDTH_ADDR     (INSTR_MEM_WA),
        .VENDOR         ("xilinx"),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .WIDTH_JDATA    (WIDTH_JDATA)
    )
instr_mem
    (
        .rstn           (rstn),
        .clk            (clk),

        .opcode         (opcode)

        .next_instr     (next_instr),
        .instr          (instr_dec),

        .jump           (jump),
        .jdata          (jdata_exe)
    );

// decode
controller
    #(
        .WIDTH_INSTR    (WIDTH_INSTR),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .WA_RF          (WA_RF),
        .WIDTH_OPCODE   (WIDTH_OPCODE),
        .WIDTH_JDATA    (WIDTH_JDATA),
        .WA_MEM_SIGN    (WA_MEM_SIGN)
    )
controller
    (
        .instr          (instr_dec),
        .valid          (valid),
        .opcode_exe     (opcode_exe),
        .zero           (zero),
        .exe_flush      (exe_flush),

        .opcode         (opcode),
        .addr_rega      (addr_rega),
        .addr_regb      (addr_regb),
        .next_instr     (next_instr),
        .jdata          (jdata),
        .we_rf          (we_rf),
        .data_imm       (data_imm),
        .mem_we         (mem_we),
        .mem_alu        (mem_alu),
        .jump           (jump),
        .mem_addr       (mem_addr)
    );


reg_file 
    #(
        .WIDTH_ADDR     (WA_RF),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .N              (N),
        .VENDOR         ("xilinx"),
        .WA_FIFO        (WA_FIFO),
        .WIDTH_OPCODE   (WIDTH_OPCODE)
    )
reg_file
    (
        .clk            (clk),
        .rstn           (rstn)
        
        .addra          (addr_rega),
        .addrb          (addr_regb),
        .rdata_a        (rdata_a_rf_exe),
        .rdata_b        (rdata_b_rf_exe),

        .wec            (we_rf_wb),
        .addrc          (addr_rega_wb),
        .wdata_c        (wdata_rf_wb),

        .fifo_full      (fifo_full),
        .fifo_empty     (fifo_empty),
        .fifo_wdata     (fifo_wdata),
        .fifo_winc      (fifo_winc),
        .fifo_wclk      (fifo_wclk),
        .fifo_wrstn     (fifo_wrstn)
    );

//execute
always_comb
    if( opcode     == 4'b1100 &&
        we_rf_exe  != 0       && 
        we_rf      != 0       && 
        (addr_rega_exe == addr_rega || addr_rega_exe == addr_regb))
            exe_flush = 1'b1;
    else 
            exe_flush = 1'b0;

always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        opcode_exe     <= 4'b1101;
        we_rf_exe      <= 0;
        mem_we_exe     <= 0;
        mem_alu_exe    <= 0;
        addr_rega_exe  <= 0;
        jdata_exe      <= 0;
        data_imm_exe   <= 0;
        mem_addr_exe   <= 0;
        addr_regb_exe  <= 0;      
    end
    else if(jump || exe_flush) begin
        opcode_exe     <= 4'b1101;
        we_rf_exe      <= 0;
        mem_we_exe     <= 0;
        mem_alu_exe    <= 0;
        addr_rega_exe  <= 0;
        jdata_exe      <= 0;
        data_imm_exe   <= 0;
        mem_addr_exe   <= 0;
        addr_regb_exe  <= 0;    
    end
    else if(next_instr) begin
        opcode_exe     <= opcode;
        we_rf_exe      <= we_rf;
        mem_we_exe     <= mem_we;
        mem_alu_exe    <= mem_alu;
        addr_rega_exe  <= addr_rega;
        jdata_exe      <= jdata;
        data_imm_exe   <= data_imm;
        mem_addr_exe   <= mem_addr;
        addr_regb_exe  <= addr_regb;
    end

always_comb
    if( we_rf_wb  != 0 && 
        we_rf_exe != 0 && 
        addr_rega_wb == addr_rega_exe)
            dataA = wdata_rf_wb;
    else 
            dataA = rdata_a_rf_exe;

always_comb
    if( we_rf_wb  != 0 && 
        we_rf_exe != 0 && 
        addr_rega_wb == addr_regb_exe)
            dataB = wdata_rf_wb;
    else 
            dataB = rdata_b_rf_exe;

always_comb
    if(opcode_exe != 4'b1011 && opcode_exe != 4'b1100)
        enable_alu = we_rf_exe;
    else 
        enable_alu = 0;

execute
    #(
        .N              (N),
        .Q              (Q),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .WIDTH_OPCODE   (WIDTH_OPCODE)
    )
execute
    (
        .clk            (clk),
        .rstn           (rstn),

        .enable_alu     (enable_alu),
        .opcode         (opcode_exe),
        .dataA          (dataA),
        .dataB          (dataB),
        .data_imm       (data_imm_exe),

        .valid          (valid),
        .zero           (zero),
        .data_out       (data_alu)
    );

// memory
always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        jdata_mem      <= 0;
        data_alu_mem   <= 0;
        mem_we_mem     <= 0;
        mem_alu_mem    <= 0;
        we_rf_mem      <= 0;
        addr_rega_mem  <= 0;
        jump_mem       <= 0;
        mem_addr_mem   <= 0;   
    end
    else if(next_instr) begin
        jdata_mem      <= jdata_exe;
        data_alu_mem   <= data_alu;
        mem_we_mem     <= mem_we_exe;
        mem_alu_mem    <= mem_alu_exe;
        we_rf_mem      <= we_rf_exe;
        addr_rega_mem  <= addr_rega_exe;
        jump_mem       <= jump_exe;
        mem_addr_mem   <= mem_addr_exe;
    end

simple_ram_vivado 
    #(
        .DSIZE          (WIDTH_VECTOR*N),
        .ASIZE          (MEM_WA),
        .INIT_FILE      ("")
    )
simple_ram_vivado
    (
        .addra          (mem_addr_mem),
        .dinc           (data_alu_mem),
        .clk            (clk),
        .wec            (mem_we_exe),
        .ena            (1'b1),
        .douta          (mem_data_mem)
    )

//writeback
always_ff @(negedge rstn, posedge clk)
    if(~rstn) begin
        mem_alu_wb    <= 0;
        data_alu_wb   <= 0;
        we_rf_wb      <= 0;
        addr_rega_wb  <= 0;
        jump_wb       <= 0;
        jdata_wb      <= 0;
    end
    else if(next_instr) begin
        mem_alu_wb    <= mem_alu_mem;
        data_alu_wb   <= data_alu_mem;
        we_rf_wb      <= we_rf_mem;
        addr_rega_wb  <= addr_rega_mem;
        jump_wb       <= jump_mem;
        jdata_wb      <= jdata_mem; 
    end

assign wdata_rf_wb = (mem_alu_wb) ? mem_data_mem : data_alu_wb;

endmodule 