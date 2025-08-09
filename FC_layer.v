module fc_layer (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [31:0] in_flat,                    
    input wire [8*4*4-1:0] weights_flat,           
    input wire [31:0] bias,                        
    output reg [31:0] out_score,                  
    output reg done
);

    
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               COMPUTE = 2'd2,
               DONE = 2'd3;

    reg [1:0] state;
    reg [7:0] inputs [0:3];
    reg [7:0] weights [0:3][0:3];
    reg [7:0] biases [0:3];
    reg [15:0] accum [0:3];
    integer i, j;

    
    always @(*) begin
        for (i = 0; i < 4; i = i + 1)
            inputs[i] = in_flat[i*8 +: 8];
    end

  
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            out_score <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        
                        for (i = 0; i < 4; i = i + 1)
                            for (j = 0; j < 4; j = j + 1)
                                weights[i][j] <= weights_flat[(i*32)+(j*8) +: 8];

                        
                        for (i = 0; i < 4; i = i + 1)
                            biases[i] <= bias[i*8 +: 8];

                        state <= LOAD;
                    end
                end

                LOAD: begin
                    
                    for (i = 0; i < 4; i = i + 1)
                        accum[i] <= 0;

                    state <= COMPUTE;
                end

                COMPUTE: begin
                    for (i = 0; i < 4; i = i + 1)
                        for (j = 0; j < 4; j = j + 1)
                            accum[i] <= accum[i] + inputs[j] * weights[i][j];

                    state <= DONE;
                end

                DONE: begin
                   out_score <= {
    (accum[0] + biases[0]) & 8'hFF,
    (accum[1] + biases[1]) & 8'hFF,
    (accum[2] + biases[2]) & 8'hFF,
    (accum[3] + biases[3]) & 8'hFF
};
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
