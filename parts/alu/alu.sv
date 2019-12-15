module alu
#(
    parameter N = 32,
    parameter Q = 16
)
(
    input  logic clk,
    input  logic rstn,

    input  logic enable_alu,
    input  logic [2:0] instr,
    input  logic signed [N-1:0] dataA,
    input  logic signed [N-1:0] dataB,

    output logic valid,
    output logic [N-1:0] data_out
);
logic [1:0]        enable_unit;
logic [1:0][N-1:0] data_unit;
logic [1:0]        valid_unit;
logic both_image;
logic [2*N-1:0] out_C;
always_comb
    if(enable_alu)
        case (instr)
            3'b00z : begin
                        enable_unit = 2'b01;
                        data_out    = data_unit [0];
                        valid_unit  = valid_unit[0];
                     end  
            3'b01z : begin
                        enable_unit = 2'b10;
                        data_out    = data_unit [1];
                        valid       = valid_unit[1];   
                     end
            3'b10z : begin
                        enable_unit = 2'b00;
                        data_out    = dataA + dataB;
                        valid       = 1'b1;
                     end
            default: begin
                        enable_unit = 2'b00;
                        data_out    = 0;
                        valid       = 0;
                     end
        endcase

assign both_image = instr[0];

multiply_image
    #(
        .A_WIDTH    (N),
        .B_WIDTH    (N),
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
    )



endmodule 