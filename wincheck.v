module wincheck
					(input clk,
					 input [4:0] fakePosx, //fakePosx and fakePosy will be obtained later when this module is combined with the controller module
					 input [4:0] fakePosy,
					 output reg [7:0] scoreTrig,
					 output reg [7:0] scoreCirc,
					 output reg [3:0] score, //not an actual output just for debugging
					 output reg [7:0] debug); // not an actual output just for debugging


reg [1:0] board [9:0][9:0]; 
//board coordinates are the in format [y][x] or [row][column]
//x is + to the right
//y is + downwards
 
//the max limit we can check up to, used to handle edge cases
integer dxmax;
integer dymax;

// the iterators for looping over the loop, they always start from the minimum position  
integer dy; 
integer dx;
integer diagoffset_min;
integer diagoffset_max;

//used to count the number of consecutive similar items
integer xcounter = 0;
integer ycounter = 0;
integer posdiagcounter = 0;
integer negdiagcounter = 0;

//intializing scores to 0, board to be all zeros
integer i, j;
reg [1:0] prevTurn = 2'b10;
initial
begin

scoreCirc = 0;
scoreTrig = 0;

for(i = 0; i <= 9; i = i + 1)
	begin
		for(j = 0; j <= 9; j = j + 1)
		begin
		board[i][j] = 'b00;
		end
	end
end



integer checker_st = 0; //0 determine limits, 1 check rows, 2 check columns, 3 diagonal limits set up,
								//4 positive slope diag, 5 negative slope diag, //6 end;


		
always @(posedge clk)
		
		
		case (checker_st)
			0: begin
			
				//debug
				
					//row debugging//
					//x debugging//
				//board[2][1] = 2'b01;
				//board[2][2] = 2'b01;
				//board[2][3] = 2'b11; 
				//board[2][4] = 2'b01;
				//board[2][5] = 2'b01;
				//board[2][6] = 2'b01;
				//board[2][7] = 2'b01; 
				//board[2][8] = 2'b11;
				
					//column debugging
					//y debugging
				//board[0][2] = 2'b01;
				//board[1][2] = 2'b01;
				//board[2][2] = 2'b01;
				//board[3][2] = 2'b01;
				//board[4][2] = 2'b11;
				//board[5][2] = 2'b11;
				//board[6][2] = 2'b11;
				//board[7][2] = 2'b11;
						//end debug
					
					//negative diag debug
				//board[0][1] = 2'b10;
				//board[1][2] = 2'b10;
				//board[2][3] = 2'b10;
				//board[3][4] = 2'b10;
				//board[4][5] = 2'b11;
				//board[5][6] = 2'b11;
				//board[6][7] = 2'b11;
				//board[7][8] = 2'b11;
				//board[8][9] = 2'b11;
				
					//positive diag debug	
				board[1][9] = 2'b10;
				board[2][8] = 2'b10;
				board[3][7] = 2'b10;
				board[4][6] = 2'b10;
				board[5][5] = 2'b11;
				board[6][4] = 2'b11;
				board[7][3] = 2'b11;
				board[8][2] = 2'b11;
				board[9][1] = 2'b10;
				
				// if current position - 3 is negative we start checking from -pos
				// if position is 0 we start checking from 0
				// if position - 3 is positive we start checking from -3
				//tbh idk why i did the 0 condition i think its unnecessary. i was really tired when i coded this part
				//so its not my best code. for now its staying this way cuz if it aint broke why fix it?
				dx <= ( ( (fakePosx - (5'b00011)) > 5'b10000)) ? (fakePosx == 0 ? 0 : -fakePosx) : -3; 
				dy <= ( ( (fakePosy - (5'b00011)) > 5'b10000)) ? (fakePosy == 0 ? 0 : -fakePosy) : -3;
				
				// if current position + 3 is > 10 we set the max loop limit to 10 - current position
				// else we set it to 3
				dxmax <= ( ( (fakePosx + (5'b00011)) > 5'b01010)) ? (fakePosx == 10 ? 0 : (10 - fakePosx)) : 3;
				dymax <= ( ( (fakePosy + (5'b00011)) > 5'b01010)) ? (fakePosy == 10 ? 0 : (10 - fakePosy)) : 3;
				//debug <= dymin + 5;
				
				
				checker_st <= 1;
			end //end case setup
			
			//row checking
			1: begin 
				
				// since the if statements contain state transitions it is really important to keep them in this order otherwise
				// you will get weird behaving code
				// since we ruined out minimum counter by adding to it we need to recalculate it again. is this the best way of doing
				// things? again coding while tired results in bad code. 
				
				if (xcounter == 4 && prevTurn == 2'b01) begin
					dx <= ( ( (fakePosx - (5'b00011)) > 5'b10000)) ? (fakePosx == 0 ? 0 : -fakePosx) : -3; 
					scoreTrig <= scoreTrig + 1;
					checker_st <= 6;
				end else if (xcounter == 4 && prevTurn == 2'b10) begin
					dx <= ( ( (fakePosx - (5'b00011)) > 5'b10000)) ? (fakePosx == 0 ? 0 : -fakePosx) : -3; 
					scoreCirc <= scoreCirc + 1;
					checker_st <= 6;
				end else if(dx > dxmax) begin
					dx <= ( ( (fakePosx - (5'b00011)) > 5'b10000)) ? (fakePosx == 0 ? 0 : -fakePosx) : -3; 
					checker_st <= 2;
				end else if(board[fakePosy][fakePosx + dx] == prevTurn) begin
					dx <= dx + 1;
					xcounter <= xcounter + 1;	
				end else begin
					dx <= dx + 1;
					xcounter <= 0;
				end
				end //end case rows
			
			 
			 2: begin
				 
				 if (ycounter == 4 && prevTurn == 2'b01) begin
					dy <= ( ( (fakePosy - (5'b00011)) > 5'b10000)) ? (fakePosy == 0 ? 0 : -fakePosy) : -3;
					scoreTrig <= scoreTrig + 1;
					checker_st <= 6;
				 end else if (ycounter == 4 && prevTurn == 2'b10) begin
					dy <= ( ( (fakePosy - (5'b00011)) > 5'b10000)) ? (fakePosy == 0 ? 0 : -fakePosy) : -3;
					scoreCirc <= scoreCirc + 1;
					checker_st <= 6;
				 end else if(dy > dymax) begin
					dy <= ( ( (fakePosy - (5'b00011)) > 5'b10000)) ? (fakePosy == 0 ? 0 : -fakePosy) : -3;
					checker_st <= 3;
				 end else if(board[fakePosy + dy][fakePosx] == prevTurn) begin
					dy <= dy + 1;
					ycounter <= ycounter + 1;	
				 end else begin
					dy <= dy + 1;
					ycounter <= 0;
				 end
				 end //end case columns
			
			//figuring out the limits for diagonal checking
			3: begin
				
				//its really hard to explain why this is the case just draw the 8 edge cases for yourself to see why
				//these if statements is work
				//the idea is as follows: we need to always take the minimum of the abs value of the checking limit
				//used to check edge cases. 
				//these edge cases happen when we insert something that is close to the border.
				
				if ((-dx) >= (-dy)) begin
					diagoffset_min <= dy;
				end else if ((-dy) > (-dx)) begin
					diagoffset_min <= dx;
				end
				
				if (dxmax <= dymax) begin
					diagoffset_max <= dxmax;
				end else if (dxmax > dymax) begin
					diagoffset_max <= dymax;
				end
				
				checker_st <= 4;
			
				end
				
				4: begin
					//debug <= diagoffset_min;
					//score <= negdiagcounter;
					if (negdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					checker_st <= 7;
				end else if (negdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					checker_st <= 7;
				end else if(diagoffset_min > diagoffset_max) begin 
					checker_st <= 5;
				end else if(board[fakePosy + diagoffset_min][fakePosx + diagoffset_min] == prevTurn) begin
					diagoffset_min <= diagoffset_min + 1;
					negdiagcounter <= negdiagcounter + 1;	
				end else begin
					diagoffset_min <= diagoffset_min + 1;
					negdiagcounter <= 0;
				end
					
				end //end negdiag
				
				5: 
				
				//why am i doing the same computation again??
				//look closely, it is not the same
				begin
				if ((-dy) >= (dxmax)) begin
					diagoffset_max <= dxmax;
				end else if ((dxmax) > (-dy)) begin
					diagoffset_max <= dy;
				end
				
				if ((-dx) <= dymax) begin
					diagoffset_min <= dx;
				end else if ((-dx) > dymax) begin
					diagoffset_min <= dymax;
				end
				
				checker_st <= 6;
				end
				
				6: 
				begin
				debug <= posdiagcounter;
				if (posdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					checker_st <= 7;
				end else if (posdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					checker_st <= 7;
				end else if(diagoffset_min > diagoffset_max) begin 
					checker_st <= 7;
				end else if(board[fakePosy - diagoffset_min][fakePosx + diagoffset_min] == prevTurn) begin
					diagoffset_min <= diagoffset_min + 1;
					posdiagcounter <= posdiagcounter + 1;	
				end else begin
					diagoffset_min <= diagoffset_min + 1;
					posdiagcounter <= 0;
				end
				end
				
				7:begin
				  end
				
		endcase
	
			
					 
endmodule