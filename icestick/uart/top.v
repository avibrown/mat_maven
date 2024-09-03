`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D1,
);

    reg [7:0] serial_in;
    reg [7:0] serial_out;
    reg serial_busy;
    reg serial_available;

    uart serial (
        .clk(clk),
        .rx(rx),
        .tx(tx),
        .rx_byte(serial_in),
        .tx_byte(serial_out),
        .busy(serial_busy),
        .byte_available(serial_available)
    );

    always @(posedge clk) begin
        if (serial_available) begin
            if (serial_in == "*") begin
                D1 <= ~D1;
            end
        end
    end

endmodule
