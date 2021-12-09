class add_tester extends random_tester;
    
    `uvm_component_utils (add_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    protected function operation_t get_op(input bit insert_error);
        bit [2:0] op_choice;
        return alu_pkg::add_op;
    endfunction : get_op
    
endclass