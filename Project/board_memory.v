// Quartus II Verilog Template
// True Dual Port RAM with single clock

module board_memory(
	input clk,
	input [6:0] addr_x,
	input [4:0] addr_y,
	output reg [1:0] q_a
);

	// Declare the RAM variable
	reg [1:0] board [128];
	// reg [1:0] board [9:0][9:0];
	integer i,j;

	initial begin
			board[0] <= 2'b00;
			board[1] <= 2'b00;
			board[2] <= 2'b01;
			board[3] <= 2'b00;
			board[4] <= 2'b10;
			board[5] <= 2'b00;
			board[6] <= 2'b11;
			board[7] <= 2'b00;
			board[8] <= 2'b11;
			board[9] <= 2'b00;
			board[10] <= 2'b01;
			board[11] <= 2'b00;
			board[12] <= 2'b10;
			board[13] <= 2'b10;
			board[14] <= 2'b01;
			board[15] <= 2'b11;
		
//		for(i = 0; i <= 9; i = i + 1)
//		begin
//			for(j = 0; j <= 9; j = j + 1)
//			begin
//				board[i*10+j] = 'b10;
//			end
//		end
	
		
	end	
	// Port A 
	always @ (posedge clk)
	begin
		// q_a <= board[addr_x][addr_y]; 
		q_a <= board[addr_x]; 
	end 

endmodule
