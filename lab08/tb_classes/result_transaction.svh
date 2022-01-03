class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    queue_element_t result;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        result_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h,rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        result = copied_transaction_h.result;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("C: %8h  err_flags: %6b", result.C, result.err_flags);
        return s;
    endfunction : convert2string

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        result_transaction RHS;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);
        same = (check_errors(result, RHS.result)) && same;
        return same;
    endfunction : do_compare
    
    protected function bit check_errors(input queue_element_t cmd, input queue_element_t resp);
        begin
            
            automatic bit crc_mismatch  = (resp.err === 1'b0) && (resp.crc !== cmd.crc);
            automatic bit flag_error    = (resp.err === 1'b0) && (resp.flags !== cmd.flags);
            automatic bit value_error   = (resp.err === 1'b0) && (resp.C !== cmd.C);
            automatic bit data_error    = (resp.err === 1'b1) && resp.err_flags[2] && resp.err_flags[5];
            automatic bit crc_error     = (resp.err === 1'b1) && resp.err_flags[1] && resp.err_flags[4];
            automatic bit op_error      = (resp.err === 1'b1) && resp.err_flags[0] && resp.err_flags[3];
            automatic bit parity_error  = (resp.err === 1'b1) && (^{1'b1, resp.err_flags, resp.parity} === 1'b1);
            
            automatic bit [6:0] errors = {crc_mismatch, flag_error, value_error, data_error, crc_error, op_error, parity_error};
            automatic bit [6:0] errors_expected = {
                cmd.insert_data_bit_error,                              // mask crc_mismatch
                cmd.insert_data_bit_error,                              // mask flag_error
                cmd.insert_data_bit_error,                              // mask_value_error
                cmd.insert_data_frame_error,                            // mask data_error
                cmd.insert_crc_error || cmd.insert_data_bit_error,      // mask crc_error
                cmd.op_set inside {[alu_pkg::bad_op1:alu_pkg::bad_op4]},// mask op_error
                1'b0                                                    // mask parity error
            }; 
            
            // Handle errors not specified in documentation
            automatic bit unknown_error = (resp.err === 1'b1) && ~(data_error || crc_error || op_error || parity_error);
            
            // mask expected errors
            errors = errors & (~errors_expected);

            assert (!errors && !unknown_error) begin
                `ifdef DEBUG
                    $display("Test passed for A=%0d B=%0d op_set=%0d", e.A, e.B, e.op_set);
                `endif
                    return 1;
                end
            else begin
                `ifdef DEBUG
                $warning("Test FAILED");
                $warning("\tInput Data: A=%0d B=%0d op_set=%0d", resp.A, resp.B, resp.op_set);
                if (errors & (1 << 0)) $warning("\tUnexpected parity error in error frame.");
                if (errors & (1 << 1)) $warning("\tUnexpected opcode error.");
                if (errors & (1 << 2)) $warning("\tUnexpected crc error.");
                if (errors & (1 << 3)) $warning("\tUnexpected data frame error.");
                if (errors & (1 << 4)) $warning("\tUnexpected value error. Expected: %d  received: %d", cmd.C, resp.C);
                if (errors & (1 << 5)) $warning("\tUnexpected flag error. Expected: %b  received: %b", cmd.flags, resp.flags);
                if (errors & (1 << 6)) $warning("\tUnexpected crc mismatch. Expected: %b  received: %b", cmd.crc, resp.crc);
                if (unknown_error) $warning("\tUnknown error");
                `endif
                return 0;
            end          
        end
    endfunction 



endclass : result_transaction
