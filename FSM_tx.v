module FSM_tx (
    input wire [7:0] data_in,
    input wire valid,
    input wire parity_en,
    input wire ser_done,
    input wire clk,
    input wire rst, 
    output reg busy,
    output reg [1:0] mux_sel,
    output reg ser_en

);
    reg [2:0] curr_state, next_state;

    localparam idle_state = 3'b000;
    localparam start_state = 3'b001;
    localparam data_state = 3'b010;
    localparam parity_state = 3'b011;
    localparam stop_state = 3'b100;
    
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
            idle_state:begin
                if (valid)begin
                    next_state = start_state;
                end
                else begin
                    next_state = idle_state;
                end
            end
            start_state:begin
                next_state = data_state;
            end
            data_state:begin
                if(ser_done)begin
                    if(parity_en)begin
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
            parity_state:begin
                next_state = stop_state;
            end
            stop_state:begin
                if(valid)begin
                    next_state = start_state;
                end
                else begin
                    next_state = idle_state;
                end
            end
            default: begin
                next_state = idle_state;
            end
        endcase
    end

    always @(*) begin
        case (curr_state)
            idle_state:begin
                busy = 0;
                mux_sel = 2'b00;
                ser_en = 0;
            end
            start_state:begin
                busy = 1;
                mux_sel = 2'b01;
                ser_en = 0;
            end
            data_state:begin
                    busy = 1;
                    ser_en = 1;
                    mux_sel = 2'b10;
                    
                end
            parity_state:begin
                busy = 1;
                mux_sel = 2'b11;
                ser_en = 0;
            end
            stop_state:begin
                busy = 1;
                mux_sel = 2'b00;
                ser_en = 0;
            end
            default: begin
                busy = 0;
                mux_sel = 2'b00;
                ser_en = 0;
            end
        endcase
    end
endmodule
