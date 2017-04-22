/*-----------------------------------------------------------------------------

	file name: dcr_decode_wb.sv
	language: SystemVerilog
	description: Decode/Write back pipeline stage
	
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/7/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_decode_wb(	input  logic clk, 
			input  logic rst, 
			input  logic clken,
			input  logic MemReadInID,
			input  logic RegWriteInID,
			input  logic SignExtInID,
			input  logic WithZeroInID,
			input  logic [31:0] ALUDataInID,
			input  logic [31:0] MemDataInID,
			input  logic [31:0] InstructionInID,
			input  logic [7:0]  PCPlusOneInID,
			input  logic [4:0]  WriteAddrInID,
			input  logic [1:0]  WriteDestInID,
			input  logic [31:0] EXEBypassDataInID,
			input  logic [31:0] MEMALUBypassDataInID,
			input  logic [31:0] MEMMEMBypassDataInID,
			input  logic [1:0]  ForwardRsInID,
			input  logic [1:0]  ForwardRtInID,
			output logic [31:0] ImmOutEXE,
			output logic [31:0] PCPlusOneOutEXE,
			output logic [31:0] RofRsOutEXE,
			output logic [31:0] RofRtOutEXE,
			output logic [31:0] ShamtOutEXE,
			output logic [31:0] WBBypassDataOutEXE,
			output logic [7:0]  BranchTargetOutIF,
			output logic [7:0]  JumpTargetOutIF,
			output logic [7:0]  RegTargetOutIF,
			output logic [5:0]  FuncOutPMCU,
			output logic [5:0]  OpcodeOutPMCU,
			output logic [4:0]  RtOutPMCU,
			output logic [4:0]  RsOutPMCU,
			output logic [4:0]  WriteAddrOutPMCU,
			output logic [2:0]  GSEOutPMCU
			);
							
// internal wiring							
							
logic [31:0] PCPlusOneID;
logic [31:0] RofRsID;
logic [31:0] RofRtID;
logic [31:0] Rddata1, Rddata2;
logic 	     RegWriteID;
logic [31:0] ShamtID;
logic [31:0] ImmID;
logic [31:0] BTC32YInputID;
logic [31:0] WriteDataID;
logic [2:0]  GSEID;
logic [4:0]  WriteAddrID;
logic [7:0]  BranchTargetID;

logic [5:0]  IWOpcodeID;
logic [4:0]  IWRsID;
logic [4:0]  IWRtID;
logic [4:0]  IWRdID;
logic [4:0]  IWShamtID;
logic [5:0]  IWFuncID;
logic [15:0] IWImmID;
logic [7:0]  IWAddrID;

// signals to make parsing instructions easier
  
assign IWOpcodeID = InstructionInID[31:26];
assign IWRsID = InstructionInID[25:21];
assign IWRtID = InstructionInID[20:16];
assign IWRdID = InstructionInID[15:11];
assign IWShamtID = InstructionInID[10:6];
assign IWFuncID = InstructionInID[5:0];
assign IWImmID = InstructionInID[15:0];
assign IWAddrID = InstructionInID[7:0];

// feed opcode, funct, rt, and GSE to PMCU
  
assign OpcodeOutPMCU = IWOpcodeID;
assign FuncOutPMCU = IWFuncID;
assign RtOutPMCU = IWRtID;
assign RsOutPMCU = IWRsID;
  
// select Write Address

assign WriteAddrID = (WriteDestInID == 2'b01)? IWRdID : 
							(WriteDestInID == 2'b10)? 5'b11111 : IWRtID;
							
// forwarding muxes

assign RofRsID = (ForwardRsInID == 2'b01)? EXEBypassDataInID :
					  (ForwardRsInID == 2'b10)? MEMALUBypassDataInID :
					  (ForwardRsInID == 2'b11)? MEMMEMBypassDataInID : Rddata1;
					 
assign RofRtID = (ForwardRtInID == 2'b01)? EXEBypassDataInID :
					  (ForwardRtInID == 2'b10)? MEMALUBypassDataInID : 
					  (ForwardRsInID == 2'b11)? MEMMEMBypassDataInID : Rddata2;
  
// select WriteDataID source
  
assign WriteDataID = (MemReadInID == 1)? MemDataInID : ALUDataInID;
  
// instantiate Register File

dcr_RegFile registerFile (
		.clk     (      clk 	     ),  // clock
		.rst     ( 		 rst  	  ),  // reset
		.wren    (  RegWriteInID  ), // write enable
		.wrdata  (   WriteDataID  ),
		.rdaddr1 (     IWRsID     ), // 5 bit alias for address field of instr
		.rdaddr2 (     IWRtID     ), // 5 bit alias for address field of instr
		.wraddr  (  WriteAddrInID ), // write address (5-bit)
		.rddata1 (     Rddata1    ), // Reg 1 read data
		.rddata2 (     Rddata2    ));// Reg 2 read data
		
  // bypass to exe

assign WBBypassDataOutEXE = WriteDataID;

  // mux to select the y operand source
  
assign BTC32YInputID = (WithZeroInID == 1)? 32'd0 : RofRtID;

always_comb
begin  
  
  GSEOutPMCU[0] = signed'(RofRsID) == signed'(BTC32YInputID);
  
  GSEOutPMCU[1] = signed'(RofRsID) < signed'(BTC32YInputID);
  
  GSEOutPMCU[2] = signed'(RofRsID) > signed'(BTC32YInputID);
  
  // extend pc + 1
  
	PCPlusOneID = 32'(PCPlusOneInID);
              
  // extend immediate
  
	if (SignExtInID == 1) begin
  
		ImmID = 32'(signed'(IWImmID));
		
	end else begin
		
		ImmID = 32'(unsigned'(IWImmID));
		
	end
  
  // extend shamt
  
	ShamtID = 32'(IWShamtID);
	
  // non-piped outs
  
	BranchTargetID = IWAddrID + PCPlusOneInID;
	BranchTargetOutIF = BranchTargetID;
	JumpTargetOutIF = InstructionInID[7:0];
	RegTargetOutIF = RofRsID[7:0];
	WriteAddrOutPMCU = WriteAddrID;
  
end

always_ff @(posedge clk, posedge rst)
begin

	if (rst == 1) begin 
		RofRsOutEXE <= 32'd0;
		RofRtOutEXE <= 32'd0;
		ShamtOutEXE <= 32'd0;
		ImmOutEXE <= 32'd0;
		PCPlusOneOutEXE <= 32'd0;
	end else if (clken == 1) begin
		RofRsOutEXE <= RofRsID;
		RofRtOutEXE <= RofRtID;
		ShamtOutEXE <= ShamtID;
		ImmOutEXE <= ImmID;
		PCPlusOneOutEXE <= PCPlusOneID;
	end   

end

endmodule

