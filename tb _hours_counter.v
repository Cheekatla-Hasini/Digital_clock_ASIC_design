`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2026 04:08:53 PM
// Design Name: 
// Module Name: tb _hours_counter
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



`timescale 1ns/1ps

module tb_hours_counter;

    reg clk;
    reg rst_n;
    reg hour_tick;

    wire [4:0] hour_count;

    integer i;
    integer errors;

    // DUT instantiation
    hours_counter uut (
        .clk(clk),
        .rst_n(rst_n),
        .hour_tick(hour_tick),
        .hour_count(hour_count)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin

        // Initialize
        clk = 0;
        rst_n = 1;
        hour_tick = 0;
        errors = 0;

        // Test 1: Asynchronous reset
        #2;
        rst_n = 0;
        #2;

        if (hour_count !== 5'd0) begin
            $display("FAIL: Reset");
            errors = errors + 1;
        end
        else
            $display("PASS: Reset");

        // Release reset
        @(negedge clk);
        rst_n = 1;

        // Test 2: Hold condition
        repeat (3) begin
            @(posedge clk);
            #1;
        end

        if (hour_count !== 5'd0) begin
            $display("FAIL: Hold condition");
            errors = errors + 1;
        end
        else
            $display("PASS: Hold condition");

        // Test 3: Count from 1 to 23
        for (i = 1; i <= 23; i = i + 1) begin

            @(negedge clk);
            hour_tick = 1;

            @(posedge clk);
            #1;

            if (hour_count !== i) begin
                $display("FAIL: Expected %0d, Got %0d",
                         i, hour_count);
                errors = errors + 1;
            end
            else
                $display("PASS: Hour count = %0d",
                         hour_count);
        end

        // Test 4: Rollover from 23 to 0
        @(negedge clk);
        hour_tick = 1;

        @(posedge clk);
        #1;

        if (hour_count !== 5'd0) begin
            $display("FAIL: Rollover 23 to 0");
            errors = errors + 1;
        end
        else
            $display("PASS: Rollover 23 to 0");

        // Test 5: Counter holds when enable is 0
        @(negedge clk);
        hour_tick = 0;

        repeat (3) begin
            @(posedge clk);
            #1;
        end

        if (hour_count !== 5'd0) begin
            $display("FAIL: Counter hold after rollover");
            errors = errors + 1;
        end
        else
            $display("PASS: Counter hold after rollover");

        // Final result
        $display("--------------------------------");
        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("TEST FAILED: %0d errors", errors);

        $display("--------------------------------");

        #10;
        $finish;
    end

    // Waveform generation
    initial begin
        $dumpfile("hours_counter.vcd");
        $dumpvars(0, tb_hours_counter);
    end

endmodule

