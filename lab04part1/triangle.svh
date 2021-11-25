class triangle extends shape;
    
    function new(real w, real h);
        super.new(w, h);
    endfunction
    
    function real get_area();
        get_area = 0.5 * width * height; 
    endfunction
    
    function void print(); 
        $display("Triangle w=%g, h=%g area=%g", width, height, get_area());
    endfunction
    
endclass