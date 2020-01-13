module alu
#(
    parameter N = 32,
    parameter Q = 16
)
(
    input  logic clk,
    input  logic rstn,

    input  logic enable_alu,
    input  logic [3:0] opcode,
    input  logic signed [N-1:0] dataA,
    input  logic signed [N-1:0] dataB,
    input  logic signed [N-1:0] data_imm,

    output logic valid,
    output logic zero,
    output logic [N-1:0] data_out
);
logic [1:0]        enable_unit;
logic [1:0][N-1:0] data_unit;
logic [1:0]        valid_unit;
logic both_image;
logic [2*N-1:0] out_C;

assign zero = (data_out == 0) ? 1'b1 : 1'b0;

always_comb
    if(enable_alu)
        case (opcode[3:0])
            4'b0101 : begin
                        enable_unit = 2'b01;
                        data_out    = data_unit [0];
                        valid_unit  = valid_unit[0];
                      end
            4'b0111 : begin
                        enable_unit = 2'b01;
                        data_out    = data_unit [0];
                        valid_unit  = valid_unit[0];
                      end   
            4'b0110 : begin
                        enable_unit = 2'b10;
                        data_out    = data_unit [1];
                        valid       = valid_unit[1];   
                      end
            4'b1000 : begin
                        enable_unit = 2'b10;
                        data_out    = data_unit [1];
                        valid       = valid_unit[1];   
                      end
            4'b0000 : begin
                        enable_unit = 2'b00;
                        data_out    = dataA + dataB;
                        valid       = 1'b1;
                      end
            4'b0001 : begin
                        enable_unit = 2'b00;
                        data_out    = dataA + data_imm;
                        valid       = 1'b1;
                      end
            4'b0010 : begin
                        enable_unit = 2'b00;
                        data_out    = dataA & dataB;
                        valid       = 1'b1;
                      end
            4'b0011 : begin
                        enable_unit = 2'b00;
                        data_out    = dataA | dataB;
                        valid       = 1'b1;
                      end
            default: begin
                        enable_unit = 2'b00;
                        data_out    = 0;
                        valid       = 0;
                     end
        endcase
    else begin
        enable_unit = 2'b00;
        data_out    = 0;
        valid       = 0;
    end


always_comb
    if(opcode == 4'b0111 || opcode == 4'b1000)
        both_image = 1'b1;
    else
        both_image = 1'b0;

multiply_image
    #(
        .A_WIDTH    (N),
        .B_WIDTH    (N)
    )
multiply_image_i1
    (
        .clk        (clk),
        .resetn     (rstn),
        .in_valid   (enable_unit[0]),
        .both_image (both_image),
        .in_A       (dataA),
        .in_B       (dataB),
        .out_C      (out_C),
        .out_valid  (valid_unit[0])
    );
assign data_unit[0] = out_C[N + (N - Q) - 1 : N - Q];


div_sign
    #(
        .Q                  (Q),
        .N                  (N)
    )
div_sign_i1 
    (
        .i_clk              (clk),
        .i_rstn             (rstn),
        .both_image         (both_image),
        .i_start            (enable_unit[1]),
        .i_dividend_sign    (dataA),
        .i_divisor_sign     (dataB),
        .o_complete         (valid_unit[1]),
        .o_quotient_sign    (data_unit[1]),
        .o_overflow         ()
    );



endmodule 