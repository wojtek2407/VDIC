`timescale 1ns/1ps


module alu_tb();
    
    //------------------------------------------------------------------------------
    // type and variable definitions
    //------------------------------------------------------------------------------
    
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
    
    bit                sin;
    wire               sout;
    bit                clk;
    bit                rst_n;
    bit                [31:0]  A;
    bit                [31:0]  B;
    bit insert_crc_error;
    bit insert_op_error;
    bit reset_alu_before;
    bit reset_alu_after;
    bit insert_data_frame_error;
    bit second_execution;
    bit insert_data_bit_error;
    event test_end;
    event scoreboard_end;
    reg err;
    reg signed [31:0] C;
    reg [3:0] flags;
    reg [2:0] crc;
    reg [5:0] err_flags;
    reg parity;
    wire [2:0] op;
    
    operation_t        op_set;
    assign op = op_set;
    
    string test_result = "PASSED";

    //------------------------------------------------------------------------------
    // DUT instantiation
    //------------------------------------------------------------------------------
	mtm_Alu u_mtm_Alu (
		.clk  (clk), //posedge active clock
		.rst_n(rst_n), //synchronous reset active low
		.sin  (sin), //serial data input
		.sout (sout) //serial data output
    );
    
    //------------------------------------------------------------------------------
    // CRC modules instantiation
    //------------------------------------------------------------------------------
    crc4 crc4();
    crc3 crc3();
    
    //------------------------------------------------------------------------------
    // Coverage block
    //------------------------------------------------------------------------------
    covergroup op_cov;
    
        option.name = "cg_op_cov";
    
        cp_op_set : coverpoint op_set {
            // #A1 test all operations
            bins A1_all_ops = {and_op,or_op,add_op,sub_op};
        }
        
        cp_reset_before : coverpoint reset_alu_before {
            bins reset_before = {1'b1};
        }
        
        cp_reset_after : coverpoint reset_alu_after {
            bins reset_after = {1'b1};
        }
        
        cp_reset_after_before_operations: cross cp_reset_before, cp_reset_after, cp_op_set {
            
            // #A2 execute all operations after reset
            bins A2_reset_before_and = binsof(cp_op_set) intersect {and_op} && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_or  = binsof(cp_op_set) intersect {or_op}  && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_add = binsof(cp_op_set) intersect {add_op} && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_sub = binsof(cp_op_set) intersect {sub_op} && binsof(cp_reset_before.reset_before);
            
            // #A3 execute reset after all operations
            bins A3_reset_after_and = binsof(cp_op_set) intersect {and_op} && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_or  = binsof(cp_op_set) intersect {or_op}  && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_add = binsof(cp_op_set) intersect {add_op} && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_sub = binsof(cp_op_set) intersect {sub_op} && binsof(cp_reset_after.reset_after);

        }
       
        cp_two_op : coverpoint op_set {
            // #A4 two operations in row
            bins A4_twoops = ([and_op:sub_op] [*2]);
        }
    
    endgroup
        
    covergroup errors_cov;
        
        option.name = "cg_errors_cov";  
        
        // #B1 Bad OP code error insertion
        coverpoint op_set {
            bins B1_bad_op = {bad_op1,bad_op2,bad_op3,bad_op4};
        }
        
        // #B2 CRC bit error insertion
        coverpoint insert_crc_error {
            bins B2_crc_bit_error = {1'b1};
        }
        
        // #B3 Data bit error insertion
        coverpoint insert_data_bit_error {
            bins B3_data_bit_error = {1'b1};
        }
        
        // #B4 Data bit error insertion
        coverpoint insert_data_frame_error {
            bins B4_data_frame_error = {1'b1};
        }
        
    endgroup
            
    covergroup min_max_cov;
        
        option.name = "cg_min_max_cov";  
        
        all_ops : coverpoint op_set {
            ignore_bins null_ops = {bad_op1,bad_op2,bad_op3,bad_op4};
        }
        
        a_leg : coverpoint A {
            bins zeros = {'h00000000};
            bins others = {['h1:'hfffffffe]};
            bins ones  = {'hffffffff};
        }
        b_leg : coverpoint B {
            bins zeros = {'h00000000};
            bins others = {['h1:'hfffffffe]};
            bins ones  = {'hffffffff};
        }
        
        B_op_00_FF: cross a_leg, b_leg, all_ops {
            
            // #C1 simulate all zero input for all the operations
            bins C1_and_00          = binsof (all_ops) intersect {and_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_or_00          = binsof (all_ops) intersect {or_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_add_00          = binsof (all_ops) intersect {add_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_sub_00          = binsof (all_ops) intersect {sub_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            
            // #C2 simulate all one input for all the operations
            bins C2_and_FF          = binsof (all_ops) intersect {and_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_or_FF          = binsof (all_ops) intersect {or_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_add_FF          = binsof (all_ops) intersect {add_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_sub_FF          = binsof (all_ops) intersect {sub_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            
            ignore_bins others_only = binsof(a_leg.others) && binsof(b_leg.others);
        }
        
    endgroup
    
    op_cov                      oc;
    min_max_cov                 c_00_FF;
    errors_cov                  er;
    
    initial begin : coverage
        oc = new();
        c_00_FF = new(); 
        er = new();
        forever begin : sample_cov
            @(test_end) begin
                oc.sample();
                c_00_FF.sample();
                er.sample();
            end
        end
    end : coverage
    
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

    
    //---------------------------
    // ALU send/receive functions
    //---------------------------
    
    typedef enum bit {DATA = 1'b0, CTL = 1'b1} transfer_type_t; 
    
    task ALU_send_byte(transfer_type_t transfer_type, input bit [7:0] data);
        integer i;
        begin
            @(negedge clk) sin = 1'b0;
            @(negedge clk) sin = transfer_type;
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) sin = data[7-i]; // MSB frist
            @(negedge clk) sin = 1'b1;           
        end
    endtask
    
    task ALU_send_32bit_operand(input bit [31:0] operand, input bit insert_error);
        integer i;
        begin
            for (i = 0; i < (insert_error ? $urandom_range(3, 0) : 4); i = i + 1)
                ALU_send_byte(DATA, operand[31-8*i-:8]);
        end
    endtask
    
    task ALU_send_ctl(input operation_t operation, input bit [3:0] crc);
        integer i;
        begin
            ALU_send_byte(CTL, {1'b0, operation, crc});
        end
    endtask
    
    task ALU_send(input bit [31:0] A, input bit [31:0] B, input operation_t operation, input bit insert_crc_error, input bit insert_data_bit_error, input bit insert_data_frame_error);
        integer i;
        bit [31:0] A_temp;
        bit [3:0] crc;
        begin
            // insert error at a random A operand bit to simulate transmission error;
            i = $urandom() % 32;
            A_temp = A;
            A_temp[i] = ~A_temp[i];
            
            ALU_send_32bit_operand(insert_data_bit_error ? A_temp : A, insert_data_frame_error);
            // dont send second operand if frame error expected
            ALU_send_32bit_operand(B, insert_data_frame_error);
            
            crc = crc4.nextCRC4_D68({A, B, 1'b1, operation}, 1'b0);
            // invert 2 crc bits to simulate crc error
            ALU_send_ctl(operation, insert_crc_error ? crc^4'b0100 : crc);
        end
    endtask
    
    task ALU_receive_byte(output bit [7:0] data, output transfer_type_t transfer_type);
        integer i;
        begin
            wait (sout === 1'b0);
            @(negedge clk);
            @(negedge clk) transfer_type = transfer_type_t'(sout);
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) data[7-i] = sout; // MSB frist
            wait (sout === 1'b1);
        end
    endtask
    
    task ALU_receive(output bit err, output bit signed [31:0] C, output bit [3:0] flags, output bit [2:0] crc, output bit [5:0] err_flags, bit parity);
        integer i;
        bit dummy;
        bit [7:0] received_data[5];
        transfer_type_t frame_types[5];
        begin
            ALU_receive_byte(received_data[0], frame_types[0]);          
            case (frame_types[0])
                DATA: begin : no_error
                    for (i = 1; i < 5; i = i + 1)   
                        ALU_receive_byte(received_data[i], frame_types[i]);
                    C = {received_data[0], received_data[1], received_data[2], received_data[3]};
                    {err_flags, parity} = 7'b0; // dont care
                    {flags, crc} = received_data[4][6:0];
                    err = 1'b0;
                end
                CTL: begin : error  
                    {err_flags, parity} = received_data[0][6:0];
                    {flags, crc} = 7'b0; // dont care
                    err = 1'b1;
                end
                default :
                    $warning("should never happen");
            endcase
        end
    endtask
    
        
    //------------------------------------------------------------------------------
    // Tester
    //------------------------------------------------------------------------------
    
    //---------------------------------
    // Random data generation functions
    
    function operation_t get_op(input bit insert_error);
        bit [2:0] op_choice;
        op_choice = insert_error ? $urandom_range(7,4) : $urandom_range(3,0);
        case (op_choice)
            0 : return and_op;
            1 : return or_op;
            2 : return add_op;
            3 : return sub_op;
            4 : return bad_op1;
            5 : return bad_op2;
            6 : return bad_op3;
            7 : return bad_op4;
            default : $warning("should never happen");
        endcase // case (op_choice)
    endfunction : get_op
    
    //---------------------------------
    function bit [31:0] get_data();
        bit [1:0] zero_ones;
        zero_ones = 2'($random);
        if (zero_ones == 2'b00)
            return 32'h00000000;
        else if (zero_ones == 2'b11)
            return 32'hFFFFFFFF;
        else
            return 32'($random);
    endfunction : get_data
    
    //------------------------
    // Tester main
    
    initial begin : tester
        reset_alu();
        repeat (100_000) begin : tester_main
            @(negedge clk);
            insert_op_error         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert opcode error with 1/32 probability
            insert_crc_error        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert crc error with 1/32 probability
            insert_data_bit_error   = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data frame error with 1/32 probability
            insert_data_frame_error = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data bit error with 1/32 probability
            reset_alu_before        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU before operation with 1/32 probability
            reset_alu_after         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU after operation with 1/32 probability
            second_execution        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // execute the same operation second time with 1/32 probability
            
            op_set = get_op(insert_op_error);
            A      = get_data();
            B      = get_data();  
            
            if (reset_alu_before) reset_alu();
            ALU_send(A, B, op_set, insert_crc_error, insert_data_bit_error, insert_data_frame_error);
            @(negedge clk);
            ->test_end; 
            @(scoreboard_end);
            if (second_execution) begin
                ALU_send(A, B, op_set, insert_crc_error, insert_data_bit_error, insert_data_frame_error);
                @(negedge clk); 
                ->test_end;
                @(scoreboard_end);
            end
            if (reset_alu_after) reset_alu();
 
            //print coverage after each loop
//             $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
//             if($get_coverage() == 100) break;
        end
        $display(test_result);
        $finish;
    end : tester

    
    //------------------------------------------------------------------------------
    // reset task
    //------------------------------------------------------------------------------
    task reset_alu();
        `ifdef DEBUG
        $display("%0t DEBUG: reset_alu", $time);
        `endif
        rst_n = 1'b0;
        sin = 1'b1;
        @(negedge clk);
        rst_n = 1'b1;
    endtask
    
    //------------------------------------------------------------------------------
    // calculate expected result
    //------------------------------------------------------------------------------
    function automatic logic [3:0] get_expected_flags(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set,
            reg [3:0] ret_flags = None_flag
        );
        bit signed [31:0] ret;
        bit [32:0] carry_check;
        case(op_set)
            and_op : ret = A & B;
            or_op :  ret = A | B;
            add_op : begin
                ret = A + B;
                carry_check = {1'b0, A} + {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b0 && ret[31] == 1'b1) ret_flags = ret_flags | Overflow_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b1 && ret[31] == 1'b0) ret_flags = ret_flags | Overflow_flag;
            end
            sub_op : begin
                ret = A - B;
                carry_check = {1'b0, A} - {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b1 && ret[31] == 1'b1) ret_flags = ret_flags | Overflow_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b0 && ret[31] == 1'b0) ret_flags = ret_flags | Overflow_flag;            
            end 
            default: ret = -1;
        endcase
           
        if (carry_check[32] == 1'b1) ret_flags = ret_flags | Carry_flag;
        if (ret < 0) ret_flags = ret_flags | Negative_flag;
        if (ret == 0) ret_flags = ret_flags | Zero_flag;

        return(ret_flags);
    endfunction
    
    function automatic logic signed [31:0] get_expected_result(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set
        );
        bit signed [31:0] ret;
        case(op_set)
            and_op : ret = A & B;
            or_op :  ret = A | B;
            add_op : ret = A + B;
            sub_op : ret = A - B;
            default: ret = -1;
        endcase
        
        return(ret);
    endfunction
    
    //------------------------------------------------------------------------------
    // Scoreboard
    //------------------------------------------------------------------------------  
    
    function automatic bit check_errors();
        begin
            automatic bit signed   [31:0] expected       = get_expected_result(A, B, op_set);
            automatic bit unsigned [ 3:0] expected_flags = get_expected_flags(A, B, op_set);
            automatic bit unsigned [ 2:0] expected_crc   = crc3.nextCRC3_D37({expected, 1'b0, expected_flags}, 3'b0);
            
            automatic bit crc_mismatch  = (err === 1'b0) && (crc !== expected_crc);
            automatic bit flag_error    = (err === 1'b0) && (flags !== expected_flags);
            automatic bit value_error   = (err === 1'b0) && (C !== expected);
            automatic bit data_error    = (err === 1'b1) && err_flags[2] && err_flags[5];
            automatic bit crc_error     = (err === 1'b1) && err_flags[1] && err_flags[4];
            automatic bit op_error      = (err === 1'b1) && err_flags[0] && err_flags[3];
            automatic bit parity_error  = (err === 1'b1) && (^{1'b1, err_flags, parity} === 1'b1);
            
            automatic bit [6:0] errors = {crc_mismatch, flag_error, value_error, data_error, crc_error, op_error, parity_error};
            automatic bit [6:0] errors_expected = {
                insert_data_bit_error,                            // mask crc_mismatch
                insert_data_bit_error,                            // mask flag_error
                insert_data_bit_error,                            // mask_value_error
                insert_data_frame_error,                          // mask data_error
                insert_crc_error || insert_data_bit_error,        // mask crc_error
                insert_op_error,                                  // mask op_error
                1'b0                                              // mask parity error
            }; 
            
            // Handle errors not specified in documentation
            automatic bit unknown_error = (err === 1'b1) && ~(data_error || crc_error || op_error || parity_error);
            
            bit return_value = 1'b0;
            
            // mask expected errors
            errors = errors & (~errors_expected);

            assert (!errors && !unknown_error) begin
                `ifdef DEBUG
                    $display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
                `endif
                end
            else begin
                $warning("Test FAILED");
                $warning("\tInput Data: A=%0d B=%0d op_set=%0d", A, B, op);
                if (errors & (1 << 0)) $warning("\tUnexpected parity error in error frame.");
                if (errors & (1 << 1)) $warning("\tUnexpected opcode error.");
                if (errors & (1 << 2)) $warning("\tUnexpected crc error.");
                if (errors & (1 << 3)) $warning("\tUnexpected data frame error.");
                if (errors & (1 << 4)) $warning("\tUnexpected value error. Expected: %d  received: %d", expected, C);
                if (errors & (1 << 5)) $warning("\tUnexpected flag error. Expected: %b  received: %b", expected_flags, flags);
                if (errors & (1 << 6)) $warning("\tUnexpected crc mismatch. Expected: %b  received: %b", expected_crc, crc);
                if (unknown_error) $warning("\tUnknown error");
                return_value = 1'b1;
            end          
            check_errors = return_value;
        end
    endfunction
    
    initial forever begin : scoreboard       
            @(test_end) begin:verify_result 
            ALU_receive(err, C, flags, crc, err_flags, parity); 
            if (check_errors()) test_result = "FAILED";
            ->scoreboard_end;
        end
    end : scoreboard
	
endmodule