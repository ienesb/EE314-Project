`timescale 1ns / 1ps
module button(
    input clk,
    input button,
    output debounced,
    output p_edge, n_edge, _edge
    );
    
    debouncer_delayed DD0(
        .clk(clk),
        .noisy(button),
        .debounced(debounced)
    );
    
    edge_detector ED0(
        .clk(clk),
        .level(debounced),
        .p_edge(p_edge),
        .n_edge(n_edge),
        ._edge(_edge)
    );
    
endmodule
