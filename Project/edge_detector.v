`timescale 1ns / 1ps
module edge_detector(
    input clk,
    input level,
    output p_edge, n_edge, _edge
    );
    
    // Edge detector with Mealy outputs
    reg state_reg, state_next;
    parameter s0 = 0, s1 = 1;
    
    // Sequential state registers
    always @(posedge clk)
    begin
		state_reg <= state_next;
    end
    
    // Next state logic
    always @(*)
    begin
        case(state_reg)
            s0: if (level)
                    state_next = s1;
                else
                    state_next = s0;
            s1: if (level)
                    state_next = s1;
                else
                    state_next = s0;
            default: state_next = s0;                
        endcase
    end
    
    // Output logic
    assign p_edge = (state_reg == s0) & level;
    assign n_edge = (state_reg == s1) & ~level;
    assign _edge = p_edge | n_edge;
    
endmodule
