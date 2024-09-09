`timescale 1ns / 1ps

module tb_top();

    reg clk = 0;
    reg rx = 1;
    wire tx;

    top uut(
        .clk(clk),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation
    always #41.6667 clk = !clk; // 12 MHz clock

    // Stimulus
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        // Send bytes with start and stop bits at 115200 baud
        send_byte(8'hFF);
        send_byte(8'h00);
        send_byte(8'h11);
        send_byte(8'h01);
        send_byte(8'h02);
        send_byte(8'h03);
        send_byte(8'h04);

        #1000;
        $finish;
    end

    // Function to send a byte including start and stop bits
    task send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 0; // Start bit
            #8680; // One bit time (1/115200 s)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #8680;
            end
            rx = 1; // Stop bit
            #8680; // Stop bit time
        end
    endtask

endmodule
