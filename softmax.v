module softmax_4 (
    input wire clk,
    input wire reset,
    input wire start,

    input wire [15:0] in0, in1, in2, in3,     
    output reg [7:0] out0, out1, out2, out3, 

    output reg done
);

    
    parameter IDLE = 2'd0, EXP = 2'd1, DIVIDE = 2'd2, DONE = 2'd3;
    reg [1:0] state;

    
    reg [15:0] exp0, exp1, exp2, exp3;
    reg [17:0] sum_exp;

    reg [7:0] result0, result1, result2, result3;

    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else begin
            case (state)
                IDLE:    state <= (start) ? EXP : IDLE;
                EXP:     state <= DIVIDE;
                DIVIDE:  state <= DONE;
                DONE:    state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end

    
    reg [31:0] x_sq0, x_sq1, x_sq2, x_sq3;
    reg [15:0] temp_exp0, temp_exp1, temp_exp2, temp_exp3;

    always @(posedge clk) begin
        if (reset) begin
            exp0 <= 0; exp1 <= 0; exp2 <= 0; exp3 <= 0;
            sum_exp <= 0;
            done <= 0;
        end else begin
            case (state)
                EXP: begin
                    x_sq0 <= in0 * in0;
                    x_sq1 <= in1 * in1;
                    x_sq2 <= in2 * in2;
                    x_sq3 <= in3 * in3;

                    temp_exp0 <= 16'd256 + in0 + (x_sq0 >> 9);
                    temp_exp1 <= 16'd256 + in1 + (x_sq1 >> 9);
                    temp_exp2 <= 16'd256 + in2 + (x_sq2 >> 9);
                    temp_exp3 <= 16'd256 + in3 + (x_sq3 >> 9);

                    exp0 <= temp_exp0;
                    exp1 <= temp_exp1;
                    exp2 <= temp_exp2;
                    exp3 <= temp_exp3;
                end

                DIVIDE: begin
                    sum_exp = exp0 + exp1 + exp2 + exp3;

                    if (sum_exp != 0) begin
                        result0 <= (exp0 * 8'd255) / sum_exp;
                        result1 <= (exp1 * 8'd255) / sum_exp;
                        result2 <= (exp2 * 8'd255) / sum_exp;
                        result3 <= (exp3 * 8'd255) / sum_exp;
                    end else begin
                        result0 <= 0;
                        result1 <= 0;
                        result2 <= 0;
                        result3 <= 0;
                    end
                end

                DONE: begin
                    out0 <= result0;
                    out1 <= result1;
                    out2 <= result2;
                    out3 <= result3;
                    done <= 1;
                end

                default: begin
                    done <= 0;
                end
            endcase
        end
    end

endmodule
