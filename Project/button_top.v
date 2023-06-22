module button_top( 
	input clk,
	input logic0_button, logic1_button, activity_button,
	output logic0, logic1, activity,
	output reg activity_reset,
	output [7:0] led
); 
	parameter PUSH_TIME = 149_999_999;
	reg [7:0] led_out;
	integer button_timer;
	integer button_counter;
	integer count_enable;
	
	initial begin 
		led_out = 7'b00;
		button_counter = 0;
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
		if (logic0 == 1 & logic1 == 1 & button_counter < 8) begin
			led_out[button_counter] <= 'b1;
			button_counter <= button_counter + 1;
		end
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
			led_out <= 7'b00;
			button_counter <= 0;
			button_timer <= 0;	
		end else begin
			activity_reset <= 0;
		end
		end
		assign led[7:0] = led_out[7:0];	
endmodule 