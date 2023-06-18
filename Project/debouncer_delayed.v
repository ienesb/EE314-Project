`timescale 1ns / 1ps
module debouncer_delayed(
    input clk,
    input noisy,
    output debounced
    );
    
    wire timer_done, timer_reset;
    
    debouncer_delayed_fsm FSM0(
        .clk(clk),
        .noisy(noisy),
        .timer_done(timer_done),
        .timer_reset(timer_reset),
        .debounced(debounced)
    );
    
    // 20 ms timer
    timer_parameter #(.FINAL_VALUE(19)) T0(
        .clk(clk),
        .enable(~timer_reset),
        .done(timer_done)
    );
endmodule
