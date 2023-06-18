module mod6(
				input clk,
				input [1:0] prevTurn,
				output reg [1:0] reallyErased,
				output reg [3:0] randomDebug,
				output wire [3:0] rndDebug2
				);

integer mov_counter;
integer array_counter;
integer flag;
reg [1:0] bookKeeper [24:0];
integer i;
initial 
begin 
	mov_counter = 0;
	array_counter = 0;
	flag = 0;
	for (i = 0; i <= 24; i = i + 1)
	begin
		bookKeeper[i] = 2'b00;
	end
end


always @(posedge clk) begin
	mov_counter <= mov_counter + 1;
	if(mov_counter == 25) begin
		mov_counter <= 0;
		randomDebug <= 0;
	end
	if (mov_counter % 6 == 0) begin
		bookKeeper[array_counter] <= 2'b11;
		flag <= 1;
		randomDebug <= 1;
	end else if (flag == 1) begin
		reallyErased <= array_counter;
		flag <= 0;
		randomDebug <= 2;
		array_counter <= array_counter + 1;
	end
end 

assign rndDebug2 = mov_counter;



endmodule