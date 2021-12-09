class scoreboard extends uvm_subscriber#(queue_element_t);
    
    `uvm_component_utils(scoreboard)
    
    uvm_tlm_analysis_fifo #(queue_element_t) cmd_f;
    virtual alu_bfm bfm;
    protected queue_element_t cmd;
    protected queue_element_t resp;
    
    
    protected string test_result = "PASSED";   
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
    function void report_phase(uvm_phase phase);
        $display(test_result);
    endfunction 
    
    function void write(queue_element_t t);
        if (!cmd_f.try_get(cmd)) $fatal(1, "Missing command in self checker");
        resp = t;
        check_errors();
    endfunction

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
    
    protected function void check_errors();
        begin
            
            automatic bit signed   [31:0] expected       = get_expected_result(cmd.A, cmd.B, cmd.op_set);
            automatic bit unsigned [ 3:0] expected_flags = get_expected_flags(cmd.A, cmd.B, cmd.op_set);
            automatic bit unsigned [ 2:0] expected_crc   = nextCRC3_D37({expected, 1'b0, expected_flags}, 3'b0);
            
            automatic bit crc_mismatch  = (resp.err === 1'b0) && (resp.crc !== expected_crc);
            automatic bit flag_error    = (resp.err === 1'b0) && (resp.flags !== expected_flags);
            automatic bit value_error   = (resp.err === 1'b0) && (resp.C !== expected);
            automatic bit data_error    = (resp.err === 1'b1) && resp.err_flags[2] && resp.err_flags[5];
            automatic bit crc_error     = (resp.err === 1'b1) && resp.err_flags[1] && resp.err_flags[4];
            automatic bit op_error      = (resp.err === 1'b1) && resp.err_flags[0] && resp.err_flags[3];
            automatic bit parity_error  = (resp.err === 1'b1) && (^{1'b1, resp.err_flags, resp.parity} === 1'b1);
            
            automatic bit [6:0] errors = {crc_mismatch, flag_error, value_error, data_error, crc_error, op_error, parity_error};
            automatic bit [6:0] errors_expected = {
                cmd.insert_data_bit_error,                            // mask crc_mismatch
                cmd.insert_data_bit_error,                            // mask flag_error
                cmd.insert_data_bit_error,                            // mask_value_error
                cmd.insert_data_frame_error,                          // mask data_error
                cmd.insert_crc_error || cmd.insert_data_bit_error,    // mask crc_error
                cmd.insert_op_error,                                  // mask op_error
                1'b0                                                  // mask parity error
            }; 
            
            // Handle errors not specified in documentation
            automatic bit unknown_error = (resp.err === 1'b1) && ~(data_error || crc_error || op_error || parity_error);
            
            // mask expected errors
            errors = errors & (~errors_expected);

            assert (!errors && !unknown_error) begin
                `ifdef DEBUG
                    $display("Test passed for A=%0d B=%0d op_set=%0d", e.A, e.B, e.op_set);
                `endif
                end
            else begin
                $warning("Test FAILED");
                $warning("\tInput Data: A=%0d B=%0d op_set=%0d", resp.A, resp.B, resp.op_set);
                if (errors & (1 << 0)) $warning("\tUnexpected parity error in error frame.");
                if (errors & (1 << 1)) $warning("\tUnexpected opcode error.");
                if (errors & (1 << 2)) $warning("\tUnexpected crc error.");
                if (errors & (1 << 3)) $warning("\tUnexpected data frame error.");
                if (errors & (1 << 4)) $warning("\tUnexpected value error. Expected: %d  received: %d", expected, resp.C);
                if (errors & (1 << 5)) $warning("\tUnexpected flag error. Expected: %b  received: %b", expected_flags, resp.flags);
                if (errors & (1 << 6)) $warning("\tUnexpected crc mismatch. Expected: %b  received: %b", expected_crc, resp.crc);
                if (unknown_error) $warning("\tUnknown error");
                test_result = "FAILED";
            end          
        end
    endfunction 
    
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