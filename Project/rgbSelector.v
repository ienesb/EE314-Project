`timescale 1ns / 1ps

module rgbSelector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480)(
	 input clk,
    input [15:0] x, 
    input [15:0] y, 
    input [1:0] board_data_in,
	 input [1:0] turn,
    output [2:0] rgb,
	 output reg [6:0] addr
);

//    reg [2:0] template [IMG_HEIGHT * IMG_WIDTH - 1:0];
    reg [2:0] tri_mem [1023:0];
	 reg [2:0] circle_mem [1023:0];
	 reg [2:0] empty_mem [1023:0];
	 
	 reg [2:0] left_mem [10239:0];
	 reg [2:0] up_mem [10239:0];
	 
	 reg [2:0] tri_empty_mem [16383:0];
	 reg [2:0] tri_filled_mem [16383:0];
	 
	 reg [2:0] circle_empty_mem [16383:0];
	 reg [2:0] circle_filled_mem [16383:0];
	 
	 reg [2:0] total_moves_mem [12287:0];
	 reg [2:0] wins_mem [4095:0];
	 reg [2:0] recent_position_mem [12287:0];
	 
	 reg [2:0] rgb_reg;
	 reg read = 0;
	 
	 reg [4:0] x_reg; 
	 reg [4:0] y_reg;
	 
	 reg [8:0] x_reg9; 
	 reg [8:0] y_reg9;
	 
    initial begin 
        // $readmemb("intro.mem", template);
        $readmemb("tri.mem", tri_mem);
        $readmemb("circle.mem", circle_mem);
        $readmemb("empty.mem", empty_mem);
		  
        $readmemb("left.mem", left_mem);
        $readmemb("up.mem", up_mem);
		  
        $readmemb("tri_empty.mem", tri_empty_mem);
        $readmemb("tri_filled.mem", tri_filled_mem);
        $readmemb("circle_empty.mem", circle_empty_mem);
        $readmemb("circle_filled.mem", circle_filled_mem);
		  
        $readmemb("total_moves.mem", total_moves_mem);
        $readmemb("wins.mem", wins_mem);
        $readmemb("recent_position.mem", recent_position_mem);
    end
	always @(posedge clk) begin
		
//		if (x < 160 || x >= 480 || y >= 320) begin
//			rgb_reg <= 3'b111;
//		end
		if (x >= 176 && x < 496 && y >= 32 && y < 352) begin // board
			if(read == 0) begin
				read <= 1;
				x_reg <= x[4:0] - 16;
				y_reg <= y[4:0];
				addr <= ((x-176)/32) + ((y-32)/32)*10;
			end
			else begin
				read <= 0;
				case(board_data_in)
					2'b00:	rgb_reg <= empty_mem[32 * y_reg + x_reg];
					2'b01:	rgb_reg <= tri_mem[32 * y_reg + x_reg];
					2'b10:	rgb_reg <= circle_mem[32 * y_reg + x_reg];
					2'b11:	rgb_reg <= 3'b100;
				endcase
			end
		end
		else if (x >= 144 && x < 176 && y >= 32 && y < 352) begin // left
			rgb_reg <= left_mem[32 * (y-32) + x-144];
		end
		else if (x >= 176 && x < 496 && y >= 0 && y < 32) begin // up
			rgb_reg <= up_mem[320 * y + x-176];
		end
		else if (x >= 8 && x < 136 && y >= 192 && y < 320) begin // left tri
			rgb_reg <= (turn == 'b01) ? tri_filled_mem[128 * (y-192) + x-8]:tri_empty_mem[128 * (y-192) + x-8];
		end
		else if (x >= 504 && x < 632 && y >= 192 && y < 320) begin // right circle
			rgb_reg <= (turn == 'b10) ? circle_filled_mem[128 * (y-192) + x-504]:circle_empty_mem[128 * (y-192) + x-504];
		end
		else if (x >= 0 && x < 192 && y >= 368 && y < 432) begin // total_moves
			rgb_reg <= total_moves_mem[192 * (y-368) + x];
		end
		else if (x >= 256 && x < 320 && y >= 368 && y < 432) begin // wins
			rgb_reg <= wins_mem[64 * (y-368) + x-256];
		end
		else if (x >= 384 && x < 576 && y >= 368 && y < 432) begin // recent_position
			rgb_reg <= recent_position_mem[192 * (y-368) + x-384];
		end
		else begin
			rgb_reg <= 3'b111;
		end
	end
    
    assign rgb = rgb_reg;
    // assign rgb = template[IMG_WIDTH * y + x];
    // assign rgb = 3'b111;
    
endmodule
