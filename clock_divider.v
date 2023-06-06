`timescale 1ns / 1ps

module clock_divider(
    input wire clk,
    input [31:0] div_value, // T = (div_value + 1)*2
    output reg divided_clk = 0
    );
    
    integer counter_value = 0;
    
    always @(posedge clk) begin
        if (counter_value == div_value) begin
            counter_value <= 0;
            divided_clk <= ~divided_clk;
        end else begin
            counter_value <= counter_value +1;
            divided_clk <= divided_clk;
        end
    end
    
endmodule
