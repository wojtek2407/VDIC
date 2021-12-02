class env extends uvm_env;
    `uvm_component_utils(env)

    /* xrun 18.1 warns about object definition from abstract class, will be
     * upgraded to error in future releases.
     * This is temporary solution -> sequencer/driver will not have this problem
     */
    base_tester tester_h;

    coverage coverage_h;
    scoreboard scoreboard_h;

    function void build_phase(uvm_phase phase);
        tester_h     = base_tester::type_id::create("tester_h",this);
        coverage_h   = coverage::type_id::create ("coverage_h",this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

endclass
