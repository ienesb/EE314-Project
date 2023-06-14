`timescale 1ns / 1ps

module rgbSelector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480)(
    input [15:0] x, 
    input [15:0] y,
    output [2:0] rgb
);

    reg [2:0] template [IMG_HEIGHT * IMG_WIDTH - 1:0];
//    
//    initial begin 
//        $readmemb("intro.mem", template);
//    end
	
    
    // assign rgb = template[IMG_WIDTH * y + x];
    assign rgb = 3'b111;
    
endmodule
