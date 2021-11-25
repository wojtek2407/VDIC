class scoreboard;
    
    virtual alu_bfm bfm;   
    protected string test_result = "PASSED";   
    protected queue_element_t e;
    
    function new (virtual alu_bfm b);
        bfm = b;
    endfunction : new
    
    task execute();
        forever begin : scoreboard  
            bfm.dequeue_element(e);
            check_errors();
            if (bfm.receive_queue.size() == 0 && bfm.send_queue.size() == 0) begin
                $display(test_result);
                $finish;
            end
        end : scoreboard
    endtask

    protected function automatic logic [3:0] get_expected_flags(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set,
            reg [3:0] ret_flags = alu_pkg::None_flag
        );
        bit signed [31:0] ret;
        bit [32:0] carry_check;
        case(op_set)
            alu_pkg::and_op : ret = A & B;
            alu_pkg::or_op :  ret = A | B;
            alu_pkg::add_op : begin
                ret = A + B;
                carry_check = {1'b0, A} + {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b0 && ret[31] == 1'b1) ret_flags = ret_flags | alu_pkg::Overflow_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b1 && ret[31] == 1'b0) ret_flags = ret_flags | alu_pkg::Overflow_flag;
            end
            alu_pkg::sub_op : begin
                ret = A - B;
                carry_check = {1'b0, A} - {1'b0, B}; 
                if (A[31] == 1'b0 && B[31] == 1'b1 && ret[31] == 1'b1) ret_flags = ret_flags | alu_pkg::Overflow_flag;
                else if (A[31] == 1'b1 && B[31] == 1'b0 && ret[31] == 1'b0) ret_flags = ret_flags | alu_pkg::Overflow_flag;            
            end 
            default: ret = -1;
        endcase
           
        if (carry_check[32] == 1'b1) ret_flags = ret_flags | alu_pkg::Carry_flag;
        if (ret < 0) ret_flags = ret_flags | alu_pkg::Negative_flag;
        if (ret == 0) ret_flags = ret_flags | alu_pkg::Zero_flag;

        return(ret_flags);
    endfunction
    
    function automatic logic signed [31:0] get_expected_result(
            bit signed [31:0] A,
            bit signed [31:0] B,
            operation_t op_set
        );
        bit signed [31:0] ret;
        case(op_set)
            alu_pkg::and_op : ret = A & B;
            alu_pkg::or_op :  ret = A | B;
            alu_pkg::add_op : ret = A + B;
            alu_pkg::sub_op : ret = A - B;
            default: ret = -1;
        endcase
        
        return(ret);
    endfunction
    
    protected task check_errors();
        begin
            
            automatic bit signed   [31:0] expected       = get_expected_result(e.A, e.B, e.op_set);
            automatic bit unsigned [ 3:0] expected_flags = get_expected_flags(e.A, e.B, e.op_set);
            automatic bit unsigned [ 2:0] expected_crc   = nextCRC3_D37({expected, 1'b0, expected_flags}, 3'b0);
            
            automatic bit crc_mismatch  = (e.err === 1'b0) && (e.crc !== expected_crc);
            automatic bit flag_error    = (e.err === 1'b0) && (e.flags !== expected_flags);
            automatic bit value_error   = (e.err === 1'b0) && (e.C !== expected);
            automatic bit data_error    = (e.err === 1'b1) && e.err_flags[2] && e.err_flags[5];
            automatic bit crc_error     = (e.err === 1'b1) && e.err_flags[1] && e.err_flags[4];
            automatic bit op_error      = (e.err === 1'b1) && e.err_flags[0] && e.err_flags[3];
            automatic bit parity_error  = (e.err === 1'b1) && (^{1'b1, e.err_flags, e.parity} === 1'b1);
            
            automatic bit [6:0] errors = {crc_mismatch, flag_error, value_error, data_error, crc_error, op_error, parity_error};
            automatic bit [6:0] errors_expected = {
                e.insert_data_bit_error,                            // mask crc_mismatch
                e.insert_data_bit_error,                            // mask flag_error
                e.insert_data_bit_error,                            // mask_value_error
                e.insert_data_frame_error,                          // mask data_error
                e.insert_crc_error || e.insert_data_bit_error,      // mask crc_error
                e.insert_op_error,                                  // mask op_error
                1'b0                                                // mask parity error
            }; 
            
            // Handle errors not specified in documentation
            automatic bit unknown_error = (e.err === 1'b1) && ~(data_error || crc_error || op_error || parity_error);
            
            // mask expected errors
            errors = errors & (~errors_expected);

            assert (!errors && !unknown_error) begin
                `ifdef DEBUG
                    $display("Test passed for A=%0d B=%0d op_set=%0d", e.A, e.B, e.op_set);
                `endif
                end
            else begin
                $warning("Test FAILED");
                $warning("\tInput Data: A=%0d B=%0d op_set=%0d", e.A, e.B, e.op_set);
                if (errors & (1 << 0)) $warning("\tUnexpected parity error in error frame.");
                if (errors & (1 << 1)) $warning("\tUnexpected opcode error.");
                if (errors & (1 << 2)) $warning("\tUnexpected crc error.");
                if (errors & (1 << 3)) $warning("\tUnexpected data frame error.");
                if (errors & (1 << 4)) $warning("\tUnexpected value error. Expected: %d  received: %d", expected, e.C);
                if (errors & (1 << 5)) $warning("\tUnexpected flag error. Expected: %b  received: %b", expected_flags, e.flags);
                if (errors & (1 << 6)) $warning("\tUnexpected crc mismatch. Expected: %b  received: %b", expected_crc, e.crc);
                if (unknown_error) $warning("\tUnknown error");
                test_result = "FAILED";
            end          
        end
    endtask
    
    protected function [2:0] nextCRC3_D37;
        input [36:0] Data;
        input [2:0] crc;
        reg [36:0] d;
        reg [2:0] c;
        reg [2:0] newcrc;
      begin
        d = Data;
        c = crc;
    
        newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
        newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
        newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
        nextCRC3_D37 = newcrc;
      end
      endfunction
    
endclass