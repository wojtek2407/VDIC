virtual class shape;
    real width = 0.0;
    real height = 0.0;
    
    function new(real w, real h);
        begin
            width = w;
            height = h;
        end
    endfunction
    
    pure virtual function real get_area();
    pure virtual function void print();
endclass