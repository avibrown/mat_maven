`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D1,
    output D5,
);

    reg [7:0] serial_in;
    reg [7:0] serial_out;
    reg serial_busy;
    reg serial_available;
    reg send_request;
    reg [23:0] counter;
    reg [7:0]  char;
 
    uart serial (
        .clk(clk),
        .rx(rx),
        .tx(tx),
        .rx_byte(serial_in),
        .tx_byte(serial_out),
        .busy(serial_busy),
        .byte_available(serial_available),
        .send_request(send_request)
    );

    initial begin
        counter <= 0;
        send_request <= 0;
        char <= "a";
    end

    always @(posedge clk) begin
        counter <= counter + 1;
        send_request <= 0;
        
        if (counter == 1200000) begin
            counter <= 0;
            D1 <= ~D1;
            serial_out   <= char;
            char <= char + 1;
            send_request <= 1;        
        end

        if (serial_available) begin
            if (serial_in == "*") begin
                D5 <= ~D5;
            end
        end
    
    end

endmodule
