module controller(
						input clk,
						input logic_0_button,
						input logic_1_button,
						input activity_button,
						output reg [7:0] debug, //debuging variables
						output reg [7:0] prevStatedebug
						);

//
reg [1:0] board [9:0][9:0];
//cannot be declared as output becuz verilog


// state definitions

reg [2:0] game_st;

parameter parse_inp_st = 3'b000; //reads the input
parameter trig_st = 3'b001;
parameter circ_st = 3'b010;
parameter sqr_st = 3'b011;
parameter invld_mv_st = 3'b100;
parameter win_chck_st = 3'b101; //most probably resetting will be done in this state
parameter rst_st = 3'b110; //not going to be needed most probably
parameter rnd_st = 3'b111; // bonus



// internal variables and counters
parameter dbparam = 'd1; //change this for the time of debouncing. also change the parse_inp_st if statement conditions
parameter buttonactivehighlow = 1; //set as 0 for active low behavior


integer pressCounterx = 0; //counts the number of inputted x and y bits
integer pressCountery = 0;

reg [2:0] prevTurn; //keeps track of who played last
reg [4:0] y; // the location we should place the circle or triangle at
reg [4:0] x; //extra bit for 2's complement operations later

//for initializing the board with 0
integer i;
integer j;


// db = debouncing
integer db0, db1, dba;

// intialization of the game
initial begin

	y[4] = 0;
	x[4] = 0;
	
	game_st = parse_inp_st;
	prevTurn = trig_st;
	debug <= 0;
	
	//debouncing counters
	db0 = 0;
	db1 = 0;
	dba = 0;
	

	for(i = 0; i <= 9; i = i + 1)
	begin
		for(j = 0; j <= 9; j = j + 1)
		begin
		board[i][j] = 'b00;
		end
	end
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
		//debug <= pressCounterx + pressCountery;
		
	end else if (pressCounterx == 4 && pressCountery == 4) begin
		//prevStatedebug <= {y, x};
		game_st <= invld_mv_st;
		//debug <= 7;
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
			game_st <= win_chck_st;
			//debug <= 15; 
		end
		
	end //end case 2
	
	win_chck_st: begin
		
	end // end case 3
	endcase
	end //end the always blocks 	
	
endmodule

						