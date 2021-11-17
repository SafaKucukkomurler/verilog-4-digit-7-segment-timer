`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.12.2020 15:38:08
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer(
input clk,
input signal_i,
output reg signal_o
    );
    
    parameter c_clkfreq = 100_000_000,
              c_debtime = 1000,
              c_initval = 1'b0;
              //c_timerlim = c_clkfreq / c_debtime;
             
    reg [31:0] c_timerlim = 32'd100000;
    localparam S_INITIAL = 3'b000, S_ZERO = 3'b001, S_ZEROTOONE = 3'b010, S_ONE = 3'b011, S_ONETOZERO = 3'b100;
    reg [2:0] state = S_INITIAL;
    reg [16:0] timer = 17'b0, timer_en = 1'b0, timer_tick = 1'b0;
    
    always@ (posedge clk) begin
    
        case (state)
        
            S_INITIAL: begin
                if (c_initval == 1'b0)
                    state = S_ZERO;
                else
                    state = S_ONE;
            end
                    
            S_ZERO: begin
                signal_o <= 1'b0;
                
                if (signal_i == 1'b1)
                    state <= S_ZEROTOONE;
            end
                  
            S_ZEROTOONE: begin
                signal_o <= 1'b0;
                timer_en <= 1'b1;
                
                if (timer_tick == 1'b1) begin
                    state <= S_ONE;
                    timer_en <= 1'b0;
                end
                
                if (signal_i == 1'b0) begin
                    state <= S_ZERO;
                    timer_en <= 1'b0;
                end
            end
            
            S_ONE: begin
                signal_o <= 1'b1;
                
                if (signal_i == 1'b0)
                    state <= S_ONETOZERO;
            end
            
            S_ONETOZERO: begin
                signal_o <= 1'b1;
                timer_en <= 1'b1;
                
                if (timer_tick == 1'b1) begin
                    state <= S_ZERO;
                    timer_en <= 1'b0;
                end
                
                if (signal_i == 1'b1) begin
                    state <= S_ONE;
                    timer_en <= 1'b0;
                end
            end
            
        endcase
        
        if (timer_en == 1'b1) begin
            if (timer == (c_timerlim - 17'b1)) begin
                timer_tick <= 1'b1;
                timer <= 17'b0;
            end    
            else begin
                timer_tick <= 1'b0;
                timer <= timer + 17'b1;
            end
        end       
        else begin
            timer <= 17'b0;
            timer_tick <= 1'b0;
        end    
            
    end 
                      
endmodule
