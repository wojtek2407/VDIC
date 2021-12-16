class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    uvm_analysis_port #(result_transaction) ap;
    virtual alu_bfm bfm;

    function void write_to_monitor(result_transaction r);
        result_transaction result_t;
        result_t        = new("result_t");
        result_t        = r;
        ap.write(result_t);
    endfunction : write_to_monitor

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        bfm.result_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : result_monitor