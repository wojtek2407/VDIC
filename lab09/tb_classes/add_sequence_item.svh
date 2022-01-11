class add_sequence_item extends sequence_item;
    `uvm_object_utils(add_sequence_item)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint add_only {op_set == add_op;}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "add_sequence_item");
        super.new(name);
    endfunction : new

endclass : add_sequence_item