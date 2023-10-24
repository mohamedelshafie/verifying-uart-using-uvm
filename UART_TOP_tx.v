module UART_TOP_tx (
    input wire [7:0] data,
    input wire data_valid,
    input wire parity_type,
    input wire parity_en,
    input wire clk,
    input wire rst,
    output data_out,
    output busy
);
    wire ser_done_wire;
    wire ser_en_wire;
    wire ser_data_wire;
    wire [1:0] mux_sel_wire;
    wire parity_wire;

    serializer s1 (
        .data_in(data),
        .enable(ser_en_wire),
        .clk(clk),
        .rst(rst),
        .data_out(ser_data_wire),
        .done(ser_done_wire)
    );

    parity_calc p1 (
        .data_in(data),
        .type(parity_type),
        .parity(parity_wire)
    );

    FSM_tx fsm1 (
        .data_in(data),
        .valid(data_valid),
        .parity_en(parity_en),
        .ser_done(ser_done_wire),
        .clk(clk),
        .rst(rst),
        .busy(busy),
        .mux_sel(mux_sel_wire),
        .ser_en(ser_en_wire)
    );

    MUX mux1 (
        .in1(1'b1),
        .in2(1'b0),
        .in3(ser_data_wire),
        .in4(parity_wire),
        .select(mux_sel_wire),
        .out(data_out)
    );
endmodule
