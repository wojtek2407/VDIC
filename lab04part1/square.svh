class square extends shape;
    
    function new(real w);
        super.new(w, 0.0);
    endfunction
    
    function real get_area();
        get_area = width * width; 
    endfunction
    
    function void print(); 
        $display("Square w=%g, area=%g", width, get_area());
    endfunction
    
endclass