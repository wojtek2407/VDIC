`timescale 1ns/1ps

package alu_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //------------------------------------------------------------------------------
    // type and variable definitions
    //------------------------------------------------------------------------------
    
    integer N_TESTS = 10_000;
    
    typedef enum bit[2:0] {
        and_op                   = 3'b000,
        or_op                    = 3'b001,
        add_op                   = 3'b100,
        sub_op                   = 3'b101,
        bad_op1                  = 3'b010,
        bad_op2                  = 3'b011,
        bad_op3                  = 3'b110,
        bad_op4                  = 3'b111
    } operation_t;
    
    typedef enum bit [3:0] {
        None_flag                = 4'b0000,
        Negative_flag            = 4'b0001,
        Zero_flag                = 4'b0010,
        Overflow_flag            = 4'b0100,
        Carry_flag               = 4'b1000
    } flag;
    
    typedef struct packed {
        bit [31:0]  A;
        bit [31:0]  B;
        bit insert_crc_error;
        bit insert_op_error;
        bit reset_alu_before;
        bit reset_alu_after;
        bit insert_data_frame_error;
        bit second_execution;
        bit insert_data_bit_error;
        bit err;
        bit signed [31:0] C;
        bit [3:0] flags;
        bit [2:0] crc;
        bit [5:0] err_flags;
        bit parity;
        operation_t op_set;
    } queue_element_t;
        
    typedef enum bit {DATA = 1'b0, CTL = 1'b1} transfer_type_t; 
    
    `include "driver.svh"
    `include "command_monitor.svh"
    `include "result_monitor.svh"
    `include "coverage.svh"
    `include "base_tester.svh"
    `include "random_tester.svh"
    `include "add_tester.svh"
    `include "minmax_tester.svh"
    `include "scoreboard.svh"
    `include "env.svh"
    `include "random_test.svh"
    `include "add_test.svh"
    `include "minmax_test.svh"
    
endpackage : alu_pkg