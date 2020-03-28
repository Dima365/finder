module alu
#(
    parameter N = 32,
    parameter Q = 16,
    parameter WIDTH_OPCODE = 4
)
(
    input  logic clk,
    input  logic rstn,

    input  logic enable_alu,
    input  logic [WIDTH_OPCODE-1:0] opcode,
    input  logic signed [N-1:0]     dataA,
    input  logic signed [N-1:0]     dataB,
    input  logic signed [N-1:0]     data_imm,

    output logic valid,
    output logic zero,
    output logic [N-1:0] data_out
);
logic [1:0]        enable_unit;
logic [1:0][N-1:0] data_unit;
logic [1:0]        valid_unit;
logic [2*N-1:0] out_C;

assign zero = (data_out == 0) ? 1'b1 : 1'b0;

always_comb
    if(enable_alu)
        case (opcode)
            4'b0000:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA + dataB;
                        valid       = 1'b1;                        
                      end
            4'b0001:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA & dataB;
                        valid       = 1'b1;
                      end
            4'b0010:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA | dataB;
                        valid       = 1'b1;                        
                      end
            4'b0011:  begin
                        enable_unit = 2'b00;
                        data_out    = ~dataA;
                        valid       = 1'b1;                        
                      end
            4'b0100:  begin
                        enable_unit = 2'b01;
                        data_out    = data_unit [0];
                        valid       = valid_unit[0];
                      end
            4'b0101:  begin
                        enable_unit = 2'b10;
                        data_out    = data_unit [1];
                        valid       = valid_unit[1];   
                      end
            4'b0110:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA + data_imm;
                        valid       = 1'b1;
                      end
            4'b1001:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA + ~dataB + 1;
                        valid       = 1'b1;                        
                      end
            4'b1011:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA;
                        valid       = 1'b1;                        
                      end
            4'b1110:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA < dataB;
                        valid       = 1'b1;                        
                      end
            4'b1111:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA + ~dataB + 1;
                        valid       = 1'b1;                        
                      end
            4'b1011:  begin
                        enable_unit = 2'b00;
                        data_out    = dataA;
                        valid       = 1'b1;                        
                      end
            default : begin
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

multiply
    #(
        .A_WIDTH    (N),
        .B_WIDTH    (N)
    )
multiply
    (
        .clk        (clk),
        .resetn     (rstn),
        .in_valid   (enable_unit[0]),
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
        .i_start            (enable_unit[1]),
        .i_dividend_sign    (dataA),
        .i_divisor_sign     (dataB),
        .o_complete         (valid_unit[1]),
        .o_quotient_sign    (data_unit[1]),
        .o_overflow         ()
    );



endmodule 