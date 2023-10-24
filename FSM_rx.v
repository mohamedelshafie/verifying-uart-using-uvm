module FSM_rx (
    input wire data,
    input wire par_enable,
    input wire [15:0] edge_count,
    input wire [3:0] bit_count,
    input wire [7:0] prescale,
    input wire parity_error,
    input wire start_glitch,
    input wire stop_check_out,
    input wire clk,
    input wire rst,
    output reg data_sampling_en,
    output reg edge_bit_counter_en,
    output reg start_check_en,
    output reg stop_check_en,
    output reg par_check_en,
    output reg deserializer_en,
    output reg data_valid
);
    reg [2:0] curr_state, next_state;

    localparam idle_state = 0;
    localparam start_state = 1;
    localparam data_state = 2;
    localparam parity_state = 3;
    localparam stop_state = 4;
    
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            curr_state <= 0;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case (curr_state)
            idle_state: begin
                if(!data)begin
                    next_state = start_state;
                    //data_sampling_en = 1;
                    //edge_bit_counter_en = 1;
                end
                else begin
                    next_state = idle_state;
                end
            end
            start_state: begin
                if(!start_glitch && bit_count == 1)begin
                    next_state = data_state;
                end
                else begin
                    next_state = start_state;
                end
            end
            data_state: begin
                if (bit_count == 9) begin
                    if (par_enable) begin
                        next_state = parity_state;    
                    end
                    else begin
                        next_state = stop_state;
                    end
                end
                else begin
                    next_state = data_state;
                end
            end
            parity_state: begin
                if(bit_count == 10)begin
                   next_state = stop_state;  
                end
                else begin
                   next_state = parity_state;
                end
            end
            stop_state: begin
                if(edge_count == (prescale - 1) && data == 1)begin
                   next_state = idle_state;  
                end
                else if(edge_count == (prescale - 1) && data == 0)begin
                   next_state = start_state;  
                end
                else begin
                   next_state = stop_state;
                end
            end
            default: begin
                next_state = idle_state;
            end
        endcase
    end
    always @(*) begin
        case (curr_state)
            idle_state: begin
                if(!data)begin
                    data_sampling_en = 1;
                    edge_bit_counter_en = 1;
                    start_check_en = 1;    
                    stop_check_en = 0;
                    par_check_en = 0;
                    deserializer_en = 0;
                    data_valid = 0;
                end
                else begin
                    data_sampling_en = 0;
                    edge_bit_counter_en = 0;
                    start_check_en = 0;
                    stop_check_en = 0;
                    par_check_en = 0;
                    deserializer_en = 0;
                    data_valid = 0;
                end
                
            end
            start_state: begin
                data_sampling_en = 1;
                edge_bit_counter_en = 1;
                if(!start_glitch && bit_count == 1)begin
                    start_check_en = 0;//new
                end
                else begin
                    start_check_en = 1;//new
                end
                /*if(bit_count == 1)begin
                    start_check_en = 1;    
                end
                else begin
                    start_check_en = 0;
                end*/
                stop_check_en = 0;
                par_check_en = 0;
                deserializer_en = 0;//1
                data_valid = 0;
            end
            data_state: begin
                data_sampling_en = 1;
                edge_bit_counter_en = 1;
                start_check_en = 0;
                stop_check_en = 0;
                par_check_en = 0;
                

                if(edge_count == (prescale - 2))begin //bit_count == 2
                    deserializer_en = 1;
                    //par_check_en = 1;
                end
                else begin
                    deserializer_en = 0;
                    //par_check_en = 0;
                end
                
                data_valid = 0;
            end
            parity_state: begin
                data_sampling_en = 1;
                edge_bit_counter_en = 1;
                start_check_en = 0;
                stop_check_en = 0;
                if(edge_count == (prescale - 1))begin //2
                    par_check_en = 1;
                end
                else begin
                    par_check_en = 0;
                end
                //par_check_en = 1;
                deserializer_en = 0;
                data_valid = 0;
            end
            stop_state: begin
                data_sampling_en = 1;
                if(edge_count == (prescale - 1))begin //2
                    edge_bit_counter_en = 0;
                end
                else begin
                    edge_bit_counter_en = 1;
                end
                
                start_check_en = 0;
                /*if(par_enable && bit_count == 10)begin
                    stop_check_en = 1;
                end
                else if (!par_enable && bit_count == 9) begin
                    stop_check_en = 1;
                end
                else begin
                    stop_check_en = 0;
                end*/
                if(edge_count == (prescale - 1))begin //2
                    stop_check_en = 1;
                end
                else begin
                    stop_check_en = 0;
                end
                par_check_en = 0;
                deserializer_en = 0;
                if(!parity_error && !stop_check_out && edge_count == (prescale - 1))begin
                    data_valid = 1;
                end
                else begin
                    data_valid = 0;
                end
                
            end
            default: begin
                data_sampling_en = 0;
                edge_bit_counter_en = 0;
                start_check_en = 0;
                stop_check_en = 0;
                par_check_en = 0;
                deserializer_en = 0;
                data_valid = 0;
            end
        endcase
    end
endmodule
