class tester;
    
    virtual alu_bfm bfm;  
    
    function new (virtual alu_bfm b);
        bfm = b;
    endfunction : new

    task execute();
        automatic queue_element_t e;
        bfm.reset_alu();
        repeat (N_TESTS) begin : tester_main

            e.insert_op_error         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert opcode error with 1/32 probability
            e.insert_crc_error        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert crc error with 1/32 probability
            e.insert_data_bit_error   = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data frame error with 1/32 probability
            e.insert_data_frame_error = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data bit error with 1/32 probability
            e.reset_alu_before        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU before operation with 1/32 probability
            e.reset_alu_after         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU after operation with 1/32 probability
            e.second_execution        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // execute the same operation second time with 1/32 probability
            
            e.op_set = get_op(e.insert_op_error);
            e.A      = get_data();
            e.B      = get_data();  
            
            bfm.enqueue_element(e);

        end
    endtask
       
    //---------------------------------
    // Random data generation functions
    
    protected function operation_t get_op(input bit insert_error);
        bit [2:0] op_choice;
        op_choice = insert_error ? $urandom_range(7,4) : $urandom_range(3,0);
        case (op_choice)
            0 : return alu_pkg::and_op;
            1 : return alu_pkg::or_op;
            2 : return alu_pkg::add_op;
            3 : return alu_pkg::sub_op;
            4 : return alu_pkg::bad_op1;
            5 : return alu_pkg::bad_op2;
            6 : return alu_pkg::bad_op3;
            7 : return alu_pkg::bad_op4;
            default : $warning("should never happen");
        endcase // case (op_choice)
    endfunction : get_op
    
    //---------------------------------
    protected function bit [31:0] get_data();
        bit [1:0] zero_ones;
        zero_ones = 2'($random);
        if (zero_ones == 2'b00)
            return 32'h00000000;
        else if (zero_ones == 2'b11)
            return 32'hFFFFFFFF;
        else
            return 32'($random);
    endfunction : get_data
    
endclass