`default_nettype none

module top(
    input  clk,
    input  rx,
    output tx,
    output D1,
    output D5,
);

    /* Serial comm stuff */
    reg [7:0] serial_in;
    reg [7:0] serial_out;
    reg serial_busy;
    reg serial_available;
    reg send_request;
    reg [23:0] counter;
    reg [7:0]  char;

    /* mat mul stuff */
    localparam  A = 0;
    localparam  B = 1;
    reg [7:0]   a11, a12, a21, a22;
    reg [7:0]   b11, b12, b21, b22;
    reg [7:0]   c11, c12, c21, c22;
    reg [7:0]   current_job;
    reg         current_mat;
    reg [3:0]   hyperpacket_idx;
    reg [2:0]   result_idx;
    reg         op_in_progress;
    reg         new_job;
    reg [7:0]   checksumA, checksumB;
 
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

    mat_mul mat_mul (
        .clk(clk),
        .a11(a11), .a12(a12), .a21(a21), .a22(a22),
        .b11(b11), .b12(b12), .b21(b21), .b22(b22),
        .c11(c11), .c12(c12), .c21(c21), .c22(c22) 
    );

    initial begin
        counter         <= 0;
        send_request    <= 0;
        char            <= "a";
        op_in_progress  <= 0;
        current_mat     <= A;
        hyperpacket_idx <= 0;
        result_idx      <= 0;
        new_job         <= 0;
    end

    always @(posedge clk) begin
        counter      <= counter + 1;
        send_request <= 0;
        
        if (counter == 1200000) begin
            counter <= 0;
            D1 <= ~D1;
            serial_out   <= current_job;
            // char <= char + 1;
            send_request <= 1;        
        end

        if (serial_available) begin

            case (hyperpacket_idx)
                0: begin /* new hyperpacket */
                    if (serial_in == 8'hFF) begin   /* op code for mat mul */
                        if (~op_in_progress) begin  /* check if new job */
                            op_in_progress <= 1;
                            new_job        <= 1;
                            current_mat    <= A;
                        end 
                        else begin
                            current_mat <= B;
                            new_job     <= 0;
                        end      
                        hyperpacket_idx <= hyperpacket_idx + 1;
                    end
                end

                1: begin /* confirm matrix */
                    if ((serial_in == 0 && current_mat != A) ||
                        (serial_in == 1 && current_mat != B)) begin
                        /* something went wrong! restart... */
                        hyperpacket_idx <= 0;
                        op_in_progress  <= 0;
                        current_job     <= 0;
                        new_job         <= 0;
                    end
                    else begin
                        hyperpacket_idx <= hyperpacket_idx + 1;
                    end
                end

                2: begin /* job ID */
                    if (new_job) begin
                        current_job <= serial_in;
                        new_job <= 0;
                        D5 <= ~D5;
                    end
                    else begin
                        if (current_job - serial_in != 0) begin
                            /* something went wrong! restart... */
                            hyperpacket_idx <= 0;
                            op_in_progress  <= 0;
                            current_job     <= 0;
                            new_job         <= 0;
                        end
                        else begin
                            hyperpacket_idx <= hyperpacket_idx + 1;
                        end
                    end
                end

                3: begin /* store item 0 */
                    if (current_mat == A) begin
                        a11 <= serial_in;
                    end else begin
                        b11 <= serial_in;
                    end
                    hyperpacket_idx <= hyperpacket_idx + 1;
                end

                4: begin /* store item 1 */
                    if (current_mat == A) begin
                        a12 <= serial_in;
                    end else begin
                        b12 <= serial_in;
                    end
                    hyperpacket_idx <= hyperpacket_idx + 1;
                end

                5: begin /* store item 2 */
                    if (current_mat == A) begin
                        a21 <= serial_in;
                    end else begin
                        b21 <= serial_in;
                    end
                    hyperpacket_idx <= hyperpacket_idx + 1;
                end

                6: begin /* store item 3 */
                    if (current_mat == A) begin
                        a22 <= serial_in;
                    end else begin
                        b22 <= serial_in;
                    end
                    hyperpacket_idx <= hyperpacket_idx + 1;
                end

                7: begin /* checksum */
                    /* unimplemented for now... */
                    hyperpacket_idx <= hyperpacket_idx + 1;
                end

                8: begin /* send op results */
                    if (current_mat == B) begin
                        case (result_idx)
                            0: begin /* send job ID */
                                serial_out   <= current_job;
                                send_request <= 1;       
                                result_idx   <= result_idx + 1;
                            end
                            
                            1: begin /* send item 1 */
                                serial_out   <= c11;
                                send_request <= 1;       
                                result_idx   <= result_idx + 1;
                            end

                            2: begin /* send item 2 */
                                serial_out   <= c12;
                                send_request <= 1;       
                                result_idx   <= result_idx + 1;
                            end

                            3: begin /* send item 3 */
                                serial_out   <= c21;
                                send_request <= 1;       
                                result_idx   <= result_idx + 1;
                            end

                            4: begin /* send item 4 */
                                serial_out      <= c22;
                                send_request    <= 1;       
                                result_idx      <= result_idx + 1;
                                hyperpacket_idx <= 0;
                                op_in_progress  <= 0;
                                current_job     <= 0;
                                new_job         <= 0;
                            end
                        endcase
                    end
                    
                    else begin
                        hyperpacket_idx <= 0;
                    end

                end
            endcase
        end
    end
endmodule
