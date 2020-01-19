module controller
#(
    parameter WIDTH_INSTR  = 16,
    parameter WIDTH_VECTOR = 8, // have to be 2**N
    parameter WA_RF        = 8,
    parameter WIDTH_OPCODE = 4,
    parameter WIDTH_JDATA  = 24,
    parameter WA_MEM_SIGN  = 20  
)
(
    input  logic [WIDTH_INSTR-1:0]  instr,
    input  logic valid,
    input  logic opcode_exe,
    input  logic zero,
    input  logic exe_flush,

    output logic [WIDTH_OPCODE-1:0] opcode,
    output logic [WA_RF-1:0]        addr_rega,
    output logic [WA_RF-1:0]        addr_regb,
    output logic                    next_instr,
    output logic [WIDTH_JDATA-1:0]  jdata,
    output logic [WIDTH_VECTOR-1:0] we_rf,
    output logic [WIDTH_VECTOR-1:0] data_imm,
    output logic                    mem_we,
    output logic                    mem_alu,
    output logic                    jump,
    output logic [WA_MEM_SIGN-1:0]  mem_addr
);
localparam WI = WIDTH_INSTR;
localparam WO = WIDTH_OPCODE;

assign opcode = instr[WI-1:WI-WO];
assign {addr_rega,addr_regb} = instr[WI-WO-1:WI-WO-2*WA_RF];

always_comb
    if(opcode_exe == 4'b1001 || opcode_exe == 4'b1010)
        next_instr = 1'b1;
    else if(opcode_exe == 4'b1011 || opcode_exe == 4'b1100)
        next_instr = 1'b1;
    else if(opcode_exe == 4'b1101)
        next_instr = 1'b1;
    else if(valid && ~exe_flush)
        next_instr = 1'b1;
    else 
        next_instr = 1'b0;
    
assign jdata    = instr[WIDTH_JDATA-1:0];
assign data_imm = instr[WIDTH_VECTOR-1:0];
assign mem_alu  = (opcode == 4'b1100) ? 1'b1 : 1'b0;
assign mem_we   = (opcode == 4'b1011) ? 1'b1 : 1'b0;

always_comb
    if(opcode_exe == 4'b1001 && zero)
        jump = 1'b1;
    else if(opcode_exe == 4'b1010)
        jump = 1'b1;
    else 
        jump = 1'b0;

always_comb
    if( opcode != 4'b1001 &&
        opcode != 4'b1010 &&
        opcode != 4'b1101)
            we_rf = instr[WIDTH_VECTOR-1:0];
    else 
        we_rf = 0;
    
endmodule 