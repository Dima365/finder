module instr_mem
#(
    parameter WIDTH_INSTR = 8,
    parameter WIDTH_ADDR  = 8,
    parameter WIDTH_VECTOR = 8,
    parameter VENDOR = "xilinx"
)
(
    input  logic rstn,
    input  logic clk,

    input  logic inc,
    output logic [WIDTH_INSTR-1:0] rdata,

    input  logic jump,
    input  logic we_jump,
    input  logic [WIDTH_VECTOR-1:0] data_jump
);
logic [WIDTH_ADDR-1:0] addr;
logic [WIDTH_VECTOR-1:0] data_jump_reg; 

always_ff @(negedge rstn, posedge clk)
    if(~rstn)
        addr <= 0;
    else if(inc)
        addr_t <= addr;

always_ff @(negedge rstn, posedge clk)
    if(~rstn)
        data_jump_reg <= 0;
    else if(we_jump)
        data_jump_reg <= data_jump;

always_comb
    if(jump)
        addr = data_jump_reg;
    else 
        addr = addr_t + inc;

generate
    if(VENDOR == "xilinx")begin
        simple_ram_vivado
            #(
                .DSIZE      (WIDTH_INSTR),
                .ASIZE      (WIDTH_ADDR),
                .INIT_FILE  ("")
            )
        simple_ram_vivado
            (
                .addra      (addr),
                .dinc       (0),
                .clk        (clk),
                .wec        (0),
                .ena        (1'b1),
                .douta      (rdata)
            );
    end
endgenerate

endmodule 