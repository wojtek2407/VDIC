class alu_agent_config;

//------------------------------------------------------------------------------
// configuration variables
//------------------------------------------------------------------------------

   virtual alu_bfm bfm;
   protected  uvm_active_passive_enum     is_active;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

   function new (virtual alu_bfm bfm, uvm_active_passive_enum
         is_active);
      this.bfm = bfm;
      this.is_active = is_active;
   endfunction : new

//------------------------------------------------------------------------------
// is_active access function
//------------------------------------------------------------------------------

   function uvm_active_passive_enum get_is_active();
      return is_active;
   endfunction : get_is_active
   
endclass : alu_agent_config
