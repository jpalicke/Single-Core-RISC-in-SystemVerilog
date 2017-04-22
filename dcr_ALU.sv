/*-----------------------------------------------------------------------------

	file name: dcr_ALU.sv
	language: SystemVerilog
	description: SystemVerilog version of P3 processor ALU
	
	Author: Joseph Palicke
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_ALU(	input  logic [31:0] x, 
	        input  logic [31:0] y,
		input  logic [3:0] funct,
		output logic [31:0] result
		);

always_comb
begin: dcr_ALU
	case(funct)
		4'h0: result = x & y;			 // 0x0 - Bitwise AND		
		4'h1: result = x | y;			 // 0x1 - Bitwise OR	
		4'h2: result = x ^ y;			 // 0x2 - Bitwise XOR
		4'h3: result = ~(x | y);		 // 0x3 - Bitwise NOR		
		4'h4: result = x + y;		     	 // 0x4 - Unsigned addition		
		4'h5: result = x + y;  // 0x5 - Signed addition
		4'h6: result = x - y;			 // 0x6 - Unsigned subtraction
		4'h7: result = x - y;  // 0x7 - Signed Subtraction		
		4'hA: result = (x < y)?1'd1:1'd0;	 // 0xA - Unsigned set less than
		4'hB: result = (signed'(x) < signed'(y))?1'd1:1'd0;	// 0xB - Signed set less than
		4'hC: result = y << x;			 // 0xC - Shift Left Logical
		4'hE: result = y >> x;			 // 0XE - Shift Right Logical
		4'hF: result = $signed(y) >>> x;	 // OxF - Shift Right Arithmetic
		default: result = 32'b0;			
	endcase
end

endmodule