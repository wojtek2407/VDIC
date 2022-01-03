class add_transaction extends command_transaction;
    `uvm_object_utils(add_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint add_only {e.op_set == alu_pkg::add_op;}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : add_transaction