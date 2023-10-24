module data_sampling (
    input wire data,
    input wire enable,
    input wire [15:0] edge_count,
    input wire [7:0] prescale,
    input wire clk,
    input wire rst,
    output wire sampled_data,
    output reg valid
);
    reg [2:0] samples;
    wire [7:0] sample_rate;
    assign sample_rate = prescale>>1;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            samples <=3'b000;
            valid <= 0;
        end
        else if (enable) begin
            if(edge_count == sample_rate - 1)begin
                samples[0] <= data;
                valid <= 0;
            end
            else if(edge_count == sample_rate)begin
                samples[1] <= data;
                valid <= 0;
            end
            else if(edge_count == sample_rate + 1)begin
                samples[2] <= data;
                valid <= 1;
            end
            else begin
                samples <= data;
                valid <= 0;
            end
        end
        else begin
            samples <=3'b000;
            valid <= 0;
        end
    end
    assign sampled_data = (samples[1] & (samples[0] | samples[2])) | (samples[0] & samples[2]);
endmodule
