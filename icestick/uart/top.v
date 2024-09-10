`default_nettype none

module top(
    input      clk,
    input      rx,
    output     tx,
    // output reg D1,
    // output reg D2,
    output reg D5
);

    reg [23:0] counter;

    /* --- serial --- */

    wire [7:0] rx_byte;
    reg [7:0] tx_byte;
    reg [7:0] test_char;
    wire       byte_available;
    reg       tx_enable;
    reg       rx_enable;

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

    reg [7:0]  _a11, _a12, _a21, _a22;
    wire [7:0]  a11,  a12,  a21,  a22;
    wire [7:0]  b11,  b12,  b21,  b22;
    reg [7:0]  _b11, _b12, _b21, _b22;
    assign a11 = _a11;
    assign a12 = _a12;
    assign a21 = _a21;
    assign a22 = _a22;
    assign b11 = _b11;
    assign b12 = _b12;
    assign b21 = _b21;
    assign b22 = _b22;

    wire [7:0] c11, c12, c21, c22;
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
    reg [1:0]  res_counter;
    reg [7:0]  prev_byte;

    initial begin
        test_char      <= "0";
        counter        <= 0;
        rx_enable      <= 1;
        tx_enable      <= 0;
        state          <= S_IDLE;
        next_state     <= S_IDLE;
        current_mat    <= A;
        res_counter    <= 0;
    end

    always @(negedge clk) begin
        if (~byte_available) begin
            state <= next_state; 
        end
    end

    always @(posedge clk) begin
        tx_enable <= 0;
        rx_enable <= 1;
        counter <= counter + 1;

            case (state)

                /* ------ */

                S_IDLE: begin
                    if (byte_available) begin
                        tx_enable <= 1;
                        tx_byte <= rx_byte;
                        if (rx_byte == 255) begin
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
                        // tx_enable <= 1;
                        // tx_byte <= rx_byte;
                        case (matA_idx)
                            0: _a11 <= rx_byte;
                            1: _a12 <= rx_byte;
                            2: _a21 <= rx_byte;
                            3: _a22 <= rx_byte;
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
                    if (byte_available) begin
                        case (matB_idx)
                            0: _b11 <= rx_byte;
                            1: _b12 <= rx_byte;
                            2: _b21 <= rx_byte;
                            3: _b22 <= rx_byte;
                            4: begin
                            D5 <= ~D5;
                                next_state <= S_STOP;
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

                S_STOP: begin
                    case (res_counter)
                        0: begin
                            // tx_enable   <= 1;
                            // tx_byte     <= c11;
                            res_counter <= res_counter + 1;
                            
                        end

                        1: begin
                            // tx_enable   <= 1;
                            // tx_byte     <= c12;
                            res_counter <= res_counter + 1;
                        end

                        2: begin
                            // tx_enable   <= 1;
                            // tx_byte     <= c21;
                            res_counter <= res_counter + 1;
                        end

                        3: begin
                            // tx_enable   <= 1;
                            // tx_byte     <= c22;
                            res_counter <= 0;
                            next_state  <= S_IDLE; 
                        end

                        default: begin
                            res_counter <= 0;
                            next_state  <= S_IDLE; 
                        end
                    endcase
                    
                end
            endcase
    end
endmodule