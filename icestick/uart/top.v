`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D5
);


    /* --- rx --- */
    reg       rx_enable;
    reg [7:0] rx_byte;
    wire      byte_available;

    uart_rx uart_rx (
        .clk(clk),
        .rx(rx),
        .rx_enable(rx_enable),
        .rx_byte(rx_byte),
        .byte_available(byte_available)
    );

    /* --- tx --- */
    reg       tx_enable;
    reg [7:0] tx_byte;
    reg [7:0] test_char;

    uart_tx uart_tx (
        .clk(clk),
        .tx(tx),
        .tx_enable(tx_enable),
        .tx_byte(tx_byte)
    );

    initial begin
        rx_enable <= 0;
        tx_enable <= 0;
        test_char <= "0";
    end

    reg [23:0] counter;

    always @(posedge clk) begin
        // tx_enable <= 0;
        counter <= counter + 1;
        // rx_enable <= 1;
        // if (byte_available) begin
        //     if (rx_byte == "A") begin
        //         D5 <= ~D5;
        //     end
        // end

        if (counter >= 12_000_000) begin
            tx_enable <= 1;
            D5 <= ~D5;
            tx_byte   <= test_char;
            test_char <= test_char + 1;     
            counter   <= 0;       
        end else begin
            tx_enable <= 0;
        end
    end
endmodule