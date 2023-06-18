module top( 
	input clk,
	input logic0_button, logic1_button, activity_button,
	output logic0, logic1, activity,
	output [1:0] led
); 

	reg [1:0] led_out;
	integer button_counter;
	integer count_enable; 
	integer clock1Hz;
	initial begin 
	clock1Hz = 0;
	led_out = 2'b00;
	button_counter = 0; 
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
		.p_edge(act_p),
		.n_edge(act_n)
	);

	always @(posedge clk) begin 
		if (logic0 == 1) begin 
			led_out[0] = ~led_out[0];
		end 
		if (logic1 == 1) begin 
			led_out[1] = ~led_out[1];
		end 
		if (act_p == 1) begin 
			count_enable = 1; 
		end 
		if (act_n == 1) begin 
			count_enable = 0;
			button_counter = 0;	
		end 
		if (count_enable == 1) begin 
			button_counter = button_counter + 1; 
		end 
		if (button_counter == 149_999_999) begin 
			led_out = 2'b11; 
		end 
	end 
	assign led[0] = led_out[0];
	assign led[1] = led_out[1];
endmodule 