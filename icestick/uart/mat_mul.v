module mat_mul(
    input [7:0] a11, a12, a21, a22,
    input [7:0] b11, b12, b21, b22,
    input clk,
    /* I know this allows overflow */
    output reg [7:0] c11, c12, c21, c22 
);

always @* begin
    c11 = a11 * b11 + a12 * b21;
    c12 = a11 * b12 + a12 * b22;
    c21 = a21 * b11 + a22 * b21;
    c22 = a21 * b12 + a22 * b22;
end

endmodule