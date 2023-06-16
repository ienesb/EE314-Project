// Quartus II Verilog Template
// True Dual Port RAM with single clock

module board_memory
#(parameter DATA_WIDTH=2, parameter ADDR_WIDTH=7)
(
	input clk,
	input [(ADDR_WIDTH-1):0] addr_a,
	output reg [(DATA_WIDTH-1):0] q_a
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] board[2**ADDR_WIDTH-1:0];

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
	end
	
	// Port A 
	always @ (posedge clk)
	begin
		q_a <= board[addr_a]; 
	end 

endmodule
