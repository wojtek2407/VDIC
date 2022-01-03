`timescale 1ns/1ps

module top;
import uvm_pkg::*;
`include "uvm_macros.svh"
import alu_pkg::*;

alu_bfm class_bfm();
mtm_Alu class_dut (
    .clk  (class_bfm.clk), //posedge active clock
    .rst_n(class_bfm.rst_n), //synchronous reset active low
    .sin  (class_bfm.sin), //serial data input
    .sout (class_bfm.sout) //serial data output
);
    
alu_bfm module_bfm();
mtm_Alu module_dut (
    .clk  (module_bfm.clk), //posedge active clock
    .rst_n(module_bfm.rst_n), //synchronous reset active low
    .sin  (module_bfm.sin), //serial data input
    .sout (module_bfm.sout) //serial data output
);   
    
    
// stimulus generator for module_dut
alu_tester_module stim_module(module_bfm);
    
initial begin
    uvm_config_db #(virtual alu_bfm)::set(null, "*", "class_bfm", class_bfm);
    uvm_config_db #(virtual alu_bfm)::set(null, "*", "module_bfm", module_bfm);
    run_test("dual_test");
end    

//initial begin
//    uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
//    run_test();
//end

endmodule : top