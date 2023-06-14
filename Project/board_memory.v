// Quartus II Verilog Template
// True Dual Port RAM with single clock

module board_memory
#(parameter DATA_WIDTH=2, parameter ADDR_WIDTH=7)
(
	input [(DATA_WIDTH-1):0] data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_b, clk,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	initial begin
		ram[0] <= 2'b00;
		ram[1] <= 2'b00;
		ram[2] <= 2'b01;
		ram[3] <= 2'b00;
		ram[4] <= 2'b10;
		ram[5] <= 2'b00;
		ram[6] <= 2'b11;
		ram[7] <= 2'b00;
		ram[8] <= 2'b11;
		ram[9] <= 2'b00;
		ram[10] <= 2'b01;
		ram[11] <= 2'b00;
		ram[12] <= 2'b10;
		ram[13] <= 2'b10;
		ram[14] <= 2'b01;
		ram[15] <= 2'b11;
	end
	
	// Port A 
	always @ (posedge clk)
	begin
		q_a <= ram[addr_a]; 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end

endmodule
