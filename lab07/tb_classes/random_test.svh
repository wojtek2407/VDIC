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
        // other printers available:
        // - uvm_default_line_printer
        // - uvm_default_tree_printer
        set_print_color(COLOR_BLUE_ON_WHITE);
        this.print(uvm_default_table_printer); // print test env topology
        set_print_color(COLOR_DEFAULT);
    endfunction : end_of_elaboration_phase

endclass