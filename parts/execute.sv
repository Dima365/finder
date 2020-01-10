module execute
#(
    parameter N = 32,
    parameter Q = 16,
    parameter ALU_NUM = 8
)
(
    input  logic clk,
    input  logic rstn,

    input  logic [ALU_NUM-1:0] enable_alu,
    input  logic [2:0] instr,
    input  logic signed [ALU_NUM-1:0][N-1:0] dataA,
    input  logic signed [ALU_NUM-1:0][N-1:0] dataB,

    output logic valid,
    output logic zero,
    output logic signed [ALU_NUM-1:0][N-1:0] data_out
);
logic [ALU_NUM-1:0] valid_alu;
logic signed [ALU_NUM-1:0][N-1:0] data_out_alu;
logic [ALU_NUM-1:0] zero_alu;

assign valid = (enable_alu == valid_alu) ? 1'b1 : 1'b0;
assign zero  = (enable_alu == zero_alu)  ? 1'b1 : 1'b0;

generate
    for(genvar i = 0; i < ALU_NUM; i++)begin
        assign data_out[i] = (valid_alu[i]) ? data_out_alu[i] : '0;
    alu 
        #(
            .N      (N),
            .Q      (Q)
        )
    alu_i
        (
            .clk        (clk),
            .rstn       (rstn),

            .enable_alu (enable_alu[i]),
            .instr      (instr),
            .dataA      (dataA[i]),
            .dataB      (dataB[i]),

            .valid      (valid_alu[i]),
            .zero       (zero_alu),
            .data_out   (data_out_alu[i]),
        );

    end
endgenerate




endmodule 