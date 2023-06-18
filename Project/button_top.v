module button_top( 
	input clk,
	input logic0_button, logic1_button, activity_button,
	output logic0, logic1, activity
); 

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
		.p_edge(activity)
	);
endmodule 