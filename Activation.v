`timescale 1ns / 1ps

module activation_unit #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire reset,
    input wire [1:0] activation_type, 
    input wire [DATA_WIDTH-1:0] in,
    output reg [DATA_WIDTH-1:0] out
);

    always @(*) begin
        case (activation_type)
            2'b01: begin 
                if (in[DATA_WIDTH-1] == 1'b1)  
                    out = {DATA_WIDTH{1'b0}};
                else
                    out = in;
            end
            2'b10: begin 
                out = in >> 1;
            end
            default: begin
                out = in;
            end
        endcase
    end

endmodule



module activation_controller #(
    parameter NUM_ELEMENTS = 16,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [1:0] activation_type,
    input wire [NUM_ELEMENTS*DATA_WIDTH-1:0] in,   
    output reg [NUM_ELEMENTS*DATA_WIDTH-1:0] out, 
    output reg done
);

    reg [$clog2(NUM_ELEMENTS)-1:0] index; 
    reg processing;

    wire [DATA_WIDTH-1:0] in_element;
    wire [DATA_WIDTH-1:0] activated_out;

    assign in_element = in[index*DATA_WIDTH +: DATA_WIDTH];

    activation_unit #(.DATA_WIDTH(DATA_WIDTH)) act_unit (
        .clk(clk),
        .reset(reset),
        .activation_type(activation_type),
        .in(in_element),
        .out(activated_out)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            index <= 0;
            out <= 0;
            done <= 0;
            processing <= 0;
        end else begin
            if (start && !processing) begin
                processing <= 1;
                index <= 0;
                done <= 0;
            end else if (processing) begin
                out[index*DATA_WIDTH +: DATA_WIDTH] <= activated_out;

                if (index == NUM_ELEMENTS - 1) begin
                    done <= 1;
                    processing <= 0;
                end else begin
                    index <= index + 1;
                end
            end
        end
    end

endmodule
