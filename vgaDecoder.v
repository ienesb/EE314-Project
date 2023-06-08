`timescale 1ns / 1ps

module vgaDecoder(
    input [2:0] rgb,
    output [11:0] vga
); 
    assign vga[11] = rgb[2];
    assign vga[10] = rgb[2];
    assign vga[9] = rgb[2];
    assign vga[8] = rgb[2];
    
    assign vga[7] = rgb[1];
    assign vga[6] = rgb[1];
    assign vga[5] = rgb[1];
    assign vga[4] = rgb[1];
    
    assign vga[3] = rgb[0];
    assign vga[2] = rgb[0];
    assign vga[1] = rgb[0];
    assign vga[0] = rgb[0];
    
endmodule
