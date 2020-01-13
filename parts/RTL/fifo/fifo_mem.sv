module fifo_mem
#( 
    parameter DSIZE  = 8,
    parameter ASIZE  = 4,
    parameter VENDOR = "xilinx" 
)
(
    input  logic wclk,
    input  logic rclk,
    input  logic wfull,
    input  logic rempty,
    input  logic wclken,
    input  logic rclken,
    input  logic [ASIZE-1:0]  waddr,
    input  logic [DSIZE-1:0]  wdata,
    input  logic [ASIZE-1:0]  raddr,
    output logic [DSIZE-1:0]  rdata,
);
logic wea, enb;
assign wea = wclken && ~wfull;
assign enb = rclken && ~rempty;
generate
    if(VENDOR == "xilinx")begin
        rams_tdp_rf_rf 
            #(
                .DSIZE      (DSIZE),
                .ASIZE      (ASIZE),
                .INIT_FILE  ("")
            )
        rams_tdp_rf_rf
            (
                .clka       (wclk),
                .clkb       (rclk),
                .ena        (1'b1),
                .enb        (enb),
                .wea        (wea),
                .web        (1'b0),
                .addra      (waddr),
                .addrb      (raddr),
                .dina       (wdata),
                .dinb       (0),
                .doa        (),
                .dob        (rdata)
            )
    end
endgenerate


endmodule