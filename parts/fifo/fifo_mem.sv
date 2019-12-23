module fifo_mem
#( 
    parameter DSIZE  = 8,
    parameter ASIZE  = 4,
    parameter VENDOR = "xilinx" 
)
(
    input  logic wclk,
    input  logic wfull,
    input  logic wclken,
    input  logic [ASIZE-1:0]  waddr,
    input  logic [DSIZE-1:0]  wdata,
    input  logic [ASIZE-1:0]  raddr,
    output logic [DSIZE-1:0]  rdata,
);
logic wea;
assign wea = wclken && ~wfull;

generate
    if(VENDOR == "xilinx")begin
        sdpRAM_vivado 
            #(
                .DSIZE      (DSIZE),
                .ASIZE      (ASIZE),
                .INIT_FILE  ("")
            )
        sdpRAM_vivado
            (
                .addra      (waddr),
                .addrb      (raddr),
                .dina       (wdata),
                .clka       (wclk),
                .wea        (wea),
                .enb        (1'b1),
                .doutb      (rdata)
            )
    end
endgenerate


endmodule