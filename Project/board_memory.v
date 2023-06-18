// Quartus II Verilog Template
// True Dual Port RAM with single clock

module board_memory(
	input clk,
	input [3:0] addr_x,
	input [3:0] addr_y,
	output reg [1:0] q_a
);

	// Declare the RAM variable
	reg [1:0] board [9:0][9:0];

	initial begin
		board[0][0] <= 2'b00;
		board[0][1] <= 2'b00;
		board[0][2] <= 2'b01;
		board[0][3] <= 2'b00;
		board[0][4] <= 2'b10;
		board[0][5] <= 2'b00;
		board[0][6] <= 2'b11;
		board[0][7] <= 2'b00;
		board[0][8] <= 2'b11;
		board[0][9] <= 2'b00;
		board[1][0] <= 2'b01;
		board[1][1] <= 2'b00;
		board[1][2] <= 2'b10;
		board[1][3] <= 2'b10;
		board[1][4] <= 2'b01;
		board[1][5] <= 2'b11;
	end	
	// Port A 
	always @ (posedge clk)
	begin
		q_a <= board[addr_y][addr_x]; 
	end 

endmodule
