`timescale 1ns / 1ps

module vgaDecoder(
    input [2:0] rgb,
    output [23:0] vga
); 
	 
    assign vga[23:16] = (rgb[2] == 1) ? 8'hFF:8'h00;
    assign vga[15:8] = (rgb[1] == 1) ? 8'hFF:8'h00;
    assign vga[7:0] = (rgb[0] == 1) ? 8'hFF:8'h00;
    
endmodule
