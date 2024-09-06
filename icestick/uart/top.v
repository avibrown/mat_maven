`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D5
);

    reg         rx_enable;
    reg [7:0]   rx_byte;
    wire        byte_available;

    uart_rx uart_rx (
        .clk(clk),
        .rx(rx),
        .rx_enable(rx_enable),
        .rx_byte(rx_byte),
        .byte_available(byte_available)
    );

    initial begin
        tx <= 1;
        rx_enable <= 0;
    end

    always @(posedge clk) begin
        rx_enable <= 1;
        if (byte_available) begin
            if (rx_byte == "A") begin
                D5 <= ~D5;
            end
        end
    end

endmodule