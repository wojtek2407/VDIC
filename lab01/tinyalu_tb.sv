/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {no_op = 3'b000,
    add_op                   = 3'b001,
    and_op                   = 3'b010,
    xor_op                   = 3'b011,
    mul_op                   = 3'b100,
    rst_op                   = 3'b111} operation_t;
bit         [7:0]  A;
bit         [7:0]  B;
bit                clk;
bit                reset_n;
wire        [2:0]  op;
bit                start;
wire               done;
wire        [15:0] result;
operation_t        op_set;

assign op = op_set;

string             test_result = "PASSED";

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

tinyalu DUT (.A, .B, .clk, .op, .reset_n, .start, .done, .result);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen
    clk = 0;
    forever begin : clk_frv
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

function operation_t get_op();
    bit [2:0] op_choice;
    op_choice = $random;
    case (op_choice)
        3'b000 : return no_op;
        3'b001 : return add_op;
        3'b010 : return and_op;
        3'b011 : return xor_op;
        3'b100 : return mul_op;
        3'b101 : return no_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
    endcase // case (op_choice)
endfunction : get_op

//---------------------------------
function byte get_data();
    bit [1:0] zero_ones;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        return 8'h00;
    else if (zero_ones == 2'b11)
        return 8'hFF;
    else
        return 8'($random);
endfunction : get_data

//------------------------
// Tester main

initial begin : tester
    reset_alu();
    repeat (100) begin : tester_main
        @(negedge clk);
        op_set = get_op();
        A      = get_data();
        B      = get_data();
        start  = 1'b1;
        case (op_set) // handle the start signal
            no_op: begin : case_no_op
                @(negedge clk);
                start                             = 1'b0;
            end
            rst_op: begin : case_rst_op
                reset_alu();
            end
            default: begin : case_default
                wait(done);
                @(negedge clk);
                start                             = 1'b0;

                //------------------------------------------------------------------------------
                // temporary data check - scoreboard will do the job later
                begin
                    automatic bit [15:0] expected = get_expected(A, B, op_set);
                    assert(result === expected) begin
                        `ifdef DEBUG
                        $display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
                        `endif
                    end
                    else begin
                        $display("Test FAILED for A=%0d B=%0d op_set=%0d", A, B, op);
                        $display("Expected: %d  received: %d", expected, result);
                        test_result = "FAILED";
                    end;
                end

            end
        endcase // case (op_set)
    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
    end
    $finish;
end : tester
//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset_alu();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_alu", $time);
    `endif
    start   = 1'b0;
    reset_n = 1'b0;
    @(negedge clk);
    reset_n = 1'b1;
endtask

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
function logic [15:0] get_expected(
        bit [7:0] A,
        bit [7:0] B,
        operation_t op_set
    );
    bit [15:0] ret;
    `ifdef DEBUG
    $display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, A, B, op_set);
    `endif
    case(op_set)
        and_op : ret = A & B;
        add_op : ret = A + B;
        mul_op : ret = A * B;
        xor_op : ret = A ^ B;
        default: begin
            $display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
            test_result = "FAILED";
            return -1;
        end
    endcase
    return(ret);
endfunction
//------------------------------------------------------------------------------
// Temporary. The scoreboard data will be later used.
final begin : finish_of_the_test
    $display("Test %s.",test_result);
end
//------------------------------------------------------------------------------
endmodule : top
