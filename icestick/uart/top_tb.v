`timescale 1ns / 1ps

module top_tb();

    reg clk = 0;
    reg rx = 1;
    wire tx;

    top uut(
        .clk(clk),
        .rx(rx),
        .tx(tx)
    );

    always #41.6667 clk = !clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        send_byte(8'hFF);
        send_byte(8'h00);
        send_byte(8'h11);
        send_byte(8'h01);
        send_byte(8'h02);
        send_byte(8'h03);
        send_byte(8'h04);

        // #1000;
        $finish;
    end

    task send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 0;
            #8680;
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #8680;
            end
            rx = 1;
            #8680;
        end
    endtask

endmodule
