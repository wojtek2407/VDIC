class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand bit [31:0]  A;
    rand bit [31:0]  B;
    rand bit insert_crc_error;
    rand bit reset_alu_before;
    rand bit reset_alu_after;
    rand bit insert_data_frame_error;
    rand bit second_execution;
    rand bit insert_data_bit_error;
    rand bit err;
    rand bit signed [31:0] C;
    rand bit [3:0] flags;
    rand bit [2:0] crc;
    rand bit [5:0] err_flags;
    rand bit parity;
    rand operation_t op_set;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(insert_crc_error, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(reset_alu_before, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(reset_alu_after, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(insert_data_frame_error, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(second_execution, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(insert_data_bit_error, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(err, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(C, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(flags, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(crc, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(err_flags, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(parity, UVM_ALL_ON | UVM_BIN)
        `uvm_field_enum(operation_t, op_set, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {
        A dist {32'h00000000:=1, [32'h1:32'hfffffffe]:/1, 32'hffffffff:=1};
        B dist {32'h00000000:=1, [32'h1:32'hfffffffe]:/1, 32'hffffffff:=1};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        return {super.convert2string(),
            $sformatf("A: %2h  B: %2h   op: %s = %4h", A, B, op_set.name(), C)
        };
    endfunction : convert2string

endclass : sequence_item


