`timescale 1ns / 1ps

module minutes_counter (
        input  wire       clk,
        input  wire       rst_n,
        input  wire       min_tick,
        output reg  [5:0] min_count,
        output reg        hour_tick
    );
    
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                min_count <= 6'd0;
                hour_tick <= 1'b0;
            end else begin
                // Default: keep hour_tick low unless a 59 -> 00 rollover occurs
                hour_tick <= 1'b0;
    
                if (min_tick) begin
                    if (min_count == 6'd59) begin
                        min_count <= 6'd0;
                        hour_tick <= 1'b1;
                    end else begin
                        min_count <= min_count + 6'd1;
                    end
                end
            end
        end
    
endmodule
