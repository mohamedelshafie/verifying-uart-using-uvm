module parity_check (
    input wire samp_data_in,
    input wire [7:0] bus,
    input wire par_check_enable,
    //input wire valid,
    input wire par_type,
    //input wire clk,
    //input wire rst,
    output reg parity_error
);
    //reg [8:0] data;
    reg temp;
    /*always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            data <= 0;
        end
        else if(valid)begin
            data = {samp_data_in,data[8:1]};    
        end
        else begin
            data = data;
            //data <= 0;
        end
    end*/

    always @(*) begin
        if(par_check_enable)begin
            temp = par_type ? (~^bus[7:0]):(^bus[7:0]);
            if(temp == samp_data_in)begin
                parity_error = 1'b0;
            end
            else begin
                parity_error = 1'b1;
            end
        end
        else begin
            temp = 0;
            parity_error = 1'b0;
        end
    end
    
endmodule
