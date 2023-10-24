module deserializer (
    input wire data_in,
    input wire enable,
    input wire clk,
    input wire rst,
    output reg [7:0] data_out
    //output wire done
);
    
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            data_out <= 0;
        end
        else if (enable) begin
            data_out <= {data_in,data_out[7:1]};
        end
        else begin
            data_out <= data_out; //<=0
        end
    end
endmodule
