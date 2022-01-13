class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "random_sequence_item");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)

//       req = sequence_item::type_id::create("req");
        `uvm_create(req);

        repeat (N_TESTS) begin : random_loop
//         start_item(req);
//         assert(req.randomize());
//         finish_item(req);
         `uvm_rand_send(req)
        end : random_loop
    endtask : body

    

endclass : random_sequence