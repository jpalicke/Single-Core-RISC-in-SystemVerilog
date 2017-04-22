/*-----------------------------------------------------------------------------

	file name: dcr_sc_top.sv
	language: SystemVerilog
	description: Top level file for the single core cacheless processor
	
	Author: Joseph Palicke
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/7/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_sc_top(	clk,
							rst,
							clken,
							InstructionOutTop,
							GSEOutTop,
							PCSrcOutTop,
							WithZeroOutTop,
							MemWriteOutTop,
							MemReadOutTop,
							SignExtOutTop,
							RegWriteOutTop,
							WriteDestOutTop,
							BranchTargetOutTop,
							JumpTargetOutTop,
							RegTargetOutTop,
							PCPlusOneOutTop,
							RofRsOutTop,
							RofRtOutTop,
							ImmOutTop
						);
							
input  logic 		  clk;
input  logic 		  rst;
input  logic 		  clken;
output logic [31:0] InstructionOutTop;
output logic [2:0]  GSEOutTop;
output logic [1:0]  PCSrcOutTop;
output logic WithZeroOutTop;
output logic MemWriteOutTop;
output logic MemReadOutTop;
output logic SignExtOutTop;
output logic RegWriteOutTop;
output logic [1:0] WriteDestOutTop;
output logic [7:0] BranchTargetOutTop;
output logic [7:0] JumpTargetOutTop;
output logic [7:0] RegTargetOutTop;
output logic [7:0] PCPlusOneOutTop;
output logic [31:0] RofRsOutTop;
output logic [31:0] RofRtOutTop;
output logic [31:0] ImmOutTop;

logic [31:0] InstructionTop;
logic [2:0]  GSETop;
logic [1:0]  PCSrcTop;
logic			 WithZeroTop;
logic			 MemWriteTop;
logic			 MemReadTop;
logic [3:0]  ALUControlTop;
logic [1:0]  ALUSrcXTop;
logic [1:0]  ALUSrcYTop;
logic			 SignExtTop;
logic			 RegWriteTop;
logic	[1:0]  WriteDestTop;
logic [7:0]  BranchTargetTop;
logic [7:0]  JumpTargetTop;
logic [7:0]  RegTargetTop;
logic [7:0]  PCPlusOneTop;
logic [5:0]  OpcodeTop;
logic [4:0]  RtTop;
logic [4:0]  RsTop;
logic [5:0]  FuncTop;
logic [7:0]  PCPlusOneIFTop;
logic [31:0] ALUDataIDTop;
logic [31:0] MemDataIDTop;
logic [31:0] RofRsTop;
logic [31:0] RofRtIDTop;
logic [31:0] ShamtTop;
logic [4:0]  WriteAddrIDTop;
logic [4:0]  WriteAddrPMCUTop;
logic [31:0] ImmTop;
logic [31:0] PCPlusOneIDTop;
logic [31:0] PCPlusOneEXETop;
logic [31:0] ALUResultOutEXETop;
logic [7:0]  ALUAddrTop;
logic [31:0] RofRtMemTop;
logic [4:0]  WriteAddrEXETop;
logic [2:0] CVZTop;
logic [4:0] WriteAddrMEMTop;
logic StallTop;
logic [1:0] BypassRsTop;
logic [1:0] BypassRtTop;
logic [31:0] ALUResultEXETop;
logic [31:0] ALUResultMEMTop;
logic [1:0] ForwardRsIDTop, ForwardRtIDTop; 
logic [1:0] ForwardRsEXETop, ForwardRtEXETop;
logic [31:0] MEMALUBypassDataTop, MEMMEMBypassDataTop, EXEBypassDataTop, WBBypassDataTop;

// instantiate processor pipeline

	// fetch

	dcr_fetch fetch_stage( .PCSrcInIF(PCSrcTop),
								  .BranchTargetInIF(BranchTargetTop),
								  .JumpTargetInIF(JumpTargetTop),
								  .RegTargetInIF(RegTargetTop),
								  .clken(clken),
								  .clk(clk),
								  .rst(rst),
								  .InstructionOutID(InstructionTop),
								  .PCPlusOneOutID(PCPlusOneIFTop)
								);
	
	// decode/writeback
	
	dcr_decode_wb decode_stage( .clk(clk),
										 .rst(rst),
										 .clken(clken),
										 .MemReadInID(MemReadTop),
										 .RegWriteInID(RegWriteTop),
										 .SignExtInID(SignExtTop),
										 .WithZeroInID(WithZeroTop),
										 .ALUDataInID(ALUDataIDTop),
										 .MemDataInID(MemDataIDTop),
										 .InstructionInID(InstructionTop),
										 .PCPlusOneInID(PCPlusOneIFTop),
										 .WriteAddrInID(WriteAddrPMCUTop),
										 .WriteDestInID(WriteDestTop),
										 .ImmOutEXE(ImmTop),
										 .PCPlusOneOutEXE(PCPlusOneEXETop),
										 .RofRsOutEXE(RofRsTop),
										 .RofRtOutEXE(RofRtIDTop),
										 .ShamtOutEXE(ShamtTop),
										 .BranchTargetOutIF(BranchTargetTop),
										 .JumpTargetOutIF(JumpTargetTop),
										 .RegTargetOutIF(RegTargetTop),
										 .FuncOutPMCU(FuncTop),
										 .OpcodeOutPMCU(OpcodeTop),
										 .RtOutPMCU(RtTop),
										 .RsOutPMCU(RsTop),
										 .WriteAddrOutPMCU(WriteAddrIDTop),
										 .GSEOutPMCU(GSETop),
										 .ForwardRsInID(ForwardRsIDTop),
										 .ForwardRtInID(ForwardRtIDTop),
										 .EXEBypassDataInID(EXEBypassDataTop),
										 .MEMALUBypassDataInID(MEMALUBypassDataTop),
										 .MEMMEMBypassDataInID(MEMMEMBypassDataTop),
										 .WBBypassDataOutEXE(WBBypassDataTop)
									  );
	
	// execute
	
	dcr_execute execute_stage(  .RofRsInEXE(RofRsTop),
										 .RofRtInEXE(RofRtIDTop),
										 .ShamtInEXE(ShamtTop),
										 .ImmInEXE(ImmTop),
										 .PCPlusOneInEXE(PCPlusOneEXETop),
										 .ALUControlInEXE(ALUControlTop),
										 .ALUSrcXInEXE(ALUSrcXTop),
										 .ALUSrcYInEXE(ALUSrcYTop),
										 .rst(rst),
										 .clk(clk),
										 .clken(clken),
										 .ALUResultOutMEM(ALUResultOutEXETop),
										 .ALUAddrOutMEM(ALUAddrTop),
										 .RofRtOutMEM(RofRtMemTop),
										 .MEMMEMBypassDataInEXE(MEMMEMBypassDataTop),
										 .BypassRsInEXE(ForwardRsEXETop),
										 .BypassRtInEXE(ForwardRsEXETop),
										 .EXEBypassDataOutID(EXEBypassDataTop),
										 .WBBypassDataInEXE(WBBypassDataTop)
									 );
	
	// memory
	
	dcr_memory memory_stage(   .ALUResultInMEM(ALUResultOutEXETop),
										.RofRtInMEM(RofRtMemTop),
										.ALUAddrInMEM(ALUAddrTop),
										.MemWriteInMEM(MemWriteTop),
										.clk(clk),
										.clken(clken),
										.rst(rst),
										.ALUResultOutID(ALUDataIDTop),
										.MemDataOutID(MemDataIDTop),
										.MEMALUBypassDataOutIDEXE(MEMALUBypassDataTop),
										.MEMMEMBypassDataOutIDEXE(MEMMEMBypassDataTop)
									);
									
	// pmcu
	
	dcr_pmcu_haz pmcu(   .clk(clk), 
								.rst(rst), 
								.clken(clken),
								.OpcodeInPMCU(OpcodeTop),
								.RtInPMCU(RtTop),
								.RsInPMCU(RsTop),
								.FuncInPMCU(FuncTop),
								.GSEInPMCU(GSETop),
								.WriteAddrInPMCU(WriteAddrIDTop),
								.PCSrcOutIF(PCSrcTop),
								.WithZeroOutID(WithZeroTop),
								.MemWriteOutMEM(MemWriteTop),
								.MemReadOutIDWB(MemReadTop),
								.ALUControlOutEXE(ALUControlTop),
								.ALUSrcXOutEXE(ALUSrcXTop),
								.ALUSrcYOutEXE(ALUSrcYTop),
								.SignExtOutID(SignExtTop),
								.RegWriteOutIDWB(RegWriteTop),
								.WriteDestOutIDWB(WriteDestTop),
								.WriteAddrOutIDWB(WriteAddrPMCUTop),
								.ForwardRsOutID(ForwardRsIDTop),
								.ForwardRtOutID(ForwardRtIDTop),
								.ForwardRsOutEXE(ForwardRsEXETop),
								.ForwardRtOutEXE(ForwardRtEXETop)
						);
						

always_comb
begin: dcr_sc_top

    InstructionOutTop = InstructionTop;
    GSEOutTop = GSETop;
    PCSrcOutTop = PCSrcTop;
    WithZeroOutTop = WithZeroTop;
    MemWriteOutTop = MemWriteTop;
    MemReadOutTop = MemReadTop;
    SignExtOutTop = SignExtTop;
    RegWriteOutTop = RegWriteTop;
    WriteDestOutTop = WriteDestTop;
    BranchTargetOutTop = BranchTargetTop;
    JumpTargetOutTop = JumpTargetTop;
    RegTargetOutTop = RegTargetTop;
    PCPlusOneOutTop = PCPlusOneIFTop;
    RofRsOutTop = RofRsTop;
    RofRtOutTop = RofRtIDTop;
    ImmOutTop = ImmTop;

end

endmodule 