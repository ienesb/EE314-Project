`timescale 1ns / 1ps

module rgbSelector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480)(
	 input clk,
    input [15:0] x, 
    input [15:0] y, 
    input [1:0] board_data_in,
	 input [1:0] turn,
	 input [4:0] scoreTri,
	 input [4:0] scoreCirc,
	 input [4:0] rpx,
	 input [4:0] rpy,
	 input winCondition,
	 input [3:0] movTrig,
	 input [3:0] movCirc,
	 input [3:0] pressCounterx,
	 input [3:0] pressCountery,
    output [2:0] rgb,
	 output reg [6:0] addr
);

    reg [2:0] tri_mem [1023:0];
	 reg [2:0] circle_mem [1023:0];
	 reg [2:0] empty_mem [1023:0];
	 
	 reg [2:0] left_mem [10239:0];
	 reg [2:0] up_mem [10239:0];
	 
	 reg [2:0] tri_empty_mem [16383:0];
	 reg [2:0] tri_filled_mem [16383:0];
	 
	 reg [2:0] circle_empty_mem [16383:0];
	 reg [2:0] circle_filled_mem [16383:0];
	 
	 reg [2:0] total_moves_mem [11263:0];
	 reg [2:0] wins_mem [4095:0];
	 reg [2:0] recent_position_mem [11263:0];
	 
	 reg [2:0] tri_turn_mem [8191:0];
	 reg [2:0] circle_turn_mem [8191:0];
	 
	 reg [2:0] winner_tri_mem [20479:0];
	 reg [2:0] winner_circle_mem [20479:0];
	 
	 reg [2:0] rgb_reg;
	 reg read = 0;
	 
	 reg [4:0] x_reg; 
	 reg [4:0] y_reg;
	 
	 reg [1:0] slope;
	 reg [3:0] endpoint_x;
	 reg [3:0] endpoint_y;
	 	 
    initial begin 
        $readmemb("tri.mem", tri_mem);
        $readmemb("circle.mem", circle_mem);
        $readmemb("empty.mem", empty_mem);
		  
        $readmemb("left.mem", left_mem);
        $readmemb("up.mem", up_mem);
		  
        // $readmemb("tri_empty.mem", tri_empty_mem);
        $readmemb("tri_filled.mem", tri_filled_mem);
        // $readmemb("circle_empty.mem", circle_empty_mem);
        $readmemb("circle_filled.mem", circle_filled_mem);
		  
        $readmemb("total_moves.mem", total_moves_mem);
        $readmemb("wins.mem", wins_mem);
        $readmemb("recent_position.mem", recent_position_mem);
		  
        // $readmemb("triangle_turn.mem", tri_turn_mem);
        // $readmemb("circle_turn.mem", circle_turn_mem);
		  
        $readmemb("winner_1.mem", winner_tri_mem);
        $readmemb("winner_2.mem", winner_circle_mem);
    end
	always @(posedge clk) begin
		

		if (x >= 176 && x < 496 && y >= 32 && y < 352) begin // board
			if(read == 0) begin
				read <= 1;
				x_reg <= x[4:0] - 16;
				y_reg <= y[4:0];
				addr <= ((x-176)/32) + ((y-32)/32)*10;
			end
			else begin
				read <= 0;
				if (winCondition == 1) begin
					case(slope)
						2'b00: begin 
							if (x <= (endpoint_x*32+192) && x >= (endpoint_x*32+96) && y <= (endpoint_y*32+29) && y >= (endpoint_y*32+35)) begin
								rgb_reg <= 'b100;
							end
						end
					endcase
				end 
				else begin
					case(board_data_in)
						2'b00:	rgb_reg <= empty_mem[32 * y_reg + x_reg];
						2'b01:	rgb_reg <= tri_mem[32 * y_reg + x_reg];
						2'b10:	rgb_reg <= circle_mem[32 * y_reg + x_reg];
						2'b11:	rgb_reg <= 3'b100;
					endcase
				end
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
		else if (x >= 0 && x < 176 && y >= 368 && y < 432) begin // total_moves
			rgb_reg <= total_moves_mem[176 * (y-368) + x];
		end
		else if (x >= 256 && x < 320 && y >= 368 && y < 432) begin // wins
			rgb_reg <= wins_mem[64 * (y-368) + x-256];
		end
		else if (x >= 384 && x < 560 && y >= 368 && y < 432) begin // recent_position
			rgb_reg <= recent_position_mem[176 * (y-368) + x-384];
		end
		else if (x >= 0 && x < 640 && y >= 448 && y < 480) begin // winning case
			if (winCondition == 1) begin
				case(turn)
					2'b01: rgb_reg <= winner_tri_mem[640 * (y-448) + x];
					2'b10: rgb_reg <= winner_circle_mem[640 * (y-448) + x];
				endcase
			end
			else begin
				rgb_reg <= 'b111;
			end
		end
		
		
		else if (x >= 8 && x < 136 && y >= 128 && y < 192) begin // tri_turn
			rgb_reg <= (turn == 'b01) ? tri_turn_mem[128 * (y-128) + x-8]:3'b111;
		end
		else if (x >= 504 && x < 632 && y >= 128 && y < 192) begin // circle_turn
			rgb_reg <= (turn == 'b10) ? circle_turn_mem[128 * (y-128) + x-504]:3'b111;
		end
		else if (x >= 320 && x < 352 && y >= 368 && y < 400) begin // score_tri_1
			rgb_reg <= left_mem[1024 * (scoreTri/10) + 32 * (y-368) + x-320];
		end
		else if (x >= 352 && x < 384 && y >= 368 && y < 400) begin // score_tri_2
			rgb_reg <= left_mem[1024 * (scoreTri%10) + 32 * (y-368) + x-352];
		end
		else if (x >= 320 && x < 352 && y >= 400 && y < 432) begin // score_circle_1
			rgb_reg <= left_mem[1024 * (scoreCirc/10) + 32 * (y-400) + x-320];
		end
		else if (x >= 352 && x < 384 && y >= 400 && y < 432) begin // score_circle_2
			rgb_reg <= left_mem[1024 * (scoreCirc%10) + 32 * (y-400) + x-352];
		end
		
		else if (x >= 176 && x < 208 && y >= 368 && y < 400) begin // mov_tri_1
			rgb_reg <= left_mem[1024 * (movTrig/10) + 32 * (y-368) + x-176];
		end
		else if (x >= 208 && x < 240 && y >= 368 && y < 400) begin // mov_tri_2
			rgb_reg <= left_mem[1024 * (movTrig%10) + 32 * (y-368) + x-208];
		end
		else if (x >= 176 && x < 208 && y >= 400 && y < 432) begin // mov_circle_1
			rgb_reg <= left_mem[1024 * (movCirc/10) + 32 * (y-400) + x-176];
		end
		else if (x >= 208 && x < 240 && y >= 400 && y < 432) begin // mov_circle_2
			rgb_reg <= left_mem[1024 * (movCirc%10) + 32 * (y-400) + x-208];
		end
		
		else if (x >= 576 && x < 608 && y >= 368 && y < 400) begin // rp_tri_1
			rgb_reg <= up_mem[32 * rpx + 320 * (y-368) + x-576];
		end
		else if (x >= 608 && x < 640 && y >= 368 && y < 400) begin // rp_tri_2
			rgb_reg <= left_mem[1024 * rpy + 32 * (y-368) + x-608];
		end
		
		else if (x >= 576 && x < 608 && y >= 400 && y < 432) begin // rp_circle_1
			rgb_reg <= left_mem[1024 * pressCounterx + 32 * (y-400) + x-576];
		end
		else if (x >= 608 && x < 640 && y >= 400 && y < 432) begin // rp_circle_2
			rgb_reg <= left_mem[1024 * pressCountery + 32 * (y-400) + x-608];
		end
		
		else begin
			rgb_reg <= 3'b111;
		end
	end
    
    assign rgb = rgb_reg;
    
endmodule
