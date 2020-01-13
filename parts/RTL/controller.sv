module controller
#(
    parameter WIDTH_INSTR  = 16,
    parameter WIDTH_VECTOR = 8, // have to be 2**N
    parameter WA_RF        = 8
)
(
    input  logic [WIDTH_INSTR-1:0] instr,
    output logic [WA_RF-1:0] addr_rega,
    output logic [WA_RF-1:0] addr_regb,
    output logic [3:0] opcode,

    input  logic valid,
    output logic next_instr,

    output logic [WIDTH_VECTOR-1:0] we_rf,

    output logic we_mem,

    output logic mem_alu,

    output logic [WIDTH_VECTOR-1:0] addr_instr,

    input  logic zero,
    output logic jump,
    output logic [WIDTH_VECTOR-1:0] data_imm
);
localparam WI = WIDTH_INSTR;
assign addr_rega = instr[WI-5:WI-5-WA_RF];
assign addr_regb = instr[WI-5-WA_RF-1:WI-5-WA_RF-1-WA_RF];
assign opcode    = instr[WI-1:WI-4];

assign next_instr = valid;
    
assign addr_instr = instr[WIDTH_VECTOR-1:0];

assign data_imm = instr[WIDTH_VECTOR-1:0];

always_comb
    if( instr[WI-1:WI-4] != 4'b1010 &&
        instr[WI-1:WI-4] != 4'b1011 &&
        instr[WI-1:WI-4] != 4'b1100)
            we_rf = instr[WIDTH_VECTOR-1:0];
    else 
        we_rf = 0;

always_comb
    if(instr[WI-1:WI-4] == 4'b1100 && zero)
        jump = 1'b1;
    else 
        jump = 1'b0;

always_comb
    if(instr[WI-1:WI-4] == 4'b1001 || instr[WI-1:WI-4] == 4'b1010)
        mem_alu = 1'b1;
    else
        mem_alu = 1'b0; 

always_comb
    if(instr[WI-1:WI-4] == 4'b1001)
        we_mem = 1'b1;
    else 
        we_mem = 1'b0

endmodule 