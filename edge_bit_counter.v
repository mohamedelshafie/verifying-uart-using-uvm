module edge_bit_counter (
    input wire [7:0] prescale,
    input wire enable,
    input wire clk,
    input wire rst,
    output reg [15:0] edge_count,
    output reg [3:0] bit_count
);

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            edge_count <= 0;
            bit_count <= 0;
        end
        else if (enable) begin
            if(edge_count == prescale - 1)begin
                edge_count <= 0;
                bit_count <= bit_count + 1;
            end
            else begin
                edge_count <= edge_count + 1;
                bit_count <= bit_count;
            end
        end
        else begin
            edge_count <= 0;
            bit_count <= 0;
        end
    end

    
endmodule
