module reg_file 
#(
    parameter WIDTH_ADDR   = 4,
    parameter WIDTH_VECTOR = 8,
    parameter N = 32,
    parameter VENDOR = "xilinx",
    parameter WA_FIFO = 8,
    parameter WIDTH_OPCODE = 4
)
(
    input  logic clk,    // Clock
    input  logic rstn,

    input  logic [WIDTH_OPCODE-1:0] opcode,

    input  logic [WIDTH_ADDR-1:0] addra,
    input  logic [WIDTH_ADDR-1:0] addrb,
    output logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a_rf,
    output logic [WIDTH_VECTOR-1:0][N-1:0] rdata_b_rf,

    input  logic [WIDTH_VECTOR-1:0] wec,
    input  logic [WIDTH_ADDR-1:0]   addrc,
    input  logic [WIDTH_VECTOR-1:0][N-1:0] wdata_c,

    output logic fifo_full,
    output logic fifo_empty,
    input  logic [WIDTH_VECTOR-1:0][N-1:0] fifo_wdata,
    input  logic fifo_winc,
    input  logic fifo_wclk,
    input  logic fifo_wrstn    
);
logic fifo_rinc, fifo_en_read;
logic [WIDTH_VECTOR-1:0][N-1:0] rdata_a,rdata_b, fifo_rdata;
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
                );
            assign rdata_a_rf[i] = (fifo_en_read) ? fifo_rdata[i] : rdata_a[i];
            assign rdata_b_rf[i] = (fifo_en_read) ? fifo_rdata[i] : rdata_b[i];
        end
    end
endgenerate

always_comb
    if(opcode >= 0 && opcode <= 5)
        fifo_rinc = (addra == 0) || (addrb == 0);
    else if(opcode > 5 && opcode <= 8)
        fifo_rinc = (addra == 0);
    else if(opcode == 4'b1001)
        fifo_rinc = (addra == 0) || (addrb == 0);
    else if(opcode == 4'b1010)
        fifo_rinc = 1'b0;
    else if(opcode == 4'b1011 || opcode == 4'b1100)
        fifo_rinc = (addra == 0);
    else if(opcode == 4'b1101)
        fifo_rinc = 1'b0;
    else
        fifo_rinc = 1'b0;

always_ff @(negedge rstn, posedge clk)
    if(rstn)
        fifo_en_read <= 0;
    else 
        fifo_en_read <= fifo_rinc;

fifo
    #(
        .DSIZE      (WIDTH_VECTOR*N),
        .ASIZE      (WA_FIFO)
    )
fifo
    (
        .rdata      (fifo_rdata),
        .wfull      (fifo_full),
        .rempty     (fifo_empty),
        .wdata      (fifo_wdata),
        .winc       (fifo_winc),
        .wclk       (fifo_wclk),
        .wrst_n     (fifo_wrstn),
        .rinc       (fifo_rinc),
        .rclk       (clk),
        .rrst_n     (rstn)
    );
endmodule