module simple_ram_vivado
#(
  parameter DSIZE = 8,      
  parameter ASIZE = 10,     
  parameter INIT_FILE = ""  
)
(
  input  [ASIZE-1:0] addra, 
  input  [DSIZE-1:0] dinc,          
  input  clk,                        
  input  wec,                           
  input  ena,
  output [DSIZE-1:0] douta
);
  wire [ASIZE-1:0] addra;  
  wire [DSIZE-1:0] dinc;  
  wire clk;             
  wire wec;               
  wire ena;                            
  wire [DSIZE-1:0] douta;

  reg [DSIZE-1:0] ram [2**ASIZE-1:0];
  reg [DSIZE-1:0] ram_dataa = ram[0];

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

  always @(posedge clk) begin
    if (wec)
      ram[addra] <= dinc;
    if (ena)
      ram_dataa   <= ram[addra];
  end

    assign douta = ram_dataa;
                       
endmodule