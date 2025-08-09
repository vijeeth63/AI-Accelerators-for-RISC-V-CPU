module PE (
    input clk,
    input reset,
    input [7:0] a_in,
    input [7:0] b_in,
    input [31:0] acc_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [31:0] acc_out
);

    reg [15:0] product_internal;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc_out <= 0;
            a_out <= 0;
            b_out <= 0;
        end else begin
            product_internal <= a_in * b_in;
            acc_out <= acc_in + product_internal;
            a_out <= a_in;
            b_out <= b_in;
        end
    end

endmodule
