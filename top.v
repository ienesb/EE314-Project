`timescale 1ns / 1ps

module top(
    input clk,
    input [3:0] wasd,
    output Hsynq,
    output Vsynq,
    output [3:0] vgaRed, 
    output [3:0] vgaGreen, 
    output [3:0] vgaBlue
);
    parameter IMG_WIDTH = 640;
    parameter IMG_HEIGHT = 480;
        
    wire clk_25_MHz;
    wire clk_50_Hz;
    reg [31:0] div_value = 1;
    reg [31:0] div_value2 = 999999;
    
    wire enable_V_Counter;
    wire [15:0] H_Count_Value;
    wire [15:0] V_Count_Value;
    
    wire [15:0] frameX;
    wire [15:0] frameY;

    wire [2:0] rgb;
    wire [11:0] vga;
    
    assign frameX = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? (H_Count_Value - 144): 16'b0000000000000000;
    assign frameY = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? (V_Count_Value - 35): 16'b0000000000000000;
    
    rgbSelector rgbs(frameX, frameY, rgb);

    clock_divider cd(clk, div_value, clk_25_MHz);
    clock_divider cd2(clk, div_value2, clk_50_Hz);
    
    horizontal_counter VGA_Horiz(clk_25_MHz, enable_V_Counter, H_Count_Value);
    vertical_counter VGA_Verti(clk_25_MHz, enable_V_Counter, V_Count_Value);
    
    vgaDecoder vd(rgb, vga);
    
    assign Hsynq = (H_Count_Value < 96) ? 1'b1:1'b0;
    assign Vsynq = (V_Count_Value < 2) ? 1'b1:1'b0;
    
    assign vgaRed = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[11:8]:4'h0;
    assign vgaGreen = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[7:4]:4'h0;
    assign vgaBlue = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34) ? vga[3:0]:4'h0;
    
endmodule
