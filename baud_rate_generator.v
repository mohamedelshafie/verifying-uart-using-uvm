module baud_rate_generator(
    input wire clk,rst,
    input wire [7:0] prescale,
    //output reg tx_clk,rx_clk
    output tx,rx
);

    localparam system_clk = 100000000;
    localparam baud_rate = 9600;

    //localparam tx_count_max = system_clk / (2 * baud_rate);
    localparam count_max = (system_clk / (2*baud_rate))-1;

    reg [15:0] tx_counter, rx_counter;

    reg tx_clk,rx_clk;
    //assign tx = (tx_counter == ((count_max * prescale) - 1)) ? ~tx : tx;
    assign tx = tx_clk;
    assign rx = rx_clk;

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            tx_clk <= 0;
            rx_clk <= 1;
            tx_counter <= 0;
            rx_counter <= 0;
        end
        else begin
            if(tx_counter == ((count_max) - 1))begin
                tx_counter <= 0;
                tx_clk <= ~tx_clk;
            end
            else begin
                tx_counter <= tx_counter + 1;
                tx_clk <= tx_clk;
            end

            if(rx_counter == ((count_max/prescale) - 1))begin
                rx_counter <= 0;
                rx_clk <= ~rx_clk;
            end
            else begin
                rx_counter <= rx_counter + 1;
                rx_clk <= rx_clk;
            end
        end
    end



endmodule