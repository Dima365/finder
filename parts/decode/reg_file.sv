module reg_file 
#(
    parameter WIDTH_ADDR   = 4,
    parameter WIDTH_VECTOR = 8,
    parameter N = 32,
    parameter VENDOR = "xilinx"
)
(
    input  logic clk,    // Clock

    input  logic [WIDTH_ADDR-1:0] addra,
    input  logic [WIDTH_ADDR-1:0] addrb,
    output logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a
    output logic [WIDTH_VECTOR-1:0][N-1:0] rdata_b

    input  logic [WIDTH_VECTOR-1:0] wec,
    input  logic [WIDTH_ADDR-1:0]   addrc,
    input  logic [WIDTH_VECTOR-1:0][N-1:0] wdata_c
);

generate
    if(VENDOR == "xilinx")begin
        for(genvar i = 0; i < WIDTH_VECTOR; i++)begin
            RAM_vivado 
                #(
                    .DSIZE      (N),
                    .ASIZE      (WIDTH_ADDR),
                    .INIT_FILE  ("")
                )
            RAM_vivado
                (
                    .addra      (addra),
                    .addrb      (addrb),
                    .addrc      (addrc),
                    .dinc       (wdata_c[i]),
                    .clk        (clk),
                    .wec        (wec[i]),
                    .ena        (1'b1),
                    .enb        (1'b1),
                    .douta      (rdata_a[i]),
                    .doutb      (rdata_b[i])
                )
        end
    end
endgenerate

endmodule