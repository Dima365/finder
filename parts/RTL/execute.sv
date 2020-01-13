module execute
#(
    parameter N = 32,
    parameter Q = 16,
    parameter ALU_NUM = 24
)
(
    input  logic clk,
    input  logic rstn,

    input  logic [ALU_NUM-1:0] enable_alu,
    input  logic [3:0] opcode,
    input  logic signed [ALU_NUM-1:0][N-1:0] dataA,
    input  logic signed [ALU_NUM-1:0][N-1:0] dataB,
    input  logic signed [ALU_NUM-1:0] data_imm

    output logic valid,
    output logic zero,
    output logic signed [ALU_NUM-1:0][N-1:0] data_out
);
logic [ALU_NUM-1:0] valid_alu;
logic signed [ALU_NUM-1:0][N-1:0] data_out_alu;
logic [ALU_NUM-1:0] zero_alu;
logic signed [ALU_NUM-1:0][N-1:0] data_out_inside;

assign zero  = (enable_alu == zero_alu)  ? 1'b1 : 1'b0;

always_comb
    if(opcode == 4'b0100)
        data_out = dataA << N*data_imm;
    else 
        data_out = data_out_inside

always_comb
    if(opcode == 4'b0100)
        valid = 1'b1;
    else if(enable_alu == valid_alu)
        valid = 1'b1;
    else 
        valid = 1'b0;

generate
    if(ALU_NUM < N)

    for(genvar i = 0; i < ALU_NUM; i++)begin
        assign data_out_inside[i] = (valid_alu[i]) ? 
                                        data_out_alu[i] : '0;
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
            .opcode     (opcode),
            .dataA      (dataA[i]),
            .dataB      (dataB[i]),
            .data_imm   (data_imm)

            .valid      (valid_alu[i]),
            .zero       (zero_alu[i]),
            .data_out   (data_out_alu[i])
        );
    end
    end
endgenerate




endmodule 