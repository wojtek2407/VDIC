class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

//------------------------------------------------------------------------------
// configuration object
//------------------------------------------------------------------------------

    alu_agent_config tinyalu_agent_config_h;

//------------------------------------------------------------------------------
// testbench components
//------------------------------------------------------------------------------

    tester tester_h;
    driver driver_h;
    scoreboard scoreboard_h;
    coverage coverage_h;
    command_monitor command_monitor_h;
    result_monitor result_monitor_h;

    uvm_tlm_fifo #(command_transaction) command_f;
    uvm_analysis_port #(command_transaction) cmd_mon_ap;
    uvm_analysis_port #(result_transaction) result_ap;

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

        // get the agent configuration
        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", tinyalu_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get config object");

        if (tinyalu_agent_config_h.get_is_active() == UVM_ACTIVE) begin : make_stimulus
            command_f = new("command_f", this);
            tester_h  = tester::type_id::create( "tester_h",this);
            driver_h  = driver::type_id::create("driver_h",this);
        end

        command_monitor_h = command_monitor::type_id::create("command_monitor_h",this);
        result_monitor_h  = result_monitor::type_id::create("result_monitor_h",this);

        coverage_h        = coverage::type_id::create("coverage_h",this);
        scoreboard_h      = scoreboard::type_id::create("scoreboard_h",this);

        cmd_mon_ap        = new("cmd_mon_ap",this);
        result_ap         = new("result_ap", this);

    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        if (tinyalu_agent_config_h.get_is_active() == UVM_ACTIVE) begin : make_stimulus
            driver_h.command_port.connect(command_f.get_export);
            tester_h.command_port.connect(command_f.put_export);
        end

        command_monitor_h.ap.connect(cmd_mon_ap);
        result_monitor_h.ap.connect(result_ap);

        command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        command_monitor_h.ap.connect(coverage_h.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);

    endfunction : connect_phase


endclass : alu_agent

