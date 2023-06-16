`timescale 1ns / 1ps

module rgbSelector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480)(
	 input clk,
    input [15:0] x, 
    input [15:0] y, 
    input [1:0] board_data_in,
    output [2:0] rgb,
	 output reg [6:0] addr
);

//    reg [2:0] template [IMG_HEIGHT * IMG_WIDTH - 1:0];
    reg [2:0] tri_mem [1023:0];
	 reg [2:0] circle_mem [1023:0];
	 reg [2:0] empty_mem [1023:0];
	 // reg [2:0] left_mem [10239:0];
	 // reg [2:0] top_mem [10239:0];
	 
	 reg [2:0] rgb_reg;
	 reg read = 0;
	 
	 reg [4:0] x_reg; 
	 reg [4:0] y_reg;
	 
    initial begin 
        // $readmemb("intro.mem", template);
        $readmemb("tri.mem", tri_mem);
        $readmemb("circle.mem", circle_mem);
        $readmemb("empty.mem", empty_mem);
        // $readmemb("left.mem", left_mem);
        // $readmemb("top.mem", top_mem);
    end
	always @(posedge clk) begin
		
		if (x < 160 || x >= 480 || y >= 320) begin
			rgb_reg <= 3'b111;
		end
		else begin
			if(read == 0) begin
				read <= 1;
				x_reg <= x[4:0];
				y_reg <= y[4:0];
				addr <= ((x-160)/32) + (y/32)*10;
			end
			else begin
				read <= 0;
				case(board_data_in)
					2'b00:	rgb_reg <= empty_mem[32 * y_reg + x_reg];
					2'b01:	rgb_reg <= tri_mem[32 * y_reg + x_reg];
					2'b10:	rgb_reg <= circle_mem[32 * y_reg + x_reg];
					2'b11:	rgb_reg <= 3'b000;
				endcase
			end
		end	
	end
    
    assign rgb = rgb_reg;
    // assign rgb = template[IMG_WIDTH * y + x];
    // assign rgb = 3'b111;
    
endmodule
