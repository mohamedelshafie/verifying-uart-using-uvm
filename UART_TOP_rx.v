module UART_TOP_rx (
    input wire data,
    input wire par_enable,
    input wire [7:0] prescale,
    input wire par_type,
    input wire clk,
    input wire rst,
    output wire [7:0] data_out,
    output wire data_valid
);
    
    wire deser_en_wire,edge_bit_counter_en_wire,sampled_data_wire,par_check_en_wire;
    wire start_check_en_wire,stop_check_en_wire,data_sampling_en_wire;
    wire parity_error_wire,start_glitch_wire,stop_check_out_wire, valid_wire;
    wire [3:0] bit_count_wire;
    wire [15:0] edge_count_wire;

    deserializer des1(
        .data_in(data),
        .enable(deser_en_wire),
        .clk(clk),
        .rst(rst),
        .data_out(data_out)
        //.done()
    );

    edge_bit_counter c1(
        .prescale(prescale),
        .enable(edge_bit_counter_en_wire),
        .clk(clk),
        .rst(rst),
        .edge_count(edge_count_wire),
        .bit_count(bit_count_wire)
    );

    parity_check par_check1 (
        .samp_data_in(sampled_data_wire),
        .bus(data_out),
        .par_check_enable(par_check_en_wire),
        //.valid(valid_wire),
        .par_type(par_type),
        //.clk(clk),
        //.rst(rst),
        .parity_error(parity_error_wire)
    );

    start_check start_check1(
        .samp_data_in(sampled_data_wire),
        .start_check_enable(start_check_en_wire),
        .start_glitch(start_glitch_wire)
    );

    stop_check stop_check1(
        .samp_data_in(sampled_data_wire),
        .stop_check_enable(stop_check_en_wire),
        .stop_check_out(stop_check_out_wire)
    );

    data_sampling samp1(
        .data(data),
        .enable(data_sampling_en_wire),
        .edge_count(edge_count_wire),
        .prescale(prescale),
        .clk(clk),
        .rst(rst),
        .sampled_data(sampled_data_wire),
        .valid(valid_wire)
    );

    FSM_rx fsm_rx1(
        .data(data),
        .par_enable(par_enable),
        .edge_count(edge_count_wire),
        .bit_count(bit_count_wire),
        .prescale(prescale),
        .parity_error(parity_error_wire),
        .start_glitch(start_glitch_wire),
        .stop_check_out(stop_check_out_wire),
        .clk(clk),
        .rst(rst),
        .data_sampling_en(data_sampling_en_wire),
        .edge_bit_counter_en(edge_bit_counter_en_wire),
        .start_check_en(start_check_en_wire),
        .stop_check_en(stop_check_en_wire),
        .par_check_en(par_check_en_wire),
        .deserializer_en(deser_en_wire),
        .data_valid(data_valid)
    );
endmodule
