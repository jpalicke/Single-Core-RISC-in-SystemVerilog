/*-----------------------------------------------------------------------------

	file name: dcr_RegFile.sv
	language: SystemVerilog
	description: 32bit x 32 register file
	
	Author: Joseph Palicke
	Group: Anas Farooq, Joseph Palicke
	Project: Dual-core CPU Microarchitecture in SystemVerilog
	
	Date: 2/1/2017
	Version: 1.0
	
-----------------------------------------------------------------------------*/

module dcr_RegFile(	input  logic [31:0] wrdata,
			input  logic [4:0]  rdaddr1, 
			input  logic [4:0]  rdaddr2, 
			input  logic [4:0]  wraddr,
			input  logic 	    clk, 
			input  logic 	    rst, 
			input  logic 	    wren,
			output logic [31:0] rddata1, 
			output logic [31:0] rddata2
		   );


reg [31:0] reg_file [31:0];

// muxes for reading data
// the selection bit here
// takes care of the zeroes
// for reg[0]

always_comb
begin
	
	// provide for forwarding from wrdata to rddata1 and 2 on
	// simultaneous read/writes

	// no forwarding for rdaddr == 0!!!

	if ((rdaddr1 == wraddr) && wren) begin	
		rddata1 = (rdaddr1 == 5'b0)? 32'b0 : wrdata;
	end else begin
		rddata1 = (rdaddr1 == 5'b0)? 32'b0 : reg_file[rdaddr1];
	end

	if ((rdaddr2 == wraddr) && wren) begin
		rddata2 = (rdaddr2 == 5'b0)? 32'b0 : wrdata; 
	end else begin
		rddata2 = (rdaddr2 == 5'b0)? 32'b0 : reg_file[rdaddr2];
	end
end
// instantiate ffs for register file

always_ff @(posedge clk or posedge rst)
begin //begin always block

// first part takes care of reset case

if (rst) begin // begin if

	// for loop steps through each line of the register file
	// and zeroes it
	
	for (integer i = 0; i < 32; i++) begin // begin for
		
		reg_file[i] <= 32'd0;
	
	end // end for
	
	// flop in write data on wren

end else if (wren && wraddr != 0) begin
	
		reg_file[wraddr] <= wrdata;
		
end // end if

end //end always block

endmodule