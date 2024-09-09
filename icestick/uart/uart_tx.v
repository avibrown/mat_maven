`default_nettype none

module uart_tx (
    input  wire  clk,
    output reg   tx,
    input  [7:0] tx_byte,
    input  wire  tx_enable
);

    localparam  BAUD         = 115200;
    localparam  CLK_HZ       = 12000000;
    localparam  CLKS_IN_BAUD = CLK_HZ / BAUD;

    localparam  S_IDLE = 0;
    localparam  S_TX   = 1;
    localparam  S_STOP = 2;

    reg [6:0] counter;
    reg [1:0] state;
    reg [1:0] next_state;
    reg [3:0] tx_idx;
    wire      tick;
    assign    tick = counter >= CLKS_IN_BAUD;
    wire      packet_sent;
    assign    packet_sent = tx_idx > 9; /* start bit + 8 data bits + stop bit */

    initial begin
        counter    <= 0;
        state      <= S_IDLE;
        next_state <= S_IDLE;
        tx_idx     <= 0;
        tx         <= 1; /* normally high */
    end

    always @(negedge clk) begin
        case (state)
            S_IDLE: next_state <= tx_enable   ? S_TX   : S_IDLE;
            S_TX:   next_state <= packet_sent ? S_STOP : S_TX;
            S_STOP: next_state <= packet_sent ? S_STOP : S_IDLE;
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
                tx_idx <= 0;
            end 

            S_TX: begin
                if (tick) begin
                    if (tx_idx == 0) begin                   /* start bit low */
                        tx <= 0;
                    end 
                    
                    else if (tx_idx > 0 && tx_idx < 9) begin /* payload bits */
                        tx <= tx_byte[tx_idx - 1];
                    end                       

                    else if (tx_idx == 9) begin              /* stop bit high */
                        tx <= 1;
                    end

                    counter <= 0;
                    tx_idx  <= tx_idx + 1;
                end
            end

            S_STOP: begin
                tx_idx <= 0;
                counter <= 0;
            end
        endcase
     end
endmodule