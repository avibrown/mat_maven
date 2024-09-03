`default_nettype none

//-- Template for the top entity
module uart(
    input  clk,
    input  rx,
    output tx,
    output D1,
    output D2,
    );

localparam BAUD   = 115200;
localparam CLK_HZ = 12000000;
localparam CLKS_IN_BAUD = CLK_HZ / BAUD;
reg [6:0]  counter;

localparam S_IDLE = 2'b00;
localparam S_RX   = 2'b01;    
localparam S_TX   = 2'b10;
reg [1:0]  state  = S_IDLE;

reg [7:0] rx_byte;
reg [3:0] rx_idx;

always @(posedge clk) begin
    tx = 1'b1;
    counter <= counter + 1;

    if (state == S_IDLE) begin
        if (~rx) begin
            counter <= 0;
            D2 <= ~D2;
            state   <= S_RX;
            rx_byte <= 0;
            rx_idx  <= 0;
        end
    end
    
    if (state == S_RX) begin
        if (counter >= CLKS_IN_BAUD) begin
            rx_byte[rx_idx] <= rx;
            rx_idx <= rx_idx + 1;
            counter <= 0;

            if (rx_idx == 8) begin
                state <= S_IDLE;
                if (rx_byte == "A") begin
                    D1 <= ~D1;
                end
            end
        end
    end
end

endmodule
