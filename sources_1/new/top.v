`timescale 1ns / 1ps

module top(
input clk,
input reset_i,
input start_i,
output reg [6:0] seven_seg_o,
output [3:0] anodes_o
    );
    
    localparam c_saliselim = 1000000,
               c_saliseCount_lim = 100,
               c_saniyeCount_lim = 60;
               
    reg [31:0] c_timerlim_1ms = 32'd100000; //after success convert to localparam
    reg [31:0] timer_1ms = 32'b0;
               
    reg [19:0] saliseTimer = 20'b0;
    reg [6:0] saliseCount = 7'b0;
    reg [5:0] saniyeCount = 6'b0;	
    
    wire start_deb, reset_deb;
    debouncer start_debouncer(clk, start_i, start_deb);
    debouncer reset_debouncer(clk, reset_i, reset_deb);
    
    reg increment_salise = 1'b0, increment_saniye = 1'b0;
    wire [3:0] birler_salise, onlar_salise, birler_saniye, onlar_saniye; 
    bcd_incrementor #(.birler_lim(4'd9), .onlar_lim(4'd9)) salise_incr(clk, increment_salise, reset_deb, birler_salise, onlar_salise);
    bcd_incrementor #(.birler_lim(4'd9), .onlar_lim(4'd5)) saniye_incr(clk, increment_saniye, reset_deb, birler_saniye, onlar_saniye);
    
    wire [6:0] salise_birler_7seg, salise_onlar_7seg;
    wire [6:0] saniye_birler_7seg, saniye_onlar_7seg;
    reg [3:0] anodes = 4'b1110;
    
    seven_segment display_salise_birler(birler_salise, salise_birler_7seg);
    seven_segment display_salise_onlar(onlar_salise, salise_onlar_7seg);
    seven_segment display_saniye_birler(birler_saniye, saniye_birler_7seg);
    seven_segment display_saniye_onlar(onlar_saniye, saniye_onlar_7seg);
    
    reg start_deb_prev = 1'b0, continue = 1'b0;
    
    always@ (posedge clk) begin
        
        start_deb_prev <= start_deb;
        if (start_deb == 1'b1 && start_deb_prev == 1'b0) begin
            continue = ~continue;
        end
        
        increment_salise <= 1'b0;
        increment_saniye <= 1'b0;
        
        if (continue == 1'b1) begin
    
            if (saliseTimer == c_saliselim - 1'b1) begin
                increment_salise <= 1'b1;
                saliseTimer <= 20'b0;
                if (saliseCount == c_saliseCount_lim - 1'b1) begin
                    saliseCount <= 7'b0;
                    increment_saniye <= 1'b1;
                    if (saniyeCount == c_saniyeCount_lim - 1'b1) begin
                        saniyeCount <= 1'b0;
                    end
                    else begin
                        saniyeCount <= saniyeCount + 1'b1;
                    end
                end
                else begin
                    saliseCount <= saliseCount + 1'b1;
                end
            end
            else begin
                saliseTimer <= saliseTimer + 20'b1;
            end
        
        end
    
        if (reset_deb == 1'b1) begin
            saliseTimer <= 20'b0;
            saliseCount <= 7'b0;
            saniyeCount <= 6'b0;
        end
    
    end
    
    always@ (posedge clk) begin
        
        if (anodes[0] == 1'b0) begin
		  seven_seg_o <= salise_birler_7seg;
		end
	    else if (anodes[1] == 1'b0) begin
		  seven_seg_o <= salise_onlar_7seg;
		end
	    else if (anodes[2] == 1'b0) begin
		  seven_seg_o <= saniye_birler_7seg;
		 // seven_seg_o(0) <= '0';
		end
	    else if (anodes[3] == 1'b0) begin	
		  seven_seg_o <= saniye_onlar_7seg;
		end	    	
	    else begin
		  seven_seg_o	<= ~7'b0000000;
	    end
        
    end
    
    always@ (posedge clk) begin
    
        if (timer_1ms == c_timerlim_1ms - 32'b1) begin
            timer_1ms <= 32'b0;
            anodes <= (anodes << 1) | (anodes >> 3);
        end
        else begin
            timer_1ms <= timer_1ms + 32'b1;
        end
        
        
    end
    
    assign anodes_o = anodes;
    
endmodule
