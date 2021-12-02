virtual class base_tester extends uvm_component;
    
    `uvm_component_utils(base_tester)
     
    virtual alu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

    pure virtual protected function operation_t get_op(input bit insert_error);
    pure virtual protected function bit [31:0] get_data();   

    task run_phase(uvm_phase phase);  
        automatic queue_element_t e;
        phase.raise_objection(this);
        bfm.reset_alu();

        repeat (N_TESTS) begin : tester_main

            e.insert_op_error         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert opcode error with 1/32 probability
            e.insert_crc_error        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert crc error with 1/32 probability
            e.insert_data_bit_error   = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data frame error with 1/32 probability
            e.insert_data_frame_error = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // insert data bit error with 1/32 probability
            e.reset_alu_before        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU before operation with 1/32 probability
            e.reset_alu_after         = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // reset ALU after operation with 1/32 probability
            e.second_execution        = ($urandom() % 32 == 0) ? 1'b1 : 1'b0; // execute the same operation second time with 1/32 probability
            
            e.op_set = get_op(e.insert_op_error);
            e.A      = get_data();
            e.B      = get_data();  
            
            bfm.enqueue_element(e);

        end

        wait(bfm.receive_queue.size() == 0 && bfm.send_queue.size() == 0);
        phase.drop_objection(this);

    endtask : run_phase
    
endclass