`timescale 1ns / 1ps

module tb_minutes_counter;

    // Testbench signals
    reg        clk;
    reg        rst_n;
    reg        min_tick;
    wire [5:0] min_count;
    wire       hour_tick;

    integer errors = 0;
    integer i;

    // Instantiate the Unit Under Test (UUT)
    minutes_counter uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .min_tick  (min_tick),
        .min_count (min_count),
        .hour_tick (hour_tick)
    );

    // 100 MHz system clock generation (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Task to apply a single-cycle min_tick pulse and wait for the clock edge
    task pulse_min_tick;
        begin
            @(negedge clk);
            min_tick = 1'b1;
            @(posedge clk);
            #1; // Small delay to allow non-blocking outputs to settle
            @(negedge clk);
            min_tick = 1'b0;
        end
    endtask

    // Task to check expected outputs
    task check_state(input [5:0] exp_min, input exp_hour_tick, input [255:0] msg);
        begin
            if (min_count !== exp_min || hour_tick !== exp_hour_tick) begin
                $display("[FAIL] %0s | Time=%0t | Expected: min=%0d, hour_tick=%b | Got: min=%0d, hour_tick=%b",
                         msg, $time, exp_min, exp_hour_tick, min_count, hour_tick);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Waveform dump for GTKWave
        $dumpfile("tb_minutes_counter.vcd");
        $dumpvars(0, tb_minutes_counter);

        // Initialize inputs
        rst_n    = 1'b0;
        min_tick = 1'b0;

        // ------------------------------------------------------------
        // Test 1: Active-low asynchronous reset
        // ------------------------------------------------------------
        #12;
        check_state(6'd0, 1'b0, "Initial Reset");

        @(negedge clk);
        rst_n = 1'b1;

        // ------------------------------------------------------------
        // Test 2: Hold value when min_tick is deasserted (0)
        // ------------------------------------------------------------
        repeat (5) @(posedge clk);
        #1;
        check_state(6'd0, 1'b0, "Hold when min_tick=0");

        // ------------------------------------------------------------
        // Test 3: Count from 0 to 59 on single-cycle min_tick pulses
        // ------------------------------------------------------------
        for (i = 1; i <= 59; i = i + 1) begin
            pulse_min_tick();
            check_state(i[5:0], 1'b0, "Normal Increment (1 to 59)");
        end

        // Verify counter holds at 59 if min_tick stays 0
        repeat (3) @(posedge clk);
        #1;
        check_state(6'd59, 1'b0, "Hold at 59 when min_tick=0");

        // ------------------------------------------------------------
        // Test 4: Rollover (59 -> 00) and one-cycle hour_tick pulse
        // ------------------------------------------------------------
        @(negedge clk);
        min_tick = 1'b1;
        @(posedge clk);
        #1;
        check_state(6'd0, 1'b1, "Rollover 59->00 & hour_tick asserted");

        // Deassert min_tick and verify hour_tick drops after 1 cycle
        @(negedge clk);
        min_tick = 1'b0;
        @(posedge clk);
        #1;
        check_state(6'd0, 1'b0, "hour_tick deasserted after 1 cycle");

        // ------------------------------------------------------------
        // Test 5: Asynchronous reset mid-count
        // ------------------------------------------------------------
        repeat (10) pulse_min_tick();
        check_state(6'd10, 1'b0, "Count to 10 before mid-count reset");

        #3; // Assert reset asynchronously between clock edges
        rst_n = 1'b0;
        #1;
        check_state(6'd0, 1'b0, "Asynchronous Reset mid-count");

        @(negedge clk);
        rst_n = 1'b1;

        // ------------------------------------------------------------
        // Final Summary
        // ------------------------------------------------------------
        #20;
        if (errors == 0)
            $display("\n=== ALL TESTS PASSED: tb_minutes_counter ===\n");
        else
            $display("\n=== TEST FAILED: %0d error(s) found ===\n", errors);

        $finish;
    end

endmodule