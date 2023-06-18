module wincheck
					(input clk,
					 input [4:0] fakePosx, //fakePosx and fakePosy will be obtained later when this module is combined with the controller module
					 input [4:0] fakePosy,
					 output reg [7:0] scoreTrig,
					 output reg [7:0] scoreCirc,
					 output reg [3:0] score, //not an actual output just for debugging
					 output reg [7:0] debug); // not an actual output just for debugging


					 
reg [1:0] board [127:0]; 
//board coordinates are the in format [y][x] or [row][column]
//x is + to the right
//y is + downwards
 

// the  looping limits 
integer dxmin, dymin, dxmax, dymax, negdiagoffset_min, negdiagoffset_max, posdiagoffset_min, posdiagoffset_max;


//the looping iterators
integer dx, dy, negdiagoffset, posdiagoffset;


//counters for the number of consecutive similar shapes
integer xcounter = 0;
integer ycounter = 0;
integer posdiagcounter = 0;
integer negdiagcounter = 0;


//board initializing iterators
integer i, j;


//keeps track of the prevTurn, this will be obtained from the main controller module later
reg [1:0] prevTurn = 2'b01;

integer checker_st = 0; //0&1 determine limits, 2 row and column checking


initial
begin

scoreCirc = 0;
scoreTrig = 0;

//fills the board with all 00(empty cells)
for(i = 0; i <= 9; i = i + 1)
	begin
		for(j = 0; j <= 9; j = j + 1)
		begin
		board[i*10 + j] = 'b00;
		end
	end

end

always @(posedge clk)
begin
	case (checker_st)
	
	0: begin
	
		//if current position  - 3 < 0 then we loop until -currentPos
		//else the lower limit is directly -3
		//this is done to avoid iterating outside of the array at an index such 
		//as [-1][5]
		dxmin <= ( ( (fakePosx - (5'b00011)) > 5'b10000)) ? (-fakePosx) : -3; 
		dymin <= ( ( (fakePosy - (5'b00011)) > 5'b10000)) ? (-fakePosy) : -3;
		
		//if current position + 3 is > 10 then we loop until 10 only (i.e. loop counter is 
		//10 - current pos). else we loop for 3 counts
		dxmax <= ( ( (fakePosx + (5'b00011)) >= 5'b01010)) ? (10 - fakePosx) : 3;
		dymax <= ( ( (fakePosy + (5'b00011)) >= 5'b01010)) ? (10 - fakePosy) : 3;
		checker_st <= 1;
		end
	
	1: begin
	
		//looping limits setup for rows and columns
		dx <= dxmin;
		dy <= dymin;
		
		
		//looping limts calculation for positive diagonals
		if ((-dxmin) >= (-dymin)) begin
			posdiagoffset_min <= dymin;
		end else if ((-dymin) > (-dxmin)) begin
			posdiagoffset_min <= dxmin;
		end
		
		if (dxmax <= dymax) begin
			posdiagoffset_max <= dxmax;
		end else if (dxmax > dymax) begin
			posdiagoffset_max <= dymax;
		end
		
		//looping limts calculation for negative diagonals
		if ((-dymin) >= (dxmax)) begin
			negdiagoffset_max <= dxmax;
		end else if ((dxmax) > (-dymin)) begin
			negdiagoffset_max <= dymin;
		end
				
		if ((-dxmin) <= dymax) begin
			negdiagoffset_min <= dxmin;
		end else if ((-dxmin) > dymax) begin
			negdiagoffset_min <= dymax;
		end	
		
		checker_st <= 2;
		
		end //end case 0
		
		2: begin
			
			//setting up the diagonal checking cuonters
			posdiagoffset <= posdiagoffset_min;
			negdiagoffset <= negdiagoffset_min;
			
			//every thing above this point will be incorporated into the main controller
			//the winchecker state in main controller will be at most composed of two stages
			
			//////////////////////////////////////////
					//row debugging//
					//x debugging//
				
				board[10] = 2'b01;
				board[13] = 2'b01;
				board[12] = 2'b01;
				board[11] = 2'b01;
				
				debug <= scoreTrig;
				score <= (fakePosy * 10) + fakePosx + dx;
				
					//column debugging
					//y debugging
			
			//row checking
			if (xcounter == 4 & prevTurn == 2'b01) begin
				scoreTrig <= scoreTrig + 1;
				checker_st <= 6;
			end else if (xcounter == 4 && prevTurn == 2'b10) begin 
				scoreCirc <= scoreCirc + 1;
				checker_st <= 6;
			end else if(dx > dxmax) begin
				xcounter <= 0;
			end else if(board[(fakePosy * 10) + fakePosx + dx] == prevTurn) begin
				dx <= dx + 1;
				xcounter <= xcounter + 1;	
			end else begin
				dx <= dx + 1;
				xcounter <= 0;
			end
			
			//column checking
			if (ycounter == 4 && prevTurn == 2'b01) begin
				scoreTrig <= scoreTrig + 1;
				checker_st <= 6;
			end else if (ycounter == 4 && prevTurn == 2'b10) begin
				scoreCirc <= scoreCirc + 1;
				checker_st <= 6;
	   	end else if(dy > dymax) begin
				ycounter <= 0;
	   	end else if(board[((fakePosy + dy) * 10)+ fakePosx] == prevTurn) begin
				dy <= dy + 1;
				ycounter <= ycounter + 1;	
			end else begin
				dy <= dy + 1;
				ycounter <= 0;
			end
			
			if (dy > dymax && dx > dxmax)
			begin
				checker_st <= 3;
			end
			
			end//endcase
			
			//diagonal checking
		3: begin
		
		
//			//+ve slope diagonal checking
//			if (posdiagcounter == 4 && prevTurn == 2'b01) begin
//				scoreTrig <= scoreTrig + 1;
//				checker_st <= 7;
//			end else if (posdiagcounter == 4 && prevTurn == 2'b10) begin
//				scoreCirc <= scoreCirc + 1;
//				checker_st <= 7;
//			end else if(posdiagoffset > posdiagoffset_max) begin 
//				posdiagcounter <= 0; //
//			end else if(board[fakePosy + posdiagoffset][fakePosx + posdiagoffset] == prevTurn) begin
//				posdiagoffset <= posdiagoffset + 1;
//				posdiagcounter <= posdiagcounter + 1;	
//			end else begin
//				posdiagoffset <= posdiagoffset + 1;
//				posdiagcounter <= 0;
//			end
//			
//				
//			//-ve slope diagonal checking
//			if (negdiagcounter == 4 && prevTurn == 2'b01) begin
//				scoreTrig <= scoreTrig + 1;
//				checker_st <= 7;
//			end else if (negdiagcounter == 4 && prevTurn == 2'b10) begin
//				scoreCirc <= scoreCirc + 1;
//				checker_st <= 7;
//			end else if(negdiagoffset > negdiagoffset_max) begin 
//				negdiagcounter <= 0;
//			end else if(board[fakePosy - negdiagoffset][fakePosx + negdiagoffset] == prevTurn) begin
//				negdiagoffset <= negdiagoffset + 1;
//				negdiagcounter <= negdiagcounter + 1;	
//			end else begin
//				negdiagoffset <= negdiagoffset + 1;
//				negdiagcounter <= 0;
//			end
//			
//			if (negdiagoffset > negdiagoffset_max && posdiagoffset > posdiagoffset_max)
//			begin
//				score <= 7;
//			end
			end
			
			6: begin
				debug <= 4'b1111;
				score <= scoreTrig;
				end
		endcase
		
end //end always


endmodule
