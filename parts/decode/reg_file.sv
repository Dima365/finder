module reg_file 
#(
    parameter WIDTH_ADDR   = 4,
    parameter WIDTH_VECTOR = 8,
    parameter N = 32
)
(
    input  logic clk,    // Clock

    input  logic we,
    input  logic [WIDTH_ADDR-1:0] addr,
    input  logic [WIDTH_VECTOR-1:0][N-1:0] wdata,

    output logic [WIDTH_VECTOR-1:0][N-1:0] rdata
);

ram_module 
    #(
        .WA     (WIDTH_ADDR),
        .WD     (WIDTH_VECTOR*N)
    )
ram_module_i1
    (
        .clk       (clk),
        .we        (we),
        .addr      (addr),
        .wdata     (wdata),
        .rdata     (rdata)
    );


endmodule

module ram_module 
#(
    parameter WA = 16,
    parameter WD = 32
)
(
    input logic clk,    // Clock

    input  logic we,
    input  logic [WA-1:0] addr,
    input  logic [WD-1:0] wdata,

    output logic [WD-1:0] rdata    
);
logic [WD-1:0] ram [2**WA-1:0];

always_ff @(negedge rstn, posedge clk)
    if(we) begin 
        ram[addr] <= wdata;
    end

assign rdata = ram[addr];

endmodule

