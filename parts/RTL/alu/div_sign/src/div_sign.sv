module div_sign 
#(
    parameter Q = 15,
    parameter N = 32
)
(
    input   logic         i_clk,
    input   logic         i_rstn,

    input   logic         both_image,// 0 not image

    input   logic         i_start,
    input   logic [N-1:0] i_dividend_sign,
    input   logic [N-1:0] i_divisor_sign,

    output  logic         o_complete,
    output  logic [N-1:0] o_quotient_sign,
    output  logic         o_overflow
);
logic [N-2:0] i_dividend, i_divisor, o_quotient_out;

always_comb
    if(i_dividend_sign[N-1])
        i_dividend = ~i_dividend_sign[N-2:0] + 1;
    else 
        i_dividend = i_dividend_sign[N-2:0];

always_comb
    if(i_divisor_sign[N-1])
        i_divisor = ~i_divisor_sign[N-2:0] + 1;
    else
        i_divisor = i_divisor_sign[N-2:0];

always_comb
    case (both_image)
        0:  if(i_dividend_sign[N-1] ^ i_divisor_sign[N-1])begin
                o_quotient_sign[N-2:0] = ~o_quotient_out + 1;
                o_quotient_sign[N-1]   = 1'b1;
            end
            else begin
                o_quotient_sign[N-2:0] = o_quotient_out;
                o_quotient_sign[N-1]   = 1'b0;
            end
        1:  if(i_dividend_sign[N-1] ^ i_divisor_sign[N-1])begin
                o_quotient_sign[N-2:0] = o_quotient_out;
                o_quotient_sign[N-1]   = 1'b0;
            end
            else begin
                o_quotient_sign[N-2:0] = ~o_quotient_out + 1;
                o_quotient_sign[N-1]   = 1'b1;                
            end
        default: o_quotient_sign = 0;
    endcase

qdiv
    #(
        .Q      (Q),
        .N      (N-1)
    )
qdiv_i1
    (
        .*
    );


endmodule