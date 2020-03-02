module test
#(
    parameter MEM_WA       = 8,
    parameter INSTR_MEM_WA = 8,
    parameter WIDTH_VECTOR = 16, // have to be 2**N
    parameter N            = 16, //have to N < WIDTH_VECTOR
    parameter Q            = 4, 
    parameter WA_RF        = 4,
    parameter WA_FIFO      = 6,
    parameter WIDTH_OPCODE = 4
)
();
logic clk;
logic rstn;

logic fifo_full;
logic [WIDTH_VECTOR-1:0][N-1:0] fifo_wdata;
logic fifo_winc;
logic fifo_wclk;
logic fifo_wrstn;
core
    #(
        .MEM_WA         (MEM_WA),
        .INSTR_MEM_WA   (INSTR_MEM_WA),
        .WIDTH_VECTOR   (WIDTH_VECTOR),
        .N              (N),
        .Q              (Q),
        .WA_RF          (WA_RF),
        .WA_FIFO        (WA_FIFO),
        .WIDTH_OPCODE   (WIDTH_OPCODE)
    )
core_i1
    (
        .*
    );

always
   #30 clk  = ~clk;

always 
   #44 fifo_wclk = ~fifo_wclk;

initial begin
    fifo_winc  = 0;
    fifo_wdata = 0;
    clk   = 0;
    fifo_wclk  = 0;
    rstn  = 1;
    fifo_wrstn = 1;
    #33      ;
    rstn  = 0;
    fifo_wrstn = 0;
    #44      ;
    rstn  = 1;
    fifo_wrstn = 1;
end

endmodule