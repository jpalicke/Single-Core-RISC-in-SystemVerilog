/*-----------------------------------------------------------------------------

	file name: dcr_execute.sv
	language: SystemVerilog
	description: SystemVerilog implementation of the EXE pipeline stage
	
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_execute(	input logic  clk,
			input logic  rst,
			input logic  clken,
			input logic [1:0]  BypassRsInEXE,
			input logic [1:0]  BypassRtInEXE,
			input logic [31:0] RofRsInEXE,
			input logic [31:0] RofRtInEXE,
			input logic [31:0] ShamtInEXE,
			input logic [31:0] ImmInEXE, 
			input logic [31:0] PCPlusOneInEXE,
			input logic [31:0] MEMMEMBypassDataInEXE,
			input logic [31:0] WBBypassDataInEXE,
			input logic [3:0]  ALUControlInEXE,
			input logic [1:0]  ALUSrcXInEXE,
			input logic [1:0]  ALUSrcYInEXE,
			output logic [31:0] ALUResultOutMEM,
			output logic [31:0] EXEBypassDataOutID,
			output logic [31:0] RofRtOutMEM,
			output logic [7:0]  ALUAddrOutMEM
		);
								
logic [31:0] ALUOperandX, ALUOperandY, RsOperand, RtOperand, Result;
								
								
always_comb
begin: dcr_pipe_execute

	//forwarding mux x operand

	case(BypassRsInEXE)
		2'd1: RsOperand = MEMMEMBypassDataInEXE;
		2'd2: RsOperand = WBBypassDataInEXE;
		default: RsOperand = RofRsInEXE;
	endcase
	
	//forwarding mux y operand
	
	case(BypassRtInEXE)
		2'd1: RtOperand = MEMMEMBypassDataInEXE;
		2'd2: RtOperand = WBBypassDataInEXE;
		default: RtOperand = RofRtInEXE;
	endcase

	//select ALU X operand
	
	case(ALUSrcXInEXE)
		2'd1: ALUOperandX = PCPlusOneInEXE;
		2'd2: ALUOperandX = ShamtInEXE;
		2'd3: ALUOperandX = 32'd16;
		default: ALUOperandX = RsOperand;
	endcase
	
	//select ALU Y operand
	
	case(ALUSrcYInEXE)
		2'd1: ALUOperandY = ImmInEXE;
		2'd2: ALUOperandY = 32'd1;
		default: ALUOperandY = RtOperand;
	endcase
					 
	//non-pipelined outputs
	
	RofRtOutMEM = RofRtInEXE;
        ALUAddrOutMEM = Result[7:0];
	
	//ALU output to bypass muxes
	
	EXEBypassDataOutID = Result;
	
	end // end combinational logic
	
	//instantiate ALU
	
	dcr_ALU alu(	.x(ALUOperandX), 
					   .y(ALUOperandY), 
						.funct(ALUControlInEXE), 
						.result(Result)
					);
	
	// begin pipeline flip flops
	
	
	always_ff @(posedge clk or posedge rst)
	begin
		if (rst == 1) begin
			ALUResultOutMEM <= 32'd0;
		end else if (clken) begin
			ALUResultOutMEM <= Result;
		end
	end
	
	endmodule