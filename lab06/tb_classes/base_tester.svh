virtual class base_tester extends uvm_component;

    uvm_put_port #(queue_element_t) command_port;
    
    pure virtual protected function operation_t get_op(input bit insert_error);
    pure virtual protected function bit [31:0] get_data();  
    
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase


    task run_phase(uvm_phase phase);  
        automatic queue_element_t e;
        phase.raise_objection(this);

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
            
            command_port.put(e);

        end

        phase.drop_objection(this);

    endtask : run_phase
       
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
endclass