/*-----------------------------------------------------------------------------

	file name: dcr_fetch.sv
	language: SystemVerilog
	description: SystemVerilog version of P3 processor ALU
	
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_fetch(	input logic [1:0]  PCSrcInIF,
			input logic [7:0]  BranchTargetInIF,
			input logic [7:0]  JumpTargetInIF,
			input logic [7:0]  RegTargetInIF,
			input logic clk,
			input logic clken,
			input logic rst,
			output logic [31:0] InstructionOutID,
			output logic [7:0]  PCPlusOneOutID
		);
							
logic [7:0]  AddressIF, PseudoAddressIF, PCPlusOneIF;
logic [31:0] InstructionIF;

	// instantiate InstructionROM
	
	instructionROM rom(  .address(AddressIF),
			     .clock(clk),
			     .q(InstructionIF)
			);

assign PCPlusOneIF = PseudoAddressIF + 8'd1;

always_comb
begin: dcr_pipe_fetch
	
	// mux to select PC Source
	
	case(PCSrcInIF)
		2'd1: AddressIF = BranchTargetInIF;
		2'd2: AddressIF = JumpTargetInIF;
		2'd3: AddressIF = RegTargetInIF;
		default: AddressIF = PCPlusOneIF;
	endcase

end // end combinational logic

// begin pipeline flip flops and program counter flip flops

always_ff @(posedge clk or posedge rst)
begin

	if (rst == 1) begin
		PCPlusOneOutID <= 8'd0;
		InstructionOutID <= 32'd0;
		
		// pseudoPC
		
		PseudoAddressIF <= 8'b11111111;
	end else if (clken) begin
		InstructionOutID <= InstructionIF;
		PCPlusOneOutID <= PCPlusOneIF;
		
		// pseudoPC
		
		PseudoAddressIF <= AddressIF;
	end

end

endmodule