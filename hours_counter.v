
module hours_counter (
    input wire clk,
    input wire rst_n,
    input wire hour_tick,
    output reg [4:0] hour_count
);

    // 24-hour modulo counter
    always @(posedge clk or negedge rst_n)
    begin
        if (rst_n == 1'b0)
        begin
            hour_count <= 5'd0;
        end
        else if (hour_tick == 1'b1)
        begin
            if (hour_count == 5'd23)
                hour_count <= 5'd0;
            else
                hour_count <= hour_count + 1'b1;
        end
    end

endmodule