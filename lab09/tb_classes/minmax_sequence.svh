class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence_item");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)

        `uvm_create(req);

        repeat (N_TESTS) begin : random_loop
        `uvm_do_with(req, {A dist {32'h0 := 1, 32'hFFFF_FFFF := 1};
                           B dist {32'h0 := 1, 32'hFFFF_FFFF := 1};})
        end : random_loop
    endtask : body

    

endclass : minmax_sequence