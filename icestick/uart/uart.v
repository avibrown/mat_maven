`default_nettype none

module uart(
    input  clk,
    input  rx,
    output tx,
    input  [7:0] tx_byte,
    output [7:0] rx_byte,
    output busy,
    output byte_available,
    );

    localparam BAUD         = 115200;
    localparam CLK_HZ       = 12000000;
    localparam CLKS_IN_BAUD = CLK_HZ / BAUD;
    localparam S_IDLE       = 2'b00;
    localparam S_RX         = 2'b01;    
    localparam S_TX         = 2'b10;
    
    reg [6:0] counter;
    reg [1:0] state;
    reg [3:0] rx_idx;

    initial begin
        counter <= 0;
        state   <= S_IDLE;
        rx_byte <= 0;
        rx_idx  <= 0;        
    end

    always @(posedge clk) begin
        tx = 1'b1;
        byte_available <= 0;
        
        counter <= counter + 1;

        if (state == S_IDLE) begin
            if (~rx) begin
                busy    <= 1;
                counter <= 0;
                state   <= S_RX;
                rx_byte <= 0;
                rx_idx  <= 0;
            end
        end
        
        if (state == S_RX) begin
            if (counter >= CLKS_IN_BAUD) begin
                rx_byte[rx_idx] <= rx;
                rx_idx          <= rx_idx + 1;
                counter         <= 0;

                if (rx_idx == 8) begin
                    state      <= S_IDLE;
                    byte_available <= 1;
                    busy       <= 0;
                end
            end
        end
    end

endmodule
