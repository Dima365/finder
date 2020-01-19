module instr_mem
#(
    parameter WIDTH_INSTR   = 8,
    parameter WIDTH_ADDR    = 8,
    parameter WIDTH_VECTOR  = 8,
    parameter VENDOR = "xilinx",
    parameter WIDTH_JDATA = 24
)
(
    input  logic rstn,
    input  logic clk,

    input  logic opcode,

    input  logic next_instr,
    output logic [WIDTH_INSTR-1:0] instr,

    input  logic jump,
    input  logic [WIDTH_JDATA-1:0] jdata
);
logic [WIDTH_ADDR-1:0] addr, addr_t; 

always_comb
    if(opcode == 4'b1010 && jump)
        addr = jdata[WIDTH_ADDR-1:0];
    else if(opcode == 4'b1001 && jump)
        addr = addr_t + jdata[WIDTH_VECTOR-1:0]; 
    else 
        addr = addr_t + next_instr;

always_ff @(negedge rstn, posedge clk)
    if(~rstn)
        addr_t <= 0;
    else
        addr_t <= addr;

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
                .douta      (instr)
            );
    end
endgenerate

endmodule 