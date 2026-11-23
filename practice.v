`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2026 04:54:00 PM
// Design Name: 
// Module Name: practice
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

module practice #(
    parameter CLK_FREQ_HZ = 50000000
)(
    input  wire clk,
    input  wire rst_n,
    output wire tick_1s
);

    localparam integer MAX_COUNT = (CLK_FREQ_HZ > 0) ? (CLK_FREQ_HZ - 1) : 0;

    reg [31:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 32'd0;
        end else if (count >= MAX_COUNT) begin
            count <= 32'd0;
        end else begin
            count <= count + 32'd1;
        end
    end

    assign tick_1s = (count == MAX_COUNT);

endmodule
`timescale 1ns / 1ps

module tb_practice;

    parameter SIM_CLK_HZ = 10;
    parameter CLK_PERIOD = 10;

    reg  clk;
    reg  rst_n;
    wire tick_1s;

    integer tick_count;
    integer err_count;

    practice #(
        .CLK_FREQ_HZ(SIM_CLK_HZ)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .tick_1s (tick_1s)
    );

    // Clock generator
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Count pulses
    always @(posedge clk) begin
        if (!rst_n) begin
            tick_count <= 0;
        end else if (tick_1s) begin
            tick_count <= tick_count + 1;
            $display("Time=%0t ns | tick_1s pulse #%0d", $time, tick_count + 1);
        end
    end

    // Stimulus
    initial begin
        err_count = 0;
        rst_n = 1'b0;
        #(CLK_PERIOD * 2);

        if (tick_1s !== 1'b0) begin
            $display("ERROR: tick_1s should be 0 during reset");
            err_count = err_count + 1;
        end

        @(posedge clk);
        #1;
        rst_n = 1'b1;

        // Run for 35 clock cycles (3 ticks expected when SIM_CLK_HZ = 10)
        repeat (SIM_CLK_HZ * 3 + 5) begin
            @(posedge clk);
        end

        if (tick_count !== 3) begin
            $display("ERROR: Expected 3 ticks, got %0d", tick_count);
            err_count = err_count + 1;
        end

        // Apply reset and verify tick_1s clears
        @(negedge clk);
        rst_n = 1'b0;
        #1;
        if (tick_1s !== 1'b0) begin
            $display("ERROR: tick_1s did not clear on reset");
            err_count = err_count + 1;
        end

        #(CLK_PERIOD * 2);
        @(negedge clk);
        rst_n = 1'b1;

        repeat (SIM_CLK_HZ + 2) begin
            @(posedge clk);
        end

        if (err_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", err_count);

        $finish;
    end

endmodule