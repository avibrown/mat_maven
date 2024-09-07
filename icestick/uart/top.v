`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D1,
    output D2,
    output D5
);

    reg [23:0] counter;

    /* --- serial --- */

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

    /* --- mat mul --- */

    reg [7:0]  a11, a12, a21, a22;
    reg [7:0]  b11, b12, b21, b22;
    reg [7:0]  c11, c12, c21, c22;
    reg [2:0]  matA_idx, matB_idx;
    reg [7:0]  current_job;
    reg        current_mat;
    localparam A = 0;
    localparam B = 1;

    mat_mul mat_mul (
        .clk(clk),
        .a11(a11), .a12(a12), .a21(a21), .a22(a22),
        .b11(b11), .b12(b12), .b21(b21), .b22(b22),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22) 
    );

    /* --- fsm --- */

    reg [3:0]  state;
    reg [3:0]  next_state;
    localparam S_IDLE      = 0;
    localparam S_START     = 1;
    localparam S_CHECK_JOB = 2;
    localparam S_MAT_A     = 3;
    localparam S_MAT_B     = 4;
    localparam S_STOP      = 5;

    initial begin
        test_char      <= "0";
        counter        <= 0;
        rx_enable      <= 1;
        tx_enable      <= 0;
        state          <= S_IDLE;
        next_state     <= S_IDLE;
        current_mat    <= A;
    end

    assign tx_enable = ~rx_enable;

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(posedge clk) begin
        rx_enable <= 1;
        counter <= counter + 1;

            case (state)

                /* ------ */

                S_IDLE: begin
                    if (byte_available) begin
                        if (rx_byte == 8'hFF) begin
                            next_state <= S_START;
                        end
                    end
                end

                /* ------ */

                S_START: begin
                    if (byte_available) begin
                        if (rx_byte == 8'h00) begin
                            current_mat <= A;
                            next_state <= S_CHECK_JOB;
                        end else if (rx_byte == 8'h01) begin
                            current_mat <= B;
                            next_state <= S_CHECK_JOB;
                        end else begin
                            next_state <= S_IDLE;
                        end
                    end
                end

                /* ------ */

                S_CHECK_JOB: begin
                    if (byte_available) begin
                        if (current_mat == A) begin
                            current_job <= rx_byte;
                            next_state <= S_MAT_A;
                        end 
                        
                        else if (current_mat == B) begin
                            if (current_job == rx_byte) begin
                                next_state <= S_MAT_B;
                            end else begin
                                next_state <= S_IDLE;
                            end    
                        end
                    end
                end

                /* ------ */

                S_MAT_A: begin
                    if (byte_available) begin
                        case (matA_idx)
                            0: a11 <= rx_byte;
                            1: a12 <= rx_byte;
                            2: a21 <= rx_byte;
                            3: a22 <= rx_byte;
                            default: begin
                                next_state  <= S_IDLE; /* start next mat */
                            end 
                        endcase

                        matA_idx <= matA_idx + 1;
                    end

                    else begin /* restart if no byte available... */
                        next_state <= S_IDLE;
                    end
                end
                
                /* ------ */
                
                S_MAT_B: begin
                            D5 <= ~D5;
                    if (byte_available) begin
                        case (matB_idx)
                            0: b11 <= rx_byte;
                            1: b12 <= rx_byte;
                            2: b21 <= rx_byte;
                            3: b22 <= rx_byte;
                            default: begin
                                next_state <= S_STOP; /* start next mat */
                                current_mat <= A;
                            end
                        endcase

                        matB_idx <= matB_idx + 1;
                    end

                    else begin /* restart if no byte available... */
                        next_state <= S_IDLE;
                        current_mat <= A;
                    end
                end
            endcase

        // if (counter >= 12_000_00) begin
        //     rx_enable <= 0;
        //     D5 <= ~D5;
        //     tx_byte   <= test_char;   
        //     counter   <= 0;       
        // end else begin
        //     rx_enable <= 1;
        // end
    end
endmodule