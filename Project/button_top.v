module button_top( 
	input clk,
	input logic0_button, logic1_button, activity_button,
	output logic0, logic1, activity,
	output reg activity_reset
); 
	parameter PUSH_TIME = 159_999_999;
	integer button_timer;
	integer count_enable;
	
	initial begin 
		count_enable = 0;
		button_timer = 0; 
	end  
	
	button logic0_btn (
		.clk(clk),
		.button(logic0_button),
		.p_edge(logic0)
	);
	button logic1_btn (
		.clk(clk),
		.button(logic1_button),
		.p_edge(logic1)
	);
	button activity_btn (
		.clk(clk),
		.button(activity_button),
		.n_edge(activity),
		.p_edge(act_n)
	);
	
	always @(posedge clk) begin 
		if (act_n == 1) begin 
			count_enable <= 1; 
		end 
		if (activity == 1) begin 
			count_enable <= 0;
			button_timer <= 0;	
		end 
		if (count_enable == 1) begin 
			button_timer <= button_timer + 1; 
		end 
		if (button_timer == PUSH_TIME) begin
			activity_reset <= 1;
			button_timer <= 0;	
		end else begin
			activity_reset <= 0;
		end
	end
endmodule 