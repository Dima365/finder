module multiply_image
#(
    parameter A_WIDTH = 6,
    parameter B_WIDTH = 6    
)
(
    input  logic clk, 
    input  logic resetn,
    input  logic in_valid,
    input  logic both_image, 
    input  logic signed [(A_WIDTH-1):0] in_A,
    input  logic signed [(B_WIDTH-1):0] in_B,
    output logic signed [(A_WIDTH+B_WIDTH-1):0] out_C,
    output logic out_valid     
);
logic [(A_WIDTH+B_WIDTH-1):0] C_inside;

assign out_C = (both_image) ? (~C_inside + 1) : C_inside;  

multiply
    #(
        .A_WIDTH    (A_WIDTH),
        .B_WIDTH    (B_WIDTH)
    )
multiply
    (
        .clk        (clk),
        .resetn     (resetn),
        .in_valid   (in_valid),
        .in_A       (in_A),
        .in_B       (in_B),
        .out_C      (C_inside),
        .out_valid  (out_valid)
    );

endmodule 