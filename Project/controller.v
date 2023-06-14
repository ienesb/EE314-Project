module controller(
						input clk,
						input logic_0_button,
						input logic_1_button,
						input activity_button,
						output reg [9:0] debug, //debuging variables
						output reg [9:0] prevStatedebug
						);

//////////////////////////////////////start of variable declarations////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

reg [1:0] board [9:0][9:0];
//board coordinates are the in format [y][x] or [row][column]
//x is + to the right
//y is + downwards


// state definitions

reg [2:0] game_st;

parameter parse_inp_st = 3'b000; //reads the input
parameter trig_st = 3'b001;
parameter circ_st = 3'b010;
parameter sqr_st = 3'b011;
parameter invld_mv_st = 3'b100;
parameter win_chck_st = 3'b101; //most probably resetting will be done in this state
parameter rst_st = 3'b110; //not going to be needed most probably
parameter modulo_st = 3'b111; // bonus



// internal variables and counters
parameter dbparam = 'd1; //change this for the time of debouncing. also change the parse_inp_st if statement conditions
parameter buttonactivehighlow = 1; //set as 0 for active low behavior


integer pressCounterx = 0; //counts the number of inputed x and y bits
integer pressCountery = 0;

reg [1:0] prevTurn; //keeps track of who played last
reg [4:0] y; // the location we should place the circle or triangle at
reg [4:0] x; //extra bit for 2's complement operations later

//for initializing the board with 0
integer i;
integer j;

///////////////////////////////////////////////win checking variables/////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//scores
integer scoreTrig, scoreCirc;

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

// db = debouncing
integer db0, db1, dba;

//////////////////////////////////////////////end of all variables//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// intialization of the game
initial begin

	y[4] = 0;
	x[4] = 0;
	
	game_st = parse_inp_st;
	prevTurn = 2'b01;
	debug <= 0;
	
	//debouncing counters
	db0 = 0;
	db1 = 0;
	dba = 0;
	
	
	//fills the board with all empty cells
	for(i = 0; i <= 9; i = i + 1)
	begin
		for(j = 0; j <= 9; j = j + 1)
		begin
		board[i][j] = 'b00;
		end
	end
	
	scoreCirc = 0;
	scoreTrig = 0;
end

//button debouncing
always @(posedge clk) begin

		// debouncing logic:
		// we count up for some clock cycle to make sure that the button transience has died down. 
		// the limit is controlled by dbparam
		// note: buttons are active low
		
		if (logic_0_button == buttonactivehighlow && db0 < dbparam) begin
			db0 <= db0 + 'd1;
		end else if (logic_0_button == ~buttonactivehighlow) begin
			db0 <= 0;
		end
		
		if (logic_1_button == buttonactivehighlow && db1 < dbparam) begin
			db1 <= db1 + 'd1;
		end else if (logic_1_button == ~buttonactivehighlow) begin
			db1 <= 0;
		end
		
		if (activity_button == buttonactivehighlow && dba < dbparam) begin
			dba <= dba + 'd1;
		end else if (activity_button == ~buttonactivehighlow) begin
			dba <= 0;
		end
	end




	
//state machine
always @(posedge clk)
begin
	case (game_st)
	
	//input code idea:
	//first we input the y location
	//when have entered 4 digits we start inputting the x coordintate(check the if statement condition)
	
	parse_inp_st: begin
		
	if(logic_0_button == buttonactivehighlow && pressCountery <= 3) begin
		y[pressCountery] <= 1'b0; 
		pressCountery <= pressCountery + 'd1;
		//debug <= pressCounterx + pressCountery;
		
	end else if (logic_1_button == buttonactivehighlow && pressCountery <= 3) begin
		y[pressCountery] <= 1'b1; 
		pressCountery <= pressCountery + 'd1;
		//debug <= pressCounterx + pressCountery;
		
	end else if (logic_0_button == buttonactivehighlow  && ((pressCountery == 'd4) && pressCounterx <= 3)) begin 
		x[pressCounterx] <= 1'b0; 
		pressCounterx <= pressCounterx + 1;
		//debug <= pressCounterx + pressCountery;
		
	end else if ( (logic_1_button == buttonactivehighlow) && ((pressCountery == 'd4) && (pressCounterx <= 3)) ) begin 
		x[pressCounterx] <= 1'b1; 
		pressCounterx <= pressCounterx + 'd1;
		debug <= y;
		//debug <= pressCounterx + pressCountery;
		
	end else if (pressCounterx == 4 && pressCountery == 4 && activity_button == buttonactivehighlow) begin
		prevStatedebug <= {y,x};
		game_st <= invld_mv_st;
		
	end
	end //end case 1 
	
	invld_mv_st:begin
		
		
		// reset the counters for future use
		pressCounterx <= 0;
		pressCountery <= 0;
		
		//debuging
		//board[3][3] = 2'b00;
		
		//if input is greater than 10 or if there is already an object in place input another location
		if (y > 10 || x > 10) begin
			game_st <= parse_inp_st;
			//debug <= 14;
		end else if (board[y][x][0] | board[y][x][1]) begin
			game_st <= parse_inp_st;
			//debug <= 13;
		end else begin
			game_st <= modulo_st;
			board[y][x] = prevTurn;
			//debug <= 15; 
		end
		
	end //end invld_mv_st
	
	modulo_st: begin
		//nonmodule related stuff just preparations for win checking
		
		//for testing reasons
		game_st <= win_chck_st;
		//game_st <= parse_inp_st;
		//prevTurn[0] = ~prevTurn[0]; //activate these statemetns and turn off the other one for testing reasons
		//prevTurn[1] = ~prevTurn[1];
		
		
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
			
				//////////////////////////////////////////
						//row debugging//
						//x debugging//
				board[2][1] = 2'b11;
				board[2][2] = 2'b11;
				board[2][3] = 2'b11; 
				board[2][4] = 2'b11;
				board[2][5] = 2'b11;
				board[2][6] = 2'b11;
				board[2][7] = 2'b11; 
				board[2][8] = 2'b11;
				
						//column debugging
						//y debugging
				board[0][2] = 2'b11;
				board[1][2] = 2'b11;
				board[2][2] = 2'b11;
				board[3][2] = 2'b01;
				board[4][2] = 2'b11;
				board[5][2] = 2'b11;
				board[6][2] = 2'b11;
				board[7][2] = 2'b11;
			
				//row checking
				if (xcounter == 4 & prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					checker_st <= 6;
				end else if (xcounter == 4 && prevTurn == 2'b10) begin 
					scoreCirc <= scoreCirc + 1;
					checker_st <= 6;
				end else if(dx > dxmax) begin
					xcounter <= 0;
				end else if(board[y][x + dx] == prevTurn) begin
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
				end else if(board[y + dy][x] == prevTurn) begin
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

					//positive diag debug
				board[1][1] = 2'b10;
				board[2][2] = 2'b11;
				board[3][3] = 2'b11;
				board[4][4] = 2'b10;
				board[5][5] = 2'b11;
				board[6][6] = 2'b11;
				board[7][7] = 2'b11;
				board[8][8] = 2'b10;
				board[9][9] = 2'b10;
				
				
				//negative diag debug	
				board[1][9] = 2'b10;
				board[2][8] = 2'b10;
				board[3][7] = 2'b10;
				board[4][6] = 2'b10;
				board[5][5] = 2'b11;
				board[6][4] = 2'b10;
				board[7][3] = 2'b10;
				board[8][2] = 2'b10;
				board[9][1] = 2'b10;
		
				//+ve slope diagonal checking
				if (posdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					checker_st <= 7;
				end else if (posdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					checker_st <= 7;
				end else if(posdiagoffset > posdiagoffset_max) begin 
					posdiagcounter <= 0; //
				end else if(board[y + posdiagoffset][x + posdiagoffset] == prevTurn) begin
					posdiagoffset <= posdiagoffset + 1;
					posdiagcounter <= posdiagcounter + 1;	
				end else begin
					posdiagoffset <= posdiagoffset + 1;
					posdiagcounter <= 0;
				end
			
				
				//-ve slope diagonal checking
				if (negdiagcounter == 4 && prevTurn == 2'b01) begin
					scoreTrig <= scoreTrig + 1;
					checker_st <= 7;
				end else if (negdiagcounter == 4 && prevTurn == 2'b10) begin
					scoreCirc <= scoreCirc + 1;
					checker_st <= 7;
				end else if(negdiagoffset > negdiagoffset_max) begin 
					negdiagcounter <= 0;
				end else if(board[y - negdiagoffset][x + negdiagoffset] == prevTurn) begin
					negdiagoffset <= negdiagoffset + 1;
					negdiagcounter <= negdiagcounter + 1;	
				end else begin
					negdiagoffset <= negdiagoffset + 1;
					negdiagcounter <= 0;
				end
			
				if (negdiagoffset > negdiagoffset_max && posdiagoffset > posdiagoffset_max)
				begin
					game_st <= parse_inp_st;
					prevTurn[0] = ~prevTurn[0]; //activate these statemetns and turn off the other one for testing reasons
					prevTurn[1] = ~prevTurn[1];
				end
				end // end diagonal checking
			
		endcase
		
	end //end win_chck_st
	
	
	
	endcase
	end //end the always blocks 	
	
endmodule

						
