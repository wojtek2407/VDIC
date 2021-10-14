`timescale 1ns/1ps


module alu_tb();
	
	reg clk;
	reg rst_n;
	reg sin;
	
	always #10 clk = ~clk;
	
	wire sout;

	mtm_Alu u_mtm_Alu (
		.clk  (clk), //posedge active clock
		.rst_n(rst_n), //synchronous reset active low
		.sin  (sin), //serial data input
		.sout (sout) //serial data output
        );
	
	initial begin
		
        clk = 1'b0;
        rst_n = 1'b0;
        sin = 1'b1;
        #1000;
        rst_n = 1'b1;
        
        #1000;
        
        test1;
        
        #100000;

		$display("PASS");
		$finish();
	end
	
	task send_data(input reg [7:0] data);
        integer i;
		begin
			repeat(2) @(negedge clk) sin = 1'b0;
			for (i = 0; i < 8; i = i + 1)
                @(negedge clk) sin = data[7-i];
			@(negedge clk) sin = 1'b1;
		end
	endtask
	
    task send_cmd(input reg [7:0] cmd);
        integer i;
        begin
            @(negedge clk) sin = 1'b0;
            @(negedge clk) sin = 1'b1;
            for (i = 0; i < 8; i = i + 1)
                @(negedge clk) sin = cmd[7-i];
            @(negedge clk) sin = 1'b1;
        end
    endtask

	task test1;
		begin
			repeat(7) send_data(0);
            send_data(1);
            send_cmd(8'haa);
		end
	endtask
	
endmodule