`default_nettype none

//-- Template for the top entity
module uart(
    input  clk,
    output D1
    );

reg [23:0] counter;

always @(posedge clk) begin
    counter <= counter + 1;
    if (counter == 12_000_000) begin
        counter <= 0;
        D1 <= ~D1;
    end
end

endmodule
