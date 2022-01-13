class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    local virtual alu_bfm bfm;
    uvm_analysis_port #(sequence_item) ap;
    
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")

        ap = new("ap",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase


    function void write_to_monitor(sequence_item cmd);
//        $display("COMMAND MONITOR: A:0x%2h B:0x%2h op: %s", cmd.A, cmd.B, cmd.op.name());
//        sequence_item x;
//        x.A = cmd.A;
//        x.B = cmd.B;
//        x.op_set = cmd.op_set;
//        x.insert_crc_error = cmd.insert_crc_error;
//        x.reset_alu_before = cmd.reset_alu_before;
//        x.reset_alu_after = cmd.reset_alu_after;
//        x.insert_data_frame_error = cmd.insert_data_frame_error;
//        x.second_execution = cmd.second_execution;
//        x.insert_data_bit_error = cmd.insert_data_bit_error;
        ap.write(cmd);
    endfunction : write_to_monitor

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

endclass : command_monitor