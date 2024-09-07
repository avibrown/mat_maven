`default_nettype none

module uart (
    input        clk,
    input        rx,
    output       tx,
    input  [7:0] tx_byte,
    output [7:0] rx_byte,
    input        tx_enable,
    input        rx_enable,
    output       byte_available
);

    uart_rx uart_rx (
        .clk(clk),
        .rx(rx),
        .rx_enable(rx_enable),
        .rx_byte(rx_byte),
        .byte_available(byte_available)
    );

    uart_tx uart_tx (
        .clk(clk),
        .tx(tx),
        .tx_enable(tx_enable),
        .tx_byte(tx_byte)
    );

endmodule