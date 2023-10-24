module stop_check (
    input wire samp_data_in,
    input wire stop_check_enable,
    output reg stop_check_out
);
    always @(*) begin
        if(stop_check_enable)begin
            if(samp_data_in)begin
                stop_check_out = 0;
            end
            else begin
                stop_check_out = 1;
            end
        end
        else begin
            stop_check_out = 0;
        end
    end
endmodule
