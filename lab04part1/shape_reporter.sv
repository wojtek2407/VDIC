class shape_reporter #(type T = shape);
    protected static T shape_storage [$];
    
    static function void store_shape(T l);
        shape_storage.push_back(l);
    endfunction
    
    static function void report_shapes();
        real sum = 0.0;
        foreach(shape_storage[i]) begin
            shape_storage[i].print();
            sum += shape_storage[i].get_area();
        end
        $display("Total area: %g\n", sum);
    endfunction
endclass