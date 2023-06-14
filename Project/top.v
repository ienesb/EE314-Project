`timescale 1ns / 1ps

module top(
    input CLOCK_50,
    input i0,
    input i1,
    output VGA_HS,
    output VGA_VS,
    output [7:0] VGA_R, 
    output [7:0] VGA_G, 
    output [7:0] VGA_B, 
    output VGA_SYNC_N, 
    output VGA_BLANK_N, 
    output VGA_CLK,
	 output o
);
    parameter IMG_WIDTH = 640;
    parameter IMG_HEIGHT = 480;
        
    wire clk_25_MHz;
    reg [31:0] div_value = 0;
    
    wire enable_V_Counter;
    wire [15:0] H_Count_Value;
    wire [15:0] V_Count_Value;
	 
    wire [2:0] rgb;
    wire [23:0] vga;
	 
    wire [15:0] frameX;
    wire [15:0] frameY;
    
	 wire [1:0] data_b;
	 
	 wire [6:0] addr_a;
    wire [6:0] addr_b;
	 
    wire we_b;
	 
	 wire [1:0] q_a;
    wire [1:0] q_b;
    
    clock_divider cd(CLOCK_50, div_value, clk_25_MHz);
    horizontal_counter VGA_Horiz(clk_25_MHz, enable_V_Counter, H_Count_Value);
    vertical_counter VGA_Verti(clk_25_MHz, enable_V_Counter, V_Count_Value);
    
	 assign frameX = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? (H_Count_Value - 144): 16'b0000000000000000;
    assign frameY = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? (V_Count_Value - 35): 16'b0000000000000000;
    
	 rgbSelector rgbs(CLOCK_50, frameX, frameY, q_a, rgb, addr_a);
	 board_memory board(
		 data_b,
		 addr_a, addr_b,
		 we_b, CLOCK_50,
		 q_a, q_b
	 );
	 // single_port_ram spr(3'b000, 640 * frameY + frameX, 1'b0, CLOCK_50, rgb);
    vgaDecoder vd(rgb, vga);
	 
	 
    assign VGA_HS = (H_Count_Value < 96) ? 1'b1:1'b0;
    assign VGA_VS = (V_Count_Value < 2) ? 1'b1:1'b0;
    
    assign VGA_R = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[23:16]:8'h00;
    assign VGA_G = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[15:8]:8'h00;
    assign VGA_B = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[7:0]:8'h00;
    
    assign VGA_SYNC_N = 0; 
    assign VGA_BLANK_N = 1;
    assign VGA_CLK = clk_25_MHz;
	 assign o = i0&i1;
	 
endmodule
