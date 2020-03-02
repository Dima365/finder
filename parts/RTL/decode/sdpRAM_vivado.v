module sdpRAM_vivado
  //  Xilinx Simple Dual Port Single Clock RAM
  //  This code implements a parameterizable SDP single clock memory.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.
#(
  parameter DSIZE = 8,                  // Specify RAM data width
  parameter ASIZE = 10,                  // Specify RAM depth (number of entries)
  parameter INIT_FILE = ""                      // Specify name/location of RAM initialization file if using one (leave blank if not)
)
(
  input  [ASIZE-1:0] addra, 
  input  [ASIZE-1:0] addrb, 
  input  [DSIZE-1:0] dina,          
  input  clka,                        
  input  wea,                           
  input  enb,                                                                        
  output [DSIZE-1:0] doutb 
);
 // wire [ASIZE-1:0] addra; // Write address bus, width determined from RAM_DEPTH
 // wire [ASIZE-1:0] addrb; // Read address bus, width determined from RAM_DEPTH
 // wire [DSIZE-1:0] dina;  // RAM input data
 // wire clka;              // Clock
 // wire wea;               // Write enable
 // wire enb;               // Read Enable, for additional power savings, disable when not in use
 // wire [DSIZE-1:0] doutb; // RAM output data

  reg [DSIZE-1:0] ram [2**ASIZE-1:0];
  reg [DSIZE-1:0] ram_data = {DSIZE{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, ram, 0, 2**ASIZE-1);
    end else begin: init_bram_to_zero
     integer ram_index;
      initial
        for (ram_index = 0; ram_index < 2**ASIZE; ram_index = ram_index + 1)
          ram[ram_index] = {DSIZE{1'b0}};
    end
  endgenerate

  always @(posedge clka) begin
    if (wea)
      ram[addra] <= dina;
    if (enb)
      ram_data <= ram[addrb];
  end

    assign doutb = ram_data;

                        
endmodule