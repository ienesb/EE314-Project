module controller(
						input clk,
						input logic_0_button,
						input logic_1_button,
						input activity_button,
						input activity_reset,
						input [6:0] addr,
						output reg [1:0] q_a,
						output [4:0] xout, //x
						output [4:0] yout, //y 
						output [4:0] scoreCircOut, //scoreCirc
						output [4:0] scoreTrigOut, // scoreTrig
						output [1:0] currentTurn, //prevTurn
						output [3:0] pressCounterxOut,
						output [3:0] pressCounteryOut,
						output [2:0] st_out,
						output debugOut,
						output reg winCondition,
						output reg [3:0] movTrig,
						output reg [3:0] movCirc,
						output reg [1:0] slope,
						output reg [6:0] lastMovx,
						output reg [6:0] lastMovy,
						output reg recentMovflag,
						output reg bonus1,
						output reg [3:0] rptx,
						output reg [3:0] rpty,
						output reg [3:0] rpcx,
						output reg [3:0] rpcy,
						output reg [3:0] xpre,
						output reg [3:0] ypre,
						output reg drawCon,
						output reg error
 						);

//////////////////////////////////////start of variable declarations////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

// reg [1:0] board [9:0][9:0];
reg [1:0] board [128];
reg [8:0] bookKeeper[25:0];
//board coordinates are the in format [y][x] or [row][column]
//x is + to the right
//y is + downwards
//bookKeeper keeps list of played coordinates

// state definitions

reg [2:0] game_st = parse_inp_st;

parameter parse_inp_st = 3'b000; //reads the input
parameter invld_mv_st = 3'b001; 
parameter win_chck_st = 3'b010; 
parameter modulo_st = 3'b011;
parameter rst_st = 3'b111; 
 
//other parameters
parameter rstParam = 'd50_0000_000; //number of seconds * 50mill
parameter movParam = 25;				// max number of moves
parameter buttonactivehighlow = 1; //set as 0 for active low behavior



// internal variables and counters
integer movCounter = 0; //counts the number of total moves played
reg [31:0] rstCounter = 0; // counts the second for resetting
reg [3:0] pressCounterx = 0; //counts the number of inputed x and y bits
reg [3:0] pressCountery = 0;
integer bookKeeperrst = 0;

//for initializing the board with some values
integer i;
integer j;
integer i2;
integer j2;
integer i3;
integer j3;


reg [1:0] prevTurn = 0; //keeps track of who played last
reg [4:0] y; // the location we should place the circle or triangle at
reg [4:0] x; //extra bit for 2's complement operations later

reg firstMove = 1; // i dont understand how or why this solves the bug but it does



///////////////////////////////////////////////win checking variables/////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//scores
integer scoreTrig = 0;
integer scoreCirc = 0;

// the  looping limits 
integer dxmin, dymin, dxmax, dymax, negdiagoffset_min, negdiagoffset_max, posdiagoffset_min, posdiagoffset_max;


//the looping iterators
integer dx, dy, negdiagoffset, posdiagoffset;


//counters for the number of consecutive similar shapes
integer xcounter = 0;
integer ycounter = 0;
integer posdiagcounter = 0;
integer negdiagcounter = 0;

integer checker_st = 0; //0&1 determine limits, 2 row and column checking, 3 diagonal checking


//////////////////////////////////////////////end of win checking variables/////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////end of all variables//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// intialization of the game
initial begin
	y[4] = 0;
	x[4] = 0;
	
	for(i = 0; i <= 9; i = i + 1)
		begin
			for(j = 0; j <= 9; j = j + 1)
			begin
				board[i*10+j] = 2'b00;
			end
		end
end


always @(posedge clk) begin
	q_a <= board[addr];
	
end


//state machine
always @(posedge clk)
begin
	case (game_st)
	
	//input code idea:
	//first we input the y location
	//when have entered 4 digits we start inputting the x coordintate(check the if statement condition)
	
	parse_inp_st: begin

	xcounter <= 0;
	ycounter <= 0;
	negdiagcounter <= 0;
	posdiagcounter <= 0;
	checker_st <= 0;
	//
	if(movCounter == movParam) begin
		movCounter <= movCounter + 1;
		game_st <= modulo_st;
		pressCounterx <= 0;
		pressCountery <= 0;
	end else if(activity_reset == 1) begin 
		pressCounterx <= 0;
		pressCountery <= 0;
		x <= 0;
		y <= 0;
		game_st <= parse_inp_st;	
	end else if (firstMove == 1) begin
		prevTurn <= 'b01;
		firstMove <= 0;
	end else if(logic_0_button == buttonactivehighlow && pressCountery <= 3) begin
		y[pressCountery] <= 1'b0; 
		pressCountery <= pressCountery + 'd1;
	end else if (logic_1_button == buttonactivehighlow && pressCountery <= 3) begin
		y[pressCountery] <= 1'b1; 
		pressCountery <= pressCountery + 'd1;
	end else if ((logic_0_button == buttonactivehighlow)  && ((pressCountery == 'd4) && pressCounterx <= 3)) begin 
		x[pressCounterx] <= 1'b0; 
		pressCounterx <= pressCounterx + 'd1;
	end else if ( (logic_1_button == buttonactivehighlow) && ((pressCountery == 'd4) && (pressCounterx <= 3)) ) begin 
		x[pressCounterx] <= 1'b1; 
		pressCounterx <= pressCounterx + 'd1;
	end else if (pressCounterx == 4 && pressCountery == 4 && activity_button == buttonactivehighlow) begin
		game_st <= invld_mv_st;
		xpre <= x;
		ypre <= y;
		bonus1 <= 1;
	end else if ((pressCounterx < 4 || pressCountery < 4) && activity_button == buttonactivehighlow) begin
		pressCounterx <= 0;
		pressCountery <= 0;
		x <= 0;
		y <= 0;
		game_st <= parse_inp_st;
	end
	end //end case 1 
	
	
	invld_mv_st:begin
		
		bonus1 <= 0;
		// reset the counters for future use
		pressCounterx <= 0;
		pressCountery <= 0;
		x[4] = 'b0;
		y[4] = 'b0;
		
		//if (ypre<10 && xpre<10 && bonus1 )
		//if input is greater than 10 or if there is already an object in place input another location
		if (y >= 10 || x >= 10) begin
			game_st <= parse_inp_st;
			error <= 1;
		end else if (board[y*10+x][0] | board[y*10+x][1]) begin
			game_st <= parse_inp_st;
			error <= 1;
		end else begin
			error <= 0;
			game_st <= modulo_st;
			board[y*10+x] = prevTurn; // prevTurn = currentTurn
			bookKeeper[movCounter] = y*10+x;
			movCounter <= movCounter + 1;
			recentMovflag <= 1;
			if (prevTurn == 'b01) begin
				movTrig <= movTrig + 1;
				rptx <= x;
				rpty <= y;
			end
			else if (prevTurn == 'b10) begin
				movCirc <= movCirc + 1;
				rpcx <= x;
				rpcy <= y;
			end
		end
		
	end //end invld_mv_st
	
	
	modulo_st: begin
		recentMovflag <= 0;
		case (movCounter)
		
			movParam + 1:  begin
								game_st <= rst_st;
								end
			11: begin
			    board[bookKeeper[0]] = 2'b11;
				 game_st <= win_chck_st;
				 end
			12: begin
				 board[bookKeeper[1]] = 2'b11;
				 game_st <= win_chck_st;
				 end
			23: begin
				 board[bookKeeper[2]] = 2'b11;
				 game_st <= win_chck_st;
				 end
			24: begin
				 board[bookKeeper[3]] = 2'b11;
				 game_st <= win_chck_st;
				 end
			default: game_st <= win_chck_st;
		endcase
	
		
		
		end // end modulo_st
	
	win_chck_st: begin
		case (checker_st)
			0: begin
				
				//if current position  - 3 < 0 then we loop until -currentPos
				//else the lower limit is directly -3
				//this is done to avoid iterating outside of the array at an index such 
				//as [-1][5]
				dxmin <= ( ( (x - (5'b00011)) > 5'b10000)) ? (-x) : -3; 
				dymin <= ( ( (y - (5'b00011)) > 5'b10000)) ? (-y) : -3;
		
				//if current position + 3 is > 10 then we loop until 10 only (i.e. loop counter is 
				//10 - current pos). else we loop for 3 counts
				dxmax <= ( ( (x + (5'b00011)) >= 5'b01010)) ? (10 - x) : 3;
				dymax <= ( ( (y + (5'b00011)) >= 5'b01010)) ? (10 - y) : 3;
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
			
				//row checking
				if (xcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b00;
					lastMovx <= x + dx - 1;
					lastMovy <= y;
				end else if (xcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b00;
					lastMovx <= x + dx - 1;
					lastMovy <= y;
				end else if(dx > dxmax) begin
					xcounter <= 0;
					checker_st <= 3;
				end else if(board[y*10 + x + dx] == prevTurn) begin
					dx <= dx + 1;
					xcounter <= xcounter + 1;	 
				end else if (board[y*10 + x + dx] != prevTurn)  begin
					dx <= dx + 1;
					xcounter <= 0;
				end			
			
				end//endcase
			
				//column checking
			3: begin
				if (ycounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b11;
					lastMovy <= y + dy - 1;
					lastMovx <= x;
				end else if (ycounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b11;
					lastMovy <= y + dy - 1;
					lastMovx <= x;
				end else if(dy > dymax) begin
					ycounter <= 0;
					checker_st <= 4;
				end else if(board[(y + dy)*10 + x] == prevTurn) begin
					dy <= dy + 1;
					ycounter <= ycounter + 1;	
				end else begin
					dy <= dy + 1;
					ycounter <= 0;
				end
				end
				
			4: begin
				//+ve slope diagonal checking
				if (posdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b01;
					lastMovy <= (y + posdiagoffset - 1);
					lastMovx <= x + posdiagoffset - 1;
				end else if (posdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b01;
					lastMovy <= (y + posdiagoffset - 1);
					lastMovx <= x + posdiagoffset - 1;
				end else if(posdiagoffset > posdiagoffset_max) begin 
					posdiagcounter <= 0; 
					checker_st <= 5;
				end else if(board[(y + posdiagoffset)*10+ x + posdiagoffset] == prevTurn) begin
					posdiagoffset <= posdiagoffset + 1;
					posdiagcounter <= posdiagcounter + 1;	
				end else begin
					posdiagoffset <= posdiagoffset + 1;
					posdiagcounter <= 0;
				end
				end
			
			5: begin
			
				//-ve slope diagonal checking
				if (negdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b10;	
					lastMovy <= (y - negdiagoffset + 1);
					lastMovx <= x + negdiagoffset - 1;
				end else if (negdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					game_st <= rst_st;
					winCondition <= 1;
					slope <= 'b10;
					lastMovy <= (y - negdiagoffset + 1);
					lastMovx <= x + negdiagoffset - 1;
				end else if(negdiagoffset > negdiagoffset_max) begin 
					negdiagcounter <= 0;
					checker_st <= 0;
					game_st <= parse_inp_st;
					pressCounterx <= 0;
					pressCountery <= 0;
					x <= 0;
					y <= 0;
					prevTurn[0] = ~prevTurn[0]; 
					prevTurn[1] = ~prevTurn[1];
				end else if(board[(y - negdiagoffset)*10 + x + negdiagoffset] == prevTurn) begin
					negdiagoffset <= negdiagoffset + 1;
					negdiagcounter <= negdiagcounter + 1;	
				end else begin
					negdiagoffset <= negdiagoffset + 1;
					negdiagcounter <= 0;
				end
		
			end // end diagonal checking
	
		endcase
		
	end //end win_chck_st
	
	
	rst_st: begin
	
				if(rstCounter == rstParam) begin
					//counter and condition reseting
					drawCon <= 0;
					winCondition <= 0;
					rstCounter <= 0;
					movCounter <= 0;
					i3 = 0;
					j3 = 0;
					bookKeeperrst = 0;
					movTrig <= 0;
					movCirc <= 0;
					
					//reinitialize the game
					game_st <= parse_inp_st;
					
					//clear the bookKeeper
					for(bookKeeperrst = 0; bookKeeperrst <= 25; bookKeeperrst = bookKeeperrst + 1) begin
						bookKeeper[bookKeeperrst] = 0;
				
					end
					
					//clear the board
					for(i3 = 0; i3 <= 9; i3 = i3 + 1)
					begin
						for(j3 = 0; j3 <= 9; j3 = j3 + 1)
						begin
							board[i3*10+j3] = 2'b00;
						end
					end
					end else begin
						rstCounter <= rstCounter + 1;
						drawCon <= 1;
					end
				
				end//end case
		default: game_st <= parse_inp_st;
		
	endcase
	end //end the always blocks 

	// assign turn = prevTurn;
	assign turn = (checker_st == 4) ? 1'b1:1'b0;
	
	assign xout = x[4:0];
	assign yout = y[4:0];
	assign scoreCircOut = scoreCirc[4:0];
	assign scoreTrigOut = scoreTrig[4:0];
	assign currentTurn = prevTurn;
	
	assign pressCounterxOut = pressCounterx;
	assign pressCounteryOut = pressCountery;
	
	assign st_out = game_st;
	assign debugOut = logic_0_button;
	
endmodule

						
