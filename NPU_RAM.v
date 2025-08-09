module ai_ram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10              
)(
    input wire clk,
    input wire we,                          
    input wire [ADDR_WIDTH-1:0] addr,     
    input wire [DATA_WIDTH-1:0] din,     
    output reg [DATA_WIDTH-1:0] dout       
);

   
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        // $readmemh("weights.hex", mem); 
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];                
    end

endmodule
