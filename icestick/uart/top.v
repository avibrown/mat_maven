`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D1,
    output D5
);

    reg [23:0] counter;

    reg [7:0] tx_byte;
    reg [7:0] rx_byte;
    reg [7:0] test_char;
    wire      byte_available;
    wire      tx_enable;
    wire      rx_enable;

    uart serial (
        .clk(clk),
        .rx(rx),
        .tx(tx),
        .tx_byte(tx_byte),
        .rx_byte(rx_byte),
        .tx_enable(tx_enable),
        .rx_enable(rx_enable),
        .byte_available(byte_available)
    );

    initial begin
        test_char <= "0";
        counter   <= 0;
        rx_enable <= 1;
        tx_enable <= 0;
    end

    assign tx_enable = ~rx_enable;

    always @(posedge clk) begin
        counter <= counter + 1;

        if (counter >= 12_000_00) begin
            rx_enable <= 0;
            D5 <= ~D5;
            tx_byte   <= test_char;   
            counter   <= 0;       
        end else begin
            rx_enable <= 1;
        end
    end

    always @(posedge clk) begin
        if (byte_available)
            D1 <= ~D1;
            test_char <= rx_byte;
        end 
endmodule