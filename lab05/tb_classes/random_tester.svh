class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
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