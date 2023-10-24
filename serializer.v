module serializer (
    input wire [7:0] data_in,
    input wire enable,
    input wire clk,
    input wire rst,
    output wire data_out,
    output wire done
);
reg [2:0] count;
reg [7:0] temp;

assign data_out = temp[0];
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            temp <= 0;
        end
        else if (enable)begin
            temp <= temp >> 1;
        end
        else begin
            temp <= data_in;
        end
    end

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            count <= 0;
        end
        else if (enable) begin
            count <= count + 1;
        end
        else if (done) begin
            count <= 0;
        end
        else begin
            count <= 0;
        end
    end


assign done = count == 3'b111;

endmodule
