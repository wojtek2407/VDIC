class scoreboard extends uvm_subscriber#(result_transaction);
    
    `uvm_component_utils(scoreboard)
    
    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;
    protected test_result tr = TEST_PASSED;
    
    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;
    virtual alu_bfm bfm;
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction
    
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction 
    
    function void write(result_transaction t);
        string data_str;
        command_transaction cmd;
        result_transaction predicted;
        
        if (!cmd_f.try_get(cmd)) $fatal(1, "Missing command in self checker");
        predicted = new("predicted");
        predicted.result = cmd.e;
        predicted.result.C = get_expected_result(cmd.e.A, cmd.e.B, cmd.e.op_set);
        predicted.result.flags = get_expected_flags(cmd.e.A, cmd.e.B, cmd.e.op_set);
        predicted.result.crc = nextCRC3_D37({predicted.result.C, 1'b0, predicted.result.flags}, 3'b0);

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};

        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            tr = TEST_FAILED;
        end
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
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