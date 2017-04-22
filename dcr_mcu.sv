/*-----------------------------------------------------------------------------

	file name: dcr_mcu.sv
	language: SystemVerilog
	description: SystemVerilog version of P3 processor MCU
	
	Author: Joseph Palicke
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_mcu(	OpcodeInMCU,
						RtInMCU,
						FuncInMCU,
						GSEInMCU,
						PCSrcOutPMCU,
						WithZeroOutPMCU,
						MemWriteOutPMCU,
						MemReadOutPMCU,
						ALUControlOutPMCU,
						ALUSrcXOutPMCU,
						ALUSrcYOutPMCU,
						SignExtOutPMCU,
						RegWriteOutPMCU,
						WriteDestOutPMCU
					);
					
input  logic [5:0] OpcodeInMCU;
input  logic [4:0] RtInMCU;
input  logic [5:0] FuncInMCU;
input  logic [2:0] GSEInMCU;
output logic [1:0] PCSrcOutPMCU;
output logic	    WithZeroOutPMCU;
output logic	    MemWriteOutPMCU;
output logic	    MemReadOutPMCU;
output logic [3:0] ALUControlOutPMCU;
output logic [1:0] ALUSrcXOutPMCU;
output logic [1:0] ALUSrcYOutPMCU;
output logic	    SignExtOutPMCU;
output logic	    RegWriteOutPMCU;
output logic [1:0] WriteDestOutPMCU;							

// enum types for the later case statement
// matches opcode, function code, few other things

//patterns to match for the instructionWord in the casex statement

typedef enum logic [15:0] {	ADDI     = 16'b001000??????????,
										ADDIU    = 16'b001001??????????,
										ANDI     = 16'b001100??????????,
										BEQ      = 16'b000100?????????1,
										BEQ_not  = 16'b000100?????????0,
										BGEZ_gr  = 16'b0000011??????1?0,
										BGEZ_eq  = 16'b0000011??????0?1,
										BGEZ_not = 16'b0000011??????0?0,
										BLTZ     = 16'b0000010???????1?,
										BLTZ_not = 16'b0000010???????0?,
										BGTZ     = 16'b000111???????1??,
										BGTZ_not = 16'b000111???????0??,
										BLEZ_lt  = 16'b000110????????10,
										BLEZ_eq  = 16'b000110????????01,
										BLEZ_not = 16'b000110????????00,
										BNE      = 16'b000101?????????0,
										BNE_not  = 16'b000101?????????1,
										J        = 16'b000010??????????,
										JAL      = 16'b000011??????????,
										LUI      = 16'b001111??????????,
										LW       = 16'b100011??????????,
										ORI      = 16'b001101??????????,
										SLTI     = 16'b001010??????????,
										SLTIU    = 16'b001011??????????,
										SW       = 16'b101011??????????,
										XORI     = 16'b001110??????????,
										ADD      = 16'b000000?100000???,
										ADDU     = 16'b000000?100001???,
										AND_OP   = 16'b000000?100100???,
										JALR     = 16'b000000?001001???,
										JR       = 16'b000000?001000???,
										NOR_OP   = 16'b000000?100111???,
										OR_OP    = 16'b000000?100101???,
										SLL_OP   = 16'b000000?000000???,
										SLLV     = 16'b000000?000100???,
										SLT      = 16'b000000?101010???,
										SLTU     = 16'b000000?101011???,
										SRA_OP   = 16'b000000?000011???,
										SRAV     = 16'b000000?000111???,
										SRL_OP   = 16'b000000?000010???,
										SRLV     = 16'b000000?000110???,
										SUB      = 16'b000000?100010???,
										SUBU     = 16'b000000?100011???,
										XOR_OP   = 16'b000000?100110???
									} iw_t;
								
iw_t instructionWord;								
					  
// output signals for each instruction to make the later casex more readable

typedef enum logic[16:0] {	ADDI_CW 	   = 17'b0000x000101000111,
				ANDI_CW		   = 17'b0000x000000000101,
				BEQ_CW 	   = 17'b0100000xxxxxxxxx0,
			        BEQ_not_CW  = 17'b0000000xxxxxxxxx0,
				BRN_gr_CW   = 17'b0100100xxxxxxxxx0,
				BRN_not_CW  = 17'b0000100xxxxxxxxx0,
				J_CW        = 17'b1000x00xxxxxxxxx0,
										JAL_CW      = 17'b1010x0001010110x1,
										LUI_CW      = 17'b0000x001100110111,
										LW_CW       = 17'b0000x010101000111,
										ORI_CW      = 17'b0000x000001000101,
										SLTI_CW     = 17'b0000x001011000111,
										SLTIU_CW    = 17'b0000x0010100001x1,
										SW_CW       = 17'b0000x100101000110,
										XORI_CW     = 17'b0000x000010000101,
										ADD_CW      = 17'b0001x0001010000x1,
										AND_OP_CW   = 17'b0001x0000000000x1,
										JALR_CW     = 17'b1110x0001010110x1,
										JR_CW       = 17'b1101x00xxxxxxxxx0,
										NOR_OP_CW   = 17'b0001x0000110000x1,
										OR_OP_CW    = 17'b0001x0000010000x1,
										SLL_OP_CW   = 17'b0001x0011001000x1,
										SLLV_CW     = 17'b0001x0011000000x1,
										SLT_CW      = 17'b0001x0010110000x1,
										SLTU_CW     = 17'b0001x001010000001,
										SRA_OP_CW   = 17'b0001x0011111000x1,
										SRAV_CW     = 17'b0001x0011110000x1,
										SRL_OP_CW   = 17'b0001x0011101000x1,
										SRLV_CW     = 17'b0001x0011100000x1,
										SUB_CW      = 17'b0001x0001110000x1,
										XOR_OP_CW   = 17'b0001x0000100000x1,
										NOTHING		= 17'b0
								} cw_t;
								
cw_t controlWord;
					  
always_comb
begin: dcr_mcu

	instructionWord = iw_t'({ OpcodeInMCU, RtInMCU[0], FuncInMCU, GSEInMCU });

	casex (instructionWord)	
		ADDI	 : controlWord = ADDI_CW;
		ADDIU    : controlWord = ADDI_CW;
		ANDI     : controlWord = ANDI_CW;
		BEQ      : controlWord = BEQ_CW;
		BEQ_not  : controlWord = BEQ_not_CW;
		BGEZ_gr  : controlWord = BRN_gr_CW;
		BGEZ_eq  : controlWord = BRN_gr_CW;
		BGEZ_not : controlWord = BRN_not_CW;
		BLTZ     : controlWord = BRN_gr_CW;
		BLTZ_not : controlWord = BRN_not_CW;
		BGTZ     : controlWord = BRN_gr_CW;
		BGTZ_not : controlWord = BRN_not_CW;
		BLEZ_lt  : controlWord = BRN_gr_CW;
		BLEZ_eq  : controlWord = BRN_gr_CW;
		BLEZ_not : controlWord = BRN_not_CW;
		BNE      : controlWord = BEQ_CW;
		BNE_not  : controlWord = BEQ_not_CW;
		J        : controlWord = J_CW;
		JAL      : controlWord = JAL_CW;
		LUI      : controlWord = LUI_CW;
		LW       : controlWord = LW_CW;
		ORI      : controlWord = ORI_CW;
		SLTI     : controlWord = SLTI_CW;
		SLTIU    : controlWord = SLTIU_CW;
		SW       : controlWord = SW_CW;
		XORI     : controlWord = XORI_CW;
		ADD      : controlWord = ADD_CW;
		ADDU     : controlWord = ADD_CW;
		AND_OP   : controlWord = AND_OP_CW;
		JALR     : controlWord = JALR_CW;
		JR       : controlWord = JR_CW;
		NOR_OP   : controlWord = NOR_OP_CW;
		OR_OP    : controlWord = OR_OP_CW;
		SLL_OP   : controlWord = SLL_OP_CW;
	   	SLLV     : controlWord = SLLV_CW;
		SLT      : controlWord = SLT_CW;
		SLTU     : controlWord = SLTU_CW;
		SRA_OP   : controlWord = SRA_OP_CW;
		SRAV     : controlWord = SRAV_CW;
		SRL_OP   : controlWord = SRL_OP_CW;
		SRLV     : controlWord = SRLV_CW;
		SUB      : controlWord = SUB_CW;
		SUBU     : controlWord = SUB_CW;
		XOR_OP   : controlWord = XOR_OP_CW;
		default  : controlWord = NOTHING;
	endcase

	PCSrcOutPMCU = controlWord[16:15];
	WriteDestOutPMCU = controlWord[14:13];
	WithZeroOutPMCU = controlWord[12];
   	MemWriteOutPMCU = controlWord[11];
	MemReadOutPMCU = controlWord[10];
	ALUControlOutPMCU = controlWord[9:6];
	ALUSrcXOutPMCU = controlWord[5:4];
	ALUSrcYOutPMCU = controlWord[3:2];
   	SignExtOutPMCU = controlWord[1];
	RegWriteOutPMCU = controlWord[0];
	
end

endmodule