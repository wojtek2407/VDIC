class env_config;

//------------------------------------------------------------------------------
// configuration variables
//------------------------------------------------------------------------------

    virtual alu_bfm class_bfm;
    virtual alu_bfm module_bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(virtual alu_bfm class_bfm, virtual alu_bfm module_bfm);
        this.class_bfm  = class_bfm;
        this.module_bfm = module_bfm;
    endfunction : new

endclass : env_config