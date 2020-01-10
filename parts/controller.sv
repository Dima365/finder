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
    output logic [2:0] com,

    input  logic valid,
    output logic next_instr,

    output logic [WIDTH_VECTOR-1:0] we_rf,

    output logic we_mem,

    output logic mem_alu,

    output logic jump_com

);
localparam WI = WIDTH_INSTR;
assign addr_rega = instr[WI-5:WI-5-WA_RF];
assign addr_regb = instr[WI-5-WA_RF-1:WI-5-WA_RF-1-WA_RF];
assign com       = instr[WI-1:WI-3];

assign next_instr = valid;

// if equal arifmetic commands set enable  
assign we_rf = (instr[WIDTH_INSTR-1:WIDTH_INSTR-2] != 2'b11) ?
                instr[WIDTH_VECTOR-1:0] : 0;    

assign we_mem = (com == 3'b111) ? 1'b1 : 1'b0;

assign mem_alu = (com === 3'b110) ? 1'b1 : 1'b0;

assign jump_com = instr[WIDTH_INSTR-4];

endmodule 