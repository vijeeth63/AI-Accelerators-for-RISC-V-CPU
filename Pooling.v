module max_pool_2x2 (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [127:0] in_flat,    
    output reg  [31:0]  out_flat,   
    output reg         done
);

    
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state, next_state;

    
    reg [7:0] in[0:15];  
    reg [7:0] out[0:3];  

    integer i;

   
    function [7:0] max4;
        input [7:0] a, b, c, d;
        begin
            max4 = a;
            if (b > max4) max4 = b;
            if (c > max4) max4 = c;
            if (d > max4) max4 = d;
        end
    endfunction

    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    always @(*) begin
        case (state)
            IDLE:    next_state = start ? COMPUTE : IDLE;
            COMPUTE: next_state = DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

   
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                done <= 0;
            end

            COMPUTE: begin
                
                for (i = 0; i < 16; i = i + 1)
                    in[i] <= in_flat[i*8 +: 8];

              
                out[0] <= max4(in[0], in[1], in[4], in[5]);
                out[1] <= max4(in[2], in[3], in[6], in[7]);
                out[2] <= max4(in[8], in[9], in[12], in[13]);
                out[3] <= max4(in[10], in[11], in[14], in[15]);
            end

            DONE: begin
                
                out_flat <= {out[0], out[1], out[2], out[3]};
                done <= 1;
            end
        endcase
    end

endmodule
