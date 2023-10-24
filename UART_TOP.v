module UART_TOP(
    input wire clk,rst,
    input wire [7:0] data_in_bus,
    input wire data_valid_in,
    input wire data_in_wire,
    input wire par_enable,
    input wire [7:0] prescale,
    input wire par_type,

    output data_out_wire,
    output busy,
    output wire [7:0] data_out_bus,
    output wire data_valid_out
);

    wire tx_clk,rx_clk;

    baud_rate_generator baud1 (
        .clk(clk),
        .rst(rst),
        .prescale(prescale),
        .tx(tx_clk),
        .rx(rx_clk)
    );

    UART_TOP_tx tx1 (
        .data(data_in_bus),
        .data_valid(data_valid_in),
        .parity_type(par_type),
        .parity_en(par_enable),
        .clk(tx_clk),
        .rst(rst),
        .data_out(data_out_wire),
        .busy(busy)
    );

    UART_TOP_rx rx1 (
        .data(data_in_wire),
        .par_enable(par_enable),
        .prescale(prescale),
        .par_type(par_type),
        .clk(rx_clk),
        .rst(rst),
        .data_out(data_out_bus),
        .data_valid(data_valid_out)
    );
endmodule