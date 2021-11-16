`timescale 1ns/1ps

module alu_tb();

    alu_bfm bfm();
    tester tester(.bfm);
    scoreboard scoreboard(.bfm);
    coverage coverage(.bfm);
    
    //------------------------------------------------------------------------------
    // DUT instantiation
    //------------------------------------------------------------------------------
	mtm_Alu u_mtm_Alu (
		.clk  (bfm.clk), //posedge active clock
		.rst_n(bfm.rst_n), //synchronous reset active low
		.sin  (bfm.sin), //serial data input
		.sout (bfm.sout) //serial data output
    );

endmodule