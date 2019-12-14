class float2fix
    #(parameter Q = 15, parameter N = 32);
    localparam WIDTH_HOLD_FIX = (N-Q) + 23;
    rand shortreal float;
    bit  [N-1:0]   fix;

    constraint float_c {
        float > (0 - 2**(N-1-Q));
        float < (2**(N-1-Q) - 1);
    }

    function void set_up(shortreal float);
        this.float = float; 
    endfunction : set_up

    function bit [N-1:0] getfix();
        bit [31:0] ieee754;
        bit [WIDTH_HOLD_FIX-1:0] hold_fix;
        
        ieee754  = $shortrealtobits(float);
        hold_fix = 0;
        hold_fix[23:0] = {1'b1, ieee754[22:0]};
//        $display("hold_fix = %b", hold_fix);
        if(ieee754[30:23] > 127)           
            hold_fix = hold_fix << (ieee754[30:23] - 127);
        else
            hold_fix = hold_fix >> (127 - ieee754[30:23]);

        fix[N-1:Q] = hold_fix[23+(N-Q)-1: 23];
        fix[Q-1:0] = hold_fix[22:22-Q+1];
/*        
        $display("float    = %f", float);
        $display("ieee754  = %b", ieee754);
        $display("hold_fix = %b", hold_fix);
        $display("fix      = %b", fix);
        if(ieee754[31])
            $display("fix = -%f", fix/2.0**Q);
        else 
            $display("fix =  %f", fix/2.0**Q);
*/
        if(ieee754[31])
            fix = ~fix + 1;
        return fix; 
    endfunction


    function void display();
        if(fix[31])
            $display("real = %f, fix = -%f", float, fix/2.0**Q);
        else
            $display("real = %f, fix =  %f", float, fix/2.0**Q);
    endfunction : display 
endclass : float2fix

module test
#(
    parameter Q = 15,
    parameter N = 32
)
();
logic         i_clk;
logic         i_rstn;

logic         both_image;// 0 not image

logic         i_start;
logic [N-1:0] i_dividend_sign;
logic [N-1:0] i_divisor_sign;

logic         o_complete;
logic [N-1:0] o_quotient_sign;
logic         o_overflow;

shortreal dividend_float, divisor_float;

float2fix #(Q, N) flt2fix;

function void display();
    if(o_quotient_sign[N-1])
        $display("quotient_float = %f, quotient_fix = -%f", 
                  dividend_float/divisor_float, (~o_quotient_sign + 1)/2.0**Q); 
    else
        $display("quotient_float = %f, quotient_fix = %f", 
                  dividend_float/divisor_float, o_quotient_sign/2.0**Q);       
endfunction : display

always 
    #10 i_clk = ~i_clk;

div_sign
    #(
        .Q      (Q),
        .N      (N)
    )
div_sign_i1
    (
        .i_dividend_sign  (i_dividend_sign),
        .i_divisor_sign   (i_divisor_sign),
        .*
    );


initial begin
    i_clk  = 0;
    i_rstn = 0;
    both_image = 0; 
    i_start    = 0;
    i_dividend_sign = 0;
    i_divisor_sign  = 0;

    #111 i_rstn = 1;

    flt2fix = new();

    flt2fix.set_up(6.5);        
    i_dividend_sign = flt2fix.getfix();
    dividend_float  = flt2fix.float;
    $display("flt2fix.getfix() = %b",flt2fix.getfix());
    flt2fix.display();

    flt2fix.set_up(2.3);
    i_divisor_sign = flt2fix.getfix();
    divisor_float  = flt2fix.float;
    flt2fix.display();

    repeat($urandom_range(0,10))
        @(posedge i_clk); #1;
    i_start = 1;
    @(posedge i_clk); #1;
    i_start = 0;
        
    wait(o_complete == 1'b1); #1;
    display();   

    repeat(10)begin
        assert(flt2fix.randomize());        
        i_dividend_sign = flt2fix.getfix();
        dividend_float  = flt2fix.float;
        flt2fix.display();

        assert(flt2fix.randomize()); 
        i_divisor_sign = flt2fix.getfix();
        divisor_float  = flt2fix.float;
        flt2fix.display();

        repeat($urandom_range(0,10))
            @(posedge i_clk); #1;
        i_start = 1;
        @(posedge i_clk); #1;
        i_start = 0;
        
        wait(o_complete == 1'b1); #1;
        display();
    end

    flt2fix = null;
end


endmodule