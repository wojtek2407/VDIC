`timescale 1ns/1ps

module top();
    integer fd;
    
    initial begin
        fd = $fopen("./lab04part1_shapes.txt", "r");
        if (!fd) $fatal(1, "Can't access file.");
        while (!$feof(fd)) begin
            string shape;
            automatic real w, h;
            void'($fscanf(fd, "%s %f %f", shape, w, h));                 
            shape_factory::make_shape(shape, w, h);
 
        end
        
        shape_reporter#(rectangle)::report_shapes();
        shape_reporter#(square)::report_shapes();
        shape_reporter#(triangle)::report_shapes();
        
        $finish;
    end
    
endmodule