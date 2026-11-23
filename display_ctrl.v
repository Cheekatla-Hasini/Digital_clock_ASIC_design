
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

