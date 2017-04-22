/*-----------------------------------------------------------------------------

	file name: dcr_pmcu_haz.sv
	language: SystemVerilog
	description: SystemVerilog version of P3 processor pipelined control and
		hazard unit
	
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_pmcu_haz(		input  logic		 clk, 
				input  logic 		 rst, 
				input  logic       clken,
				input  logic [5:0] OpcodeInPMCU,
				input  logic [4:0] RsInPMCU, 
				input  logic [4:0] RtInPMCU, 
				input  logic [5:0] FuncInPMCU,
				input  logic [2:0] GSEInPMCU,
				input  logic [4:0] WriteAddrInPMCU,
				output logic [1:0] PCSrcOutIF,
				output logic 		 WithZeroOutID,
				output logic 		 MemWriteOutMEM,
				output logic 		 MemReadOutIDWB,
				output logic [3:0] ALUControlOutEXE,
				output logic [1:0] ALUSrcXOutEXE,
				output logic [1:0] ALUSrcYOutEXE,
				output logic 		 SignExtOutID,
				output logic 		 RegWriteOutIDWB,
				output logic [1:0] WriteDestOutIDWB,
				output logic [4:0] WriteAddrOutIDWB,
				output logic [1:0] ForwardRsOutID,
				output logic [1:0] ForwardRtOutID,
				output logic [1:0] ForwardRsOutEXE,
				output logic [1:0] ForwardRtOutEXE
							);

// singals to carry read and write addresses through
// to throw bypass signals

logic [4:0] RsInEXE;
logic [4:0] RtInEXE;					 
						 
// pipeline signals into PMCU stage

logic 		MemWritePMCU;
logic 		MemReadPMCU;
logic [3:0] ALUControlPMCU;
logic [1:0] ALUSrcXPMCU;
logic [1:0] ALUSrcYPMCU;
logic 		RegWritePMCU;

// pipeline signals into EXE stage

logic 	   MemWriteEXE;
logic 		MemReadEXE;
logic 		RegWriteEXE;
logic [4:0] WriteAddrEXE;

// pipeline signals into MEM stage

logic 		MemReadMEM;
logic 		RegWriteMEM;
logic [4:0] WriteAddrMEM;

// instantiate MCU

dcr_mcu mcu(	.OpcodeInMCU(OpcodeInPMCU),
					.RtInMCU(RtInPMCU),
					.FuncInMCU(FuncInPMCU),
					.GSEInMCU(GSEInPMCU),
					.PCSrcOutPMCU(PCSrcOutIF),
					.WithZeroOutPMCU(WithZeroOutID),
					.MemWriteOutPMCU(MemWritePMCU),
					.MemReadOutPMCU(MemReadPMCU),
					.ALUControlOutPMCU(ALUControlPMCU),
					.ALUSrcXOutPMCU(ALUSrcXPMCU),
					.ALUSrcYOutPMCU(ALUSrcYPMCU),
					.SignExtOutPMCU(SignExtOutID),
					.RegWriteOutPMCU(RegWritePMCU),
					.WriteDestOutPMCU(WriteDestOutIDWB)
				);
				
always @ (*)
begin
	
		if (RsInPMCU == 5'b0)
			ForwardRsOutID = 2'b0;
		else if ((WriteAddrEXE == RsInPMCU) && RegWriteEXE)
			ForwardRsOutID = 2'b01;
		else if ((WriteAddrMEM == RsInPMCU) && RegWriteMEM && !(MemReadMEM))
			ForwardRsOutID = 2'b10;
		else if (((WriteAddrMEM == RsInPMCU) && RegWriteMEM && MemReadMEM) || ((WriteAddrEXE == RsInPMCU) && MemReadMEM && RegWriteEXE))
			ForwardRsOutID = 2'b11;
		else
			ForwardRsOutID = 2'b0;
end
always @ (*)
begin	
		if (RtInPMCU == 5'b0)
			ForwardRtOutID = 2'b0;
		else if ((WriteAddrEXE == RtInPMCU) && RegWriteEXE)
			ForwardRsOutID = 2'b01;
		else if ((WriteAddrMEM == RtInPMCU) && RegWriteMEM && !(MemReadMEM))
			ForwardRtOutID = 2'b10;
		else if (((WriteAddrMEM == RtInPMCU) && RegWriteMEM && MemReadMEM) || ((WriteAddrEXE == RtInPMCU) && MemReadMEM && RegWriteEXE))
			ForwardRsOutID = 2'b11;
		else
			ForwardRsOutID = 2'b0;
end
always @ (*)
begin
		if (RsInEXE == 5'b0)
			ForwardRsOutEXE <= 2'd0;
		else if ((RsInEXE == WriteAddrMEM) && (MemReadMEM == 1'b1) && (RegWriteMEM == 1'b1))
			ForwardRsOutEXE <= 2'd1;
		else if ((RsInEXE == WriteAddrOutIDWB) && (RegWriteOutIDWB == 1'b1))
			ForwardRsOutEXE <= 2'd2;
		else
			ForwardRsOutEXE <= 2'd0;
end
always @ (*)
begin
		if (RtInEXE == 5'b0)
			ForwardRtOutEXE <= 2'd0;
		else if ((RtInEXE == WriteAddrMEM) && (MemReadMEM == 1'b1) && (RegWriteMEM == 1'b1))
			ForwardRtOutEXE <= 2'd1;
		else if ((RtInEXE == WriteAddrOutIDWB) && (MemReadOutIDWB == 1'b1) && (RegWriteOutIDWB == 1'b1))
			ForwardRtOutEXE <= 2'd2;
		else
			ForwardRtOutEXE <= 2'd0;
end
				
always_ff @(posedge clk or posedge rst)
begin
	
	if (rst == 1) begin
	
		//ID/EXE stage pipeline
	
		MemWriteEXE <= 'b0;
		MemReadEXE <= 'b0;
		ALUControlOutEXE <= 'b0;
		ALUSrcXOutEXE <= 'b0;
		ALUSrcYOutEXE <= 'b0;
		RegWriteEXE <= 'b0;
		WriteAddrEXE <= 'b0;
		RsInEXE <= 'b0;
		RtInEXE <= 'b0;
	
		//EXE/MEM stage pipeline
	
		MemReadMEM <= 'b0;
		RegWriteMEM <= 'b0;
		WriteAddrMEM <= 'b0;
	
		//MEM/WB-ID stage pipeline
	
		MemReadOutIDWB <= 'b0;
		RegWriteOutIDWB <= 'b0;
		WriteAddrOutIDWB <= 'b0;
	
	end else if (clken) begin
	
		//ID/EXE stage pipeline
	
		MemWriteOutMEM <= MemWritePMCU;
		MemReadEXE <= MemReadPMCU;
		ALUControlOutEXE <= ALUControlPMCU;
		ALUSrcXOutEXE <= ALUSrcXPMCU;
		ALUSrcYOutEXE <= ALUSrcYPMCU;
		RegWriteEXE <= RegWritePMCU;
		WriteAddrEXE <= WriteAddrInPMCU;
		RsInEXE <= RsInPMCU;
		RtInEXE <= RtInPMCU;
	
		//EXE/MEM stage pipeline
	
		MemReadMEM <= MemReadEXE;
		RegWriteMEM <= RegWriteEXE;
		WriteAddrMEM <= WriteAddrEXE;
	
		//MEM/WB-ID stage pipeline
	
		MemReadOutIDWB <= MemReadMEM;
		RegWriteOutIDWB <= RegWriteMEM;
		WriteAddrOutIDWB <= WriteAddrMEM;
	
	end
	
end
endmodule 