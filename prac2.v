`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2026 04:57:22 PM
// Design Name: 
// Module Name: prac2
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
`timescale 1ns / 1ps

module prac2 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tick_1s,
    output reg  [5:0] sec_count,
    output wire       min_tick
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec_count <= 6'd0;
        end else if (tick_1s) begin
            if (sec_count >= 6'd59) begin
                sec_count <= 6'd0;
            end else begin
                sec_count <= sec_count + 6'd1;
            end
        end
    end

    // Generates a 1-clock-cycle pulse when rolling over from 59 to 0
    assign min_tick = (sec_count == 6'd59) && tick_1s;

endmodule

`timescale 1ns / 1ps

module tb_prac2;

    parameter CLK_PERIOD = 10;

    reg        clk;
    reg        rst_n;
    reg        tick_1s;
    wire [5:0] sec_count;
    wire       min_tick;

    integer min_pulse_count;
    integer err_count;

    // Instantiate the Unit Under Test (UUT)
    prac2 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .tick_1s   (tick_1s),
        .sec_count (sec_count),
        .min_tick  (min_tick)
    );

    // 100 MHz Clock Generator
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Monitor min_tick pulses
    always @(posedge clk) begin
        if (!rst_n) begin
            min_pulse_count <= 0;
        end else if (min_tick) begin
            min_pulse_count <= min_pulse_count + 1;
            $display("Time=%0t ns | min_tick pulsed! sec_count=%0d", $time, sec_count);
        end
    end

    // Task to generate a single-cycle tick_1s pulse
    task send_1s_tick;
        begin
            @(negedge clk);
            tick_1s = 1'b1;
            @(negedge clk);
            tick_1s = 1'b0;
            // Wait 2 extra clock cycles between ticks to mimic multi-cycle spacing
            repeat (2) @(posedge clk);
        end
    endtask

    // Main Stimulus
    initial begin
        err_count = 0;
        rst_n     = 1'b0;
        tick_1s   = 1'b0;

        // Hold reset for 2 clock cycles
        #(CLK_PERIOD * 2);
        if (sec_count !== 6'd0 || min_tick !== 1'b0) begin
            $display("ERROR: Outputs not zero during reset");
            err_count = err_count + 1;
        end

        // Release reset
        @(negedge clk);
        rst_n = 1'b1;

        // 1. Send 59 ticks: sec_count should reach 59, min_tick must stay 0
        repeat (59) begin
            send_1s_tick();
        end

        if (sec_count !== 6'd59) begin
            $display("ERROR: Expected sec_count = 59, got %0d", sec_count);
            err_count = err_count + 1;
        end

        // 2. Send 60th tick: min_tick should pulse high during tick_1s, then wrap to 0
        @(negedge clk);
        tick_1s = 1'b1;
        #1; // Small delay to check combinational min_tick output
        if (min_tick !== 1'b1) begin
            $display("ERROR: min_tick did not assert at sec_count = 59 with tick_1s = 1");
            err_count = err_count + 1;
        end

        @(negedge clk);
        tick_1s = 1'b0;
        if (sec_count !== 6'd0 || min_tick !== 1'b0) begin
            $display("ERROR: Failed to roll over to 0 cleanly");
            err_count = err_count + 1;
        end

        // 3. Send 15 more ticks, then test asynchronous reset
        repeat (15) begin
            send_1s_tick();
        end

        @(negedge clk);
        rst_n = 1'b0;
        #1;
        if (sec_count !== 6'd0) begin
            $display("ERROR: sec_count did not clear on reset");
            err_count = err_count + 1;
        end

        #(CLK_PERIOD * 2);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        if (err_count == 0 && min_pulse_count == 1)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", err_count);

        $finish;
    end

endmodule
