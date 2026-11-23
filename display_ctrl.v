
module display_ctrl(
    input wire [4:0] hour_count,
    input wire [5:0] min_count,
    input wire [5:0] sec_count,

    output reg [3:0] hour_tens,
    output reg [3:0] hour_ones,

    output reg [3:0] min_tens,
    output reg [3:0] min_ones,

    output reg [3:0] sec_tens,
    output reg [3:0] sec_ones
);

// Combinational logic for binary to BCD conversion

always @(*) begin

    // Convert hours
    hour_tens = hour_count / 10;
    hour_ones = hour_count % 10;

    // Convert minutes
    min_tens = min_count / 10;
    min_ones = min_count % 10;

    // Convert seconds
    sec_tens = sec_count / 10;
    sec_ones = sec_count % 10;

end

endmodule

`timescale 1ns / 1ps

module tb_display_ctrl;

reg [4:0] hour_count;
reg [5:0] min_count;
reg [5:0] sec_count;

wire [3:0] hour_tens;
wire [3:0] hour_ones;
wire [3:0] min_tens;
wire [3:0] min_ones;
wire [3:0] sec_tens;
wire [3:0] sec_ones;

// Instantiate DUT

display_ctrl DUT (
    .hour_count(hour_count),
    .min_count(min_count),
    .sec_count(sec_count),

    .hour_tens(hour_tens),
    .hour_ones(hour_ones),
    .min_tens(min_tens),
    .min_ones(min_ones),

    .sec_tens(sec_tens),
    .sec_ones(sec_ones)
);

// Apply test inputs

initial begin

    $display("Starting Display Controller Verification");

    // Test 1
    hour_count = 0;
    min_count  = 0;
    sec_count  = 0;
    #10;

    // Test 2
    hour_count = 14;
    min_count  = 35;
    sec_count  = 48;
    #10;

    // Test 3
    hour_count = 23;
    min_count  = 59;
    sec_count  = 59;
    #10;

    // Test 4
    hour_count = 9;
    min_count  = 10;
    sec_count  = 20;
    #10;

    // Test 5
    hour_count = 12;
    min_count  = 45;
    sec_count  = 56;
    #10;

    $display("Verification completed");

    $finish;

end

// Monitor outputs

initial begin

    $monitor("Time = %0d%0d:%0d%0d:%0d%0d",
        hour_tens, hour_ones,
        min_tens, min_ones,
        sec_tens, sec_ones);

end

endmodule
