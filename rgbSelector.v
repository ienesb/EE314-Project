`timescale 1ns / 1ps

module rgbSelector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480)(
    input [15:0] x, 
    input [15:0] y,
    output [2:0] rgb
);
    integer i, j, k1, k2;

    reg [2:0] rgbReg = 3'b000;
    reg [2:0] rom [IMG_HEIGHT * IMG_WIDTH - 1:0];
    reg [1:0] block;
    reg [2:0] template [IMG_HEIGHT - 1:0][IMG_WIDTH - 1:0];
    reg [2:0] emptyBlock [29:0][29:0];
    reg [2:0] triBlock [29:0][29:0];
    reg [2:0] circBlock [29:0][29:0];
    reg [1:0] block = 2'b00;
    
    initial begin 
        $readmemb("intro.mem", rom);
        $readmemb("intro.mem", template);
        $readmemb("tri.mem", emptyBlock);
        $readmemb("tri.mem", triBlock);
        $readmemb("tri.mem", circBlock);
    end
    
    always @(*) begin
        if (x > 140 && x < 440 && y > 60 && y < 360) begin
            for(k1 = 0; k1 < 10; k1=k1+1) begin
                for(k2 = 0; k2 < 10; k2=k2+1) begin
                    if (k1*30 + 140 < x && k2*30 + 60 < y) begin
                        for (i = 0; i < 30; i = i+1) begin    
                            for (j = 0; j < 30; j = j+1) begin
                                case(block)
                                    2'b00: template[i + k2*30 + 60][j + k1*30 + 140] <= emptyBlock[i][j];
                                    2'b01: template[i + k2*30 + 60][j + k1*30 + 140] <= triBlock[i][j];
                                    2'b10: template[i + k2*30 + 60][j + k1*30 + 140] <= circBlock[i][j];
                                endcase
                            end
                        end  
                    end
                end
            end
        end
        else begin
            
        end
        rgbReg <= rom[IMG_WIDTH * y + x];
    end
    
//    assign rgb = rom[IMG_WIDTH * y + x];
    assign rgb = template[y][x];
//    assign rgb = rgbReg;
    
endmodule
