module rams_tdp_rf_rf 
#(
  parameter DSIZE = 8,
  parameter ASIZE = 16,
  parameter INIT_FILE = ""
)
(clka,clkb,ena,enb,wea,web,addra,addrb,dia,dib,doa,dob);

input clka,clkb,ena,enb,wea,web;
input  [ASIZE-1:0] addra,addrb;
input  [DSIZE-1:0] dia,dib;
output [DSIZE-1:0] doa,dob;

reg [DSIZE-1:0] ram [2**ASIZE-1:0];
reg [DSIZE-1:0] doa,dob;

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

always @(posedge clka)
begin   
    if (ena)    
    begin      
        if (wea)        
            ram[addra] <= dia;      
        doa <= ram[addra];
    end
end

always @(posedge clkb) 
begin   
    if (enb)    
    begin      
        if (web)        
            ram[addrb] <= dib;      
        dob <= ram[addrb];    
    end
end

endmodule