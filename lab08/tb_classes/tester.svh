class tester extends uvm_component;
    `uvm_component_utils (tester)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        command_transaction command;

        phase.raise_objection(this);

        command    = command_transaction::type_id::create("command");
        repeat (N_TESTS) begin
            assert(command.randomize());
            command_port.put(command);
        end

        phase.drop_objection(this);
    endtask : run_phase


endclass : tester