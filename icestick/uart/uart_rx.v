`default_nettype none

module uart_rx (
    input   wire        clk,
    input   wire        rx,
    input   wire        rx_enable,
    output  reg [7:0]   rx_byte,
    output  wire        byte_available
);

    localparam  BAUD            = 115200;
    localparam  CLK_HZ          = 12000000;
    localparam  CLKS_IN_BAUD    = CLK_HZ / BAUD;

    reg [1:0]   state;
    localparam  S_IDLE          = 0;
    localparam  S_RX            = 1;
    localparam  S_STOP          = 2;

    reg [6:0] counter;
    reg [1:0] state;
    reg [1:0] next_state;
    reg [3:0] rx_idx;
    wire      tick;
    wire      byte_available;
    
    assign    byte_available = rx_idx > 8;
    assign    tick           = counter >= CLKS_IN_BAUD;

    initial begin
        counter    <= 0;
        state      <= S_IDLE;
        next_state <= S_IDLE;
        rx_idx     <= 0;
    end

    /* Handle finite state machine flow */
    always @(posedge clk) begin
        case (state)
            S_IDLE: next_state <= rx_enable && ~rx ? S_RX   : S_IDLE;
            S_RX:   next_state <= byte_available   ? S_STOP : S_RX;
            S_STOP: next_state <= byte_available   ? S_STOP : S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(posedge clk) begin
        counter <= counter + 1;
        case (state)
            S_IDLE: begin
                counter <= 0;  
                rx_idx  <= 0;        
            end

            S_RX: begin
                if (tick) begin
                    counter         <= 0;
                    rx_byte[rx_idx] <= rx;
                    rx_idx          <= rx_idx + 1;
                end
            end

            S_STOP: begin
                rx_idx  <= rx_idx + 1;
                counter <= 0;      
            end
        endcase        
    end
endmodule
