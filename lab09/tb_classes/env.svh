class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench components
//------------------------------------------------------------------------------

    sequencer sequencer_h;
    coverage coverage_h;
    scoreboard scoreboard_h;
    driver driver_h;
    command_monitor command_monitor_h;
    result_monitor result_monitor_h;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);

        // stimulus
        sequencer_h       = sequencer::type_id::create("sequencer_h",this);
        driver_h          = driver::type_id::create("driver_h",this);

        // monitors
        command_monitor_h = command_monitor::type_id::create("command_monitor_h",this);
        result_monitor_h  = result_monitor::type_id::create("result_monitor",this);

        // analysis
        coverage_h        = coverage::type_id::create ("coverage_h",this);
        scoreboard_h      = scoreboard::type_id::create("scoreboard",this);

    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);

        driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

        command_monitor_h.ap.connect(coverage_h.analysis_export);
        command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
        
    endfunction : connect_phase


endclass : env