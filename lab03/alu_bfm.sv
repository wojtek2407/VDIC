interface alu_bfm;
    
    import alu_pkg::*;
    
    bit                sin;
    wire               sout;
    bit                clk;
    bit                rst_n;
    
    queue_element_t send_queue [$];
    queue_element_t receive_queue [$];
    queue_element_t e_temp;
    event check_coverage;
    
    
    task enqueue_element(input queue_element_t e);
        begin
            send_queue.push_back(e);
        end
    endtask
    
    task dequeue_element(output queue_element_t e);
        begin
            wait(receive_queue.size() > 0);
            e = receive_queue.pop_front();
        end
    endtask
      
    initial forever begin
        wait(send_queue.size() > 0);
        e_temp = send_queue.pop_front();
        ->check_coverage;
        if (e_temp.reset_alu_before) reset_alu();
        ALU_send(e_temp.A, e_temp.B, e_temp.op_set, e_temp.insert_crc_error, e_temp.insert_data_bit_error, e_temp.insert_data_frame_error);
        ALU_receive(e_temp.err, e_temp.C, e_temp.flags, e_temp.crc, e_temp.err_flags, e_temp.parity);
        if (e_temp.second_execution) begin
            ALU_send(e_temp.A, e_temp.B, e_temp.op_set, e_temp.insert_crc_error, e_temp.insert_data_bit_error, e_temp.insert_data_frame_error);
            ALU_receive(e_temp.err, e_temp.C, e_temp.flags, e_temp.crc, e_temp.err_flags, e_temp.parity);
        end
        if (e_temp.reset_alu_after) reset_alu();
        receive_queue.push_back(e_temp);
    end
    
    //------------------------------------------------------------------------------
    // Clock generator
    //------------------------------------------------------------------------------
    
    initial begin : clk_gen
        clk = 0;
        forever begin : clk_frv
            #10;
            clk = ~clk;
        end
    end
    
    //---------------------------
    // ALU send/receive functions
    //---------------------------

    
    task ALU_send_byte(transfer_type_t transfer_type, input bit [7:0] data);
        integer i;
        begin
            @(negedge clk) sin = 1'b0;
            @(negedge clk) sin = transfer_type;
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) sin = data[7-i]; // MSB frist
            @(negedge clk) sin = 1'b1;           
        end
    endtask
    
    task ALU_send_32bit_operand(input bit [31:0] operand, input bit insert_error);
        integer i;
        begin
            for (i = 0; i < (insert_error ? $urandom_range(3, 0) : 4); i = i + 1)
                ALU_send_byte(alu_pkg::DATA, operand[31-8*i-:8]);
        end
    endtask
    
    task ALU_send_ctl(input operation_t operation, input bit [3:0] crc);
        integer i;
        begin
            ALU_send_byte(alu_pkg::CTL, {1'b0, operation, crc});
        end
    endtask
    
    task ALU_send(input bit [31:0] A, input bit [31:0] B, input operation_t operation, input bit insert_crc_error, input bit insert_data_bit_error, input bit insert_data_frame_error);
        integer i;
        bit [31:0] A_temp;
        bit [3:0] crc;
        begin
            // insert error at a random A operand bit to simulate transmission error;
            i = $urandom() % 32;
            A_temp = A;
            A_temp[i] = ~A_temp[i];
            
            ALU_send_32bit_operand(insert_data_bit_error ? A_temp : A, insert_data_frame_error);
            // dont send second operand if frame error expected
            ALU_send_32bit_operand(B, insert_data_frame_error);
            
            crc = crc4.nextCRC4_D68({A, B, 1'b1, operation}, 1'b0);
            // invert 2 crc bits to simulate crc error
            ALU_send_ctl(operation, insert_crc_error ? crc^4'b0100 : crc);
        end
    endtask
    
    task ALU_receive_byte(output bit [7:0] data, output transfer_type_t transfer_type);
        integer i;
        begin
            wait (sout === 1'b0);
            @(negedge clk);
            @(negedge clk) transfer_type = transfer_type_t'(sout);
            for (i = 0; i < 8; i = i + 1) 
                @(negedge clk) data[7-i] = sout; // MSB frist
            wait (sout === 1'b1);
        end
    endtask
    
    task ALU_receive(output bit err, output bit signed [31:0] C, output bit [3:0] flags, output bit [2:0] crc, output bit [5:0] err_flags, bit parity);
        integer i;
        bit dummy;
        bit [7:0] received_data[5];
        transfer_type_t frame_types[5];
        begin
            ALU_receive_byte(received_data[0], frame_types[0]);          
            case (frame_types[0])
                alu_pkg::DATA: begin : no_error
                    for (i = 1; i < 5; i = i + 1)   
                        ALU_receive_byte(received_data[i], frame_types[i]);
                    C = {received_data[0], received_data[1], received_data[2], received_data[3]};
                    {err_flags, parity} = 7'b0; // dont care
                    {flags, crc} = received_data[4][6:0];
                    err = 1'b0;
                end
                alu_pkg::CTL: begin : error  
                    {err_flags, parity} = received_data[0][6:0];
                    {flags, crc} = 7'b0; // dont care
                    err = 1'b1;
                end
                default :
                    $warning("should never happen");
            endcase
        end
    endtask
    
    //------------------------------------------------------------------------------
    // reset task
    //------------------------------------------------------------------------------
    task reset_alu();
        `ifdef DEBUG
        $display("%0t DEBUG: reset_alu", $time);
        `endif
        rst_n = 1'b0;
        sin = 1'b1;
        @(negedge clk);
        rst_n = 1'b1;
    endtask
    
endinterface : alu_bfm