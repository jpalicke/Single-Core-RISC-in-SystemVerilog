/*---- -------------------------------------------------------------------------

	file name: dcr_memory.sv
	language: SystemVerilog
	description: memory pipeline stage
	
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/7/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_memory( 	input  logic 	     clk, 
							input  logic        clken, 
							input  logic        rst,
							input  logic [31:0] ALUResultInMEM,
							input  logic [31:0] RofRtInMEM,
							input  logic [7:0]  ALUAddrInMEM,
							input  logic 	     MemWriteInMEM,
							output logic [31:0] ALUResultOutID,
							output logic [31:0] MemDataOutID,
							output logic [31:0] MEMALUBypassDataOutIDEXE,
							output logic [31:0] MEMMEMBypassDataOutIDEXE
					  );



logic [31:0] MemDataMem;

  dataRAM ram( .clock(clk),
					.wren(MemWriteInMEM),
					.address(ALUAddrInMEM),
					.data(RofRtInMEM),
					.q(MemDataMem));
					
assign MEMALUBypassDataOutIDEXE = ALUResultInMEM;
assign MEMMEMBypassDataOutIDEXE = MemDataMem; 
					
always_ff @(posedge clk, posedge rst)
begin

	if (rst == 1) begin
		
		ALUResultOutID <= 32'b0;
		MemDataOutID <= 32'b0;
	
	end else if (clken == 1) begin
		
		ALUResultOutID <= ALUResultInMEM;
		MemDataOutID <= MemDataMem;
		
	end

end
endmodule