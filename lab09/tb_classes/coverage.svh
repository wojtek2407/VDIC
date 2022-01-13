class coverage extends uvm_subscriber#(sequence_item);
    
    `uvm_component_utils(coverage)
    local bit [31:0]  A;
    local bit [31:0]  B;
    local bit insert_crc_error;
    local bit reset_alu_before;
    local bit reset_alu_after;
    local bit insert_data_frame_error;
    local bit second_execution;
    local bit insert_data_bit_error;
    local operation_t op_set;

    covergroup op_cov;
    
        option.name = "cg_op_cov";
    
        cp_op_set : coverpoint op_set {
            // #A1 test all operations
            bins A1_all_ops = {alu_pkg::and_op,alu_pkg::or_op,alu_pkg::add_op,alu_pkg::sub_op};
        }
        
        cp_reset_before : coverpoint reset_alu_before {
            bins reset_before = {1'b1};
        }
        
        cp_reset_after : coverpoint reset_alu_after {
            bins reset_after = {1'b1};
        }
        
        cp_reset_after_before_operations: cross cp_reset_before, cp_reset_after, cp_op_set {
            
            // #A2 execute all operations after reset
            bins A2_reset_before_and = binsof(cp_op_set) intersect {alu_pkg::and_op} && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_or  = binsof(cp_op_set) intersect {alu_pkg::or_op}  && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_add = binsof(cp_op_set) intersect {alu_pkg::add_op} && binsof(cp_reset_before.reset_before);
            bins A2_reset_before_sub = binsof(cp_op_set) intersect {alu_pkg::sub_op} && binsof(cp_reset_before.reset_before);
            
            // #A3 execute reset after all operations
            bins A3_reset_after_and = binsof(cp_op_set) intersect {alu_pkg::and_op} && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_or  = binsof(cp_op_set) intersect {alu_pkg::or_op}  && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_add = binsof(cp_op_set) intersect {alu_pkg::add_op} && binsof(cp_reset_after.reset_after);
            bins A3_reset_after_sub = binsof(cp_op_set) intersect {alu_pkg::sub_op} && binsof(cp_reset_after.reset_after);

        }
       
        cp_two_op : coverpoint op_set {
            // #A4 two operations in row
            bins A4_twoops = ([alu_pkg::and_op:alu_pkg::sub_op] [*2]);
        }
    
    endgroup
        
    covergroup errors_cov;
        
        option.name = "cg_errors_cov";  
        
        // #B1 Bad OP code error insertion
        coverpoint op_set {
            bins B1_bad_op = {alu_pkg::bad_op1,alu_pkg::bad_op2,alu_pkg::bad_op3,alu_pkg::bad_op4};
        }
        
        // #B2 CRC bit error insertion
        coverpoint insert_crc_error {
            bins B2_crc_bit_error = {1'b1};
        }
        
        // #B3 Data bit error insertion
        coverpoint insert_data_bit_error {
            bins B3_data_bit_error = {1'b1};
        }
        
        // #B4 Data bit error insertion
        coverpoint insert_data_frame_error {
            bins B4_data_frame_error = {1'b1};
        }
        
    endgroup
            
    covergroup min_max_cov;
        
        option.name = "cg_min_max_cov";  
        
        all_ops : coverpoint op_set {
            ignore_bins null_ops = {alu_pkg::bad_op1,alu_pkg::bad_op2,alu_pkg::bad_op3,alu_pkg::bad_op4};
        }
        
        a_leg : coverpoint A {
            bins zeros = {'h00000000};
            bins others = {['h1:'hfffffffe]};
            bins ones  = {'hffffffff};
        }
        b_leg : coverpoint B {
            bins zeros = {'h00000000};
            bins others = {['h1:'hfffffffe]};
            bins ones  = {'hffffffff};
        }
        
        B_op_00_FF: cross a_leg, b_leg, all_ops {
            
            // #C1 simulate all zero input for all the operations
            bins C1_and_00          = binsof (all_ops) intersect {alu_pkg::and_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_or_00           = binsof (all_ops) intersect {alu_pkg::or_op}  && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_add_00          = binsof (all_ops) intersect {alu_pkg::add_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            bins C1_sub_00          = binsof (all_ops) intersect {alu_pkg::sub_op} && (binsof (a_leg.zeros) || binsof (b_leg.zeros));
            
            // #C2 simulate all one input for all the operations
            bins C2_and_FF          = binsof (all_ops) intersect {alu_pkg::and_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_or_FF           = binsof (all_ops) intersect {alu_pkg::or_op}  && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_add_FF          = binsof (all_ops) intersect {alu_pkg::add_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            bins C2_sub_FF          = binsof (all_ops) intersect {alu_pkg::sub_op} && (binsof (a_leg.ones) || binsof (b_leg.ones));
            
            ignore_bins others_only = binsof(a_leg.others) && binsof(b_leg.others);
        }
        
    endgroup
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov      = new();
        errors_cov  = new();
        min_max_cov = new();
    endfunction : new
    
    
    function void write(sequence_item t);
        A = t.A;
        B = t.B;
        op_set = t.op_set;
        insert_crc_error = t.insert_crc_error;
        reset_alu_before = t.reset_alu_before;
        reset_alu_after = t.reset_alu_after;
        insert_data_frame_error = t.insert_data_frame_error;
        second_execution = t.second_execution;
        insert_data_bit_error = t.insert_data_bit_error;
        op_cov.sample();
        errors_cov.sample();
        min_max_cov.sample();
    endfunction : write

endclass