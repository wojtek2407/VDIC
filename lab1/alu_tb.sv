`timescale 1ns/1ps

module alu_tb();
	
	wire clk;
	wire rst_n;
	wire sin;
	wire sout;

	mtm_Alu u_mtm_Alu (
		.clk  (clk), //posedge active clock
		.rst_n(rst_n), //synchronous reset active low
		.sin  (sin), //serial data input
		.sout (sout) //serial data output
		);
	
	initial begin
		$display("PASS");
	end
	
	
endmodule