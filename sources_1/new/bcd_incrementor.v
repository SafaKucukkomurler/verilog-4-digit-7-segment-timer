`timescale 1ns / 1ps

module bcd_incrementor(
input clk,
input incr_i,
input rst_i,
output reg [3:0] birler_o, onlar_o
    );
    
    initial begin
        birler_o = 4'b0; 
        onlar_o = 4'b0;
    end
    
    parameter [3:0] birler_lim = 4'd9, onlar_lim = 4'd9;
    
    always@ (posedge clk) begin
    
        if (incr_i == 1'b1) begin
            if (birler_o == birler_lim) begin
                if (onlar_o == onlar_lim) begin
                    birler_o <= 4'b0;
                    onlar_o <= 4'b0;
                end
                else begin
                    birler_o <= 4'b0;
                    onlar_o <= onlar_o + 4'b1;
                end
            end
            else begin
                birler_o <= birler_o + 1'b1; 
            end    
        end
        
        if (rst_i == 1'b1) begin
            birler_o <= 4'b0;
            onlar_o <= 4'b0;
        end
                
    end    
    
endmodule
