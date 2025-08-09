module matrix_dot_4x4 (
    input clk,
    input reset,

    input [7:0] A_in_0, A_in_1, A_in_2, A_in_3,
    input [7:0] B_in_0, B_in_1, B_in_2, B_in_3,

    output [31:0] C_out_00, C_out_01, C_out_02, C_out_03,
    output [31:0] C_out_10, C_out_11, C_out_12, C_out_13,
    output [31:0] C_out_20, C_out_21, C_out_22, C_out_23,
    output [31:0] C_out_30, C_out_31, C_out_32, C_out_33
);

    
    wire [7:0] A_in [0:3];
    wire [7:0] B_in [0:3];

    assign A_in[0] = A_in_0;
    assign A_in[1] = A_in_1;
    assign A_in[2] = A_in_2;
    assign A_in[3] = A_in_3;

    assign B_in[0] = B_in_0;
    assign B_in[1] = B_in_1;
    assign B_in[2] = B_in_2;
    assign B_in[3] = B_in_3;

    
    wire [7:0] a_wire [0:3][0:4];       
    wire [7:0] b_wire [0:4][0:3];     
    wire [31:0] acc_wire [0:3][0:3];   

    
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : init_inputs
            assign a_wire[i][0] = A_in[i];
            assign b_wire[0][i] = B_in[i];
        end
    endgenerate

    
    genvar row, col;
    generate
        for (row = 0; row < 4; row = row + 1) begin : row_loop
            for (col = 0; col < 4; col = col + 1) begin : col_loop
                PE pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .a_in(a_wire[row][col]),
                    .b_in(b_wire[row][col]),
                    .acc_in((col == 0) ? 32'd0 : acc_wire[row][col - 1]),
                    .a_out(a_wire[row][col + 1]),
                    .b_out(b_wire[row + 1][col]),
                    .acc_out(acc_wire[row][col])
                );
            end
        end
    endgenerate

   
    assign C_out_00 = acc_wire[0][0]; assign C_out_01 = acc_wire[0][1];
    assign C_out_02 = acc_wire[0][2]; assign C_out_03 = acc_wire[0][3];
    assign C_out_10 = acc_wire[1][0]; assign C_out_11 = acc_wire[1][1];
    assign C_out_12 = acc_wire[1][2]; assign C_out_13 = acc_wire[1][3];
    assign C_out_20 = acc_wire[2][0]; assign C_out_21 = acc_wire[2][1];
    assign C_out_22 = acc_wire[2][2]; assign C_out_23 = acc_wire[2][3];
    assign C_out_30 = acc_wire[3][0]; assign C_out_31 = acc_wire[3][1];
    assign C_out_32 = acc_wire[3][2]; assign C_out_33 = acc_wire[3][3];

endmodule
