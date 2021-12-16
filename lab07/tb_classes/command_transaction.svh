class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    rand queue_element_t e;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {
        e.A dist {32'h00000000:=1, [32'h1:32'hfffffffe]:/1, 32'hffffffff:=1};
        e.B dist {32'h00000000:=1, [32'h1:32'hfffffffe]:/1, 32'hffffffff:=1};
    }
    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        e  = copied_transaction_h.e;

    endfunction : do_copy


    function command_transaction clone_me();
        
        command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        command_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) && (compared_transaction_h.e == e);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("A: %8h  B: %8h op: %3b", e.A, e.B, e.op_set);
        return s;
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : command_transaction
