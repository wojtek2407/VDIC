class random_test extends alu_base_test;
   `uvm_component_utils(random_test)
  
   local random_sequence random_seq;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
   
   task run_phase(uvm_phase phase);
      random_seq = new("random_seq");
      phase.raise_objection(this);
      random_seq.start(sequencer_h); // the sequence gets the sequencer by its own
      phase.drop_objection(this);
   endtask : run_phase

endclass