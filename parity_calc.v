module parity_calc (
    input wire [7:0] data_in,
    input wire type,
    output wire parity

);

assign parity = type ? (~^data_in):(^data_in);

endmodule
