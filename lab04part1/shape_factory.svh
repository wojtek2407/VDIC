class shape_factory;
    
    static function shape make_shape(string shape_type, real w, real h);
        rectangle rectangle_h;
        square square_h;
        triangle triangle_h;
        case (shape_type)
            "rectangle": begin
                rectangle_h = new(w, h);
                shape_reporter#(rectangle)::store_shape(rectangle_h);
                return rectangle_h;
            end
            "square": begin
                square_h = new(w);
                shape_reporter#(square)::store_shape(square_h);
                return square_h;
            end
            "triangle": begin
                triangle_h = new(w, h);
                shape_reporter#(triangle)::store_shape(triangle_h);
                return triangle_h;
            end
            default : 
                $fatal (1, {"No such shape: ", shape_type});
        endcase
    endfunction
    
endclass