module top();
    integer fd;
    shape shape_h;
    rectangle rectangle_h;
    square square_h;
    triangle triangle_h;
    
    initial begin
        fd = $fopen("./lab04part1_shapes.txt", "r");
        if (!fd) $fatal(1, "Can't access file.");
        while (!$feof(fd)) begin
            string shape;
            automatic real w, h;
            void'($fscanf(fd, "%s %f %f", shape, w, h));
                  
            shape_h = shape_factory::make_shape(shape, w, h);
            
            if ($cast(rectangle_h, shape_h)) shape_reporter#(rectangle)::store_shape(rectangle_h);
            else if ($cast(square_h, shape_h)) shape_reporter#(square)::store_shape(square_h);
            else if ($cast(triangle_h, shape_h)) shape_reporter#(triangle)::store_shape(triangle_h);
            else $fatal (1, {"No such shape: ", shape});
 
        end
        
        shape_reporter#(rectangle)::report_shapes();
        shape_reporter#(square)::report_shapes();
        shape_reporter#(triangle)::report_shapes();
        
        $finish;
    end
    
endmodule