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

generate
    if(VENDOR == "xilinx")begin
        sdpRAM_vivado 
            #(
                .DSIZE      (WIDTH_VECTOR*N),
                .ASIZE      (WIDTH_ADDR),
                .INIT_FILE  ("")
            )
        sdpRAM_vivado
            (
                .addra      (addr),
                .addrb      (addr),
                .dina       (wdata),
                .clka       (clk),
                .wea        (we),
                .enb        (~we),
                .doutb      (rdata)
            )
    end
endgenerate

endmodule