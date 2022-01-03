class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// agents
//------------------------------------------------------------------------------

    alu_agent class_alu_agent_h;
    alu_agent module_alu_agent_h;

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

        env_config env_config_h;
        alu_agent_config class_config_h;
        alu_agent_config module_config_h;

        // get the BFM set form the env_config
        if(!uvm_config_db #(env_config)::get(this, "","config", env_config_h))
            `uvm_fatal("ENV", "Failed to get config object");

        // create configs for the agents
        class_config_h         = new(.bfm(env_config_h.class_bfm), .is_active(UVM_ACTIVE));
        module_config_h        = new(.bfm(env_config_h.module_bfm), .is_active(UVM_PASSIVE));

        // store the agent configs in the UMV database
        // important: restricted access! see second argument
        uvm_config_db #(alu_agent_config)::set(this, "class_alu_agent_h*",
            "config", class_config_h);
        uvm_config_db #(alu_agent_config)::set(this, "module_alu_agent_h*",
            "config", module_config_h);

        // create the agents
        class_alu_agent_h  = alu_agent::type_id::create("class_alu_agent_h",this);
        module_alu_agent_h = alu_agent::type_id::create("module_alu_agent_h",this);

    endfunction : build_phase

endclass
