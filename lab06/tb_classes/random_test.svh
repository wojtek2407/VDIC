class random_test extends uvm_test;
    `uvm_component_utils(random_test)

    env env_h;
    
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        env_h = env::type_id::create("env_h",this);
    endfunction : build_phase
    
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.print(); // print test environment topology
    endfunction : end_of_elaboration_phase

endclass