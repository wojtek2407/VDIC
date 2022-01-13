class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)

    protected virtual alu_bfm bfm;
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        sequence_item cmd;

        void'(begin_tr(cmd));

        forever begin : cmd_loop
            shortint unsigned result;
            seq_item_port.get_next_item(cmd);
            
            bfm.enqueue_element(cmd);

            seq_item_port.item_done();
        end : cmd_loop

        end_tr(cmd);

    endtask : run_phase

//    task run_phase(uvm_phase phase);
//        command_transaction command;
//
//        forever begin : command_loop
//            command_port.get(command);
//            bfm.enqueue_element(command);
//        end : command_loop
//    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver
