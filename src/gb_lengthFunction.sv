/* Length Function for APU Channels

If enabled, the Length Function starts the length timer, which disables the
channel once it runs out until the next trigger.

Credit:
    VerilogBoy: https://github.com/zephray/VerilogBoy

Inputs:
    clk             - System Clock
    reset           - System Reset
    clk_length_ctr  - Length Function Clock
    start           - Start Signal
    single          - Length Enable
    length          - Initial Length Timer (6-bit for Ch 1,2,4 and 8-bit for Ch 3)

Outputs:
    enable          - Active while the length counter is still counting
Parameters:
    WIDTH           - Counter for length function, counts from [0, 2^^WIDTH]
                    - WIDTH = 6 for channels 1,2,4 and 8 for channel 3
*/
module gb_lengthFunction #(parameter WIDTH = 6) (
    input logic clk,
    input logic reset,
    input logic clk_length_ctr,
    input logic start,
    input logic single,
    input logic [WIDTH-1:0] length,
    output logic enable = 0
);
    // Up-Counter
    logic [WIDTH-1:0] length_left;

    // Length Control
    always_ff @(posedge clk) begin
        if (start) begin
            enable <= 1'b1;
            length_left <= (length == 0) ? ({WIDTH{1'b1}}) : (length);
        end
        else if (clk_length_ctr) begin
            if (single) begin
                if (length_left != {WIDTH{1'b1}})
                    length_left <= length_left + 1'b1;
                else
                    enable <= 1'b0;
            end
        end
        if (reset) begin
            enable <= 1'b0;
            length_left <= 0;
        end
    end

endmodule  // gb_lengthFunction
