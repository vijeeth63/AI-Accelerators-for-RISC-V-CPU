module conv2d_controller (
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire [8*36-1:0] input_image_flat,   
    input  wire [8*9-1:0]  kernel_flat,        

    output reg  [32*16-1:0] feature_map_flat, 
    output reg  done
);

    reg [7:0] image[0:5][0:5];
    reg [7:0] kernel[0:2][0:2];
    reg [3:0] row, col, out_idx;
    reg [1:0] state;

    localparam IDLE = 0, LOAD = 1, COMPUTE = 2, DONE = 3;

    integer i, j;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 6; i = i + 1)
                for (j = 0; j < 6; j = j + 1)
                    image[i][j] <= 8'd0;
            for (i = 0; i < 3; i = i + 1)
                for (j = 0; j < 3; j = j + 1)
                    kernel[i][j] <= 8'd0;
        end else if (state == LOAD) begin
            for (i = 0; i < 6; i = i + 1)
                for (j = 0; j < 6; j = j + 1)
                    image[i][j] <= input_image_flat[8*(i*6 + j) +: 8];
            for (i = 0; i < 3; i = i + 1)
                for (j = 0; j < 3; j = j + 1)
                    kernel[i][j] <= kernel_flat[8*(i*3 + j) +: 8];
        end
    end

   
    wire [7:0] A_in_0, A_in_1, A_in_2, A_in_3;
    wire [7:0] B_in_0, B_in_1, B_in_2, B_in_3;
    wire [31:0] C_out_00;

    assign A_in_0 = image[row][col];
    assign A_in_1 = image[row][col + 1];
    assign A_in_2 = image[row][col + 2];
    assign A_in_3 = 8'd0;

    assign B_in_0 = kernel[0][0];
    assign B_in_1 = kernel[0][1];
    assign B_in_2 = kernel[0][2];
    assign B_in_3 = 8'd0;

    
    matrix_dot_4x4 mac_inst (
        .clk(clk),
        .reset(reset),
        .A_in_0(A_in_0), .A_in_1(A_in_1), .A_in_2(A_in_2), .A_in_3(A_in_3),
        .B_in_0(B_in_0), .B_in_1(B_in_1), .B_in_2(B_in_2), .B_in_3(B_in_3),
        .C_out_00(C_out_00),    
        .C_out_01(), .C_out_02(), .C_out_03(),
        .C_out_10(), .C_out_11(), .C_out_12(), .C_out_13(),
        .C_out_20(), .C_out_21(), .C_out_22(), .C_out_23(),
        .C_out_30(), .C_out_31(), .C_out_32(), .C_out_33()
    );

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            row <= 0;
            col <= 0;
            out_idx <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start)
                        state <= LOAD;
                end

                LOAD: begin
                    row <= 0;
                    col <= 0;
                    out_idx <= 0;
                    state <= COMPUTE;
                end

                COMPUTE: begin
                    
                    feature_map_flat[32*out_idx +: 32] <= C_out_00;

                    
                    if (col < 3) begin
                        col <= col + 1;
                        out_idx <= out_idx + 1;
                    end else if (row < 3) begin
                        row <= row + 1;
                        col <= 0;
                        out_idx <= out_idx + 1;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
