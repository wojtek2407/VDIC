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
    
        // terminal print colors
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;

    function void set_print_color ( print_color c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction

    `include "alu_agent_config.svh"
    `include "env_config.svh"
    
    `include "command_transaction.svh"
    `include "result_transaction.svh"
    `include "add_transaction.svh"
       
    `include "command_monitor.svh"
    `include "driver.svh"
    `include "result_monitor.svh"
    `include "coverage.svh"
    `include "tester.svh"
    `include "scoreboard.svh"
    `include "alu_agent.svh"
    `include "env.svh"
    
    `include "dual_test.svh"
    
endpackage : alu_pkg