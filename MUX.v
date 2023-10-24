module MUX (
    input wire in1,
    input wire in2,
    input wire in3,
    input wire in4,
    input wire [1:0] select,
    output reg out
);
    
    always @(*) begin
        case (select)
            2'b00:begin
                out = in1;
            end 
            2'b01:begin
                out = in2;
            end 
            2'b10:begin
                out = in3;
            end 
            2'b11:begin
                out = in4;
            end 
            default: out = 0;
        endcase
    end
endmodule