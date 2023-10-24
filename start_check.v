module start_check (
    input wire samp_data_in,
    input wire start_check_enable,
    output reg start_glitch
);
    always @(*) begin
        if(start_check_enable)begin
            if(!samp_data_in)begin
                start_glitch = 0;
            end
            else begin
                start_glitch = 1;
            end
        end
        else begin
            start_glitch = 0;
        end
    end
endmodule
